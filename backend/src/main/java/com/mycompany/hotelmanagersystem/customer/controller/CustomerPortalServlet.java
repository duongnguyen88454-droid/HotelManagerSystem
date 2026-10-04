package com.mycompany.hotelmanagersystem.customer.controller;

import com.mycompany.hotelmanagersystem.room.model.RoomType;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "CustomerPortalServlet", urlPatterns = {"/customer/home"})
public class CustomerPortalServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate today = LocalDate.now();
        LocalDate tomorrow = today.plusDays(1);

        List<RoomType> roomTypes = roomService.getActiveRoomTypes();

        request.setAttribute("defaultCheckIn", today.toString());
        request.setAttribute("defaultCheckOut", tomorrow.toString());
        request.setAttribute("paramCheckIn", today.toString());
        request.setAttribute("paramCheckOut", tomorrow.toString());
        request.setAttribute("paramGuests", "");
        request.setAttribute("paramRoomType", "ALL");
        request.setAttribute("roomTypes", roomTypes);

        request.getRequestDispatcher("/views/customer/home.jsp").forward(request, response);
    }
}
