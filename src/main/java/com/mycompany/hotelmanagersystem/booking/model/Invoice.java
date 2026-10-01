package com.mycompany.hotelmanagersystem.booking.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Entity ánh xạ bảng HOADON
 */
public class Invoice implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maHoaDon;
    private String maBooking;
    private Timestamp ngayLap;
    private Double tongTienCuoiCung;
    private String maNV;
    private String trangThai; // 'ChuaThanhToan', 'MotPhan', 'DaThanhToanDu'

    public Invoice() {
    }

    public Invoice(String maHoaDon, String maBooking, Timestamp ngayLap, Double tongTienCuoiCung, String maNV, String trangThai) {
        this.maHoaDon = maHoaDon;
        this.maBooking = maBooking;
        this.ngayLap = ngayLap;
        this.tongTienCuoiCung = tongTienCuoiCung;
        this.maNV = maNV;
        this.trangThai = trangThai;
    }

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public Timestamp getNgayLap() {
        return ngayLap;
    }

    public void setNgayLap(Timestamp ngayLap) {
        this.ngayLap = ngayLap;
    }

    public Double getTongTienCuoiCung() {
        return tongTienCuoiCung;
    }

    public void setTongTienCuoiCung(Double tongTienCuoiCung) {
        this.tongTienCuoiCung = tongTienCuoiCung;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }
}
