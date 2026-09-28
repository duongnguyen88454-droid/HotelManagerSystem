package com.mycompany.hotelmanagersystem.model;

import java.io.Serializable;

public class Customer implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maKH;
    private String maTaiKhoan;
    private String hoTen;
    private String email;
    private String soDT;
    private String cccd;

    public Customer() {
    }

    public Customer(String maKH, String maTaiKhoan, String hoTen, String email, String soDT, String cccd) {
        this.maKH = maKH;
        this.maTaiKhoan = maTaiKhoan;
        this.hoTen = hoTen;
        this.email = email;
        this.soDT = soDT;
        this.cccd = cccd;
    }

    public String getMaKH() {
        return maKH;
    }

    public void setMaKH(String maKH) {
        this.maKH = maKH;
    }

    public String getMaTaiKhoan() {
        return maTaiKhoan;
    }

    public void setMaTaiKhoan(String maTaiKhoan) {
        this.maTaiKhoan = maTaiKhoan;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSoDT() {
        return soDT;
    }

    public void setSoDT(String soDT) {
        this.soDT = soDT;
    }

    public String getCccd() {
        return cccd;
    }

    public void setCccd(String cccd) {
        this.cccd = cccd;
    }
}
