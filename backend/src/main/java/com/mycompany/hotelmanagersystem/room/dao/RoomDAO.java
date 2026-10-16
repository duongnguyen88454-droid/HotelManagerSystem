package com.mycompany.hotelmanagersystem.room.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.model.RoomType;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * DAO chuyên trách các thao tác dữ liệu phòng và hạng phòng.
 * Kế thừa BaseRepository theo kiến trúc chuẩn.
 */
public class RoomDAO extends BaseRepository<AvailableRoomDTO, String> {

    @Override
    protected String getTableName() {
        return "Room";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "RoomId";
    }

    @Override
    protected RowMapper<AvailableRoomDTO> getRowMapper() {
        return this::mapAvailableRoom;
    }

    /**
     * Lấy toàn bộ danh sách hạng phòng đang kinh doanh
     */
    public List<RoomType> getAllActiveRoomTypes() {
        String sql = "SELECT rt.RoomTypeId AS MaLoaiPhong, rt.RoomTypeName AS TenLoaiPhong, "
                + "       rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       ISNULL((SELECT STRING_AGG(bt.BedTypeName, ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId AND bt.IsActive = 1), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM RoomType rt "
                + "WHERE rt.IsActive = 1 "
                + "ORDER BY rt.BasePrice ASC";
        return queryCustom(sql, this::mapRoomType);
    }

    /**
     * Tra cứu danh sách các phòng trống khả dụng theo khoảng ngày, số khách và loại phòng
     */
    public List<AvailableRoomDTO> searchAvailableRooms(LocalDate checkIn, LocalDate checkOut, Integer guests,
            String roomTypeId) {
        String sql = "SELECT r.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       rt.DepositPercent, "
                + "       ISNULL((SELECT STRING_AGG(rs.RoomServiceName, ', ') "
                + "               FROM RoomType_RoomService rtrs "
                + "               JOIN RoomService rs ON rtrs.RoomServiceId = rs.RoomServiceId "
                + "               WHERE rtrs.RoomTypeId = rt.RoomTypeId AND rs.IsActive = 1), N'Đầy đủ tiện nghi cơ bản') AS MoTaPhong, "
                + "       ISNULL((SELECT STRING_AGG(CONCAT(rtbt.Quantity, ' ', bt.BedTypeName), ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId AND bt.IsActive = 1), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM Room r "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE rt.IsActive = 1 "
                + "  AND r.RoomStatus = 'Available' "
                + "  AND (? IS NULL OR rt.RoomTypeId = ?) "
                + "  AND (? IS NULL OR rt.Capacity >= ?) "
                + "  AND dbo.fn_KiemTraPhongTrongTrongKhoang(r.RoomId, ?, ?, NULL) = 1 "
                + "ORDER BY rt.BasePrice ASC, r.RoomName ASC";

        boolean hasRoomType = (roomTypeId != null && !roomTypeId.trim().isEmpty() && !"ALL".equalsIgnoreCase(roomTypeId));
        Object typeParam = hasRoomType ? roomTypeId.trim() : null;
        Object guestParam = (guests != null && guests > 0) ? guests : null;
        Date dIn = checkIn != null ? Date.valueOf(checkIn) : null;
        Date dOut = checkOut != null ? Date.valueOf(checkOut) : null;

        return query(sql, typeParam, typeParam, guestParam, guestParam, dIn, dOut);
    }

    /**
     * Lấy thông tin chi tiết của một phòng cụ thể
     */
    public AvailableRoomDTO getRoomDetailById(String maPhong) {
        String sql = "SELECT r.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       rt.DepositPercent, "
                + "       ISNULL((SELECT STRING_AGG(rs.RoomServiceName, ', ') "
                + "               FROM RoomType_RoomService rtrs "
                + "               JOIN RoomService rs ON rtrs.RoomServiceId = rs.RoomServiceId "
                + "               WHERE rtrs.RoomTypeId = rt.RoomTypeId AND rs.IsActive = 1), N'Đầy đủ tiện nghi cơ bản') AS MoTaPhong, "
                + "       ISNULL((SELECT STRING_AGG(CONCAT(rtbt.Quantity, ' ', bt.BedTypeName), ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId AND bt.IsActive = 1), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM Room r "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE r.RoomId = ?";
        return queryOne(sql, maPhong).orElse(null);
    }

