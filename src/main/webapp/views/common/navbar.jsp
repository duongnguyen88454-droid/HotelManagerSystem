<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<nav class="navbar">
    <div class="nav-container">
        <a href="${pageContext.request.contextPath}/index.jsp" class="brand">
            🏨 <span>HotelManagerSystem</span>
        </a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/views/guest/home.jsp">Khách hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/views/receptionist/room_map.jsp">Lễ tân</a></li>
            <li><a href="${pageContext.request.contextPath}/views/housekeeper/task_list.jsp">Buồng phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/views/manager/dashboard.jsp">Quản lý</a></li>
            <li><a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.85rem;">Đăng nhập</a></li>
        </ul>
    </div>
</nav>
