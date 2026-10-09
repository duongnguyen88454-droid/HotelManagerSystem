<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cashier/cashier_dashboard.css">

<div class="cashier-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Quầy Thu Ngân - Quyết Toán & Hóa Đơn</h1>
            <div class="page-subtitle">Danh sách các đơn đặt phòng đang lưu trú cần quyết toán và thanh toán</div>
        </div>
    </div>

    <!-- Thanh tìm kiếm nhanh -->
    <div class="search-card">
        <form action="${pageContext.request.contextPath}/cashier/dashboard" method="GET" class="search-form">
            <input type="text" name="keyword" value="${keyword}" class="search-input"
                   placeholder="Nhập Tên khách hàng, Số CCCD, Số điện thoại hoặc Mã Booking..." />
            <button type="submit" class="btn-search">Tìm Kiếm</button>
            <c:if test="${not empty keyword}">
                <a href="${pageContext.request.contextPath}/cashier/dashboard" class="btn-reset">Đặt Lại</a>
            </c:if>
        </form>
    </div>

    <!-- Bảng danh sách đơn đặt phòng -->
    <div class="table-card">
        <div class="table-header-bar">
            <h2 class="table-title">Đơn Đặt Phòng Cần Thanh Toán</h2>
            <span class="badge-count">${not empty bookingList ? bookingList.size() : 0} đơn</span>
        </div>

        <c:choose>
            <c:when test="${not empty bookingList}">
                <table class="cashier-table">
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
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${bookingList}">
                            <tr>
                                <td>
                                    <strong style="color: #1e40af;">${item.maBooking}</strong>
                                    <c:if test="${not empty item.maHoaDon}">
                                        <div style="font-size: 12px; color: #64748b;">HĐ: ${item.maHoaDon}</div>
                                    </c:if>
                                </td>
                                <td>
                                    <strong>${item.tenKhach}</strong>
                                </td>
                                <td>
                                    <div>CCCD: ${item.cccd}</div>
                                    <div style="font-size: 12px; color: #64748b;">SĐT: ${item.soDT}</div>
                                </td>
                                <td>
                                    <span class="badge badge-occupied">${item.danhSachPhong}</span>
                                    <div style="font-size: 12px; color: #64748b; margin-top: 2px;">
                                        Tổng ${item.tongSoPhong} phòng
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.soPhongChuaTra > 0}">
                                            <span class="badge badge-checkedin">Còn ${item.soPhongChuaTra} phòng ở</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-occupied">Đã trả hết phòng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatNumber value="${item.tongTien != null ? item.tongTien : item.chiPhiDuKien}" pattern="#,##0" /> đ
                                </td>
                                <td>
                                    <div style="color: #047857; font-size: 13px;">
                                        Đã trả: <fmt:formatNumber value="${item.daThanhToan != null ? item.daThanhToan : 0}" pattern="#,##0" /> đ
                                    </div>
                                    <div class="amount-highlight">
                                        Còn thiếu: <fmt:formatNumber value="${item.soTienConNo != null ? item.soTienConNo : (item.chiPhiDuKien - (item.daThanhToan != null ? item.daThanhToan : 0))}" pattern="#,##0" /> đ
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.trangThaiHoaDon == 'DaThanhToanDu'}">
                                            <span class="badge badge-paid">Đã thanh toán đủ</span>
                                        </c:when>
                                        <c:when test="${item.trangThaiHoaDon == 'MotPhan' || (item.daThanhToan != null && item.daThanhToan > 0)}">
                                            <span class="badge badge-partial">Thanh toán một phần</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-unpaid">Chưa thanh toán</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                       class="btn-action">
                                        Chi Tiết &amp; Trả Phòng
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-title">Không tìm thấy đơn đặt phòng nào cần thanh toán</div>
                    <div>Thử tìm kiếm với từ khóa khác hoặc kiểm tra lại trạng thái lưu trú của khách hàng.</div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
