package com.mycompany.hotelmanagersystem.hotelservice.dao;

import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {

    /**
     * Lấy toàn bộ danh sách dịch vụ đang được áp dụng kinh doanh
     */
    public List<ServiceItem> getAllActiveServices() {
        List<ServiceItem> list = new ArrayList<>();
        String sql = "SELECT ServiceId AS MaDichVu, ServiceName AS TenDichVu, BasePrice AS DonGia, "
                   + "       CASE WHEN IsActive = 1 THEN 'ApDung' ELSE 'NgungApDung' END AS TrangThai "
                   + "FROM Service "
                   + "WHERE IsActive = 1 "
                   + "ORDER BY BasePrice ASC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ServiceItem item = new ServiceItem(
                        rs.getString("MaDichVu"),
                        rs.getNString("TenDichVu"),
                        rs.getDouble("DonGia"),
                        rs.getString("TrangThai")
                );
                list.add(item);
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy chi tiết một dịch vụ theo mã
     */
    public ServiceItem getServiceById(String maDichVu) {
        String sql = "SELECT ServiceId AS MaDichVu, ServiceName AS TenDichVu, BasePrice AS DonGia, "
                   + "       CASE WHEN IsActive = 1 THEN 'ApDung' ELSE 'NgungApDung' END AS TrangThai "
                   + "FROM Service "
                   + "WHERE ServiceId = ? AND IsActive = 1";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maDichVu);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new ServiceItem(
                            rs.getString("MaDichVu"),
                            rs.getNString("TenDichVu"),
                            rs.getDouble("DonGia"),
                            rs.getString("TrangThai")
                    );
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }
}
