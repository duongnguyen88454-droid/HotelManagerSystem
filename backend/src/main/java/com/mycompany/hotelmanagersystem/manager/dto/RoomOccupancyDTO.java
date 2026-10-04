package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.math.BigDecimal;

public class RoomOccupancyDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int tongSoPhong;
    private int soPhongDangCoKhach;
    private int soPhongTrong;
    private int soPhongDangDon;
    private int soPhongHuHai;
    private BigDecimal tyLeLapDayPhanTram;

    public RoomOccupancyDTO() {
    }

    public RoomOccupancyDTO(int tongSoPhong, int soPhongDangCoKhach, int soPhongTrong,
                            int soPhongDangDon, int soPhongHuHai, BigDecimal tyLeLapDayPhanTram) {
        this.tongSoPhong = tongSoPhong;
        this.soPhongDangCoKhach = soPhongDangCoKhach;
        this.soPhongTrong = soPhongTrong;
        this.soPhongDangDon = soPhongDangDon;
        this.soPhongHuHai = soPhongHuHai;
        this.tyLeLapDayPhanTram = tyLeLapDayPhanTram;
    }

    public int getTongSoPhong() {
        return tongSoPhong;
    }

    public void setTongSoPhong(int tongSoPhong) {
        this.tongSoPhong = tongSoPhong;
    }

    public int getSoPhongDangCoKhach() {
        return soPhongDangCoKhach;
    }

    public void setSoPhongDangCoKhach(int soPhongDangCoKhach) {
        this.soPhongDangCoKhach = soPhongDangCoKhach;
    }

    public int getSoPhongTrong() {
        return soPhongTrong;
    }

    public void setSoPhongTrong(int soPhongTrong) {
        this.soPhongTrong = soPhongTrong;
    }

    public int getSoPhongDangDon() {
        return soPhongDangDon;
    }

    public void setSoPhongDangDon(int soPhongDangDon) {
        this.soPhongDangDon = soPhongDangDon;
    }

    public int getSoPhongHuHai() {
        return soPhongHuHai;
    }

    public void setSoPhongHuHai(int soPhongHuHai) {
        this.soPhongHuHai = soPhongHuHai;
    }

    public BigDecimal getTyLeLapDayPhanTram() {
        return tyLeLapDayPhanTram;
    }

    public void setTyLeLapDayPhanTram(BigDecimal tyLeLapDayPhanTram) {
        this.tyLeLapDayPhanTram = tyLeLapDayPhanTram;
    }
}
