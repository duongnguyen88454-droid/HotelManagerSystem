package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.booking.dto.CancellationRecordDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO truy vấn và xét duyệt hoàn tiền cọc hủy phòng cho Manager (CancellationHistory & fn_TinhTienHoanTraHuyPhong).
 */
public class ManagerRefundDAO extends DBContext {

    private static final String SELECT_CANCELLATIONS_SQL =
            "SELECT ch.CancellationId, ch.BookingId, ch.RoomId, r.RoomName, "
                    + "ISNULL(acc.UserName, ch.CancelledBy) AS CancelledBy, ch.DepositAtCancellation, "
                    + "ch.CancellationDate, ch.CancellationFee, ch.RefundStatus, ch.Reason, "
                    + "dbo.fn_TinhTienHoanTraHuyPhong(ch.CancellationId) AS RefundAmount "
                    + "FROM CancellationHistory ch "
                    + "INNER JOIN Room r ON ch.RoomId = r.RoomId "
                    + "LEFT JOIN Account acc ON ch.CancelledBy = acc.AccountId "
                    + "ORDER BY CASE ch.RefundStatus WHEN 'Pending' THEN 1 ELSE 2 END, ch.CancellationDate DESC";

    private static final String UPDATE_REFUND_STATUS_SQL =
            "UPDATE CancellationHistory SET RefundStatus = ? WHERE CancellationId = ?";

    public List<CancellationRecordDTO> getAllCancellationRequests() {
        List<CancellationRecordDTO> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_CANCELLATIONS_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToDTO(rs));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateRefundStatus(String cancellationId, String status) {
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(UPDATE_REFUND_STATUS_SQL)) {
            ps.setString(1, status);
            ps.setString(2, cancellationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private CancellationRecordDTO mapRowToDTO(ResultSet rs) throws SQLException {
        Timestamp ts = rs.getTimestamp("CancellationDate");
        LocalDateTime cancelDate = (ts != null) ? ts.toLocalDateTime() : null;
        BigDecimal deposit = rs.getBigDecimal("DepositAtCancellation");
        BigDecimal fee = rs.getBigDecimal("CancellationFee");
        BigDecimal refund = rs.getBigDecimal("RefundAmount");

        return new CancellationRecordDTO(
                rs.getString("CancellationId"),
                rs.getString("BookingId"),
                rs.getString("RoomId"),
                rs.getString("RoomName"),
                rs.getString("CancelledBy"),
                (deposit != null) ? deposit : BigDecimal.ZERO,
                cancelDate,
                (fee != null) ? fee : BigDecimal.ZERO,
                rs.getString("RefundStatus"),
                rs.getNString("Reason"),
                (refund != null) ? refund : BigDecimal.ZERO
        );
    }
}
