package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * DTO chứa thông tin cập nhật biểu phí và cấu hình hạng phòng cho Ban Quản Lý.
 */
public class RoomTypePriceDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String roomTypeId;
    private String roomTypeName;
    private int capacity;
    private double basePrice;
    private double earlyCheckInFee;
    private double lateCheckOutFee;
    private double depositPercent;
    private boolean active;
    private Map<String, Integer> bedTypes;
    private List<String> amenityIds;

    public RoomTypePriceDTO() {
    }

    public RoomTypePriceDTO(String roomTypeId, double basePrice, double earlyCheckInFee,
                            double lateCheckOutFee, double depositPercent, boolean active) {
        this.roomTypeId = roomTypeId;
        this.basePrice = basePrice;
        this.earlyCheckInFee = earlyCheckInFee;
        this.lateCheckOutFee = lateCheckOutFee;
        this.depositPercent = depositPercent;
        this.active = active;
    }

    public String getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(String roomTypeId) {
        this.roomTypeId = roomTypeId;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public double getEarlyCheckInFee() {
        return earlyCheckInFee;
    }

    public void setEarlyCheckInFee(double earlyCheckInFee) {
        this.earlyCheckInFee = earlyCheckInFee;
    }

    public double getLateCheckOutFee() {
        return lateCheckOutFee;
    }

    public void setLateCheckOutFee(double lateCheckOutFee) {
        this.lateCheckOutFee = lateCheckOutFee;
    }

    public double getDepositPercent() {
        return depositPercent;
    }

    public void setDepositPercent(double depositPercent) {
        this.depositPercent = depositPercent;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getRoomTypeName() {
        return roomTypeName;
    }

    public void setRoomTypeName(String roomTypeName) {
        this.roomTypeName = roomTypeName;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public Map<String, Integer> getBedTypes() {
        return bedTypes;
    }

    public void setBedTypes(Map<String, Integer> bedTypes) {
        this.bedTypes = bedTypes;
    }

    public List<String> getAmenityIds() {
        return amenityIds;
    }

    public void setAmenityIds(List<String> amenityIds) {
        this.amenityIds = amenityIds;
    }
}
