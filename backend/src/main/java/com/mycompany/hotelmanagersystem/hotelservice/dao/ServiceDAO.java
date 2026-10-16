package com.mycompany.hotelmanagersystem.hotelservice.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;

import java.util.List;

public class ServiceDAO extends BaseRepository<ServiceItem, String> {

    @Override
    protected String getTableName() {
        return "Service";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "ServiceId";
    }

    @Override
    protected RowMapper<ServiceItem> getRowMapper() {
        return rs -> new ServiceItem(
                rs.getString("ServiceId"),
                rs.getNString("ServiceName"),
                rs.getDouble("BasePrice"),
                rs.getBoolean("IsActive") ? "ApDung" : "NgungApDung"
        );
    }

    /**
     * Lấy toàn bộ danh sách dịch vụ đang được áp dụng kinh doanh
     */
    public List<ServiceItem> getAllActiveServices() {
        String sql = "SELECT * FROM Service WHERE IsActive = 1 ORDER BY BasePrice ASC";
        return query(sql);
    }

    /**
     * Lấy chi tiết một dịch vụ theo mã
     */
    public ServiceItem getServiceById(String maDichVu) {
        String sql = "SELECT * FROM Service WHERE ServiceId = ? AND IsActive = 1";
        return queryOne(sql, maDichVu).orElse(null);
    }
}

