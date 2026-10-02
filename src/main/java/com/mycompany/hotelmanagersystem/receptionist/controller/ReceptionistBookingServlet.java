package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.booking.service.BookingService;
import com.mycompany.hotelmanagersystem.customer.model.Customer;
import com.mycompany.hotelmanagersystem.customer.service.CustomerService;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.model.RoomType;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Controller phục vụ nghiệp vụ tiếp nhận đặt phòng trực tiếp tại quầy cho Lễ tân.
 * Hỗ trợ tạo đơn đặt phòng cho khách vãng lai nhận dạng qua CCCD.
 */
@WebServlet(name = "ReceptionistBookingServlet", urlPatterns = {"/receptionist/booking"})
public class ReceptionistBookingServlet extends HttpServlet {

    private BookingService bookingService;
    private RoomService roomService;
    private CustomerService customerService;

    @Override
    public void init() {
        this.bookingService = new BookingService();
        this.roomService = new RoomService();
        this.customerService = new CustomerService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("lookup-customer".equalsIgnoreCase(action)) {
            handleLookupCustomerAjax(request, response);
            return;
        }
        renderBookingPage(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        String cccd = request.getParameter("cccd");
        String hoTen = request.getParameter("hoTen");
        String soDT = request.getParameter("soDT");
        String email = request.getParameter("email");
        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String[] selectedRooms = request.getParameterValues("selectedRooms");
        String actionType = request.getParameter("actionType");
        String note = request.getParameter("note");

        try {
            validateRequiredFields(cccd, hoTen, soDT, checkInStr, checkOutStr);
            if (selectedRooms == null || selectedRooms.length == 0) {
                throw new IllegalArgumentException("Vui lòng tích chọn ít nhất một phòng trống để đặt!");
            }

            // Ghi nhận hồ sơ khách lưu trú qua CCCD (không cần tài khoản web)
            String maKH = customerService.findOrUpsertGuestByCCCD(
                    hoTen.trim(), email != null ? email.trim() : "", soDT.trim(), cccd.trim());

            // Dựng giỏ phòng và dịch vụ
            BookingCartDTO cart = buildCartFromRequest(request, selectedRooms, checkInStr, checkOutStr);

            // Ghi nhận đặt phòng tại quầy
            String maBooking = bookingService.createMultiRoomBooking(maKH, null, cart, note);

            boolean checkInNow = "checkin_now".equalsIgnoreCase(actionType);
            if (checkInNow) {
                response.sendRedirect(request.getContextPath() + "/receptionist/checkin?autoModal=" + maBooking);
            } else {
                response.sendRedirect(request.getContextPath() + "/receptionist/room-map?bookingSuccess=" + maBooking);
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", e.getMessage());
            renderBookingPage(request, response);
        }
    }

    private void renderBookingPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        LocalDate today = LocalDate.now();

        if (checkInStr == null || checkInStr.trim().isEmpty()) {
            checkInStr = today.toString();
        }
        if (checkOutStr == null || checkOutStr.trim().isEmpty()) {
            checkOutStr = today.plusDays(1).toString();
        }

        List<AvailableRoomDTO> availableRooms;
        try {
            availableRooms = roomService.searchRooms(checkInStr, checkOutStr, null, null);
        } catch (Exception e) {
            availableRooms = java.util.Collections.emptyList();
        }
        List<RoomType> roomTypes = roomService.getActiveRoomTypes();
        List<ServiceItem> services = bookingService.getActiveServices();

        request.setAttribute("checkIn", checkInStr);
        request.setAttribute("checkOut", checkOutStr);
        request.setAttribute("availableRooms", availableRooms);
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("services", services);
        request.setAttribute("preselectedRoomId", request.getParameter("maPhong"));

        request.getRequestDispatcher("/views/receptionist/booking_form.jsp").forward(request, response);
    }

    private void handleLookupCustomerAjax(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String cccd = request.getParameter("cccd");
        if (cccd == null || cccd.trim().isEmpty()) {
            response.getWriter().write("{\"found\":false}");
            return;
        }

        Customer c = customerService.findCustomerByCCCD(cccd.trim());
        if (c == null) {
            response.getWriter().write("{\"found\":false}");
            return;
        }

        String json = String.format(
                "{\"found\":true,\"maKH\":\"%s\",\"hoTen\":\"%s\",\"soDT\":\"%s\",\"email\":\"%s\"}",
                escapeJson(c.getMaKH()),
                escapeJson(c.getHoTen()),
                escapeJson(c.getSoDT()),
                escapeJson(c.getEmail() != null ? c.getEmail() : ""));
        response.getWriter().write(json);
    }

    private BookingCartDTO buildCartFromRequest(HttpServletRequest request, String[] selectedRooms,
            String checkInStr, String checkOutStr) {
        BookingCartDTO cart = new BookingCartDTO();
        List<ServiceItem> activeServices = bookingService.getActiveServices();

        for (String roomId : selectedRooms) {
            String soPhong = request.getParameter("soPhong_" + roomId);
            String tenLoaiPhong = request.getParameter("tenLoaiPhong_" + roomId);
            String maLoaiPhong = request.getParameter("maLoaiPhong_" + roomId);
            String donGiaStr = request.getParameter("donGia_" + roomId);

            double donGia = 0.0;
            if (donGiaStr != null) {
                try {
                    donGia = Double.parseDouble(donGiaStr);
                } catch (NumberFormatException ignored) {
                }
            }

            CartRoomItemDTO roomItem = new CartRoomItemDTO(roomId,
                    soPhong != null ? soPhong : roomId,
                    maLoaiPhong != null ? maLoaiPhong : "",
                    tenLoaiPhong != null ? tenLoaiPhong : "",
                    donGia, checkInStr, checkOutStr);

            for (ServiceItem svc : activeServices) {
                String qtyStr = request.getParameter("svc_" + roomId + "_" + svc.getMaDichVu());
                if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                    try {
                        int qty = Integer.parseInt(qtyStr.trim());
                        if (qty > 0) {
                            roomItem.getSelectedServices().add(new CartServiceItemDTO(
                                    svc.getMaDichVu(), svc.getTenDichVu(), svc.getDonGia(), qty));
                        }
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
            roomItem.recalculate();
            cart.addOrUpdateRoom(roomItem);
        }
        return cart;
    }

    private void validateRequiredFields(String cccd, String hoTen, String soDT,
            String checkInStr, String checkOutStr) {
        if (cccd == null || cccd.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập số CCCD của khách lưu trú!");
        }
        if (hoTen == null || hoTen.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập họ và tên khách hàng đại diện!");
        }
        if (soDT == null || soDT.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập số điện thoại liên lạc của khách!");
        }
        if (checkInStr == null || checkOutStr == null) {
            throw new IllegalArgumentException("Vui lòng chọn ngày nhận và ngày trả phòng hợp lệ!");
        }
    }

    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
