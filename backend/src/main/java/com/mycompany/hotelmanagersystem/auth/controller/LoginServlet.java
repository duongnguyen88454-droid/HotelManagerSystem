package com.mycompany.hotelmanagersystem.auth.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.auth.service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private AuthService authService;

    @Override
    public void init() {
        this.authService = new AuthService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("CURRENT_USER") != null) {
            UserSessionDTO currentUser = (UserSessionDTO) session.getAttribute("CURRENT_USER");
            String redirectUrl = authService.getRedirectUrlByRole(request.getContextPath(), currentUser.getRole());
            response.sendRedirect(redirectUrl);
            return;
        }

        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String loginIdentifier = request.getParameter("loginIdentifier");
        String password = request.getParameter("password");
        String redirectTarget = request.getParameter("redirect");

        try {
            // Xác thực đăng nhập qua AuthService (Service băm SHA-256 mật khẩu vừa nhập và so khớp với CSDL)
            UserSessionDTO user = authService.login(loginIdentifier, password);

            // Lưu người dùng vào session
            HttpSession session = request.getSession(true);
            session.setAttribute("CURRENT_USER", user);

            if (redirectTarget != null && !redirectTarget.trim().isEmpty() && !redirectTarget.contains("/login")) {
                String target = redirectTarget.trim();
                String finalUrl = target.startsWith(request.getContextPath())
                        ? target
                        : request.getContextPath() + (target.startsWith("/") ? target : "/" + target);
                response.sendRedirect(finalUrl);
            } else {
                String redirectUrl = authService.getRedirectUrlByRole(request.getContextPath(), user.getRole());
                response.sendRedirect(redirectUrl);
            }
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("oldIdentifier", loginIdentifier);
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }
}
