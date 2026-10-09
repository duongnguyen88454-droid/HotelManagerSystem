<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cashier/booking_detail.css">

<div class="cashier-detail-container">
    <div class="nav-breadcrumbs">
        <a href="${pageContext.request.contextPath}/cashier/dashboard">Thu Ngân</a>
        <span>&gt;</span>
        <strong>Chi Tiết Đơn ${invoice.maBooking}</strong>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert-error">
            ${errorMessage}
        </div>
    </c:if>

    <div class="page-header">
        <div>
            <h1 class="page-title">Đơn Đặt Phòng: ${invoice.maBooking}</h1>
            <div style="font-size: 14px; color: #64748b; margin-top: 4px;">
                Mã Hóa Đơn Quyết Toán: <strong>${invoice.maHoaDon}</strong> | Thu ngân tiếp nhận: <strong>${invoice.tenNVLap}</strong>
            </div>
        </div>
        <div>
            <c:choose>
                <c:when test="${invoice.trangThaiHoaDon == 'DaThanhToanDu'}">
                    <span class="badge badge-paid">Đã thanh toán đủ</span>
                </c:when>
                <c:when test="${invoice.trangThaiHoaDon == 'MotPhan' || invoice.daThanhToan > 0}">
                    <span class="badge badge-partial">Thanh toán một phần</span>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-unpaid">Chưa thanh toán</span>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Thông tin khách hàng & Tài chính tổng quan -->
    <div class="info-grid">
        <div class="info-card">
            <h2 class="card-title">Thông Tin Khách Hàng</h2>
            <div class="data-row">
                <span class="data-label">Họ và Tên</span>
                <span class="data-value">${invoice.tenKhachHang}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Số CCCD / Hộ Chiếu</span>
                <span class="data-value">${invoice.cccd}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Số Điện Thoại</span>
                <span class="data-value">${invoice.soDT}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Mã Khách Hàng</span>
                <span class="data-value">${invoice.maKH}</span>
            </div>
        </div>

        <div class="info-card">
            <h2 class="card-title">Đối Soát Tài Chính</h2>
            <div class="data-row">
                <span class="data-label">Tổng Chi Phí Hóa Đơn</span>
                <span class="data-value" style="color: #1e3a8a;">
                    <fmt:formatNumber value="${invoice.tongTienCuoiCung}" pattern="#,##0" /> đ
                </span>
            </div>
            <div class="data-row">
                <span class="data-label">Đã Ghi Nhận Thanh Toán</span>
                <span class="data-value" style="color: #059669;">
                    <fmt:formatNumber value="${invoice.daThanhToan}" pattern="#,##0" /> đ
                </span>
            </div>
            <div class="data-row">
                <span class="data-label">Số Tiền Còn Thiếu</span>
                <span class="data-value" style="color: #dc2626; font-size: 16px;">
                    <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
                </span>
            </div>
        </div>
    </div>

    <!-- Form Chọn Phòng để Chuyển sang Bước Thanh Toán (Chưa Check-out sớm trong DB) -->
    <form action="${pageContext.request.contextPath}/cashier/payment" method="GET" id="checkoutForm">
        <input type="hidden" name="maBooking" value="${invoice.maBooking}" />
        <input type="hidden" name="maHoaDon" value="${invoice.maHoaDon}" />

        <div class="table-card">
            <div class="table-title-bar">
                <h2 class="table-title">Danh Sách Phòng Trong Đơn (Tích chọn phòng cần trả)</h2>
                <label style="font-size: 13px; font-weight: 500; cursor: pointer;">
                    <input type="checkbox" id="selectAllRooms" onchange="toggleSelectAllRooms(this)" />
                    Chọn tất cả phòng đang ở
                </label>
            </div>

            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width: 50px; text-align: center;">Chọn</th>
                        <th>Phòng</th>
                        <th>Hạng Phòng</th>
                        <th>Thời Gian Check-in</th>
                        <th>Thời Gian Check-out</th>
                        <th>Số Đêm</th>
                        <th>Đơn Giá / Đêm</th>
                        <th>Thành Tiền Phòng</th>
                        <th>Trạng Thái</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="room" items="${invoice.rooms}">
                        <tr>
                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${room.ngayCheckOutThucTe == null}">
                                        <input type="checkbox" name="selectedRooms" value="${room.maPhong}"
                                               class="room-checkbox room-selectable" checked />
                                    </c:when>
                                    <c:otherwise>
                                        <input type="checkbox" disabled class="room-checkbox" />
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><strong>${room.maPhong}</strong></td>
                            <td>${room.tenLoaiPhong}</td>
                            <td>
                                <fmt:formatDate value="${room.ngayCheckInThucTe}" pattern="dd/MM/yyyy HH:mm" />
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${room.ngayCheckOutThucTe != null}">
                                        <fmt:formatDate value="${room.ngayCheckOutThucTe}" pattern="dd/MM/yyyy HH:mm" />
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #64748b;">(Dự kiến: <fmt:formatDate value="${room.ngayTraDuKien}" pattern="dd/MM/yyyy" />)</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>${room.soDem} đêm</td>
                            <td>
                                <fmt:formatNumber value="${room.donGiaPhong}" pattern="#,##0" /> đ
                            </td>
                            <td>
                                <strong><fmt:formatNumber value="${room.thanhTien}" pattern="#,##0" /> đ</strong>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${room.ngayCheckOutThucTe != null}">
                                        <span class="badge badge-checkout">Đã trả phòng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-active">Đang lưu trú</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Bảng kê dịch vụ đã sử dụng -->
        <c:if test="${not empty invoice.services}">
            <div class="table-card">
                <div class="table-title-bar">
                    <h2 class="table-title">Dịch Vụ Đã Sử Dụng Theo Từng Phòng</h2>
                    <span style="font-size: 13px; color: #64748b;">${invoice.services.size()} dịch vụ phát sinh</span>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Tên Dịch Vụ</th>
                            <th>Phòng Gọi</th>
                            <th>Thời Điểm Gọi</th>
                            <th>Đơn Giá</th>
                            <th>Số Lượng</th>
                            <th>Thành Tiền Dịch Vụ</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="srv" items="${invoice.services}">
                            <tr>
                                <td><strong>${srv.tenDichVu}</strong></td>
                                <td>Phòng ${srv.maPhong}</td>
                                <td>
                                    <fmt:formatDate value="${srv.thoiDiemThem}" pattern="dd/MM/yyyy HH:mm" />
                                </td>
                                <td>
                                    <fmt:formatNumber value="${srv.donGia}" pattern="#,##0" /> đ
                                </td>
                                <td>${srv.soLuong}</td>
                                <td>
                                    <strong><fmt:formatNumber value="${srv.thanhTien}" pattern="#,##0" /> đ</strong>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <!-- Thanh điều hướng thao tác -->
        <div class="action-panel">
            <div>
                <a href="${pageContext.request.contextPath}/cashier/dashboard"
                   style="color: #64748b; text-decoration: none; font-size: 14px; font-weight: 500;">
                    &larr; Quay lại danh sách
                </a>
            </div>
            <div>
                <button type="submit" class="btn-checkout-submit">
                    Tiếp Tục Chọn Phương Thức Thanh Toán &amp; Trả Phòng &rarr;
                </button>
            </div>
        </div>
    </form>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cashier/booking_detail.js"></script>

<jsp:include page="/views/common/footer.jsp" />
