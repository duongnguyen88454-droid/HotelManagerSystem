package com.mycompany.hotelmanagersystem.manager.dto;

import java.math.BigDecimal;

/**
 * DTO dữ liệu báo cáo Doanh Thu Tiền Phòng theo từng phòng cho Manager.
 */
public class RoomRevenueItemDTO {

    private String roomId;
    private String roomName;
    private String roomTypeName;
    private BigDecimal basePrice;
    private int totalBookings;
    private int totalNights;
    private BigDecimal totalRevenue;

    public RoomRevenueItemDTO() {
    }

    public RoomRevenueItemDTO(String roomId, String roomName, String roomTypeName,
                              BigDecimal basePrice, int totalBookings, int totalNights,
                              BigDecimal totalRevenue) {
        this.roomId = roomId;
        this.roomName = roomName;
        this.roomTypeName = roomTypeName;
        this.basePrice = (basePrice != null) ? basePrice : BigDecimal.ZERO;
        this.totalBookings = totalBookings;
        this.totalNights = totalNights;
        this.totalRevenue = (totalRevenue != null) ? totalRevenue : BigDecimal.ZERO;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomTypeName() {
        return roomTypeName;
    }

    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public int getTotalBookings() {
        return totalBookings;
    }

    public void setTotalBookings(int totalBookings) {
        this.totalBookings = totalBookings;
    }

    public int getTotalNights() {
        return totalNights;
    }

    public void setTotalNights(int totalNights) {
        this.totalNights = totalNights;
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }
}
