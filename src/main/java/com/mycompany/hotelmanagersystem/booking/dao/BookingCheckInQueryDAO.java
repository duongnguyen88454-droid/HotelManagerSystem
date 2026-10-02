package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.CheckInArrivalItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInRoomDetailDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO chuyên trách các truy vấn đọc dữ liệu phục vụ Quầy Tiếp Đón Check-in (QT 2.1).
 */
public class BookingCheckInQueryDAO {

    /**
     * Lấy danh sách các đơn đặt phòng chờ tiếp nhận tại quầy.
     */
    public List<CheckInArrivalItemDTO> getArrivalBookings(String hoTen, String cccd, String maBK) {
        List<CheckInArrivalItemDTO> list = new ArrayList<>();
        boolean hasHoTen = hoTen != null && !hoTen.trim().isEmpty();
        boolean hasCccd  = cccd  != null && !cccd.trim().isEmpty();
        boolean hasMaBK  = maBK  != null && !maBK.trim().isEmpty();
        String sql = buildArrivalQuerySql(hasHoTen, hasCccd, hasMaBK);

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            if (hasHoTen) {
                ps.setString(idx++, "%" + hoTen.trim() + "%");
            }
            if (hasCccd) {
                ps.setString(idx++, cccd.trim());
            }
            if (hasMaBK) {
                ps.setString(idx++, "%" + maBK.trim() + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToArrivalDTO(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    private String buildArrivalQuerySql(boolean hasHoTen, boolean hasCccd, boolean hasMaBK) {
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT b.MaBooking, kh.HoTen, kh.SoDT, kh.CCCD, ");
        sb.append("       MIN(bp.NgayNhanDuKien) AS NgayNhan, MAX(bp.NgayTraDuKien) AS NgayTra, ");
        sb.append("       COUNT(bp.MaPhong) AS TongSoPhong, ");
        sb.append("       COUNT(CASE WHEN bp.NgayCheckInThucTe IS NOT NULL THEN 1 END) AS SoPhongDaNhan ");
        sb.append("FROM BOOKING b ");
        sb.append("INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH ");
        sb.append("INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking ");
        sb.append("WHERE b.TrangThai IN ('DaXacNhan', 'DaCheckIn') ");
        // Bộ lọc độc lập: HoTen (LIKE), CCCD (khớp chính xác), MaBooking (LIKE)
        if (hasHoTen) {
            sb.append("AND kh.HoTen LIKE ? ");
        }
        if (hasCccd) {
            sb.append("AND kh.CCCD = ? ");
        }
        if (hasMaBK) {
            sb.append("AND b.MaBooking LIKE ? ");
        }
        sb.append("GROUP BY b.MaBooking, kh.HoTen, kh.SoDT, kh.CCCD ");
        sb.append("ORDER BY MIN(bp.NgayNhanDuKien) ASC, b.MaBooking ASC");
        return sb.toString();
    }

    private CheckInArrivalItemDTO mapRowToArrivalDTO(ResultSet rs) throws SQLException {
        Date inSql = rs.getDate("NgayNhan");
        Date outSql = rs.getDate("NgayTra");
        LocalDate inDate = inSql != null ? inSql.toLocalDate() : null;
        LocalDate outDate = outSql != null ? outSql.toLocalDate() : null;

        return new CheckInArrivalItemDTO(
                rs.getString("MaBooking"),
                rs.getString("HoTen"),
                rs.getString("SoDT"),
                rs.getString("CCCD"),
                inDate,
                outDate,
                rs.getInt("TongSoPhong"),
                rs.getInt("SoPhongDaNhan")
        );
    }

    /**
     * Lấy thông tin chi tiết một đơn đặt phòng kèm các phòng và dịch vụ đã đặt trước.
     */
    public CheckInDetailDTO getBookingCheckInDetail(String maBooking) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }

        try (Connection conn = DBContext.getConnection()) {
            CheckInDetailDTO dto = fetchBookingHeader(conn, maBooking.trim());
            if (dto == null) {
                return null;
            }
            List<CheckInRoomDetailDTO> rooms = fetchRoomsForBooking(conn, maBooking.trim());
            Map<String, List<String>> servicesMap = fetchServicesByRoom(conn, maBooking.trim());

            for (CheckInRoomDetailDTO r : rooms) {
                List<String> svcs = servicesMap.get(r.getMaPhong());
                if (svcs != null && !svcs.isEmpty()) {
                    r.setDanhSachDichVu(svcs);
                }
            }
            dto.setDanhSachPhong(rooms);
            return dto;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    private CheckInDetailDTO fetchBookingHeader(Connection conn, String maBooking) throws SQLException {
        String sql = "SELECT b.MaBooking, kh.HoTen, kh.SoDT, kh.CCCD, kh.Email, "
                   + "       MIN(bp.NgayNhanDuKien) AS NgayNhan, MAX(bp.NgayTraDuKien) AS NgayTra "
                   + "FROM BOOKING b "
                   + "INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH "
                   + "INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking "
                   + "WHERE b.MaBooking = ? "
                   + "GROUP BY b.MaBooking, kh.HoTen, kh.SoDT, kh.CCCD, kh.Email";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Date inSql = rs.getDate("NgayNhan");
                    Date outSql = rs.getDate("NgayTra");
                    return new CheckInDetailDTO(
                            rs.getString("MaBooking"),
                            rs.getString("HoTen"),
                            rs.getString("SoDT"),
                            rs.getString("CCCD"),
                            rs.getString("Email"),
                            inSql != null ? inSql.toLocalDate() : null,
                            outSql != null ? outSql.toLocalDate() : null
                    );
                }
            }
        }
        return null;
    }

    private List<CheckInRoomDetailDTO> fetchRoomsForBooking(Connection conn, String maBooking)
            throws SQLException {
        List<CheckInRoomDetailDTO> rooms = new ArrayList<>();
        String sql = "SELECT bp.MaPhong, p.SoPhong, lp.TenLoaiPhong, p.TrangThai AS TrangThaiBuong, "
                   + "       bp.NgayCheckInThucTe "
                   + "FROM BOOKING_PHONG bp "
                   + "INNER JOIN PHONG p ON bp.MaPhong = p.MaPhong "
                   + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                   + "WHERE bp.MaBooking = ? "
                   + "ORDER BY p.SoPhong ASC";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp ts = rs.getTimestamp("NgayCheckInThucTe");
                    String actualInStr = (ts != null) ? sdf.format(ts) : null;
                    rooms.add(new CheckInRoomDetailDTO(
                            rs.getString("MaPhong"),
                            rs.getString("SoPhong"),
                            rs.getString("TenLoaiPhong"),
                            rs.getString("TrangThaiBuong"),
                            actualInStr
                    ));
                }
            }
        }
        return rooms;
    }

    private Map<String, List<String>> fetchServicesByRoom(Connection conn, String maBooking)
            throws SQLException {
        Map<String, List<String>> map = new HashMap<>();
        String sql = "SELECT bdv.MaPhong, dv.TenDichVu, bdv.SoLuong "
                   + "FROM BOOKING_DICHVU bdv "
                   + "INNER JOIN DICHVU dv ON bdv.MaDichVu = dv.MaDichVu "
                   + "WHERE bdv.MaBooking = ? "
                   + "ORDER BY bdv.MaPhong ASC, dv.TenDichVu ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String maPhong = rs.getString("MaPhong");
                    String text = "- " + rs.getString("TenDichVu") + " (x" + rs.getInt("SoLuong") + ")";
                    map.computeIfAbsent(maPhong, k -> new ArrayList<>()).add(text);
                }
            }
        }
        return map;
    }
}
