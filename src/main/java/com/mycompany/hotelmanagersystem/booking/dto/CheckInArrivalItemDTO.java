package com.mycompany.hotelmanagersystem.booking.dto;

import java.time.LocalDate;

/**
 * DTO đại diện cho một dòng đơn đặt phòng trong Bảng danh sách tổng quát tại Quầy Check-in.
 */
public class CheckInArrivalItemDTO {

    private String maBooking;
    private String tenKhachHang;
    private String soDienThoai;
    private String soCccd;
    private LocalDate ngayNhanDuKien;
    private LocalDate ngayTraDuKien;
    private int tongSoPhong;
    private int soPhongDaNhan;
    private String trangThaiTiepNhan;

    public CheckInArrivalItemDTO() {
    }

    public CheckInArrivalItemDTO(String maBooking, String tenKhachHang, String soDienThoai,
                                 String soCccd, LocalDate ngayNhanDuKien, LocalDate ngayTraDuKien,
                                 int tongSoPhong, int soPhongDaNhan) {
        this.maBooking = maBooking;
        this.tenKhachHang = tenKhachHang;
        this.soDienThoai = soDienThoai;
        this.soCccd = soCccd;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        this.tongSoPhong = tongSoPhong;
        this.soPhongDaNhan = soPhongDaNhan;
        this.trangThaiTiepNhan = calculateTrangThai(tongSoPhong, soPhongDaNhan);
    }

    private String calculateTrangThai(int total, int checkedIn) {
        if (checkedIn == 0) {
            return "Chờ nhận phòng";
        } else if (checkedIn < total) {
            return "Đang nhận dở (" + checkedIn + "/" + total + " phòng)";
        } else {
            return "Đã nhận đủ (" + total + "/" + total + " phòng)";
        }
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

    public LocalDate getNgayNhanDuKien() {
        return ngayNhanDuKien;
    }

    public void setNgayNhanDuKien(LocalDate ngayNhanDuKien) {
        this.ngayNhanDuKien = ngayNhanDuKien;
    }

    public LocalDate getNgayTraDuKien() {
        return ngayTraDuKien;
    }

    public void setNgayTraDuKien(LocalDate ngayTraDuKien) {
        this.ngayTraDuKien = ngayTraDuKien;
    }

    public int getTongSoPhong() {
        return tongSoPhong;
    }

    public void setTongSoPhong(int tongSoPhong) {
        this.tongSoPhong = tongSoPhong;
        this.trangThaiTiepNhan = calculateTrangThai(this.tongSoPhong, this.soPhongDaNhan);
    }

    public int getSoPhongDaNhan() {
        return soPhongDaNhan;
    }

    public void setSoPhongDaNhan(int soPhongDaNhan) {
        this.soPhongDaNhan = soPhongDaNhan;
        this.trangThaiTiepNhan = calculateTrangThai(this.tongSoPhong, this.soPhongDaNhan);
    }

    public String getTrangThaiTiepNhan() {
        return trangThaiTiepNhan;
    }

    public void setTrangThaiTiepNhan(String trangThaiTiepNhan) {
        this.trangThaiTiepNhan = trangThaiTiepNhan;
    }
}
