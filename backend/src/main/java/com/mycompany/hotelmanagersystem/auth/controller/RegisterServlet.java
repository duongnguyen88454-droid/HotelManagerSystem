package com.mycompany.hotelmanagersystem.auth.controller;

import com.mycompany.hotelmanagersystem.auth.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String hoTen = request.getParameter("hoTen");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            boolean success = authService.register(hoTen, email, password, confirmPassword);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/login?msg=register_success");
            } else {
                request.setAttribute("errorMessage", "Đăng ký không thành công. Vui lòng thử lại!");
                request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
            }
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("oldHoTen", hoTen);
            request.setAttribute("oldEmail", email);
            request.getRequestDispatcher("/views/auth/register.jsp").forward(request, response);
        }
    }
}
