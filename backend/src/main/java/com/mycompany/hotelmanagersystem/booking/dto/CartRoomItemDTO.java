package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

public class CartRoomItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maPhong;
    private String soPhong;
    private String maLoaiPhong;
    private String tenLoaiPhong;
    private double donGiaPhong;

    private String ngayNhan; // yyyy-MM-dd
    private String ngayTra;  // yyyy-MM-dd
    private long soDem;
    private double tienPhong;

    private List<CartServiceItemDTO> selectedServices = new ArrayList<>();

    public CartRoomItemDTO() {
    }

    public CartRoomItemDTO(String maPhong, String soPhong, String maLoaiPhong, String tenLoaiPhong,
                           double donGiaPhong, String ngayNhan, String ngayTra) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.maLoaiPhong = maLoaiPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.donGiaPhong = donGiaPhong;
        this.ngayNhan = ngayNhan;
        this.ngayTra = ngayTra;
        recalculate();
    }

    public void recalculate() {
        if (ngayNhan != null && ngayTra != null && !ngayNhan.isEmpty() && !ngayTra.isEmpty()) {
            try {
                LocalDate dIn = LocalDate.parse(ngayNhan);
                LocalDate dOut = LocalDate.parse(ngayTra);
                long diff = ChronoUnit.DAYS.between(dIn, dOut);
                this.soDem = Math.max(1, diff);
            } catch (Exception ex) {
                this.soDem = 1;
            }
        } else {
            this.soDem = 1;
        }
        this.tienPhong = this.donGiaPhong * this.soDem;
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getSoPhong() {
        return soPhong;
    }

    public void setSoPhong(String soPhong) {
        this.soPhong = soPhong;
    }

    public String getMaLoaiPhong() {
        return maLoaiPhong;
    }

    public void setMaLoaiPhong(String maLoaiPhong) {
        this.maLoaiPhong = maLoaiPhong;
    }

    public String getTenLoaiPhong() {
        return tenLoaiPhong;
    }

    public void setTenLoaiPhong(String tenLoaiPhong) {
        this.tenLoaiPhong = tenLoaiPhong;
    }

    public double getDonGiaPhong() {
        return donGiaPhong;
    }

    public void setDonGiaPhong(double donGiaPhong) {
        this.donGiaPhong = donGiaPhong;
        recalculate();
    }

    public String getNgayNhan() {
        return ngayNhan;
    }

    public void setNgayNhan(String ngayNhan) {
        this.ngayNhan = ngayNhan;
        recalculate();
    }

    public String getNgayTra() {
        return ngayTra;
    }

    public void setNgayTra(String ngayTra) {
        this.ngayTra = ngayTra;
        recalculate();
    }

    public long getSoDem() {
        return soDem;
    }

    public double getTienPhong() {
        return tienPhong;
    }

    public List<CartServiceItemDTO> getSelectedServices() {
        if (selectedServices == null) {
            selectedServices = new ArrayList<>();
        }
        return selectedServices;
    }

    public void setSelectedServices(List<CartServiceItemDTO> selectedServices) {
        this.selectedServices = selectedServices != null ? selectedServices : new ArrayList<>();
    }

    public double getTongTienDichVu() {
        if (selectedServices == null || selectedServices.isEmpty()) {
            return 0.0;
        }
        double sum = 0.0;
        for (CartServiceItemDTO svc : selectedServices) {
            sum += svc.getThanhTien();
        }
        return sum;
    }

    public double getTongTienPhongVaDichVu() {
        return getTienPhong() + getTongTienDichVu();
    }

    // Aliases for JSP EL & JSON compatibility
    public String getCheckIn() {
        return ngayNhan;
    }

    public void setCheckIn(String checkIn) {
        this.ngayNhan = checkIn;
        recalculate();
    }

    public String getCheckOut() {
        return ngayTra;
    }

    public void setCheckOut(String checkOut) {
        this.ngayTra = checkOut;
        recalculate();
    }

    public String getRoomId() {
        return maPhong;
    }

    public void setRoomId(String roomId) {
        this.maPhong = roomId;
    }

    public double getRoomPrice() {
        return getTienPhong();
    }

    public double getServiceTotal() {
        return getTongTienDichVu();
    }

    public double getRoomTotal() {
        return getTongTienPhongVaDichVu();
    }

    public double getTotalPrice() {
        return getTongTienPhongVaDichVu();
    }
}
