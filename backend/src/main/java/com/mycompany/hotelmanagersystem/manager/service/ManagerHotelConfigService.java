package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.manager.dao.ManagerHotelConfigDAO;
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

    public List<BedType> getAllBedTypes() {
        return configDAO.getAllBedTypes();
    }

    public boolean addBedType(String bedTypeId, String bedTypeName) {
        if (bedTypeId == null || bedTypeId.trim().isEmpty() || bedTypeName == null || bedTypeName.trim().isEmpty()) {
            return false;
        }
        return configDAO.addBedType(bedTypeId.trim(), bedTypeName.trim());
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
        if (amenityId == null || amenityId.trim().isEmpty() || amenityName == null || amenityName.trim().isEmpty()) {
            return false;
        }
        return configDAO.addRoomAmenity(amenityId.trim(), amenityName.trim());
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
        if (serviceId == null || serviceId.trim().isEmpty() || serviceName == null || serviceName.trim().isEmpty()) {
            return false;
        }
        return configDAO.addService(serviceId.trim(), serviceName.trim(), Math.max(0, basePrice));
    }

    public boolean updateService(String serviceId, double basePrice, boolean isActive) {
        if (serviceId == null || serviceId.trim().isEmpty()) {
            return false;
        }
        return configDAO.updateService(serviceId.trim(), Math.max(0, basePrice), isActive);
    }
}
