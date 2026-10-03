package com.mycompany.hotelmanagersystem.housekeeper.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * DTO dữ liệu nhiệm vụ dọn phòng phục vụ phân hệ Buồng phòng (Phase 5).
 */
public class HousekeeperTaskDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maNhiemVu;
    private String maPhong;
    private String soPhong;
    private String tenLoaiPhong;
    private String trangThaiPhong;
    private String trangThaiNhiemVu;
    private String maNV;
    private String tenNV;
    private Timestamp thoiGianNhan;
    private Timestamp thoiGianBatDau;
    private Timestamp thoiGianKetThuc;
    private String ketQua;

    public HousekeeperTaskDTO() {
    }

    public String getMaNhiemVu() {
        return maNhiemVu;
    }

    public void setMaNhiemVu(String maNhiemVu) {
        this.maNhiemVu = maNhiemVu;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
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

    public String getTrangThaiPhong() {
        return trangThaiPhong;
    }

    public void setTrangThaiPhong(String trangThaiPhong) {
        this.trangThaiPhong = trangThaiPhong;
    }

    public String getTrangThaiNhiemVu() {
        return trangThaiNhiemVu;
    }

    public void setTrangThaiNhiemVu(String trangThaiNhiemVu) {
        this.trangThaiNhiemVu = trangThaiNhiemVu;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }

    public String getTenNV() {
        return tenNV;
    }

    public void setTenNV(String tenNV) {
        this.tenNV = tenNV;
    }

    public Timestamp getThoiGianNhan() {
        return thoiGianNhan;
    }

    public void setThoiGianNhan(Timestamp thoiGianNhan) {
        this.thoiGianNhan = thoiGianNhan;
    }

    public Timestamp getThoiGianBatDau() {
        return thoiGianBatDau;
    }

    public void setThoiGianBatDau(Timestamp thoiGianBatDau) {
        this.thoiGianBatDau = thoiGianBatDau;
    }

    public Timestamp getThoiGianKetThuc() {
        return thoiGianKetThuc;
    }

    public void setThoiGianKetThuc(Timestamp thoiGianKetThuc) {
        this.thoiGianKetThuc = thoiGianKetThuc;
    }

    public String getKetQua() {
        return ketQua;
    }

    public void setKetQua(String ketQua) {
        this.ketQua = ketQua;
    }
}
