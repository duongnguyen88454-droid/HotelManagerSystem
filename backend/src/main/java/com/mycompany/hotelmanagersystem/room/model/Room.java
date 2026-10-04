package com.mycompany.hotelmanagersystem.room.model;

import java.io.Serializable;

/**
 * Entity ánh xạ bảng PHONG
 */
public class Room implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maPhong;
    private String soPhong;
    private String maLoaiPhong;
    private String trangThai; // 'Available', 'Booked', 'Occupied', 'Dirty', 'Cleaning', 'Damaged'
    private String moTa;

    public Room() {
    }

    public Room(String maPhong, String soPhong, String maLoaiPhong, String trangThai, String moTa) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.maLoaiPhong = maLoaiPhong;
        this.trangThai = trangThai;
        this.moTa = moTa;
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

    public String getMaLoaiPhong() {
        return maLoaiPhong;
    }

    public void setMaLoaiPhong(String maLoaiPhong) {
        this.maLoaiPhong = maLoaiPhong;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }
}
