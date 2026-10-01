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
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
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
        String callSql = "{CALL sp_GoiThemDichVu(?, ?, ?, ?, ?, ?, ?)}";

        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(callSql)) {

            cs.setString(1, req.getMaBooking());
            if (req.getMaPhong() != null && !req.getMaPhong().trim().isEmpty()) {
                cs.setString(2, req.getMaPhong().trim());
            } else {
                cs.setNull(2, Types.VARCHAR);
            }
            cs.setString(3, req.getMaDichVu());
            cs.setInt(4, req.getSoLuong());
            cs.setString(5, "NhanVien");

            if (req.getMaNV() != null && !req.getMaNV().trim().isEmpty()) {
                cs.setString(6, req.getMaNV().trim());
            } else {
                cs.setNull(6, Types.VARCHAR);
            }

            cs.registerOutParameter(7, Types.VARCHAR);
            cs.execute();

            String newBookingDichVuId = cs.getString(7);
            double totalServiceCost = calculateTotalServiceCost(conn, req.getMaBooking());

            return ServiceOrderResultDTO.success("Thêm dịch vụ tại phòng thành công!",
                    newBookingDichVuId, totalServiceCost);

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
        sql.append("SELECT bdv.MaBookingDichVu, bdv.MaDichVu, dv.TenDichVu, bdv.DonGia, bdv.SoLuong, ")
           .append("       (bdv.DonGia * bdv.SoLuong) AS ThanhTien, bdv.ThoiDiemThem, bdv.NguoiThem, bdv.MaNV ")
           .append("FROM BOOKING_DICHVU bdv ")
           .append("INNER JOIN DICHVU dv ON bdv.MaDichVu = dv.MaDichVu ")
           .append("WHERE bdv.MaBooking = ? ");

        if (maPhong != null && !maPhong.trim().isEmpty()) {
            sql.append("  AND (bdv.MaPhong = ? OR bdv.MaPhong IS NULL) ");
        }
        sql.append("ORDER BY bdv.ThoiDiemThem DESC");

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setString(1, maBooking);
            if (maPhong != null && !maPhong.trim().isEmpty()) {
                ps.setString(2, maPhong.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp ts = rs.getTimestamp("ThoiDiemThem");
                    LocalDateTime time = ts != null ? ts.toLocalDateTime() : null;

                    RoomServiceUsageDTO item = new RoomServiceUsageDTO(
                            rs.getString("MaBookingDichVu"),
                            rs.getString("MaDichVu"),
                            rs.getNString("TenDichVu"),
                            rs.getDouble("DonGia"),
                            rs.getInt("SoLuong"),
                            rs.getDouble("ThanhTien"),
                            time,
                            rs.getString("NguoiThem"),
                            rs.getString("MaNV")
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
     * Tìm mã Booking đang lưu trú (DaCheckIn) của một phòng cụ thể.
     */
    public String findActiveBookingByRoom(String maPhong) {
        String sql = "SELECT TOP 1 bp.MaBooking "
                   + "FROM BOOKING_PHONG bp "
                   + "INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking "
                   + "WHERE bp.MaPhong = ? AND b.TrangThai = 'DaCheckIn' "
                   + "ORDER BY bp.NgayNhanDuKien DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("MaBooking");
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
        String sumSql = "SELECT ISNULL(SUM(DonGia * SoLuong), 0) AS TongTienDV "
                      + "FROM BOOKING_DICHVU WHERE MaBooking = ?";
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
