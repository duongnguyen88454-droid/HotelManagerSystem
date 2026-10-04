package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.DamagedRoomItemDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceDAO extends DBContext {

    private static final String SELECT_PENDING_DAMAGES_SQL =
            "SELECT MaBaoCao, MaPhong, SoPhong, TenLoaiPhong, NgayPhatHien, "
                    + "TenLoaiHuHai, MoTaChiTiet, TrangThaiBaoCao, NhanVienPhatHien "
                    + "FROM v_DanhSachPhongHuHaiCanBaoTri ORDER BY NgayPhatHien DESC";

    private static final String UPDATE_REPORT_STATUS_SQL =
            "UPDATE BAOCAOHUHAI SET TrangThai = 'DaXuLy' WHERE MaBaoCao = ?";

    private static final String UPDATE_ROOM_AVAILABLE_SQL =
            "UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = ?";

    public List<DamagedRoomItemDTO> getPendingDamagedRooms() {
        List<DamagedRoomItemDTO> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_PENDING_DAMAGES_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDTO(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean resolveDamagedRoom(String maBaoCao, String maPhong) {
        Connection conn = null;
        try {
            conn = getConnection();
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

    private DamagedRoomItemDTO mapResultSetToDTO(ResultSet rs) throws Exception {
        Timestamp ts = rs.getTimestamp("NgayPhatHien");
        LocalDateTime ldt = (ts != null) ? ts.toLocalDateTime() : null;
        return new DamagedRoomItemDTO(
                rs.getString("MaBaoCao"),
                rs.getString("MaPhong"),
                rs.getString("SoPhong"),
                rs.getString("TenLoaiPhong"),
                ldt,
                rs.getString("TenLoaiHuHai"),
                rs.getString("MoTaChiTiet"),
                rs.getString("TrangThaiBaoCao"),
                rs.getString("NhanVienPhatHien")
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
