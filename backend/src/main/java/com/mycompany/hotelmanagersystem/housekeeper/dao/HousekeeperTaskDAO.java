package com.mycompany.hotelmanagersystem.housekeeper.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.housekeeper.dto.HousekeeperTaskDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * DAO truy vấn dữ liệu nhiệm vụ dọn phòng từ CSDL.
 */
public class HousekeeperTaskDAO extends BaseRepository<HousekeeperTaskDTO, String> {

    private static final String SELECT_TASKS_SQL = "SELECT * FROM v_HousekeeperTasks "
            + "WHERE (? IS NULL OR TaskStatus = ?) "
            + "ORDER BY CASE TaskStatus "
            + "WHEN 'InProgress' THEN 1 "
            + "WHEN 'Pending' THEN 2 "
            + "ELSE 3 END, TaskId DESC";

    private static final String SELECT_BY_ID_SQL = "SELECT * FROM v_HousekeeperTasks "
            + "WHERE TaskId = ?";

    @Override
    protected String getTableName() {
        return "v_HousekeeperTasks";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "TaskId";
    }

    @Override
    protected RowMapper<HousekeeperTaskDTO> getRowMapper() {
        return this::mapTaskRow;
    }

    public List<HousekeeperTaskDTO> getTasks(String statusFilter) {
        return getTasks(statusFilter, null, null);
    }

    public List<HousekeeperTaskDTO> getTasks(String statusFilter, String maTK, String maNV) {
        if ("MyActive".equalsIgnoreCase(statusFilter)) {
            String sql = SELECT_TASKS_SQL.replace("WHERE (? IS NULL OR TaskStatus = ?)",
                    "WHERE TaskStatus = 'InProgress' AND (StaffId = ? OR StaffId = ?)");
            return query(sql, maTK, maNV);
        }
        if ("MyHistory".equalsIgnoreCase(statusFilter)) {
            String sql = SELECT_TASKS_SQL.replace("WHERE (? IS NULL OR TaskStatus = ?)",
                    "WHERE TaskStatus = 'Completed' AND (StaffId = ? OR StaffId = ?)");
            return query(sql, maTK, maNV);
        }
        String filterVal = resolveFilterValue(statusFilter);
        return query(SELECT_TASKS_SQL, filterVal, filterVal);
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
        try (Connection conn = DBContext.getConnection()) {
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
                if (rs.next())
                    return clean;
            }
        } catch (SQLException ignored) {
        }
        String sqlEmp = "SELECT AccountId FROM Employee WHERE EmployeeId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlEmp)) {
            ps.setString(1, clean);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getString("AccountId");
            }
        } catch (SQLException ignored) {
        }
        return "ACC004";
    }

    public HousekeeperTaskDTO getTaskById(String maNhiemVu) {
        return queryOne(SELECT_BY_ID_SQL, maNhiemVu).orElse(null);
    }

    private HousekeeperTaskDTO mapTaskRow(ResultSet rs) throws SQLException {
        HousekeeperTaskDTO dto = new HousekeeperTaskDTO();
        dto.setMaNhiemVu(rs.getString("TaskId"));
        dto.setMaPhong(rs.getString("RoomId"));
        dto.setSoPhong(rs.getString("RoomName"));
        dto.setTenLoaiPhong(rs.getString("RoomTypeName"));
        dto.setTrangThaiPhong(rs.getString("RoomStatus"));
        dto.setTrangThaiNhiemVu(rs.getString("TaskStatus"));
        dto.setMaNV(rs.getString("StaffId"));
        dto.setTenNV(rs.getString("StaffName"));
        dto.setThoiGianNhan(rs.getTimestamp("AssignedTime"));
        dto.setThoiGianBatDau(rs.getTimestamp("StartTime"));
        dto.setThoiGianKetThuc(rs.getTimestamp("EndTime"));
        dto.setKetQua(rs.getString("Result"));
        return dto;
    }
}
