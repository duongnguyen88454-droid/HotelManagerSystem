package com.mycompany.hotelmanagersystem.booking.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng BOOKING_DICHVU (Dịch vụ gắn cho từng phòng trong booking)
 */
public class BookingDichVu implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBookingDichVu;
    private String maBooking;
    private String maPhong;
    private String maDichVu;
    private double donGia;
    private int soLuong;
    private Timestamp thoiDiemThem;
    private String nguoiThem; // 'KhachHang', 'NhanVien'
    private String maNV;

    public BookingDichVu() {
    }

    public BookingDichVu(String maBookingDichVu, String maBooking, String maPhong, String maDichVu, double donGia, int soLuong, Timestamp thoiDiemThem, String nguoiThem, String maNV) {
        this.maBookingDichVu = maBookingDichVu;
        this.maBooking = maBooking;
        this.maPhong = maPhong;
        this.maDichVu = maDichVu;
        this.donGia = donGia;
        this.soLuong = soLuong;
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

    public String getMaDichVu() {
        return maDichVu;
    }

    public void setMaDichVu(String maDichVu) {
        this.maDichVu = maDichVu;
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

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }
}
