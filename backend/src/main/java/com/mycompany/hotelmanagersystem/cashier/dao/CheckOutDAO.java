package com.mycompany.hotelmanagersystem.cashier.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * DAO phụ trách thực thi thủ tục Check-out trả phòng (sp_CheckOut).
 */
public class CheckOutDAO {

    /**
     * Check-out toàn bộ các phòng còn lại trong đơn đặt phòng.
     *
     * @param maBooking Mã đơn đặt phòng
     * @param maNV      Mã nhân viên thực hiện
     * @return true nếu gọi thành công
     * @throws SQLException           nếu có lỗi truy vấn SQL
     * @throws ClassNotFoundException nếu thiếu driver JDBC
     */
    public boolean executeCheckOutAll(String maBooking, String maNV) throws SQLException, ClassNotFoundException {
        String sql = "{call sp_CheckOut(?, ?, NULL)}";
        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, maBooking);
            cs.setString(2, maNV);
            cs.execute();
            return true;
        }
    }

    /**
     * Check-out riêng lẻ một phòng cụ thể trong đơn (phục vụ multi-room).
     *
     * @param maBooking Mã đơn đặt phòng
     * @param maPhong   Mã phòng cần trả
     * @param maNV      Mã nhân viên thực hiện
     * @return true nếu gọi thành công
     * @throws SQLException           nếu có lỗi truy vấn SQL
     * @throws ClassNotFoundException nếu thiếu driver JDBC
     */
    public boolean executeCheckOutRoom(String maBooking, String maPhong, String maNV)
            throws SQLException, ClassNotFoundException {
        String sql = "{call sp_CheckOut(?, ?, ?)}";
        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, maBooking);
            cs.setString(2, maNV);
            cs.setString(3, maPhong);
            cs.execute();
            return true;
        }
    }
}
