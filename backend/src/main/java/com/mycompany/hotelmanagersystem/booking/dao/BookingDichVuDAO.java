package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

/**
 * DAO chuyên trách quản lý các dịch vụ đi kèm trong đơn đặt phòng (Booking Services).
 * Tách biệt từ BookingDAO theo QT 2.1 và QT 2.3 trong ARCHITECTURE_RULES.md.
 */
public class BookingDichVuDAO {

    private final InvoiceWriter invoiceWriter = new InvoiceWriter();

    /**
     * Điều phối thêm dịch vụ vào phòng cụ thể trong đơn booking
     */
    public boolean addServiceToBookingRoom(String maBooking, String maPhong, String maDichVu, int soLuong,
            String nguoiThem) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            validateRoomBelongsToBooking(conn, maBooking, maPhong);
            double donGia = getActiveServicePrice(conn, maDichVu);
            insertSingleBookingService(conn, maBooking, maPhong,
                    new CartServiceItemDTO(maDichVu, "", donGia, soLuong),
                    nguoiThem != null ? nguoiThem : "KhachHang");
            invoiceWriter.updateBookingTotalCost(conn, maBooking, donGia * soLuong);

            conn.commit();
            return true;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    /**
     * Điều phối xóa dịch vụ khỏi phòng đã đặt (khi chưa check-in)
     */
    public boolean removeServiceFromBookingRoom(String maBookingDichVu, String maBooking) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            double thanhTien = getBookingServiceCost(conn, maBookingDichVu, maBooking);
            if (thanhTien < 0) {
                conn.rollback();
                return false;
            }

            deleteBookingServiceRecord(conn, maBookingDichVu, maBooking);
            invoiceWriter.updateBookingTotalCost(conn, maBooking, -thanhTien);

            conn.commit();
            return true;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    /**
     * Trách nhiệm: Tra cứu giá và chèn danh sách dịch vụ đã chọn vào bảng BOOKING_DICHVU (nhận Connection)
     */
    void insertBookingServices(Connection conn, String maBooking, String maPhong,
            Map<String, Integer> selectedServices) throws SQLException {
        if (selectedServices == null || selectedServices.isEmpty()) {
            return;
        }

        String selectPriceSql = "SELECT BasePrice FROM Service WHERE ServiceId = ?";
        for (Map.Entry<String, Integer> entry : selectedServices.entrySet()) {
            String maDichVu = entry.getKey();
            int soLuong = entry.getValue() != null ? entry.getValue() : 0;
            if (soLuong > 0) {
                double donGiaDichVu = 0;
                try (PreparedStatement psPrice = conn.prepareStatement(selectPriceSql)) {
                    psPrice.setString(1, maDichVu);
                    try (ResultSet rsPrice = psPrice.executeQuery()) {
                        if (rsPrice.next()) {
                            donGiaDichVu = rsPrice.getDouble("BasePrice");
                        }
                    }
                }
                insertSingleBookingService(conn, maBooking, maPhong,
                        new CartServiceItemDTO(maDichVu, "", donGiaDichVu, soLuong), "KhachHang");
            }
        }
    }

