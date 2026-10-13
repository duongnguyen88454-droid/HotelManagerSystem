package com.mycompany.hotelmanagersystem.cashier.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * DTO biểu diễn một giao dịch nạp tiền / thanh toán của hóa đơn.
 */
public class PaymentRecordDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String maThanhToan;
    private String maHoaDon;
    private String maNV;
    private String tenNV;
    private Double soTien;
    private String phuongThucThanhToan;
    private Timestamp thoiDiemThanhToan;

    public PaymentRecordDTO() {
    }

    public PaymentRecordDTO(String maThanhToan, String maHoaDon, String maNV, String tenNV,
                            Double soTien, String phuongThucThanhToan, Timestamp thoiDiemThanhToan) {
        this.maThanhToan = maThanhToan;
        this.maHoaDon = maHoaDon;
        this.maNV = maNV;
        this.tenNV = tenNV;
        this.soTien = soTien;
        this.phuongThucThanhToan = phuongThucThanhToan;
        this.thoiDiemThanhToan = thoiDiemThanhToan;
    }

    public String getMaThanhToan() {
        return maThanhToan;
    }

    public void setMaThanhToan(String maThanhToan) {
        this.maThanhToan = maThanhToan;
    }

    public String getMaHoaDon() {
        return maHoaDon;
    }

    public void setMaHoaDon(String maHoaDon) {
        this.maHoaDon = maHoaDon;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }

    public String getTenNV() {
        return tenNV;
    }

    public void setTenNV(String tenNV) {
        this.tenNV = tenNV;
    }

    public Double getSoTien() {
        return soTien;
    }

    public void setSoTien(Double soTien) {
        this.soTien = soTien;
    }

    public String getPhuongThucThanhToan() {
        return phuongThucThanhToan;
    }

    public void setPhuongThucThanhToan(String phuongThucThanhToan) {
        this.phuongThucThanhToan = phuongThucThanhToan;
    }

    public Timestamp getThoiDiemThanhToan() {
        return thoiDiemThanhToan;
    }

    public void setThoiDiemThanhToan(Timestamp thoiDiemThanhToan) {
        this.thoiDiemThanhToan = thoiDiemThanhToan;
    }
}
