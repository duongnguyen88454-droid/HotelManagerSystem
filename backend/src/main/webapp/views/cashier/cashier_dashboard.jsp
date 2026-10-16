<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Thu Ngân - Quyết Toán & Hóa Đơn" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cashier/cashier_dashboard.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái (Sidebar) -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="cashier" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <!-- Thanh tìm kiếm tích hợp trên đầu bảng -->
            <div class="toolbar-header" style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <form action="${pageContext.request.contextPath}/cashier/dashboard" method="GET" style="display: flex; gap: 10px; align-items: center; margin: 0; flex: 1; max-width: 600px; flex-wrap: wrap;">
                    <input type="text" name="keyword" value="${keyword}" class="portal-input"
                           placeholder="Tìm kiếm theo Tên khách, CCCD, SĐT hoặc Mã Booking..." style="width: 380px;" />
                    <button type="submit" class="portal-btn portal-btn-primary">Tìm Kiếm</button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/cashier/dashboard" class="portal-btn portal-btn-secondary">Đặt Lại</a>
                    </c:if>
                </form>
                <span class="portal-date-pill" style="font-size: 12.5px; padding: 6px 14px;">
                    ${not empty bookingList ? bookingList.size() : 0} đơn cần thanh toán
                </span>
            </div>

            <!-- Bảng danh sách đơn theo chuẩn portal-table đồng bộ -->
            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <c:choose>
                    <c:when test="${not empty bookingList}">
                        <table class="portal-table">
                            <thead>
                                <tr>
                                    <th>Mã Booking</th>
                                    <th>Khách Hàng</th>
                                    <th>Thông Tin Liên Hệ</th>
                                    <th>Phòng Lưu Trú</th>
                                    <th>Trạng Thái Phòng</th>
                                    <th>Tổng Chi Phí</th>
                                    <th>Đã Trả / Còn Thiếu</th>
                                    <th>Trạng Thái Thu</th>
                                    <th style="text-align: right;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${bookingList}">
                                    <tr>
                                        <td>
                                            <strong style="color: var(--portal-primary);">${item.maBooking}</strong>
                                            <c:if test="${not empty item.maHoaDon}">
                                                <div style="font-size: 12px; color: var(--portal-text-muted);">HĐ: ${item.maHoaDon}</div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <strong>${item.tenKhach}</strong>
                                        </td>
                                        <td>
                                            <div>CCCD: ${item.cccd}</div>
                                            <div style="font-size: 12px; color: var(--portal-text-muted);">SĐT: ${item.soDT}</div>
                                        </td>
                                        <td>
                                            <span class="badge-pill badge-occupied">${item.danhSachPhong}</span>
                                            <div style="font-size: 12px; color: var(--portal-text-muted); margin-top: 2px;">
                                                Tổng ${item.tongSoPhong} phòng
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.soPhongChuaTra > 0}">
                                                    <span class="badge-pill badge-cleaning">Còn ${item.soPhongChuaTra} phòng ở</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-available">Đã trả hết phòng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <strong><fmt:formatNumber value="${item.tongTien != null ? item.tongTien : item.chiPhiDuKien}" pattern="#,##0" /> đ</strong>
                                        </td>
                                        <td>
                                            <div style="color: #059669; font-size: 13px;">
                                                Đã trả: <fmt:formatNumber value="${item.daThanhToan != null ? item.daThanhToan : 0}" pattern="#,##0" /> đ
                                            </div>
                                            <div style="color: #dc2626; font-size: 13px; font-weight: 700; margin-top: 2px;">
                                                Còn thiếu: <fmt:formatNumber value="${item.soTienConNo != null ? item.soTienConNo : (item.chiPhiDuKien - (item.daThanhToan != null ? item.daThanhToan : 0))}" pattern="#,##0" /> đ
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.trangThaiHoaDon == 'Paid'}">
                                                    <span class="badge-pill badge-available">Đã thanh toán đủ</span>
                                                </c:when>
                                                <c:when test="${item.trangThaiHoaDon == 'PartiallyPaid' || item.trangThaiHoaDon == 'Partial' || (item.daThanhToan != null && item.daThanhToan > 0)}">
                                                    <span class="badge-pill badge-partial">Thanh toán một phần</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-occupied">Chưa thanh toán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <c:choose>
                                                <c:when test="${item.soPhongChuaTra > 0}">
                                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                                       class="portal-btn portal-btn-primary" style="font-size: 12.5px; padding: 6px 14px;">
                                                        Chi Tiết &amp; Trả Phòng
                                                    </a>
                                                </c:when>
                                                <c:when test="${item.trangThaiHoaDon == 'Paid' || (item.soTienConNo != null && item.soTienConNo le 0)}">
                                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                                       class="portal-btn portal-btn-success" style="font-size: 12.5px; padding: 6px 14px;">
                                                        Xem Chi Tiết &amp; HĐ
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                                       class="portal-btn" style="background-color: #ea580c; color: #ffffff; font-size: 12.5px; padding: 6px 14px;">
                                                        Quyết Toán Công Nợ
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align: center; padding: 60px 20px; color: var(--portal-text-muted);">
                            <div style="font-weight: 700; font-size: 16px; color: var(--portal-text-secondary); margin-bottom: 6px;">Không tìm thấy đơn đặt phòng nào cần thanh toán</div>
                            <div>Thử tìm kiếm với từ khóa khác hoặc kiểm tra lại trạng thái lưu trú của khách hàng.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />
