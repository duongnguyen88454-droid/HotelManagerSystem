package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;

/**
 * DTO kết quả thực thi Check-out trả phòng.
 */
public class CheckOutResultDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private boolean success;
    private String message;
    private String maBooking;
    private String maHoaDon;
    private boolean allRoomsCheckedOut;

    public CheckOutResultDTO() {
    }

    public CheckOutResultDTO(boolean success, String message, String maBooking,
                             String maHoaDon, boolean allRoomsCheckedOut) {
        this.success = success;
        this.message = message;
        this.maBooking = maBooking;
        this.maHoaDon = maHoaDon;
        this.allRoomsCheckedOut = allRoomsCheckedOut;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public boolean isAllRoomsCheckedOut() {
        return allRoomsCheckedOut;
    }

    public void setAllRoomsCheckedOut(boolean allRoomsCheckedOut) {
        this.allRoomsCheckedOut = allRoomsCheckedOut;
    }
}
