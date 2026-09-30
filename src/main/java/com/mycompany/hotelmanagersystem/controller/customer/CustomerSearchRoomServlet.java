package com.mycompany.hotelmanagersystem.controller.customer;

import com.mycompany.hotelmanagersystem.dto.room.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.model.RoomType;
import com.mycompany.hotelmanagersystem.service.room.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "CustomerSearchRoomServlet", urlPatterns = {"/customer/search-rooms"})
public class CustomerSearchRoomServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String guests = request.getParameter("guests");
        String roomType = request.getParameter("roomType");

        // Gán giá trị mặc định nếu người dùng truy cập trực tiếp
        if (checkIn == null || checkIn.trim().isEmpty()) {
            checkIn = LocalDate.now().toString();
        }
        if (checkOut == null || checkOut.trim().isEmpty()) {
            checkOut = LocalDate.now().plusDays(1).toString();
        }

        // [BUG-02 FIX] Validate checkOut > checkIn trước khi query DB
        try {
            LocalDate dateIn  = LocalDate.parse(checkIn.trim());
            LocalDate dateOut = LocalDate.parse(checkOut.trim());
            if (!dateOut.isAfter(dateIn)) {
                request.setAttribute("errorMessage",
                    "Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 ngày. Vui lòng chọn lại!");
                request.setAttribute("roomList", new java.util.ArrayList<>());
            } else {
                List<AvailableRoomDTO> roomList = roomService.searchRooms(checkIn, checkOut, guests, roomType);
                request.setAttribute("roomList", roomList);
            }
        } catch (java.time.format.DateTimeParseException ex) {
            request.setAttribute("errorMessage", "Định dạng ngày không hợp lệ, vui lòng chọn lại từ lịch!");
            request.setAttribute("roomList", new java.util.ArrayList<>());
        } catch (IllegalArgumentException ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("roomList", new java.util.ArrayList<>());
        }

        List<RoomType> roomTypes = roomService.getActiveRoomTypes();
        request.setAttribute("roomTypes", roomTypes);

        request.setAttribute("paramCheckIn", checkIn);
        request.setAttribute("paramCheckOut", checkOut);
        request.setAttribute("paramGuests", guests);
        request.setAttribute("paramRoomType", roomType);

        request.getRequestDispatcher("/views/customer/room_list.jsp").forward(request, response);
    }
}
