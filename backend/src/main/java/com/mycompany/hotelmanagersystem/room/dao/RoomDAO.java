package com.mycompany.hotelmanagersystem.room.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.model.RoomType;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * DAO chuyên trách các thao tác dữ liệu phòng và hạng phòng.
 * Kế thừa BaseRepository theo kiến trúc chuẩn.
 */
public class RoomDAO extends BaseRepository<AvailableRoomDTO, String> {

    @Override
    protected String getTableName() {
        return "v_RoomDetails";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "RoomId";
    }

    @Override
    protected RowMapper<AvailableRoomDTO> getRowMapper() {
        return this::mapAvailableRoom;
    }

    @Override
    protected String getRole() {
        return "Customer";
    }

    /**
     * Lấy toàn bộ danh sách hạng phòng đang kinh doanh
     */
    public List<RoomType> getAllActiveRoomTypes() {
        String sql = "SELECT rt.RoomTypeId AS MaLoaiPhong, rt.RoomTypeName AS TenLoaiPhong, "
                + "       rt.Capacity AS SoNguoiToiDa, rt.BasePrice AS GiaPhong, "
                + "       ISNULL((SELECT STRING_AGG(bt.BedTypeName, ', ') "
                + "               FROM RoomType_BedType rtbt "
                + "               JOIN BedType bt ON rtbt.BedTypeId = bt.BedTypeId "
                + "               WHERE rtbt.RoomTypeId = rt.RoomTypeId AND bt.IsActive = 1), N'Tiêu chuẩn') AS LoaiGiuong "
                + "FROM RoomType rt "
                + "WHERE rt.IsActive = 1 "
                + "ORDER BY rt.BasePrice ASC";
        return queryCustom(sql, this::mapRoomType);
    }

    /**
     * Tra cứu danh sách các phòng trống khả dụng theo khoảng ngày, số khách và loại phòng
     */
    public List<AvailableRoomDTO> searchAvailableRooms(LocalDate checkIn, LocalDate checkOut, Integer guests,
            String roomTypeId) {
        String sql = "SELECT * FROM v_RoomDetails "
                + "WHERE RoomTypeIsActive = 1 "
                + "  AND RoomStatus = 'Available' "
                + "  AND (? IS NULL OR RoomTypeId = ?) "
                + "  AND (? IS NULL OR Capacity >= ?) "
                + "  AND dbo.fn_KiemTraPhongTrongTrongKhoang(RoomId, ?, ?, NULL) = 1 "
                + "ORDER BY BasePrice ASC, RoomName ASC";

        boolean hasRoomType = (roomTypeId != null && !roomTypeId.trim().isEmpty() && !"ALL".equalsIgnoreCase(roomTypeId));
        Object typeParam = hasRoomType ? roomTypeId.trim() : null;
        Object guestParam = (guests != null && guests > 0) ? guests : null;
        Date dIn = checkIn != null ? Date.valueOf(checkIn) : null;
        Date dOut = checkOut != null ? Date.valueOf(checkOut) : null;

        return query(sql, typeParam, typeParam, guestParam, guestParam, dIn, dOut);
    }

    /**
     * Lấy thông tin chi tiết của một phòng cụ thể
     */
    public AvailableRoomDTO getRoomDetailById(String maPhong) {
        String sql = "SELECT * FROM v_RoomDetails WHERE RoomId = ?";
        return queryOne(sql, maPhong).orElse(null);
    }

    /**
     * Kiểm tra nhanh phòng có trống và khả dụng trong khoảng thời gian không
     */
    public boolean isRoomAvailable(String maPhong, LocalDate checkIn, LocalDate checkOut) {
        String sql = "SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(?, ?, ?, NULL) AS KhaDung";
        Date dIn = checkIn != null ? Date.valueOf(checkIn) : null;
        Date dOut = checkOut != null ? Date.valueOf(checkOut) : null;
        Long result = queryScalarLong(sql, maPhong, dIn, dOut);
        return result != null && result == 1;
    }

    /**
     * FN-3.1: Lấy toàn bộ danh sách phòng thực tế theo tầng để hiển thị trên PMS Gantt Timeline
     */
    public List<RoomTimelineDTO> getAllRoomsForTimeline() {
        String sql = "SELECT * FROM v_RoomDetails ORDER BY RoomName ASC";
        return queryCustom(sql, this::mapRoomTimeline);
    }

    private AvailableRoomDTO mapAvailableRoom(ResultSet rs) throws SQLException {
        AvailableRoomDTO dto = new AvailableRoomDTO(
                rs.getString("RoomId"),
                rs.getString("RoomName"),
                rs.getString("RoomTypeId"),
                rs.getNString("RoomTypeName"),
                0.0,
                rs.getNString("BedTypesDescription"),
                rs.getInt("Capacity"),
                rs.getDouble("BasePrice"),
                rs.getNString("AmenitiesDescription"));
        dto.setDepositPercent(rs.getDouble("DepositPercent"));
        return dto;
    }

    private RoomType mapRoomType(ResultSet rs) throws SQLException {
        return new RoomType(
                rs.getString("MaLoaiPhong"),
                rs.getNString("TenLoaiPhong"),
                0.0,
                rs.getNString("LoaiGiuong"),
                rs.getInt("SoNguoiToiDa"),
                rs.getDouble("GiaPhong"),
                "Active");
    }

    private RoomTimelineDTO mapRoomTimeline(ResultSet rs) throws SQLException {
        String rawStatus = rs.getString("RoomStatus") + "|"
                + rs.getString("OccupancyStatus") + "|"
                + rs.getString("HousekeepingStatus");
        return new RoomTimelineDTO(
                rs.getString("RoomId"),
                rs.getString("RoomName"),
                1,
                rs.getString("RoomTypeId"),
                rs.getNString("RoomTypeName"),
                rs.getDouble("BasePrice"),
                rawStatus,
                rs.getNString("RoomDescription"));
    }
}
