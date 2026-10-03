package com.mycompany.hotelmanagersystem.housekeeper.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.housekeeper.dto.HousekeeperTaskDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO truy vấn dữ liệu nhiệm vụ dọn phòng từ CSDL.
 */
public class HousekeeperTaskDAO extends DBContext {

    private static final String SELECT_TASKS_SQL =
            "SELECT nvdp.MaNhiemVu, p.MaPhong, p.SoPhong, lp.TenLoaiPhong, "
            + "p.TrangThai AS TrangThaiPhong, nvdp.TrangThai AS TrangThaiNhiemVu, "
            + "nv.MaNV AS MaNhanVienDon, nv.HoTen AS TenNhanVienDon, "
            + "nvdp.ThoiGianNhan, nvdp.ThoiGianBatDau, nvdp.ThoiGianKetThuc, nvdp.KetQua "
            + "FROM NHIEMVUDOPHONG nvdp "
            + "INNER JOIN PHONG p ON nvdp.MaPhong = p.MaPhong "
            + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
            + "LEFT JOIN NHANVIEN nv ON nvdp.MaNV = nv.MaNV "
            + "WHERE p.TrangThai IN ('Dirty', 'Cleaning') "
            + "AND (? IS NULL OR nvdp.TrangThai = ?) "
            + "ORDER BY CASE p.TrangThai "
            + "WHEN 'Cleaning' THEN 1 "
            + "WHEN 'Dirty' THEN 2 "
            + "ELSE 3 END, nvdp.ThoiGianNhan DESC";

    public List<HousekeeperTaskDTO> getTasks(String statusFilter) {
        List<HousekeeperTaskDTO> list = new ArrayList<>();
        String filterVal = resolveFilterValue(statusFilter);

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_TASKS_SQL)) {
            ps.setString(1, filterVal);
            ps.setString(2, filterVal);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapTaskRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String resolveFilterValue(String statusFilter) {
        if (statusFilter != null && !statusFilter.trim().isEmpty()
                && !"TatCa".equalsIgnoreCase(statusFilter.trim())) {
            return statusFilter.trim();
        }
        return null;
    }

    public void updateTaskProgress(String maNhiemVu, String maNV, String hanhDong, String ketQua)
            throws SQLException, ClassNotFoundException {
        String callSql = "{call sp_CapNhatTienDoDonPhong(?, ?, ?, ?)}";
        try (Connection conn = getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setString(1, maNhiemVu);
            cs.setString(2, maNV);
            cs.setString(3, hanhDong);
            cs.setString(4, ketQua);
            cs.execute();
        }
    }

    public HousekeeperTaskDTO getTaskById(String maNhiemVu) {
        String sql = "SELECT nvdp.MaNhiemVu, p.MaPhong, p.SoPhong, lp.TenLoaiPhong, "
                + "p.TrangThai AS TrangThaiPhong, nvdp.TrangThai AS TrangThaiNhiemVu, "
                + "nv.MaNV AS MaNhanVienDon, nv.HoTen AS TenNhanVienDon, "
                + "nvdp.ThoiGianNhan, nvdp.ThoiGianBatDau, nvdp.ThoiGianKetThuc, nvdp.KetQua "
                + "FROM NHIEMVUDOPHONG nvdp "
                + "INNER JOIN PHONG p ON nvdp.MaPhong = p.MaPhong "
                + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                + "LEFT JOIN NHANVIEN nv ON nvdp.MaNV = nv.MaNV "
                + "WHERE nvdp.MaNhiemVu = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maNhiemVu);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapTaskRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private HousekeeperTaskDTO mapTaskRow(ResultSet rs) throws SQLException {
        HousekeeperTaskDTO dto = new HousekeeperTaskDTO();
        dto.setMaNhiemVu(rs.getString("MaNhiemVu"));
        dto.setMaPhong(rs.getString("MaPhong"));
        dto.setSoPhong(rs.getString("SoPhong"));
        dto.setTenLoaiPhong(rs.getString("TenLoaiPhong"));
        dto.setTrangThaiPhong(rs.getString("TrangThaiPhong"));
        dto.setTrangThaiNhiemVu(rs.getString("TrangThaiNhiemVu"));
        dto.setMaNV(rs.getString("MaNhanVienDon"));
        dto.setTenNV(rs.getString("TenNhanVienDon"));
        dto.setThoiGianNhan(rs.getTimestamp("ThoiGianNhan"));
        dto.setThoiGianBatDau(rs.getTimestamp("ThoiGianBatDau"));
        dto.setThoiGianKetThuc(rs.getTimestamp("ThoiGianKetThuc"));
        dto.setKetQua(rs.getString("KetQua"));
        return dto;
    }
}
