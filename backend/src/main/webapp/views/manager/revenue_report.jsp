<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Báo Cáo Doanh Thu Khách Sạn" />
    <jsp:param name="zone" value="portal" />
</jsp:include>

<div class="portal-layout">
    <!-- Thanh chức năng bên trái (Sidebar với 4 menu con) -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="revenue" />
        <jsp:param name="activeSubMenu" value="${reportType}" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="page-header">
            <div class="page-header-left">
                <c:choose>
                    <c:when test="${reportType eq 'room'}">
                        <h1 class="page-title">Báo Cáo Doanh Thu Tiền Phòng</h1>
                        <p class="page-subtitle">Thống kê số lượt đặt, số đêm lưu trú và tổng doanh thu từng phòng trong khoảng thời gian</p>
                    </c:when>
                    <c:when test="${reportType eq 'product'}">
                        <h1 class="page-title">Báo Cáo Doanh Thu Sản Phẩm &amp; Dịch Vụ</h1>
                        <p class="page-subtitle">Thống kê số lượng tiêu thụ và tổng doanh thu các sản phẩm, minibar và dịch vụ gia tăng đã bán</p>
                    </c:when>
                    <c:when test="${reportType eq 'overall'}">
                        <h1 class="page-title">Báo Cáo Tổng Doanh Thu &amp; Dòng Tiền Thu Chi</h1>
                        <p class="page-subtitle">Xem chi tiết tổng doanh thu của khách sạn từ các mã phiếu theo loại thu chi và phương thức thanh toán</p>
                    </c:when>
                    <c:otherwise>
                        <h1 class="page-title">Báo Cáo Doanh Thu Hóa Đơn</h1>
                        <p class="page-subtitle">Cung cấp toàn bộ thông tin từ tất cả các hóa đơn phát sinh trong quá trình giao dịch ở khách sạn</p>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="page-header-right">
                <span class="pill pill-primary">Ca trực: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- THANH CÔNG CỤ LỌC & THAO TÁC (FILTER TOOLBAR) -->
        <div class="card p-3 mb-4">
            <form action="${pageContext.request.contextPath}/manager/revenue" method="GET" class="filter-group">
                <input type="hidden" name="type" value="${reportType}" />
                
                <div class="flex items-center gap-2">
                    <label class="form-label mb-0 nowrap font-bold text-secondary">Từ Ngày:</label>
                    <input type="date" name="fromDate" value="${fromDate}" required class="form-control" />
                </div>

                <div class="flex items-center gap-2">
                    <label class="form-label mb-0 nowrap font-bold text-secondary">Đến Ngày:</label>
                    <input type="date" name="toDate" value="${toDate}" required class="form-control" />
                </div>

                <c:if test="${reportType ne 'product'}">
                    <div class="flex items-center gap-2">
                        <label class="form-label mb-0 nowrap font-bold text-secondary">Nhân Viên:</label>
                        <select name="employeeId" class="form-control" style="min-width: 170px;">
                            <option value="">Tất cả nhân viên</option>
                            <c:forEach var="emp" items="${employeeList}">
                                <option value="${emp.employeeId}" ${selectedEmployeeId eq emp.employeeId ? 'selected' : ''}>
                                    ${emp.fullName} (${emp.employeeId})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>

                <div class="flex gap-2" style="margin-left: auto;">
                    <button type="submit" class="btn btn-primary btn-sm">
                        Tải Lại
                    </button>
                    <button type="button" class="btn btn-success btn-sm" onclick="exportTableToExcel('reportDataTable', 'BaoCao_${reportType}_${fromDate}_${toDate}');">
                        Xuất Excel
                    </button>
                </div>
            </form>
        </div>

        <!-- PHÂN HỆ 1: DOANH THU HÓA ĐƠN -->
        <c:if test="${empty reportType or reportType eq 'invoice'}">
            <c:set var="sumDeposit" value="0" />
            <c:set var="sumRoom" value="0" />
            <c:set var="sumService" value="0" />
            <c:set var="sumSurcharge" value="0" />
            <c:set var="sumFinal" value="0" />
            <c:set var="sumPaid" value="0" />
            <c:forEach var="item" items="${invoiceReport}">
                <c:set var="sumDeposit" value="${sumDeposit + item.deposit}" />
                <c:set var="sumRoom" value="${sumRoom + item.roomCharge}" />
                <c:set var="sumService" value="${sumService + item.serviceCharge}" />
                <c:set var="sumSurcharge" value="${sumSurcharge + item.surcharge}" />
                <c:set var="sumFinal" value="${sumFinal + item.finalTotalAmount}" />
                <c:set var="sumPaid" value="${sumPaid + item.paidAmount}" />
            </c:forEach>

            <div class="card p-0">
                <div class="table-wrapper">
                    <table class="table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Hóa Đơn</th>
                                <th>Khách Hàng</th>
                                <th>Phòng</th>
                                <th>Ngày Lập</th>
                                <th class="text-right">Đặt Trước</th>
                                <th class="text-right">Tiền Phòng</th>
                                <th class="text-right">Dịch Vụ</th>
                                <th class="text-right">Phụ Thu</th>
                                <th class="text-right">Tổng Tiền</th>
                                <th class="text-right text-success">Thực Thu</th>
                                <th class="text-center">Trạng Thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG ĐẬM NÉT ĐẦU BẢNG -->
                            <tr class="summary-highlight-row">
                                <td colspan="4" class="text-primary font-bold text-sm">
                                    TỔNG TIỀN (${not empty invoiceReport ? invoiceReport.size() : 0} hóa đơn)
                                </td>
                                <td class="text-right mono">
                                    <fmt:formatNumber value="${sumDeposit}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td class="text-right mono">
                                    <fmt:formatNumber value="${sumRoom}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td class="text-right mono">
                                    <fmt:formatNumber value="${sumService}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td class="text-right mono">
                                    <fmt:formatNumber value="${sumSurcharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td class="text-right text-primary mono font-bold">
                                    <fmt:formatNumber value="${sumFinal}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td class="text-right text-success mono font-bold text-sm">
                                    <fmt:formatNumber value="${sumPaid}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td class="text-center">-</td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty invoiceReport}">
                                    <c:forEach var="inv" items="${invoiceReport}">
                                        <tr>
                                            <td>
                                                <strong class="text-primary">${inv.invoiceId}</strong>
                                            </td>
                                            <td class="font-semibold">${inv.customerName}</td>
                                            <td class="text-secondary text-sm">${inv.roomNames}</td>
                                            <td class="text-muted text-xs">${inv.createDate}</td>
                                            <td class="text-right mono">
                                                <fmt:formatNumber value="${inv.deposit}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-right mono">
                                                <fmt:formatNumber value="${inv.roomCharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-right mono">
                                                <fmt:formatNumber value="${inv.serviceCharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-right mono">
                                                <fmt:formatNumber value="${inv.surcharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-right font-semibold mono">
                                                <fmt:formatNumber value="${inv.finalTotalAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-right font-bold text-success mono">
                                                <fmt:formatNumber value="${inv.paidAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-center">
                                                <c:choose>
                                                    <c:when test="${inv.invoiceStatus eq 'Paid'}">
                                                        <span class="badge badge-success badge-pill badge-available">Đã Quyết Toán</span>
                                                    </c:when>
                                                    <c:when test="${inv.invoiceStatus eq 'PartiallyPaid'}">
                                                        <span class="badge badge-warning badge-pill badge-cleaning">Một Phần</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger badge-pill badge-occupied">Chưa Thanh Toán</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="11" class="text-center py-6 text-muted">
                                            Không tìm thấy hóa đơn nào trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <div class="report-pagination-container pagination-bar" style="display: none;">
                    <div class="report-pagination-info pagination-info">
                        Hiển thị <strong class="page-start">1</strong> - <strong class="page-end">10</strong> trên tổng số <strong class="page-total">0</strong> dòng
                    </div>
                    <div class="report-pagination-buttons pagination-actions"></div>
                </div>
            </div>
        </c:if>

        <!-- PHÂN HỆ 2: DOANH THU TIỀN PHÒNG (TỔNG HỢP THEO PHÒNG) -->
        <c:if test="${reportType eq 'room'}">
            <c:set var="sumBookings" value="0" />
            <c:set var="sumNights" value="0" />
            <c:set var="sumRoomRevenue" value="0" />
            <c:forEach var="item" items="${roomReport}">
                <c:set var="sumBookings" value="${sumBookings + item.totalBookings}" />
                <c:set var="sumNights" value="${sumNights + item.totalNights}" />
                <c:set var="sumRoomRevenue" value="${sumRoomRevenue + item.totalRevenue}" />
            </c:forEach>

            <div class="card p-0">
                <div class="table-wrapper">
                    <table class="table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Phòng</th>
                                <th>Tên Phòng (Số Phòng)</th>
                                <th>Hạng Phòng</th>
                                <th class="text-right">Đơn Giá Niêm Yết</th>
                                <th class="text-center">Số Lượt Đặt</th>
                                <th class="text-center">Số Đêm Đã Thuê</th>
                                <th class="text-right text-success">Tổng Doanh Thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG TIỀN PHÒNG -->
                            <tr class="summary-highlight-row">
                                <td colspan="4" class="text-primary font-bold text-sm">
                                    TỔNG DOANH THU TIỀN PHÒNG (${not empty roomReport ? roomReport.size() : 0} phòng)
                                </td>
                                <td class="text-center text-primary font-bold">
                                    ${sumBookings} lượt
                                </td>
                                <td class="text-center text-primary font-bold">
                                    ${sumNights} đêm
                                </td>
                                <td class="text-right text-success mono font-bold text-sm">
                                    <fmt:formatNumber value="${sumRoomRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty roomReport}">
                                    <c:forEach var="r" items="${roomReport}">
                                        <tr>
                                            <td><strong class="text-primary">${r.roomId}</strong></td>
                                            <td class="font-semibold text-main">${r.roomName}</td>
                                            <td class="text-secondary text-sm">${r.roomTypeName}</td>
                                            <td class="text-right mono">
                                                <fmt:formatNumber value="${r.basePrice}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-center font-semibold">
                                                ${r.totalBookings}
                                            </td>
                                            <td class="text-center font-bold">
                                                ${r.totalNights}
                                            </td>
                                            <td class="text-right font-bold text-success mono text-sm">
                                                <fmt:formatNumber value="${r.totalRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="text-center py-6 text-muted">
                                            Chưa ghi nhận doanh thu phòng nào trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <div class="report-pagination-container pagination-bar" style="display: none;">
                    <div class="report-pagination-info pagination-info">
                        Hiển thị <strong class="page-start">1</strong> - <strong class="page-end">10</strong> trên tổng số <strong class="page-total">0</strong> dòng
                    </div>
                    <div class="report-pagination-buttons pagination-actions"></div>
                </div>
            </div>
        </c:if>

        <!-- PHÂN HỆ 3: DOANH THU SẢN PHẨM & DỊCH VỤ -->
        <c:if test="${reportType eq 'product'}">
            <c:set var="sumQty" value="0" />
            <c:set var="sumProductRevenue" value="0" />
            <c:forEach var="item" items="${productReport}">
                <c:set var="sumQty" value="${sumQty + item.quantitySold}" />
                <c:set var="sumProductRevenue" value="${sumProductRevenue + item.totalRevenue}" />
            </c:forEach>

            <div class="card p-0">
                <div class="table-wrapper">
                    <table class="table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Dịch Vụ / Sản Phẩm</th>
                                <th>Tên Sản Phẩm / Dịch Vụ Tiêu Dùng</th>
                                <th class="text-right">Đơn Giá Niêm Yết</th>
                                <th class="text-center">Số Lượng Đã Bán</th>
                                <th class="text-right text-success">Tổng Doanh Thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG SẢN PHẨM -->
                            <tr class="summary-highlight-row">
                                <td colspan="3" class="text-primary font-bold text-sm">
                                    TỔNG DOANH THU TIÊU DÙNG (${not empty productReport ? productReport.size() : 0} mặt hàng)
                                </td>
                                <td class="text-center text-primary font-bold">
                                    ${sumQty} lượt
                                </td>
                                <td class="text-right text-success mono font-bold text-sm">
                                    <fmt:formatNumber value="${sumProductRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty productReport}">
                                    <c:forEach var="p" items="${productReport}">
                                        <tr>
                                            <td><strong class="text-primary">${p.serviceId}</strong></td>
                                            <td class="font-semibold text-main">${p.serviceName}</td>
                                            <td class="text-right mono">
                                                <fmt:formatNumber value="${p.basePrice}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-center font-bold">
                                                ${p.quantitySold}
                                            </td>
                                            <td class="text-right font-bold text-success mono text-sm">
                                                <fmt:formatNumber value="${p.totalRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" class="text-center py-6 text-muted">
                                            Chưa ghi nhận doanh thu sản phẩm nào trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <div class="report-pagination-container pagination-bar" style="display: none;">
                    <div class="report-pagination-info pagination-info">
                        Hiển thị <strong class="page-start">1</strong> - <strong class="page-end">10</strong> trên tổng số <strong class="page-total">0</strong> dòng
                    </div>
                    <div class="report-pagination-buttons pagination-actions"></div>
                </div>
            </div>
        </c:if>

        <!-- PHÂN HỆ 4: TỔNG DOANH THU & PHIẾU THU DÒNG TIỀN -->
        <c:if test="${reportType eq 'overall'}">
            <c:set var="sumOverall" value="0" />
            <c:forEach var="item" items="${overallReport}">
                <c:set var="sumOverall" value="${sumOverall + item.totalAmount}" />
            </c:forEach>

            <div class="card p-0">
                <div class="table-wrapper">
                    <table class="table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Phiếu Thu</th>
                                <th>Mã Hóa Đơn</th>
                                <th>Mã Booking</th>
                                <th>Khách Nộp Tiền</th>
                                <th>Thời Điểm Thu</th>
                                <th>Phương Thức</th>
                                <th>Nhân Viên Thu</th>
                                <th class="text-right text-success">Số Tiền Thực Thu</th>
                                <th>Ghi Chú</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG PHIẾU THU -->
                            <tr class="summary-highlight-row">
                                <td colspan="7" class="text-primary font-bold text-sm">
                                    TỔNG THỰC THU (${not empty overallReport ? overallReport.size() : 0} phiếu thu)
                                </td>
                                <td class="text-right text-success mono font-bold text-sm">
                                    <fmt:formatNumber value="${sumOverall}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td>-</td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty overallReport}">
                                    <c:forEach var="pay" items="${overallReport}">
                                        <tr>
                                            <td><strong class="text-primary">${pay.paymentId}</strong></td>
                                            <td class="font-semibold text-main">${pay.invoiceId}</td>
                                            <td class="text-secondary text-sm">${pay.bookingId}</td>
                                            <td class="font-semibold">${pay.customerName}</td>
                                            <td class="text-muted text-xs">${pay.paymentDate}</td>
                                            <td>
                                                <span class="badge badge-success badge-pill badge-available">${pay.paymentMethod}</span>
                                            </td>
                                            <td class="text-secondary text-xs">${pay.staffName}</td>
                                            <td class="text-right font-bold text-success mono text-sm">
                                                <fmt:formatNumber value="${pay.totalAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td class="text-muted text-xs" style="max-width: 200px;">${pay.note}</td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" class="text-center py-6 text-muted">
                                            Không có phiếu thu nào được ghi nhận trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <div class="report-pagination-container pagination-bar" style="display: none;">
                    <div class="report-pagination-info pagination-info">
                        Hiển thị <strong class="page-start">1</strong> - <strong class="page-end">10</strong> trên tổng số <strong class="page-total">0</strong> dòng
                    </div>
                    <div class="report-pagination-buttons pagination-actions"></div>
                </div>
            </div>
        </c:if>
    </main>
