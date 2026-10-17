<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thu Ngân - Chi Tiết Đơn Đặt Phòng ${invoice.maBooking}" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="cashier/booking_detail.css" />
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
            <strong>Chi Tiết Đơn ${invoice.maBooking}</strong>
        </nav>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" role="alert">
                <strong>Lỗi:</strong> ${errorMessage}
            </div>
        </c:if>

        <div class="page-header">
            <div class="page-header-main">
                <h1 class="page-title">Đơn Đặt Phòng: ${invoice.maBooking}</h1>
                <p class="page-subtitle">
                    Mã Hóa Đơn Quyết Toán: <strong>${invoice.maHoaDon}</strong> | Thu ngân tiếp nhận: <strong>${invoice.tenNVLap}</strong>
                </p>
            </div>
            <div class="page-actions">
                <c:choose>
                    <c:when test="${invoice.trangThaiHoaDon == 'Paid'}">
                        <span class="badge badge-success">Đã thanh toán đủ</span>
                    </c:when>
                    <c:when test="${invoice.trangThaiHoaDon == 'PartiallyPaid' || invoice.trangThaiHoaDon == 'Partial' || invoice.daThanhToan > 0}">
                        <span class="badge badge-warning">Thanh toán một phần</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge badge-danger">Chưa thanh toán</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Thông tin khách hàng & Tài chính tổng quan -->
        <div class="grid-2 mb-6">
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Thông Tin Khách Hàng</h2>
                </div>
                <div class="card-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Họ và Tên</span>
                            <span class="detail-value">${invoice.tenKhachHang}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Số CCCD / Hộ Chiếu</span>
                            <span class="detail-value mono">${invoice.cccd}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Số Điện Thoại</span>
                            <span class="detail-value mono">${invoice.soDT}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Mã Khách Hàng</span>
                            <span class="detail-value mono">${invoice.maKH}</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Đối Soát Tài Chính</h2>
                </div>
                <div class="card-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Tổng Chi Phí Hóa Đơn</span>
                            <span class="detail-value text-primary mono fw-bold">
                                <fmt:formatNumber value="${invoice.tongTienCuoiCung}" pattern="#,##0" /> đ
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Đã Ghi Nhận Thanh Toán</span>
                            <span class="detail-value text-success mono fw-bold">
                                <fmt:formatNumber value="${invoice.daThanhToan}" pattern="#,##0" /> đ
                            </span>
                        </div>
                        <div class="detail-item" style="grid-column: span 2;">
                            <span class="detail-label">Số Tiền Còn Thiếu</span>
                            <span class="detail-value text-danger mono text-lg fw-bold">
                                <fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <c:set var="hasUncheckedRooms" value="false" />
        <c:forEach var="r" items="${invoice.rooms}">
            <c:if test="${r.trangThaiDatPhong != 'Cancelled' && r.ngayCheckOutThucTe == null && r.ngayCheckInThucTe != null}">
                <c:set var="hasUncheckedRooms" value="true" />
            </c:if>
        </c:forEach>

        <!-- Form Chọn Phòng để Chuyển sang Bước Thanh Toán -->
        <form action="${pageContext.request.contextPath}/cashier/payment" method="GET" id="checkoutForm">
            <input type="hidden" name="maBooking" value="${invoice.maBooking}" />
            <input type="hidden" name="maHoaDon" value="${invoice.maHoaDon}" />

            <div class="card card-flush">
                <div class="card-toolbar">
                    <h2 class="card-title">Danh Sách Phòng Trong Đơn (Tích chọn phòng cần trả)</h2>
                    <c:choose>
                        <c:when test="${hasUncheckedRooms}">
                            <label class="flex items-center gap-2 text-sm fw-medium" style="cursor: pointer;">
                                <input type="checkbox" id="selectAllRooms" onchange="toggleSelectAllRooms(this)" />
                                Chọn tất cả phòng đang ở
                            </label>
                        </c:when>
                        <c:otherwise>
                            <span class="text-success text-sm fw-semibold">Tất cả phòng hợp lệ đã trả</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="table-wrapper">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 50px; text-align: center;">Chọn</th>
                                <th>Phòng</th>
                                <th>Hạng Phòng</th>
                                <th>Thời Gian Check-in</th>
                                <th>Thời Gian Check-out</th>
                                <th>Số Đêm</th>
                                <th class="text-right">Đơn Giá / Đêm</th>
                                <th class="text-right">Thành Tiền Phòng</th>
                                <th class="text-center">Trạng Thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="room" items="${invoice.rooms}">
                                <tr <c:if test="${room.trangThaiDatPhong == 'Cancelled'}">style="opacity: 0.7; background: #fef2f2;"</c:if>>
                                    <td style="text-align: center;">
                                        <c:choose>
                                            <c:when test="${room.trangThaiDatPhong == 'Cancelled'}">
                                                <span class="text-muted font-bold">[--]</span>
                                            </c:when>
                                            <c:when test="${room.ngayCheckOutThucTe == null && room.ngayCheckInThucTe != null}">
                                                <input type="checkbox" name="selectedRooms" value="${room.maPhong}"
                                                       class="room-checkbox room-selectable" />
                                            </c:when>
                                            <c:otherwise>
                                                <input type="checkbox" disabled class="room-checkbox" />
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><strong>${room.maPhong}</strong></td>
                                    <td>${room.tenLoaiPhong}</td>
                                    <td class="mono">
                                        <fmt:formatDate value="${room.ngayCheckInThucTe}" pattern="dd/MM/yyyy HH:mm" />
                                    </td>
                                    <td class="mono">
                                        <c:choose>
                                            <c:when test="${room.trangThaiDatPhong == 'Cancelled'}">
                                                <span class="text-danger" style="font-style: italic;">(Đã hủy phòng)</span>
                                            </c:when>
                                            <c:when test="${room.ngayCheckOutThucTe != null}">
                                                <fmt:formatDate value="${room.ngayCheckOutThucTe}" pattern="dd/MM/yyyy HH:mm" />
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">(Dự kiến: <fmt:formatDate value="${room.ngayTraDuKien}" pattern="dd/MM/yyyy" />)</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${room.soDem} đêm</td>
                                    <td class="text-right mono">
                                        <fmt:formatNumber value="${room.donGiaPhong}" pattern="#,##0" /> đ
                                    </td>
                                    <td class="text-right mono">
                                        <c:choose>
                                            <c:when test="${room.trangThaiDatPhong == 'Cancelled'}">
                                                <span class="text-danger font-bold">0 đ <small class="text-muted">(Đã hủy)</small></span>
                                            </c:when>
                                            <c:otherwise>
                                                <strong><fmt:formatNumber value="${room.thanhTien}" pattern="#,##0" /> đ</strong>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${room.trangThaiDatPhong == 'Cancelled'}">
                                                <span class="badge badge-danger" style="background: #fee2e2; color: #b91c1c; border: 1px solid #f87171;">Đã hủy</span>
                                            </c:when>
                                            <c:when test="${room.ngayCheckOutThucTe != null}">
                                                <span class="badge badge-neutral">Đã trả phòng</span>
                                            </c:when>
                                            <c:when test="${room.ngayCheckInThucTe != null}">
                                                <span class="badge badge-success">Đang lưu trú</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-warning">Chưa nhận phòng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Bảng kê dịch vụ đã sử dụng -->
            <c:if test="${not empty invoice.services}">
                <div class="card card-flush">
                    <div class="card-toolbar">
                        <h2 class="card-title">Dịch Vụ Đã Sử Dụng Theo Từng Phòng</h2>
                        <span class="text-sm text-muted">${invoice.services.size()} dịch vụ phát sinh</span>
                    </div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Tên Dịch Vụ</th>
                                    <th>Phòng Gọi</th>
                                    <th>Thời Điểm Gọi</th>
                                    <th class="text-right">Đơn Giá</th>
                                    <th class="text-center">Số Lượng</th>
                                    <th class="text-right">Thành Tiền Dịch Vụ</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="srv" items="${invoice.services}">
                                    <tr>
                                        <td><strong>${srv.tenDichVu}</strong></td>
                                        <td>Phòng ${srv.maPhong}</td>
                                        <td class="mono">
                                            <fmt:formatDate value="${srv.thoiDiemThem}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td class="text-right mono">
                                            <fmt:formatNumber value="${srv.donGia}" pattern="#,##0" /> đ
                                        </td>
                                        <td class="text-center mono">${srv.soLuong}</td>
                                        <td class="text-right mono">
                                            <strong><fmt:formatNumber value="${srv.thanhTien}" pattern="#,##0" /> đ</strong>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <!-- Thanh điều hướng thao tác -->
            <div class="form-actions" style="justify-content: space-between;">
                <div>
                    <a href="${pageContext.request.contextPath}/cashier/dashboard" class="btn btn-secondary">
                        &larr; Quay lại danh sách
                    </a>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${!hasUncheckedRooms && (invoice.conThieu == null || invoice.conThieu le 0)}">
                            <div class="flex items-center gap-3">
                                <span class="text-success text-sm fw-semibold">
                                    Đơn đã trả hết phòng và thanh toán đủ
                                </span>
                                <a href="${pageContext.request.contextPath}/cashier/invoice?maHoaDon=${invoice.maHoaDon}"
                                   class="btn btn-success btn-lg">
                                    In / Xem Hóa Đơn &rarr;
                                </a>
                            </div>
                        </c:when>
                        <c:when test="${!hasUncheckedRooms && invoice.conThieu gt 0}">
                            <button type="submit" class="btn btn-warning btn-lg">
                                Quyết Toán Công Nợ Còn Thiếu (<fmt:formatNumber value="${invoice.conThieu}" pattern="#,##0" /> đ) &rarr;
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button type="submit" class="btn btn-primary btn-lg">
                                Tiếp Tục Chọn Phương Thức Thanh Toán &amp; Trả Phòng &rarr;
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </form>
    </main>
</div>

<script src="${pageContext.request.contextPath}/assets/js/cashier/booking_detail.js"></script>

<jsp:include page="/views/common/footer.jsp" />
