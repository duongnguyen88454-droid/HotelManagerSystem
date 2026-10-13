package com.mycompany.hotelmanagersystem.cashier.dao;

import com.mycompany.hotelmanagersystem.cashier.dto.PaymentRecordDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO phụ trách thực thi nạp tiền (sp_GhiNhanThanhToan) và truy vấn lịch sử thanh toán.
 */
public class PaymentDAO {

    /**
     * Ghi nhận một đợt thanh toán/đặt cọc mới qua thủ tục dbo.sp_GhiNhanThanhToan.
     */
    public String recordPayment(String maHoaDon, String maTaiKhoan, double soTien, String phuongThuc)
            throws SQLException, ClassNotFoundException {
        String sql = "{call dbo.sp_GhiNhanThanhToan(?, ?, ?, ?, ?, ?)}";
        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, maHoaDon);
            String validAccountId = resolveValidAccountId(conn, maTaiKhoan);
            if (validAccountId != null) {
                cs.setString(2, validAccountId);
            } else {
                cs.setNull(2, Types.VARCHAR);
            }
            cs.setDouble(3, soTien);
            cs.setString(4, phuongThuc != null ? phuongThuc : "Cash");
            cs.setString(5, "Thanh toan tai quay thu ngan");
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.execute();
            return cs.getString(6);
        }
    }

    private String resolveValidAccountId(Connection conn, String accountOrEmpId) {
        if (accountOrEmpId == null || accountOrEmpId.trim().isEmpty()) {
            return null;
        }
        String cleanId = accountOrEmpId.trim();
        String checkAccSql = "SELECT AccountId FROM Account WHERE AccountId = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkAccSql)) {
            ps.setString(1, cleanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return cleanId;
                }
            }
        } catch (SQLException ignored) {
        }

        String findByEmpSql = "SELECT AccountId FROM Employee WHERE EmployeeId = ?";
        try (PreparedStatement ps = conn.prepareStatement(findByEmpSql)) {
            ps.setString(1, cleanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("AccountId");
                }
            }
        } catch (SQLException ignored) {
        }
        return null;
    }

    /**
     * Lấy toàn bộ lịch sử các đợt nạp tiền/thanh toán của một hóa đơn.
     */
    public List<PaymentRecordDTO> getPaymentHistory(String maHoaDon) throws SQLException, ClassNotFoundException {
        List<PaymentRecordDTO> list = new ArrayList<>();
        String sql = "SELECT p.PaymentId AS MaThanhToan, p.InvoiceId AS MaHoaDon, p.ProcessBy AS MaNV, " +
                     "       ISNULL(acc.Username, N'Khách Hàng') AS TenNV, p.TotalAmount AS SoTien, " +
                     "       p.PaymentMethod AS PhuongThucThanhToan, p.PaymentDate AS ThoiDiemThanhToan " +
                     "FROM Payment p " +
                     "LEFT JOIN Account acc ON p.ProcessBy = acc.AccountId " +
                     "WHERE p.InvoiceId = ? " +
                     "ORDER BY p.PaymentDate ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maHoaDon);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToPaymentRecord(rs));
                }
            }
        }
        return list;
    }

    /**
     * Lấy tổng số tiền đã thanh toán cho một hóa đơn.
     */
    public double getTotalPaid(String maHoaDon) throws SQLException, ClassNotFoundException {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) AS TongDaTra FROM Payment WHERE InvoiceId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maHoaDon);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("TongDaTra");
                }
            }
        }
        return 0.0;
    }

    private PaymentRecordDTO mapRowToPaymentRecord(ResultSet rs) throws SQLException {
        return new PaymentRecordDTO(
                rs.getString("MaThanhToan"),
                rs.getString("MaHoaDon"),
                rs.getString("MaNV"),
                rs.getString("TenNV"),
                rs.getDouble("SoTien"),
                rs.getString("PhuongThucThanhToan"),
                rs.getTimestamp("ThoiDiemThanhToan")
        );
    }
}
