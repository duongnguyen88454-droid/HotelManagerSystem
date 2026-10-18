package com.mycompany.hotelmanagersystem.manager.dto;

import java.time.format.DateTimeFormatter;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO dữ liệu báo cáo Tổng Doanh Thu từ các phiếu thu chi cho Manager.
 */
public class PaymentReceiptItemDTO {

    private String paymentId;
    private String invoiceId;
    private String bookingId;
    private String customerName;
    private LocalDateTime paymentDate;
    private String paymentMethod;
    private String staffName;
    private BigDecimal totalAmount;
    private String note;

    public PaymentReceiptItemDTO() {
    }

    public PaymentReceiptItemDTO(String paymentId, String invoiceId, String bookingId,
            String customerName, LocalDateTime paymentDate, String paymentMethod,
            String staffName, BigDecimal totalAmount, String note) {
        this.paymentId = paymentId;
        this.invoiceId = invoiceId;
        this.bookingId = bookingId;
        this.customerName = customerName;
        this.paymentDate = paymentDate;
        this.paymentMethod = paymentMethod;
        this.staffName = staffName;
        this.totalAmount = (totalAmount != null) ? totalAmount : BigDecimal.ZERO;
        this.note = note;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    public String getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(String invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public LocalDateTime getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(LocalDateTime paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getFormattedPaymentDate() {
        return (paymentDate != null)
                ? paymentDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
