package com.mycompany.hotelmanagersystem.employee.model;

import java.io.Serializable;
import java.util.Date;

public class Employee implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maNV;
    private String maTaiKhoan;
    private String hoTen;
    private String email;
    private String soDienThoai;
    private Date ngayVaoLam;
    private Date ngayNghiLam;
    private String trangThaiLamViec; // 'DangLam', 'NghiViec'

    public Employee() {
    }

    public Employee(String maNV, String maTaiKhoan, String hoTen, String email, String soDienThoai, Date ngayVaoLam, Date ngayNghiLam, String trangThaiLamViec) {
        this.maNV = maNV;
        this.maTaiKhoan = maTaiKhoan;
        this.hoTen = hoTen;
        this.email = email;
        this.soDienThoai = soDienThoai;
        this.ngayVaoLam = ngayVaoLam;
        this.ngayNghiLam = ngayNghiLam;
        this.trangThaiLamViec = trangThaiLamViec;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
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

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public Date getNgayVaoLam() {
        return ngayVaoLam;
    }

    public void setNgayVaoLam(Date ngayVaoLam) {
        this.ngayVaoLam = ngayVaoLam;
    }

    public Date getNgayNghiLam() {
        return ngayNghiLam;
    }

    public void setNgayNghiLam(Date ngayNghiLam) {
        this.ngayNghiLam = ngayNghiLam;
    }

    public String getTrangThaiLamViec() {
        return trangThaiLamViec;
    }

    public void setTrangThaiLamViec(String trangThaiLamViec) {
        this.trangThaiLamViec = trangThaiLamViec;
    }
}
