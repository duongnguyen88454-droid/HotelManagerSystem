package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DTO truyền dữ liệu tạo hạng phòng mới kèm cấu hình loại giường và tiện nghi.
 */
public class CreateRoomTypeDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String roomTypeId;
    private String roomTypeName;
    private int capacity;
    private double basePrice;
    private double earlyCheckInFee;
    private double lateCheckOutFee;
    private double depositPercent;
    private Map<String, Integer> bedTypes = new HashMap<>();
    private List<String> amenityIds = new ArrayList<>();

    public CreateRoomTypeDTO() {
    }

    public CreateRoomTypeDTO(String roomTypeId, String roomTypeName, int capacity,
                             double basePrice, double earlyCheckInFee,
                             double lateCheckOutFee, double depositPercent) {
        this.roomTypeId = roomTypeId;
        this.roomTypeName = roomTypeName;
        this.capacity = capacity;
        this.basePrice = basePrice;
        this.earlyCheckInFee = earlyCheckInFee;
        this.lateCheckOutFee = lateCheckOutFee;
        this.depositPercent = depositPercent;
    }

    public String getRoomTypeId() {
        return roomTypeId;
    }

    public void setRoomTypeId(String roomTypeId) {
        this.roomTypeId = roomTypeId;
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
