package com.mycompany.hotelmanagersystem.hotelservice.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.hotelservice.dto.RoomServiceUsageDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderRequestDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderResultDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO chuyên trách ghi nhận và tra cứu dịch vụ phòng lưu trú (Phase 3 FN-3.4 & FN-3.5).
 * Tách biệt hoàn toàn khỏi BookingDAO theo QT 2.1 và QT 5.2.
 */
public class RoomServiceOrderDAO {

    /**
     * Gọi Stored Procedure sp_GoiThemDichVu để thêm dịch vụ vào đơn đặt phòng.
     */
    public ServiceOrderResultDTO executeOrderService(ServiceOrderRequestDTO req) {
        String callSql = "{CALL dbo.sp_GoiThemDichVu(?, ?, ?, ?)}";

        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {

            cs.setString(1, req.getMaBooking());
            cs.setString(2, req.getMaPhong() != null ? req.getMaPhong().trim() : null);
            cs.setString(3, req.getMaDichVu() != null ? req.getMaDichVu().trim() : null);
            cs.setInt(4, req.getSoLuong());

            cs.execute();

            double totalServiceCost = calculateTotalServiceCost(conn, req.getMaBooking());
            String orderRef = req.getMaPhong() + "-" + req.getMaDichVu();

            return ServiceOrderResultDTO.success("Thêm dịch vụ tại phòng thành công!",
                    orderRef, totalServiceCost);

        } catch (SQLException e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("!")) {
                int start = msg.lastIndexOf(":");
                if (start >= 0 && start < msg.length() - 1) {
                    msg = msg.substring(start + 1).trim();
                }
            }
            return ServiceOrderResultDTO.failure(msg != null ? msg : "Lỗi hệ thống khi gọi dịch vụ!");
        } catch (ClassNotFoundException e) {
            return ServiceOrderResultDTO.failure("Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
        }
    }

    /**
     * Truy vấn toàn bộ dịch vụ đã sử dụng trong đơn đặt phòng (tùy chọn lọc theo phòng).
     */
    public List<RoomServiceUsageDTO> getServicesUsedByBooking(String maBooking, String maPhong) {
        List<RoomServiceUsageDTO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT brs.BookingId, brs.RoomId, brs.ServiceId, s.ServiceName AS TenDichVu, ")
           .append("       brs.UnitPrice AS DonGia, brs.Quantity AS SoLuong, ")
           .append("       (brs.UnitPrice * brs.Quantity) AS ThanhTien ")
           .append("FROM Booking_Room_Service brs ")
           .append("INNER JOIN Service s ON brs.ServiceId = s.ServiceId ")
           .append("WHERE brs.BookingId = ? ");

        if (maPhong != null && !maPhong.trim().isEmpty()) {
            sql.append("  AND brs.RoomId = ? ");
        }
        sql.append("ORDER BY s.ServiceName ASC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setString(1, maBooking);
            if (maPhong != null && !maPhong.trim().isEmpty()) {
                ps.setString(2, maPhong.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomServiceUsageDTO item = new RoomServiceUsageDTO(
                            rs.getString("RoomId") + "-" + rs.getString("ServiceId"),
                            rs.getString("ServiceId"),
                            rs.getNString("TenDichVu"),
                            rs.getDouble("DonGia"),
                            rs.getInt("SoLuong"),
                            rs.getDouble("ThanhTien"),
                            null,
                            "Lễ tân",
                            "NV001"
                    );
                    list.add(item);
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm mã Booking đang lưu trú (CheckedIn) của một phòng cụ thể.
     */
    public String findActiveBookingByRoom(String maPhong) {
        String sql = "SELECT TOP 1 br.BookingId "
                   + "FROM Booking_Room br "
                   + "WHERE br.RoomId = ? AND br.BookingStatus = 'CheckedIn' "
                   + "ORDER BY br.ActualCheckInDate DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("BookingId");
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tính tổng chi phí dịch vụ hiện tại của đơn booking.
     */
    private double calculateTotalServiceCost(Connection conn, String maBooking) throws SQLException {
        String sumSql = "SELECT ISNULL(SUM(UnitPrice * Quantity), 0) AS TongTienDV "
                      + "FROM Booking_Room_Service WHERE BookingId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sumSql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("TongTienDV");
                }
            }
        }
        return 0;
    }
}
