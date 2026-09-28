package com.mycompany.hotelmanagersystem.controller.auth;

import com.mycompany.hotelmanagersystem.service.auth.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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
        request.getRequestDispatcher("/views/common/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String hoTen = request.getParameter("hoTen");
        String email = request.getParameter("email");
        String soDT = request.getParameter("soDT");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String cccd = request.getParameter("cccd");

        try {
            boolean success = authService.register(hoTen, email, soDT, password, confirmPassword, cccd);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/login?msg=register_success");
            } else {
                request.setAttribute("errorMessage", "Đăng ký không thành công. Vui lòng thử lại!");
                request.getRequestDispatcher("/views/common/register.jsp").forward(request, response);
            }
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("oldHoTen", hoTen);
            request.setAttribute("oldEmail", email);
            request.setAttribute("oldSoDT", soDT);
            request.setAttribute("oldCccd", cccd);
            request.getRequestDispatcher("/views/common/register.jsp").forward(request, response);
        }
    }
}
