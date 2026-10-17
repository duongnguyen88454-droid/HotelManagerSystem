<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Hóa Đơn Quyết Toán - ${invoice.maHoaDon}" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="cashier/invoice_detail.css" />
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
            <strong>Hóa Đơn ${invoice.maHoaDon}</strong>
        </nav>

        <c:if test="${paymentSuccess}">
            <div class="alert alert-success">
                Giao dịch thanh toán đã được ghi nhận thành công vào hệ thống! Hóa đơn quyết toán đã được cập nhật.
            </div>
        </c:if>
        <c:if test="${checkoutSuccess}">
            <div class="alert alert-info">
                Đã cập nhật hoàn tất trả phòng thành công!
            </div>
        </c:if>
        <c:if test="${alreadyPaidInfo}">
            <div class="alert alert-success">
                Đơn đặt phòng này đã hoàn tất toàn bộ thủ tục trả phòng và thanh toán đầy đủ trước đó.
            </div>
        </c:if>

        <div class="page-header">
            <div class="flex gap-2">
                <a href="${pageContext.request.contextPath}/cashier/dashboard" class="btn btn-secondary">
                    &larr; Về Danh Sách Thu Ngân
                </a>
                <c:if test="${invoice.conThieu gt 0}">
                    <a href="${pageContext.request.contextPath}/cashier/payment?maHoaDon=${invoice.maHoaDon}" class="btn btn-warning">
                        Thu Tiền Tiếp
                    </a>
                </c:if>
            </div>
            <div>
                <button type="button" class="btn btn-primary" onclick="window.print()">In Hóa Đơn</button>
            </div>
        </div>

        <!-- Khung Hóa Đơn Quyết Toán Chính -->
        <div class="card invoice-sheet">
            <div class="card-body">
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
                        <div class="text-sm text-muted mt-1">
                            Ngày lập: <fmt:formatDate value="${invoice.ngayLap}" pattern="dd/MM/yyyy HH:mm" />
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
                            <span class="meta-value mono">${invoice.cccd}</span>
                        </div>
                        <div class="meta-row">
                            <span class="meta-label">Số điện thoại:</span>
                            <span class="meta-value mono">${invoice.soDT}</span>
                        </div>
                        <div class="meta-row">
                            <span class="meta-label">Mã khách hàng:</span>
                            <span class="meta-value mono">${invoice.maKH}</span>
                        </div>
                    </div>

                    <div class="meta-box">
                        <div class="meta-box-title">Thông Tin Đơn Lưu Trú</div>
                        <div class="meta-row">
                            <span class="meta-label">Mã Booking:</span>
                            <span class="meta-value mono">${invoice.maBooking}</span>
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
                                        <span class="badge badge-success">ĐÃ THANH TOÁN ĐỦ</span>
                                    </c:when>
                                    <c:when test="${invoice.trangThaiHoaDon == 'PartiallyPaid' || invoice.trangThaiHoaDon == 'Partial' || invoice.daThanhToan gt 0}">
                                        <span class="badge badge-warning">THANH TOÁN MỘT PHẦN</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-danger">CHƯA THANH TOÁN</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Bảng Kê Tiền Phòng -->
                <div class="section-title">1. Bảng Kê Chi Tiết Tiền Phòng</div>
                <div class="table-wrapper">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 40px;">STT</th>
                                <th>Phòng</th>
                                <th>Hạng Phòng</th>
                                <th>Ngày Check-in</th>
                                <th>Ngày Check-out</th>
                                <th class="text-center">Số Đêm</th>
                                <th class="text-right">Đơn Giá</th>
                                <th class="text-right">Thành Tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${invoice.rooms}" varStatus="status">
                                <tr>
                                    <td>${status.index + 1}</td>
                                    <td><strong>${r.maPhong}</strong></td>
                                    <td>${r.tenLoaiPhong}</td>
                                    <td class="mono">
                                        <fmt:formatDate value="${r.ngayCheckInThucTe}" pattern="dd/MM/yyyy HH:mm" />
                                    </td>
                                    <td class="mono">
                                        <c:choose>
                                            <c:when test="${r.ngayCheckOutThucTe != null}">
                                                <fmt:formatDate value="${r.ngayCheckOutThucTe}" pattern="dd/MM/yyyy HH:mm" />
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">(Đang ở - Dự kiến: <fmt:formatDate value="${r.ngayTraDuKien}" pattern="dd/MM/yyyy" />)</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">${r.soDem}</td>
                                    <td class="text-right mono">
                                        <fmt:formatNumber value="${r.donGiaPhong}" pattern="#,##0" /> đ
                                    </td>
                                    <td class="text-right fw-bold mono">
                                        <fmt:formatNumber value="${r.thanhTien}" pattern="#,##0" /> đ
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- Bảng Kê Dịch Vụ Đã Dùng -->
                <c:if test="${not empty invoice.services}">
                    <div class="section-title">2. Bảng Kê Dịch Vụ Phát Sinh</div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">STT</th>
                                    <th>Tên Dịch Vụ</th>
                                    <th>Phòng Sử Dụng</th>
                                    <th>Thời Điểm Gọi</th>
                                    <th class="text-right">Đơn Giá</th>
                                    <th class="text-center">Số Lượng</th>
                                    <th class="text-right">Thành Tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${invoice.services}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td><strong>${s.tenDichVu}</strong></td>
                                        <td>Phòng ${s.maPhong}</td>
                                        <td class="mono">
                                            <fmt:formatDate value="${s.thoiDiemThem}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td class="text-right mono">
                                            <fmt:formatNumber value="${s.donGia}" pattern="#,##0" /> đ
                                        </td>
                                        <td class="text-center mono">${s.soLuong}</td>
                                        <td class="text-right fw-bold mono">
                                            <fmt:formatNumber value="${s.thanhTien}" pattern="#,##0" /> đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <!-- Bảng Kê Lịch Sử Thu Tiền Ca Thu Ngân -->
                <c:if test="${not empty paymentHistory}">
                    <div class="section-title">3. Nhật Ký Giao Dịch Thanh Toán (Đối Soát Ca Làm Việc)</div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 40px;">STT</th>
                                    <th>Mã Giao Dịch</th>
                                    <th>Thu Ngân Tiếp Nhận</th>
                                    <th>Thời Điểm Thu</th>
                                    <th>Hình Thức</th>
                                    <th class="text-right">Số Tiền Ghi Nhận</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${paymentHistory}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td><strong class="mono">${p.maThanhToan}</strong></td>
                                        <td>${p.tenNV} (${p.maNV})</td>
                                        <td class="mono">
                                            <fmt:formatDate value="${p.thoiDiemThanhToan}" pattern="dd/MM/yyyy HH:mm:ss" />
                                        </td>
                                        <td><span class="pill">${p.phuongThucThanhToan}</span></td>
                                        <td class="text-right fw-bold text-success mono">
                                            <fmt:formatNumber value="${p.soTien}" pattern="#,##0" /> đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>

                <!-- Tổng Kết Tài Chính -->
                <div class="summary-block">
                    <div class="summary-box">
                        <c:if test="${invoice.totalRoomCharge != null && invoice.totalRoomCharge gt 0}">
                            <div class="summary-row">
                                <span class="text-secondary">Tiền phòng lưu trú:</span>
                                <span class="fw-semibold mono">
                                    <fmt:formatNumber value="${invoice.totalRoomCharge}" pattern="#,##0" /> đ
                                </span>
                            </div>
                        </c:if>
                        <c:if test="${invoice.totalServiceCharge != null && invoice.totalServiceCharge gt 0}">
                            <div class="summary-row">
                                <span class="text-secondary">Tiền dịch vụ phát sinh:</span>
                                <span class="fw-semibold mono">
                                    <fmt:formatNumber value="${invoice.totalServiceCharge}" pattern="#,##0" /> đ
                                </span>
                            </div>
                        </c:if>
                        <c:if test="${invoice.earlyCheckInFee != null && invoice.earlyCheckInFee gt 0}">
                            <div class="summary-row">
                                <span class="text-warning">Phụ thu nhận phòng sớm (&lt;13h):</span>
                                <span class="fw-semibold text-warning mono">
                                    + <fmt:formatNumber value="${invoice.earlyCheckInFee}" pattern="#,##0" /> đ
                                </span>
                            </div>
                        </c:if>
                        <c:if test="${invoice.lateCheckOutFee != null && invoice.lateCheckOutFee gt 0}">
                            <div class="summary-row">
                                <span class="text-warning">Phụ thu trả phòng trễ (&gt;12h):</span>
                                <span class="fw-semibold text-warning mono">
                                    + <fmt:formatNumber value="${invoice.lateCheckOutFee}" pattern="#,##0" /> đ
                                </span>
                            </div>
                        </c:if>
                        <div class="summary-row">
                            <span class="fw-bold">Tổng cộng quyết toán:</span>
                            <span class="fw-bold mono">
                                <fmt:formatNumber value="${invoice.tongTienCuoiCung}" pattern="#,##0" /> đ
                            </span>
                        </div>
                        <div class="summary-row">
                            <span class="text-success">Đã thanh toán (các ca):</span>
                            <span class="fw-bold text-success mono">
                                - <fmt:formatNumber value="${invoice.daThanhToan}" pattern="#,##0" /> đ
                            </span>
                        </div>
                        <div class="summary-row summary-row-final">
                            <span>CÒN THIẾU CẦN THU:</span>
                            <c:choose>
                                <c:when test="${invoice.conThieu gt 0}">
                                    <span class="text-danger mono">
                                        <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-success mono">
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
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />