package com.mycompany.hotelmanagersystem.controller.customer;

import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.dto.booking.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.model.ServiceItem;
import com.mycompany.hotelmanagersystem.service.booking.BookingService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "CustomerBookingDetailServlet", urlPatterns = {"/customer/booking-detail"})
public class CustomerBookingDetailServlet extends HttpServlet {

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

        String bookingId = request.getParameter("bookingId");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            bookingId = request.getParameter("maBooking");
        }
        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/history");
            return;
        }

        String maKH = currentUser.getMaDinhDanh();
        String maTaiKhoan = currentUser.getMaTaiKhoan();
        try {
            BookingDetailDTO bookingDetail = bookingService.getBookingDetail(bookingId.trim(), maKH, maTaiKhoan);
            if (bookingDetail == null) {
                response.sendRedirect(request.getContextPath() + "/customer/history?error=not_found");
                return;
            }

            List<ServiceItem> activeServices = bookingService.getActiveServices();

            request.setAttribute("bookingDetail", bookingDetail);
            request.setAttribute("activeServices", activeServices);

            request.getRequestDispatcher("/views/customer/booking_detail.jsp").forward(request, response);
        } catch (SecurityException ex) {
            response.sendRedirect(request.getContextPath() + "/customer/history?error=access_denied");
        }
    }
}
