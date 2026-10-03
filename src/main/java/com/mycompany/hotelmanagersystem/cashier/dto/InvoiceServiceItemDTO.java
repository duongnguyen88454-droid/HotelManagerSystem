package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * DTO chi tiết dịch vụ đã sử dụng trong hóa đơn quyết toán.
 */
public class InvoiceServiceItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBookingDichVu;
    private String maPhong;
    private String tenDichVu;
    private Double donGia;
    private int soLuong;
    private Double thanhTien;
    private Timestamp thoiDiemThem;

    public InvoiceServiceItemDTO() {
    }

    public InvoiceServiceItemDTO(String maBookingDichVu, String maPhong, String tenDichVu,
                                 Double donGia, int soLuong, Double thanhTien, Timestamp thoiDiemThem) {
        this.maBookingDichVu = maBookingDichVu;
        this.maPhong = maPhong;
        this.tenDichVu = tenDichVu;
        this.donGia = donGia;
        this.soLuong = soLuong;
        this.thanhTien = thanhTien;
        this.thoiDiemThem = thoiDiemThem;
    }

    public String getMaBookingDichVu() {
        return maBookingDichVu;
    }

    public void setMaBookingDichVu(String maBookingDichVu) {
        this.maBookingDichVu = maBookingDichVu;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getTenDichVu() {
        return tenDichVu;
    }

    public void setTenDichVu(String tenDichVu) {
        this.tenDichVu = tenDichVu;
    }

    public Double getDonGia() {
        return donGia;
    }

    public void setDonGia(Double donGia) {
        this.donGia = donGia;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public Double getThanhTien() {
        return thanhTien;
    }

    public void setThanhTien(Double thanhTien) {
        this.thanhTien = thanhTien;
    }

    public Timestamp getThoiDiemThem() {
        return thoiDiemThem;
    }

    public void setThoiDiemThem(Timestamp thoiDiemThem) {
        this.thoiDiemThem = thoiDiemThem;
    }
}
