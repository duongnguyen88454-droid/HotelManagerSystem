<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cashier/payment_form.css">

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
