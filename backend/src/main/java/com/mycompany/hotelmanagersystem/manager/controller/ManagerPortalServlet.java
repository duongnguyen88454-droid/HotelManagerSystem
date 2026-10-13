package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.RoomOccupancyDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerDashboardService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ManagerPortalServlet", urlPatterns = {"/manager/dashboard"})
public class ManagerPortalServlet extends HttpServlet {

    private final ManagerDashboardService dashboardService = new ManagerDashboardService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RoomOccupancyDTO occupancy = dashboardService.getOccupancySummary();
        request.setAttribute("occupancy", occupancy);
        request.getRequestDispatcher("/views/manager/dashboard.jsp").forward(request, response);
    }
}
