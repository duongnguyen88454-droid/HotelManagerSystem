package com.mycompany.hotelmanagersystem.dto.booking;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * DTO hiển thị dữ liệu lịch sử đặt phòng cho khách hàng
 */
public class CustomerBookingHistoryDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBooking;
    private String soPhong;
    private String tenLoaiPhong;
    private Timestamp ngayDat;
    private Date ngayNhanDuKien;
    private Date ngayTraDuKien;
    private int soDem;
    private double chiPhiDuKien;
    private String trangThaiBooking;
    private String maHoaDon;
    private String trangThaiHoaDon;
    private boolean coTheHuy;

    public CustomerBookingHistoryDTO() {
    }

    public CustomerBookingHistoryDTO(String maBooking, String soPhong, String tenLoaiPhong, 
                                     Timestamp ngayDat, Date ngayNhanDuKien, Date ngayTraDuKien, 
                                     int soDem, double chiPhiDuKien, String trangThaiBooking, 
                                     String maHoaDon, String trangThaiHoaDon) {
        this.maBooking = maBooking;
        this.soPhong = soPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.ngayDat = ngayDat;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        this.soDem = soDem;
        this.chiPhiDuKien = chiPhiDuKien;
        this.trangThaiBooking = trangThaiBooking;
        this.maHoaDon = maHoaDon;
        this.trangThaiHoaDon = trangThaiHoaDon;
        this.coTheHuy = "DaXacNhan".equalsIgnoreCase(trangThaiBooking);
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public String getSoPhong() {
        return soPhong;
    }

    public void setSoPhong(String soPhong) {
        this.soPhong = soPhong;
    }

    public String getTenLoaiPhong() {
        return tenLoaiPhong;
    }

    public void setTenLoaiPhong(String tenLoaiPhong) {
        this.tenLoaiPhong = tenLoaiPhong;
    }

    public Timestamp getNgayDat() {
        return ngayDat;
    }

    public void setNgayDat(Timestamp ngayDat) {
        this.ngayDat = ngayDat;
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

    public int getSoDem() {
        return soDem;
    }

    public void setSoDem(int soDem) {
        this.soDem = soDem;
    }

    public double getChiPhiDuKien() {
        return chiPhiDuKien;
    }

    public void setChiPhiDuKien(double chiPhiDuKien) {
        this.chiPhiDuKien = chiPhiDuKien;
    }

    public String getTrangThaiBooking() {
        return trangThaiBooking;
    }

    public void setTrangThaiBooking(String trangThaiBooking) {
        this.trangThaiBooking = trangThaiBooking;
        this.coTheHuy = "DaXacNhan".equalsIgnoreCase(trangThaiBooking);
    }

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public String getTrangThaiHoaDon() {
        return trangThaiHoaDon;
    }

    public void setTrangThaiHoaDon(String trangThaiHoaDon) {
        this.trangThaiHoaDon = trangThaiHoaDon;
    }

    public boolean isCoTheHuy() {
        return coTheHuy;
    }

    public void setCoTheHuy(boolean coTheHuy) {
        this.coTheHuy = coTheHuy;
    }
}
