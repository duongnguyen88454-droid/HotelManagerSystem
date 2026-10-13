package com.mycompany.hotelmanagersystem.hotelservice.dto;

/**
 * DTO đóng gói kết quả thực hiện gọi thêm dịch vụ phòng.
 */
public class ServiceOrderResultDTO {

    private boolean success;
    private String message;
    private String maBookingDichVu;
    private double tongTienDichVuMoi;

    public ServiceOrderResultDTO() {
    }

    public ServiceOrderResultDTO(boolean success, String message, String maBookingDichVu, double tongTienDichVuMoi) {
        this.success = success;
        this.message = message;
        this.maBookingDichVu = maBookingDichVu;
        this.tongTienDichVuMoi = tongTienDichVuMoi;
    }

    public static ServiceOrderResultDTO failure(String message) {
        return new ServiceOrderResultDTO(false, message, null, 0);
    }

    public static ServiceOrderResultDTO success(String message, String maBookingDichVu, double tongTienDichVuMoi) {
        return new ServiceOrderResultDTO(true, message, maBookingDichVu, tongTienDichVuMoi);
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

    public String getMaBookingDichVu() {
        return maBookingDichVu;
    }

    public void setMaBookingDichVu(String maBookingDichVu) {
        this.maBookingDichVu = maBookingDichVu;
    }

    public double getTongTienDichVuMoi() {
        return tongTienDichVuMoi;
    }

    public void setTongTienDichVuMoi(double tongTienDichVuMoi) {
        this.tongTienDichVuMoi = tongTienDichVuMoi;
    }
}
