package com.mycompany.hotelmanagersystem.hotelservice.dto;

/**
 * DTO đóng gói tham số gọi thêm dịch vụ phòng cho khách lưu trú.
 */
public class ServiceOrderRequestDTO {

    private String maBooking;
    private String maPhong;
    private String maDichVu;
    private int soLuong;
    private String maNV;
    private String ghiChu;

    public ServiceOrderRequestDTO() {
    }

    public ServiceOrderRequestDTO(String maBooking, String maPhong, String maDichVu, int soLuong, String maNV, String ghiChu) {
        this.maBooking = maBooking;
        this.maPhong = maPhong;
        this.maDichVu = maDichVu;
        this.soLuong = soLuong;
        this.maNV = maNV;
        this.ghiChu = ghiChu;
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getMaDichVu() {
        return maDichVu;
    }

    public void setMaDichVu(String maDichVu) {
        this.maDichVu = maDichVu;
    }

    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }
}
