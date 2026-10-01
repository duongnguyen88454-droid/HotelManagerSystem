package com.mycompany.hotelmanagersystem.booking.dto;

public class CheckInResultDTO {
    private boolean success;
    private String message;
    private String maBooking;
    private String maPhong;
    private String newRoomStatus;

    public CheckInResultDTO() {
    }

    public CheckInResultDTO(boolean success, String message, String maBooking,
                            String maPhong, String newRoomStatus) {
        this.success = success;
        this.message = message;
        this.maBooking = maBooking;
        this.maPhong = maPhong;
        this.newRoomStatus = newRoomStatus;
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

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getNewRoomStatus() {
        return newRoomStatus;
    }

    public void setNewRoomStatus(String newRoomStatus) {
        this.newRoomStatus = newRoomStatus;
    }
}
