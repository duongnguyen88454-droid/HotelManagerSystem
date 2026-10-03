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
     * Ghi nhận một đợt thanh toán/đặt cọc mới qua thủ tục sp_GhiNhanThanhToan.
     */
    public String recordPayment(String maHoaDon, String maNV, double soTien, String phuongThuc)
            throws SQLException, ClassNotFoundException {
        String sql = "{call sp_GhiNhanThanhToan(?, ?, ?, ?, ?)}";
        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, maHoaDon);
            cs.setString(2, maNV);
            cs.setDouble(3, soTien);
            cs.setString(4, phuongThuc);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.execute();
            return cs.getString(5);
        }
    }

    /**
     * Lấy toàn bộ lịch sử các đợt nạp tiền/thanh toán của một hóa đơn.
     */
    public List<PaymentRecordDTO> getPaymentHistory(String maHoaDon) throws SQLException, ClassNotFoundException {
        List<PaymentRecordDTO> list = new ArrayList<>();
        String sql = "SELECT tt.MaThanhToan, tt.MaHoaDon, tt.MaNV, nv.HoTen AS TenNV, " +
                     "       tt.SoTien, tt.PhuongThucThanhToan, tt.ThoiDiemThanhToan " +
                     "FROM THANHTOAN tt " +
                     "LEFT JOIN NHANVIEN nv ON tt.MaNV = nv.MaNV " +
                     "WHERE tt.MaHoaDon = ? " +
                     "ORDER BY tt.ThoiDiemThanhToan ASC";
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
        String sql = "SELECT ISNULL(SUM(SoTien), 0) AS TongDaTra FROM THANHTOAN WHERE MaHoaDon = ?";
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
