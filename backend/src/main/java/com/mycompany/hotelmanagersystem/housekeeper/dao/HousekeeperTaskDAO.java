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
            "SELECT rct.RoomCleaningTaskId AS MaNhiemVu, r.RoomId AS MaPhong, r.RoomName AS SoPhong, "
            + "rt.RoomTypeName AS TenLoaiPhong, r.HousekeepingStatus AS TrangThaiPhong, "
            + "rct.RoomCleaningTaskStatus AS TrangThaiNhiemVu, "
            + "ISNULL(rct.ReceivedBy, '') AS MaNhanVienDon, "
            + "ISNULL(emp.FullName, acc.UserName) AS TenNhanVienDon, "
            + "rct.StartTime AS ThoiGianNhan, rct.StartTime AS ThoiGianBatDau, "
            + "rct.EndTime AS ThoiGianKetThuc, rct.Result AS KetQua "
            + "FROM RoomCleaningTask rct "
            + "INNER JOIN Room r ON rct.RoomId = r.RoomId "
            + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
            + "LEFT JOIN Account acc ON rct.ReceivedBy = acc.AccountId "
            + "LEFT JOIN Employee emp ON acc.AccountId = emp.AccountId "
            + "WHERE (? IS NULL OR rct.RoomCleaningTaskStatus = ?) "
            + "ORDER BY CASE rct.RoomCleaningTaskStatus "
            + "WHEN 'InProgress' THEN 1 "
            + "WHEN 'Pending' THEN 2 "
            + "ELSE 3 END, rct.RoomCleaningTaskId DESC";

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
        if (statusFilter == null || statusFilter.trim().isEmpty()
                || "TatCa".equalsIgnoreCase(statusFilter.trim())) {
            return null;
        }
        String s = statusFilter.trim();
        if ("ChoXuLy".equalsIgnoreCase(s) || "Pending".equalsIgnoreCase(s)) {
            return "Pending";
        }
        if ("DangDon".equalsIgnoreCase(s) || "InProgress".equalsIgnoreCase(s)) {
            return "InProgress";
        }
        if ("DaHoanThanh".equalsIgnoreCase(s) || "Completed".equalsIgnoreCase(s)) {
            return "Completed";
        }
        return s;
    }

    public void updateTaskProgress(String maNhiemVu, String maNV, String hanhDong, String ketQua)
            throws SQLException, ClassNotFoundException {
        String callSql = "{call dbo.sp_CapNhatTienDoDonPhong(?, ?, ?, ?)}";
        String normalizedAction = normalizeAction(hanhDong);
        try (Connection conn = getConnection()) {
            String validAccountId = resolveAccountId(conn, maNV);
            try (CallableStatement cs = conn.prepareCall(callSql)) {
                cs.setString(1, maNhiemVu);
                cs.setString(2, validAccountId);
                cs.setString(3, normalizedAction);
                cs.setString(4, ketQua);
                cs.execute();
            }
        }
    }

    private String normalizeAction(String action) {
        if (action == null) {
            return "AcceptTask";
        }
        String a = action.trim();
        if ("start".equalsIgnoreCase(a) || "NhanViec".equalsIgnoreCase(a) || "AcceptTask".equalsIgnoreCase(a)) {
            return "AcceptTask";
        }
        if ("complete".equalsIgnoreCase(a) || "HoanThanh".equalsIgnoreCase(a) || "CompleteTask".equalsIgnoreCase(a)) {
            return "CompleteTask";
        }
        return a;
    }

    private String resolveAccountId(Connection conn, String id) {
        if (id == null || id.trim().isEmpty()) {
            return "ACC004";
        }
        String clean = id.trim();
        String sqlAcc = "SELECT AccountId FROM Account WHERE AccountId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlAcc)) {
            ps.setString(1, clean);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return clean;
            }
        } catch (SQLException ignored) {
        }
        String sqlEmp = "SELECT AccountId FROM Employee WHERE EmployeeId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlEmp)) {
            ps.setString(1, clean);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("AccountId");
            }
        } catch (SQLException ignored) {
        }
        return "ACC004";
    }

    public HousekeeperTaskDTO getTaskById(String maNhiemVu) {
        String sql = "SELECT rct.RoomCleaningTaskId AS MaNhiemVu, r.RoomId AS MaPhong, r.RoomName AS SoPhong, "
                + "rt.RoomTypeName AS TenLoaiPhong, r.HousekeepingStatus AS TrangThaiPhong, "
                + "rct.RoomCleaningTaskStatus AS TrangThaiNhiemVu, "
                + "ISNULL(rct.ReceivedBy, '') AS MaNhanVienDon, "
                + "ISNULL(emp.FullName, acc.UserName) AS TenNhanVienDon, "
                + "rct.StartTime AS ThoiGianNhan, rct.StartTime AS ThoiGianBatDau, "
                + "rct.EndTime AS ThoiGianKetThuc, rct.Result AS KetQua "
                + "FROM RoomCleaningTask rct "
                + "INNER JOIN Room r ON rct.RoomId = r.RoomId "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "LEFT JOIN Account acc ON rct.ReceivedBy = acc.AccountId "
                + "LEFT JOIN Employee emp ON acc.AccountId = emp.AccountId "
                + "WHERE rct.RoomCleaningTaskId = ?";
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
