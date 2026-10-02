package com.mycompany.hotelmanagersystem.booking.dao;

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
import java.util.ArrayList;
import java.util.List;

/**
 * DAO chuyên trách các truy vấn và thủ tục Check-in cho Phân hệ Lễ tân (Phase
 * 3).
 * Tách biệt hoàn toàn khỏi BookingDAO để tuân thủ QT 2.1 và QT 5.2.
 */
public class BookingCheckInDAO {

    /**
     * Truy vấn toàn bộ dải đặt phòng trong tuần có trạng thái DaXacNhan hoặc
     * DaCheckIn.
     */
    public List<BookingBarDTO> getBookingBarsInWeek(LocalDate startDate, LocalDate endDate) {
        List<BookingBarDTO> list = new ArrayList<>();
        String sql = "SELECT bp.MaBooking, bp.MaPhong, kh.HoTen AS TenKhachHang, kh.SoDT AS SoDienThoai, kh.CCCD AS SoCCCD, "
                + "       bp.NgayNhanDuKien, bp.NgayTraDuKien, b.TrangThai AS TrangThaiBooking, "
                + "       bp.NgayCheckInThucTe, bp.NgayCheckOutThucTe "
                + "FROM BOOKING_PHONG bp "
                + "INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking "
                + "INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH "
                + "WHERE b.TrangThai IN ('DaXacNhan', 'DaCheckIn') "
                + "  AND bp.NgayNhanDuKien <= ? "
                + "  AND bp.NgayTraDuKien >= ? "
                + "ORDER BY bp.NgayNhanDuKien ASC";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, Date.valueOf(endDate));
            ps.setDate(2, Date.valueOf(startDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToBookingBar(rs, startDate));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    private BookingBarDTO mapRowToBookingBar(ResultSet rs, LocalDate startDate) throws SQLException {
        Date nhan = rs.getDate("NgayNhanDuKien");
        Date tra = rs.getDate("NgayTraDuKien");
        LocalDate localNhan = nhan.toLocalDate();
        LocalDate localTra = tra.toLocalDate();

        long daysFromStart = ChronoUnit.DAYS.between(startDate, localNhan);
        int startCol = (int) Math.max(1, daysFromStart + 1);

        long daysToEnd = ChronoUnit.DAYS.between(startDate, localTra);
        int endCol = (int) Math.min(7, daysToEnd);
        int colSpan = Math.max(1, endCol - startCol + 1);

        String status = rs.getString("TrangThaiBooking");
        String cssClass = "DaCheckIn".equalsIgnoreCase(status) ? "bar-occupied" : "bar-confirmed";

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
        String sql = "SELECT 1 FROM BOOKING b "
                + "INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking "
                + "WHERE b.MaBooking = ? AND bp.MaPhong = ? "
                + "  AND b.TrangThai IN ('DaXacNhan', 'DaCheckIn') "
                + "  AND bp.NgayCheckInThucTe IS NULL";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maBooking);
            ps.setString(2, maPhong);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Thực hiện Check-in nhận phòng qua Stored Procedure sp_CheckInNhanPhong.
     */
    public boolean executeCheckIn(String maBooking, String maPhong, String maNV) {
        String callSql = "{CALL sp_CheckInNhanPhong(?, ?, ?)}";

        try (Connection conn = DBContext.getConnection();
                CallableStatement cs = conn.prepareCall(callSql)) {

            cs.setString(1, maBooking);
            cs.setString(2, maNV);
            cs.setString(3, maPhong);

            cs.execute();
            return true;
        } catch (SQLException e) {
            // Lỗi 2812: Stored procedure không tồn tại -> dùng fallback transaction
            if (e.getErrorCode() == 2812) {
                return executeCheckInFallback(maBooking, maPhong, maNV);
            }
            return false;
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Fallback transaction nếu SP có vấn đề kết nối: đảm bảo cập nhật đồng bộ CSDL.
     */
    private boolean executeCheckInFallback(String maBooking, String maPhong, String maNV) {
        String updateBp = "UPDATE BOOKING_PHONG SET NgayCheckInThucTe = GETDATE() "
                + "WHERE MaBooking = ? AND MaPhong = ? AND NgayCheckInThucTe IS NULL";
        String updateB = "UPDATE BOOKING SET TrangThai = 'DaCheckIn', MaNV = ? WHERE MaBooking = ?";
        String updateP = "UPDATE PHONG SET TrangThai = 'Occupied' WHERE MaPhong = ?";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement psBp = conn.prepareStatement(updateBp);
                    PreparedStatement psB = conn.prepareStatement(updateB);
                    PreparedStatement psP = conn.prepareStatement(updateP)) {

                psBp.setString(1, maBooking);
                psBp.setString(2, maPhong);
                int rows = psBp.executeUpdate();
                if (rows <= 0) {
                    conn.rollback();
                    return false;
                }

                psB.setString(1, maNV);
                psB.setString(2, maBooking);
                psB.executeUpdate();

                psP.setString(1, maPhong);
                psP.executeUpdate();

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /**
     * Thực hiện Check-in cho danh sách các phòng được chọn trong đơn.
     */
    public boolean executeCheckInRooms(String maBooking, List<String> roomIds, String maNV) {
        if (roomIds == null || roomIds.isEmpty()) {
            return false;
        }
        boolean anySuccess = false;
        for (String roomId : roomIds) {
            if (roomId != null && !roomId.trim().isEmpty()) {
                boolean ok = executeCheckIn(maBooking, roomId.trim(), maNV);
                if (ok) {
                    anySuccess = true;
                }
            }
        }
        return anySuccess;
    }
}
