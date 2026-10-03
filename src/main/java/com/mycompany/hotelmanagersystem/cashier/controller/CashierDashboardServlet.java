package com.mycompany.hotelmanagersystem.cashier.controller;

import com.mycompany.hotelmanagersystem.cashier.dto.ActiveBookingItemDTO;
import com.mycompany.hotelmanagersystem.cashier.service.ActiveBookingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller hiển thị danh sách đơn lưu trú cần thanh toán tại quầy Thu Ngân.
 */
@WebServlet(name = "CashierDashboardServlet", urlPatterns = {"/cashier/dashboard"})
public class CashierDashboardServlet extends HttpServlet {

    private ActiveBookingService activeBookingService;

    @Override
    public void init() throws ServletException {
        this.activeBookingService = new ActiveBookingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String keyword = request.getParameter("keyword");

        List<ActiveBookingItemDTO> bookingList = activeBookingService.findCheckedInBookings(keyword);

        request.setAttribute("bookingList", bookingList);
        request.setAttribute("keyword", keyword != null ? keyword.trim() : "");
        request.getRequestDispatcher("/views/cashier/cashier_dashboard.jsp").forward(request, response);
    }
}
