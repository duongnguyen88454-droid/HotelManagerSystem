package com.mycompany.hotelmanagersystem.housekeeper.dto;

import java.io.Serializable;

/**
 * DTO đại diện cho một mục chi tiết hư hại trong biên bản.
 */
public class DamageDetailItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maLoaiHuHai;
    private String tenLoaiHuHai;
    private String moTaChiTiet;

    public DamageDetailItemDTO() {
    }

    public DamageDetailItemDTO(String maLoaiHuHai, String moTaChiTiet) {
        this.maLoaiHuHai = maLoaiHuHai;
        this.moTaChiTiet = moTaChiTiet;
    }

    public String getMaLoaiHuHai() {
        return maLoaiHuHai;
    }

    public void setMaLoaiHuHai(String maLoaiHuHai) {
        this.maLoaiHuHai = maLoaiHuHai;
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
}
