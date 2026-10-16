package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.manager.dao.ManagerHotelConfigDAO;
import com.mycompany.hotelmanagersystem.manager.dto.CreateRoomTypeDTO;
import com.mycompany.hotelmanagersystem.manager.dto.RoomTypePriceDTO;
import com.mycompany.hotelmanagersystem.room.model.BedType;
import com.mycompany.hotelmanagersystem.room.model.RoomAmenity;
import com.mycompany.hotelmanagersystem.room.model.RoomType;

import java.util.List;

/**
 * Service xử lý logic cấu hình khách sạn, biểu phí, loại giường, tiện nghi và dịch vụ cho Ban Quản Lý.
 */
public class ManagerHotelConfigService {

    private final ManagerHotelConfigDAO configDAO;

    public ManagerHotelConfigService() {
        this.configDAO = new ManagerHotelConfigDAO();
    }

    public ManagerHotelConfigService(ManagerHotelConfigDAO configDAO) {
        this.configDAO = configDAO;
    }

    public List<RoomType> getAllRoomTypes() {
        return configDAO.getAllRoomTypes();
    }

    public boolean updateRoomTypePricing(RoomTypePriceDTO dto) {
        if (dto == null || dto.getRoomTypeId() == null || dto.getRoomTypeId().trim().isEmpty()) {
            return false;
        }
        return configDAO.updateRoomTypePricing(dto);
    }

    public boolean addRoomType(CreateRoomTypeDTO dto) {
        if (dto == null || dto.getRoomTypeName() == null || dto.getRoomTypeName().trim().isEmpty()
                || dto.getCapacity() <= 0 || dto.getBasePrice() < 0 || dto.getEarlyCheckInFee() < 0
                || dto.getLateCheckOutFee() < 0 || dto.getDepositPercent() < 0 || dto.getDepositPercent() > 100) {
            return false;
        }
        if (dto.getRoomTypeId() != null) {
            dto.setRoomTypeId(dto.getRoomTypeId().trim());
        }
        dto.setRoomTypeName(dto.getRoomTypeName().trim());
        return configDAO.addRoomType(dto);
    }

    public List<BedType> getAllBedTypes() {
        return configDAO.getAllBedTypes();
    }

    public boolean addBedType(String bedTypeId, String bedTypeName) {
        if (bedTypeName == null || bedTypeName.trim().isEmpty()) {
            return false;
        }
        String id = (bedTypeId != null) ? bedTypeId.trim() : "";
        return configDAO.addBedType(id, bedTypeName.trim());
    }

    public boolean toggleBedTypeStatus(String bedTypeId, boolean isActive) {
        if (bedTypeId == null || bedTypeId.trim().isEmpty()) {
            return false;
        }
        return configDAO.toggleBedTypeStatus(bedTypeId.trim(), isActive);
    }

    public List<RoomAmenity> getAllRoomAmenities() {
        return configDAO.getAllRoomAmenities();
    }

    public boolean addRoomAmenity(String amenityId, String amenityName) {
        if (amenityName == null || amenityName.trim().isEmpty()) {
            return false;
        }
        String id = (amenityId != null) ? amenityId.trim() : "";
        return configDAO.addRoomAmenity(id, amenityName.trim());
    }

    public boolean toggleRoomAmenityStatus(String amenityId, boolean isActive) {
        if (amenityId == null || amenityId.trim().isEmpty()) {
            return false;
        }
        return configDAO.toggleRoomAmenityStatus(amenityId.trim(), isActive);
    }

    public List<ServiceItem> getAllServices() {
        return configDAO.getAllServices();
    }

    public boolean addService(String serviceId, String serviceName, double basePrice) {
        if (serviceName == null || serviceName.trim().isEmpty()) {
            return false;
        }
        String id = (serviceId != null) ? serviceId.trim() : "";
        return configDAO.addService(id, serviceName.trim(), Math.max(0, basePrice));
    }

    public boolean updateService(String serviceId, double basePrice, boolean isActive) {
        if (serviceId == null || serviceId.trim().isEmpty()) {
            return false;
        }
        return configDAO.updateService(serviceId.trim(), Math.max(0, basePrice), isActive);
    }
}