    /**
     * Trách nhiệm: Chèn hoặc cộng dồn dịch vụ phòng vào bảng Booking_Room_Service (nhận Connection)
     */
    void insertSingleBookingService(Connection conn, String maBooking, String maPhong,
            CartServiceItemDTO sItem, String nguoiThem) throws SQLException {
        String upsertSql = "IF EXISTS (SELECT 1 FROM Booking_Room_Service WHERE BookingId = ? AND RoomId = ? AND ServiceId = ?) "
                + "    UPDATE Booking_Room_Service SET Quantity = Quantity + ?, UnitPrice = ? "
                + "    WHERE BookingId = ? AND RoomId = ? AND ServiceId = ? "
                + "ELSE "
                + "    INSERT INTO Booking_Room_Service (BookingId, RoomId, ServiceId, UnitPrice, Quantity) "
                + "    VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement psBdv = conn.prepareStatement(upsertSql)) {
            psBdv.setString(1, maBooking);
            psBdv.setString(2, maPhong);
            psBdv.setString(3, sItem.getMaDichVu());
            psBdv.setInt(4, sItem.getSoLuong());
            psBdv.setDouble(5, sItem.getDonGia());
            psBdv.setString(6, maBooking);
            psBdv.setString(7, maPhong);
            psBdv.setString(8, sItem.getMaDichVu());
            psBdv.setString(9, maBooking);
            psBdv.setString(10, maPhong);
            psBdv.setString(11, sItem.getMaDichVu());
            psBdv.setDouble(12, sItem.getDonGia());
            psBdv.setInt(13, sItem.getSoLuong());
            psBdv.executeUpdate();
        }
    }

    /**
     * Trách nhiệm: Kiểm tra phòng có thuộc đơn đặt phòng hay không
     */
    void validateRoomBelongsToBooking(Connection conn, String maBooking, String maPhong) throws SQLException {
        String checkRoomSql = "SELECT 1 FROM Booking_Room WHERE BookingId = ? AND RoomId = ?";
        try (PreparedStatement psCheck = conn.prepareStatement(checkRoomSql)) {
            psCheck.setString(1, maBooking);
            psCheck.setString(2, maPhong);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Phòng không thuộc đơn đặt phòng này!");
                }
            }
        }
    }

    /**
     * Trách nhiệm: Lấy đơn giá dịch vụ đang áp dụng
     */
    double getActiveServicePrice(Connection conn, String maDichVu) throws SQLException {
        String selectPriceSql = "SELECT BasePrice FROM Service WHERE ServiceId = ?";
        try (PreparedStatement psPrice = conn.prepareStatement(selectPriceSql)) {
            psPrice.setString(1, maDichVu);
            try (ResultSet rs = psPrice.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("BasePrice");
                } else {
                    throw new SQLException("Dịch vụ không tồn tại hoặc đã tạm dừng!");
                }
            }
        }
    }

    /**
     * Trách nhiệm: Lấy thành tiền của 1 dịch vụ đã đặt trong phòng (trả về -1 nếu không tìm thấy)
     */
    double getBookingServiceCost(Connection conn, String maBookingDichVu, String maBooking)
            throws SQLException {
        String roomId = "";
        String serviceId = maBookingDichVu;
        if (maBookingDichVu != null && maBookingDichVu.contains("_")) {
            String[] parts = maBookingDichVu.split("_", 2);
            roomId = parts[0];
            serviceId = parts[1];
        }
        String selectSql = "SELECT UnitPrice, Quantity FROM Booking_Room_Service WHERE BookingId = ? "
                + "AND (? = '' OR RoomId = ?) AND ServiceId = ?";
        try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
            psSelect.setString(1, maBooking);
            psSelect.setString(2, roomId);
            psSelect.setString(3, roomId);
            psSelect.setString(4, serviceId);
            try (ResultSet rs = psSelect.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("UnitPrice") * rs.getInt("Quantity");
                }
            }
        }
        return -1;
    }

    /**
     * Trách nhiệm: Xóa bản ghi dịch vụ khỏi bảng BOOKING_DICHVU
     */
    void deleteBookingServiceRecord(Connection conn, String maBookingDichVu, String maBooking)
            throws SQLException {
        String roomId = "";
        String serviceId = maBookingDichVu;
        if (maBookingDichVu != null && maBookingDichVu.contains("_")) {
            String[] parts = maBookingDichVu.split("_", 2);
            roomId = parts[0];
            serviceId = parts[1];
        }
        String deleteSql = "DELETE FROM Booking_Room_Service WHERE BookingId = ? "
                + "AND (? = '' OR RoomId = ?) AND ServiceId = ?";
        try (PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
            psDelete.setString(1, maBooking);
            psDelete.setString(2, roomId);
            psDelete.setString(3, roomId);
            psDelete.setString(4, serviceId);
            psDelete.executeUpdate();
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
