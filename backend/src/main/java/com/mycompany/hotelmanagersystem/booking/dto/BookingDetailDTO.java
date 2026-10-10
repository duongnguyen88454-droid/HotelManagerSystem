package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * DTO chi tiết toàn diện của đơn đặt phòng bao gồm các phòng và dịch vụ kèm theo
 */
public class BookingDetailDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maBooking;
    private Timestamp ngayDat;
    private String trangThaiBooking;
    private String ghiChu;

    private String maKH;
    private String maTaiKhoan;
    private String hoTenKhachHang;
    private String soDT;
    private String email;
    private String cccd;

    private String maHoaDon;
    private String trangThaiHoaDon;

    private List<RoomBookingDetailDTO> danhSachPhong = new ArrayList<>();
    private double tongTienPhong;
    private double tongTienDichVu;
    private double tongChiPhiDuKien;
    private double tongTienCoc;

    private boolean coTheHuy;
    private boolean coTheThemDichVu;

    public BookingDetailDTO() {
    }

    public void addPhong(RoomBookingDetailDTO room) {
        this.danhSachPhong.add(room);
        recalculateTotals();
    }

    private void updateCapabilities() {
        this.coTheHuy = "Confirmed".equalsIgnoreCase(this.trangThaiBooking);
        boolean daCoc = "PartiallyPaid".equalsIgnoreCase(this.trangThaiHoaDon)
                || "Paid".equalsIgnoreCase(this.trangThaiHoaDon);
        this.coTheThemDichVu = !daCoc && ("Confirmed".equalsIgnoreCase(this.trangThaiBooking)
                || "CheckedIn".equalsIgnoreCase(this.trangThaiBooking));
    }

    public void recalculateTotals() {
        this.tongTienPhong = 0;
        this.tongTienDichVu = 0;
        this.tongTienCoc = 0;
        if (danhSachPhong != null) {
            for (RoomBookingDetailDTO room : danhSachPhong) {
                this.tongTienPhong += room.getTienPhong();
                this.tongTienDichVu += room.getTongTienDichVuPhong();
                this.tongTienCoc += room.getTienCoc();
            }
        }
        this.tongChiPhiDuKien = this.tongTienPhong + this.tongTienDichVu;
        updateCapabilities();
    }

    public String getMaBooking() {
        return maBooking;
    }

    public void setMaBooking(String maBooking) {
        this.maBooking = maBooking;
    }

    public Timestamp getNgayDat() {
        return ngayDat;
    }

    public void setNgayDat(Timestamp ngayDat) {
        this.ngayDat = ngayDat;
    }

    public String getTrangThaiBooking() {
        return trangThaiBooking;
    }

    public void setTrangThaiBooking(String trangThaiBooking) {
        this.trangThaiBooking = trangThaiBooking;
        updateCapabilities();
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public String getMaKH() {
        return maKH;
    }

    public void setMaKH(String maKH) {
        this.maKH = maKH;
    }

    public String getHoTenKhachHang() {
        return hoTenKhachHang;
    }

    public void setHoTenKhachHang(String hoTenKhachHang) {
        this.hoTenKhachHang = hoTenKhachHang;
    }

    public String getSoDT() {
        return soDT;
    }

    public void setSoDT(String soDT) {
        this.soDT = soDT;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public String getTrangThaiHoaDon() {
        return trangThaiHoaDon;
    }

    public void setTrangThaiHoaDon(String trangThaiHoaDon) {
        this.trangThaiHoaDon = trangThaiHoaDon;
        updateCapabilities();
    }

    public List<RoomBookingDetailDTO> getDanhSachPhong() {
        return danhSachPhong;
    }

    public void setDanhSachPhong(List<RoomBookingDetailDTO> danhSachPhong) {
        this.danhSachPhong = danhSachPhong;
        recalculateTotals();
    }

    public double getTongTienPhong() {
        return tongTienPhong;
    }

    public void setTongTienPhong(double tongTienPhong) {
        this.tongTienPhong = tongTienPhong;
    }

    public double getTongTienDichVu() {
        return tongTienDichVu;
    }

    public void setTongTienDichVu(double tongTienDichVu) {
        this.tongTienDichVu = tongTienDichVu;
    }

    public double getTongChiPhiDuKien() {
        return tongChiPhiDuKien;
    }

    public void setTongChiPhiDuKien(double tongChiPhiDuKien) {
        this.tongChiPhiDuKien = tongChiPhiDuKien;
    }

    public boolean isCoTheHuy() {
        return coTheHuy;
    }

    public void setCoTheHuy(boolean coTheHuy) {
        this.coTheHuy = coTheHuy;
    }

    public boolean isCoTheThemDichVu() {
        return coTheThemDichVu;
    }

    public void setCoTheThemDichVu(boolean coTheThemDichVu) {
        this.coTheThemDichVu = coTheThemDichVu;
    }

    public String getMaTaiKhoan() {
        return maTaiKhoan;
    }

    public void setMaTaiKhoan(String maTaiKhoan) {
        this.maTaiKhoan = maTaiKhoan;
    }

    public String getCccd() {
        return cccd;
    }

    public void setCccd(String cccd) {
        this.cccd = cccd;
    }

    public double getTongTienCoc() {
        return tongTienCoc;
    }

    public void setTongTienCoc(double tongTienCoc) {
        this.tongTienCoc = tongTienCoc;
    }
}
