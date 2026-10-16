package com.mycompany.hotelmanagersystem.room.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.room.model.BedType;
import com.mycompany.hotelmanagersystem.room.model.RoomAmenity;

import java.util.List;

/**
 * DAO chuyên trách truy vấn danh mục Loại giường (BedType) và Tiện nghi phòng (RoomService) 3NF.
 */
public class RoomAmenityDAO extends BaseRepository<RoomAmenity, String> {

    private static final String SELECT_BED_TYPES_SQL =
            "SELECT BedTypeId, BedTypeName, IsActive FROM BedType WHERE IsActive = 1 ORDER BY BedTypeName ASC";

    private static final String SELECT_AMENITIES_SQL =
            "SELECT RoomServiceId, RoomServiceName, IsActive FROM RoomService WHERE IsActive = 1 ORDER BY RoomServiceName ASC";

    @Override
    protected String getTableName() {
        return "RoomService";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "RoomServiceId";
    }

    @Override
    protected RowMapper<RoomAmenity> getRowMapper() {
        return rs -> new RoomAmenity(
                rs.getString("RoomServiceId"),
                rs.getNString("RoomServiceName"),
                rs.getBoolean("IsActive")
        );
    }

    public List<BedType> getAllActiveBedTypes() {
        RowMapper<BedType> bedMapper = rs -> new BedType(
                rs.getString("BedTypeId"),
                rs.getNString("BedTypeName"),
                rs.getBoolean("IsActive")
        );
        return queryCustom(SELECT_BED_TYPES_SQL, bedMapper);
    }

    public List<RoomAmenity> getAllActiveAmenities() {
        return query(SELECT_AMENITIES_SQL);
    }
}

