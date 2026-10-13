<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="403 - Quyền Truy Cập Bị Từ Chối"/>
</jsp:include>
<jsp:include page="navbar.jsp"/>

<div class="container" style="max-width: 600px; margin-top: 60px; text-align: center;">
    <div class="card" style="padding: 40px; background: white; border-radius: 8px; border: 1px solid #fed7d7;">
        <div style="font-size: 54px; margin-bottom: 10px;">🚫</div>
        <h1 style="color: #c53030; font-size: 28px; margin-bottom: 12px;">403 - TRUY CẬP BỊ TỪ CHỐI</h1>
        <p style="color: #4a5568; font-size: 16px; line-height: 1.6;">
            Bạn không có quyền hạn truy cập vào đường dẫn: <br/>
            <code style="background: #edf2f7; padding: 4px 8px; border-radius: 4px; color: #e53e3e;">${deniedPath}</code>
        </p>
        <p style="color: #718096; font-size: 14px; margin-top: 8px;">
            Vai trò hiện tại của bạn là: <strong>${sessionScope.CURRENT_USER.role}</strong>.
        </p>
        <div style="margin-top: 24px;">
            <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary" 
               style="display: inline-block; padding: 10px 20px; background: #1a365d; color: white; border-radius: 6px; text-decoration: none;">
                ← Về Trang Chủ
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn" 
               style="display: inline-block; padding: 10px 20px; background: #e2e8f0; color: #2d3748; border-radius: 6px; text-decoration: none; margin-left: 10px;">
                Đổi Tài Khoản Khác
            </a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
