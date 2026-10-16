package com.mycompany.hotelmanagersystem.cashier.dao;

import com.mycompany.hotelmanagersystem.cashier.dto.ActiveBookingItemDTO;
import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * DAO phụ trách tra cứu danh sách booking cần thu tiền phục vụ dashboard Thu Ngân.
 */
public class ActiveBookingDAO extends BaseRepository<ActiveBookingItemDTO, String> {

    @Override
    protected String getTableName() {
        return "Booking";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "BookingId";
    }

    @Override
    protected RowMapper<ActiveBookingItemDTO> getRowMapper() {
        return this::mapRowToActiveBooking;
    }

    /**
     * Tìm kiếm các đơn đặt phòng chưa thanh toán hoặc thanh toán một phần theo từ khóa.
     */
    public List<ActiveBookingItemDTO> findCheckedInBookings(String keyword)
            throws SQLException, ClassNotFoundException {
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        String sql = "SELECT b.BookingId AS MaBooking, c.FullName AS TenKhach, c.PhoneNumber AS SoDT, c.CCCD, "
                     + "       ISNULL(inv.FinalTotalAmount, 0) AS ChiPhiDuKien, "
                     + "       ISNULL((SELECT TOP 1 br_st.BookingStatus FROM Booking_Room br_st WHERE br_st.BookingId = b.BookingId), 'CheckedIn') AS TrangThai, "
                     + "       COUNT(br.RoomId) AS TongSoPhong, "
                     + "       STRING_AGG(br.RoomId, ', ') AS DanhSachPhong, "
                     + "       SUM(CASE WHEN br.ActualCheckOutDate IS NULL THEN 1 ELSE 0 END) AS SoPhongChuaTra, "
                     + "       inv.InvoiceId AS MaHoaDon, "
                     + "       ISNULL(inv.InvoiceStatus, 'Unpaid') AS TrangThaiHoaDon, "
                     + "       ISNULL(inv.FinalTotalAmount, 0) AS TongTien, "
                     + "       ISNULL(tt.DaTra, 0) AS DaThanhToan, "
                     + "       (ISNULL(inv.FinalTotalAmount, 0) - ISNULL(tt.DaTra, 0)) AS SoTienConNo "
                     + "FROM Booking b "
                     + "INNER JOIN Customer c ON b.CustomerId = c.CustomerId "
                     + "INNER JOIN Booking_Room br ON b.BookingId = br.BookingId "
                     + "LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId "
                     + "OUTER APPLY ( "
                     + "    SELECT SUM(TotalAmount) AS DaTra FROM Payment WHERE InvoiceId = inv.InvoiceId "
                     + ") tt "
                     + "WHERE EXISTS (SELECT 1 FROM Booking_Room br2 WHERE br2.BookingId = b.BookingId AND br2.BookingStatus IN ('CheckedIn', 'CheckedOut')) "
                     + "  AND ISNULL(inv.InvoiceStatus, 'Unpaid') <> 'Paid' "
                     + (hasKeyword ? "  AND (b.BookingId LIKE ? OR c.FullName LIKE ? OR c.PhoneNumber LIKE ? OR c.CCCD LIKE ?) " : "")
                     + "GROUP BY b.BookingId, c.FullName, c.PhoneNumber, c.CCCD, inv.FinalTotalAmount, "
                     + "         inv.InvoiceId, inv.InvoiceStatus, tt.DaTra "
                     + "ORDER BY b.BookingId DESC";

        if (hasKeyword) {
            String pattern = "%" + keyword.trim() + "%";
            return query(sql, pattern, pattern, pattern, pattern);
        }
        return query(sql);
    }

    /**
     * Kiểm tra xem đơn đặt phòng có còn phòng nào chưa thực hiện Check-out hay không.
     */
    public boolean hasUncheckedOutRooms(String maBooking) throws SQLException, ClassNotFoundException {
        String sql = "SELECT 1 FROM Booking_Room WHERE BookingId = ? AND ActualCheckOutDate IS NULL AND BookingStatus = 'CheckedIn'";
        return !queryCustom(sql, rs -> 1, maBooking).isEmpty();
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
