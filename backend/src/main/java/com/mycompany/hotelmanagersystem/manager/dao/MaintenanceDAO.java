package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.DamagedRoomItemDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

public class MaintenanceDAO extends BaseRepository<DamagedRoomItemDTO, String> {

    private static final String SELECT_PENDING_DAMAGES_SQL =
            "SELECT ReportId, RoomId, RoomName, RoomTypeName, DetectedAt, "
                    + "DamageTypeName, DamageDescription, ReportStatus, ReportedBy "
                    + "FROM v_MaintenancePendingRooms ORDER BY DetectedAt DESC";

    private static final String UPDATE_REPORT_STATUS_SQL =
            "UPDATE DamageReport SET DamageReportStatus = 'Resolved' WHERE DamageReportId = ?";

    private static final String UPDATE_ROOM_AVAILABLE_SQL =
            "UPDATE Room SET RoomStatus = 'Available' WHERE RoomId = ?";

    @Override
    protected String getTableName() {
        return "v_MaintenancePendingRooms";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "ReportId";
    }

    @Override
    protected RowMapper<DamagedRoomItemDTO> getRowMapper() {
        return this::mapResultSetToDTO;
    }

    @Override
    protected String getRole() {
        return "Manager";
    }

    public List<DamagedRoomItemDTO> getPendingDamagedRooms() {
        return query(SELECT_PENDING_DAMAGES_SQL);
    }

    public boolean resolveDamagedRoom(String maBaoCao, String maPhong) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection(getRole());
            conn.setAutoCommit(false);

            try (PreparedStatement psReport = conn.prepareStatement(UPDATE_REPORT_STATUS_SQL);
                 PreparedStatement psRoom = conn.prepareStatement(UPDATE_ROOM_AVAILABLE_SQL)) {
                psReport.setString(1, maBaoCao);
                psReport.executeUpdate();

                psRoom.setString(1, maPhong);
                psRoom.executeUpdate();

                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                ex.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            closeQuietly(conn);
        }
    }

    private DamagedRoomItemDTO mapResultSetToDTO(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("DetectedAt");
        LocalDateTime ldt = (ts != null) ? ts.toLocalDateTime() : null;
        return new DamagedRoomItemDTO(
                rs.getString("ReportId"),
                rs.getString("RoomId"),
                rs.getString("RoomName"),
                rs.getString("RoomTypeName"),
                ldt,
                rs.getString("DamageTypeName"),
                rs.getString("DamageDescription"),
                rs.getString("ReportStatus"),
                rs.getString("ReportedBy")
        );
    }

    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ignore) {
            }
        }
    }
}

