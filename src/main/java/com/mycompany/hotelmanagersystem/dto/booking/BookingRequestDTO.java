package com.mycompany.hotelmanagersystem.dto.booking;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

/**
 * DTO nhận dữ liệu yêu cầu đặt phòng gửi từ phía Client
 */
public class BookingRequestDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maKH;
    private String maPhong;
    private String ngayNhan;
    private String ngayTra;
    private String ghiChu;
    private Map<String, Integer> selectedServices = new HashMap<>();

    public BookingRequestDTO() {
    }

    public BookingRequestDTO(String maKH, String maPhong, String ngayNhan, String ngayTra, String ghiChu) {
        this.maKH = maKH;
        this.maPhong = maPhong;
        this.ngayNhan = ngayNhan;
        this.ngayTra = ngayTra;
        this.ghiChu = ghiChu;
    }

    public String getMaKH() {
        return maKH;
    }

    public void setMaKH(String maKH) {
        this.maKH = maKH;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getNgayNhan() {
        return ngayNhan;
    }

    public void setNgayNhan(String ngayNhan) {
        this.ngayNhan = ngayNhan;
    }

    public String getNgayTra() {
        return ngayTra;
    }

    public void setNgayTra(String ngayTra) {
        this.ngayTra = ngayTra;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public Map<String, Integer> getSelectedServices() {
        return selectedServices;
    }

    public void setSelectedServices(Map<String, Integer> selectedServices) {
        this.selectedServices = selectedServices;
    }
}
