package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.manager.dto.InvoiceRevenueItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.PaymentReceiptItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.ProductRevenueItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.RoomRevenueItemDTO;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DAO truy vấn các báo cáo doanh thu chi tiết (Hóa đơn, Tiền phòng, Sản phẩm, Phiếu thu).
 */
public class RevenueReportDAO extends BaseRepository<InvoiceRevenueItemDTO, String> {

    private static final String SQL_INVOICE_REPORT =
            "SELECT * FROM v_InvoiceRevenueReport "
            + "WHERE CAST(CreateDate AS DATE) >= ? AND CAST(CreateDate AS DATE) <= ? "
            + "AND (? IS NULL OR ? = '' OR EXISTS (SELECT 1 FROM Payment p2 "
            + "LEFT JOIN Employee emp ON p2.ProcessBy = emp.AccountId "
            + "WHERE p2.InvoiceId = v_InvoiceRevenueReport.InvoiceId AND emp.EmployeeId = ?)) "
            + "ORDER BY CreateDate DESC";

    private static final String SQL_ROOM_REPORT =
            "SELECT r.RoomId, r.RoomName, rt.RoomTypeName, rt.BasePrice, "
            + "ISNULL(COUNT(br.BookingId), 0) AS TotalBookings, "
            + "ISNULL(SUM(CASE WHEN DATEDIFF(day, br.ExpectedCheckInDate, br.ExpectedCheckOutDate) <= 0 THEN 1 "
            + "ELSE DATEDIFF(day, br.ExpectedCheckInDate, br.ExpectedCheckOutDate) END), 0) AS TotalNights, "
            + "ISNULL(SUM((CASE WHEN DATEDIFF(day, br.ExpectedCheckInDate, br.ExpectedCheckOutDate) <= 0 THEN 1 "
            + "ELSE DATEDIFF(day, br.ExpectedCheckInDate, br.ExpectedCheckOutDate) END) * br.Price), 0) AS TotalRevenue "
            + "FROM Room r "
            + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
            + "LEFT JOIN Booking_Room br ON r.RoomId = br.RoomId "
            + "AND br.BookingStatus NOT IN ('Cancelled') "
            + "AND br.ExpectedCheckInDate >= ? AND br.ExpectedCheckInDate <= ? "
            + "AND (? IS NULL OR ? = '' OR EXISTS (SELECT 1 FROM Booking b "
            + "INNER JOIN Employee emp ON b.CreateBy = emp.AccountId WHERE b.BookingId = br.BookingId AND emp.EmployeeId = ?)) "
            + "GROUP BY r.RoomId, r.RoomName, rt.RoomTypeName, rt.BasePrice "
            + "ORDER BY TotalRevenue DESC, TotalNights DESC, r.RoomName ASC";

    private static final String SQL_PRODUCT_REPORT =
            "SELECT s.ServiceId, s.ServiceName, s.BasePrice, "
            + "ISNULL(SUM(brs.Quantity), 0) AS TotalQuantity, "
            + "ISNULL(SUM(brs.Quantity * brs.UnitPrice), 0) AS TotalRevenue "
            + "FROM Service s "
            + "LEFT JOIN Booking_Room_Service brs ON s.ServiceId = brs.ServiceId "
            + "LEFT JOIN Booking_Room br ON brs.BookingId = br.BookingId AND brs.RoomId = br.RoomId "
            + "LEFT JOIN Invoice inv ON br.BookingId = inv.BookingId "
            + "WHERE (inv.CreateDate IS NULL OR (CAST(inv.CreateDate AS DATE) >= ? AND CAST(inv.CreateDate AS DATE) <= ?)) "
            + "GROUP BY s.ServiceId, s.ServiceName, s.BasePrice "
            + "ORDER BY TotalRevenue DESC, TotalQuantity DESC";

    private static final String SQL_PAYMENT_RECEIPT_REPORT =
            "SELECT * FROM v_PaymentReceiptReport "
            + "WHERE CAST(PaymentDate AS DATE) >= ? AND CAST(PaymentDate AS DATE) <= ? "
            + "AND (? IS NULL OR ? = '' OR EmployeeId = ?) "
            + "ORDER BY PaymentDate DESC";

