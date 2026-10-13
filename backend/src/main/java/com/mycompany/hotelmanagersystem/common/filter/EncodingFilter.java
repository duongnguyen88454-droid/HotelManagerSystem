package com.mycompany.hotelmanagersystem.common.filter;

import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

/**
 * EncodingFilter - Tự động ép toàn bộ Request & Response sang UTF-8.
 * Đảm bảo hiển thị và lưu trữ tiếng Việt có dấu chuẩn 100%, không bị lỗi font (???).
 */
@WebFilter(filterName = "EncodingFilter", urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    private static final String ENCODING = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo filter
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Ép mã hóa UTF-8 cho cả chiều gửi lên và chiều phản hồi về
        request.setCharacterEncoding(ENCODING);
        response.setCharacterEncoding(ENCODING);

        if (request instanceof HttpServletRequest) {
            HttpServletRequest httpRequest = (HttpServletRequest) request;
            String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
            // Chỉ ép Content-Type text/html cho trang động, không đè lên tài nguyên tĩnh (/assets/)
            if (!path.startsWith("/assets/")) {
                response.setContentType("text/html;charset=UTF-8");
            }
        }
        
        // Chuyển tiếp request đến Servlet / JSP tiếp theo
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Hủy filter khi ứng dụng dừng
    }
}
