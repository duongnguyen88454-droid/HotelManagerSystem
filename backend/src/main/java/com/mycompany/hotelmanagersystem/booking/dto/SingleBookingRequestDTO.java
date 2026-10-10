package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.Map;

/**
 * DTO chứa thông tin yêu cầu tạo đơn đặt phòng đơn (1 phòng) kèm dịch vụ.
 * Tuân thủ QT 1.4 trong ARCHITECTURE_RULES.md (gom tham số vào DTO).
 */
public class SingleBookingRequestDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maKH;
    private String maTaiKhoan;
    private String maPhong;
    private LocalDate checkIn;
    private LocalDate checkOut;
    private double donGiaPhong;
    private double tongChiPhi;
    private Map<String, Integer> selectedServices;
    private String ghiChu;

    public SingleBookingRequestDTO() {
    }

    public SingleBookingRequestDTO(String maKH, String maTaiKhoan, String maPhong, LocalDate checkIn,
                                  LocalDate checkOut, Map<String, Integer> selectedServices, String ghiChu) {
        this(maKH, maTaiKhoan, maPhong, checkIn, checkOut, 0.0, 0.0, selectedServices, ghiChu);
    }

    public SingleBookingRequestDTO(String maKH, String maTaiKhoan, String maPhong, LocalDate checkIn,
                                  LocalDate checkOut, double donGiaPhong, double tongChiPhi,
                                  Map<String, Integer> selectedServices, String ghiChu) {
        this.maKH = maKH;
        this.maTaiKhoan = maTaiKhoan;
        this.maPhong = maPhong;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.donGiaPhong = donGiaPhong;
        this.tongChiPhi = tongChiPhi;
        this.selectedServices = selectedServices;
        this.ghiChu = ghiChu;
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

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public LocalDate getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(LocalDate checkIn) {
        this.checkIn = checkIn;
    }

    public LocalDate getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(LocalDate checkOut) {
        this.checkOut = checkOut;
    }

    public double getDonGiaPhong() {
        return donGiaPhong;
    }

    public void setDonGiaPhong(double donGiaPhong) {
        this.donGiaPhong = donGiaPhong;
    }

    public double getTongChiPhi() {
        return tongChiPhi;
    }

    public void setTongChiPhi(double tongChiPhi) {
        this.tongChiPhi = tongChiPhi;
    }

    public Map<String, Integer> getSelectedServices() {
        return selectedServices;
    }

    public void setSelectedServices(Map<String, Integer> selectedServices) {
        this.selectedServices = selectedServices;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }
}
