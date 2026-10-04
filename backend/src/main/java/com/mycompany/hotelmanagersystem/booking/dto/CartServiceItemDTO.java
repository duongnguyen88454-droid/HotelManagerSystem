package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;

public class CartServiceItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maDichVu;
    private String tenDichVu;
    private double donGia;
    private int soLuong;

    public CartServiceItemDTO() {
    }

    public CartServiceItemDTO(String maDichVu, String tenDichVu, double donGia, int soLuong) {
        this.maDichVu = maDichVu;
        this.tenDichVu = tenDichVu;
        this.donGia = donGia;
        this.soLuong = Math.max(1, soLuong);
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
        this.soLuong = Math.max(1, soLuong);
    }

    public double getThanhTien() {
        return donGia * soLuong;
    }
}
