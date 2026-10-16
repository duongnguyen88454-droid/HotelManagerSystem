package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.receptionist.service.RoomMapService;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.dto.TimelineDayDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Controller phục vụ giao diện sơ đồ buồng phòng theo dạng lưới thời gian (Timeline Grid).
 */
@WebServlet(name = "ReceptionistTimelineServlet", urlPatterns = {"/receptionist/timeline"})
public class ReceptionistTimelineServlet extends HttpServlet {

    private RoomMapService roomMapService;

    @Override
    public void init() throws ServletException {
        this.roomMapService = new RoomMapService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String startDateParam = request.getParameter("startDate");
        LocalDate today = LocalDate.now();
        LocalDate startDate;

        if (startDateParam != null && !startDateParam.trim().isEmpty()) {
            try {
                startDate = LocalDate.parse(startDateParam.trim());
            } catch (Exception e) {
                startDate = today;
            }
        } else {
            startDate = today;
        }

        LocalDate endDate = startDate.plusDays(6);
        LocalDate prevWeek = startDate.minusDays(7);
        LocalDate nextWeek = startDate.plusDays(7);

        List<TimelineDayDTO> days = new ArrayList<>();
        for (int i = 0; i < 7; i++) {
            LocalDate d = startDate.plusDays(i);
            days.add(new TimelineDayDTO(i + 1, d, d.equals(today)));
        }

        String formattedRange = String.format("%02d/%02d/%d - %02d/%02d/%d",
                startDate.getDayOfMonth(), startDate.getMonthValue(), startDate.getYear(),
                endDate.getDayOfMonth(), endDate.getMonthValue(), endDate.getYear());

        List<RoomTimelineDTO> roomList = roomMapService.buildTimelineGrid(startDate, endDate, days);
        Map<Integer, int[]> floorAvailableMap = roomMapService.computeFloorAvailableCounts(roomList);

        request.setAttribute("days", days);
        request.setAttribute("roomList", roomList);
        request.setAttribute("floorAvailableMap", floorAvailableMap);
        request.setAttribute("startDate", startDate.toString());
        request.setAttribute("endDate", endDate.toString());
        request.setAttribute("prevWeek", prevWeek.toString());
        request.setAttribute("nextWeek", nextWeek.toString());
        request.setAttribute("todayDate", today.toString());
        request.setAttribute("formattedRange", formattedRange);

        request.getRequestDispatcher("/views/receptionist/timeline.jsp").forward(request, response);
    }
}
