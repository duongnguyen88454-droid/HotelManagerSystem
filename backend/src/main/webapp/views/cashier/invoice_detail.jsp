<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="/views/common/header.jsp" />
            <jsp:include page="/views/common/navbar.jsp" />

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cashier/invoice_detail.css">

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
                        Giao dịch thanh toán đã được ghi nhận thành công vào hệ thống! Hóa đơn quyết toán đã được cập nhật.
                    </div>
                </c:if>
                <c:if test="${checkoutSuccess}">
                    <div class="alert-success" style="background-color: #eff6ff; color: #1d4ed8; border-color: #bfdbfe;">
                        Đã cập nhật hoàn tất trả phòng thành công!
                    </div>
                </c:if>
                <c:if test="${alreadyPaidInfo}">
                    <div class="alert-info" style="background-color: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; font-weight: 500;">
                        Đơn đặt phòng này đã hoàn tất toàn bộ thủ tục trả phòng và thanh toán đầy đủ trước đó.
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
                                        <c:when test="${invoice.trangThaiHoaDon == 'Paid'}">
                                            <span class="badge-status badge-paid">ĐÃ THANH TOÁN ĐỦ</span>
                                        </c:when>
                                        <c:when
                                            test="${invoice.trangThaiHoaDon == 'PartiallyPaid' || invoice.trangThaiHoaDon == 'Partial' || invoice.daThanhToan gt 0}">
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
                            <c:if test="${invoice.totalRoomCharge != null && invoice.totalRoomCharge gt 0}">
                                <div class="summary-row">
                                    <span style="color: #475569;">Tiền phòng lưu trú:</span>
                                    <span style="font-weight: 600;">
                                        <fmt:formatNumber value="${invoice.totalRoomCharge}" pattern="#,##0" /> đ
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${invoice.totalServiceCharge != null && invoice.totalServiceCharge gt 0}">
                                <div class="summary-row">
                                    <span style="color: #475569;">Tiền dịch vụ phát sinh:</span>
                                    <span style="font-weight: 600;">
                                        <fmt:formatNumber value="${invoice.totalServiceCharge}" pattern="#,##0" /> đ
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${invoice.earlyCheckInFee != null && invoice.earlyCheckInFee gt 0}">
                                <div class="summary-row">
                                    <span style="color: #d97706;">Phụ thu nhận phòng sớm (&lt;13h):</span>
                                    <span style="font-weight: 600; color: #d97706;">
                                        + <fmt:formatNumber value="${invoice.earlyCheckInFee}" pattern="#,##0" /> đ
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${invoice.lateCheckOutFee != null && invoice.lateCheckOutFee gt 0}">
                                <div class="summary-row">
                                    <span style="color: #d97706;">Phụ thu trả phòng trễ (&gt;12h):</span>
                                    <span style="font-weight: 600; color: #d97706;">
                                        + <fmt:formatNumber value="${invoice.lateCheckOutFee}" pattern="#,##0" /> đ
                                    </span>
                                </div>
                            </c:if>
                            <div class="summary-row">
                                <span style="color: #1e293b; font-weight: 700;">Tổng cộng quyết toán:</span>
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