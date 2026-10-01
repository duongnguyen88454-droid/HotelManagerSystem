package com.mycompany.hotelmanagersystem.dto.receptionist;

import java.util.ArrayList;
import java.util.List;

public class RoomTimelineDTO {
    private String maPhong;
    private String soPhong;
    private int soTang;
    private String maLoaiPhong;
    private String tenLoaiPhong;
    private double giaPhong;
    private String trangThaiPhong; // Available, Dirty, Cleaning, Damaged, Occupied, Booked
    private String moTa;
    private List<BookingBarDTO> bookingBars = new ArrayList<>();

    public RoomTimelineDTO() {}

    public RoomTimelineDTO(String maPhong, String soPhong, int soTang, String maLoaiPhong,
                           String tenLoaiPhong, double giaPhong, String trangThaiPhong, String moTa) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.soTang = soTang;
        this.maLoaiPhong = maLoaiPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.giaPhong = giaPhong;
        this.trangThaiPhong = trangThaiPhong;
        this.moTa = moTa;
    }

    public String getTrangThaiBadgeText() {
        if ("Available".equalsIgnoreCase(trangThaiPhong)) {
            return "[Đã dọn]";
        } else if ("Dirty".equalsIgnoreCase(trangThaiPhong)) {
            return "[Bẩn]";
        } else if ("Cleaning".equalsIgnoreCase(trangThaiPhong)) {
            return "[Đang dọn]";
        } else if ("Damaged".equalsIgnoreCase(trangThaiPhong)) {
            return "[Bảo trì]";
        } else if ("Occupied".equalsIgnoreCase(trangThaiPhong)) {
            return "[Đang có khách]";
        } else if ("Booked".equalsIgnoreCase(trangThaiPhong)) {
            return "[Đã giữ chỗ]";
        }
        return "[" + trangThaiPhong + "]";
    }

    public String getTrangThaiCssClass() {
        if ("Available".equalsIgnoreCase(trangThaiPhong)) {
            return "badge-clean";
        } else if ("Dirty".equalsIgnoreCase(trangThaiPhong)) {
            return "badge-dirty";
        } else if ("Cleaning".equalsIgnoreCase(trangThaiPhong)) {
            return "badge-cleaning";
        } else if ("Damaged".equalsIgnoreCase(trangThaiPhong)) {
            return "badge-maintenance";
        } else if ("Occupied".equalsIgnoreCase(trangThaiPhong)) {
            return "badge-occupied";
        } else if ("Booked".equalsIgnoreCase(trangThaiPhong)) {
            return "badge-booked";
        }
        return "badge-secondary";
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

    public int getSoTang() {
        return soTang;
    }

    public void setSoTang(int soTang) {
        this.soTang = soTang;
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

    public double getGiaPhong() {
        return giaPhong;
    }

    public void setGiaPhong(double giaPhong) {
        this.giaPhong = giaPhong;
    }

    public String getTrangThaiPhong() {
        return trangThaiPhong;
    }

    public void setTrangThaiPhong(String trangThaiPhong) {
        this.trangThaiPhong = trangThaiPhong;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public List<BookingBarDTO> getBookingBars() {
        return bookingBars;
    }

    public void setBookingBars(List<BookingBarDTO> bookingBars) {
        this.bookingBars = bookingBars;
    }
}
