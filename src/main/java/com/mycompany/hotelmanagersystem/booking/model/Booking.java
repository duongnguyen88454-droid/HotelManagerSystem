package com.mycompany.hotelmanagersystem.booking.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng BOOKING
 */
public class Booking implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBooking;
    private String maKH;
    private String maTaiKhoan; // Khóa ngoại trỏ đến TAIKHOAN (Người tạo đơn trên web)
    private String maNV;
    private Timestamp ngayDat;
    private String trangThai; // 'DaXacNhan', 'DaCheckIn', 'DaCheckOut', 'DaHuy'
    private double chiPhiDuKien;
    private String phuongPhapBooking; // 'Online', 'Offline'
    private Timestamp thoiDiemHuy;
    private Double phiHuy;

    public Booking() {
    }

    public Booking(String maBooking, String maKH, String maTaiKhoan, String maNV, Timestamp ngayDat, String trangThai, double chiPhiDuKien,
            String phuongPhapBooking, Timestamp thoiDiemHuy, Double phiHuy) {
        this.maBooking = maBooking;
        this.maKH = maKH;
        this.maTaiKhoan = maTaiKhoan;
        this.maNV = maNV;
        this.ngayDat = ngayDat;
        this.trangThai = trangThai;
        this.chiPhiDuKien = chiPhiDuKien;
        this.phuongPhapBooking = phuongPhapBooking;
        this.thoiDiemHuy = thoiDiemHuy;
        this.phiHuy = phiHuy;
    }

    public Booking(String maBooking, String maKH, String maNV, Timestamp ngayDat, String trangThai, double chiPhiDuKien,
            String phuongPhapBooking, Timestamp thoiDiemHuy, Double phiHuy) {
        this(maBooking, maKH, null, maNV, ngayDat, trangThai, chiPhiDuKien, phuongPhapBooking, thoiDiemHuy, phiHuy);
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public String getMaKH() {
        return maKH;
    }

    public void setMaKH(String maKH) {
        this.maKH = maKH;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }

    public Timestamp getNgayDat() {
        return ngayDat;
    }

    public void setNgayDat(Timestamp ngayDat) {
        this.ngayDat = ngayDat;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public double getChiPhiDuKien() {
        return chiPhiDuKien;
    }

    public void setChiPhiDuKien(double chiPhiDuKien) {
        this.chiPhiDuKien = chiPhiDuKien;
    }

    public String getPhuongPhapBooking() {
        return phuongPhapBooking;
    }

    public void setPhuongPhapBooking(String phuongPhapBooking) {
        this.phuongPhapBooking = phuongPhapBooking;
    }

    public Timestamp getThoiDiemHuy() {
        return thoiDiemHuy;
    }

    public void setThoiDiemHuy(Timestamp thoiDiemHuy) {
        this.thoiDiemHuy = thoiDiemHuy;
    }

    public Double getPhiHuy() {
        return phiHuy;
    }

    public void setPhiHuy(Double phiHuy) {
        this.phiHuy = phiHuy;
    }

    public String getMaTaiKhoan() {
        return maTaiKhoan;
    }

    public void setMaTaiKhoan(String maTaiKhoan) {
        this.maTaiKhoan = maTaiKhoan;
    }
}
