package com.mycompany.hotelmanagersystem.booking.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng BOOKING_PHONG
 */
public class BookingRoom implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBooking;
    private String maPhong;
    private double donGiaPhong;
    private Date ngayNhanDuKien;
    private Date ngayTraDuKien;
    private Timestamp ngayCheckInThucTe;
    private Timestamp ngayCheckOutThucTe;

    public BookingRoom() {
    }

    public BookingRoom(String maBooking, String maPhong, double donGiaPhong, Date ngayNhanDuKien, Date ngayTraDuKien, Timestamp ngayCheckInThucTe, Timestamp ngayCheckOutThucTe) {
        this.maBooking = maBooking;
        this.maPhong = maPhong;
        this.donGiaPhong = donGiaPhong;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        this.ngayCheckInThucTe = ngayCheckInThucTe;
        this.ngayCheckOutThucTe = ngayCheckOutThucTe;
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

    public double getDonGiaPhong() {
        return donGiaPhong;
    }

    public void setDonGiaPhong(double donGiaPhong) {
        this.donGiaPhong = donGiaPhong;
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
}
