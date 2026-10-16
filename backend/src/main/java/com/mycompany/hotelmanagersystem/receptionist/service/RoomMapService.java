package com.mycompany.hotelmanagersystem.receptionist.service;

import com.mycompany.hotelmanagersystem.room.dto.TimelineCellDTO;
import com.mycompany.hotelmanagersystem.room.dto.TimelineDayDTO;
import com.mycompany.hotelmanagersystem.booking.service.CheckInService;
import com.mycompany.hotelmanagersystem.room.dto.BookingBarDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service tổng hợp dữ liệu buồng phòng và dải đặt phòng phục vụ giao diện Lễ tân.
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
     * Dựng cấu trúc ô (TimelineCellDTO) cho từng ngày trong tuần của từng phòng.
     */
    public List<RoomTimelineDTO> buildTimelineGrid(LocalDate startDate, LocalDate endDate,
            List<TimelineDayDTO> days) {
        List<RoomTimelineDTO> rooms = getTimelineWithBookingBars(startDate, endDate);
        for (RoomTimelineDTO r : rooms) {
            List<TimelineCellDTO> cells = new ArrayList<>();
            int skipUntilCol = 0;
            for (TimelineDayDTO day : days) {
                int col = day.getDayIndex();
                TimelineCellDTO cell = new TimelineCellDTO(col, day.getDateStr(), day.getNextDateStr(),
                        day.getDisplayShort(), day.isToday());

                BookingBarDTO startingBar = findStartingBar(r.getBookingBars(), col);
                if (startingBar != null) {
                    cell.setBarStart(true);
                    cell.setEmpty(false);
                    cell.setBookingBar(startingBar);
                    skipUntilCol = col + startingBar.getColSpan() - 1;
                } else if (col <= skipUntilCol) {
                    cell.setBarCovered(true);
                    cell.setEmpty(false);
                } else {
                    cell.setEmpty(true);
                }
                cells.add(cell);
            }
            r.setCells(cells);
        }
        return rooms;
    }

    private BookingBarDTO findStartingBar(List<BookingBarDTO> bars, int col) {
        if (bars == null) {
            return null;
        }
        for (BookingBarDTO bar : bars) {
            if (bar.getStartCol() == col) {
                return bar;
            }
        }
        return null;
    }

    /**
     * Tính tổng số lượng phòng trống theo từng ngày của mỗi tầng.
     */
    public Map<Integer, int[]> computeFloorAvailableCounts(List<RoomTimelineDTO> rooms) {
        Map<Integer, int[]> map = new HashMap<>();
        for (RoomTimelineDTO r : rooms) {
            int floor = r.getSoTang();
            int[] counts = map.computeIfAbsent(floor, k -> new int[7]);
            List<TimelineCellDTO> cells = r.getCells();
            for (int i = 0; i < cells.size() && i < 7; i++) {
                if (cells.get(i).isEmpty()) {
                    counts[i]++;
                }
            }
        }
        return map;
    }
}
