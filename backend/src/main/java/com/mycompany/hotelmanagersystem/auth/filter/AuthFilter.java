package com.mycompany.hotelmanagersystem.auth.filter;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Set;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/customer/*",
        "/receptionist/*",
        "/housekeeper/*",
        "/manager/*",
        "/cashier/*"
})
public class AuthFilter implements Filter {

    /**
     * Danh mục các tuyến đường công khai cho phép khách vãng lai truy cập tự do mà không cần đăng nhập.
     */
    private static final Set<String> PUBLIC_PATHS = Set.of(
            "/customer/search-rooms",
            "/customer/room-detail"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String contextPath = request.getContextPath();
        String path = request.getRequestURI().substring(contextPath.length());

        // 1. Tuyến đường công khai -> Bỏ qua kiểm tra xác thực
        if (isPublicPath(path)) {
            chain.doFilter(request, response);
            return;
        }

        // 2. Kiểm tra phiên đăng nhập (Chưa đăng nhập -> Chuyển hướng về Login)
        HttpSession session = request.getSession(false);
        UserSessionDTO currentUser = (session != null) ? (UserSessionDTO) session.getAttribute("CURRENT_USER") : null;
        if (currentUser == null) {
            redirectToLogin(request, response, contextPath, path);
            return;
        }

        // 3. Kiểm tra quyền truy cập theo vai trò
        if (!isAuthorized(path, currentUser.getRole())) {
            handleAccessDenied(request, response, path);
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublicPath(String path) {
        return PUBLIC_PATHS.contains(path);
    }

    private boolean isAuthorized(String path, String role) {
        if (path.startsWith("/customer/")) {
            return "Customer".equalsIgnoreCase(role);
        }
        if (path.startsWith("/receptionist/")) {
            return "Receptionist".equalsIgnoreCase(role);
        }
        if (path.startsWith("/housekeeper/")) {
            return "Housekeeper".equalsIgnoreCase(role);
        }
        if (path.startsWith("/manager/")) {
            return "Manager".equalsIgnoreCase(role);
        }
        if (path.startsWith("/cashier/")) {
            return "Receptionist".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role);
        }
        return false;
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response,
                                 String contextPath, String path) throws IOException {
        String queryString = request.getQueryString();
        String targetPath = (queryString != null && !queryString.isEmpty()) ? path + "?" + queryString : path;
        String encodedTarget = URLEncoder.encode(targetPath, StandardCharsets.UTF_8);
        response.sendRedirect(contextPath + "/login?redirect=" + encodedTarget);
    }

    private void handleAccessDenied(HttpServletRequest request, HttpServletResponse response,
                                    String path) throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        request.setAttribute("deniedPath", path);
        request.getRequestDispatcher("/views/common/error_403.jsp").forward(request, response);
    }

    @Override
    public void destroy() {
    }
}

