package com.mycompany.hotelmanagersystem.dao.room;

import com.mycompany.hotelmanagersystem.dto.room.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.model.RoomType;
import com.mycompany.hotelmanagersystem.util.DBContext;

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
}
