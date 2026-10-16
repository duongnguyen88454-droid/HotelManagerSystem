package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.manager.dto.CreateRoomTypeDTO;
import com.mycompany.hotelmanagersystem.manager.dto.RoomTypePriceDTO;
import com.mycompany.hotelmanagersystem.room.model.BedType;
import com.mycompany.hotelmanagersystem.room.model.RoomAmenity;
import com.mycompany.hotelmanagersystem.room.model.RoomType;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * DAO phục vụ chức năng cấu hình khách sạn, biểu phí, loại giường, tiện nghi và dịch vụ cho Manager.
 */
public class ManagerHotelConfigDAO extends BaseRepository<RoomType, String> {

    @Override
    protected String getTableName() {
        return "RoomType";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "RoomTypeId";
    }

    @Override
    protected RowMapper<RoomType> getRowMapper() {
        return rs -> {
            RoomType rt = new RoomType();
            rt.setMaLoaiPhong(rs.getString("RoomTypeId"));
            rt.setTenLoaiPhong(rs.getNString("RoomTypeName"));
            rt.setGiaPhong(rs.getDouble("BasePrice"));
            rt.setSoNguoiToiDa(rs.getInt("Capacity"));
            rt.setEarlyCheckInFee(rs.getDouble("EarlyCheckInFee"));
            rt.setLateCheckOutFee(rs.getDouble("LateCheckOutFee"));
            rt.setDepositPercent(rs.getDouble("DepositPercent"));
            rt.setTrangThai(rs.getBoolean("IsActive") ? "Active" : "Inactive");
            return rt;
        };
    }

    public List<RoomType> getAllRoomTypes() {
        String sql = "SELECT rt.RoomTypeId, rt.RoomTypeName, rt.BasePrice, rt.Capacity, rt.EarlyCheckInFee, "
                + "rt.LateCheckOutFee, rt.DepositPercent, rt.IsActive, "
                + "(SELECT STRING_AGG(CONCAT(rtbt.Quantity, 'x ', bt.BedTypeName), ', ') "
                + " FROM RoomType_BedType rtbt JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + " WHERE rtbt.RoomTypeId = rt.RoomTypeId) AS BedSummary, "
                + "(SELECT STRING_AGG(CONCAT(rtbt.BedTypeId, ':', rtbt.Quantity), ',') "
                + " FROM RoomType_BedType rtbt WHERE rtbt.RoomTypeId = rt.RoomTypeId) AS BedIds, "
                + "(SELECT STRING_AGG(rs.RoomServiceName, ', ') "
                + " FROM RoomType_RoomService rtrs JOIN RoomService rs ON rtrs.RoomServiceId = rs.RoomServiceId "
                + " WHERE rtrs.RoomTypeId = rt.RoomTypeId) AS AmenitySummary, "
                + "(SELECT STRING_AGG(rtrs.RoomServiceId, ',') "
                + " FROM RoomType_RoomService rtrs WHERE rtrs.RoomTypeId = rt.RoomTypeId) AS AmenityIds "
                + "FROM RoomType rt "
                + "ORDER BY rt.RoomTypeId";

