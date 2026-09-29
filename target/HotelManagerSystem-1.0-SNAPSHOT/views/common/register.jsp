<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Đăng Ký Tài Khoản - Nhóm 10 Hotel"/>
</jsp:include>
<jsp:include page="navbar.jsp"/>

<div class="container" style="max-width: 520px; margin-top: 30px; margin-bottom: 50px;">
    <div class="card shadow-sm" style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 30px;">
        <div style="text-align: center; margin-bottom: 25px;">
            <h2 style="color: #1a365d; margin-bottom: 8px;">ĐĂNG KÝ KHÁCH HÀNG</h2>
            <p style="color: #718096; font-size: 14px;">Email và Số điện thoại sẽ dùng để đăng nhập hệ thống</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" style="margin-bottom: 20px;">
                <strong>⚠️ Lỗi:</strong> ${errorMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="POST">
            <div class="form-group" style="margin-bottom: 14px;">
                <label for="hoTen" style="display: block; font-weight: 600; margin-bottom: 4px; color: #2d3748;">
                    Họ và Tên: <span style="color: red;">*</span>
                </label>
                <input type="text" id="hoTen" name="hoTen" value="${oldHoTen}" required placeholder="VD: Trần Văn Nam"
                       style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;"/>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label for="email" style="display: block; font-weight: 600; margin-bottom: 4px; color: #2d3748;">
                    Địa chỉ Email (Dùng để đăng nhập): <span style="color: red;">*</span>
                </label>
                <input type="email" id="email" name="email" value="${oldEmail}" required placeholder="VD: nam.tran@gmail.com"
                       style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;"/>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label for="soDT" style="display: block; font-weight: 600; margin-bottom: 4px; color: #2d3748;">
                    Số điện thoại (Dùng để đăng nhập): <span style="color: red;">*</span>
                </label>
                <input type="tel" id="soDT" name="soDT" value="${oldSoDT}" required placeholder="VD: 0912345678"
                       style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;"/>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label for="password" style="display: block; font-weight: 600; margin-bottom: 4px; color: #2d3748;">
                    Mật khẩu: <span style="color: red;">*</span>
                </label>
                <input type="password" id="password" name="password" required placeholder="Nhập mật khẩu bảo vệ"
                       style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;"/>
            </div>

            <div class="form-group" style="margin-bottom: 20px;">
                <label for="confirmPassword" style="display: block; font-weight: 600; margin-bottom: 4px; color: #2d3748;">
                    Xác nhận lại Mật khẩu: <span style="color: red;">*</span>
                </label>
                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu"
                       style="width: 100%; padding: 10px; border: 1px solid #cbd5e0; border-radius: 6px;"/>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 16px; font-weight: 600; background: #c5a880; color: #1a365d; border: none; border-radius: 6px; cursor: pointer;">
                Đăng Ký Tài Khoản
            </button>
        </form>

        <div style="text-align: center; margin-top: 16px; font-size: 14px;">
            Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" style="color: #2b6cb0; text-decoration: none; font-weight: 600;">Đăng nhập ngay</a>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
