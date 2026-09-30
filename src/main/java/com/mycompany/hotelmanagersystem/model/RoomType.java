package com.mycompany.hotelmanagersystem.model;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Entity ánh xạ bảng LOAIPHONG
 */
public class RoomType implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maLoaiPhong;
    private String tenLoaiPhong;
    private double dienTich;
    private String loaiGiuong;
    private int soNguoiToiDa;
    private double giaPhong;
    private String trangThai; // 'ApDung', 'NgungApDung'

    public RoomType() {
    }

    public RoomType(String maLoaiPhong, String tenLoaiPhong, double dienTich, String loaiGiuong, int soNguoiToiDa, double giaPhong, String trangThai) {
        this.maLoaiPhong = maLoaiPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.dienTich = dienTich;
        this.loaiGiuong = loaiGiuong;
        this.soNguoiToiDa = soNguoiToiDa;
        this.giaPhong = giaPhong;
        this.trangThai = trangThai;
    }

    public String getMaLoaiPhong() {
        return maLoaiPhong;
    }

    public void setMaLoaiPhong(String maLoaiPhong) {
        this.maLoaiPhong = maLoaiPhong;
    }

    public String getTenLoaiPhong() {
        return tenLoaiPhong;
    }

    public void setTenLoaiPhong(String tenLoaiPhong) {
        this.tenLoaiPhong = tenLoaiPhong;
    }

    public double getDienTich() {
        return dienTich;
    }

    public void setDienTich(double dienTich) {
        this.dienTich = dienTich;
    }

    public String getLoaiGiuong() {
        return loaiGiuong;
    }

    public void setLoaiGiuong(String loaiGiuong) {
        this.loaiGiuong = loaiGiuong;
    }

    public int getSoNguoiToiDa() {
        return soNguoiToiDa;
    }

    public void setSoNguoiToiDa(int soNguoiToiDa) {
        this.soNguoiToiDa = soNguoiToiDa;
    }

    public double getGiaPhong() {
        return giaPhong;
    }

    public void setGiaPhong(double giaPhong) {
        this.giaPhong = giaPhong;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }
}