</div>

<!-- JAVASCRIPT PHÂN TRANG 10 DÒNG/TRANG & XUẤT EXCEL THUẦN -->
<script>
document.addEventListener('DOMContentLoaded', function () {
    initTablePagination();
});

function initTablePagination() {
    var table = document.getElementById('reportDataTable');
    if (!table) return;

    var tbody = table.querySelector('tbody');
    if (!tbody) return;

    var allRows = Array.from(tbody.querySelectorAll('tr'));
    var dataRows = allRows.filter(function (row) {
        return !row.classList.contains('summary-highlight-row') && row.querySelectorAll('td').length > 1;
    });

    var totalItems = dataRows.length;
    var pageSize = 10;
    var totalPages = Math.ceil(totalItems / pageSize);

    var pagContainer = document.querySelector('.report-pagination-container');
    if (!pagContainer) return;

    if (totalItems <= pageSize) {
        pagContainer.style.display = 'none';
        return;
    }

    pagContainer.style.display = 'flex';
    var currentPage = 1;

    function showPage(page) {
        currentPage = page;
        var startIdx = (page - 1) * pageSize;
        var endIdx = Math.min(startIdx + pageSize, totalItems);

        dataRows.forEach(function (row, idx) {
            if (idx >= startIdx && idx < endIdx) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });

        var startEl = pagContainer.querySelector('.page-start');
        var endEl = pagContainer.querySelector('.page-end');
        var totalEl = pagContainer.querySelector('.page-total');
        if (startEl) startEl.textContent = (startIdx + 1);
        if (endEl) endEl.textContent = endIdx;
        if (totalEl) totalEl.textContent = totalItems;

        renderButtons();
    }

    function renderButtons() {
        var btnContainer = pagContainer.querySelector('.report-pagination-buttons');
        if (!btnContainer) return;
        btnContainer.innerHTML = '';

        // Nút Trước
        var prevBtn = createPageBtn('« Trước', currentPage > 1, function () {
            if (currentPage > 1) showPage(currentPage - 1);
        });
        btnContainer.appendChild(prevBtn);

        // Các nút số trang
        for (var i = 1; i <= totalPages; i++) {
            (function (p) {
                var pageBtn = createPageBtn(p, true, function () {
                    showPage(p);
                });
                if (p === currentPage) {
                    pageBtn.className = 'btn btn-primary btn-sm';
                } else {
                    pageBtn.className = 'btn btn-outline btn-sm';
                }
                btnContainer.appendChild(pageBtn);
            })(i);
        }

        // Nút Kế tiếp
        var nextBtn = createPageBtn('Kế tiếp »', currentPage < totalPages, function () {
            if (currentPage < totalPages) showPage(currentPage + 1);
        });
        btnContainer.appendChild(nextBtn);
    }

    function createPageBtn(text, enabled, onClick) {
        var btn = document.createElement('button');
        btn.type = 'button';
        btn.textContent = text;
        btn.className = 'btn btn-outline btn-sm';
        btn.disabled = !enabled;
        if (enabled) {
            btn.addEventListener('click', onClick);
        }
        return btn;
    }

    showPage(1);
}

function exportTableToExcel(tableId, filename) {
    var table = document.getElementById(tableId);
    if (!table) {
        alert("Không tìm thấy bảng dữ liệu để xuất!");
        return;
    }

    var html = table.outerHTML;
    var template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">'
                 + '<head><meta charset="utf-8"><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>'
                 + '<x:Name>BaoCao</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head>'
                 + '<body>' + html + '</body></html>';

    var blob = new Blob(["\ufeff", template], {
        type: "application/vnd.ms-excel;charset=utf-8"
    });

    var downloadUrl = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = downloadUrl;
    a.download = (filename || "BaoCaoDoanhThu") + ".xls";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}
</script>

<jsp:include page="/views/common/footer.jsp" />