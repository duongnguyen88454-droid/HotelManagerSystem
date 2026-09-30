package com.mycompany.hotelmanagersystem.controller.customer;

import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.dto.booking.BookingCartDTO;
import com.mycompany.hotelmanagersystem.dto.booking.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.dto.booking.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.dto.room.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.model.Customer;
import com.mycompany.hotelmanagersystem.model.ServiceItem;
import com.mycompany.hotelmanagersystem.dao.customer.CustomerDAO;
import com.mycompany.hotelmanagersystem.service.booking.BookingService;
import com.mycompany.hotelmanagersystem.service.room.RoomService;

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
    private final CustomerDAO customerDAO = new CustomerDAO();

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
        Customer savedGuest = null;
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;
        if (currentUser != null) {
            savedGuest = customerDAO.getGuestProfileByAccount(currentUser.getMaTaiKhoan(), currentUser.getEmail());
            // Nếu chưa tìm thấy qua DB nhưng trong session có lưu CCCD
            if (savedGuest == null) {
                String savedCccd = (String) session.getAttribute("SAVED_CCCD");
                if (savedCccd != null && !savedCccd.trim().isEmpty()) {
                    savedGuest = customerDAO.findCustomerByCCCD(savedCccd.trim());
                }
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

        String note = request.getParameter("note");
        String customerName = request.getParameter("customerName");
        String customerPhone = request.getParameter("customerPhone");
        String customerEmail = request.getParameter("customerEmail");
        String customerCccd = request.getParameter("customerCccd");

        // Tự động lấy thông tin từ tài khoản hiện tại nếu chưa nhập
        if (customerName == null || customerName.trim().isEmpty()) {
            customerName = currentUser.getHoTen();
        }
        if (customerEmail == null || customerEmail.trim().isEmpty()) {
            customerEmail = currentUser.getEmail();
        }
        if (customerPhone == null || customerPhone.trim().isEmpty()) {
            customerPhone = currentUser.getSoDT();
        }

        // BẮT BUỘC: Tất cả các thuộc tính HoTen, Email, SoDT đều NOT NULL theo quy tắc
        // mới
        if (customerName == null || customerName.trim().isEmpty() ||
                customerEmail == null || customerEmail.trim().isEmpty() ||
                customerPhone == null || customerPhone.trim().isEmpty()) {
            request.setAttribute("errorMessage",
                    "Quy tắc bắt buộc: Họ tên, Email và Số điện thoại của người lưu trú không được để trống!");
            doGet(request, response);
            return;
        }

        // BẮT BUỘC: Kiểm tra CCCD 12 chữ số theo thiết kế CSDL mới (NOT NULL)
        if (customerCccd == null || !customerCccd.trim().matches("^[0-9]{12}$")) {
            request.setAttribute("errorMessage",
                    "Vui lòng nhập đầy đủ và chính xác Số Căn Cước Công Dân (CCCD gồm đúng 12 chữ số)!");
            doGet(request, response);
            return;
        }

        BookingCartDTO cart = (session != null) ? (BookingCartDTO) session.getAttribute("BOOKING_CART") : null;

        // Fallback nếu khách submit đơn lẻ trực tiếp
        if (cart == null || cart.getTotalRoomCount() == 0) {
            String roomId = request.getParameter("roomId");
            if (roomId == null)
                roomId = request.getParameter("maPhong");
            String checkIn = request.getParameter("checkIn");
            String checkOut = request.getParameter("checkOut");
            if (roomId != null && checkIn != null && checkOut != null) {
                try {
                    AvailableRoomDTO roomDetail = roomService.getRoomBookingDetail(roomId.trim(), checkIn.trim(),
                            checkOut.trim());
                    if (roomDetail != null) {
                        if (cart == null) {
                            cart = new BookingCartDTO();
                            session.setAttribute("BOOKING_CART", cart);
                        }
                        CartRoomItemDTO roomItem = new CartRoomItemDTO(
                                roomDetail.getMaPhong(),
                                roomDetail.getSoPhong(),
                                roomDetail.getMaLoaiPhong(),
                                roomDetail.getTenLoaiPhong(),
                                roomDetail.getGiaPhong(),
                                checkIn.trim(),
                                checkOut.trim());
                        cart.addOrUpdateRoom(roomItem);
                    }
                } catch (Exception ex) {
                    request.setAttribute("errorMessage", ex.getMessage());
                    doGet(request, response);
                    return;
                }
            }
        }

        if (cart == null || cart.getTotalRoomCount() == 0) {
            request.setAttribute("errorMessage", "Giỏ hàng của bạn đang trống! Vui lòng chọn ít nhất 1 phòng.");
            doGet(request, response);
            return;
        }

        // Tạo đơn đặt phòng đa phòng trong 1 Transaction duy nhất
        try {
            // Tra cứu hoặc tạo/cập nhật hồ sơ KHACHHANG dựa theo CCCD và liên kết với tài
            // khoản
            String maTaiKhoan = currentUser.getMaTaiKhoan();
            String maKH = customerDAO.findOrUpsertGuestByCCCD(customerName, customerEmail, customerPhone,
                    customerCccd.trim(), maTaiKhoan);

            String createdBookingId = bookingService.createMultiRoomBooking(maKH, maTaiKhoan, cart, note);

            // Cập nhật thông tin khách vào UserSessionDTO & Session Attribute để ghi nhớ
            // cho các lần đặt tiếp theo
            currentUser.setSoDT(customerPhone);
            currentUser.setMaDinhDanh(maKH);
            session.setAttribute("CURRENT_USER", currentUser);
            session.setAttribute("SAVED_CCCD", customerCccd.trim());

            // Xóa giỏ hàng sau khi đặt thành công
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
