package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.room.dto.BookingBarDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * DAO chuyên trách các truy vấn và thủ tục Check-in cho Phân hệ Lễ tân (Phase
 * 3).
 * Tách biệt hoàn toàn khỏi BookingDAO để tuân thủ QT 2.1 và QT 5.2.
 */
public class BookingCheckInDAO extends BaseRepository<BookingBarDTO, String> {

    @Override
    protected String getTableName() {
        return "Booking_Room";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "BookingId";
    }

    @Override
    protected RowMapper<BookingBarDTO> getRowMapper() {
        return rs -> mapRowToBookingBar(rs, LocalDate.now());
    }

    @Override
    protected String getRole() {
        return "Receptionist";
    }

    /**
     * Truy vấn toàn bộ dải đặt phòng trong tuần có trạng thái Confirmed hoặc
     * CheckedIn.
     */
    public List<BookingBarDTO> getBookingBarsInWeek(LocalDate startDate, LocalDate endDate) {
        String sql = "SELECT br.BookingId AS MaBooking, br.RoomId AS MaPhong, c.FullName AS TenKhachHang, "
                + "       c.PhoneNumber AS SoDienThoai, c.CCCD AS SoCCCD, br.ExpectedCheckInDate AS NgayNhanDuKien, "
                + "       br.ExpectedCheckOutDate AS NgayTraDuKien, br.BookingStatus AS TrangThaiBooking, "
                + "       br.ActualCheckInDate AS NgayCheckInThucTe, br.ActualCheckOutDate AS NgayCheckOutThucTe "
                + "FROM Booking_Room br "
                + "INNER JOIN Booking b ON br.BookingId = b.BookingId "
                + "INNER JOIN Customer c ON b.CustomerId = c.CustomerId "
                + "WHERE br.BookingStatus IN ('Confirmed', 'CheckedIn') "
                + "  AND br.ExpectedCheckInDate <= ? "
                + "  AND br.ExpectedCheckOutDate >= ? "
                + "ORDER BY br.ExpectedCheckInDate ASC";

        Date dEnd = Date.valueOf(endDate);
        Date dStart = Date.valueOf(startDate);
        return queryCustom(sql, rs -> mapRowToBookingBar(rs, startDate), dEnd, dStart);
    }

    private BookingBarDTO mapRowToBookingBar(ResultSet rs, LocalDate startDate) throws SQLException {
        Date nhan = rs.getDate("NgayNhanDuKien");
        Date tra = rs.getDate("NgayTraDuKien");
        LocalDate localNhan = nhan.toLocalDate();
        LocalDate localTra = tra.toLocalDate();

        long daysFromStart = ChronoUnit.DAYS.between(startDate, localNhan);
        int startCol = (int) Math.max(1, Math.min(7, daysFromStart + 1));

        long daysToEnd = ChronoUnit.DAYS.between(startDate, localTra);
        int endCol = (int) Math.max(startCol, Math.min(7, daysToEnd));
        int maxAllowedSpan = 7 - startCol + 1;
        int colSpan = Math.max(1, Math.min(maxAllowedSpan, endCol - startCol + 1));

        String status = rs.getString("TrangThaiBooking");
        String cssClass = "CheckedIn".equalsIgnoreCase(status) ? "bar-occupied" : "bar-confirmed";

        BookingBarDTO bar = new BookingBarDTO(
                rs.getString("MaBooking"),
                rs.getString("MaPhong"),
                rs.getNString("TenKhachHang"),
                rs.getString("SoDienThoai"),
                rs.getString("SoCCCD"),
                nhan,
                tra,
                status,
                startCol,
                colSpan,
                cssClass);
        bar.setNgayCheckInThucTe(rs.getTimestamp("NgayCheckInThucTe"));
        bar.setNgayCheckOutThucTe(rs.getTimestamp("NgayCheckOutThucTe"));
        return bar;
    }

    /**
     * Kiểm tra điều kiện đơn đặt phòng và phòng có hợp lệ để Check-in.
     */
    public boolean isBookingEligibleForCheckIn(String maBooking, String maPhong) {
        String sql = "SELECT 1 FROM Booking_Room br "
                + "WHERE br.BookingId = ? AND br.RoomId = ? "
                + "  AND br.BookingStatus = 'Confirmed' "
                + "  AND br.ActualCheckInDate IS NULL";
        return !queryCustom(sql, rs -> 1, maBooking, maPhong).isEmpty();
    }

    /**
     * Thực hiện Check-in nhận phòng qua Stored Procedure sp_CheckInNhanPhong.
     */
    public boolean executeCheckIn(String maBooking, String maPhong) {
        String callSql = "{CALL sp_CheckInNhanPhong(?, ?)}";

        try (Connection conn = DBContext.getConnection(getRole());
                CallableStatement cs = conn.prepareCall(callSql)) {

            cs.setString(1, maBooking);
            cs.setString(2, maPhong);

            cs.execute();
            return true;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Thực hiện Check-in cho danh sách các phòng được chọn trong đơn.
     */
    public boolean executeCheckInRooms(String maBooking, List<String> roomIds) {
        if (roomIds == null || roomIds.isEmpty()) {
            return false;
        }
        boolean anySuccess = false;
        for (String roomId : roomIds) {
            if (roomId != null && !roomId.trim().isEmpty()) {
                boolean ok = executeCheckIn(maBooking, roomId.trim());
                if (ok) {
                    anySuccess = true;
                }
            }
        }
        return anySuccess;
    }
}
