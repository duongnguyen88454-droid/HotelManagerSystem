package com.mycompany.hotelmanagersystem.auth.filter;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/customer/*",
        "/receptionist/*",
        "/housekeeper/*",
        "/manager/*",
        "/cashier/*"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // 1. Kiểm tra đã đăng nhập chưa
        if (currentUser == null) {
            response.sendRedirect(contextPath + "/login?redirect=" + java.net.URLEncoder.encode(path, "UTF-8"));
            return;
        }

        // 2. Kiểm tra phân quyền truy cập theo vai trò (Phân lập tuyệt đối 100%)
        String role = currentUser.getMaVaiTro();
        boolean isAuthorized = false;

        if (path.startsWith("/customer/")) {
            isAuthorized = "VT01".equalsIgnoreCase(role); // DUY NHẤT Khách hàng
        } else if (path.startsWith("/receptionist/")) {
            isAuthorized = "VT02".equalsIgnoreCase(role); // DUY NHẤT Lễ tân
        } else if (path.startsWith("/housekeeper/")) {
            isAuthorized = "VT03".equalsIgnoreCase(role); // DUY NHẤT Buồng phòng
        } else if (path.startsWith("/manager/")) {
            isAuthorized = "VT04".equalsIgnoreCase(role); // DUY NHẤT Quản lý
        } else if (path.startsWith("/cashier/")) {
            isAuthorized = "VT02".equalsIgnoreCase(role) || "VT04".equalsIgnoreCase(role); // Lễ tân & Quản lý
        }

        if (isAuthorized) {
            chain.doFilter(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("deniedPath", path);
            request.getRequestDispatcher("/views/common/error_403.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
    }
}
