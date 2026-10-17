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
        return "v_ReceivableBookings";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "BookingId";
    }

    @Override
    protected RowMapper<ActiveBookingItemDTO> getRowMapper() {
        return this::mapRowToActiveBooking;
    }

    @Override
    protected String getRole() {
        return "Receptionist";
    }

    /**
     * Tìm kiếm các đơn đặt phòng chưa thanh toán hoặc thanh toán một phần theo từ khóa.
     */
    public List<ActiveBookingItemDTO> findCheckedInBookings(String keyword)
            throws SQLException, ClassNotFoundException {
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        String sql = "SELECT * FROM v_ReceivableBookings "
                     + (hasKeyword ? "WHERE (BookingId LIKE ? OR CustomerName LIKE ? OR PhoneNumber LIKE ? OR CCCD LIKE ?) " : "")
                     + "ORDER BY BookingId DESC";

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
        dto.setMaBooking(rs.getString("BookingId"));
        dto.setTenKhach(rs.getString("CustomerName"));
        dto.setSoDT(rs.getString("PhoneNumber"));
        dto.setCccd(rs.getString("CCCD"));
        dto.setChiPhiDuKien(rs.getDouble("EstimatedTotal"));
        dto.setTrangThai(rs.getString("BookingStatus"));
        dto.setTongSoPhong(rs.getInt("TotalRooms"));
        dto.setDanhSachPhong(rs.getString("RoomList"));
        dto.setSoPhongChuaTra(rs.getInt("PendingCheckOutRooms"));
        dto.setMaHoaDon(rs.getString("InvoiceId"));
        dto.setTrangThaiHoaDon(rs.getString("InvoiceStatus"));
        dto.setTongTien(rs.getDouble("TotalAmount"));
        dto.setDaThanhToan(rs.getDouble("PaidAmount"));
        dto.setSoTienConNo(rs.getDouble("RemainingDebt"));
        return dto;
    }
}
