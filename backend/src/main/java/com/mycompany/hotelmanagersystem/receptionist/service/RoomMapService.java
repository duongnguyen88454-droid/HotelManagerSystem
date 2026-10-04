package com.mycompany.hotelmanagersystem.receptionist.service;

import com.mycompany.hotelmanagersystem.booking.service.CheckInService;
import com.mycompany.hotelmanagersystem.room.dto.BookingBarDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service tổng hợp dữ liệu buồng phòng, dải đặt phòng và KPI phục vụ giao diện Lễ tân.
 */
public class RoomMapService {

    private final RoomService roomService;
    private final CheckInService checkInService;

    public RoomMapService() {
        this.roomService = new RoomService();
        this.checkInService = new CheckInService();
    }

    public RoomMapService(RoomService roomService, CheckInService checkInService) {
        this.roomService = roomService;
        this.checkInService = checkInService;
    }

    /**
     * Tải danh sách phòng kèm toàn bộ các dải đặt phòng trong tuần được gán đúng từng phòng.
     */
    public List<RoomTimelineDTO> getTimelineWithBookingBars(LocalDate startDate, LocalDate endDate) {
        List<RoomTimelineDTO> rooms = roomService.getAllRoomsForTimeline();
        List<BookingBarDTO> bars = checkInService.getBookingBarsInWeek(startDate, endDate);

        if (bars == null || bars.isEmpty()) {
            return rooms;
        }

        Map<String, List<BookingBarDTO>> barMap = new HashMap<>();
        for (BookingBarDTO bar : bars) {
            if (bar.getMaPhong() != null) {
                barMap.computeIfAbsent(bar.getMaPhong(), k -> new ArrayList<>()).add(bar);
            }
        }

        for (RoomTimelineDTO r : rooms) {
            List<BookingBarDTO> roomBars = barMap.get(r.getMaPhong());
            if (roomBars != null) {
                r.setBookingBars(roomBars);
            }
        }

        return rooms;
    }

    /**
     * Lấy số liệu thống kê buồng phòng thời gian thực (KPI).
     */
    public RoomMapKpiDTO getRoomMapKpi() {
        return roomService.getRoomMapKpi();
    }
}
