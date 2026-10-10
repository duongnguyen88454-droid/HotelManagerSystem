package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.SingleBookingRequestDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object quản lý điều phối tạo đơn đặt phòng (Booking) và giao dịch
 * toàn vẹn.
 * Đã refactor tinh gọn theo QT 2.1, QT 2.2 và QT 2.3 trong
 * ARCHITECTURE_RULES.md.
 */
public class BookingDAO {

    private final BookingDichVuDAO bookingDichVuDAO = new BookingDichVuDAO();
    private final InvoiceWriter invoiceWriter = new InvoiceWriter();

    /**
     * Điều phối tạo đơn đặt phòng trực tuyến 1 phòng kèm dịch vụ trong 1
     * Transaction
     */
    public String createOnlineBookingWithServices(SingleBookingRequestDTO req) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            Date checkInSql = req.getCheckIn() != null ? Date.valueOf(req.getCheckIn()) : null;
            Date checkOutSql = req.getCheckOut() != null ? Date.valueOf(req.getCheckOut()) : null;
            validateRoomAvailability(conn, req.getMaPhong(), checkInSql, checkOutSql);
            String maBooking = getNextBookingIdFromDB(conn);
            insertBookingHeader(conn, maBooking, req.getMaKH(), req.getMaTaiKhoan(), req.getTongChiPhi());
            insertBookingRoom(conn, maBooking, req.getMaPhong(), req.getDonGiaPhong(), checkInSql, checkOutSql);
            bookingDichVuDAO.insertBookingServices(conn, maBooking, req.getMaPhong(), req.getSelectedServices());
            invoiceWriter.ensureInvoiceExists(conn, maBooking);

