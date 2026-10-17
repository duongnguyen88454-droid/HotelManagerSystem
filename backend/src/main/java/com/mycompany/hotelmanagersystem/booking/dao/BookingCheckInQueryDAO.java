package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.CheckInArrivalItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInRoomDetailDTO;
import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;

import java.sql.Date;
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
 * DAO chuyên trách các truy vấn đọc dữ liệu phục vụ Quầy Tiếp Đón Check-in (QT
 * 2.1).
 */
public class BookingCheckInQueryDAO extends BaseRepository<CheckInArrivalItemDTO, String> {

    @Override
    protected String getTableName() {
        return "v_ArrivalCheckInBookings";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "BookingId";
    }

    @Override
    protected RowMapper<CheckInArrivalItemDTO> getRowMapper() {
        return this::mapRowToArrivalDTO;
    }

    @Override
    protected String getRole() {
        return "Receptionist";
    }

    /**
     * Lấy danh sách các đơn đặt phòng chờ tiếp nhận tại quầy.
     */
    public List<CheckInArrivalItemDTO> getArrivalBookings(String hoTen, String cccd, String maBK, String keyword) {
        boolean hasHoTen = hoTen != null && !hoTen.trim().isEmpty();
        boolean hasCccd = cccd != null && !cccd.trim().isEmpty();
        boolean hasMaBK = maBK != null && !maBK.trim().isEmpty();
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        String sql = buildArrivalQuerySql(hasHoTen, hasCccd, hasMaBK, hasKeyword);

        List<Object> params = new ArrayList<>();
        if (hasKeyword) {
            String kwParam = "%" + keyword.trim() + "%";
            params.add(kwParam);
            params.add(kwParam);
            params.add(kwParam);
            params.add(kwParam);
        }
        if (hasHoTen) {
            params.add("%" + hoTen.trim() + "%");
        }
        if (hasCccd) {
            params.add(cccd.trim());
        }
        if (hasMaBK) {
            params.add("%" + maBK.trim() + "%");
        }

        return query(sql, params.toArray());
    }

    private String buildArrivalQuerySql(boolean hasHoTen, boolean hasCccd, boolean hasMaBK, boolean hasKeyword) {
        StringBuilder sb = new StringBuilder("SELECT * FROM v_ArrivalCheckInBookings WHERE 1=1 ");
        if (hasKeyword) {
            sb.append("AND (CustomerName LIKE ? OR CCCD LIKE ? OR BookingId LIKE ? OR PhoneNumber LIKE ?) ");
        }
        if (hasHoTen) {
            sb.append("AND CustomerName LIKE ? ");
        }
        if (hasCccd) {
            sb.append("AND CCCD = ? ");
        }
        if (hasMaBK) {
            sb.append("AND BookingId LIKE ? ");
        }
        sb.append("ORDER BY ExpectedCheckInDate ASC, BookingId ASC");
        return sb.toString();
    }

    private CheckInArrivalItemDTO mapRowToArrivalDTO(ResultSet rs) throws SQLException {
        Date inSql = rs.getDate("ExpectedCheckInDate");
        Date outSql = rs.getDate("ExpectedCheckOutDate");
        LocalDate inDate = inSql != null ? inSql.toLocalDate() : null;
        LocalDate outDate = outSql != null ? outSql.toLocalDate() : null;

        return new CheckInArrivalItemDTO(
                rs.getString("BookingId"),
                rs.getString("CustomerName"),
                rs.getString("PhoneNumber"),
                rs.getString("CCCD"),
                inDate,
                outDate,
                rs.getInt("TotalRooms"),
                rs.getInt("ReceivedRooms"));
    }

    /**
     * Lấy thông tin chi tiết một đơn đặt phòng kèm các phòng và dịch vụ đã đặt
     * trước.
     */
    public CheckInDetailDTO getBookingCheckInDetail(String maBooking) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }

        CheckInDetailDTO dto = fetchBookingHeader(maBooking.trim());
        if (dto == null) {
            return null;
        }
        List<CheckInRoomDetailDTO> rooms = fetchRoomsForBooking(maBooking.trim());
        Map<String, List<String>> servicesMap = fetchServicesByRoom(maBooking.trim());

        for (CheckInRoomDetailDTO r : rooms) {
            List<String> svcs = servicesMap.get(r.getMaPhong());
            if (svcs != null && !svcs.isEmpty()) {
                r.setDanhSachDichVu(svcs);
            }
        }
        dto.setDanhSachPhong(rooms);
        return dto;
    }

    private CheckInDetailDTO fetchBookingHeader(String maBooking) {
        String sql = "SELECT b.BookingId AS MaBooking, c.FullName AS HoTen, c.PhoneNumber AS SoDT, c.CCCD, c.Email, "
                + "       MIN(br.ExpectedCheckInDate) AS NgayNhan, MAX(br.ExpectedCheckOutDate) AS NgayTra "
                + "FROM Booking b "
                + "INNER JOIN Customer c ON b.CustomerId = c.CustomerId "
                + "INNER JOIN Booking_Room br ON b.BookingId = br.BookingId "
                + "WHERE b.BookingId = ? "
                + "GROUP BY b.BookingId, c.FullName, c.PhoneNumber, c.CCCD, c.Email";

        return queryOneCustom(sql, rs -> {
            Date inSql = rs.getDate("NgayNhan");
            Date outSql = rs.getDate("NgayTra");
            return new CheckInDetailDTO(
                    rs.getString("MaBooking"),
                    rs.getString("HoTen"),
                    rs.getString("SoDT"),
                    rs.getString("CCCD"),
                    rs.getString("Email"),
                    inSql != null ? inSql.toLocalDate() : null,
                    outSql != null ? outSql.toLocalDate() : null);
        }, maBooking).orElse(null);
    }

    private List<CheckInRoomDetailDTO> fetchRoomsForBooking(String maBooking) {
        String sql = "SELECT br.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, "
                + "       r.HousekeepingStatus AS TrangThaiBuong, br.ActualCheckInDate AS NgayCheckInThucTe "
                + "FROM Booking_Room br "
                + "INNER JOIN Room r ON br.RoomId = r.RoomId "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE br.BookingId = ? "
                + "ORDER BY r.RoomName ASC";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        return queryCustom(sql, rs -> {
            Timestamp ts = rs.getTimestamp("NgayCheckInThucTe");
            String actualInStr = (ts != null) ? sdf.format(ts) : null;
            return new CheckInRoomDetailDTO(
                    rs.getString("MaPhong"),
                    rs.getString("SoPhong"),
                    rs.getString("TenLoaiPhong"),
                    rs.getString("TrangThaiBuong"),
                    actualInStr);
        }, maBooking);
    }

    private Map<String, List<String>> fetchServicesByRoom(String maBooking) {
        Map<String, List<String>> map = new HashMap<>();
        String sql = "SELECT brs.RoomId AS MaPhong, s.ServiceName AS TenDichVu, brs.Quantity AS SoLuong "
                + "FROM Booking_Room_Service brs "
                + "INNER JOIN Service s ON brs.ServiceId = s.ServiceId "
                + "WHERE brs.BookingId = ? "
                + "ORDER BY brs.RoomId ASC, s.ServiceName ASC";

        queryCustom(sql, rs -> {
            String maPhong = rs.getString("MaPhong");
            String text = "- " + rs.getString("TenDichVu") + " (x" + rs.getInt("SoLuong") + ")";
            map.computeIfAbsent(maPhong, k -> new ArrayList<>()).add(text);
            return null;
        }, maBooking);

        return map;
    }
}
