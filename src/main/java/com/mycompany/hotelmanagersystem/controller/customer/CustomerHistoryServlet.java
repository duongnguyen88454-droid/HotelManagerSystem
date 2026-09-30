package com.mycompany.hotelmanagersystem.controller.customer;

import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.dto.booking.CustomerBookingHistoryDTO;
import com.mycompany.hotelmanagersystem.service.booking.BookingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerHistoryServlet", urlPatterns = {"/customer/history"})
public class CustomerHistoryServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/customer/history");
            return;
        }

        String maTaiKhoan = currentUser.getMaTaiKhoan();
        List<CustomerBookingHistoryDTO> bookingList = bookingService.getCustomerHistoryByAccountId(maTaiKhoan);
        // Fallback kiểm tra thêm theo maDinhDanh nếu là tài khoản seed cũ có liên kết KHACHHANG
        if (bookingList.isEmpty() && currentUser.getMaDinhDanh() != null && !currentUser.getMaDinhDanh().trim().isEmpty()) {
            bookingList = bookingService.getCustomerHistory(currentUser.getMaDinhDanh().trim());
        }
        request.setAttribute("bookingList", bookingList);

        request.getRequestDispatcher("/views/customer/booking_history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String bookingId = request.getParameter("bookingId");
        String maKH = currentUser.getMaDinhDanh();
        String maTaiKhoan = currentUser.getMaTaiKhoan();

        if ("cancel".equalsIgnoreCase(action) && bookingId != null && !bookingId.trim().isEmpty()) {
            try {
                boolean success = bookingService.cancelBooking(bookingId.trim(), maKH, maTaiKhoan);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/customer/history?cancelSuccess=true");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/history?error=cancel_failed");
                    return;
                }
            } catch (Exception ex) {
                response.sendRedirect(request.getContextPath() + "/customer/history?error=" + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/customer/history");
    }
}
