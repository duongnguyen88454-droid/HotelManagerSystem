package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * DTO đại diện cho 1 dòng dịch vụ được gọi gắn liền với phòng
 */
public class BookingDichVuItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBookingDichVu;
    private String maDichVu;
    private String tenDichVu;
    private double donGia;
    private int soLuong;
    private double thanhTien;
    private Timestamp thoiDiemThem;
    private String nguoiThem; // 'KhachHang', 'NhanVien'

    public BookingDichVuItemDTO() {
    }

    public BookingDichVuItemDTO(String maBookingDichVu, String maDichVu, String tenDichVu, 
                                double donGia, int soLuong, Timestamp thoiDiemThem, String nguoiThem) {
        this.maBookingDichVu = maBookingDichVu;
        this.maDichVu = maDichVu;
        this.tenDichVu = tenDichVu;
        this.donGia = donGia;
        this.soLuong = soLuong;
        this.thanhTien = donGia * soLuong;
        this.thoiDiemThem = thoiDiemThem;
        this.nguoiThem = nguoiThem;
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
        this.thanhTien = this.donGia * this.soLuong;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
        this.thanhTien = this.donGia * this.soLuong;
    }

    public double getThanhTien() {
        return thanhTien;
    }

    public void setThanhTien(double thanhTien) {
        this.thanhTien = thanhTien;
    }

    public Timestamp getThoiDiemThem() {
        return thoiDiemThem;
    }

    public void setThoiDiemThem(Timestamp thoiDiemThem) {
        this.thoiDiemThem = thoiDiemThem;
    }

    public String getNguoiThem() {
        return nguoiThem;
    }

    public void setNguoiThem(String nguoiThem) {
        this.nguoiThem = nguoiThem;
    }
}
