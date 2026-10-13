package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * DTO đại diện cho bản ghi hủy phòng từ bảng CancellationHistory và function fn_TinhTienHoanTraHuyPhong.
 */
public class CancellationRecordDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String cancellationId;
    private String bookingId;
    private String roomId;
    private String roomName;
    private String cancelledBy;
    private BigDecimal depositAtCancellation;
    private LocalDateTime cancellationDate;
    private BigDecimal cancellationFee;
    private String refundStatus;
    private String reason;
    private BigDecimal refundAmount;

    public CancellationRecordDTO() {
    }

    public CancellationRecordDTO(String cancellationId, String bookingId, String roomId,
                                 String roomName, String cancelledBy, BigDecimal depositAtCancellation,
                                 LocalDateTime cancellationDate, BigDecimal cancellationFee,
                                 String refundStatus, String reason, BigDecimal refundAmount) {
        this.cancellationId = cancellationId;
        this.bookingId = bookingId;
        this.roomId = roomId;
        this.roomName = roomName;
        this.cancelledBy = cancelledBy;
        this.depositAtCancellation = depositAtCancellation;
        this.cancellationDate = cancellationDate;
        this.cancellationFee = cancellationFee;
        this.refundStatus = refundStatus;
        this.reason = reason;
        this.refundAmount = refundAmount;
    }

    public String getCancellationId() {
        return cancellationId;
    }

    public void setCancellationId(String cancellationId) {
        this.cancellationId = cancellationId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getCancelledBy() {
        return cancelledBy;
    }

    public void setCancelledBy(String cancelledBy) {
        this.cancelledBy = cancelledBy;
    }

    public BigDecimal getDepositAtCancellation() {
        return depositAtCancellation;
    }

    public void setDepositAtCancellation(BigDecimal depositAtCancellation) {
        this.depositAtCancellation = depositAtCancellation;
    }

    public LocalDateTime getCancellationDate() {
        return cancellationDate;
    }

    public void setCancellationDate(LocalDateTime cancellationDate) {
        this.cancellationDate = cancellationDate;
    }

    public BigDecimal getCancellationFee() {
        return cancellationFee;
    }

    public void setCancellationFee(BigDecimal cancellationFee) {
        this.cancellationFee = cancellationFee;
    }

    public String getRefundStatus() {
        return refundStatus;
    }

    public void setRefundStatus(String refundStatus) {
        this.refundStatus = refundStatus;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public BigDecimal getRefundAmount() {
        return refundAmount;
    }

    public void setRefundAmount(BigDecimal refundAmount) {
        this.refundAmount = refundAmount;
    }
}
