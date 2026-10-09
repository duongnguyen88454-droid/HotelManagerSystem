package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.sql.Date;
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
    private Date checkIn;
    private Date checkOut;
    private double donGiaPhong;
    private double tongChiPhi;
    private Map<String, Integer> selectedServices;
    private String ghiChu;

    public SingleBookingRequestDTO() {
    }

    public SingleBookingRequestDTO(String maKH, String maTaiKhoan, String maPhong, Date checkIn,
                                  Date checkOut, double donGiaPhong, double tongChiPhi,
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

    public Date getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(Date checkIn) {
        this.checkIn = checkIn;
    }

    public Date getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(Date checkOut) {
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
