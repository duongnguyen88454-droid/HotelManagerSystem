<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Phân Tích Dịch Vụ Sinh Lời & Tiêu Dùng" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="services" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Phân Tích Dịch Vụ Sinh Lời & Tiêu Dùng</h1>
                <p>Thống kê tần suất sử dụng và doanh thu các dịch vụ gia tăng khách sạn</p>
            </div>
            <div class="portal-header-right">
                <a href="${pageContext.request.contextPath}/manager/dashboard" class="portal-btn portal-btn-secondary">
                    Quay Lại Dashboard
                </a>
            </div>
        </header>

        <!-- Bảng phân tích dịch vụ -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); background: #f8fafc; display: flex; justify-content: space-between; align-items: center;">
                <h3 class="portal-card-title">
                    Bảng Xếp Hạng Doanh Thu Dịch Vụ
                </h3>
                <span style="font-size: 13px; color: var(--portal-text-muted);">Dữ liệu tổng hợp từ toàn bộ các lượt đặt dịch vụ</span>
            </div>

            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th style="width: 14%;">Mã Dịch Vụ</th>
                            <th style="width: 28%;">Tên Dịch Vụ</th>
                            <th style="text-align: right; width: 18%;">Đơn Giá Hiện Tại</th>
                            <th style="text-align: center; width: 18%;">Số Lượt Sử Dụng</th>
                            <th style="text-align: right; width: 22%;">Tổng Doanh Thu Phát Sinh</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty serviceList}">
                                <c:forEach var="s" items="${serviceList}" varStatus="status">
                                    <tr>
                                        <td style="font-weight: 700; color: var(--portal-primary);">
                                            ${s.maDichVu}
                                        </td>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <c:if test="${status.index < 3}">
                                                    <span class="badge-pill badge-partial" style="font-size: 11px; padding: 2px 8px;">
                                                        Top ${status.index + 1}
                                                    </span>
                                                </c:if>
                                                <span style="font-weight: 700; color: var(--portal-text-primary); font-size: 14.5px;">${s.tenDichVu}</span>
                                            </div>
                                        </td>
                                        <td style="text-align: right; color: var(--portal-text-secondary); font-weight: 600;">
                                            <fmt:formatNumber value="${s.donGiaHienTai}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                        </td>
                                        <td style="text-align: center;">
                                            <span class="badge-pill badge-damaged">
                                                ${s.tongSoLuongSuDung} lượt
                                            </span>
                                        </td>
                                        <td style="text-align: right; font-weight: 800; color: #16a34a; font-size: 15px;">
                                            <fmt:formatNumber value="${s.tongDoanhThuDichVu}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="5" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                        Chưa có dịch vụ nào phát sinh tiêu dùng trong hệ thống.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />
