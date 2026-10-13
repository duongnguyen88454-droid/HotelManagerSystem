<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="portal-sidebar">
    <!-- Tiêu đề thương hiệu khách sạn -->
    <div class="portal-brand">
        <h2 class="portal-brand-title">Hotel Management</h2>
        <div class="portal-brand-subtitle">Hệ Thống Quản Lý Khách Sạn</div>
    </div>

    <!-- Thanh chức năng phân nhóm theo vai trò -->
    <nav class="portal-nav">
        <c:choose>
            <%-- VAI TRÒ 1: LỄ TÂN (RECEPTIONIST) --%>
            <c:when test="${sessionScope.CURRENT_USER.receptionist}">
                <div class="nav-group-title">Tiếp Đón</div>
                <a href="${pageContext.request.contextPath}/receptionist/checkin" 
                   class="portal-nav-item ${param.activeMenu eq 'checkin' ? 'active' : ''}">
                    <span>Quầy Tiếp Đón Check-in</span>
                </a>
                <a href="${pageContext.request.contextPath}/receptionist/booking" 
                   class="portal-nav-item ${param.activeMenu eq 'booking' ? 'active' : ''}">
                    <span>Đặt Phòng Mới (Walk-in)</span>
                </a>
                <a href="${pageContext.request.contextPath}/receptionist/room-map" 
                   class="portal-nav-item ${param.activeMenu eq 'room_map' ? 'active' : ''}">
                    <span>Danh Sách Phòng</span>
                </a>

                <div class="nav-group-title">Thu Ngân</div>
                <a href="${pageContext.request.contextPath}/cashier/dashboard" 
                   class="portal-nav-item ${param.activeMenu eq 'cashier' ? 'active' : ''}">
                    <span>Quầy Thu Ngân</span>
                </a>

                <div class="nav-group-title">Hệ Thống</div>
                <a href="${pageContext.request.contextPath}/index.jsp" class="portal-nav-item">
                    <span>Cổng Khách Hàng</span>
                </a>
            </c:when>

            <%-- VAI TRÒ 2: BUỒNG PHÒNG (HOUSEKEEPER) --%>
            <c:when test="${sessionScope.CURRENT_USER.housekeeper}">
                <div class="nav-group-title">Buồng Phòng</div>
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" 
                   class="portal-nav-item ${param.activeMenu eq 'tasks' ? 'active' : ''}">
                    <span>Danh Sách Nhiệm Vụ</span>
                </a>

                <div class="nav-group-title">Hệ Thống</div>
                <a href="${pageContext.request.contextPath}/index.jsp" class="portal-nav-item">
                    <span>Cổng Khách Hàng</span>
                </a>
            </c:when>

            <%-- VAI TRÒ 3: QUẢN LÝ (MANAGER) --%>
            <c:when test="${sessionScope.CURRENT_USER.manager}">
                <div class="nav-group-title">Tổng Quan</div>
                <a href="${pageContext.request.contextPath}/manager/dashboard" 
                   class="portal-nav-item ${param.activeMenu eq 'dashboard' ? 'active' : ''}">
                    <span>Dashboard Quản Trị</span>
                </a>

                <div class="nav-group-title">Vận Hành</div>
                <a href="${pageContext.request.contextPath}/manager/damages" 
                   class="portal-nav-item ${param.activeMenu eq 'damages' ? 'active' : ''}">
                    <span>Nghiệm Thu Hư Hại</span>
                    <c:if test="${not empty occupancy and occupancy.soPhongHuHai > 0}">
                        <span class="portal-nav-badge">${occupancy.soPhongHuHai}</span>
                    </c:if>
                </a>
                <a href="${pageContext.request.contextPath}/manager/hotel-config" 
                   class="portal-nav-item ${param.activeMenu eq 'hotel_config' ? 'active' : ''}">
                    <span>Cấu Hình Khách Sạn</span>
                </a>

                <div class="nav-group-title">Tài Chính</div>
                <a href="${pageContext.request.contextPath}/manager/revenue" 
                   class="portal-nav-item ${param.activeMenu eq 'revenue' ? 'active' : ''}">
                    <span>Báo Cáo Doanh Thu</span>
                </a>
                <a href="${pageContext.request.contextPath}/manager/services" 
                   class="portal-nav-item ${param.activeMenu eq 'services' ? 'active' : ''}">
                    <span>Phân Tích Dịch Vụ</span>
                </a>
                <a href="${pageContext.request.contextPath}/manager/refunds" 
                   class="portal-nav-item ${param.activeMenu eq 'refunds' ? 'active' : ''}">
                    <span>Xét Duyệt Hoàn Cọc</span>
                </a>

                <div class="nav-group-title">Nhân Sự & Thu Ngân</div>
                <a href="${pageContext.request.contextPath}/manager/employees" 
                   class="portal-nav-item ${param.activeMenu eq 'employees' ? 'active' : ''}">
                    <span>Quản Lý Nhân Sự</span>
                </a>
                <a href="${pageContext.request.contextPath}/cashier/dashboard" 
                   class="portal-nav-item ${param.activeMenu eq 'cashier' ? 'active' : ''}">
                    <span>Quầy Thu Ngân</span>
                </a>

                <div class="nav-group-title">Hệ Thống</div>
                <a href="${pageContext.request.contextPath}/index.jsp" class="portal-nav-item">
                    <span>Cổng Khách Hàng</span>
                </a>
            </c:when>

            <%-- MẶC ĐỊNH / DỰ PHÒNG CHO CÁC VAI TRÒ KHÁC NẾU CÓ --%>
            <c:otherwise>
                <div class="nav-group-title">Chức Năng</div>
                <a href="${pageContext.request.contextPath}/index.jsp" class="portal-nav-item active">
                    <span>Trang Chủ</span>
                </a>
            </c:otherwise>
        </c:choose>
    </nav>

    <!-- Thẻ thông tin cá nhân nhân viên ở chân thanh chức năng -->
    <div class="portal-sidebar-footer">
        <div class="portal-user-card">
            <div class="portal-user-name">${sessionScope.CURRENT_USER.hoTen}</div>
            <div class="portal-user-role">
                Vai trò: ${sessionScope.CURRENT_USER.role} 
                <c:if test="${not empty sessionScope.CURRENT_USER.maDinhDanh}">
                    (${sessionScope.CURRENT_USER.maDinhDanh})
                </c:if>
            </div>
            <a href="${pageContext.request.contextPath}/logout" class="portal-logout-btn">
                Đăng Xuất
            </a>
        </div>
    </div>
</aside>
