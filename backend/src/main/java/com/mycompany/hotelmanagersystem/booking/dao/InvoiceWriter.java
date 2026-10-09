package com.mycompany.hotelmanagersystem.booking.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Lớp phụ trợ nội bộ (package-private) quản lý thao tác Hóa đơn trong Transaction của Booking.
 * Tuân thủ QT 2.2 và QT 2.3 trong ARCHITECTURE_RULES.md.
 */
class InvoiceWriter {

    /**
     * Trách nhiệm: Khởi tạo/đồng bộ hóa đơn trong bảng Invoice nếu chưa tồn tại
     */
    void ensureInvoiceExists(Connection conn, String maBooking) throws SQLException {
        String checkInvoiceSql = "SELECT 1 FROM Invoice WHERE BookingId = ?";
        boolean hasInvoice = false;
        try (PreparedStatement psCheckInv = conn.prepareStatement(checkInvoiceSql)) {
            psCheckInv.setString(1, maBooking);
            try (ResultSet rsInv = psCheckInv.executeQuery()) {
                if (rsInv.next()) {
                    hasInvoice = true;
                }
            }
        }

        if (!hasInvoice) {
            String invoiceId = "INV001";
            String getInvoiceIdSql = "SELECT dbo.fn_SinhMaInvoice()";
            try (PreparedStatement psId = conn.prepareStatement(getInvoiceIdSql);
                 ResultSet rsId = psId.executeQuery()) {
                if (rsId.next() && rsId.getString(1) != null) {
                    invoiceId = rsId.getString(1);
                }
            }

            String insertInvSql = "INSERT INTO Invoice (InvoiceId, BookingId, CreateDate, "
                    + "TotalRoomCharge, TotalServiceCharge, EarlyCheckInFee, LateCheckOutFee, "
                    + "InvoiceStatus, FinalTotalAmount) "
                    + "VALUES (?, ?, GETDATE(), dbo.fn_TinhTienPhongBooking(?), dbo.fn_TinhTienDichVuBooking(?), "
                    + "0, 0, 'Unpaid', dbo.fn_TinhTongTienHoaDonDuKien(?))";
            try (PreparedStatement psInv = conn.prepareStatement(insertInvSql)) {
                psInv.setString(1, invoiceId);
                psInv.setString(2, maBooking);
                psInv.setString(3, maBooking);
                psInv.setString(4, maBooking);
                psInv.setString(5, maBooking);
                psInv.executeUpdate();
            }
        }
    }

    /**
     * Trách nhiệm: Cập nhật tổng chi phí dịch vụ và tổng tiền cuối cùng trong Invoice
     */
    void updateBookingTotalCost(Connection conn, String maBooking, double deltaAmount) throws SQLException {
        String updateInvSql = "UPDATE Invoice SET "
                + "TotalServiceCharge = TotalServiceCharge + ?, "
                + "FinalTotalAmount = FinalTotalAmount + ? "
                + "WHERE BookingId = ?";
        try (PreparedStatement psUpdate = conn.prepareStatement(updateInvSql)) {
            psUpdate.setDouble(1, deltaAmount);
            psUpdate.setDouble(2, deltaAmount);
            psUpdate.setString(3, maBooking);
            psUpdate.executeUpdate();
        }
    }
}
