<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thu Ngân - Ghi Nhận Thanh Toán" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="cashier/payment_form.css" />
</jsp:include>

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái (Sidebar) -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="cashier" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <nav class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/cashier/dashboard">Quầy Thu Ngân</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${invoice.maBooking}">Đơn ${invoice.maBooking}</a>
            <span>/</span>
            <strong>Thanh Toán Quyết Toán</strong>
        </nav>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" role="alert">
                <strong>Lỗi:</strong> ${errorMessage}
            </div>
        </c:if>

        <div class="page-header">
            <div class="page-header-main">
                <h1 class="page-title">Xác Nhận &amp; Ghi Nhận Thanh Toán</h1>
                <p class="page-subtitle">
                    Khách hàng: <strong>${invoice.tenKhachHang}</strong> (CCCD: ${invoice.cccd} - SĐT: ${invoice.soDT}) |
                    Mã Booking: <strong>${invoice.maBooking}</strong> | Mã Hóa Đơn: <strong>${invoice.maHoaDon}</strong>
                </p>
            </div>
        </div>

        <!-- 3 Khối Thống Kê Tài Chính Chuẩn KPI -->
        <div class="kpi-grid mb-6">
            <div class="kpi-card">
                <div class="kpi-label">Tổng Tiền Booking</div>
                <div class="kpi-value text-primary">
                    <fmt:formatNumber value="${invoice.tongTienCuoiCung}" pattern="#,##0" /> đ
                </div>
                <div class="kpi-desc">Toàn bộ chi phí phòng và dịch vụ phát sinh</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label">Số Tiền Đã Thanh Toán</div>
                <div class="kpi-value text-success">
                    <fmt:formatNumber value="${invoice.daThanhToan}" pattern="#,##0" /> đ
                </div>
                <div class="kpi-desc">Tổng các lần thu trước đó trong các ca làm việc</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label">Số Tiền Còn Lại Cần Thu</div>
                <div class="kpi-value text-danger">
                    <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
                </div>
                <div class="kpi-desc">Công nợ thực tế cần quyết toán tại quầy</div>
            </div>
        </div>

        <!-- Form Ghi Nhận Thanh Toán & Lịch Sử Thu Tiền -->
        <div class="grid-2">
            <!-- Cột Form Nhập Tiền -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Ghi Nhận Giao Dịch Thu Tiền</h2>
                </div>
                <div class="card-body">
                    <!-- Thông báo các phòng sẽ trả đồng thời -->
                    <c:if test="${not empty selectedRooms}">
                        <div class="alert alert-info">
                            <div class="fw-bold mb-1">
                                Phòng sẽ thực hiện trả khi xác nhận thanh toán:
                            </div>
                            <div class="flex gap-2 flex-wrap mb-1">
                                <c:forEach var="r" items="${selectedRooms}">
                                    <span class="badge badge-info">Phòng ${r}</span>
                                </c:forEach>
                            </div>
                            <div class="text-xs text-muted">
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
                                   class="form-control mono fw-bold text-lg" disabled />
                            <input type="hidden" id="soTien" name="soTien" value="<fmt:formatNumber value='${paymentAmount}' pattern='0' />" />
                            <div class="form-hint">
                                Số tiền đã được hệ thống tự động tính toán chính xác dựa trên danh sách phòng, dịch vụ và các khoản phụ phí phát sinh.
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Phương Thức Thanh Toán</label>
                            <div class="flex flex-col gap-2 mt-2">
                                <label class="flex items-center gap-2 text-sm" style="cursor: pointer;">
                                    <input type="radio" name="phuongThuc" value="Cash" checked />
                                    <span><strong>Tiền Mặt</strong> - Thu tiền mặt trực tiếp tại quầy</span>
                                </label>
                                <label class="flex items-center gap-2 text-sm" style="cursor: pointer;">
                                    <input type="radio" name="phuongThuc" value="CreditCard" />
                                    <span><strong>Thẻ Ngân Hàng (POS)</strong> - Quẹt thẻ ATM / Visa / Mastercard</span>
                                </label>
                                <label class="flex items-center gap-2 text-sm" style="cursor: pointer;">
                                    <input type="radio" name="phuongThuc" value="BankTransfer" />
                                    <span><strong>Chuyển Khoản Ngân Hàng</strong> - Quét mã QR / Chuyển khoản số tài khoản</span>
                                </label>
                            </div>
                        </div>

                        <div class="alert alert-warning">
                            <strong>Quy định đối soát ca làm việc:</strong><br />
                            Khoản tiền thu này sẽ được ghi nhận định danh vào mã nhân viên của bạn. Trường hợp khách chỉ thanh toán một phần, số tiền còn thiếu sẽ được lưu giữ tự động trên hệ thống để thu ngân ca tiếp theo tiếp quản.
                        </div>

                        <div class="form-actions">
                            <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${invoice.maBooking}" class="btn btn-secondary">
                                Hủy Bỏ / Quay Lại
                            </a>
                            <button type="submit" class="btn btn-primary btn-lg flex-1">
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
            </div>

            <!-- Cột Tóm Tắt & Lịch Sử Ca Làm Việc -->
            <div class="card card-flush">
                <div class="card-header">
                    <h2 class="card-title">Lịch Sử Thu Tiền Các Ca</h2>
                </div>
                <div class="table-wrapper">
                    <c:choose>
                        <c:when test="${not empty paymentHistory}">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Thời Điểm</th>
                                        <th>Thu Ngân</th>
                                        <th>Hình Thức</th>
                                        <th class="text-right">Số Tiền</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="p" items="${paymentHistory}">
                                        <tr>
                                            <td class="mono">
                                                <fmt:formatDate value="${p.thoiDiemThanhToan}" pattern="dd/MM HH:mm" />
                                            </td>
                                            <td>
                                                <strong>${p.maNV}</strong>
                                                <div class="text-xs text-muted">${p.tenNV}</div>
                                            </td>
                                            <td>
                                                <span class="pill">${p.phuongThucThanhToan}</span>
                                            </td>
                                            <td class="text-right text-success fw-bold mono">
                                                <fmt:formatNumber value="${p.soTien}" pattern="#,##0" /> đ
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <p>Chưa có giao dịch thanh toán nào được ghi nhận cho đơn này.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="card-toolbar text-center" style="justify-content: center;">
                    <a href="${pageContext.request.contextPath}/cashier/invoice?maHoaDon=${invoice.maHoaDon}" class="fw-semibold text-sm">
                        Xem bản in hóa đơn hiện tại &rarr;
                    </a>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />
