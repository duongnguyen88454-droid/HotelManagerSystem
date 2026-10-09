package com.mycompany.hotelmanagersystem.room.service;

import com.mycompany.hotelmanagersystem.room.dao.RoomDAO;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.model.RoomType;
import com.mycompany.hotelmanagersystem.room.util.RoomUtil;

import java.time.LocalDate;
import java.util.List;

public class RoomService {

    private final RoomDAO roomDAO;

    public RoomService() {
        this.roomDAO = new RoomDAO();
    }

    public RoomService(RoomDAO roomDAO) {
        this.roomDAO = roomDAO;
    }

    /**
     * Lấy toàn bộ hạng phòng đang kinh doanh
     */
    public List<RoomType> getActiveRoomTypes() {
        return roomDAO.getAllActiveRoomTypes();
    }

    /**
     * Tìm kiếm phòng trống theo tiêu chí và tính toán chi phí lưu trú
     */
    public List<AvailableRoomDTO> searchRooms(String checkInStr, String checkOutStr, String guestsStr, String roomTypeId) {
        LocalDate[] dates = RoomUtil.parseAndValidateDates(checkInStr, checkOutStr);
        Integer guests = RoomUtil.parseGuests(guestsStr);

        List<AvailableRoomDTO> rooms = roomDAO.searchAvailableRooms(dates[0], dates[1], guests, roomTypeId);
        for (AvailableRoomDTO room : rooms) {
            RoomUtil.applyPricingAndDates(room, dates[0], dates[1]);
        }
        return rooms;
    }

    /**
     * Lấy thông tin chi tiết của phòng đã chọn để chuẩn bị xác nhận đặt phòng
     */
    public AvailableRoomDTO getRoomBookingDetail(String maPhong, String checkInStr, String checkOutStr) {
        if (maPhong == null || maPhong.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã phòng không hợp lệ!");
        }
        LocalDate[] dates = RoomUtil.parseAndValidateDates(checkInStr, checkOutStr);
        AvailableRoomDTO room = roomDAO.getRoomDetailById(maPhong.trim());
        if (room == null) {
            throw new IllegalArgumentException("Không tìm thấy thông tin phòng yêu cầu!");
        }
        RoomUtil.applyPricingAndDates(room, dates[0], dates[1]);
        return room;
    }

    /**
     * FN-3.1: Lấy toàn bộ danh sách phòng thực tế theo tầng và chuẩn hóa trạng thái hiển thị
     */
    public List<RoomTimelineDTO> getAllRoomsForTimeline() {
        List<RoomTimelineDTO> list = roomDAO.getAllRoomsForTimeline();
        for (RoomTimelineDTO room : list) {
            room.setSoTang(RoomUtil.calculateFloor(room.getSoPhong()));
            room.setTrangThaiPhong(RoomUtil.resolveTimelineStatus(room.getTrangThaiPhong()));
        }
        return list;
    }

    /**
     * FN-3.1: Lấy các chỉ số thống kê buồng phòng thời gian thực (KPI)
     */
    public RoomMapKpiDTO getRoomMapKpi() {
        return roomDAO.getRoomMapKpi();
    }

    /**
     * Lấy thông tin phòng theo mã phòng
     */
    public AvailableRoomDTO getRoomDetailById(String maPhong) {
        if (maPhong == null || maPhong.trim().isEmpty()) {
            return null;
        }
        return roomDAO.getRoomDetailById(maPhong.trim());
    }
}
