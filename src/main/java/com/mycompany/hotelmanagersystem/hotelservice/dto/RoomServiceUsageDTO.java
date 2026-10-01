package com.mycompany.hotelmanagersystem.hotelservice.dto;

import java.time.LocalDateTime;

/**
 * DTO đại diện cho một bản ghi dịch vụ đã sử dụng trong đơn booking tại phòng.
 */
public class RoomServiceUsageDTO {

    private String maBookingDichVu;
    private String maDichVu;
    private String tenDichVu;
    private double donGia;
    private int soLuong;
    private double thanhTien;
    private LocalDateTime thoiDiemThem;
    private String nguoiThem;
    private String maNV;

    public RoomServiceUsageDTO() {
    }

    public RoomServiceUsageDTO(String maBookingDichVu, String maDichVu, String tenDichVu, double donGia,
                              int soLuong, double thanhTien, LocalDateTime thoiDiemThem, String nguoiThem, String maNV) {
        this.maBookingDichVu = maBookingDichVu;
        this.maDichVu = maDichVu;
        this.tenDichVu = tenDichVu;
        this.donGia = donGia;
        this.soLuong = soLuong;
        this.thanhTien = thanhTien;
        this.thoiDiemThem = thoiDiemThem;
        this.nguoiThem = nguoiThem;
        this.maNV = maNV;
    }

    public String getMaBookingDichVu() {
        return maBookingDichVu;
    }

    public void setMaBookingDichVu(String maBookingDichVu) {
        this.maBookingDichVu = maBookingDichVu;
    }

    public String getMaDichVu() {
        return maDichVu;
    }

    public void setMaDichVu(String maDichVu) {
        this.maDichVu = maDichVu;
    }

    public String getTenDichVu() {
        return tenDichVu;
    }

    public void setTenDichVu(String tenDichVu) {
        this.tenDichVu = tenDichVu;
    }

    public double getDonGia() {
        return donGia;
    }

    public void setDonGia(double donGia) {
        this.donGia = donGia;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public double getThanhTien() {
        return thanhTien;
    }

    public void setThanhTien(double thanhTien) {
        this.thanhTien = thanhTien;
    }

    public LocalDateTime getThoiDiemThem() {
        return thoiDiemThem;
    }

    public void setThoiDiemThem(LocalDateTime thoiDiemThem) {
        this.thoiDiemThem = thoiDiemThem;
    }

    public String getNguoiThem() {
        return nguoiThem;
    }

    public void setNguoiThem(String nguoiThem) {
        this.nguoiThem = nguoiThem;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }
}
