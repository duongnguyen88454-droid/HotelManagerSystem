package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDate;

public class DailyAuditReportDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private LocalDate ngayBaoCao;
    private int soDonDatMoi;
    private int soPhongCheckIn;
    private int soPhongCheckOut;
    private BigDecimal tongTienThucThu;
    private BigDecimal thuTienMat;
    private BigDecimal thuChuyenKhoan;
    private BigDecimal thuTheNganHang;

    public DailyAuditReportDTO() {
    }

    public DailyAuditReportDTO(LocalDate ngayBaoCao, int soDonDatMoi, int soPhongCheckIn,
                               int soPhongCheckOut, BigDecimal tongTienThucThu,
                               BigDecimal thuTienMat, BigDecimal thuChuyenKhoan,
                               BigDecimal thuTheNganHang) {
        this.ngayBaoCao = ngayBaoCao;
        this.soDonDatMoi = soDonDatMoi;
        this.soPhongCheckIn = soPhongCheckIn;
        this.soPhongCheckOut = soPhongCheckOut;
        this.tongTienThucThu = tongTienThucThu;
        this.thuTienMat = thuTienMat;
        this.thuChuyenKhoan = thuChuyenKhoan;
        this.thuTheNganHang = thuTheNganHang;
    }

    public LocalDate getNgayBaoCao() {
        return ngayBaoCao;
    }

    public void setNgayBaoCao(LocalDate ngayBaoCao) {
        this.ngayBaoCao = ngayBaoCao;
    }

    public int getSoDonDatMoi() {
        return soDonDatMoi;
    }

    public void setSoDonDatMoi(int soDonDatMoi) {
        this.soDonDatMoi = soDonDatMoi;
    }

    public int getSoPhongCheckIn() {
        return soPhongCheckIn;
    }

    public void setSoPhongCheckIn(int soPhongCheckIn) {
        this.soPhongCheckIn = soPhongCheckIn;
    }

    public int getSoPhongCheckOut() {
        return soPhongCheckOut;
    }

    public void setSoPhongCheckOut(int soPhongCheckOut) {
        this.soPhongCheckOut = soPhongCheckOut;
    }

    public BigDecimal getTongTienThucThu() {
        return tongTienThucThu;
    }

    public void setTongTienThucThu(BigDecimal tongTienThucThu) {
        this.tongTienThucThu = tongTienThucThu;
    }

    public BigDecimal getThuTienMat() {
        return thuTienMat;
    }

    public void setThuTienMat(BigDecimal thuTienMat) {
        this.thuTienMat = thuTienMat;
    }

    public BigDecimal getThuChuyenKhoan() {
        return thuChuyenKhoan;
    }

    public void setThuChuyenKhoan(BigDecimal thuChuyenKhoan) {
        this.thuChuyenKhoan = thuChuyenKhoan;
    }

    public BigDecimal getThuTheNganHang() {
        return thuTheNganHang;
    }

    public void setThuTheNganHang(BigDecimal thuTheNganHang) {
        this.thuTheNganHang = thuTheNganHang;
    }
}
