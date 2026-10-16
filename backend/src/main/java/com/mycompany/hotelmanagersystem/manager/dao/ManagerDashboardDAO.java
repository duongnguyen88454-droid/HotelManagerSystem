package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.manager.dto.RoomOccupancyDTO;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ManagerDashboardDAO extends BaseRepository<RoomOccupancyDTO, Integer> {

    private static final String SELECT_OCCUPANCY_SQL =
            "SELECT TotalRooms, OccupiedRooms, AvailableRooms, CleaningRooms, "
                    + "MaintenanceRooms, OccupancyRatePercentage FROM v_RoomOccupancyRate";

    @Override
    protected String getTableName() {
        return "v_RoomOccupancyRate";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "TotalRooms";
    }

    @Override
    protected RowMapper<RoomOccupancyDTO> getRowMapper() {
        return this::mapResultSetToDTO;
    }

    public RoomOccupancyDTO getOccupancySummary() {
        return queryOne(SELECT_OCCUPANCY_SQL).orElseGet(() -> new RoomOccupancyDTO(0, 0, 0, 0, 0, BigDecimal.ZERO));
    }

    private RoomOccupancyDTO mapResultSetToDTO(ResultSet rs) throws SQLException {
        int tong = rs.getInt("TotalRooms");
        int coKhach = rs.getInt("OccupiedRooms");
        int trong = rs.getInt("AvailableRooms");
        int dangDon = rs.getInt("CleaningRooms");
        int huHai = rs.getInt("MaintenanceRooms");
        BigDecimal tyLe = rs.getBigDecimal("OccupancyRatePercentage");
        if (tyLe == null) {
            tyLe = BigDecimal.ZERO;
        }
        return new RoomOccupancyDTO(tong, coKhach, trong, dangDon, huHai, tyLe);
    }
}

