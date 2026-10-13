package com.mycompany.hotelmanagersystem.auth.model;

import java.io.Serializable;

public class Account implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maTaiKhoan;
    private String matKhau;
    private String role; // 'Customer', 'Receptionist', 'Housekeeper', 'Manager'
    private String trangThai; // 'Active', 'Locked'
    private String hoTenTaiKhoan;
    private String email;

    public Account() {
    }

    public Account(String maTaiKhoan, String matKhau, String role, String trangThai, String hoTenTaiKhoan, String email) {
        this.maTaiKhoan = maTaiKhoan;
        this.matKhau = matKhau;
        this.role = role;
        this.trangThai = trangThai;
        this.hoTenTaiKhoan = hoTenTaiKhoan;
        this.email = email;
    }

    // Constructor cũ tương thích ngược (nếu cần)
    public Account(String maTaiKhoan, String email, String matKhau, String role, String trangThai) {
        this.maTaiKhoan = maTaiKhoan;
        this.email = email;
        this.matKhau = matKhau;
        this.role = role;
        this.trangThai = trangThai;
    }

    public String getMaTaiKhoan() {
        return maTaiKhoan;
    }

    public void setMaTaiKhoan(String maTaiKhoan) {
        this.maTaiKhoan = maTaiKhoan;
    }

    public String getMatKhau() {
        return matKhau;
    }

    public void setMatKhau(String matKhau) {
        this.matKhau = matKhau;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getHoTenTaiKhoan() {
        return hoTenTaiKhoan;
    }

    public void setHoTenTaiKhoan(String hoTenTaiKhoan) {
        this.hoTenTaiKhoan = hoTenTaiKhoan;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // Alias tương thích ngược cho TenDangNhap (Email đóng vai trò tên đăng nhập)
    public String getTenDangNhap() {
        return email;
    }

    public void setTenDangNhap(String tenDangNhap) {
        this.email = tenDangNhap;
    }

    public String getHoTen() {
        return hoTenTaiKhoan;
    }

    public void setHoTen(String hoTen) {
        this.hoTenTaiKhoan = hoTen;
    }
}
