package com.mycompany.hotelmanagersystem.dto.booking;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO chi tiết của 1 phòng trong đơn đặt phòng kèm danh sách các dịch vụ gọi cho phòng đó
 */
public class RoomBookingDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maPhong;
    private String soPhong;
    private String maLoaiPhong;
    private String tenLoaiPhong;
    private double donGiaPhong;
    private Date ngayNhanDuKien;
    private Date ngayTraDuKien;
    private Timestamp ngayCheckInThucTe;
    private Timestamp ngayCheckOutThucTe;
    private int soDem;
    private double tienPhong;
    private List<BookingDichVuItemDTO> danhSachDichVu = new ArrayList<>();
    private double tongTienDichVuPhong;

    public RoomBookingDetailDTO() {
    }

    public RoomBookingDetailDTO(String maPhong, String soPhong, String maLoaiPhong, String tenLoaiPhong, 
                                double donGiaPhong, Date ngayNhanDuKien, Date ngayTraDuKien, int soDem) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.maLoaiPhong = maLoaiPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.donGiaPhong = donGiaPhong;
        this.ngayNhanDuKien = ngayNhanDuKien;
        this.ngayTraDuKien = ngayTraDuKien;
        this.soDem = soDem;
        this.tienPhong = donGiaPhong * soDem;
    }

    public void addDichVu(BookingDichVuItemDTO item) {
        this.danhSachDichVu.add(item);
        this.tongTienDichVuPhong += item.getThanhTien();
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
        this.tienPhong = this.donGiaPhong * this.soDem;
    }

    public Date getNgayNhanDuKien() {
        return ngayNhanDuKien;
    }

    public void setNgayNhanDuKien(Date ngayNhanDuKien) {
        this.ngayNhanDuKien = ngayNhanDuKien;
    }

    public Date getNgayTraDuKien() {
        return ngayTraDuKien;
    }

    public void setNgayTraDuKien(Date ngayTraDuKien) {
        this.ngayTraDuKien = ngayTraDuKien;
    }

    public Timestamp getNgayCheckInThucTe() {
        return ngayCheckInThucTe;
    }

    public void setNgayCheckInThucTe(Timestamp ngayCheckInThucTe) {
        this.ngayCheckInThucTe = ngayCheckInThucTe;
    }

    public Timestamp getNgayCheckOutThucTe() {
        return ngayCheckOutThucTe;
    }

    public void setNgayCheckOutThucTe(Timestamp ngayCheckOutThucTe) {
        this.ngayCheckOutThucTe = ngayCheckOutThucTe;
    }

    public int getSoDem() {
        return soDem;
    }

    public void setSoDem(int soDem) {
        this.soDem = soDem;
        this.tienPhong = this.donGiaPhong * this.soDem;
    }

    public double getTienPhong() {
        return tienPhong;
    }

    public void setTienPhong(double tienPhong) {
        this.tienPhong = tienPhong;
    }

    public List<BookingDichVuItemDTO> getDanhSachDichVu() {
        return danhSachDichVu;
    }

    public void setDanhSachDichVu(List<BookingDichVuItemDTO> danhSachDichVu) {
        this.danhSachDichVu = danhSachDichVu;
        this.tongTienDichVuPhong = 0;
        if (danhSachDichVu != null) {
            for (BookingDichVuItemDTO item : danhSachDichVu) {
                this.tongTienDichVuPhong += item.getThanhTien();
            }
        }
    }

    public double getTongTienDichVuPhong() {
        return tongTienDichVuPhong;
    }

    public void setTongTienDichVuPhong(double tongTienDichVuPhong) {
        this.tongTienDichVuPhong = tongTienDichVuPhong;
    }
}
