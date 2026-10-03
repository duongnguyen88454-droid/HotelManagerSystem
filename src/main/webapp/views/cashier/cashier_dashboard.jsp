<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<style>
    .cashier-container {
        max-width: 1320px;
        margin: 24px auto;
        padding: 0 20px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        color: #1e293b;
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
        font-size: 24px;
        font-weight: 700;
        color: #0f172a;
        margin: 0;
    }

    .page-subtitle {
        font-size: 14px;
        color: #64748b;
        margin-top: 4px;
    }

    .search-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .search-form {
        display: flex;
        gap: 12px;
        align-items: center;
    }

    .search-input {
        flex: 1;
        padding: 10px 14px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 14px;
        color: #1e293b;
        outline: none;
        transition: border-color 0.15s ease-in-out;
    }

    .search-input:focus {
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }

    .btn-search {
        padding: 10px 20px;
        background: #1e40af;
        color: #ffffff;
        border: none;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.15s ease-in-out;
    }

    .btn-search:hover {
        background: #1d4ed8;
    }

    .btn-reset {
        padding: 10px 18px;
        background: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 500;
        text-decoration: none;
        display: inline-block;
        transition: background 0.15s ease-in-out;
    }

    .btn-reset:hover {
        background: #e2e8f0;
    }

    .table-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .table-header-bar {
        padding: 16px 20px;
        background: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .table-title {
        font-size: 16px;
        font-weight: 600;
        color: #334155;
        margin: 0;
    }

    .badge-count {
        background: #e0e7ff;
        color: #3730a3;
        font-size: 12px;
        font-weight: 700;
        padding: 3px 9px;
        border-radius: 9999px;
    }

    .cashier-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
    }

    .cashier-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        text-align: left;
        padding: 12px 16px;
        border-bottom: 1px solid #e2e8f0;
    }

    .cashier-table td {
        padding: 14px 16px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }

    .cashier-table tr:hover {
        background-color: #f8fafc;
    }

    .badge {
        display: inline-block;
        padding: 4px 10px;
        font-size: 12px;
        font-weight: 600;
        border-radius: 4px;
        text-align: center;
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

    .badge-checkedin {
        background: #dbeafe;
        color: #1e40af;
        border: 1px solid #bfdbfe;
    }

    .badge-occupied {
        background: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
    }

    .amount-highlight {
        font-weight: 700;
        color: #b91c1c;
    }

    .btn-action {
        padding: 8px 14px;
        background: #0284c7;
        color: #ffffff;
        border: none;
        border-radius: 5px;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        display: inline-block;
        transition: background 0.15s ease-in-out;
        white-space: nowrap;
    }

    .btn-action:hover {
        background: #0369a1;
    }

    .empty-state {
        text-align: center;
        padding: 48px 20px;
        color: #64748b;
    }

    .empty-state-title {
        font-size: 16px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 6px;
    }
</style>

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
