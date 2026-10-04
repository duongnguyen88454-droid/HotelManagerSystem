package com.mycompany.hotelmanagersystem.housekeeper.dto;

import java.io.Serializable;

/**
 * DTO đại diện cho loại hư hại thiết bị từ bảng LOAIHUHAI.
 */
public class DamageCategoryDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maLoaiHuHai;
    private String tenLoaiHuHai;
    private String moTa;

    public DamageCategoryDTO() {
    }

    public DamageCategoryDTO(String maLoaiHuHai, String tenLoaiHuHai, String moTa) {
        this.maLoaiHuHai = maLoaiHuHai;
        this.tenLoaiHuHai = tenLoaiHuHai;
        this.moTa = moTa;
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

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }
}
