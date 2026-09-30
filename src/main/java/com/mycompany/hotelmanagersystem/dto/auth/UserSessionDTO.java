package com.mycompany.hotelmanagersystem.dto.auth;

import java.io.Serializable;

public class UserSessionDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maTaiKhoan;
    private String email;
    private String soDT;
    private String maVaiTro; // 'VT01', 'VT02', 'VT03', 'VT04'
    private String tenVaiTro; // 'Customer', 'Receptionist', 'HouseKeeper', 'Manager'
    private String hoTen; // Họ tên lấy từ KHACHHANG hoặc NHANVIEN
    private String maDinhDanh; // Mã KH (nếu là khách) hoặc Mã NV (nếu là nhân viên)
    private String trangThai; // 'Active', 'Locked'

    public UserSessionDTO() {
    }

    public UserSessionDTO(String maTaiKhoan, String email, String soDT, String maVaiTro,
            String tenVaiTro, String hoTen, String maDinhDanh, String trangThai) {
        this.maTaiKhoan = maTaiKhoan;
        this.email = email;
        this.soDT = soDT;
        this.maVaiTro = maVaiTro;
        this.tenVaiTro = tenVaiTro;
        this.hoTen = hoTen;
        this.maDinhDanh = maDinhDanh;
        this.trangThai = trangThai;
    }

    // Helper methods kiểm tra vai trò nhanh trong JSP EL hoặc Filter
    public boolean isCustomer() {
        return "VT01".equalsIgnoreCase(this.maVaiTro);
    }

    public boolean isReceptionist() {
        return "VT02".equalsIgnoreCase(this.maVaiTro);
    }

    public boolean isHousekeeper() {
        return "VT03".equalsIgnoreCase(this.maVaiTro);
    }

    public boolean isManager() {
        return "VT04".equalsIgnoreCase(this.maVaiTro);
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
