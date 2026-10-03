package com.mycompany.hotelmanagersystem.cashier.dao;

import com.mycompany.hotelmanagersystem.cashier.dto.ActiveBookingItemDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO phụ trách tra cứu danh sách booking cần thu tiền phục vụ dashboard Thu Ngân.
 */
public class ActiveBookingDAO {

    /**
     * Tìm kiếm các đơn đặt phòng chưa thanh toán hoặc thanh toán một phần theo từ khóa.
     */
    public List<ActiveBookingItemDTO> findCheckedInBookings(String keyword)
            throws SQLException, ClassNotFoundException {
        List<ActiveBookingItemDTO> list = new ArrayList<>();
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        String sql = "SELECT b.MaBooking, kh.HoTen AS TenKhach, kh.SoDT, kh.CCCD, b.ChiPhiDuKien, b.TrangThai, " +
                     "       COUNT(bp.MaPhong) AS TongSoPhong, " +
                     "       STRING_AGG(bp.MaPhong, ', ') AS DanhSachPhong, " +
                     "       SUM(CASE WHEN bp.NgayCheckOutThucTe IS NULL THEN 1 ELSE 0 END) AS SoPhongChuaTra, " +
                     "       hd.MaHoaDon, " +
                     "       ISNULL(hd.TrangThai, 'ChuaThanhToan') AS TrangThaiHoaDon, " +
                     "       ISNULL(hd.TongTienCuoiCung, b.ChiPhiDuKien) AS TongTien, " +
                     "       ISNULL(tt.DaTra, 0) AS DaThanhToan, " +
                     "       (ISNULL(hd.TongTienCuoiCung, b.ChiPhiDuKien) - ISNULL(tt.DaTra, 0)) AS SoTienConNo " +
                     "FROM BOOKING b " +
                     "INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH " +
                     "INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking " +
                     "LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking " +
                     "OUTER APPLY ( " +
                     "    SELECT SUM(SoTien) AS DaTra FROM THANHTOAN WHERE MaHoaDon = hd.MaHoaDon " +
                     ") tt " +
                     "WHERE b.TrangThai IN ('DaCheckIn', 'DaCheckOut') " +
                     "  AND ISNULL(hd.TrangThai, 'ChuaThanhToan') <> 'DaThanhToanDu' " +
                     (hasKeyword ? "  AND (b.MaBooking LIKE ? OR kh.HoTen LIKE ? OR kh.SoDT LIKE ? OR kh.CCCD LIKE ?) " : "") +
                     "GROUP BY b.MaBooking, kh.HoTen, kh.SoDT, kh.CCCD, b.ChiPhiDuKien, b.TrangThai, " +
                     "         hd.MaHoaDon, hd.TrangThai, hd.TongTienCuoiCung, tt.DaTra " +
                     "ORDER BY b.MaBooking DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (hasKeyword) {
                String pattern = "%" + keyword.trim() + "%";
                ps.setString(1, pattern);
                ps.setString(2, pattern);
                ps.setString(3, pattern);
                ps.setString(4, pattern);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToActiveBooking(rs));
                }
            }
        }
        return list;
    }

    /**
     * Kiểm tra xem đơn đặt phòng có còn phòng nào chưa thực hiện Check-out hay không.
     */
    public boolean hasUncheckedOutRooms(String maBooking) throws SQLException, ClassNotFoundException {
        String sql = "SELECT 1 FROM BOOKING_PHONG WHERE MaBooking = ? AND NgayCheckOutThucTe IS NULL";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private ActiveBookingItemDTO mapRowToActiveBooking(ResultSet rs) throws SQLException {
        ActiveBookingItemDTO dto = new ActiveBookingItemDTO();
        dto.setMaBooking(rs.getString("MaBooking"));
        dto.setTenKhach(rs.getString("TenKhach"));
        dto.setSoDT(rs.getString("SoDT"));
        dto.setCccd(rs.getString("CCCD"));
        dto.setChiPhiDuKien(rs.getDouble("ChiPhiDuKien"));
        dto.setTrangThai(rs.getString("TrangThai"));
        dto.setTongSoPhong(rs.getInt("TongSoPhong"));
        dto.setDanhSachPhong(rs.getString("DanhSachPhong"));
        dto.setSoPhongChuaTra(rs.getInt("SoPhongChuaTra"));
        dto.setMaHoaDon(rs.getString("MaHoaDon"));
        dto.setTrangThaiHoaDon(rs.getString("TrangThaiHoaDon"));
        dto.setTongTien(rs.getDouble("TongTien"));
        dto.setDaThanhToan(rs.getDouble("DaThanhToan"));
        dto.setSoTienConNo(rs.getDouble("SoTienConNo"));
        return dto;
    }
}
