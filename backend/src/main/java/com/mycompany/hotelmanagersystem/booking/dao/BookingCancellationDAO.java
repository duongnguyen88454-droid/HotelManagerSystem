package com.mycompany.hotelmanagersystem.booking.dao;

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
 * DAO chuyên trách duy nhất nghiệp vụ Hủy phòng & Hủy đơn đặt phòng (Cancellation).
 * Tách biệt khỏi BookingDAO theo QT 2.1 trong ARCHITECTURE_RULES.md.
 */
public class BookingCancellationDAO {

    /**
     * Hủy một phòng cụ thể trong đơn qua Stored Procedure dbo.sp_HuyPhong.
     * CSDL sẽ kích hoạt Trigger 8 để giải phóng phòng Vacant và Trigger 5 để cập nhật lại hóa đơn.
     */
    public boolean cancelSingleRoom(String bookingId, String roomId, String cancelledBy, String reason)
            throws SQLException, ClassNotFoundException {
        String sql = "{call dbo.sp_HuyPhong(?, ?, ?, 0, ?, ?)}";
        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {

            cs.setString(1, bookingId);
            cs.setString(2, roomId);
            cs.setString(3, (cancelledBy != null && !cancelledBy.trim().isEmpty()) ? cancelledBy.trim() : "ACC002");
            cs.setString(4, (reason != null && !reason.trim().isEmpty()) ? reason.trim() : "Khách hàng hủy phòng");
            cs.registerOutParameter(5, Types.VARCHAR);

            cs.execute();
            return cs.getString(5) != null;
        }
    }

    /**
     * Hủy toàn bộ các phòng còn hiệu lực (Confirmed) trong đơn đặt phòng.
     * Tái sử dụng cancelSingleRoom trong 1 giao tác an toàn.
     */
    public boolean cancelAllRoomsInBooking(String bookingId, String cancelledBy, String reason)
            throws SQLException, ClassNotFoundException {
        List<String> confirmedRooms = getConfirmedRoomsInBooking(bookingId);
        if (confirmedRooms.isEmpty()) {
            return false;
        }

        for (String roomId : confirmedRooms) {
            boolean ok = cancelSingleRoom(bookingId, roomId, cancelledBy, reason);
            if (!ok) {
                return false;
            }
        }
        return true;
    }

    /**
     * Hàm phụ trợ lấy danh sách mã phòng đang Confirmed của một Booking.
     */
    public List<String> getConfirmedRoomsInBooking(String bookingId) throws SQLException, ClassNotFoundException {
        List<String> rooms = new ArrayList<>();
        String sql = "SELECT RoomId FROM Booking_Room WHERE BookingId = ? AND BookingStatus = 'Confirmed'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rooms.add(rs.getString("RoomId"));
                }
            }
        }
        return rooms;
    }
}
