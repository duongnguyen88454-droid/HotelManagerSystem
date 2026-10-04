package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.RoomOccupancyDTO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ManagerDashboardDAO extends DBContext {

    private static final String SELECT_OCCUPANCY_SQL =
            "SELECT TongSoPhong, SoPhongDangCoKhach, SoPhongTrong, SoPhongDangDon, "
                    + "SoPhongHuHai, TyLeLapDayPhanTram FROM v_TyLeLapDayPhong";

    public RoomOccupancyDTO getOccupancySummary() {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_OCCUPANCY_SQL);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return mapResultSetToDTO(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new RoomOccupancyDTO(0, 0, 0, 0, 0, BigDecimal.ZERO);
    }

    private RoomOccupancyDTO mapResultSetToDTO(ResultSet rs) throws Exception {
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
