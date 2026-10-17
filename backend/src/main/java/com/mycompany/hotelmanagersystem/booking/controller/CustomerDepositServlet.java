package com.mycompany.hotelmanagersystem.booking.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.booking.service.BookingCheckoutService;
import com.mycompany.hotelmanagersystem.booking.service.BookingService;
import com.mycompany.hotelmanagersystem.booking.service.PaymentService;
import com.mycompany.hotelmanagersystem.customer.model.Customer;

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
@WebServlet(name = "CustomerDepositServlet", urlPatterns = { "/customer/deposit" })
public class CustomerDepositServlet extends HttpServlet {

    private final BookingService bookingService = new BookingService();
    private final PaymentService paymentService = new PaymentService();
    private final BookingCheckoutService bookingCheckoutService = new BookingCheckoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null)
                ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/customer/deposit");
            return;
        }

        String bookingId = request.getParameter("bookingId");
        if (bookingId != null && !bookingId.trim().isEmpty() && !"CHO_THANH_TOAN".equals(bookingId.trim())) {
            renderExistingBookingDeposit(request, response, currentUser, bookingId.trim());
            return;
        }

        renderCartDeposit(request, response, session);
    }

    private void renderExistingBookingDeposit(HttpServletRequest request, HttpServletResponse response,
                                              UserSessionDTO currentUser, String bookingId)
            throws ServletException, IOException {
        try {
            BookingDetailDTO bookingDetail = bookingService.getBookingDetail(
                    bookingId, currentUser.getMaDinhDanh(), currentUser.getMaTaiKhoan());

            if (bookingDetail == null) {
                response.sendRedirect(request.getContextPath() + "/customer/history?error=not_found");
                return;
            }

            if (isAlreadyDepositedOrPaid(bookingDetail)) {
                response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId="
                        + bookingId + "&info=already_deposited");
                return;
            }

            request.setAttribute("bookingDetail", bookingDetail);
            request.getRequestDispatcher("/views/booking/deposit_checkout.jsp").forward(request, response);
        } catch (SecurityException ex) {
            response.sendRedirect(request.getContextPath() + "/customer/history?error=access_denied");
        }
    }

    private void renderCartDeposit(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session) throws ServletException, IOException {
        BookingCartDTO cart = (session != null) ? (BookingCartDTO) session.getAttribute("BOOKING_CART") : null;
        Customer guest = (session != null) ? (Customer) session.getAttribute("PENDING_BOOKING_GUEST") : null;
        String note = (session != null) ? (String) session.getAttribute("PENDING_BOOKING_NOTE") : null;

        if (cart == null || cart.getTotalRoomCount() == 0 || guest == null) {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
            return;
        }

        BookingDetailDTO bookingDetail = bookingCheckoutService.buildPendingBookingDetail(cart, guest, note);
        request.setAttribute("bookingDetail", bookingDetail);
        request.getRequestDispatcher("/views/booking/deposit_checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null)
                ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookingId = request.getParameter("bookingId");
        String paymentMethod = request.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
            paymentMethod = "BankTransfer";
        }

        if (bookingId != null && !bookingId.trim().isEmpty() && !"CHO_THANH_TOAN".equals(bookingId.trim())) {
            processExistingDeposit(request, response, currentUser, bookingId.trim(), paymentMethod.trim());
            return;
        }

        processCartDeposit(request, response, session, currentUser, paymentMethod.trim());
    }

    private void processExistingDeposit(HttpServletRequest request, HttpServletResponse response,
                                        UserSessionDTO currentUser, String bookingId, String paymentMethod)
            throws ServletException, IOException {
        try {
            paymentService.processDepositPayment(bookingId, paymentMethod,
                    "Khách hàng xác nhận chuyển khoản cọc");
            response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId="
                    + bookingId + "&depositSuccess=true");
        } catch (Exception ex) {
            handleDepositFailure(request, response, bookingId, currentUser, ex.getMessage());
        }
    }

    private void processCartDeposit(HttpServletRequest request, HttpServletResponse response,
                                    HttpSession session, UserSessionDTO currentUser, String paymentMethod)
            throws ServletException, IOException {
        BookingCartDTO cart = (session != null) ? (BookingCartDTO) session.getAttribute("BOOKING_CART") : null;
        Customer guest = (session != null) ? (Customer) session.getAttribute("PENDING_BOOKING_GUEST") : null;
        String note = (session != null) ? (String) session.getAttribute("PENDING_BOOKING_NOTE") : null;

        if (cart == null || cart.getTotalRoomCount() == 0 || guest == null) {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
            return;
        }

        try {
            String createdBookingId = bookingCheckoutService.executeCheckoutAndPayment(
                    guest, note, currentUser, cart, paymentMethod);

            session.removeAttribute("BOOKING_CART");
            session.removeAttribute("PENDING_BOOKING_GUEST");
            session.removeAttribute("PENDING_BOOKING_NOTE");
            currentUser.setSoDT(guest.getSoDT());
            session.setAttribute("CURRENT_USER", currentUser);
            session.setAttribute("SAVED_CCCD", guest.getCccd());

            response.sendRedirect(request.getContextPath() + "/customer/booking-detail?bookingId="
                    + createdBookingId + "&depositSuccess=true");
        } catch (Exception ex) {
            BookingDetailDTO detail = bookingCheckoutService.buildPendingBookingDetail(cart, guest, note);
            request.setAttribute("bookingDetail", detail);
            request.setAttribute("errorMessage", "Không thể hoàn tất đặt phòng: " + ex.getMessage());
            request.getRequestDispatcher("/views/booking/deposit_checkout.jsp").forward(request, response);
        }
    }

    private boolean isAlreadyDepositedOrPaid(BookingDetailDTO detail) {
        String status = detail.getTrangThaiHoaDon();
        return "Paid".equalsIgnoreCase(status)
                || "PartiallyPaid".equalsIgnoreCase(status)
                || "Partial".equalsIgnoreCase(status);
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
