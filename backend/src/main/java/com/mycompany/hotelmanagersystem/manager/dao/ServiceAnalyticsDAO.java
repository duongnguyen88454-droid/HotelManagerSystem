package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.ServiceAnalyticsDTO;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ServiceAnalyticsDAO extends DBContext {

    private static final String SELECT_SERVICE_ANALYTICS_SQL =
            "SELECT MaDichVu, TenDichVu, DonGiaHienTai, TongSoLuongSuDung, TongDoanhThuDichVu "
                    + "FROM v_ThongKeDichVuBanChay "
                    + "ORDER BY TongDoanhThuDichVu DESC, TongSoLuongSuDung DESC";

    public List<ServiceAnalyticsDTO> getServiceAnalytics() {
        List<ServiceAnalyticsDTO> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_SERVICE_ANALYTICS_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDTO(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private ServiceAnalyticsDTO mapResultSetToDTO(ResultSet rs) throws Exception {
        BigDecimal donGia = rs.getBigDecimal("DonGiaHienTai");
        BigDecimal doanhThu = rs.getBigDecimal("TongDoanhThuDichVu");
        return new ServiceAnalyticsDTO(
                rs.getString("MaDichVu"),
                rs.getString("TenDichVu"),
                (donGia != null) ? donGia : BigDecimal.ZERO,
                rs.getInt("TongSoLuongSuDung"),
                (doanhThu != null) ? doanhThu : BigDecimal.ZERO
        );
    }
}
