package com.mycompany.hotelmanagersystem.cashier.dao;

import com.mycompany.hotelmanagersystem.cashier.dto.PaymentRecordDTO;
import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;

/**
 * DAO phụ trách thực thi nạp tiền (sp_GhiNhanThanhToan) và truy vấn lịch sử thanh toán.
 */
public class PaymentDAO extends BaseRepository<PaymentRecordDTO, String> {

    @Override
    protected String getTableName() {
        return "Payment";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "PaymentId";
    }

    @Override
    protected RowMapper<PaymentRecordDTO> getRowMapper() {
        return this::mapRowToPaymentRecord;
    }

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

    public List<PaymentRecordDTO> getPaymentHistory(String maHoaDon) {
        String sql = "SELECT p.PaymentId AS MaThanhToan, p.InvoiceId AS MaHoaDon, p.ProcessBy AS MaNV, " +
                     "       ISNULL(acc.Username, N'Khách Hàng') AS TenNV, p.TotalAmount AS SoTien, " +
                     "       p.PaymentMethod AS PhuongThucThanhToan, p.PaymentDate AS ThoiDiemThanhToan " +
                     "FROM Payment p " +
                     "LEFT JOIN Account acc ON p.ProcessBy = acc.AccountId " +
                     "WHERE p.InvoiceId = ? " +
                     "ORDER BY p.PaymentDate ASC";
        return query(sql, maHoaDon);
    }

    public double getTotalPaid(String maHoaDon) {
        String sql = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Payment WHERE InvoiceId = ?";
        String val = queryScalarString(sql, maHoaDon);
        return val != null ? Double.parseDouble(val) : 0.0;
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

