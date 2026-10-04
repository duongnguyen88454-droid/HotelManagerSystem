package com.mycompany.hotelmanagersystem.booking.dto;

public class CheckInRequestDTO {
    private String maBooking;
    private String maPhong;
    private String maNV;
    private String ghiChu;
    private boolean daDoiChieuCccd;

    public CheckInRequestDTO() {
    }

    public CheckInRequestDTO(String maBooking, String maPhong, String maNV,
                             String ghiChu, boolean daDoiChieuCccd) {
        this.maBooking = maBooking;
        this.maPhong = maPhong;
        this.maNV = maNV;
        this.ghiChu = ghiChu;
        this.daDoiChieuCccd = daDoiChieuCccd;
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

    public boolean isDaDoiChieuCccd() {
        return daDoiChieuCccd;
    }

    public void setDaDoiChieuCccd(boolean daDoiChieuCccd) {
        this.daDoiChieuCccd = daDoiChieuCccd;
    }
}
