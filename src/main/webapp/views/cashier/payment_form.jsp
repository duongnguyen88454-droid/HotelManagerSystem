<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<style>
    .payment-container {
        max-width: 1100px;
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

    .page-title {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 6px 0;
    }

    .page-subtitle {
        font-size: 14px;
        color: #64748b;
        margin-bottom: 24px;
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

    /* 3 Financial Metric Cards */
    .metric-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
        margin-bottom: 28px;
    }

    .metric-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .metric-card-total {
        border-left: 4px solid #2563eb;
    }

    .metric-card-paid {
        border-left: 4px solid #059669;
    }

    .metric-card-remaining {
        border-left: 4px solid #dc2626;
        background: #fffafa;
    }

    .metric-label {
        font-size: 13px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748b;
        margin-bottom: 8px;
    }

    .metric-value {
        font-size: 26px;
        font-weight: 800;
        color: #0f172a;
    }

    .metric-value-total {
        color: #1e40af;
    }

    .metric-value-paid {
        color: #059669;
    }

    .metric-value-remaining {
        color: #dc2626;
    }

    .metric-note {
        font-size: 12px;
        color: #64748b;
        margin-top: 6px;
    }

    /* Layout: Form & Summary */
    .payment-layout {
        display: grid;
        grid-template-columns: 1.6fr 1fr;
        gap: 24px;
        margin-bottom: 28px;
    }

    .form-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .card-heading {
        font-size: 16px;
        font-weight: 700;
        color: #0f172a;
        margin: 0 0 18px 0;
        padding-bottom: 10px;
        border-bottom: 1px solid #f1f5f9;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 8px;
    }

    .form-input {
        width: 100%;
        padding: 12px 14px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 16px;
        font-weight: 600;
        color: #0f172a;
        box-sizing: border-box;
        outline: none;
    }

    .form-input:focus {
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }

    .quick-amount-buttons {
        display: flex;
        gap: 8px;
        margin-top: 8px;
    }

    .btn-quick {
        padding: 6px 12px;
        background: #f1f5f9;
        border: 1px solid #cbd5e1;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
        color: #475569;
        cursor: pointer;
    }

    .btn-quick:hover {
        background: #e2e8f0;
    }

    .method-options {
        display: grid;
        grid-template-columns: 1fr;
        gap: 10px;
    }

    .method-label {
        display: flex;
        align-items: center;
        padding: 12px 16px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.15s ease-in-out;
        background: #ffffff;
    }

    .method-label:hover {
        background: #f8fafc;
        border-color: #94a3b8;
    }

    .method-radio {
        margin-right: 12px;
        width: 16px;
        height: 16px;
        cursor: pointer;
    }

    .method-text {
        font-size: 14px;
        font-weight: 600;
        color: #1e293b;
    }

    .method-desc {
        font-size: 12px;
        color: #64748b;
        margin-left: auto;
    }

    .notice-box {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 6px;
        padding: 14px 16px;
        margin-top: 20px;
        font-size: 13px;
        line-height: 1.5;
        color: #475569;
    }

    .btn-submit-payment {
        width: 100%;
        padding: 14px 20px;
        background: #059669;
        color: #ffffff;
        border: none;
        border-radius: 6px;
        font-size: 15px;
        font-weight: 700;
        cursor: pointer;
        transition: background 0.15s ease-in-out;
        margin-top: 10px;
    }

    .btn-submit-payment:hover {
        background: #047857;
    }

    .history-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }

    .history-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }

    .history-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 600;
        text-align: left;
        padding: 10px 12px;
        border-bottom: 1px solid #e2e8f0;
    }

    .history-table td {
        padding: 10px 12px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
    }

    .badge-method {
        display: inline-block;
        padding: 3px 8px;
        font-size: 11px;
        font-weight: 600;
        border-radius: 4px;
        background: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
    }
</style>

