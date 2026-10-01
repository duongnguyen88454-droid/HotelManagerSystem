package com.mycompany.hotelmanagersystem.room.dto;

import java.io.Serializable;

/**
 * DTO chứa dữ liệu hiển thị thẻ phòng khả dụng trên màn hình tìm kiếm & đặt phòng
 */
public class AvailableRoomDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maPhong;
    private String soPhong;
    private String maLoaiPhong;
    private String tenLoaiPhong;
    private double dienTich;
    private String loaiGiuong;
    private int soNguoiToiDa;
    private double giaPhong;
    private String moTaPhong;
    private String ngayNhan;
    private String ngayTra;
    private int soDem;
    private double tongTienDuKien;
    private String hinhAnhMinhHoa;

    public AvailableRoomDTO() {
    }

    public AvailableRoomDTO(String maPhong, String soPhong, String maLoaiPhong, String tenLoaiPhong, 
                            double dienTich, String loaiGiuong, int soNguoiToiDa, double giaPhong, 
                            String moTaPhong) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.maLoaiPhong = maLoaiPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.dienTich = dienTich;
        this.loaiGiuong = loaiGiuong;
        this.soNguoiToiDa = soNguoiToiDa;
        this.giaPhong = giaPhong;
        this.moTaPhong = moTaPhong;
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

    public double getDienTich() {
        return dienTich;
    }

    public void setDienTich(double dienTich) {
        this.dienTich = dienTich;
    }

    public String getLoaiGiuong() {
        return loaiGiuong;
    }

    public void setLoaiGiuong(String loaiGiuong) {
        this.loaiGiuong = loaiGiuong;
    }

    public int getSoNguoiToiDa() {
        return soNguoiToiDa;
    }

    public void setSoNguoiToiDa(int soNguoiToiDa) {
        this.soNguoiToiDa = soNguoiToiDa;
    }

    public double getGiaPhong() {
        return giaPhong;
    }

    public void setGiaPhong(double giaPhong) {
        this.giaPhong = giaPhong;
    }

    public double getDonGia() {
        return giaPhong;
    }

    public void setDonGia(double donGia) {
        this.giaPhong = donGia;
    }

    public String getMoTaPhong() {
        return moTaPhong;
    }

    public void setMoTaPhong(String moTaPhong) {
        this.moTaPhong = moTaPhong;
    }

    public String getMoTa() {
        return moTaPhong;
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

    public int getSoDem() {
        return soDem;
    }

    public void setSoDem(int soDem) {
        this.soDem = soDem;
    }

    public double getTongTienDuKien() {
        return tongTienDuKien;
    }

    public void setTongTienDuKien(double tongTienDuKien) {
        this.tongTienDuKien = tongTienDuKien;
    }

    public String getHinhAnhMinhHoa() {
        return hinhAnhMinhHoa;
    }

    public void setHinhAnhMinhHoa(String hinhAnhMinhHoa) {
        this.hinhAnhMinhHoa = hinhAnhMinhHoa;
    }
}
