package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.math.BigDecimal;

public class MonthlyRevenueDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int nam;
    private int thang;
    private int soLuotGiaoDich;
    private int soHoaDonDaThanhToan;
    private BigDecimal tongDoanhThuThucThu;

    public MonthlyRevenueDTO() {
    }

    public MonthlyRevenueDTO(int nam, int thang, int soLuotGiaoDich,
                             int soHoaDonDaThanhToan, BigDecimal tongDoanhThuThucThu) {
        this.nam = nam;
        this.thang = thang;
        this.soLuotGiaoDich = soLuotGiaoDich;
        this.soHoaDonDaThanhToan = soHoaDonDaThanhToan;
        this.tongDoanhThuThucThu = tongDoanhThuThucThu;
    }

    public int getNam() {
        return nam;
    }

    public void setNam(int nam) {
        this.nam = nam;
    }

    public int getThang() {
        return thang;
    }

    public void setThang(int thang) {
        this.thang = thang;
    }

    public int getSoLuotGiaoDich() {
        return soLuotGiaoDich;
    }

    public void setSoLuotGiaoDich(int soLuotGiaoDich) {
        this.soLuotGiaoDich = soLuotGiaoDich;
    }

    public int getSoHoaDonDaThanhToan() {
        return soHoaDonDaThanhToan;
    }

    public void setSoHoaDonDaThanhToan(int soHoaDonDaThanhToan) {
        this.soHoaDonDaThanhToan = soHoaDonDaThanhToan;
    }

    public BigDecimal getTongDoanhThuThucThu() {
        return tongDoanhThuThucThu;
    }

    public void setTongDoanhThuThucThu(BigDecimal tongDoanhThuThucThu) {
        this.tongDoanhThuThucThu = tongDoanhThuThucThu;
    }
}