<div class="payment-container">
    <div class="nav-breadcrumbs">
        <a href="${pageContext.request.contextPath}/cashier/dashboard">Thu Ngân</a>
        <span>&gt;</span>
        <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${invoice.maBooking}">Đơn ${invoice.maBooking}</a>
        <span>&gt;</span>
        <strong>Thanh Toán Quyết Toán</strong>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert-error">
            ${errorMessage}
        </div>
    </c:if>

    <h1 class="page-title">Xác Nhận &amp; Ghi Nhận Thanh Toán</h1>
    <div class="page-subtitle">
        Khách hàng: <strong>${invoice.tenKhachHang}</strong> (CCCD: ${invoice.cccd} - SĐT: ${invoice.soDT}) |
        Mã Booking: <strong>${invoice.maBooking}</strong> | Mã Hóa Đơn: <strong>${invoice.maHoaDon}</strong>
    </div>

    <!-- 3 Khối Thống Kê Tài Chính Bắt Buộc -->
    <div class="metric-grid">
        <div class="metric-card metric-card-total">
            <div class="metric-label">Tổng Tiền Booking</div>
            <div class="metric-value metric-value-total">
                <fmt:formatNumber value="${invoice.tongTienCuoiCung}" pattern="#,##0" /> đ
            </div>
            <div class="metric-note">Toàn bộ chi phí phòng và dịch vụ phát sinh</div>
        </div>

        <div class="metric-card metric-card-paid">
            <div class="metric-label">Số Tiền Đã Thanh Toán</div>
            <div class="metric-value metric-value-paid">
                <fmt:formatNumber value="${invoice.daThanhToan}" pattern="#,##0" /> đ
            </div>
            <div class="metric-note">Tổng các lần thu trước đó trong các ca làm việc</div>
        </div>

        <div class="metric-card metric-card-remaining">
            <div class="metric-label">Số Tiền Còn Lại Cần Thu</div>
            <div class="metric-value metric-value-remaining">
                <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
            </div>
            <div class="metric-note">Công nợ thực tế cần quyết toán tại quầy</div>
        </div>
    </div>

    <!-- Form Ghi Nhận Thanh Toán & Lịch Sử Thu Tiền Các Ca -->
    <div class="payment-layout">
        <!-- Cột Form Nhập Tiền -->
        <div class="form-card">
            <h2 class="card-heading">Ghi Nhận Giao Dịch Thu Tiền</h2>

            <!-- Thông báo các phòng sẽ trả đồng thời -->
            <c:if test="${not empty selectedRooms}">
                <div class="notice-box" style="border-left: 4px solid #0284c7; background: #f0f9ff; margin-bottom: 20px;">
                    <div style="font-weight: 700; color: #0369a1; margin-bottom: 4px;">
                        Phòng sẽ thực hiện trả khi xác nhận thanh toán:
                    </div>
                    <div>
                        <c:forEach var="r" items="${selectedRooms}">
                            <span style="display: inline-block; background: #e0f2fe; color: #0369a1; padding: 2px 8px; border-radius: 4px; font-weight: 700; margin-right: 6px;">
                                Phòng ${r}
                            </span>
                        </c:forEach>
                    </div>
                    <div style="font-size: 12px; color: #64748b; margin-top: 6px;">
                        Trạng thái phòng chỉ chuyển sang chờ dọn dẹp sau khi bạn bấm xác nhận bên dưới.
                    </div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/cashier/payment" method="POST" id="paymentForm">
                <input type="hidden" name="maBooking" value="${invoice.maBooking}" />
                <input type="hidden" name="maHoaDon" value="${invoice.maHoaDon}" />
                <c:forEach var="r" items="${selectedRooms}">
                    <input type="hidden" name="selectedRooms" value="${r}" />
                </c:forEach>

                <div class="form-group">
                    <label class="form-label">Số Tiền Thanh Toán</label>
                    <input type="text" readonly
                           value="<fmt:formatNumber value='${paymentAmount}' pattern='#,##0' /> đ"
                           class="form-input" style="background-color: #f8fafc; cursor: not-allowed; font-size: 18px; font-weight: 700; color: #0f172a;" />
                    <input type="hidden" id="soTien" name="soTien" value="<fmt:formatNumber value='${paymentAmount}' pattern='0' />" />
                    <div style="font-size: 12px; color: #64748b; margin-top: 6px;">
                        Số tiền đã được hệ thống tự động tính toán chính xác dựa trên danh sách phòng và dịch vụ bạn đã chọn.
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Phương Thức Thanh Toán</label>
                    <div class="method-options">
                        <label class="method-label">
                            <input type="radio" name="phuongThuc" value="TienMat" checked class="method-radio" />
                            <span class="method-text">Tiền Mặt</span>
                            <span class="method-desc">Thu tiền mặt trực tiếp tại quầy</span>
                        </label>
                        <label class="method-label">
                            <input type="radio" name="phuongThuc" value="TheNganHang" class="method-radio" />
                            <span class="method-text">Thẻ Ngân Hàng (POS)</span>
                            <span class="method-desc">Quẹt thẻ ATM / Visa / Mastercard</span>
                        </label>
                        <label class="method-label">
                            <input type="radio" name="phuongThuc" value="ChuyenKhoan" class="method-radio" />
                            <span class="method-text">Chuyển Khoản Ngân Hàng</span>
                            <span class="method-desc">Quét mã QR / Chuyển khoản qua số tài khoản</span>
                        </label>
                    </div>
                </div>

                <div class="notice-box">
                    <strong>Quy định đối soát ca làm việc:</strong><br />
                    Khoản tiền thu này sẽ được ghi nhận định danh vào mã nhân viên của bạn. Trường hợp khách chỉ thanh toán một phần (hoặc một số phòng vẫn còn đang ở), số tiền còn thiếu sẽ được lưu giữ tự động trên hệ thống để thu ngân ca tiếp theo tiếp quản quyết toán khi khách trả các phòng còn lại.
                </div>

                <div style="display: flex; gap: 12px; margin-top: 16px;">
                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${invoice.maBooking}"
                       class="btn-quick" style="padding: 12px 18px; text-decoration: none; display: flex; align-items: center; justify-content: center; font-size: 14px;">
                        Hủy Bỏ / Quay Lại
                    </a>
                    <button type="submit" class="btn-submit-payment" style="flex: 1; margin-top: 0;">
                        <c:choose>
                            <c:when test="${not empty selectedRooms}">
                                Xác Nhận Thu Tiền &amp; Hoàn Tất Trả Phòng
                            </c:when>
                            <c:otherwise>
                                Xác Nhận Thu Tiền &amp; Chuyển Sang Hóa Đơn
                            </c:otherwise>
                        </c:choose>
                    </button>
                </div>
            </form>
        </div>

        <!-- Cột Tóm Tắt & Lịch Sử Ca Làm Việc -->
        <div class="history-card">
            <h2 class="card-heading">Lịch Sử Thu Tiền Các Ca</h2>

            <c:choose>
                <c:when test="${not empty paymentHistory}">
                    <table class="history-table">
                        <thead>
                            <tr>
                                <th>Thời Điểm</th>
                                <th>Thu Ngân</th>
                                <th>Hình Thức</th>
                                <th style="text-align: right;">Số Tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${paymentHistory}">
                                <tr>
                                    <td>
                                        <fmt:formatDate value="${p.thoiDiemThanhToan}" pattern="dd/MM HH:mm" />
                                    </td>
                                    <td>
                                        <div><strong>${p.maNV}</strong></div>
                                        <div style="font-size: 11px; color: #64748b;">${p.tenNV}</div>
                                    </td>
                                    <td>
                                        <span class="badge-method">${p.phuongThucThanhToan}</span>
                                    </td>
                                    <td style="text-align: right; font-weight: 700; color: #059669;">
                                        <fmt:formatNumber value="${p.soTien}" pattern="#,##0" /> đ
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div style="text-align: center; padding: 30px 10px; color: #64748b; font-size: 13px;">
                        Chưa có giao dịch thanh toán nào được ghi nhận cho đơn này.
                    </div>
                </c:otherwise>
            </c:choose>

            <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid #f1f5f9;">
                <a href="${pageContext.request.contextPath}/cashier/invoice?maHoaDon=${invoice.maHoaDon}"
                   style="display: block; text-align: center; color: #2563eb; text-decoration: none; font-size: 13px; font-weight: 600;">
                    Xem bản in hóa đơn hiện tại &rarr;
                </a>
            </div>
        </div>
    </div>
</div>



<jsp:include page="/views/common/footer.jsp" />
