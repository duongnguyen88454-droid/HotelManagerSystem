package com.mycompany.hotelmanagersystem.manager.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * DTO dữ liệu báo cáo Doanh Thu Hóa Đơn cho Manager.
 */
public class InvoiceRevenueItemDTO {

    private String invoiceId;
    private String bookingId;
    private String customerName;
    private String roomNames;
    private LocalDateTime createDate;
    private BigDecimal deposit;
    private BigDecimal roomCharge;
    private BigDecimal serviceCharge;
    private BigDecimal surcharge;
    private BigDecimal finalTotalAmount;
    private BigDecimal paidAmount;
    private String invoiceStatus;

    public InvoiceRevenueItemDTO() {
    }

    public InvoiceRevenueItemDTO(String invoiceId, String bookingId, String customerName,
            String roomNames, LocalDateTime createDate, BigDecimal deposit,
            BigDecimal roomCharge, BigDecimal serviceCharge, BigDecimal surcharge,
            BigDecimal finalTotalAmount, BigDecimal paidAmount, String invoiceStatus) {
        this.invoiceId = invoiceId;
        this.bookingId = bookingId;
        this.customerName = customerName;
        this.roomNames = roomNames;
        this.createDate = createDate;
        this.deposit = (deposit != null) ? deposit : BigDecimal.ZERO;
        this.roomCharge = (roomCharge != null) ? roomCharge : BigDecimal.ZERO;
        this.serviceCharge = (serviceCharge != null) ? serviceCharge : BigDecimal.ZERO;
        this.surcharge = (surcharge != null) ? surcharge : BigDecimal.ZERO;
        this.finalTotalAmount = (finalTotalAmount != null) ? finalTotalAmount : BigDecimal.ZERO;
        this.paidAmount = (paidAmount != null) ? paidAmount : BigDecimal.ZERO;
        this.invoiceStatus = invoiceStatus;
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

    public String getRoomNames() {
        return roomNames;
    }

    public void setRoomNames(String roomNames) {
        this.roomNames = roomNames;
    }

    public LocalDateTime getCreateDate() {
        return createDate;
    }

    public void setCreateDate(LocalDateTime createDate) {
        this.createDate = createDate;
    }

    public String getFormattedCreateDate() {
        return (createDate != null)
                ? createDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : "";
    }

    public BigDecimal getDeposit() {
        return deposit;
    }

    public void setDeposit(BigDecimal deposit) {
        this.deposit = deposit;
    }

    public BigDecimal getRoomCharge() {
        return roomCharge;
    }

    public void setRoomCharge(BigDecimal roomCharge) {
        this.roomCharge = roomCharge;
    }

    public BigDecimal getServiceCharge() {
        return serviceCharge;
    }

    public void setServiceCharge(BigDecimal serviceCharge) {
        this.serviceCharge = serviceCharge;
    }

    public BigDecimal getSurcharge() {
        return surcharge;
    }

    public void setSurcharge(BigDecimal surcharge) {
        this.surcharge = surcharge;
    }

    public BigDecimal getFinalTotalAmount() {
        return finalTotalAmount;
    }

    public void setFinalTotalAmount(BigDecimal finalTotalAmount) {
        this.finalTotalAmount = finalTotalAmount;
    }

    public BigDecimal getPaidAmount() {
        return paidAmount;
    }

    public void setPaidAmount(BigDecimal paidAmount) {
        this.paidAmount = paidAmount;
    }

    public String getInvoiceStatus() {
        return invoiceStatus;
    }

    public void setInvoiceStatus(String invoiceStatus) {
        this.invoiceStatus = invoiceStatus;
    }
}
