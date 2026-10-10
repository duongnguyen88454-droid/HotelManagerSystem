<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar"
    style="background: #1a365d; padding: 12px 24px; display: flex; justify-content: space-between; align-items: center; color: white;">
    <div class="nav-brand" style="font-size: 19px; font-weight: 700; letter-spacing: 0.5px;">
        <a href="${pageContext.request.contextPath}/index.jsp" style="color: #ffffff; text-decoration: none;">
            HOTEL MANAGEMENT SYSTEM <span style="font-size: 12px; color: #c5a880; font-weight: normal;">| Nhóm 10</span>
        </a>
    </div>

    <div class="nav-links" style="display: flex; gap: 15px; align-items: center; font-size: 14px;">
        <a href="${pageContext.request.contextPath}/index.jsp"
            style="color: #edf2f7; text-decoration: none;">Trang Chủ</a>

        <c:choose>
            <%-- Trường hợp 1: Chưa đăng nhập --%>
            <c:when test="${empty sessionScope.CURRENT_USER}">
                <a href="${pageContext.request.contextPath}/customer/search-rooms"
                    style="color: #edf2f7; text-decoration: none;">Tìm Phòng</a>
                <a href="${pageContext.request.contextPath}/customer/booking"
                    style="color: #edf2f7; text-decoration: none; display: inline-flex; align-items: center; gap: 5px;">
                    Rà Soát Đơn
                    <c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
                        <span style="background: #dd6b20; color: #ffffff; padding: 1px 6px; border-radius: 10px; font-weight: 700; font-size: 11px;">
                            ${sessionScope.BOOKING_CART.totalRoomCount}
                        </span>
                    </c:if>
                </a>
                <a href="${pageContext.request.contextPath}/login"
                    style="color: #edf2f7; text-decoration: none;">Đăng Nhập</a>
                <a href="${pageContext.request.contextPath}/register"
                    style="background: #c5a880; color: #1a365d; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-weight: 600;">
                    Đăng Ký
                </a>
            </c:when>

            <%-- Trường hợp 2: Đã đăng nhập --%>
            <c:otherwise>
                <%-- Menu theo vai trò --%>
                <c:if test="${sessionScope.CURRENT_USER.customer}">
                    <a href="${pageContext.request.contextPath}/customer/home"
                        style="color: #edf2f7; text-decoration: none;">Đặt Phòng</a>
                    <a href="${pageContext.request.contextPath}/customer/history"
                        style="color: #edf2f7; text-decoration: none;">Lịch Sử Đặt</a>
                    <a href="${pageContext.request.contextPath}/customer/booking"
                        style="color: #edf2f7; text-decoration: none; display: inline-flex; align-items: center; gap: 5px;">
                        Rà Soát Đơn Đặt
                        <c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
                            <span style="background: #dd6b20; color: #ffffff; padding: 1px 6px; border-radius: 10px; font-weight: 700; font-size: 11px;">
                                ${sessionScope.BOOKING_CART.totalRoomCount}
                            </span>
                        </c:if>
                    </a>
                </c:if>
                <c:if test="${sessionScope.CURRENT_USER.receptionist}">
                    <a href="${pageContext.request.contextPath}/receptionist/room-map"
                        style="color: #edf2f7; text-decoration: none;">Sơ Đồ Phòng</a>
                    <a href="${pageContext.request.contextPath}/receptionist/checkin"
                        style="color: #edf2f7; text-decoration: none;">Quầy Tiếp Đón</a>
                    <a href="${pageContext.request.contextPath}/cashier/dashboard"
                        style="color: #edf2f7; text-decoration: none;">Thu Ngân</a>
                </c:if>
                <c:if test="${sessionScope.CURRENT_USER.housekeeper}">
                    <a href="${pageContext.request.contextPath}/housekeeper/tasks"
                        style="color: #edf2f7; text-decoration: none;">Buồng Phòng</a>
                </c:if>
                <c:if test="${sessionScope.CURRENT_USER.manager}">
                    <a href="${pageContext.request.contextPath}/manager/dashboard"
                        style="color: #edf2f7; text-decoration: none;">Quản Trị</a>
                    <a href="${pageContext.request.contextPath}/cashier/dashboard"
                        style="color: #edf2f7; text-decoration: none;">Thu Ngân</a>
                </c:if>

                <span style="color: #cbd5e0; margin-left: 10px;">|</span>
                <span style="color: #feebc8; font-weight: 600;">
                    ${sessionScope.CURRENT_USER.hoTen}
                    <span style="font-size: 11px; background: rgba(255,255,255,0.2); padding: 2px 6px; border-radius: 4px; margin-left: 4px;">
                        ${sessionScope.CURRENT_USER.role}
                    </span>
                </span>
                <a href="${pageContext.request.contextPath}/logout"
                    style="background: #e53e3e; color: white; padding: 5px 10px; border-radius: 4px; text-decoration: none; font-size: 13px;">
                    Đăng Xuất
                </a>
            </c:otherwise>
        </c:choose>
    </div>
</nav>