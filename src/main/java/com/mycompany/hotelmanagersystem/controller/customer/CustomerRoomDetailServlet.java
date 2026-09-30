package com.mycompany.hotelmanagersystem.controller.customer;

import com.mycompany.hotelmanagersystem.dto.room.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.service.room.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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

        if (checkIn == null || checkIn.trim().isEmpty()) {
            checkIn = LocalDate.now().toString();
        }
        if (checkOut == null || checkOut.trim().isEmpty()) {
            checkOut = LocalDate.now().plusDays(1).toString();
        }

        try {
            AvailableRoomDTO room = roomService.getRoomBookingDetail(maPhong, checkIn, checkOut);
            request.setAttribute("room", room);
            request.setAttribute("paramCheckIn", checkIn);
            request.setAttribute("paramCheckOut", checkOut);
            request.getRequestDispatcher("/views/customer/room_detail.jsp").forward(request, response);
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms?error="
                    + java.net.URLEncoder.encode(ex.getMessage(), "UTF-8"));
        }
    }
}
