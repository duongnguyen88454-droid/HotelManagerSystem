package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.PhysicalRoomDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;

/**
 * DAO xử lý truy vấn và tạo phòng vật lý cho Quản lý khách sạn.
 */
public class ManagerRoomDAO extends BaseRepository<PhysicalRoomDTO, String> {

    private static final String SELECT_ALL_ROOMS_SQL =
            "SELECT r.RoomId, r.RoomTypeId, rt.RoomTypeName, r.RoomName, "
            + "r.RoomStatus, r.HousekeepingStatus, r.OccupancyStatus "
            + "FROM Room r "
            + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
            + "ORDER BY r.RoomId ASC";

    private static final String INSERT_ROOM_SQL =
            "INSERT INTO Room (RoomId, RoomTypeId, RoomName, RoomStatus, HousekeepingStatus, OccupancyStatus) "
            + "VALUES (?, ?, ?, 'Available', 'Clean', 'Vacant')";

    private static final String UPDATE_STATUS_SQL =
            "UPDATE Room SET RoomStatus = ? WHERE RoomId = ?";

    @Override
    protected String getTableName() {
        return "Room";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "RoomId";
    }

    @Override
    protected RowMapper<PhysicalRoomDTO> getRowMapper() {
        return rs -> new PhysicalRoomDTO(
                rs.getString("RoomId"),
                rs.getString("RoomTypeId"),
                rs.getString("RoomTypeName"),
                rs.getString("RoomName"),
                rs.getString("RoomStatus"),
                rs.getString("HousekeepingStatus"),
                rs.getString("OccupancyStatus"));
    }

    @Override
    protected String getRole() {
        return "Manager";
    }

    /**
     * Lấy danh sách toàn bộ các phòng vật lý trong hệ thống.
     *
     * @return danh sách PhysicalRoomDTO
     */
    public List<PhysicalRoomDTO> getAllRooms() {
        return query(SELECT_ALL_ROOMS_SQL);
    }

    /**
     * Tạo mới một phòng vật lý trong khách sạn qua Stored Procedure dbo.sp_ThemPhong.
     * CSDL tự động gọi fn_SinhMaRoom() để sinh mã phòng RM... tự tăng.
     *
     * @param roomTypeId mã hạng phòng
     * @param roomName tên hiển thị phòng (ví dụ Phòng 101)
     * @return true nếu tạo thành công
     */
    public boolean createRoom(String roomTypeId, String roomName) {
        String callSql = "{call dbo.sp_ThemPhong(?, ?, ?)}";
        try (Connection conn = DBContext.getConnection(getRole());
             CallableStatement cs = conn.prepareCall(callSql)) {
            cs.setString(1, roomTypeId);
            cs.setString(2, roomName);
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.execute();
            String newRoomId = cs.getString(3);
            return newRoomId != null && !newRoomId.trim().isEmpty();
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật trạng thái vận hành của phòng vật lý (Available, Maintenance, OutOfService).
     *
     * @param roomId mã phòng
     * @param status trạng thái mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateRoomStatus(String roomId, String status) {
        try (Connection conn = DBContext.getConnection(getRole());
             PreparedStatement ps = conn.prepareStatement(UPDATE_STATUS_SQL)) {
            ps.setString(1, status);
            ps.setString(2, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }
}
