package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * DTO chi tiết tiền phòng trong hóa đơn quyết toán.
 */
public class InvoiceRoomItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maPhong;
    private String tenLoaiPhong;
    private Double donGiaPhong;
    private Timestamp ngayNhanDuKien;
    private Timestamp ngayTraDuKien;
    private Timestamp ngayCheckInThucTe;
    private Timestamp ngayCheckOutThucTe;
    private int soDem;
    private Double thanhTien;

    public InvoiceRoomItemDTO() {
    }

    public InvoiceRoomItemDTO(String maPhong, String tenLoaiPhong, Double donGiaPhong,
                              Timestamp ngayNhanDuKien, Timestamp ngayTraDuKien,
                              Timestamp ngayCheckInThucTe, Timestamp ngayCheckOutThucTe,
                              int soDem, Double thanhTien) {
        this.maPhong = maPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.donGiaPhong = donGiaPhong;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        this.ngayCheckInThucTe = ngayCheckInThucTe;
        this.ngayCheckOutThucTe = ngayCheckOutThucTe;
        this.soDem = soDem;
        this.thanhTien = thanhTien;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getTenLoaiPhong() {
        return tenLoaiPhong;
    }

    public void setTenLoaiPhong(String tenLoaiPhong) {
        this.tenLoaiPhong = tenLoaiPhong;
    }

    public Double getDonGiaPhong() {
        return donGiaPhong;
    }

    public void setDonGiaPhong(Double donGiaPhong) {
        this.donGiaPhong = donGiaPhong;
    }

    public Timestamp getNgayNhanDuKien() {
        return ngayNhanDuKien;
    }

    public void setNgayNhanDuKien(Timestamp ngayNhanDuKien) {
        this.ngayNhanDuKien = ngayNhanDuKien;
    }

    public Timestamp getNgayTraDuKien() {
        return ngayTraDuKien;
    }

    public void setNgayTraDuKien(Timestamp ngayTraDuKien) {
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

    public int getSoDem() {
        return soDem;
    }

    public void setSoDem(int soDem) {
        this.soDem = soDem;
    }

    public Double getThanhTien() {
        return thanhTien;
    }

    public void setThanhTien(Double thanhTien) {
        this.thanhTien = thanhTien;
    }
}