            conn.commit();
            return maBooking;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    /**
     * Điều phối tạo đơn đặt đa phòng kèm dịch vụ riêng cho từng phòng trong 1
     * Transaction
     */
    public String createMultiRoomBookingWithServices(String maKH, String maTaiKhoan, BookingCartDTO cart, String ghiChu)
            throws Exception {
        if (cart == null || cart.getTotalRoomCount() == 0) {
            throw new IllegalArgumentException("Giỏ đặt phòng đang trống, vui lòng chọn ít nhất 1 phòng!");
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            cleanupExpiredPendingBookings(conn);

            for (CartRoomItemDTO roomItem : cart.getItems().values()) {
                Date dIn = Date.valueOf(roomItem.getNgayNhan());
                Date dOut = Date.valueOf(roomItem.getNgayTra());
                validateRoomAvailability(conn, roomItem.getMaPhong(), dIn, dOut);
            }

            String maBooking = getNextBookingIdFromDB(conn);
            insertBookingHeader(conn, maBooking, maKH, maTaiKhoan, cart.getGrandTotal());

            for (CartRoomItemDTO roomItem : cart.getItems().values()) {
                Date dIn = Date.valueOf(roomItem.getNgayNhan());
                Date dOut = Date.valueOf(roomItem.getNgayTra());
                insertBookingRoom(conn, maBooking, roomItem.getMaPhong(), roomItem.getDonGiaPhong(), dIn, dOut);
            }

            for (CartRoomItemDTO roomItem : cart.getItems().values()) {
                List<CartServiceItemDTO> svcs = roomItem.getSelectedServices();
                if (svcs != null && !svcs.isEmpty()) {
                    for (CartServiceItemDTO svc : svcs) {
                        if (svc.getSoLuong() > 0) {
                            bookingDichVuDAO.insertSingleBookingService(conn, maBooking, roomItem.getMaPhong(),
                                    svc, "KhachHang");
                        }
                    }
                }
            }

            invoiceWriter.ensureInvoiceExists(conn, maBooking);
            conn.commit();
            return maBooking;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    public String createMultiRoomBookingWithServices(String maKH, BookingCartDTO cart, String ghiChu) throws Exception {
        return createMultiRoomBookingWithServices(maKH, null, cart, ghiChu);
    }

    /**
     * Hủy đơn đặt phòng theo MaKH HOẶC MaTaiKhoan khi chưa Check-in
     */
    public boolean cancelBooking(String maBooking, String maKH, String maTaiKhoan) {
        String sql = "UPDATE br "
                + "SET br.BookingStatus = 'Cancelled' "
                + "FROM Booking_Room br "
                + "INNER JOIN Booking b ON br.BookingId = b.BookingId "
                + "WHERE br.BookingId = ? "
                + "  AND br.BookingStatus = 'Confirmed' "
                + "  AND (b.CustomerId = ? OR (? IS NOT NULL AND b.CreateBy = ?))";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            ps.setString(2, maKH);
            ps.setString(3, maTaiKhoan);
            ps.setString(4, maTaiKhoan);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }



    // --- CÁC HÀM HELPER NỘI BỘ TRONG TRANSACTION ---

    private void validateRoomAvailability(Connection conn, String maPhong, Date checkIn, Date checkOut)
            throws SQLException {
        String checkSql = "SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(?, ?, ?, NULL)";
        try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            psCheck.setString(1, maPhong);
            psCheck.setDate(2, checkIn);
            psCheck.setDate(3, checkOut);
            try (ResultSet rsCheck = psCheck.executeQuery()) {
                if (rsCheck.next() && rsCheck.getInt(1) == 0) {
                    throw new SQLException(
                            "Phòng " + maPhong + " không khả dụng hoặc đã có người đặt trong khoảng thời gian này!");
                }
            }
        }
    }

    private void insertBookingHeader(Connection conn, String maBooking, String maKH, String maTaiKhoan,
            double tongChiPhi) throws SQLException {
        String insertBookingSql = "INSERT INTO Booking (BookingId, CustomerId, CreateBy, CreateDate) "
                + "VALUES (?, ?, ?, GETDATE())";
        try (PreparedStatement psBooking = conn.prepareStatement(insertBookingSql)) {
            psBooking.setString(1, maBooking);
            psBooking.setString(2, maKH);
            String creator = (maTaiKhoan != null && !maTaiKhoan.trim().isEmpty()) ? maTaiKhoan.trim() : "ACC002";
            psBooking.setString(3, creator);
            psBooking.executeUpdate();
        }
    }

    private void insertBookingRoom(Connection conn, String maBooking, String maPhong, double donGiaPhong, Date checkIn,
            Date checkOut) throws SQLException {
        double depositPercent = getRoomDepositPercent(conn, maPhong);
        long soDem = 1;
        if (checkIn != null && checkOut != null) {
            long diff = (checkOut.getTime() - checkIn.getTime()) / (1000 * 60 * 60 * 24);
            soDem = Math.max(1, diff);
        }
        double deposit = (donGiaPhong * soDem * depositPercent) / 100.0;

        String insertRoomSql = "INSERT INTO Booking_Room (BookingId, RoomId, BookingStatus, "
                + "ExpectedCheckInDate, ExpectedCheckOutDate, Price, Deposit) "
                + "VALUES (?, ?, 'Confirmed', ?, ?, ?, ?)";
        try (PreparedStatement psRoom = conn.prepareStatement(insertRoomSql)) {
            psRoom.setString(1, maBooking);
            psRoom.setString(2, maPhong);
            psRoom.setDate(3, checkIn);
            psRoom.setDate(4, checkOut);
            psRoom.setDouble(5, donGiaPhong);
            psRoom.setDouble(6, deposit);
            psRoom.executeUpdate();
        }
    }

    private double getRoomDepositPercent(Connection conn, String maPhong) throws SQLException {
        String sql = "SELECT rt.DepositPercent FROM Room r JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId WHERE r.RoomId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        }
        return 0;
    }

    private String getNextBookingIdFromDB(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT dbo.fn_SinhMaBooking()");
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }
        return "BK001";
    }

    private void cleanupExpiredPendingBookings(Connection conn) throws SQLException {
        String sql = "UPDATE br "
                + "SET br.BookingStatus = 'Cancelled' "
                + "FROM Booking_Room br "
                + "JOIN Booking b ON br.BookingId = b.BookingId "
                + "LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId "
                + "WHERE br.BookingStatus = 'Confirmed' "
                + "  AND (inv.InvoiceStatus = 'Unpaid' OR inv.InvoiceStatus IS NULL) "
                + "  AND DATEDIFF(MINUTE, b.CreateDate, GETDATE()) >= 10";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    private void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    private void closeTransactionConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
