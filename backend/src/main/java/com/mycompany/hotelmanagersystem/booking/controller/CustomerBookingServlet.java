package com.mycompany.hotelmanagersystem.booking.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.customer.model.Customer;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.customer.service.CustomerService;
import com.mycompany.hotelmanagersystem.booking.service.BookingService;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CustomerBookingServlet", urlPatterns = { "/customer/booking" })
@MultipartConfig
public class CustomerBookingServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final BookingService bookingService = new BookingService();
    private final CustomerService customerService = new CustomerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        BookingCartDTO cart = (BookingCartDTO) session.getAttribute("BOOKING_CART");
        if (cart == null) {
            cart = new BookingCartDTO();
            session.setAttribute("BOOKING_CART", cart);
        }

        String roomId = request.getParameter("roomId");
        if (roomId == null)
            roomId = request.getParameter("maPhong");
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String action = request.getParameter("action"); // "prepare", "checkout", "view"

        AvailableRoomDTO currentRoom = null;
        if (roomId != null && !roomId.trim().isEmpty()) {
            if (checkIn == null || checkIn.trim().isEmpty())
                checkIn = LocalDate.now().toString();
            if (checkOut == null || checkOut.trim().isEmpty())
                checkOut = LocalDate.now().plusDays(1).toString();
            try {
                currentRoom = roomService.getRoomBookingDetail(roomId.trim(), checkIn.trim(), checkOut.trim());
            } catch (Exception ex) {
                request.setAttribute("errorMessage", ex.getMessage());
            }
        }

        // Nếu không có phòng hiện tại và giỏ hàng cũng rỗng -> Về trang tìm kiếm
        if (currentRoom == null && cart.getTotalRoomCount() == 0) {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
            return;
        }

        // Tự động tìm thông tin khách hàng lưu trú đã lưu từ trước để Autofill
        // Tra cứu qua CCCD đã lưu trong session (KHACHHANG không còn liên kết MaTaiKhoan)
        Customer savedGuest = null;
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;
        if (currentUser != null) {
            String savedCccd = (String) session.getAttribute("SAVED_CCCD");
            if (savedCccd != null && !savedCccd.trim().isEmpty()) {
                savedGuest = customerService.findCustomerByCCCD(savedCccd.trim());
            }
        }

        List<ServiceItem> activeServices = bookingService.getActiveServices();
        request.setAttribute("currentRoom", currentRoom);
        request.setAttribute("bookingCart", cart);
        request.setAttribute("activeServices", activeServices);
        request.setAttribute("savedGuest", savedGuest);
        request.setAttribute("paramCheckIn", checkIn);
        request.setAttribute("paramCheckOut", checkOut);

        request.getRequestDispatcher("/views/customer/booking_form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=/customer/booking");
            return;
        }

        Customer guest = validateAndExtractGuest(request, currentUser);
        if (guest == null) {
            doGet(request, response);
            return;
        }

        BookingCartDTO cart = resolveBookingCart(request, session);
        if (cart == null || cart.getTotalRoomCount() == 0) {
            if (request.getAttribute("errorMessage") == null) {
                request.setAttribute("errorMessage", "Giỏ hàng của bạn đang trống! Vui lòng chọn ít nhất 1 phòng.");
            }
            doGet(request, response);
            return;
        }

        executeBooking(request, response, session, currentUser, guest, cart);
    }

    private Customer validateAndExtractGuest(HttpServletRequest request, UserSessionDTO currentUser) {
        String name = request.getParameter("customerName");
        String email = request.getParameter("customerEmail");
        String phone = request.getParameter("customerPhone");
        String cccd = request.getParameter("customerCccd");

        if (name == null || name.trim().isEmpty()) {
            name = currentUser.getHoTen();
        }
        if (email == null || email.trim().isEmpty()) {
            email = currentUser.getEmail();
        }
        if (phone == null || phone.trim().isEmpty()) {
            phone = currentUser.getSoDT();
        }

        if (name == null || name.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()) {
            request.setAttribute("errorMessage",
                    "Quy tắc bắt buộc: Họ tên, Email và Số điện thoại của người lưu trú không được để trống!");
            return null;
        }
        if (cccd == null || !cccd.trim().matches("^[0-9]{12}$")) {
            request.setAttribute("errorMessage",
                    "Vui lòng nhập đầy đủ và chính xác Số Căn Cước Công Dân (CCCD gồm đúng 12 chữ số)!");
            return null;
        }
        return new Customer(null, name.trim(), email.trim(), phone.trim(), cccd.trim());
    }

    private BookingCartDTO resolveBookingCart(HttpServletRequest request, HttpSession session) {
        BookingCartDTO cart = (session != null) ? (BookingCartDTO) session.getAttribute("BOOKING_CART") : null;
        if (cart != null && cart.getTotalRoomCount() > 0) {
            return cart;
        }
        return resolveSingleRoomCartFallback(request, session);
    }

    private BookingCartDTO resolveSingleRoomCartFallback(HttpServletRequest request, HttpSession session) {
        String roomId = request.getParameter("roomId");
        if (roomId == null) {
            roomId = request.getParameter("maPhong");
        }
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");

        if (roomId == null || checkIn == null || checkOut == null) {
            return null;
        }

        try {
            AvailableRoomDTO roomDetail = roomService.getRoomBookingDetail(
                    roomId.trim(), checkIn.trim(), checkOut.trim());
            if (roomDetail == null) {
                return null;
            }

            BookingCartDTO cart = new BookingCartDTO();
            cart.addOrUpdateRoom(new CartRoomItemDTO(
                    roomDetail.getMaPhong(),
                    roomDetail.getSoPhong(),
                    roomDetail.getMaLoaiPhong(),
                    roomDetail.getTenLoaiPhong(),
                    roomDetail.getGiaPhong(),
                    checkIn.trim(),
                    checkOut.trim()
            ));
            if (session != null) {
                session.setAttribute("BOOKING_CART", cart);
            }
            return cart;
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            return null;
        }
    }

    private void executeBooking(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session, UserSessionDTO currentUser,
                                Customer guest, BookingCartDTO cart)
            throws ServletException, IOException {
        try {
            String note = request.getParameter("note");
            String maTaiKhoan = currentUser.getMaTaiKhoan();
            String maKH = customerService.findOrUpsertGuestByCCCD(
                    guest.getHoTen(), guest.getEmail(), guest.getSoDT(), guest.getCccd());

            String createdBookingId = bookingService.createMultiRoomBooking(maKH, maTaiKhoan, cart, note);

            currentUser.setSoDT(guest.getSoDT());
            currentUser.setMaDinhDanh(maKH);
            session.setAttribute("CURRENT_USER", currentUser);
            session.setAttribute("SAVED_CCCD", guest.getCccd());
            session.removeAttribute("BOOKING_CART");

            response.sendRedirect(request.getContextPath() + "/customer/booking-detail?maBooking=" + createdBookingId
                    + "&msg=success");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            doGet(request, response);
        } catch (Exception ex) {
            request.setAttribute("errorMessage", "Đã xảy ra lỗi trong quá trình đặt phòng: " + ex.getMessage());
            doGet(request, response);
        }
    }
}
