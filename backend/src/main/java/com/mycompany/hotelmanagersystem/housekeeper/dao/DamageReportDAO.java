package com.mycompany.hotelmanagersystem.housekeeper.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageCategoryDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageDetailItemDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

public class DamageReportDAO extends BaseRepository<DamageCategoryDTO, String> {

    private static final String SELECT_CATEGORIES_SQL = "SELECT DamageTypeId, DamageName FROM DamageType ORDER BY DamageTypeId ASC";

    @Override
    protected String getTableName() {
        return "DamageType";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "DamageTypeId";
    }

    @Override
    protected RowMapper<DamageCategoryDTO> getRowMapper() {
        return rs -> new DamageCategoryDTO(
                rs.getString("DamageTypeId"),
                rs.getString("DamageName"),
                rs.getString("DamageName"));
    }

    @Override
    protected String getRole() {
        return "Housekeeper";
    }

    public List<DamageCategoryDTO> getAllDamageCategories() {
        return query(SELECT_CATEGORIES_SQL);
    }

    public void createDamageReportAndLockRoom(String maNhiemVu, String maNV, String moTaChung,
            List<DamageDetailItemDTO> damageItems)
            throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection(getRole());
            conn.setAutoCommit(false);

            String maPhong = findRoomIdByTask(conn, maNhiemVu);
            if (maPhong == null) {
                throw new SQLException("Nhiệm vụ dọn phòng không tồn tại!");
            }

            String accountId = resolveAccountId(conn, maNV);
            updateTaskAndRoomToDamaged(conn, maNhiemVu, accountId, maPhong);

            String maBaoCao = "DR" + UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
            insertDamageReport(conn, maBaoCao, maPhong, accountId);
            insertDamageDetails(conn, maBaoCao, moTaChung, damageItems);

            conn.commit();
        } catch (Exception e) {
            rollbackQuietly(conn);
            if (e instanceof SQLException) {
                throw (SQLException) e;
            }
            throw new SQLException("Lỗi khi lập biên bản hư hại: " + e.getMessage(), e);
        } finally {
            closeQuietly(conn);
        }
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
                if (rs.next()) {
                    return clean;
                }
            }
        } catch (SQLException ignored) {
        }
        String sqlEmp = "SELECT AccountId FROM Employee WHERE EmployeeId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlEmp)) {
            ps.setString(1, clean);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("AccountId");
                }
            }
        } catch (SQLException ignored) {
        }
        return "ACC004";
    }

    private String findRoomIdByTask(Connection conn, String maNhiemVu) throws SQLException {
        String sql = "SELECT RoomId FROM RoomCleaningTask WHERE RoomCleaningTaskId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maNhiemVu);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("RoomId");
                }
            }
        }
        return null;
    }

    private void updateTaskAndRoomToDamaged(Connection conn, String maNhiemVu, String accountId, String maPhong)
            throws SQLException {
        String updateTaskSql = "UPDATE RoomCleaningTask SET EndTime = GETDATE(), "
                + "RoomCleaningTaskStatus = 'Completed', Result = N'Có thiệt hại', ReceivedBy = ? "
                + "WHERE RoomCleaningTaskId = ?";
        try (PreparedStatement psTask = conn.prepareStatement(updateTaskSql)) {
            psTask.setString(1, accountId);
            psTask.setString(2, maNhiemVu);
            psTask.executeUpdate();
        }

        String updatePhongSql = "UPDATE Room SET RoomStatus = 'Maintenance' WHERE RoomId = ?";
        try (PreparedStatement psP = conn.prepareStatement(updatePhongSql)) {
            psP.setString(1, maPhong);
            psP.executeUpdate();
        }
    }

    private void insertDamageReport(Connection conn, String maBaoCao, String maPhong, String accountId)
            throws SQLException {
        String insertReportSql = "INSERT INTO DamageReport (DamageReportId, RoomId, CreateBy, "
                + "DetectedAt, ConfirmedAt, DamageReportStatus) VALUES (?, ?, ?, GETDATE(), GETDATE(), 'Confirmed')";
        try (PreparedStatement psRep = conn.prepareStatement(insertReportSql)) {
            psRep.setString(1, maBaoCao);
            psRep.setString(2, maPhong);
            psRep.setString(3, accountId);
            psRep.executeUpdate();
        }
    }

    private void insertDamageDetails(Connection conn, String maBaoCao, String moTaChung,
            List<DamageDetailItemDTO> items)
            throws SQLException {
        if (items == null || items.isEmpty()) {
            return;
        }
        String insertDetailSql = "INSERT INTO DamageReport_DamageType (DamageReportId, DamageTypeId, Note) "
                + "VALUES (?, ?, ?)";
        try (PreparedStatement psDet = conn.prepareStatement(insertDetailSql)) {
            for (DamageDetailItemDTO item : items) {
                psDet.setString(1, maBaoCao);
                psDet.setString(2, item.getMaLoaiHuHai());
                String note = (item.getMoTaChiTiet() != null && !item.getMoTaChiTiet().trim().isEmpty())
                        ? item.getMoTaChiTiet().trim()
                        : moTaChung;
                psDet.setString(3, (note != null && !note.isEmpty()) ? note : "Cần bảo trì");
                psDet.addBatch();
            }
            psDet.executeBatch();
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
