package com.mycompany.hotelmanagersystem.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;

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
        response.setContentType("text/html;charset=UTF-8");
        
        // Chuyển tiếp request đến Servlet / JSP tiếp theo
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Hủy filter khi ứng dụng dừng
    }
}
