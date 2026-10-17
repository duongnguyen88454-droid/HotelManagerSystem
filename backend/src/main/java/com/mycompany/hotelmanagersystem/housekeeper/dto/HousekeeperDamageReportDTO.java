package com.mycompany.hotelmanagersystem.housekeeper.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * DTO dữ liệu lịch sử biên bản sự cố hư hại phục vụ buồng phòng.
 */
public class HousekeeperDamageReportDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBaoCao;
    private String maPhong;
    private String soPhong;
    private String tenLoaiPhong;
    private Timestamp thoiDiemPhatHien;
    private String tenLoaiHuHai;
    private String ghiChuChiTiet;
    private String trangThai;
    private String nguoiBaoCao;

    public HousekeeperDamageReportDTO() {
    }

    public HousekeeperDamageReportDTO(String maBaoCao, String maPhong, String soPhong, String tenLoaiPhong,
                                      Timestamp thoiDiemPhatHien, String tenLoaiHuHai, String ghiChuChiTiet,
                                      String trangThai, String nguoiBaoCao) {
        this.maBaoCao = maBaoCao;
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.thoiDiemPhatHien = thoiDiemPhatHien;
        this.tenLoaiHuHai = tenLoaiHuHai;
        this.ghiChuChiTiet = ghiChuChiTiet;
        this.trangThai = trangThai;
        this.nguoiBaoCao = nguoiBaoCao;
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

    public Timestamp getThoiDiemPhatHien() {
        return thoiDiemPhatHien;
    }

    public void setThoiDiemPhatHien(Timestamp thoiDiemPhatHien) {
        this.thoiDiemPhatHien = thoiDiemPhatHien;
    }

    public String getTenLoaiHuHai() {
        return tenLoaiHuHai;
    }

    public void setTenLoaiHuHai(String tenLoaiHuHai) {
        this.tenLoaiHuHai = tenLoaiHuHai;
    }

    public String getGhiChuChiTiet() {
        return ghiChuChiTiet;
    }

    public void setGhiChuChiTiet(String ghiChuChiTiet) {
        this.ghiChuChiTiet = ghiChuChiTiet;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getNguoiBaoCao() {
        return nguoiBaoCao;
    }

    public void setNguoiBaoCao(String nguoiBaoCao) {
        this.nguoiBaoCao = nguoiBaoCao;
    }
}
