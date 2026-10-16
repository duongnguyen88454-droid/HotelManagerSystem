package com.mycompany.hotelmanagersystem.hotelservice.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.hotelservice.dto.RoomServiceUsageDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderRequestDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderResultDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * DAO chuyên trách ghi nhận và tra cứu dịch vụ phòng lưu trú (Phase 3 FN-3.4 & FN-3.5).
 * Tách biệt hoàn toàn khỏi BookingDAO theo QT 2.1 và QT 5.2.
 */
public class RoomServiceOrderDAO extends BaseRepository<RoomServiceUsageDTO, String> {

    @Override
    protected String getTableName() {
        return "Booking_Room_Service";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "BookingId";
    }

    @Override
    protected RowMapper<RoomServiceUsageDTO> getRowMapper() {
        return this::mapRowToUsage;
    }

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

            Double totalServiceCost = queryScalarDouble(
                    "SELECT ISNULL(SUM(UnitPrice * Quantity), 0) FROM Booking_Room_Service WHERE BookingId = ?",
                    req.getMaBooking());
            double total = totalServiceCost != null ? totalServiceCost : 0.0;
            String orderRef = req.getMaPhong() + "-" + req.getMaDichVu();

            return ServiceOrderResultDTO.success("Thêm dịch vụ tại phòng thành công!",
                    orderRef, total);

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
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT brs.BookingId, brs.RoomId, brs.ServiceId, s.ServiceName AS TenDichVu, ")
           .append("       brs.UnitPrice AS DonGia, brs.Quantity AS SoLuong, ")
           .append("       (brs.UnitPrice * brs.Quantity) AS ThanhTien ")
           .append("FROM Booking_Room_Service brs ")
           .append("INNER JOIN Service s ON brs.ServiceId = s.ServiceId ")
           .append("WHERE brs.BookingId = ? ");

        boolean hasRoom = maPhong != null && !maPhong.trim().isEmpty();
        if (hasRoom) {
            sql.append("  AND brs.RoomId = ? ");
        }
        sql.append("ORDER BY s.ServiceName ASC");

        if (hasRoom) {
            return query(sql.toString(), maBooking, maPhong.trim());
        }
        return query(sql.toString(), maBooking);
    }

    /**
     * Tìm mã Booking đang lưu trú (CheckedIn) của một phòng cụ thể.
     */
    public String findActiveBookingByRoom(String maPhong) {
        String sql = "SELECT TOP 1 br.BookingId "
                   + "FROM Booking_Room br "
                   + "WHERE br.RoomId = ? AND br.BookingStatus = 'CheckedIn' "
                   + "ORDER BY br.ActualCheckInDate DESC";
        return queryScalarString(sql, maPhong);
    }

    private RoomServiceUsageDTO mapRowToUsage(ResultSet rs) throws SQLException {
        return new RoomServiceUsageDTO(
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
    }
}
