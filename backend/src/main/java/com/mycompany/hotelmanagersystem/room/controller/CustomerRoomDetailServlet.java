package com.mycompany.hotelmanagersystem.room.controller;

import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet(name = "CustomerRoomDetailServlet", urlPatterns = { "/customer/room-detail" })
public class CustomerRoomDetailServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String maPhong = request.getParameter("maPhong");
        if (maPhong == null || maPhong.trim().isEmpty()) {
            maPhong = request.getParameter("roomId");
        }
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");

        try {
            AvailableRoomDTO room = roomService.getRoomBookingDetail(maPhong, checkIn, checkOut);
            request.setAttribute("room", room);
            request.setAttribute("paramCheckIn", (checkIn != null && !checkIn.trim().isEmpty()) ? checkIn.trim() : LocalDate.now().toString());
            request.setAttribute("paramCheckOut", (checkOut != null && !checkOut.trim().isEmpty()) ? checkOut.trim() : LocalDate.now().plusDays(1).toString());
            request.getRequestDispatcher("/views/room/room_detail.jsp").forward(request, response);
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms?error="
                    + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }
}
