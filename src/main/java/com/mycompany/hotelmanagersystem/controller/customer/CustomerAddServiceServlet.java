package com.mycompany.hotelmanagersystem.controller.customer;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.service.booking.BookingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet(name = "CustomerAddServiceServlet", urlPatterns = {"/customer/booking-detail/add-service"})
public class CustomerAddServiceServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String maKH = currentUser.getMaDinhDanh();
        String maTaiKhoan = currentUser.getMaTaiKhoan();
        String action = request.getParameter("action");
        String bookingId = request.getParameter("bookingId");

        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/history");
            return;
        }

        try {
            if ("remove".equalsIgnoreCase(action)) {
                String serviceBookingId = request.getParameter("serviceBookingId");
                boolean removed = bookingService.removeServiceFromRoom(serviceBookingId, bookingId, maKH, maTaiKhoan);
                if (removed) {
                    response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId=" + bookingId + "&msg=service_removed");
                } else {
                    response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId=" + bookingId + "&error=remove_failed");
                }
                return;
            }

            // Mặc định là action = "add"
            String roomId = request.getParameter("roomId");
            String serviceId = request.getParameter("serviceId");
            String quantityStr = request.getParameter("quantity");
            int quantity = 1;
            if (quantityStr != null && !quantityStr.trim().isEmpty()) {
                quantity = Integer.parseInt(quantityStr.trim());
            }

            boolean added = bookingService.addServiceToRoom(bookingId, roomId, serviceId, quantity, maKH, maTaiKhoan);
            if (added) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId=" + bookingId + "&msg=service_added");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId=" + bookingId + "&error=add_failed");
            }
        } catch (Exception ex) {
            String errorMsg = URLEncoder.encode(ex.getMessage(), "UTF-8");
            response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId=" + bookingId + "&error=" + errorMsg);
        }
    }
}
