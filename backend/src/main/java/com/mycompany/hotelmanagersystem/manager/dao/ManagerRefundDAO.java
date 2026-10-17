package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.booking.dto.CancellationRecordDTO;
import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DAO truy vấn và xét duyệt hoàn tiền cọc hủy phòng cho Manager (CancellationHistory & fn_TinhTienHoanTraHuyPhong).
 */
public class ManagerRefundDAO extends BaseRepository<CancellationRecordDTO, String> {

    private static final String SELECT_CANCELLATIONS_SQL =
            "SELECT * FROM v_RefundRequests "
                    + "ORDER BY CASE RefundStatus WHEN 'Pending' THEN 1 ELSE 2 END, CancellationDate DESC";

    private static final String UPDATE_REFUND_STATUS_SQL =
            "UPDATE CancellationHistory SET RefundStatus = ? WHERE CancellationId = ?";

    @Override
    protected String getTableName() {
        return "v_RefundRequests";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "CancellationId";
    }

    @Override
    protected RowMapper<CancellationRecordDTO> getRowMapper() {
        return this::mapRowToDTO;
    }

    @Override
    protected String getRole() {
        return "Manager";
    }

    public List<CancellationRecordDTO> getAllCancellationRequests() {
        return query(SELECT_CANCELLATIONS_SQL);
    }

    public boolean updateRefundStatus(String cancellationId, String status) {
        return executeUpdate(UPDATE_REFUND_STATUS_SQL, status, cancellationId) > 0;
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

