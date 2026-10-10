package com.mycompany.hotelmanagersystem.booking.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.booking.service.BookingService;
import com.mycompany.hotelmanagersystem.booking.service.PaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet điều hướng trang nộp cọc và tiếp nhận xác nhận thanh toán cọc giữ chỗ.
 * Tuân thủ QT 1.1-1.5, QT 3.1 trong ARCHITECTURE_RULES.md.
 */
@WebServlet(name = "CustomerDepositServlet", urlPatterns = {"/customer/deposit"})
public class CustomerDepositServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null)
                ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        String bookingId = request.getParameter("bookingId");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/history");
            return;
        }

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/customer/deposit?bookingId="
                    + bookingId.trim());
            return;
        }

        try {
            BookingDetailDTO bookingDetail = bookingService.getBookingDetail(
                    bookingId.trim(), currentUser.getMaDinhDanh(), currentUser.getMaTaiKhoan());

            if (bookingDetail == null) {
                response.sendRedirect(request.getContextPath() + "/customer/history?error=not_found");
                return;
            }

            if (isAlreadyDepositedOrPaid(bookingDetail)) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId="
                        + bookingId.trim() + "&info=already_deposited");
                return;
            }

            request.setAttribute("bookingDetail", bookingDetail);
            request.getRequestDispatcher("/views/booking/deposit_checkout.jsp").forward(request, response);
        } catch (SecurityException ex) {
            response.sendRedirect(request.getContextPath() + "/customer/history?error=access_denied");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null)
                ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        String bookingId = request.getParameter("bookingId");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/customer/history");
            return;
        }

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "BankTransfer";
        }

        try {
            paymentService.processDepositPayment(bookingId.trim(), paymentMethod.trim(),
                    "Khách hàng xác nhận chuyển khoản cọc");
            response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId="
                    + bookingId.trim() + "&depositSuccess=true");
        } catch (Exception ex) {
            handleDepositFailure(request, response, bookingId.trim(), currentUser, ex.getMessage());
        }
    }

    private boolean isAlreadyDepositedOrPaid(BookingDetailDTO detail) {
        String status = detail.getTrangThaiHoaDon();
        return "Paid".equalsIgnoreCase(status)
                || "DaThanhToan".equalsIgnoreCase(status)
                || "PartiallyPaid".equalsIgnoreCase(status)
                || "ThanhToanMotPhan".equalsIgnoreCase(status);
    }

    private void handleDepositFailure(HttpServletRequest request, HttpServletResponse response,
                                      String bookingId, UserSessionDTO currentUser, String errorMsg)
            throws ServletException, IOException {
        try {
            BookingDetailDTO detail = bookingService.getBookingDetail(
                    bookingId, currentUser.getMaDinhDanh(), currentUser.getMaTaiKhoan());
            request.setAttribute("bookingDetail", detail);
        } catch (Exception ignored) {
            // Giữ nguyên lỗi xử lý chính
        }
        request.setAttribute("errorMessage", errorMsg);
        request.getRequestDispatcher("/views/booking/deposit_checkout.jsp").forward(request, response);
    }
}
