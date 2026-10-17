<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="portal-sidebar">
    <!-- Tiêu đề thương hiệu khách sạn -->
    <div class="portal-brand">
        <h2 class="portal-brand-title">Hotel Management</h2>
        <div class="portal-brand-sub">Hệ Thống Quản Lý Khách Sạn</div>
    </div>

    <!-- Thanh chức năng phân nhóm theo vai trò -->
    <nav class="portal-nav">
        <c:choose>
            <%-- VAI TRÒ 1: LỄ TÂN (RECEPTIONIST) --%>
            <c:when test="${sessionScope.CURRENT_USER.receptionist}">
                <div class="nav-group-title">Tiếp Đón</div>
                <a href="${pageContext.request.contextPath}/receptionist/timeline"
                    class="portal-nav-item ${param.activeMenu eq 'timeline' ? 'active' : ''}">
                    <span>Sơ Đồ Lịch Phòng</span>
                </a>
                <a href="${pageContext.request.contextPath}/receptionist/room-map"
                    class="portal-nav-item ${param.activeMenu eq 'room_map' ? 'active' : ''}">
                    <span>Danh Sách Phòng</span>
                </a>
                <a href="${pageContext.request.contextPath}/receptionist/checkin"
                    class="portal-nav-item ${param.activeMenu eq 'checkin' ? 'active' : ''}">
                    <span>Quầy Tiếp Đón</span>
                </a>
                <a href="${pageContext.request.contextPath}/receptionist/booking"
                    class="portal-nav-item ${param.activeMenu eq 'booking' ? 'active' : ''}">
                    <span>Đặt Phòng Mới</span>
                </a>

                <div class="nav-group-title">Giao Dịch</div>
                <a href="${pageContext.request.contextPath}/cashier/dashboard"
                    class="portal-nav-item ${param.activeMenu eq 'cashier' ? 'active' : ''}">
                    <span>Quầy Thu Ngân & Check-out</span>
                </a>
                <a href="${pageContext.request.contextPath}/receptionist/refunds"
                    class="portal-nav-item ${param.activeMenu eq 'refunds' ? 'active' : ''}">
                    <span>Xét Duyệt Hoàn Cọc</span>
                </a>
            </c:when>

            <%-- VAI TRÒ 2: BUỒNG PHÒNG (HOUSEKEEPER) --%>
            <c:when test="${sessionScope.CURRENT_USER.housekeeper}">
                <div class="nav-group-title">Buồng Phòng</div>
                <a href="${pageContext.request.contextPath}/housekeeper/tasks"
                    class="portal-nav-item ${param.activeMenu eq 'tasks' ? 'active' : ''}">
                    <span>Danh Sách Nhiệm Vụ</span>
                </a>
            </c:when>

            <%-- VAI TRÒ 3: QUẢN LÝ (MANAGER) --%>
            <c:when test="${sessionScope.CURRENT_USER.manager}">
                <div class="nav-group-title">Vận Hành</div>
                <a href="${pageContext.request.contextPath}/manager/damages"
                    class="portal-nav-item ${param.activeMenu eq 'damages' ? 'active' : ''}">
                    <span>Nghiệm Thu Hư Hại</span>
                    <c:if test="${not empty occupancy and occupancy.soPhongHuHai > 0}">
                        <span class="count-badge">${occupancy.soPhongHuHai}</span>
                    </c:if>
                </a>
                <a href="${pageContext.request.contextPath}/manager/hotel-config"
                    class="portal-nav-item ${param.activeMenu eq 'hotel_config' ? 'active' : ''}">
                    <span>Cấu Hình Khách Sạn</span>
                </a>

                <div class="nav-group-title">Tài Chính</div>
                <a href="${pageContext.request.contextPath}/manager/revenue?type=invoice"
                    class="portal-nav-item ${param.activeMenu eq 'revenue' and (empty param.activeSubMenu or param.activeSubMenu eq 'invoice') ? 'active' : ''}">
                    <span>Doanh Thu Hóa Đơn</span>
                </a>
                <a href="${pageContext.request.contextPath}/manager/revenue?type=room"
                    class="portal-nav-item ${param.activeMenu eq 'revenue' and param.activeSubMenu eq 'room' ? 'active' : ''}">
                    <span>Doanh Thu Tiền Phòng</span>
                </a>
                <a href="${pageContext.request.contextPath}/manager/revenue?type=product"
                    class="portal-nav-item ${param.activeMenu eq 'revenue' and param.activeSubMenu eq 'product' ? 'active' : ''}">
                    <span>Doanh Thu Sản Phẩm</span>
                </a>
                <a href="${pageContext.request.contextPath}/manager/revenue?type=overall"
                    class="portal-nav-item ${param.activeMenu eq 'revenue' and param.activeSubMenu eq 'overall' ? 'active' : ''}">
                    <span>Tổng Quan Doanh Thu</span>
                </a>

                <div class="nav-group-title">Nhân Sự</div>
                <a href="${pageContext.request.contextPath}/manager/employees"
                    class="portal-nav-item ${param.activeMenu eq 'employees' ? 'active' : ''}">
                    <span>Quản Lý Nhân Sự</span>
                </a>
            </c:when>

            <%-- MẶC ĐỊNH / DỰ PHÒNG CHO CÁC VAI TRÒ KHÁC NẾU CÓ --%>
            <c:otherwise>
                <div class="nav-group-title">Hệ Thống Quản Lý</div>
                <a href="${pageContext.request.contextPath}/login"
                    class="portal-nav-item active">
                    <span>Đăng Nhập Quản Trị</span>
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
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm btn-block mt-2">
                Đăng Xuất
            </a>
        </div>
    </div>
</aside>