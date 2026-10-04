package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;

/**
 * DTO kết quả thực thi thanh toán / đặt cọc.
 */
public class PaymentResultDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private boolean success;
    private String message;
    private String maHoaDon;
    private String maThanhToan;
    private Double soTien;
    private String trangThaiHoaDon;

    public PaymentResultDTO() {
    }

    public PaymentResultDTO(boolean success, String message, String maHoaDon,
                            String maThanhToan, Double soTien, String trangThaiHoaDon) {
        this.success = success;
        this.message = message;
        this.maHoaDon = maHoaDon;
        this.maThanhToan = maThanhToan;
        this.soTien = soTien;
        this.trangThaiHoaDon = trangThaiHoaDon;
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

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public String getMaThanhToan() {
        return maThanhToan;
    }

    public void setMaThanhToan(String maThanhToan) {
        this.maThanhToan = maThanhToan;
    }

    public Double getSoTien() {
        return soTien;
    }

    public void setSoTien(Double soTien) {
        this.soTien = soTien;
    }

    public String getTrangThaiHoaDon() {
        return trangThaiHoaDon;
    }

    public void setTrangThaiHoaDon(String trangThaiHoaDon) {
        this.trangThaiHoaDon = trangThaiHoaDon;
    }
}
