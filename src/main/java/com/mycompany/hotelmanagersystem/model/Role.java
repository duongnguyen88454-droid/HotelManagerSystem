package com.mycompany.hotelmanagersystem.model;

import java.io.Serializable;

public class Role implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maVaiTro;
    private String tenVaiTro;

    public Role() {
    }

    public Role(String maVaiTro, String tenVaiTro) {
        this.maVaiTro = maVaiTro;
        this.tenVaiTro = tenVaiTro;
    }

    public String getMaVaiTro() {
        return maVaiTro;
    }

    public void setMaVaiTro(String maVaiTro) {
        this.maVaiTro = maVaiTro;
    }

    public String getTenVaiTro() {
        return tenVaiTro;
    }

    public void setTenVaiTro(String tenVaiTro) {
        this.tenVaiTro = tenVaiTro;
    }
}
