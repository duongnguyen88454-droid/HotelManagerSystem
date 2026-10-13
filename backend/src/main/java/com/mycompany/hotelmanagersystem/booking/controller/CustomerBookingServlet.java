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

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
        BookingCartDTO cart = getOrCreateCart(session);

        String roomId = resolveRoomIdParam(request);
        String checkIn = resolveCheckInParam(request);
        String checkOut = resolveCheckOutParam(request);

        AvailableRoomDTO currentRoom = resolveCurrentRoom(request, roomId, checkIn, checkOut);

        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;
        Customer savedGuest = resolveSavedGuest(session, currentUser);

        String cartConflictMsg = findUnavailableRoomMessage(cart);
        if (cartConflictMsg != null) {
            request.setAttribute("errorMessage", cartConflictMsg);
        }

        request.setAttribute("currentRoom", currentRoom);
        request.setAttribute("bookingCart", cart);
        request.setAttribute("activeServices", bookingService.getActiveServices());
        request.setAttribute("savedGuest", savedGuest);
        request.setAttribute("paramCheckIn", checkIn);
        request.setAttribute("paramCheckOut", checkOut);

        request.getRequestDispatcher("/views/booking/booking_form.jsp").forward(request, response);
    }

    private String findUnavailableRoomMessage(BookingCartDTO cart) {
        if (cart == null || cart.getItems() == null) {
            return null;
        }
        for (CartRoomItemDTO item : cart.getItems().values()) {
            if (!roomService.isRoomAvailable(item.getMaPhong(), item.getNgayNhan(), item.getNgayTra())) {
                return "Phòng " + item.getSoPhong()
                        + " hiện vừa có khách đặt trong khoảng thời gian bạn chọn. Vui lòng xóa phòng khỏi giỏ trước khi chốt đơn!";
            }
        }
        return null;
    }

    private BookingCartDTO getOrCreateCart(HttpSession session) {
        BookingCartDTO cart = (BookingCartDTO) session.getAttribute("BOOKING_CART");
        if (cart == null) {
            cart = new BookingCartDTO();
            session.setAttribute("BOOKING_CART", cart);
        }
        return cart;
    }

    private String resolveRoomIdParam(HttpServletRequest request) {
        String roomId = request.getParameter("roomId");
        return (roomId != null && !roomId.trim().isEmpty()) ? roomId.trim() : request.getParameter("maPhong");
    }

    private String resolveCheckInParam(HttpServletRequest request) {
        String checkIn = request.getParameter("checkIn");
        return (checkIn != null && !checkIn.trim().isEmpty()) ? checkIn.trim() : LocalDate.now().toString();
    }

    private String resolveCheckOutParam(HttpServletRequest request) {
        String checkOut = request.getParameter("checkOut");
        return (checkOut != null && !checkOut.trim().isEmpty()) ? checkOut.trim() : LocalDate.now().plusDays(1).toString();
    }

    private AvailableRoomDTO resolveCurrentRoom(HttpServletRequest request, String roomId, String checkIn, String checkOut) {
        if (roomId == null || roomId.trim().isEmpty()) {
            return null;
        }
        try {
            return roomService.getRoomBookingDetail(roomId.trim(), checkIn, checkOut);
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            return null;
        }
    }

    private Customer resolveSavedGuest(HttpSession session, UserSessionDTO currentUser) {
        if (currentUser == null || session == null) {
            return null;
        }
        String savedCccd = (String) session.getAttribute("SAVED_CCCD");
        if (savedCccd != null && !savedCccd.trim().isEmpty()) {
            return customerService.findCustomerByCCCD(savedCccd.trim());
        }
        return null;
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

            response.sendRedirect(request.getContextPath() + "/customer/deposit?bookingId=" + createdBookingId);
        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            doGet(request, response);
        } catch (Exception ex) {
            request.setAttribute("errorMessage", "Đã xảy ra lỗi trong quá trình đặt phòng: " + ex.getMessage());
            doGet(request, response);
        }
    }
}
