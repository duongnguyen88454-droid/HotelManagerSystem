package com.mycompany.hotelmanagersystem.model;

import java.io.Serializable;

/**
 * Entity ánh xạ bảng DICHVU
 */
public class ServiceItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maDichVu;
    private String tenDichVu;
    private double donGia;
    private String trangThai; // 'ApDung', 'NgungApDung'

    public ServiceItem() {
    }

    public ServiceItem(String maDichVu, String tenDichVu, double donGia, String trangThai) {
        this.maDichVu = maDichVu;
        this.tenDichVu = tenDichVu;
        this.donGia = donGia;
        this.trangThai = trangThai;
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

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }
}
