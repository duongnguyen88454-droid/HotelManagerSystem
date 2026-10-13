package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.room.model.BedType;
import com.mycompany.hotelmanagersystem.room.model.RoomAmenity;
import com.mycompany.hotelmanagersystem.room.model.RoomType;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO phục vụ chức năng cấu hình khách sạn, biểu phí, loại giường, tiện nghi và dịch vụ cho Manager.
 */
public class ManagerHotelConfigDAO extends DBContext {

    public List<RoomType> getAllRoomTypes() {
        String sql = "SELECT RoomTypeId, RoomTypeName, BasePrice, Capacity, EarlyCheckInFee, "
                + "LateCheckOutFee, DepositPercent, IsActive FROM RoomType ORDER BY RoomTypeId";
        List<RoomType> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RoomType rt = new RoomType();
                rt.setMaLoaiPhong(rs.getString("RoomTypeId"));
                rt.setTenLoaiPhong(rs.getNString("RoomTypeName"));
                rt.setGiaPhong(rs.getDouble("BasePrice"));
                rt.setSoNguoiToiDa(rs.getInt("Capacity"));
                rt.setEarlyCheckInFee(rs.getDouble("EarlyCheckInFee"));
                rt.setLateCheckOutFee(rs.getDouble("LateCheckOutFee"));
                rt.setDepositPercent(rs.getDouble("DepositPercent"));
                rt.setTrangThai(rs.getBoolean("IsActive") ? "Active" : "Inactive");
                list.add(rt);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateRoomTypePricing(com.mycompany.hotelmanagersystem.manager.dto.RoomTypePriceDTO dto) {
        if (dto == null || dto.getRoomTypeId() == null) {
            return false;
        }
        String sql = "UPDATE RoomType SET BasePrice = ?, EarlyCheckInFee = ?, LateCheckOutFee = ?, "
                + "DepositPercent = ?, IsActive = ? WHERE RoomTypeId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, BigDecimal.valueOf(dto.getBasePrice()));
            ps.setBigDecimal(2, BigDecimal.valueOf(dto.getEarlyCheckInFee()));
            ps.setBigDecimal(3, BigDecimal.valueOf(dto.getLateCheckOutFee()));
            ps.setBigDecimal(4, BigDecimal.valueOf(dto.getDepositPercent()));
            ps.setBoolean(5, dto.isActive());
            ps.setString(6, dto.getRoomTypeId());
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<BedType> getAllBedTypes() {
        String sql = "SELECT BedTypeId, BedTypeName, IsActive FROM BedType ORDER BY BedTypeId";
        List<BedType> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new BedType(rs.getString("BedTypeId"), rs.getNString("BedTypeName"), rs.getBoolean("IsActive")));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addBedType(String bedTypeId, String bedTypeName) {
        String sql = "INSERT INTO BedType (BedTypeId, BedTypeName, IsActive) VALUES (?, ?, 1)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bedTypeId);
            ps.setString(2, bedTypeName);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleBedTypeStatus(String bedTypeId, boolean isActive) {
        String sql = "UPDATE BedType SET IsActive = ? WHERE BedTypeId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setString(2, bedTypeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<RoomAmenity> getAllRoomAmenities() {
        String sql = "SELECT RoomServiceId, RoomServiceName, IsActive FROM RoomService ORDER BY RoomServiceId";
        List<RoomAmenity> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new RoomAmenity(rs.getString("RoomServiceId"), rs.getNString("RoomServiceName"), rs.getBoolean("IsActive")));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addRoomAmenity(String amenityId, String amenityName) {
        String sql = "INSERT INTO RoomService (RoomServiceId, RoomServiceName, IsActive) VALUES (?, ?, 1)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, amenityId);
            ps.setString(2, amenityName);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleRoomAmenityStatus(String amenityId, boolean isActive) {
        String sql = "UPDATE RoomService SET IsActive = ? WHERE RoomServiceId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setString(2, amenityId);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<ServiceItem> getAllServices() {
        String sql = "SELECT ServiceId, ServiceName, BasePrice, IsActive FROM Service ORDER BY ServiceId";
        List<ServiceItem> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ServiceItem item = new ServiceItem();
                item.setMaDichVu(rs.getString("ServiceId"));
                item.setTenDichVu(rs.getNString("ServiceName"));
                item.setDonGia(rs.getDouble("BasePrice"));
                item.setTrangThai(rs.getBoolean("IsActive") ? "Active" : "Inactive");
                list.add(item);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addService(String serviceId, String serviceName, double basePrice) {
        String sql = "INSERT INTO Service (ServiceId, ServiceName, BasePrice, IsActive) VALUES (?, ?, ?, 1)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, serviceId);
            ps.setString(2, serviceName);
            ps.setBigDecimal(3, BigDecimal.valueOf(basePrice));
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateService(String serviceId, double basePrice, boolean isActive) {
        String sql = "UPDATE Service SET BasePrice = ?, IsActive = ? WHERE ServiceId = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, BigDecimal.valueOf(basePrice));
            ps.setBoolean(2, isActive);
            ps.setString(3, serviceId);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }
}