        RowMapper<RoomType> mapper = rs -> {
            RoomType rt = new RoomType();
            rt.setMaLoaiPhong(rs.getString("RoomTypeId"));
            rt.setTenLoaiPhong(rs.getNString("RoomTypeName"));
            rt.setGiaPhong(rs.getDouble("BasePrice"));
            rt.setSoNguoiToiDa(rs.getInt("Capacity"));
            rt.setEarlyCheckInFee(rs.getDouble("EarlyCheckInFee"));
            rt.setLateCheckOutFee(rs.getDouble("LateCheckOutFee"));
            rt.setDepositPercent(rs.getDouble("DepositPercent"));
            rt.setTrangThai(rs.getBoolean("IsActive") ? "Active" : "Inactive");
            rt.setLoaiGiuong(rs.getString("BedSummary"));
            rt.setBedTypeIdsWithQty(rs.getString("BedIds"));
            rt.setTienNghi(rs.getString("AmenitySummary"));
            rt.setAmenityIds(rs.getString("AmenityIds"));
            return rt;
        };
        return queryCustom(sql, mapper);
    }

    public boolean updateRoomTypePricing(RoomTypePriceDTO dto) {
        if (dto == null || dto.getRoomTypeId() == null) {
            return false;
        }
        String sql = "UPDATE RoomType SET RoomTypeName = COALESCE(?, RoomTypeName), "
                + "Capacity = CASE WHEN ? > 0 THEN ? ELSE Capacity END, "
                + "BasePrice = ?, EarlyCheckInFee = ?, LateCheckOutFee = ?, "
                + "DepositPercent = ?, IsActive = ? WHERE RoomTypeId = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setNString(1, dto.getRoomTypeName());
                    ps.setInt(2, dto.getCapacity());
                    ps.setInt(3, dto.getCapacity());
                    ps.setBigDecimal(4, BigDecimal.valueOf(dto.getBasePrice()));
                    ps.setBigDecimal(5, BigDecimal.valueOf(dto.getEarlyCheckInFee()));
                    ps.setBigDecimal(6, BigDecimal.valueOf(dto.getLateCheckOutFee()));
                    ps.setBigDecimal(7, BigDecimal.valueOf(dto.getDepositPercent()));
                    ps.setBoolean(8, dto.isActive());
                    ps.setString(9, dto.getRoomTypeId());
                    ps.executeUpdate();
                }

                updateRoomTypeRelations(conn, dto);

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException | ClassNotFoundException e) {
            return false;
        }
    }

    private void updateRoomTypeRelations(Connection conn, RoomTypePriceDTO dto) throws SQLException {
        if (dto.getBedTypes() != null) {
            try (PreparedStatement psDel = conn.prepareStatement("DELETE FROM RoomType_BedType WHERE RoomTypeId = ?")) {
                psDel.setString(1, dto.getRoomTypeId());
                psDel.executeUpdate();
            }
            insertRoomTypeBeds(conn, dto.getRoomTypeId(), dto.getBedTypes());
        }
        if (dto.getAmenityIds() != null) {
            try (PreparedStatement psDel = conn.prepareStatement("DELETE FROM RoomType_RoomService WHERE RoomTypeId = ?")) {
                psDel.setString(1, dto.getRoomTypeId());
                psDel.executeUpdate();
            }
            insertRoomTypeAmenities(conn, dto.getRoomTypeId(), dto.getAmenityIds());
        }
    }

    public boolean addRoomType(CreateRoomTypeDTO dto) {
        if (dto == null) {
            return false;
        }
        String generatedId = (dto.getRoomTypeId() != null && !dto.getRoomTypeId().trim().isEmpty())
                ? dto.getRoomTypeId().trim() : generateNextId("fn_SinhMaRoomType", "RT");

        String sqlRoomType = "INSERT INTO RoomType (RoomTypeId, RoomTypeName, Capacity, BasePrice, EarlyCheckInFee, "
                + "LateCheckOutFee, DepositPercent, IsActive) VALUES (?, ?, ?, ?, ?, ?, ?, 1)";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(sqlRoomType)) {
                    ps.setString(1, generatedId);
                    ps.setNString(2, dto.getRoomTypeName());
                    ps.setInt(3, dto.getCapacity());
                    ps.setBigDecimal(4, BigDecimal.valueOf(dto.getBasePrice()));
                    ps.setBigDecimal(5, BigDecimal.valueOf(dto.getEarlyCheckInFee()));
                    ps.setBigDecimal(6, BigDecimal.valueOf(dto.getLateCheckOutFee()));
                    ps.setBigDecimal(7, BigDecimal.valueOf(dto.getDepositPercent()));
                    ps.executeUpdate();
                }
                insertRoomTypeBeds(conn, generatedId, dto.getBedTypes());
                insertRoomTypeAmenities(conn, generatedId, dto.getAmenityIds());

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException | ClassNotFoundException e) {
            return false;
        }
    }

    private void insertRoomTypeBeds(Connection conn, String roomTypeId, Map<String, Integer> bedTypes) throws SQLException {
        if (bedTypes == null || bedTypes.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO RoomType_BedType (RoomTypeId, BedTypeId, Quantity) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Map.Entry<String, Integer> entry : bedTypes.entrySet()) {
                ps.setString(1, roomTypeId);
                ps.setString(2, entry.getKey());
                ps.setInt(3, entry.getValue());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void insertRoomTypeAmenities(Connection conn, String roomTypeId, List<String> amenityIds) throws SQLException {
        if (amenityIds == null || amenityIds.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO RoomType_RoomService (RoomTypeId, RoomServiceId) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (String amenityId : amenityIds) {
                ps.setString(1, roomTypeId);
                ps.setString(2, amenityId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    public List<BedType> getAllBedTypes() {
        String sql = "SELECT BedTypeId, BedTypeName, IsActive FROM BedType ORDER BY BedTypeId";
        RowMapper<BedType> mapper = rs -> new BedType(rs.getString("BedTypeId"), rs.getNString("BedTypeName"), rs.getBoolean("IsActive"));
        return queryCustom(sql, mapper);
    }

    public boolean addBedType(String bedTypeId, String bedTypeName) {
        String finalId = (bedTypeId != null && !bedTypeId.trim().isEmpty())
                ? bedTypeId.trim() : generateNextId("fn_SinhMaBedType", "BT");
        String sql = "INSERT INTO BedType (BedTypeId, BedTypeName, IsActive) VALUES (?, ?, 1)";
        return executeUpdate(sql, finalId, bedTypeName) > 0;
    }

    public boolean toggleBedTypeStatus(String bedTypeId, boolean isActive) {
        String sql = "UPDATE BedType SET IsActive = ? WHERE BedTypeId = ?";
        return executeUpdate(sql, isActive, bedTypeId) > 0;
    }

    public List<RoomAmenity> getAllRoomAmenities() {
        String sql = "SELECT RoomServiceId, RoomServiceName, IsActive FROM RoomService ORDER BY RoomServiceId";
        RowMapper<RoomAmenity> mapper = rs -> new RoomAmenity(rs.getString("RoomServiceId"), rs.getNString("RoomServiceName"), rs.getBoolean("IsActive"));
        return queryCustom(sql, mapper);
    }

    public boolean addRoomAmenity(String amenityId, String amenityName) {
        String finalId = (amenityId != null && !amenityId.trim().isEmpty())
                ? amenityId.trim() : generateNextId("fn_SinhMaRoomService", "RS");
        String sql = "INSERT INTO RoomService (RoomServiceId, RoomServiceName, IsActive) VALUES (?, ?, 1)";
        return executeUpdate(sql, finalId, amenityName) > 0;
    }

    public boolean toggleRoomAmenityStatus(String amenityId, boolean isActive) {
        String sql = "UPDATE RoomService SET IsActive = ? WHERE RoomServiceId = ?";
        return executeUpdate(sql, isActive, amenityId) > 0;
    }

    public List<ServiceItem> getAllServices() {
        String sql = "SELECT ServiceId, ServiceName, BasePrice, IsActive FROM Service ORDER BY ServiceId";
        RowMapper<ServiceItem> mapper = rs -> {
            ServiceItem item = new ServiceItem();
            item.setMaDichVu(rs.getString("ServiceId"));
            item.setTenDichVu(rs.getNString("ServiceName"));
            item.setDonGia(rs.getDouble("BasePrice"));
            item.setTrangThai(rs.getBoolean("IsActive") ? "Active" : "Inactive");
            return item;
        };
        return queryCustom(sql, mapper);
    }

    public boolean addService(String serviceId, String serviceName, double basePrice) {
        String finalId = (serviceId != null && !serviceId.trim().isEmpty())
                ? serviceId.trim() : generateNextId("fn_SinhMaService", "SRV");
        String sql = "INSERT INTO Service (ServiceId, ServiceName, BasePrice, IsActive) VALUES (?, ?, ?, 1)";
        return executeUpdate(sql, finalId, serviceName, BigDecimal.valueOf(basePrice)) > 0;
    }

    public boolean updateService(String serviceId, double basePrice, boolean isActive) {
        String sql = "UPDATE Service SET BasePrice = ?, IsActive = ? WHERE ServiceId = ?";
        return executeUpdate(sql, BigDecimal.valueOf(basePrice), isActive, serviceId) > 0;
    }

    private String generateNextId(String functionName, String defaultPrefix) {
        try {
            String nextId = queryScalarString("SELECT dbo." + functionName + "()");
            if (nextId != null && !nextId.trim().isEmpty()) {
                return nextId.trim();
            }
        } catch (Exception ignored) {
            // Fallback an toan
        }
        return defaultPrefix + (System.currentTimeMillis() % 1000);
    }
}

