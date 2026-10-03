package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO tổng hợp đầy đủ chi tiết của một hóa đơn thanh toán cho giao diện Cashier.
 */
public class InvoiceDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maHoaDon;
    private String maBooking;
    private Timestamp ngayLap;
    private Double tongTienCuoiCung;
    private Double daThanhToan;
    private Double conThieu;
    private String trangThaiHoaDon;
    private String maKH;
    private String tenKhachHang;
    private String soDT;
    private String cccd;
    private String tenNVLap;

    private List<InvoiceRoomItemDTO> rooms = new ArrayList<>();
    private List<InvoiceServiceItemDTO> services = new ArrayList<>();

    public InvoiceDetailDTO() {
    }

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public Timestamp getNgayLap() {
        return ngayLap;
    }

    public void setNgayLap(Timestamp ngayLap) {
        this.ngayLap = ngayLap;
    }

    public Double getTongTienCuoiCung() {
        return tongTienCuoiCung;
    }

    public void setTongTienCuoiCung(Double tongTienCuoiCung) {
        this.tongTienCuoiCung = tongTienCuoiCung;
    }

    public Double getDaThanhToan() {
        return daThanhToan;
    }

    public void setDaThanhToan(Double daThanhToan) {
        this.daThanhToan = daThanhToan;
    }

    public Double getConThieu() {
        return conThieu;
    }

    public void setConThieu(Double conThieu) {
        this.conThieu = conThieu;
    }

    public String getTrangThaiHoaDon() {
        return trangThaiHoaDon;
    }

    public void setTrangThaiHoaDon(String trangThaiHoaDon) {
        this.trangThaiHoaDon = trangThaiHoaDon;
    }

    public String getMaKH() {
        return maKH;
    }

    public void setMaKH(String maKH) {
        this.maKH = maKH;
    }

    public String getTenKhachHang() {
        return tenKhachHang;
    }

    public void setTenKhachHang(String tenKhachHang) {
        this.tenKhachHang = tenKhachHang;
    }

    public String getSoDT() {
        return soDT;
    }

    public void setSoDT(String soDT) {
        this.soDT = soDT;
    }

    public String getCccd() {
        return cccd;
    }

    public void setCccd(String cccd) {
        this.cccd = cccd;
    }

    public String getTenNVLap() {
        return tenNVLap;
    }

    public void setTenNVLap(String tenNVLap) {
        this.tenNVLap = tenNVLap;
    }

    public List<InvoiceRoomItemDTO> getRooms() {
        return rooms;
    }

    public void setRooms(List<InvoiceRoomItemDTO> rooms) {
        this.rooms = rooms;
    }

    public List<InvoiceServiceItemDTO> getServices() {
        return services;
    }

    public void setServices(List<InvoiceServiceItemDTO> services) {
        this.services = services;
    }
}
