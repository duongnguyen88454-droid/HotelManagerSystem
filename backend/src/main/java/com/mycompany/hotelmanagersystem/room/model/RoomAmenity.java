package com.mycompany.hotelmanagersystem.room.model;

import java.io.Serializable;

/**
 * Entity ánh xạ bảng RoomService (Tiện nghi phòng: Smart TV, Bồn tắm...) trong CSDL 3NF.
 */
public class RoomAmenity implements Serializable {
    private static final long serialVersionUID = 1L;

    private String roomServiceId;
    private String roomServiceName;
    private boolean isActive;

    public RoomAmenity() {
    }

    public RoomAmenity(String roomServiceId, String roomServiceName, boolean isActive) {
        this.roomServiceId = roomServiceId;
        this.roomServiceName = roomServiceName;
        this.isActive = isActive;
    }

    public String getRoomServiceId() {
        return roomServiceId;
    }

    public void setRoomServiceId(String roomServiceId) {
        this.roomServiceId = roomServiceId;
    }

    public String getRoomServiceName() {
        return roomServiceName;
    }

    public void setRoomServiceName(String roomServiceName) {
        this.roomServiceName = roomServiceName;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}
