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
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    /**
     * Lấy toàn bộ danh sách hạng phòng đang kinh doanh
     */
    public List<RoomType> getAllActiveRoomTypes() {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT MaLoaiPhong, TenLoaiPhong, DienTich, LoaiGiuong, SoNguoiToiDa, GiaPhong, TrangThai "
                   + "FROM LOAIPHONG "
                   + "WHERE TrangThai = 'ApDung' "
                   + "ORDER BY GiaPhong ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType rt = new RoomType(
                        rs.getString("MaLoaiPhong"),
                        rs.getNString("TenLoaiPhong"),
                        rs.getDouble("DienTich"),
                        rs.getNString("LoaiGiuong"),
                        rs.getInt("SoNguoiToiDa"),
                        rs.getDouble("GiaPhong"),
                        rs.getString("TrangThai")
                );
                list.add(rt);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tra cứu danh sách các phòng trống khả dụng theo khoảng ngày, số khách và loại phòng
     */
    public List<AvailableRoomDTO> searchAvailableRooms(Date checkIn, Date checkOut, Integer guests, String roomTypeId) {
        List<AvailableRoomDTO> list = new ArrayList<>();
        
        // Truy vấn tối ưu kết hợp kiểm tra trạng thái vật lý và chống giao thoa lịch đặt phòng
        String sql = "SELECT p.MaPhong, p.SoPhong, lp.MaLoaiPhong, lp.TenLoaiPhong, "
                   + "       lp.DienTich, lp.LoaiGiuong, lp.SoNguoiToiDa, lp.GiaPhong, p.MoTa "
                   + "FROM PHONG p "
                   + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                   + "WHERE p.TrangThai <> 'Damaged' "
                   + "  AND lp.TrangThai = 'ApDung' "
                   + "  AND (? IS NULL OR p.MaLoaiPhong = ?) "
                   + "  AND (? IS NULL OR lp.SoNguoiToiDa >= ?) "
                   + "  AND NOT EXISTS ( "
                   + "      SELECT 1 FROM BOOKING_PHONG bp "
                   + "      INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking "
                   + "      WHERE bp.MaPhong = p.MaPhong "
                   + "        AND b.TrangThai IN ('ChoXacNhan', 'DaXacNhan', 'DaCheckIn') "
                   + "        AND NOT (bp.NgayTraDuKien <= ? OR bp.NgayNhanDuKien >= ?) "
                   + "  ) "
                   + "ORDER BY lp.GiaPhong ASC, p.SoPhong ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (roomTypeId != null && !roomTypeId.trim().isEmpty() && !"ALL".equalsIgnoreCase(roomTypeId)) {
                ps.setString(1, roomTypeId);
                ps.setString(2, roomTypeId);
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

            ps.setDate(5, checkIn);
            ps.setDate(6, checkOut);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AvailableRoomDTO dto = new AvailableRoomDTO(
                            rs.getString("MaPhong"),
                            rs.getString("SoPhong"),
                            rs.getString("MaLoaiPhong"),
                            rs.getNString("TenLoaiPhong"),
                            rs.getDouble("DienTich"),
                            rs.getNString("LoaiGiuong"),
                            rs.getInt("SoNguoiToiDa"),
                            rs.getDouble("GiaPhong"),
                            rs.getNString("MoTa")
                    );
                    list.add(dto);
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
        String sql = "SELECT p.MaPhong, p.SoPhong, lp.MaLoaiPhong, lp.TenLoaiPhong, "
                   + "       lp.DienTich, lp.LoaiGiuong, lp.SoNguoiToiDa, lp.GiaPhong, p.MoTa "
                   + "FROM PHONG p "
                   + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                   + "WHERE p.MaPhong = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new AvailableRoomDTO(
                            rs.getString("MaPhong"),
                            rs.getString("SoPhong"),
                            rs.getString("MaLoaiPhong"),
                            rs.getNString("TenLoaiPhong"),
                            rs.getDouble("DienTich"),
                            rs.getNString("LoaiGiuong"),
                            rs.getInt("SoNguoiToiDa"),
                            rs.getDouble("GiaPhong"),
                            rs.getNString("MoTa")
                    );
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra nhanh phòng có trống và khả dụng trong khoảng thời gian không
     */
    public boolean isRoomAvailable(String maPhong, Date checkIn, Date checkOut) {
        String sql = "SELECT 1 FROM PHONG p "
                   + "WHERE p.MaPhong = ? "
                   + "  AND p.TrangThai <> 'Damaged' "
                   + "  AND NOT EXISTS ( "
                   + "      SELECT 1 FROM BOOKING_PHONG bp "
                   + "      INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking "
                   + "      WHERE bp.MaPhong = p.MaPhong "
                   + "        AND b.TrangThai IN ('ChoXacNhan', 'DaXacNhan', 'DaCheckIn') "
                   + "        AND NOT (bp.NgayTraDuKien <= ? OR bp.NgayNhanDuKien >= ?) "
                   + "  )";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maPhong);
            ps.setDate(2, checkIn);
            ps.setDate(3, checkOut);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * FN-3.1: Lấy toàn bộ danh sách phòng thực tế theo tầng để hiển thị trên PMS Gantt Timeline
     */
    public List<RoomTimelineDTO> getAllRoomsForTimeline() {
        List<RoomTimelineDTO> list = new ArrayList<>();
        String sql = "SELECT p.MaPhong, p.SoPhong, lp.MaLoaiPhong, lp.TenLoaiPhong, lp.GiaPhong, p.TrangThai, p.MoTa "
                   + "FROM PHONG p "
                   + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                   + "ORDER BY p.SoPhong ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String soPhong = rs.getString("SoPhong");
                int soTang = 1;
                if (soPhong != null && !soPhong.isEmpty()) {
                    char firstChar = soPhong.charAt(0);
                    if (Character.isDigit(firstChar)) {
                        soTang = Character.getNumericValue(firstChar);
                    }
                }

                RoomTimelineDTO dto = new RoomTimelineDTO(
                        rs.getString("MaPhong"),
                        soPhong,
                        soTang,
                        rs.getString("MaLoaiPhong"),
                        rs.getNString("TenLoaiPhong"),
                        rs.getDouble("GiaPhong"),
                        rs.getString("TrangThai"),
                        rs.getNString("MoTa")
                );
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
                   + "    SUM(CASE WHEN TrangThai = 'Available' THEN 1 ELSE 0 END) AS SoAvailable, "
                   + "    SUM(CASE WHEN TrangThai = 'Occupied' THEN 1 ELSE 0 END) AS SoOccupied, "
                   + "    SUM(CASE WHEN TrangThai = 'Dirty' THEN 1 ELSE 0 END) AS SoDirty, "
                   + "    SUM(CASE WHEN TrangThai = 'Cleaning' THEN 1 ELSE 0 END) AS SoCleaning, "
                   + "    SUM(CASE WHEN TrangThai = 'Damaged' THEN 1 ELSE 0 END) AS SoDamaged, "
                   + "    SUM(CASE WHEN TrangThai = 'Booked' THEN 1 ELSE 0 END) AS SoBooked "
                   + "FROM PHONG";

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
