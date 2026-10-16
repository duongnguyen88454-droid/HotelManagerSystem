package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.manager.dto.ServiceAnalyticsDTO;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class ServiceAnalyticsDAO extends BaseRepository<ServiceAnalyticsDTO, String> {

    private static final String SELECT_SERVICE_ANALYTICS_SQL =
            "SELECT MaDichVu, TenDichVu, DonGiaHienTai, TongSoLuongSuDung, TongDoanhThuDichVu "
                    + "FROM v_ThongKeDichVuBanChay "
                    + "ORDER BY TongDoanhThuDichVu DESC, TongSoLuongSuDung DESC";

    @Override
    protected String getTableName() {
        return "v_ThongKeDichVuBanChay";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "MaDichVu";
    }

    @Override
    protected RowMapper<ServiceAnalyticsDTO> getRowMapper() {
        return this::mapResultSetToDTO;
    }

    public List<ServiceAnalyticsDTO> getServiceAnalytics() {
        return query(SELECT_SERVICE_ANALYTICS_SQL);
    }

    private ServiceAnalyticsDTO mapResultSetToDTO(ResultSet rs) throws SQLException {
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

