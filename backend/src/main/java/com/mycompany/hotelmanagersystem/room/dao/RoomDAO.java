package com.mycompany.hotelmanagersystem.room.dao;

import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.model.RoomType;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    /**
     * Lấy toàn bộ danh sách hạng phòng đang kinh doanh
     */
    public List<RoomType> getAllActiveRoomTypes() {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT rt.RoomTypeId AS MaLoaiPhong, rt.RoomTypeName AS TenLoaiPhong, "
                + "       rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       ISNULL((SELECT STRING_AGG(bt.BedTypeName, ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM RoomType rt "
                + "WHERE rt.IsActive = 1 "
                + "ORDER BY rt.BasePrice ASC";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType rt = new RoomType(
                        rs.getString("MaLoaiPhong"),
                        rs.getNString("TenLoaiPhong"),
                        0.0,
                        rs.getNString("LoaiGiuong"),
                        rs.getInt("SoNguoiToiDa"),
                        rs.getDouble("GiaPhong"),
                        "Active");
                list.add(rt);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tra cứu danh sách các phòng trống khả dụng theo khoảng ngày, số khách và loại
     * phòng
     */
    public List<AvailableRoomDTO> searchAvailableRooms(LocalDate checkIn, LocalDate checkOut, Integer guests,
            String roomTypeId) {
        List<AvailableRoomDTO> list = new ArrayList<>();
        String sql = "SELECT r.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       ISNULL((SELECT STRING_AGG(rs.RoomServiceName, ', ') "
                + "               FROM RoomType_RoomService rtrs "
                + "               JOIN RoomService rs ON rtrs.RoomServiceId = rs.RoomServiceId "
                + "               WHERE rtrs.RoomTypeId = rt.RoomTypeId), N'Đầy đủ tiện nghi cơ bản') AS MoTaPhong, "
                + "       ISNULL((SELECT STRING_AGG(CONCAT(rtbt.Quantity, ' ', bt.BedTypeName), ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM Room r "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE rt.IsActive = 1 "
                + "  AND r.RoomStatus = 'Available' "
                + "  AND (? IS NULL OR rt.RoomTypeId = ?) "
                + "  AND (? IS NULL OR rt.Capacity >= ?) "
                + "  AND dbo.fn_KiemTraPhongTrongTrongKhoang(r.RoomId, ?, ?, NULL) = 1 "
                + "ORDER BY rt.BasePrice ASC, r.RoomName ASC";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            setFilterParams(ps, roomTypeId, guests, checkIn, checkOut);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAvailableRoom(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết của một phòng cụ thể
     */
    public AvailableRoomDTO getRoomDetailById(String maPhong) {
        String sql = "SELECT r.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       ISNULL((SELECT STRING_AGG(rs.RoomServiceName, ', ') "
                + "               FROM RoomType_RoomService rtrs "
                + "               JOIN RoomService rs ON rtrs.RoomServiceId = rs.RoomServiceId "
                + "               WHERE rtrs.RoomTypeId = rt.RoomTypeId), N'Đầy đủ tiện nghi cơ bản') AS MoTaPhong, "
                + "       ISNULL((SELECT STRING_AGG(CONCAT(rtbt.Quantity, ' ', bt.BedTypeName), ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM Room r "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE r.RoomId = ?";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAvailableRoom(rs);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void setFilterParams(PreparedStatement ps, String roomTypeId, Integer guests, LocalDate checkIn,
            LocalDate checkOut) throws SQLException {
        boolean hasRoomType = (roomTypeId != null && !roomTypeId.trim().isEmpty()
                && !"ALL".equalsIgnoreCase(roomTypeId));
        if (hasRoomType) {
            ps.setString(1, roomTypeId.trim());
            ps.setString(2, roomTypeId.trim());
        } else {
            ps.setNull(1, java.sql.Types.VARCHAR);
            ps.setNull(2, java.sql.Types.VARCHAR);
        }

        if (guests != null && guests > 0) {
            ps.setInt(3, guests);
            ps.setInt(4, guests);
        } else {
            ps.setNull(3, java.sql.Types.INTEGER);
            ps.setNull(4, java.sql.Types.INTEGER);
        }

        ps.setDate(5, checkIn != null ? Date.valueOf(checkIn) : null);
        ps.setDate(6, checkOut != null ? Date.valueOf(checkOut) : null);
    }

    private AvailableRoomDTO mapAvailableRoom(ResultSet rs) throws SQLException {
        return new AvailableRoomDTO(
                rs.getString("MaPhong"),
                rs.getString("SoPhong"),
                rs.getString("MaLoaiPhong"),
                rs.getNString("TenLoaiPhong"),
                0.0,
                rs.getNString("LoaiGiuong"),
                rs.getInt("SoNguoiToiDa"),
                rs.getDouble("GiaPhong"),
                rs.getNString("MoTaPhong"));
    }

    /**
     * Kiểm tra nhanh phòng có trống và khả dụng trong khoảng thời gian không
     */
    public boolean isRoomAvailable(String maPhong, LocalDate checkIn, LocalDate checkOut) {
        String sql = "SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(?, ?, ?, NULL) AS KhaDung";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maPhong);
            ps.setDate(2, checkIn != null ? Date.valueOf(checkIn) : null);
            ps.setDate(3, checkOut != null ? Date.valueOf(checkOut) : null);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("KhaDung") == 1;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * FN-3.1: Lấy toàn bộ danh sách phòng thực tế theo tầng để hiển thị trên PMS
     * Gantt Timeline (Dữ liệu thô)
     */
    public List<RoomTimelineDTO> getAllRoomsForTimeline() {
        List<RoomTimelineDTO> list = new ArrayList<>();
        String sql = "SELECT r.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, rt.BasePrice AS GiaPhong, "
                + "       r.RoomStatus, r.OccupancyStatus, r.HousekeepingStatus, r.RoomName AS MoTa "
                + "FROM Room r "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "ORDER BY r.RoomName ASC";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String rawStatus = rs.getString("RoomStatus") + "|"
                        + rs.getString("OccupancyStatus") + "|"
                        + rs.getString("HousekeepingStatus");
                RoomTimelineDTO dto = new RoomTimelineDTO(
                        rs.getString("MaPhong"),
                        rs.getString("SoPhong"),
                        1,
                        rs.getString("MaLoaiPhong"),
                        rs.getNString("TenLoaiPhong"),
                        rs.getDouble("GiaPhong"),
                        rawStatus,
                        rs.getNString("MoTa"));
                list.add(dto);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * FN-3.1: Tính toán các chỉ số thống kê buồng phòng thời gian thực (KPI)
     */
    public RoomMapKpiDTO getRoomMapKpi() {
        String sql = "SELECT "
                + "    COUNT(*) AS TongSoPhong, "
                + "    SUM(CASE WHEN RoomStatus = 'Available' AND OccupancyStatus = 'Vacant' AND HousekeepingStatus = 'Clean' THEN 1 ELSE 0 END) AS SoAvailable, "
                + "    SUM(CASE WHEN OccupancyStatus = 'Occupied' THEN 1 ELSE 0 END) AS SoOccupied, "
                + "    SUM(CASE WHEN HousekeepingStatus = 'Dirty' THEN 1 ELSE 0 END) AS SoDirty, "
                + "    SUM(CASE WHEN HousekeepingStatus = 'Cleaning' THEN 1 ELSE 0 END) AS SoCleaning, "
                + "    SUM(CASE WHEN RoomStatus IN ('Maintenance', 'OutOfService') THEN 1 ELSE 0 END) AS SoDamaged, "
                + "    0 AS SoBooked "
                + "FROM Room";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                int total = rs.getInt("TongSoPhong");
                int avail = rs.getInt("SoAvailable");
                int occ = rs.getInt("SoOccupied");
                int dirty = rs.getInt("SoDirty");
                int clean = rs.getInt("SoCleaning");
                int dmg = rs.getInt("SoDamaged");
                int booked = rs.getInt("SoBooked");

                return new RoomMapKpiDTO(total, avail, occ, dirty, clean, dmg, booked);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return new RoomMapKpiDTO(0, 0, 0, 0, 0, 0, 0);
    }
}
