package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;

/**
 * DTO dữ liệu phòng vật lý phục vụ quản lý cấu hình phòng khách sạn.
 */
public class PhysicalRoomDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String roomId;
    private String roomTypeId;
    private String roomTypeName;
    private String roomName;
    private String roomStatus;
    private String housekeepingStatus;
    private String occupancyStatus;

    public PhysicalRoomDTO() {
    }

    public PhysicalRoomDTO(String roomId, String roomTypeId, String roomTypeName, String roomName,
                           String roomStatus, String housekeepingStatus, String occupancyStatus) {
        this.roomId = roomId;
        this.roomTypeId = roomTypeId;
        this.roomTypeName = roomTypeName;
        this.roomName = roomName;
        this.roomStatus = roomStatus;
        this.housekeepingStatus = housekeepingStatus;
        this.occupancyStatus = occupancyStatus;
    }

    public String getRoomId() {
        return roomId;
    }

    public void setRoomId(String roomId) {
        this.roomId = roomId;
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

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getRoomStatus() {
        return roomStatus;
    }

    public void setRoomStatus(String roomStatus) {
        this.roomStatus = roomStatus;
    }

    public String getHousekeepingStatus() {
        return housekeepingStatus;
    }

    public void setHousekeepingStatus(String housekeepingStatus) {
        this.housekeepingStatus = housekeepingStatus;
    }

    public String getOccupancyStatus() {
        return occupancyStatus;
    }

    public void setOccupancyStatus(String occupancyStatus) {
        this.occupancyStatus = occupancyStatus;
    }
}
