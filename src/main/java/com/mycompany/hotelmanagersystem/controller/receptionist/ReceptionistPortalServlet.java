package com.mycompany.hotelmanagersystem.controller.receptionist;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ReceptionistPortalServlet", urlPatterns = {"/receptionist/room-map", "/receptionist/checkin"})
public class ReceptionistPortalServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/receptionist/room_map.jsp").forward(request, response);
    }
}
