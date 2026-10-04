package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.time.LocalDateTime;

public class DamagedRoomItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBaoCao;
    private String maPhong;
    private String soPhong;
    private String tenLoaiPhong;
    private LocalDateTime ngayPhatHien;
    private String tenLoaiHuHai;
    private String moTaChiTiet;
    private String trangThaiBaoCao;
    private String nhanVienPhatHien;

    public DamagedRoomItemDTO() {
    }

    public DamagedRoomItemDTO(String maBaoCao, String maPhong, String soPhong,
                              String tenLoaiPhong, LocalDateTime ngayPhatHien,
                              String tenLoaiHuHai, String moTaChiTiet,
                              String trangThaiBaoCao, String nhanVienPhatHien) {
        this.maBaoCao = maBaoCao;
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.ngayPhatHien = ngayPhatHien;
        this.tenLoaiHuHai = tenLoaiHuHai;
        this.moTaChiTiet = moTaChiTiet;
        this.trangThaiBaoCao = trangThaiBaoCao;
        this.nhanVienPhatHien = nhanVienPhatHien;
    }

    public String getMaBaoCao() {
        return maBaoCao;
    }

    public void setMaBaoCao(String maBaoCao) {
        this.maBaoCao = maBaoCao;
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

    public LocalDateTime getNgayPhatHien() {
        return ngayPhatHien;
    }

    public void setNgayPhatHien(LocalDateTime ngayPhatHien) {
        this.ngayPhatHien = ngayPhatHien;
    }

    public String getTenLoaiHuHai() {
        return tenLoaiHuHai;
    }

    public void setTenLoaiHuHai(String tenLoaiHuHai) {
        this.tenLoaiHuHai = tenLoaiHuHai;
    }

    public String getMoTaChiTiet() {
        return moTaChiTiet;
    }

    public void setMoTaChiTiet(String moTaChiTiet) {
        this.moTaChiTiet = moTaChiTiet;
    }

    public String getTrangThaiBaoCao() {
        return trangThaiBaoCao;
    }

    public void setTrangThaiBaoCao(String trangThaiBaoCao) {
        this.trangThaiBaoCao = trangThaiBaoCao;
    }

    public String getNhanVienPhatHien() {
        return nhanVienPhatHien;
    }

    public void setNhanVienPhatHien(String nhanVienPhatHien) {
        this.nhanVienPhatHien = nhanVienPhatHien;
    }
}
