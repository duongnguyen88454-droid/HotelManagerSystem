package com.mycompany.hotelmanagersystem.housekeeper.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageCategoryDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageDetailItemDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * DAO xử lý lập biên bản hư hại và truy vấn danh mục loại hư hại từ CSDL.
 */
public class DamageReportDAO extends DBContext {

    private static final String SELECT_CATEGORIES_SQL =
            "SELECT MaLoaiHuHai, TenLoaiHuHai, MoTa FROM LOAIHUHAI ORDER BY MaLoaiHuHai ASC";

    public List<DamageCategoryDTO> getAllDamageCategories() {
        List<DamageCategoryDTO> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_CATEGORIES_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DamageCategoryDTO(
                        rs.getString("MaLoaiHuHai"),
                        rs.getString("TenLoaiHuHai"),
                        rs.getString("MoTa")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void createDamageReportAndLockRoom(String maNhiemVu, String maNV, String moTaChung,
                                             List<DamageDetailItemDTO> damageItems)
            throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String maPhong = findRoomIdByTask(conn, maNhiemVu);
            if (maPhong == null) {
                throw new SQLException("Nhiệm vụ dọn phòng không tồn tại!");
            }

            updateTaskAndRoomToDamaged(conn, maNhiemVu, maNV, maPhong);

            String maBaoCao = "BC_" + UUID.randomUUID().toString().substring(0, 7).toUpperCase();
            insertDamageReport(conn, maBaoCao, maNhiemVu, moTaChung);
            insertDamageDetails(conn, maBaoCao, damageItems);

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

    private String findRoomIdByTask(Connection conn, String maNhiemVu) throws SQLException {
        String sql = "SELECT MaPhong FROM NHIEMVUDOPHONG WHERE MaNhiemVu = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maNhiemVu);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("MaPhong");
                }
            }
        }
        return null;
    }

    private void updateTaskAndRoomToDamaged(Connection conn, String maNhiemVu, String maNV, String maPhong)
            throws SQLException {
        String updateTaskSql = "UPDATE NHIEMVUDOPHONG SET ThoiGianKetThuc = GETDATE(), "
                + "TrangThai = 'HoanThanh', KetQua = 'CoThietHai', MaNV = ? WHERE MaNhiemVu = ?";
        try (PreparedStatement psTask = conn.prepareStatement(updateTaskSql)) {
            psTask.setString(1, maNV);
            psTask.setString(2, maNhiemVu);
            psTask.executeUpdate();
        }

        String updatePhongSql = "UPDATE PHONG SET TrangThai = 'Damaged' WHERE MaPhong = ?";
        try (PreparedStatement psP = conn.prepareStatement(updatePhongSql)) {
            psP.setString(1, maPhong);
            psP.executeUpdate();
        }
    }

    private void insertDamageReport(Connection conn, String maBaoCao, String maNhiemVu, String moTaChung)
            throws SQLException {
        String insertReportSql = "INSERT INTO BAOCAOHUHAI (MaBaoCao, MaNhiemVu, NgayPhatHien, MoTa, TrangThai) "
                + "VALUES (?, ?, GETDATE(), ?, 'ChoXuLy')";
        try (PreparedStatement psRep = conn.prepareStatement(insertReportSql)) {
            psRep.setString(1, maBaoCao);
            psRep.setString(2, maNhiemVu);
            psRep.setString(3, (moTaChung != null && !moTaChung.trim().isEmpty())
                    ? moTaChung.trim() : "Phát hiện sự cố hư hại thiết bị khi dọn phòng");
            psRep.executeUpdate();
        }
    }

    private void insertDamageDetails(Connection conn, String maBaoCao, List<DamageDetailItemDTO> items)
            throws SQLException {
        if (items == null || items.isEmpty()) {
            return;
        }
        String insertDetailSql = "INSERT INTO CHITIETBAOCAOHUHAI (MaBaoCao, MaLoaiHuHai, MoTaChiTiet) VALUES (?, ?, ?)";
        try (PreparedStatement psDet = conn.prepareStatement(insertDetailSql)) {
            for (DamageDetailItemDTO item : items) {
                psDet.setString(1, maBaoCao);
                psDet.setString(2, item.getMaLoaiHuHai());
                psDet.setString(3, (item.getMoTaChiTiet() != null && !item.getMoTaChiTiet().trim().isEmpty())
                        ? item.getMoTaChiTiet().trim() : "Cần bảo trì thay thế");
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
