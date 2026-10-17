<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <jsp:include page="/views/common/header.jsp">
            <jsp:param name="title" value="Đăng Ký Tài Khoản - Hệ Thống Quản Lý Khách Sạn" />
            <jsp:param name="zone" value="public" />
        </jsp:include>
        <jsp:include page="/views/common/navbar.jsp" />

        <main class="container container--narrow">
            <div class="card">
                <div class="card-body">
                    <div class="text-center mb-6">
                        <h1 class="page-title mb-2">Đăng Ký Khách Hàng</h1>
                        <p class="page-subtitle">Email sẽ dùng để đăng nhập hệ thống</p>
                    </div>

                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger" role="alert">
                            <strong>Lỗi:</strong> ${errorMessage}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/register" method="POST"
                        oninput='confirmPassword.setCustomValidity(confirmPassword.value !== password.value ? "Mật khẩu xác nhận không khớp!" : "")'>
                        <div class="form-group">
                            <label for="hoTen" class="form-label">
                                Họ Và Tên <span class="required">*</span>
                            </label>
                            <input type="text" id="hoTen" name="hoTen" value="${oldHoTen}" required pattern=".*\S+.*"
                                title="Họ và tên không được để trống hoặc chỉ chứa khoảng trắng" placeholder=""
                                class="form-control" />
                        </div>

                        <div class="form-group">
                            <label for="email" class="form-label">
                                Địa Chỉ Email <span class="required">*</span>
                            </label>
                            <input type="email" id="email" name="email" value="${oldEmail}" required placeholder=""
                                class="form-control" />
                        </div>

                        <div class="form-group">
                            <label for="password" class="form-label">
                                Mật Khẩu (Tối thiểu 6 ký tự) <span class="required">*</span>
                            </label>
                            <input type="password" id="password" name="password" required minlength="6"
                                placeholder="Nhập mật khẩu bảo vệ" class="form-control" />
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">
                                Xác Nhận Lại Mật Khẩu <span class="required">*</span>
                            </label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required minlength="6"
                                placeholder="Nhập lại mật khẩu" class="form-control" />
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg btn-block mt-4">
                            Đăng Ký Tài Khoản
                        </button>
                    </form>

                    <hr />

                    <div class="text-center text-sm">
                        Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" class="fw-semibold">Đăng
                            nhập ngay</a>
                    </div>
                </div>
            </div>
        </main>

        <jsp:include page="/views/common/footer.jsp" />