    /**
     * Kiểm tra nhanh phòng có trống và khả dụng trong khoảng thời gian không
     */
    public boolean isRoomAvailable(String maPhong, LocalDate checkIn, LocalDate checkOut) {
        String sql = "SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(?, ?, ?, NULL) AS KhaDung";
        Date dIn = checkIn != null ? Date.valueOf(checkIn) : null;
        Date dOut = checkOut != null ? Date.valueOf(checkOut) : null;
        Long result = queryScalarLong(sql, maPhong, dIn, dOut);
        return result != null && result == 1;
    }

    /**
     * FN-3.1: Lấy toàn bộ danh sách phòng thực tế theo tầng để hiển thị trên PMS Gantt Timeline
     */
    public List<RoomTimelineDTO> getAllRoomsForTimeline() {
        String sql = "SELECT r.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, rt.BasePrice AS GiaPhong, "
                + "       r.RoomStatus, r.OccupancyStatus, r.HousekeepingStatus, r.RoomName AS MoTa "
                + "FROM Room r "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "ORDER BY r.RoomName ASC";
        return queryCustom(sql, this::mapRoomTimeline);
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
        return queryOneCustom(sql, this::mapRoomMapKpi).orElseGet(() -> new RoomMapKpiDTO(0, 0, 0, 0, 0, 0, 0));
    }

    private AvailableRoomDTO mapAvailableRoom(ResultSet rs) throws SQLException {
        AvailableRoomDTO dto = new AvailableRoomDTO(
                rs.getString("MaPhong"),
                rs.getString("SoPhong"),
                rs.getString("MaLoaiPhong"),
                rs.getNString("TenLoaiPhong"),
                0.0,
                rs.getNString("LoaiGiuong"),
                rs.getInt("SoNguoiToiDa"),
                rs.getDouble("GiaPhong"),
                rs.getNString("MoTaPhong"));
        dto.setDepositPercent(rs.getDouble("DepositPercent"));
        return dto;
    }

    private RoomType mapRoomType(ResultSet rs) throws SQLException {
        return new RoomType(
                rs.getString("MaLoaiPhong"),
                rs.getNString("TenLoaiPhong"),
                0.0,
                rs.getNString("LoaiGiuong"),
                rs.getInt("SoNguoiToiDa"),
                rs.getDouble("GiaPhong"),
                "Active");
    }

    private RoomTimelineDTO mapRoomTimeline(ResultSet rs) throws SQLException {
        String rawStatus = rs.getString("RoomStatus") + "|"
                + rs.getString("OccupancyStatus") + "|"
                + rs.getString("HousekeepingStatus");
        return new RoomTimelineDTO(
                rs.getString("MaPhong"),
                rs.getString("SoPhong"),
                1,
                rs.getString("MaLoaiPhong"),
                rs.getNString("TenLoaiPhong"),
                rs.getDouble("GiaPhong"),
                rawStatus,
                rs.getNString("MoTa"));
    }

    private RoomMapKpiDTO mapRoomMapKpi(ResultSet rs) throws SQLException {
        int total = rs.getInt("TongSoPhong");
        int avail = rs.getInt("SoAvailable");
        int occ = rs.getInt("SoOccupied");
        int dirty = rs.getInt("SoDirty");
        int clean = rs.getInt("SoCleaning");
        int dmg = rs.getInt("SoDamaged");
        int booked = rs.getInt("SoBooked");
        return new RoomMapKpiDTO(total, avail, occ, dirty, clean, dmg, booked);
    }
}
