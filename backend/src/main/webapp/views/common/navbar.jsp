<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar">
    <div class="navbar-inner">
        <div class="nav-brand">
            <a href="${pageContext.request.contextPath}/index.jsp">
                HOTEL MANAGEMENT SYSTEM <span class="nav-brand-sub">| Nhóm 10</span>
            </a>
        </div>

        <div class="nav-links">
            <a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">Trang Chủ</a>

            <c:choose>
                <%-- Trường hợp 1: Chưa đăng nhập --%>
                <c:when test="${empty sessionScope.CURRENT_USER}">
                    <a href="${pageContext.request.contextPath}/customer/search-rooms" class="nav-link">Tìm Phòng</a>
                    <a href="${pageContext.request.contextPath}/customer/booking" class="nav-link flex items-center gap-2">
                        Rà Soát Đơn
                        <c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
                            <span class="count-badge badge-warning">
                                ${sessionScope.BOOKING_CART.totalRoomCount}
                            </span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/login" class="nav-link">Đăng Nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="navbar-cta">
                        Đăng Ký
                    </a>
                </c:when>

                <%-- Trường hợp 2: Đã đăng nhập --%>
                <c:otherwise>
                    <%-- Menu theo vai trò --%>
                    <c:if test="${sessionScope.CURRENT_USER.customer}">
                        <a href="${pageContext.request.contextPath}/customer/home" class="nav-link">Đặt Phòng</a>
                        <a href="${pageContext.request.contextPath}/customer/history" class="nav-link">Lịch Sử Đặt</a>
                        <a href="${pageContext.request.contextPath}/customer/booking" class="nav-link flex items-center gap-2">
                            Rà Soát Đơn Đặt
                            <c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
                                <span class="count-badge badge-warning">
                                    ${sessionScope.BOOKING_CART.totalRoomCount}
                                </span>
                            </c:if>
                        </a>
                    </c:if>
                    <c:if test="${sessionScope.CURRENT_USER.receptionist}">
                        <a href="${pageContext.request.contextPath}/receptionist/room-map" class="nav-link">Sơ Đồ Phòng</a>
                        <a href="${pageContext.request.contextPath}/receptionist/checkin" class="nav-link">Quầy Tiếp Đón</a>
                        <a href="${pageContext.request.contextPath}/receptionist/refunds" class="nav-link">Hoàn Cọc</a>
                    </c:if>
                    <c:if test="${sessionScope.CURRENT_USER.housekeeper}">
                        <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="nav-link">Buồng Phòng</a>
                    </c:if>
                    <c:if test="${sessionScope.CURRENT_USER.manager}">
                        <a href="${pageContext.request.contextPath}/manager/hotel-config" class="nav-link">Quản Trị</a>
                    </c:if>

                    <span class="text-secondary">|</span>
                    <span class="fw-semibold">
                        ${sessionScope.CURRENT_USER.hoTen}
                        <span class="pill ml-1">
                            ${sessionScope.CURRENT_USER.role}
                        </span>
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger btn-sm">
                        Đăng Xuất
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>