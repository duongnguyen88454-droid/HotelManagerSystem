<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <jsp:include page="/views/common/header.jsp" />
            <jsp:include page="/views/common/navbar.jsp" />

            <style>
                .invoice-page-container {
                    max-width: 1000px;
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

                .alert-success {
                    background: #ecfdf5;
                    color: #065f46;
                    border: 1px solid #a7f3d0;
                    border-radius: 6px;
                    padding: 14px 18px;
                    margin-bottom: 24px;
                    font-size: 14px;
                    font-weight: 600;
                }

                .action-top-bar {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 20px;
                }

                .btn-print {
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

                .btn-print:hover {
                    background: #1d4ed8;
                }

                .btn-back-dashboard {
                    padding: 10px 18px;
                    background: #f1f5f9;
                    color: #475569;
                    border: 1px solid #cbd5e1;
                    border-radius: 6px;
                    font-size: 14px;
                    font-weight: 500;
                    text-decoration: none;
                    display: inline-block;
                }

                .btn-back-dashboard:hover {
                    background: #e2e8f0;
                }

                .btn-pay-more {
                    padding: 10px 18px;
                    background: #059669;
                    color: #ffffff;
                    border: none;
                    border-radius: 6px;
                    font-size: 14px;
                    font-weight: 600;
                    text-decoration: none;
                    display: inline-block;
                }

                .btn-pay-more:hover {
                    background: #047857;
                }

                /* Khung Hóa Đơn Chuẩn Bản In */
                .invoice-sheet {
                    background: #ffffff;
                    border: 1px solid #e2e8f0;
                    border-radius: 8px;
                    padding: 40px;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
                    margin-bottom: 40px;
                }

                .hotel-brand-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: flex-start;
                    padding-bottom: 24px;
                    border-bottom: 2px solid #0f172a;
                    margin-bottom: 24px;
                }

                .hotel-name {
                    font-size: 24px;
                    font-weight: 800;
                    color: #0f172a;
                    letter-spacing: -0.5px;
                }

                .hotel-info {
                    font-size: 13px;
                    color: #64748b;
                    margin-top: 4px;
                    line-height: 1.4;
                }

                .invoice-title-block {
                    text-align: right;
                }

                .invoice-main-title {
                    font-size: 22px;
                    font-weight: 800;
                    color: #1e3a8a;
                    margin: 0 0 6px 0;
                    text-transform: uppercase;
                }

                .invoice-code {
                    font-size: 14px;
                    font-weight: 700;
                    color: #475569;
                }

                .meta-grid {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 24px;
                    margin-bottom: 28px;
                    font-size: 14px;
                }

                .meta-box {
                    background: #f8fafc;
                    border: 1px solid #e2e8f0;
                    border-radius: 6px;
                    padding: 16px;
                }

                .meta-box-title {
                    font-size: 13px;
                    font-weight: 700;
                    text-transform: uppercase;
                    color: #475569;
                    margin-bottom: 10px;
                    letter-spacing: 0.5px;
                }

                .meta-row {
                    display: flex;
                    justify-content: space-between;
                    padding: 4px 0;
                }

                .meta-label {
                    color: #64748b;
                }

                .meta-value {
                    color: #0f172a;
                    font-weight: 600;
                }

                .section-title {
                    font-size: 15px;
                    font-weight: 700;
                    color: #0f172a;
                    margin: 24px 0 12px 0;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }

                .invoice-table {
                    width: 100%;
                    border-collapse: collapse;
                    font-size: 13px;
                    margin-bottom: 20px;
                }

                .invoice-table th {
                    background: #f1f5f9;
                    color: #334155;
                    font-weight: 700;
                    text-align: left;
                    padding: 10px 12px;
                    border-bottom: 1px solid #cbd5e1;
                }

                .invoice-table td {
                    padding: 10px 12px;
                    border-bottom: 1px solid #e2e8f0;
                    vertical-align: middle;
                }

                .summary-block {
                    display: flex;
                    justify-content: flex-end;
                    margin-top: 24px;
                    padding-top: 16px;
                    border-top: 1px solid #e2e8f0;
                }

                .summary-box {
                    width: 380px;
                }

                .summary-row {
                    display: flex;
                    justify-content: space-between;
                    padding: 6px 0;
                    font-size: 14px;
                }

                .summary-row-final {
                    border-top: 2px solid #0f172a;
                    margin-top: 8px;
                    padding-top: 10px;
                    font-size: 16px;
                    font-weight: 800;
                }

                .badge-status {
                    display: inline-block;
                    padding: 4px 12px;
                    font-size: 12px;
                    font-weight: 700;
                    border-radius: 4px;
                    text-transform: uppercase;
                }

                .badge-paid {
                    background: #dcfce7;
                    color: #166534;
                    border: 1px solid #bbf7d0;
                }

                .badge-partial {
                    background: #fef3c7;
                    color: #92400e;
                    border: 1px solid #fde68a;
                }

                .badge-unpaid {
                    background: #fee2e2;
                    color: #991b1b;
                    border: 1px solid #fecaca;
                }

                .signatures-block {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 40px;
                    margin-top: 48px;
                    padding-top: 24px;
                    text-align: center;
                    font-size: 14px;
                }

                .signature-title {
                    font-weight: 700;
                    color: #0f172a;
                }

                .signature-sub {
                    font-size: 12px;
                    color: #64748b;
                    font-style: italic;
                    margin-top: 4px;
                }

                .signature-space {
                    height: 70px;
                }

                .signature-name {
                    font-weight: 600;
                    color: #334155;
                }

                /* Quy tắc bản in */
                @media print {

                    header,
                    .navbar,
                    footer,
                    .nav-breadcrumbs,
                    .action-top-bar,
                    .alert-success {
                        display: none !important;
                    }

                    body,
                    .content-wrapper,
                    .invoice-page-container {
                        margin: 0 !important;
                        padding: 0 !important;
                        max-width: 100% !important;
                        background: #ffffff !important;
                    }

                    .invoice-sheet {
                        border: none !important;
                        box-shadow: none !important;
                        padding: 0 !important;
                    }
                }
            </style>

            <div class="invoice-page-container">
                <div class="nav-breadcrumbs">
                    <a href="${pageContext.request.contextPath}/cashier/dashboard">Thu Ngân</a>
                    <span>&gt;</span>
                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${invoice.maBooking}">Đơn
                        ${invoice.maBooking}</a>
                    <span>&gt;</span>
                    <strong>Hóa Đơn ${invoice.maHoaDon}</strong>
                </div>

                <c:if test="${paymentSuccess}">
                    <div class="alert-success">
                        Giao dịch thanh toán đã được ghi nhận thành công vào hệ thống! Hóa đơn quyết toán đã được cập
                        nhật.
                    </div>
                </c:if>

                <div class="action-top-bar">
                    <div style="display: flex; gap: 10px;">
                        <a href="${pageContext.request.contextPath}/cashier/dashboard" class="btn-back-dashboard">
                            &larr; Về Danh Sách Thu Ngân
                        </a>
                        <c:if test="${invoice.conThieu gt 0}">
                            <a href="${pageContext.request.contextPath}/cashier/payment?maHoaDon=${invoice.maHoaDon}"
                                class="btn-pay-more">
                                Thu Tiền Tiếp
                            </a>
                        </c:if>
                    </div>
                    <div>
                        <button type="button" class="btn-print" onclick="window.print()">In Hóa Đơn</button>
                    </div>
                </div>

                <!-- Khung Hóa Đơn Quyết Toán Chính -->
                <div class="invoice-sheet">
                    <div class="hotel-brand-header">
                        <div>
                            <div class="hotel-name">HOTEL MANAGEMENT SYSTEM</div>
                            <div class="hotel-info">
                                Địa chỉ: Số 1 Võ Văn Ngân, Phường Linh Chiểu, TP. Thủ Đức, TP. Hồ Chí Minh<br />
                                Hotline: (028) 3722 1223 - Email: contact@hotelmanagement.vn<br />
                                Đơn vị chủ quản: HCMUTE - Khoa Công Nghệ Thông Tin
                            </div>
                        </div>
                        <div class="invoice-title-block">
                            <h1 class="invoice-main-title">Hóa Đơn Thanh Toán</h1>
                            <div class="invoice-code">Số HĐ: ${invoice.maHoaDon}</div>
                            <div style="font-size: 13px; color: #64748b; margin-top: 4px;">
                                Ngày lập:
                                <fmt:formatDate value="${invoice.ngayLap}" pattern="dd/MM/yyyy HH:mm" />
                            </div>
                        </div>
                    </div>

                    <!-- Thông Tin Khách & Thông Tin Đặt Phòng -->
                    <div class="meta-grid">
                        <div class="meta-box">
                            <div class="meta-box-title">Khách Hàng</div>
                            <div class="meta-row">
                                <span class="meta-label">Họ và tên:</span>
                                <span class="meta-value">${invoice.tenKhachHang}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Số CCCD / Hộ chiếu:</span>
                                <span class="meta-value">${invoice.cccd}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Số điện thoại:</span>
                                <span class="meta-value">${invoice.soDT}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Mã khách hàng:</span>
                                <span class="meta-value">${invoice.maKH}</span>
                            </div>
                        </div>

                        <div class="meta-box">
                            <div class="meta-box-title">Thông Tin Đơn Lưu Trú</div>
                            <div class="meta-row">
                                <span class="meta-label">Mã Booking:</span>
                                <span class="meta-value">${invoice.maBooking}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Thu ngân phụ trách:</span>
                                <span class="meta-value">${invoice.tenNVLap}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">Trạng thái quyết toán:</span>
                                <span class="meta-value">
                                    <c:choose>
                                        <c:when test="${invoice.trangThaiHoaDon == 'DaThanhToanDu'}">
                                            <span class="badge-status badge-paid">ĐÃ THANH TOÁN ĐỦ</span>
                                        </c:when>
                                        <c:when
                                            test="${invoice.trangThaiHoaDon == 'MotPhan' || invoice.daThanhToan gt 0}">
                                            <span class="badge-status badge-partial">THANH TOÁN MỘT PHẦN</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status badge-unpaid">CHƯA THANH TOÁN</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Bảng Kê Tiền Phòng -->
                    <div class="section-title">1. Bảng Kê Chi Tiết Tiền Phòng</div>
                    <table class="invoice-table">
                        <thead>
                            <tr>
                                <th style="width: 40px;">STT</th>
                                <th>Phòng</th>
                                <th>Hạng Phòng</th>
                                <th>Ngày Check-in</th>
                                <th>Ngày Check-out</th>
                                <th style="text-align: center;">Số Đêm</th>
                                <th style="text-align: right;">Đơn Giá</th>
                                <th style="text-align: right;">Thành Tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${invoice.rooms}" varStatus="status">
                                <tr>
                                    <td>${status.index + 1}</td>
                                    <td><strong>${r.maPhong}</strong></td>
                                    <td>${r.tenLoaiPhong}</td>
                                    <td>
                                        <fmt:formatDate value="${r.ngayCheckInThucTe}" pattern="dd/MM/yyyy HH:mm" />
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${r.ngayCheckOutThucTe != null}">
                                                <fmt:formatDate value="${r.ngayCheckOutThucTe}"
                                                    pattern="dd/MM/yyyy HH:mm" />
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #64748b;">(Đang ở - Dự kiến:
                                                    <fmt:formatDate value="${r.ngayTraDuKien}" pattern="dd/MM/yyyy" />)
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="text-align: center;">${r.soDem}</td>
                                    <td style="text-align: right;">
                                        <fmt:formatNumber value="${r.donGiaPhong}" pattern="#,##0" /> đ
                                    </td>
                                    <td style="text-align: right; font-weight: 600;">
                                        <fmt:formatNumber value="${r.thanhTien}" pattern="#,##0" /> đ
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- Bảng Kê Dịch Vụ Đã Dùng -->
                    <c:if test="${not empty invoice.services}">
                        <div class="section-title">2. Bảng Kê Dịch Vụ Phát Sinh</div>
                        <table class="invoice-table">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">STT</th>
                                    <th>Tên Dịch Vụ</th>
                                    <th>Phòng Sử Dụng</th>
                                    <th>Thời Điểm Gọi</th>
                                    <th style="text-align: right;">Đơn Giá</th>
                                    <th style="text-align: center;">Số Lượng</th>
                                    <th style="text-align: right;">Thành Tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${invoice.services}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td><strong>${s.tenDichVu}</strong></td>
                                        <td>Phòng ${s.maPhong}</td>
                                        <td>
                                            <fmt:formatDate value="${s.thoiDiemThem}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td style="text-align: right;">
                                            <fmt:formatNumber value="${s.donGia}" pattern="#,##0" /> đ
                                        </td>
                                        <td style="text-align: center;">${s.soLuong}</td>
                                        <td style="text-align: right; font-weight: 600;">
                                            <fmt:formatNumber value="${s.thanhTien}" pattern="#,##0" /> đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:if>

                    <!-- Bảng Kê Lịch Sử Thu Tiền Ca Thu Ngân -->
                    <c:if test="${not empty paymentHistory}">
                        <div class="section-title">3. Nhật Ký Giao Dịch Thanh Toán (Đối Soát Ca Làm Việc)</div>
                        <table class="invoice-table">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">STT</th>
                                    <th>Mã Giao Dịch</th>
                                    <th>Thu Ngân Tiếp Nhận</th>
                                    <th>Thời Điểm Thu</th>
                                    <th>Hình Thức</th>
                                    <th style="text-align: right;">Số Tiền Ghi Nhận</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${paymentHistory}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td><strong>${p.maThanhToan}</strong></td>
                                        <td>${p.tenNV} (${p.maNV})</td>
                                        <td>
                                            <fmt:formatDate value="${p.thoiDiemThanhToan}"
                                                pattern="dd/MM/yyyy HH:mm:ss" />
                                        </td>
                                        <td>${p.phuongThucThanhToan}</td>
                                        <td style="text-align: right; font-weight: 700; color: #059669;">
                                            <fmt:formatNumber value="${p.soTien}" pattern="#,##0" /> đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:if>

                    <!-- Tổng Kết Tài Chính -->
                    <div class="summary-block">
                        <div class="summary-box">
                            <div class="summary-row">
                                <span style="color: #475569;">Tổng chi phí phòng &amp; dịch vụ:</span>
                                <span style="font-weight: 700;">
                                    <fmt:formatNumber value="${invoice.tongTienCuoiCung}" pattern="#,##0" /> đ
                                </span>
                            </div>
                            <div class="summary-row">
                                <span style="color: #059669;">Đã thanh toán (các ca):</span>
                                <span style="font-weight: 700; color: #059669;">
                                    -
                                    <fmt:formatNumber value="${invoice.daThanhToan}" pattern="#,##0" /> đ
                                </span>
                            </div>
                            <div class="summary-row summary-row-final">
                                <span>CÒN THIẾU CẦN THU:</span>
                                <c:choose>
                                    <c:when test="${invoice.conThieu gt 0}">
                                        <span style="color: #dc2626;">
                                            <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: #059669;">
                                            <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>

                    <!-- Chữ Ký Xác Nhận -->
                    <div class="signatures-block">
                        <div>
                            <div class="signature-title">KHÁCH HÀNG</div>
                            <div class="signature-sub">(Ký và ghi rõ họ tên)</div>
                            <div class="signature-space"></div>
                            <div class="signature-name">${invoice.tenKhachHang}</div>
                        </div>
                        <div>
                            <div class="signature-title">THU NGÂN TIẾP NHẬN</div>
                            <div class="signature-sub">(Ký và ghi rõ họ tên)</div>
                            <div class="signature-space"></div>
                            <div class="signature-name">${invoice.tenNVLap}</div>
                        </div>
                    </div>
                </div>
            </div>

            <jsp:include page="/views/common/footer.jsp" />