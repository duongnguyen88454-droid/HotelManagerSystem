package com.mycompany.hotelmanagersystem.room.controller;

import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.model.RoomType;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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

        try {
            List<AvailableRoomDTO> roomList = roomService.searchRooms(checkIn, checkOut, guests, roomType);
            request.setAttribute("roomList", roomList);
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

        request.getRequestDispatcher("/views/room/room_list.jsp").forward(request, response);
    }
}
