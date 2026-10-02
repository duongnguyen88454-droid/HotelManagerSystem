package com.mycompany.hotelmanagersystem.auth.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.auth.service.AuthService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
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
            String redirectUrl = authService.getRedirectUrlByRole(request.getContextPath(), currentUser.getMaVaiTro());
            response.sendRedirect(redirectUrl);
            return;
        }

        request.getRequestDispatcher("/views/common/login.jsp").forward(request, response);
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
                response.sendRedirect(redirectTarget);
            } else {
                String redirectUrl = authService.getRedirectUrlByRole(request.getContextPath(), user.getMaVaiTro());
                response.sendRedirect(redirectUrl);
            }
        } catch (Exception ex) {
            request.setAttribute("errorMessage", ex.getMessage());
            request.setAttribute("oldIdentifier", loginIdentifier);
            request.getRequestDispatcher("/views/common/login.jsp").forward(request, response);
        }
    }
}
