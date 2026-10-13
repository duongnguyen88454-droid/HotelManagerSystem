package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.ServiceAnalyticsDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerReportService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManagerServiceAnalyticsServlet", urlPatterns = {"/manager/services"})
public class ManagerServiceAnalyticsServlet extends HttpServlet {

    private final ManagerReportService reportService = new ManagerReportService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ServiceAnalyticsDTO> serviceList = reportService.getServiceAnalytics();
        request.setAttribute("serviceList", serviceList);
        request.getRequestDispatcher("/views/manager/service_analytics.jsp").forward(request, response);
    }
}
