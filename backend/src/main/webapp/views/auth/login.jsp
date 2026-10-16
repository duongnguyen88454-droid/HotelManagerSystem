<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <jsp:include page="/views/common/header.jsp">
            <jsp:param name="title" value="Đăng Nhập Hệ Thống - Nhóm 10 Hotel" />
        </jsp:include>
        <jsp:include page="/views/common/navbar.jsp" />

        <div class="container" style="max-width: 480px; margin-top: 40px; margin-bottom: 50px;">
            <div class="card shadow-sm"
                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 30px;">
                <div style="text-align: center; margin-bottom: 25px;">
                    <h2 style="color: #1a365d; margin-bottom: 8px;">ĐĂNG NHẬP</h2>
                    <p style="color: #718096; font-size: 14px;">Hệ Thống Quản Lý Khách Sạn - Nhóm 10</p>
                </div>

                <%-- Thông báo lỗi khi đăng nhập thất bại --%>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" style="margin-bottom: 20px;">
                            <strong>Lỗi:</strong> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="POST">
                        <c:if test="${not empty param.redirect}">
                            <input type="hidden" name="redirect" value="${param.redirect}" />
                        </c:if>

                        <div class="form-group" style="margin-bottom: 16px;">
                            <label for="loginIdentifier"
                                style="display: block; font-weight: 600; margin-bottom: 6px; color: #2d3748;">
                                Email đăng nhập:
                            </label>
                            <input type="email" id="loginIdentifier" name="loginIdentifier" class="form-control"
                                value="${oldIdentifier}" placeholder="VD: an.nguyen@gmail.com" required
                                style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;" />
                        </div>

                        <div class="form-group" style="margin-bottom: 20px;">
                            <label for="password"
                                style="display: block; font-weight: 600; margin-bottom: 6px; color: #2d3748;">
                                Mật khẩu:
                            </label>
                            <input type="password" id="password" name="password" class="form-control"
                                placeholder="Nhập mật khẩu (Mặc định test: 1234)" required
                                style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;" />
                        </div>

                        <button type="submit" class="btn btn-primary"
                            style="width: 100%; padding: 12px; font-size: 16px; font-weight: 600; background: #1a365d; color: white; border: none; border-radius: 6px; cursor: pointer;">
                            Đăng Nhập
                        </button>
                    </form>

                    <hr style="margin: 24px 0; border: 0; border-top: 1px solid #e2e8f0;" />

                    <div style="text-align: center; margin-top: 16px; font-size: 14px;">
                        Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register"
                            style="color: #2b6cb0; text-decoration: none; font-weight: 600;">Đăng ký tài khoản
                            mới</a>
                    </div>
            </div>
        </div>
        <jsp:include page="/views/common/footer.jsp" />