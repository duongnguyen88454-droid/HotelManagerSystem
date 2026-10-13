package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.hotelservice.service.HotelServiceService;
import com.mycompany.hotelmanagersystem.receptionist.service.RoomMapService;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ReceptionistPortalServlet", urlPatterns = {"/receptionist/room-map"})
public class ReceptionistPortalServlet extends HttpServlet {

    private RoomMapService roomMapService;
    private HotelServiceService hotelServiceService;

    @Override
    public void init() throws ServletException {
        this.roomMapService = new RoomMapService();
        this.hotelServiceService = new HotelServiceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String startDateParam = request.getParameter("startDate");
        LocalDate currentMonday = LocalDate.now().with(
                java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
        LocalDate startDate;
        if (startDateParam != null && !startDateParam.trim().isEmpty()) {
            try {
                startDate = LocalDate.parse(startDateParam.trim());
            } catch (Exception e) {
                startDate = currentMonday;
            }
        } else {
            startDate = currentMonday;
        }

        LocalDate endDate = startDate.plusDays(6);
        LocalDate prevWeek = startDate.minusDays(7);
        LocalDate nextWeek = startDate.plusDays(7);

        String formattedWeek = String.format("%02d/%02d/%d - %02d/%02d/%d",
                startDate.getDayOfMonth(), startDate.getMonthValue(), startDate.getYear(),
                endDate.getDayOfMonth(), endDate.getMonthValue(), endDate.getYear());

        List<String> dayHeaders = new ArrayList<>();
        String[] dayNames = {"Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"};
        for (int i = 0; i < 7; i++) {
            LocalDate d = startDate.plusDays(i);
            dayHeaders.add(String.format("%s (%02d/%02d)", dayNames[i], d.getDayOfMonth(), d.getMonthValue()));
        }

        List<RoomTimelineDTO> roomList = roomMapService.getTimelineWithBookingBars(startDate, endDate);

        request.setAttribute("roomList", roomList);
        request.setAttribute("serviceList", hotelServiceService.getAllActiveServices());
        request.setAttribute("startDate", startDate.toString());
        request.setAttribute("endDate", endDate.toString());
        request.setAttribute("prevWeek", prevWeek.toString());
        request.setAttribute("nextWeek", nextWeek.toString());
        request.setAttribute("formattedWeek", formattedWeek);
        request.setAttribute("dayHeaders", dayHeaders);

        request.getRequestDispatcher("/views/receptionist/room_map.jsp").forward(request, response);
    }
}

