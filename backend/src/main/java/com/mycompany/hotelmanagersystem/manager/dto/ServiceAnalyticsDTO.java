package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.math.BigDecimal;

public class ServiceAnalyticsDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maDichVu;
    private String tenDichVu;
    private BigDecimal donGiaHienTai;
    private int tongSoLuongSuDung;
    private BigDecimal tongDoanhThuDichVu;

    public ServiceAnalyticsDTO() {
    }

    public ServiceAnalyticsDTO(String maDichVu, String tenDichVu, BigDecimal donGiaHienTai,
                               int tongSoLuongSuDung, BigDecimal tongDoanhThuDichVu) {
        this.maDichVu = maDichVu;
        this.tenDichVu = tenDichVu;
        this.donGiaHienTai = donGiaHienTai;
        this.tongSoLuongSuDung = tongSoLuongSuDung;
        this.tongDoanhThuDichVu = tongDoanhThuDichVu;
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

    public BigDecimal getDonGiaHienTai() {
        return donGiaHienTai;
    }

    public void setDonGiaHienTai(BigDecimal donGiaHienTai) {
        this.donGiaHienTai = donGiaHienTai;
    }

    public int getTongSoLuongSuDung() {
        return tongSoLuongSuDung;
    }

    public void setTongSoLuongSuDung(int tongSoLuongSuDung) {
        this.tongSoLuongSuDung = tongSoLuongSuDung;
    }

    public BigDecimal getTongDoanhThuDichVu() {
        return tongDoanhThuDichVu;
    }

    public void setTongDoanhThuDichVu(BigDecimal tongDoanhThuDichVu) {
        this.tongDoanhThuDichVu = tongDoanhThuDichVu;
    }
}
