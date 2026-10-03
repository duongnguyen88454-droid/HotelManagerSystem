<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<style>
    .cashier-detail-container {
        max-width: 1280px;
        margin: 24px auto;
        padding: 0 20px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        color: #1e293b;
    }

    .nav-breadcrumbs {
        margin-bottom: 16px;
        font-size: 14px;
    }

    .nav-breadcrumbs a {
        color: #2563eb;
        text-decoration: none;
        font-weight: 500;
    }

    .nav-breadcrumbs a:hover {
        text-decoration: underline;
    }

    .nav-breadcrumbs span {
        color: #94a3b8;
        margin: 0 8px;
    }

    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e2e8f0;
    }

    .page-title {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0;
    }

    .alert-error {
        background: #fee2e2;
        color: #991b1b;
        border: 1px solid #fecaca;
        border-radius: 6px;
        padding: 12px 16px;
        margin-bottom: 20px;
        font-size: 14px;
        font-weight: 500;
    }

    .info-grid {
        display: grid;
        grid-template-columns: 2fr 1fr;
        gap: 20px;
        margin-bottom: 24px;
    }

    .info-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .card-title {
        font-size: 16px;
        font-weight: 600;
        color: #1e293b;
        margin-bottom: 16px;
        padding-bottom: 8px;
        border-bottom: 1px solid #f1f5f9;
    }

    .data-row {
        display: flex;
        justify-content: space-between;
        padding: 8px 0;
        font-size: 14px;
        border-bottom: 1px dashed #f1f5f9;
    }

    .data-row:last-child {
        border-bottom: none;
    }

    .data-label {
        color: #64748b;
        font-weight: 500;
    }

    .data-value {
        color: #0f172a;
        font-weight: 600;
        text-align: right;
    }

    .table-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        overflow: hidden;
    }

    .table-title-bar {
        background: #f8fafc;
        padding: 14px 20px;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .table-title {
        font-size: 15px;
        font-weight: 600;
        color: #334155;
        margin: 0;
    }

    .data-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
    }

    .data-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        text-align: left;
        padding: 12px 16px;
        border-bottom: 1px solid #e2e8f0;
    }

    .data-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }

    .badge {
        display: inline-block;
        padding: 4px 10px;
        font-size: 12px;
        font-weight: 600;
        border-radius: 4px;
    }

    .badge-active {
        background: #dbeafe;
        color: #1e40af;
        border: 1px solid #bfdbfe;
    }

    .badge-checkout {
        background: #e2e8f0;
        color: #475569;
        border: 1px solid #cbd5e1;
    }

    .badge-unpaid {
        background: #fee2e2;
        color: #991b1b;
        border: 1px solid #fecaca;
    }

    .badge-partial {
        background: #fef3c7;
        color: #92400e;
        border: 1px solid #fde68a;
    }

    .badge-paid {
        background: #dcfce7;
        color: #166534;
        border: 1px solid #bbf7d0;
    }

    .action-panel {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .btn-checkout-submit {
        padding: 12px 24px;
        background: #0284c7;
        color: #ffffff;
        border: none;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s ease-in-out;
    }

    .btn-checkout-submit:hover {
        background: #0369a1;
    }

    .btn-pay-direct {
        padding: 12px 20px;
        background: #059669;
        color: #ffffff;
        border: none;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        text-decoration: none;
        transition: background 0.15s ease-in-out;
    }

    .btn-pay-direct:hover {
        background: #047857;
    }

    .room-checkbox {
        width: 18px;
        height: 18px;
        cursor: pointer;
    }
</style>

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

<script>
    function toggleSelectAllRooms(master) {
        var checkboxes = document.querySelectorAll('.room-selectable');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = master.checked;
        }
    }
</script>

<jsp:include page="/views/common/footer.jsp" />
