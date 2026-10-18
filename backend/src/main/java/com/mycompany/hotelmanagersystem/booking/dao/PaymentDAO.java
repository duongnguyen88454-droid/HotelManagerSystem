package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

/**
 * DAO chuyên trách các giao dịch liên quan đến bảng Payment theo QT 2.1.
 */
public class PaymentDAO extends BaseRepository<Object, String> {

    @Override
    protected String getTableName() {
        return "Payment";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "PaymentId";
    }

    @Override
    protected RowMapper<Object> getRowMapper() {
        return rs -> null;
    }

    @Override
    protected String getRole() {
        return "Customer";
    }

    /**
     * Xác nhận thanh toán tiền đặt cọc giữ chỗ qua Stored Procedure sp_XacNhanThanhToanCoc.
     *
     * @param bookingId mã booking cần nộp cọc
     * @param paymentMethod phương thức thanh toán (BankTransfer, Momo, VNPay)
     * @param note ghi chú thanh toán
     * @return mã PaymentId được sinh ra
     * @throws SQLException nếu xảy ra lỗi CSDL
     * @throws ClassNotFoundException nếu không tìm thấy driver
     */
    public String confirmDepositPaymentSP(String bookingId, String paymentMethod, String note)
            throws SQLException, ClassNotFoundException {
        String sql = "{call dbo.sp_XacNhanThanhToanCoc(?, ?, ?, ?)}";
        try (Connection conn = DBContext.getConnection(getRole());
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, bookingId);
            cs.setString(2, (paymentMethod != null && !paymentMethod.trim().isEmpty())
                    ? paymentMethod.trim() : "BankTransfer");
            cs.setString(3, (note != null && !note.trim().isEmpty())
                    ? note.trim() : "Khách hàng thanh toán tiền cọc online");
            cs.registerOutParameter(4, Types.VARCHAR);

            cs.execute();
            return cs.getString(4);
        }
    }
}
