<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <jsp:include page="/views/common/header.jsp">
            <jsp:param name="title" value="Đăng Nhập - Hệ Thống Quản Lý Khách Sạn" />
            <jsp:param name="zone" value="public" />
        </jsp:include>
        <jsp:include page="/views/common/navbar.jsp" />

        <main class="container container--narrow">
            <div class="card">
                <div class="card-body">
                    <div class="text-center mb-6">
                        <h1 class="page-title mb-2">Đăng Nhập</h1>
                        <p class="page-subtitle">Hệ Thống Quản Lý Khách Sạn - Nhóm 10</p>
                    </div>

                    <%-- Thông báo lỗi khi đăng nhập thất bại --%>
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger" role="alert">
                                <strong>Lỗi:</strong> ${errorMessage}
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/login" method="POST">
                            <c:if test="${not empty param.redirect}">
                                <input type="hidden" name="redirect" value="${param.redirect}" />
                            </c:if>

                            <div class="form-group">
                                <label for="loginIdentifier" class="form-label">
                                    Email Đăng Nhập <span class="required">*</span>
                                </label>
                                <input type="email" id="loginIdentifier" name="loginIdentifier" class="form-control"
                                    value="${oldIdentifier}" placeholder="" required />
                            </div>

                            <div class="form-group">
                                <label for="password" class="form-label">
                                    Mật Khẩu <span class="required">*</span>
                                </label>
                                <input type="password" id="password" name="password" class="form-control" placeholder=""
                                    required />
                            </div>

                            <button type="submit" class="btn btn-primary btn-lg btn-block mt-4">
                                Đăng Nhập
                            </button>
                        </form>

                        <hr />

                        <div class="text-center text-sm">
                            Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register"
                                class="fw-semibold">Đăng ký tài khoản mới</a>
                        </div>
                </div>
            </div>
        </main>

        <jsp:include page="/views/common/footer.jsp" />