package com.mycompany.hotelmanagersystem.room.dto;

public class RoomMapKpiDTO {
    private int tongSoPhong;
    private int soPhongAvailable;
    private int soPhongOccupied;
    private int soPhongDirty;
    private int soPhongCleaning;
    private int soPhongDamaged;
    private int soPhongBooked;
    private double occupancyRate;

    public RoomMapKpiDTO() {}

    public RoomMapKpiDTO(int tongSoPhong, int soPhongAvailable, int soPhongOccupied,
                         int soPhongDirty, int soPhongCleaning, int soPhongDamaged, int soPhongBooked) {
        this.tongSoPhong = tongSoPhong;
        this.soPhongAvailable = soPhongAvailable;
        this.soPhongOccupied = soPhongOccupied;
        this.soPhongDirty = soPhongDirty;
        this.soPhongCleaning = soPhongCleaning;
        this.soPhongDamaged = soPhongDamaged;
        this.soPhongBooked = soPhongBooked;
        this.occupancyRate = tongSoPhong > 0 ? ((double) soPhongOccupied / tongSoPhong) * 100.0 : 0.0;
    }

    public String getFormattedOccupancyRate() {
        return String.format("%.1f%%", occupancyRate);
    }

    public int getTongSoPhong() {
        return tongSoPhong;
    }

    public void setTongSoPhong(int tongSoPhong) {
        this.tongSoPhong = tongSoPhong;
    }

    public int getSoPhongAvailable() {
        return soPhongAvailable;
    }

    public void setSoPhongAvailable(int soPhongAvailable) {
        this.soPhongAvailable = soPhongAvailable;
    }

    public int getSoPhongOccupied() {
        return soPhongOccupied;
    }

    public void setSoPhongOccupied(int soPhongOccupied) {
        this.soPhongOccupied = soPhongOccupied;
    }

    public int getSoPhongDirty() {
        return soPhongDirty;
    }

    public void setSoPhongDirty(int soPhongDirty) {
        this.soPhongDirty = soPhongDirty;
    }

    public int getSoPhongCleaning() {
        return soPhongCleaning;
    }

    public void setSoPhongCleaning(int soPhongCleaning) {
        this.soPhongCleaning = soPhongCleaning;
    }

    public int getSoPhongDamaged() {
        return soPhongDamaged;
    }

    public void setSoPhongDamaged(int soPhongDamaged) {
        this.soPhongDamaged = soPhongDamaged;
    }

    public int getSoPhongBooked() {
        return soPhongBooked;
    }

    public void setSoPhongBooked(int soPhongBooked) {
        this.soPhongBooked = soPhongBooked;
    }

    public double getOccupancyRate() {
        return occupancyRate;
    }

    public void setOccupancyRate(double occupancyRate) {
        this.occupancyRate = occupancyRate;
    }
}
