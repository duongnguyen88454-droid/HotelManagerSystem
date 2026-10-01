package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.receptionist.service.RoomMapService;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "ReceptionistPortalServlet", urlPatterns = {"/receptionist/room-map"})
public class ReceptionistPortalServlet extends HttpServlet {

    private RoomMapService roomMapService;

    @Override
    public void init() throws ServletException {
        this.roomMapService = new RoomMapService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate startDate = LocalDate.of(2026, 9, 29);
        LocalDate endDate = LocalDate.of(2026, 10, 5);

        List<RoomTimelineDTO> roomList = roomMapService.getTimelineWithBookingBars(startDate, endDate);
        RoomMapKpiDTO kpi = roomMapService.getRoomMapKpi();

        request.setAttribute("roomList", roomList);
        request.setAttribute("kpi", kpi);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        request.getRequestDispatcher("/views/receptionist/room_map.jsp").forward(request, response);
    }
}