    @Override
    protected String getTableName() {
        return "v_InvoiceRevenueReport";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "InvoiceId";
    }

    @Override
    protected RowMapper<InvoiceRevenueItemDTO> getRowMapper() {
        return this::mapInvoiceRow;
    }

    public List<InvoiceRevenueItemDTO> getInvoiceRevenueReport(LocalDate from, LocalDate to, String empId) {
        Date sqlFrom = Date.valueOf(from);
        Date sqlTo = Date.valueOf(to);
        return queryCustom(SQL_INVOICE_REPORT, this::mapInvoiceRow, sqlFrom, sqlTo, empId, empId, empId);
    }

    public List<RoomRevenueItemDTO> getRoomRevenueReport(LocalDate from, LocalDate to, String empId) {
        Date sqlFrom = Date.valueOf(from);
        Date sqlTo = Date.valueOf(to);
        return queryCustom(SQL_ROOM_REPORT, this::mapRoomRow, sqlFrom, sqlTo, empId, empId, empId);
    }

    public List<ProductRevenueItemDTO> getProductRevenueReport(LocalDate from, LocalDate to) {
        Date sqlFrom = Date.valueOf(from);
        Date sqlTo = Date.valueOf(to);
        return queryCustom(SQL_PRODUCT_REPORT, this::mapProductRow, sqlFrom, sqlTo);
    }

    public List<PaymentReceiptItemDTO> getPaymentReceiptReport(LocalDate from, LocalDate to, String empId) {
        Date sqlFrom = Date.valueOf(from);
        Date sqlTo = Date.valueOf(to);
        return queryCustom(SQL_PAYMENT_RECEIPT_REPORT, this::mapPaymentRow, sqlFrom, sqlTo, empId, empId, empId);
    }

    private InvoiceRevenueItemDTO mapInvoiceRow(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("CreateDate");
        LocalDateTime createDate = (ts != null) ? ts.toLocalDateTime() : null;
        return new InvoiceRevenueItemDTO(
                rs.getString("InvoiceId"), rs.getString("BookingId"), rs.getString("CustomerName"),
                rs.getString("RoomNames"), createDate, rs.getBigDecimal("DepositAmount"),
                rs.getBigDecimal("TotalRoomCharge"), rs.getBigDecimal("TotalServiceCharge"),
                rs.getBigDecimal("Surcharge"), rs.getBigDecimal("FinalTotalAmount"),
                rs.getBigDecimal("PaidAmount"), rs.getString("InvoiceStatus")
        );
    }

    private RoomRevenueItemDTO mapRoomRow(ResultSet rs) throws SQLException {
        return new RoomRevenueItemDTO(
                rs.getString("RoomId"),
                rs.getString("RoomName"),
                rs.getString("RoomTypeName"),
                rs.getBigDecimal("BasePrice"),
                rs.getInt("TotalBookings"),
                rs.getInt("TotalNights"),
                rs.getBigDecimal("TotalRevenue")
        );
    }

    private ProductRevenueItemDTO mapProductRow(ResultSet rs) throws SQLException {
        return new ProductRevenueItemDTO(
                rs.getString("ServiceId"), rs.getString("ServiceName"), rs.getBigDecimal("BasePrice"),
                rs.getInt("TotalQuantity"), rs.getBigDecimal("TotalRevenue")
        );
    }

    private PaymentReceiptItemDTO mapPaymentRow(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("PaymentDate");
        LocalDateTime payDate = (ts != null) ? ts.toLocalDateTime() : null;
        return new PaymentReceiptItemDTO(
                rs.getString("PaymentId"), rs.getString("InvoiceId"), rs.getString("BookingId"),
                rs.getString("CustomerName"), payDate, rs.getString("PaymentMethod"),
                rs.getString("StaffName"), rs.getBigDecimal("TotalAmount"), rs.getString("Note")
        );
    }
}
