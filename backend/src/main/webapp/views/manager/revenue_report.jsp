<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Báo Cáo Doanh Thu Khách Sạn" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<style>
.summary-highlight-row {
    background-color: #f1f5f9;
    font-weight: 700;
    color: var(--portal-text-primary);
    border-bottom: 2px solid var(--portal-border);
}
.summary-highlight-row td {
    padding: 12px 14px !important;
}
</style>

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái (Sidebar với 4 menu con) -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="revenue" />
        <jsp:param name="activeSubMenu" value="${reportType}" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <c:choose>
                    <c:when test="${reportType eq 'room'}">
                        <h1>Báo Cáo Doanh Thu Tiền Phòng</h1>
                        <p>Thống kê số lượt đặt, số đêm lưu trú và tổng doanh thu từng phòng trong khoảng thời gian</p>
                    </c:when>
                    <c:when test="${reportType eq 'product'}">
                        <h1>Báo Cáo Doanh Thu Sản Phẩm & Dịch Vụ</h1>
                        <p>Thống kê số lượng tiêu thụ và tổng doanh thu các sản phẩm, minibar và dịch vụ gia tăng đã bán</p>
                    </c:when>
                    <c:when test="${reportType eq 'overall'}">
                        <h1>Báo Cáo Tổng Doanh Thu & Dòng Tiền Thu Chi</h1>
                        <p>Xem chi tiết tổng doanh thu của khách sạn từ các mã phiếu theo loại thu chi và phương thức thanh toán</p>
                    </c:when>
                    <c:otherwise>
                        <h1>Báo Cáo Doanh Thu Hóa Đơn</h1>
                        <p>Cung cấp toàn bộ thông tin từ tất cả các hóa đơn phát sinh trong quá trình giao dịch ở khách sạn</p>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="portal-header-right">
            </div>
        </header>

        <!-- THANH CÔNG CỤ LỌC & THAO TÁC (FILTER TOOLBAR) -->
        <div class="portal-card" style="padding: 16px 20px; margin-bottom: 20px;">
            <form action="${pageContext.request.contextPath}/manager/revenue" method="GET" style="display: flex; gap: 14px; align-items: center; flex-wrap: wrap; margin: 0;">
                <input type="hidden" name="type" value="${reportType}" />
                
                <div style="display: flex; align-items: center; gap: 8px;">
                    <label style="font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); white-space: nowrap;">Từ Ngày:</label>
                    <input type="date" name="fromDate" value="${fromDate}" required class="portal-input" style="padding: 6px 10px;" />
                </div>

                <div style="display: flex; align-items: center; gap: 8px;">
                    <label style="font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); white-space: nowrap;">Đến Ngày:</label>
                    <input type="date" name="toDate" value="${toDate}" required class="portal-input" style="padding: 6px 10px;" />
                </div>

                <c:if test="${reportType ne 'product'}">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <label style="font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); white-space: nowrap;">Nhân Viên:</label>
                        <select name="employeeId" class="portal-select" style="padding: 6px 10px; min-width: 170px;">
                            <option value="">Tất cả nhân viên</option>
                            <c:forEach var="emp" items="${employeeList}">
                                <option value="${emp.employeeId}" ${selectedEmployeeId eq emp.employeeId ? 'selected' : ''}>
                                    ${emp.fullName} (${emp.employeeId})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>

                <div style="display: flex; gap: 8px; margin-left: auto;">
                    <button type="submit" class="portal-btn portal-btn-primary" style="padding: 7px 16px; font-size: 13px;">
                        Tải Lại
                    </button>
                    <button type="button" class="portal-btn portal-btn-success" style="padding: 7px 16px; font-size: 13px; background-color: #16a34a;" onclick="exportTableToExcel('reportDataTable', 'BaoCao_${reportType}_${fromDate}_${toDate}');">
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

            <div class="portal-card" style="padding: 0; overflow: hidden;">
                <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                    <table class="portal-table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Hóa Đơn</th>
                                <th>Khách Hàng</th>
                                <th>Phòng</th>
                                <th>Ngày Lập</th>
                                <th style="text-align: right;">Đặt Trước</th>
                                <th style="text-align: right;">Tiền Phòng</th>
                                <th style="text-align: right;">Dịch Vụ</th>
                                <th style="text-align: right;">Phụ Thu</th>
                                <th style="text-align: right;">Tổng Tiền</th>
                                <th style="text-align: right; color: #16a34a;">Thực Thu</th>
                                <th style="text-align: center;">Trạng Thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG ĐẬM NÉT ĐẦU BẢNG (CHUẨN PMS TCSOFT) -->
                            <tr class="summary-highlight-row">
                                <td colspan="4" style="color: var(--portal-primary); font-size: 14px;">
                                    TỔNG TIỀN (${not empty invoiceReport ? invoiceReport.size() : 0} hóa đơn)
                                </td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${sumDeposit}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${sumRoom}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${sumService}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td style="text-align: right;">
                                    <fmt:formatNumber value="${sumSurcharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td style="text-align: right; color: var(--portal-primary);">
                                    <fmt:formatNumber value="${sumFinal}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td style="text-align: right; color: #16a34a; font-size: 14.5px;">
                                    <fmt:formatNumber value="${sumPaid}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td style="text-align: center;">-</td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty invoiceReport}">
                                    <c:forEach var="inv" items="${invoiceReport}">
                                        <tr>
                                            <td style="font-weight: 700; color: var(--portal-primary);">
                                                ${inv.invoiceId}
                                            </td>
                                            <td style="font-weight: 600;">${inv.customerName}</td>
                                            <td style="color: var(--portal-text-secondary); font-size: 13px;">${inv.roomNames}</td>
                                            <td style="font-size: 13px; color: var(--portal-text-muted);">${inv.createDate}</td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${inv.deposit}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${inv.roomCharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${inv.serviceCharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${inv.surcharge}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: right; font-weight: 600;">
                                                <fmt:formatNumber value="${inv.finalTotalAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: right; font-weight: 700; color: #16a34a;">
                                                <fmt:formatNumber value="${inv.paidAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: center;">
                                                <c:choose>
                                                    <c:when test="${inv.invoiceStatus eq 'Paid'}">
                                                        <span class="badge-pill badge-available">Đã Quyết Toán</span>
                                                    </c:when>
                                                    <c:when test="${inv.invoiceStatus eq 'PartiallyPaid'}">
                                                        <span class="badge-pill badge-cleaning">Một Phần</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-pill badge-occupied">Chưa Thanh Toán</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="11" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                            Không tìm thấy hóa đơn nào trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
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

            <div class="portal-card" style="padding: 0; overflow: hidden;">
                <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                    <table class="portal-table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Phòng</th>
                                <th>Tên Phòng (Số Phòng)</th>
                                <th>Hạng Phòng</th>
                                <th style="text-align: right;">Đơn Giá Niêm Yết</th>
                                <th style="text-align: center;">Số Lượt Đặt</th>
                                <th style="text-align: center;">Số Đêm Đã Thuê</th>
                                <th style="text-align: right; color: #16a34a;">Tổng Doanh Thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG TIỀN PHÒNG -->
                            <tr class="summary-highlight-row">
                                <td colspan="4" style="color: var(--portal-primary); font-size: 14px;">
                                    TỔNG DOANH THU TIỀN PHÒNG (${not empty roomReport ? roomReport.size() : 0} phòng)
                                </td>
                                <td style="text-align: center; color: var(--portal-primary);">
                                    ${sumBookings} lượt
                                </td>
                                <td style="text-align: center; color: var(--portal-primary);">
                                    ${sumNights} đêm
                                </td>
                                <td style="text-align: right; color: #16a34a; font-size: 15px;">
                                    <fmt:formatNumber value="${sumRoomRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty roomReport}">
                                    <c:forEach var="r" items="${roomReport}">
                                        <tr>
                                            <td style="font-weight: 700; color: var(--portal-primary);">${r.roomId}</td>
                                            <td style="font-weight: 600; font-size: 14px;">${r.roomName}</td>
                                            <td style="color: var(--portal-text-secondary);">${r.roomTypeName}</td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${r.basePrice}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: center; font-weight: 600;">
                                                ${r.totalBookings}
                                            </td>
                                            <td style="text-align: center; font-weight: 700;">
                                                ${r.totalNights}
                                            </td>
                                            <td style="text-align: right; font-weight: 800; color: #16a34a; font-size: 14.5px;">
                                                <fmt:formatNumber value="${r.totalRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                            Chưa ghi nhận doanh thu phòng nào trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
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

            <div class="portal-card" style="padding: 0; overflow: hidden;">
                <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                    <table class="portal-table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Dịch Vụ / Sản Phẩm</th>
                                <th>Tên Sản Phẩm / Dịch Vụ Tiêu Dùng</th>
                                <th style="text-align: right;">Đơn Giá Niêm Yết</th>
                                <th style="text-align: center;">Số Lượng Đã Bán</th>
                                <th style="text-align: right; color: #16a34a;">Tổng Doanh Thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG SẢN PHẨM -->
                            <tr class="summary-highlight-row">
                                <td colspan="3" style="color: var(--portal-primary); font-size: 14px;">
                                    TỔNG DOANH THU TIÊU DÙNG (${not empty productReport ? productReport.size() : 0} mặt hàng)
                                </td>
                                <td style="text-align: center; color: var(--portal-primary);">
                                    ${sumQty} lượt
                                </td>
                                <td style="text-align: right; color: #16a34a; font-size: 15px;">
                                    <fmt:formatNumber value="${sumProductRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty productReport}">
                                    <c:forEach var="p" items="${productReport}">
                                        <tr>
                                            <td style="font-weight: 700; color: var(--portal-primary);">${p.serviceId}</td>
                                            <td style="font-weight: 600; font-size: 14px;">${p.serviceName}</td>
                                            <td style="text-align: right;">
                                                <fmt:formatNumber value="${p.basePrice}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="text-align: center; font-weight: 700;">
                                                ${p.quantitySold}
                                            </td>
                                            <td style="text-align: right; font-weight: 800; color: #16a34a; font-size: 14.5px;">
                                                <fmt:formatNumber value="${p.totalRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="5" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                            Chưa ghi nhận doanh thu sản phẩm nào trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <!-- PHÂN HỆ 4: TỔNG DOANH THU & PHIẾU THU DÒNG TIỀN -->
        <c:if test="${reportType eq 'overall'}">
            <c:set var="sumCash" value="0" />
            <c:set var="sumBank" value="0" />
            <c:set var="sumCard" value="0" />
            <c:set var="sumOverall" value="0" />
            <c:forEach var="item" items="${overallReport}">
                <c:if test="${item.paymentMethod eq 'Cash'}"><c:set var="sumCash" value="${sumCash + item.totalAmount}" /></c:if>
                <c:if test="${item.paymentMethod eq 'BankTransfer' or item.paymentMethod eq 'Momo' or item.paymentMethod eq 'VNPay'}"><c:set var="sumBank" value="${sumBank + item.totalAmount}" /></c:if>
                <c:if test="${item.paymentMethod eq 'CreditCard'}"><c:set var="sumCard" value="${sumCard + item.totalAmount}" /></c:if>
                <c:set var="sumOverall" value="${sumOverall + item.totalAmount}" />
            </c:forEach>

            <!-- CÁC THẺ KPI DÒNG TIỀN THEO PHƯƠNG THỨC THANH TOÁN -->
            <div class="portal-kpi-grid" style="margin-bottom: 20px;">
                <div class="portal-kpi-card" style="border-top: 4px solid #1e3a8a;">
                    <div class="portal-kpi-label">Tổng Dòng Tiền Thu</div>
                    <div class="portal-kpi-value" style="color: #1e3a8a;">
                        <fmt:formatNumber value="${sumOverall}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                    </div>
                    <div class="portal-kpi-desc">Toàn bộ phiếu thu đã xác nhận</div>
                </div>
                <div class="portal-kpi-card" style="border-top: 4px solid #16a34a;">
                    <div class="portal-kpi-label">Thu Tiền Mặt (Cash)</div>
                    <div class="portal-kpi-value" style="color: #16a34a;">
                        <fmt:formatNumber value="${sumCash}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                    </div>
                    <div class="portal-kpi-desc">Thực thu tại quầy thu ngân</div>
                </div>
                <div class="portal-kpi-card" style="border-top: 4px solid #3b82f6;">
                    <div class="portal-kpi-label">Chuyển Khoản / Ví Điện Tử</div>
                    <div class="portal-kpi-value" style="color: #2563eb;">
                        <fmt:formatNumber value="${sumBank}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                    </div>
                    <div class="portal-kpi-desc">Chuyển khoản qua ngân hàng, Momo, VNPay</div>
                </div>
                <div class="portal-kpi-card" style="border-top: 4px solid #eab308;">
                    <div class="portal-kpi-label">Thẻ Tín Dụng (POS)</div>
                    <div class="portal-kpi-value" style="color: #ca8a04;">
                        <fmt:formatNumber value="${sumCard}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                    </div>
                    <div class="portal-kpi-desc">Quẹt thẻ Visa, MasterCard</div>
                </div>
            </div>

            <div class="portal-card" style="padding: 0; overflow: hidden;">
                <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                    <table class="portal-table" id="reportDataTable">
                        <thead>
                            <tr>
                                <th>Mã Phiếu Thu</th>
                                <th>Mã Hóa Đơn</th>
                                <th>Mã Booking</th>
                                <th>Khách Nộp Tiền</th>
                                <th>Thời Điểm Thu</th>
                                <th>Phương Thức</th>
                                <th>Nhân Viên Thu</th>
                                <th style="text-align: right; color: #16a34a;">Số Tiền Thực Thu</th>
                                <th>Ghi Chú</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- DÒNG TỔNG CỘNG PHIẾU THU -->
                            <tr class="summary-highlight-row">
                                <td colspan="7" style="color: var(--portal-primary); font-size: 14px;">
                                    TỔNG THỰC THU (${not empty overallReport ? overallReport.size() : 0} phiếu thu)
                                </td>
                                <td style="text-align: right; color: #16a34a; font-size: 15px;">
                                    <fmt:formatNumber value="${sumOverall}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td>-</td>
                            </tr>

                            <c:choose>
                                <c:when test="${not empty overallReport}">
                                    <c:forEach var="pay" items="${overallReport}">
                                        <tr>
                                            <td style="font-weight: 700; color: var(--portal-primary);">${pay.paymentId}</td>
                                            <td style="font-weight: 600;">${pay.invoiceId}</td>
                                            <td style="color: var(--portal-text-secondary);">${pay.bookingId}</td>
                                            <td style="font-weight: 600;">${pay.customerName}</td>
                                            <td style="font-size: 13px; color: var(--portal-text-muted);">${pay.paymentDate}</td>
                                            <td>
                                                <span class="badge-pill badge-available">${pay.paymentMethod}</span>
                                            </td>
                                            <td style="font-size: 13px; color: var(--portal-text-secondary);">${pay.staffName}</td>
                                            <td style="text-align: right; font-weight: 800; color: #16a34a; font-size: 14.5px;">
                                                <fmt:formatNumber value="${pay.totalAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                            </td>
                                            <td style="font-size: 13px; color: var(--portal-text-muted); max-width: 200px;">${pay.note}</td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                            Không có phiếu thu nào được ghi nhận trong khoảng thời gian đã chọn.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </main>
</div>

<!-- JAVASCRIPT XUẤT EXCEL THUẦN (HỖ TRỢ UNICODE TIẾNG VIỆT HOÀN HẢO CHO EXCEL) -->
<script>
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