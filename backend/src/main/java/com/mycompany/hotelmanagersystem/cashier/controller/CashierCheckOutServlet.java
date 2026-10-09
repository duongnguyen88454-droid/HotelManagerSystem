package com.mycompany.hotelmanagersystem.cashier.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.CheckOutResultDTO;
import com.mycompany.hotelmanagersystem.cashier.service.CheckOutService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.List;

/**
 * Controller tiếp nhận yêu cầu Check-out từng phòng hoặc nhiều phòng đã chọn.
 */
@WebServlet(name = "CashierCheckOutServlet", urlPatterns = {"/cashier/checkout"})
public class CashierCheckOutServlet extends HttpServlet {

    private CheckOutService checkOutService;

    @Override
    public void init() throws ServletException {
        this.checkOutService = new CheckOutService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String maBooking = request.getParameter("maBooking");
        String[] selectedRooms = request.getParameterValues("selectedRooms");

        if (maBooking == null || maBooking.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cashier/dashboard");
            return;
        }

        if (selectedRooms == null || selectedRooms.length == 0) {
            String err = URLEncoder.encode("Vui lòng tích chọn ít nhất một phòng để thực hiện trả phòng!", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/cashier/booking-detail?maBooking=" + maBooking + "&error=" + err);
            return;
        }

        String maNV = resolveEmployeeId(request.getSession(false));
        List<String> roomList = Arrays.asList(selectedRooms);
        CheckOutResultDTO result = checkOutService.processCheckOutRooms(maBooking.trim(), roomList, maNV);

        if (result.isSuccess()) {
            response.sendRedirect(request.getContextPath() + "/cashier/payment?maHoaDon="
                    + result.getMaHoaDon() + "&maBooking=" + maBooking.trim());
        } else {
            String err = URLEncoder.encode(result.getMessage(), "UTF-8");
            response.sendRedirect(request.getContextPath() + "/cashier/booking-detail?maBooking=" + maBooking + "&error=" + err);
        }
    }

    private String resolveEmployeeId(HttpSession session) {
        if (session != null) {
            UserSessionDTO user = (UserSessionDTO) session.getAttribute("CURRENT_USER");
            if (user != null && user.getMaDinhDanh() != null && !user.getMaDinhDanh().trim().isEmpty()) {
                return user.getMaDinhDanh().trim();
            }
        }
        return "NV001";
    }
}
