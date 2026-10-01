package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.room.dao.RoomDAO;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReceptionistPortalServlet", urlPatterns = {"/receptionist/room-map", "/receptionist/checkin"})
public class ReceptionistPortalServlet extends HttpServlet {

    private RoomDAO roomDAO;

    @Override
    public void init() throws ServletException {
        this.roomDAO = new RoomDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. Tải danh sách phòng thực tế từ CSDL SQL Server theo tầng
        List<RoomTimelineDTO> roomList = roomDAO.getAllRoomsForTimeline();

        // 2. Tính toán chỉ số thống kê buồng phòng thời gian thực (KPI)
        RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();

        request.setAttribute("roomList", roomList);
        request.setAttribute("kpi", kpi);

        request.getRequestDispatcher("/views/receptionist/room_map.jsp").forward(request, response);
    }
}
