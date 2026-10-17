package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.manager.dao.ManagerRoomDAO;
import com.mycompany.hotelmanagersystem.manager.dto.PhysicalRoomDTO;

import java.util.Collections;
import java.util.List;

/**
 * Service xử lý nghiệp vụ quản lý phòng vật lý cho Quản lý khách sạn.
 */
public class ManagerRoomService {

    private final ManagerRoomDAO roomDAO;

    public ManagerRoomService() {
        this.roomDAO = new ManagerRoomDAO();
    }

    public ManagerRoomService(ManagerRoomDAO roomDAO) {
        this.roomDAO = roomDAO;
    }

    /**
     * Lấy toàn bộ danh sách phòng vật lý hiện có.
     *
     * @return danh sách PhysicalRoomDTO
     */
    public List<PhysicalRoomDTO> getAllPhysicalRooms() {
        try {
            return roomDAO.getAllRooms();
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    /**
     * Thêm một phòng vật lý mới vào hệ thống.
     *
     * @param roomId mã định danh phòng (ví dụ P104)
     * @param roomTypeId mã hạng phòng
     * @param roomName tên hiển thị phòng (ví dụ Phòng 104)
     * @return true nếu thêm thành công
     */
    public boolean addPhysicalRoom(String roomId, String roomTypeId, String roomName) {
        if (roomId == null || roomId.trim().isEmpty()
                || roomTypeId == null || roomTypeId.trim().isEmpty()
                || roomName == null || roomName.trim().isEmpty()) {
            return false;
        }
        return roomDAO.createRoom(roomId.trim().toUpperCase(), roomTypeId.trim(), roomName.trim());
    }

    /**
     * Cập nhật trạng thái vận hành của phòng vật lý.
     *
     * @param roomId mã phòng
     * @param status trạng thái mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateRoomOperationalStatus(String roomId, String status) {
        if (roomId == null || roomId.trim().isEmpty() || status == null || status.trim().isEmpty()) {
            return false;
        }
        return roomDAO.updateRoomStatus(roomId.trim(), status.trim());
    }
}
