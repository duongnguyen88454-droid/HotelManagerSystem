package com.mycompany.hotelmanagersystem.auth.dto;

import java.io.Serializable;

public class UserSessionDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maTaiKhoan;
    private String email;
    private String soDT;
    private String role; // 'Customer', 'Receptionist', 'Housekeeper', 'Manager'
    private String hoTen; // Họ tên lấy từ NHANVIEN hoặc UserName của Account
    private String maDinhDanh; // Mã NV (nếu là nhân viên) hoặc Mã KH (khi liên kết)
    private String trangThai; // 'Active', 'Locked'

    public UserSessionDTO() {
    }

    public UserSessionDTO(String maTaiKhoan, String email, String soDT, String role,
            String hoTen, String maDinhDanh, String trangThai) {
        this.maTaiKhoan = maTaiKhoan;
        this.email = email;
        this.soDT = soDT;
        this.role = role;
        this.hoTen = hoTen;
        this.maDinhDanh = maDinhDanh;
        this.trangThai = trangThai;
    }

    // Helper methods kiểm tra vai trò nhanh trong JSP EL hoặc Filter
    public boolean isCustomer() {
        return "Customer".equalsIgnoreCase(this.role);
    }

    public boolean isReceptionist() {
        return "Receptionist".equalsIgnoreCase(this.role);
    }

    public boolean isHousekeeper() {
        return "Housekeeper".equalsIgnoreCase(this.role);
    }

    public boolean isManager() {
        return "Manager".equalsIgnoreCase(this.role);
    }

    // Getters and Setters
    public String getMaTaiKhoan() {
        return maTaiKhoan;
    }

    public void setMaTaiKhoan(String maTaiKhoan) {
        this.maTaiKhoan = maTaiKhoan;
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

    public String getSoDienThoai() {
        return soDT;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDT = soDienThoai;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getHoTen() {
        return hoTen;
    }

    public void setHoTen(String hoTen) {
        this.hoTen = hoTen;
    }

    public String getMaDinhDanh() {
        return maDinhDanh;
    }

    public void setMaDinhDanh(String maDinhDanh) {
        this.maDinhDanh = maDinhDanh;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public String getHoTenTaiKhoan() {
        return hoTen;
    }

    public void setHoTenTaiKhoan(String hoTenTaiKhoan) {
        this.hoTen = hoTenTaiKhoan;
    }
}
