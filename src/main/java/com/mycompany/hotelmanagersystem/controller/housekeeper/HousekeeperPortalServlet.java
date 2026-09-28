package com.mycompany.hotelmanagersystem.controller.housekeeper;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "HousekeeperPortalServlet", urlPatterns = {"/housekeeper/tasks"})
public class HousekeeperPortalServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/housekeeper/tasks.jsp").forward(request, response);
    }
}
