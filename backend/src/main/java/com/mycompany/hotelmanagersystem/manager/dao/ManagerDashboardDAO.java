package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.manager.dto.RoomOccupancyDTO;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ManagerDashboardDAO extends BaseRepository<RoomOccupancyDTO, Integer> {

    private static final String SELECT_OCCUPANCY_SQL =
            "SELECT TongSoPhong, SoPhongDangCoKhach, SoPhongTrong, SoPhongDangDon, "
                    + "SoPhongHuHai, TyLeLapDayPhanTram FROM v_TyLeLapDayPhong";

    @Override
    protected String getTableName() {
        return "v_TyLeLapDayPhong";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "TongSoPhong";
    }

    @Override
    protected RowMapper<RoomOccupancyDTO> getRowMapper() {
        return this::mapResultSetToDTO;
    }

    public RoomOccupancyDTO getOccupancySummary() {
        return queryOne(SELECT_OCCUPANCY_SQL).orElseGet(() -> new RoomOccupancyDTO(0, 0, 0, 0, 0, BigDecimal.ZERO));
    }

    private RoomOccupancyDTO mapResultSetToDTO(ResultSet rs) throws SQLException {
        int tong = rs.getInt("TongSoPhong");
        int coKhach = rs.getInt("SoPhongDangCoKhach");
        int trong = rs.getInt("SoPhongTrong");
        int dangDon = rs.getInt("SoPhongDangDon");
        int huHai = rs.getInt("SoPhongHuHai");
        BigDecimal tyLe = rs.getBigDecimal("TyLeLapDayPhanTram");
        if (tyLe == null) {
            tyLe = BigDecimal.ZERO;
        }
        return new RoomOccupancyDTO(tong, coKhach, trong, dangDon, huHai, tyLe);
    }
}

