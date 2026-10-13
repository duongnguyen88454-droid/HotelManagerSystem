package com.mycompany.hotelmanagersystem.room.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.room.model.BedType;
import com.mycompany.hotelmanagersystem.room.model.RoomAmenity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO chuyên trách truy vấn danh mục Loại giường (BedType) và Tiện nghi phòng (RoomService) 3NF.
 */
public class RoomAmenityDAO extends DBContext {

    private static final String SELECT_BED_TYPES_SQL =
            "SELECT BedTypeId, BedTypeName, IsActive FROM BedType WHERE IsActive = 1 ORDER BY BedTypeName ASC";

    private static final String SELECT_AMENITIES_SQL =
            "SELECT RoomServiceId, RoomServiceName, IsActive FROM RoomService WHERE IsActive = 1 ORDER BY RoomServiceName ASC";

    public List<BedType> getAllActiveBedTypes() {
        List<BedType> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_BED_TYPES_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new BedType(
                        rs.getString("BedTypeId"),
                        rs.getNString("BedTypeName"),
                        rs.getBoolean("IsActive")
                ));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<RoomAmenity> getAllActiveAmenities() {
        List<RoomAmenity> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_AMENITIES_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new RoomAmenity(
                        rs.getString("RoomServiceId"),
                        rs.getNString("RoomServiceName"),
                        rs.getBoolean("IsActive")
                ));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }
}
