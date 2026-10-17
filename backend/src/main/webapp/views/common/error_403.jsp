<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="403 - Quyền Truy Cập Bị Từ Chối"/>
    <jsp:param name="zone" value="public"/>
</jsp:include>
<jsp:include page="navbar.jsp"/>

<main class="container container--narrow text-center">
    <div class="card">
        <div class="card-body">
            <h1 class="page-title text-danger mb-2">403 - Truy Cập Bị Từ Chối</h1>
            <p class="text-secondary text-lg mb-4">
                Bạn không có quyền hạn truy cập vào đường dẫn: <br/>
                <code class="mono text-danger">${deniedPath}</code>
            </p>
            <p class="text-muted text-sm mb-6">
                Vai trò hiện tại của bạn là: <strong>${sessionScope.CURRENT_USER.role}</strong>.
            </p>
            <div class="flex justify-center gap-3">
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary">
                    &larr; Về Trang Chủ
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">
                    Đổi Tài Khoản Khác
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="footer.jsp"/>
