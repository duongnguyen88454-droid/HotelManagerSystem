package com.mycompany.hotelmanagersystem.booking.dto;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO chứa toàn bộ dữ liệu chi tiết của 1 Đơn đặt phòng cho Modal Chi Tiết Check-in.
 */
public class CheckInDetailDTO {

    private String maBooking;
    private String tenKhachHang;
    private String soDienThoai;
    private String soCccd;
    private String email;
    private LocalDate ngayNhanDuKien;
    private LocalDate ngayTraDuKien;
    private long soDem;
    private List<CheckInRoomDetailDTO> danhSachPhong;

    public CheckInDetailDTO() {
        this.danhSachPhong = new ArrayList<>();
    }

    public CheckInDetailDTO(String maBooking, String tenKhachHang, String soDienThoai,
                            String soCccd, String email, LocalDate ngayNhanDuKien,
                            LocalDate ngayTraDuKien) {
        this.maBooking = maBooking;
        this.tenKhachHang = tenKhachHang;
        this.soDienThoai = soDienThoai;
        this.soCccd = soCccd;
        this.email = email;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        if (ngayNhanDuKien != null && ngayTraDuKien != null) {
            this.soDem = ChronoUnit.DAYS.between(ngayNhanDuKien, ngayTraDuKien);
        } else {
            this.soDem = 0;
        }
        this.danhSachPhong = new ArrayList<>();
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public String getTenKhachHang() {
        return tenKhachHang;
    }

    public void setTenKhachHang(String tenKhachHang) {
        this.tenKhachHang = tenKhachHang;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getSoCccd() {
        return soCccd;
    }

    public void setSoCccd(String soCccd) {
        this.soCccd = soCccd;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getNgayNhanDuKien() {
        return ngayNhanDuKien;
    }

    public void setNgayNhanDuKien(LocalDate ngayNhanDuKien) {
        this.ngayNhanDuKien = ngayNhanDuKien;
        if (this.ngayNhanDuKien != null && this.ngayTraDuKien != null) {
            this.soDem = ChronoUnit.DAYS.between(this.ngayNhanDuKien, this.ngayTraDuKien);
        }
    }

    public LocalDate getNgayTraDuKien() {
        return ngayTraDuKien;
    }

    public void setNgayTraDuKien(LocalDate ngayTraDuKien) {
        this.ngayTraDuKien = ngayTraDuKien;
        if (this.ngayNhanDuKien != null && this.ngayTraDuKien != null) {
            this.soDem = ChronoUnit.DAYS.between(this.ngayNhanDuKien, this.ngayTraDuKien);
        }
    }

    public long getSoDem() {
        return soDem;
    }

    public void setSoDem(long soDem) {
        this.soDem = soDem;
    }

    public List<CheckInRoomDetailDTO> getDanhSachPhong() {
        return danhSachPhong;
    }

    public void setDanhSachPhong(List<CheckInRoomDetailDTO> danhSachPhong) {
        this.danhSachPhong = danhSachPhong;
    }
}
