package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;

/**
 * DTO đại diện cho một đơn đặt phòng cần thanh toán trên Dashboard Thu Ngân.
 */
public class ActiveBookingItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBooking;
    private String tenKhach;
    private String soDT;
    private String cccd;
    private Double chiPhiDuKien;
    private String trangThai;
    private int tongSoPhong;
    private String danhSachPhong;
    private int soPhongChuaTra;

    private String maHoaDon;
    private String trangThaiHoaDon;
    private Double tongTien;
    private Double daThanhToan;
    private Double soTienConNo;

    public ActiveBookingItemDTO() {
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public String getTenKhach() {
        return tenKhach;
    }

    public void setTenKhach(String tenKhach) {
        this.tenKhach = tenKhach;
    }

    public String getSoDT() {
        return soDT;
    }

    public void setSoDT(String soDT) {
        this.soDT = soDT;
    }

    public String getCccd() {
        return cccd;
    }

    public void setCccd(String cccd) {
        this.cccd = cccd;
    }

    public Double getChiPhiDuKien() {
        return chiPhiDuKien;
    }

    public void setChiPhiDuKien(Double chiPhiDuKien) {
        this.chiPhiDuKien = chiPhiDuKien;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public int getTongSoPhong() {
        return tongSoPhong;
    }

    public void setTongSoPhong(int tongSoPhong) {
        this.tongSoPhong = tongSoPhong;
    }

    public String getDanhSachPhong() {
        return danhSachPhong;
    }

    public void setDanhSachPhong(String danhSachPhong) {
        this.danhSachPhong = danhSachPhong;
    }

    public int getSoPhongChuaTra() {
        return soPhongChuaTra;
    }

    public void setSoPhongChuaTra(int soPhongChuaTra) {
        this.soPhongChuaTra = soPhongChuaTra;
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

    public Double getTongTien() {
        return tongTien;
    }

    public void setTongTien(Double tongTien) {
        this.tongTien = tongTien;
    }

    public Double getDaThanhToan() {
        return daThanhToan;
    }

    public void setDaThanhToan(Double daThanhToan) {
        this.daThanhToan = daThanhToan;
    }

    public Double getSoTienConNo() {
        return soTienConNo;
    }

    public void setSoTienConNo(Double soTienConNo) {
        this.soTienConNo = soTienConNo;
    }
}
