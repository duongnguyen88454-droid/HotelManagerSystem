package com.mycompany.hotelmanagersystem.room.dto;

import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class BookingBarDTO {
    private String maBooking;
    private String maPhong;
    private String tenKhachHang;
    private String soDienThoai;
    private String soCccd;
    private Date ngayNhanDuKien;
    private Date ngayTraDuKien;
    private Timestamp ngayCheckInThucTe;
    private Timestamp ngayCheckOutThucTe;
    private String trangThaiBooking; // DaXacNhan, DaCheckIn, DaTraPhong
    private int startCol; // 1-7
    private int colSpan;  // Số cột chiếm dụng
    private String cssClass; // bar-confirmed, bar-occupied

    public BookingBarDTO() {}

    public BookingBarDTO(String maBooking, String maPhong, String tenKhachHang, String soDienThoai,
                         String soCccd, Date ngayNhanDuKien, Date ngayTraDuKien, String trangThaiBooking,
                         int startCol, int colSpan, String cssClass) {
        this.maBooking = maBooking;
        this.maPhong = maPhong;
        this.tenKhachHang = tenKhachHang;
        this.soDienThoai = soDienThoai;
        this.soCccd = soCccd;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        this.trangThaiBooking = trangThaiBooking;
        this.startCol = startCol;
        this.colSpan = colSpan;
        this.cssClass = cssClass;
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

    public String getTenKhachHang() {
        return tenKhachHang;
    }

    public void setTenKhachHang(String tenKhachHang) {
        this.tenKhachHang = tenKhachHang;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getSoCccd() {
        return soCccd;
    }

    public void setSoCccd(String soCccd) {
        this.soCccd = soCccd;
    }

    public Date getNgayNhanDuKien() {
        return ngayNhanDuKien;
    }

    public void setNgayNhanDuKien(Date ngayNhanDuKien) {
        this.ngayNhanDuKien = ngayNhanDuKien;
    }

    public Date getNgayTraDuKien() {
        return ngayTraDuKien;
    }

    public void setNgayTraDuKien(Date ngayTraDuKien) {
        this.ngayTraDuKien = ngayTraDuKien;
    }

    public String getTrangThaiBooking() {
        return trangThaiBooking;
    }

    public void setTrangThaiBooking(String trangThaiBooking) {
        this.trangThaiBooking = trangThaiBooking;
    }

    public int getStartCol() {
        return startCol;
    }

    public void setStartCol(int startCol) {
        this.startCol = startCol;
    }

    public int getColSpan() {
        return colSpan;
    }

    public void setColSpan(int colSpan) {
        this.colSpan = colSpan;
    }

    public String getCssClass() {
        return cssClass;
    }

    public void setCssClass(String cssClass) {
        this.cssClass = cssClass;
    }

    public Timestamp getNgayCheckInThucTe() {
        return ngayCheckInThucTe;
    }

    public void setNgayCheckInThucTe(Timestamp ngayCheckInThucTe) {
        this.ngayCheckInThucTe = ngayCheckInThucTe;
    }

    public Timestamp getNgayCheckOutThucTe() {
        return ngayCheckOutThucTe;
    }

    public void setNgayCheckOutThucTe(Timestamp ngayCheckOutThucTe) {
        this.ngayCheckOutThucTe = ngayCheckOutThucTe;
    }

    public String getFormattedNgayCheckInThucTe() {
        if (ngayCheckInThucTe == null) {
            return "___";
        }
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(ngayCheckInThucTe);
    }

    public String getFormattedNgayCheckOutThucTe() {
        if (ngayCheckOutThucTe == null) {
            return "___";
        }
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(ngayCheckOutThucTe);
    }
}
