<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Báo Cáo Doanh Thu & Chốt Ca Tài Chính" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="revenue" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Báo Cáo Doanh Thu & Chốt Ca Tài Chính</h1>
                <p>Thống kê dòng tiền thực thu, Night Audit ca trực và lịch sử doanh thu theo tháng</p>
            </div>
            <div class="portal-header-right">
                <a href="${pageContext.request.contextPath}/manager/dashboard" class="portal-btn portal-btn-secondary">
                    Quay Lại Dashboard
                </a>
            </div>
        </header>

        <!-- PHẦN 1: BÁO CÁO CHỐT CA THEO NGÀY (NIGHT AUDIT) -->
        <div class="portal-card">
            <div class="portal-card-header">
                <div>
                    <h3 class="portal-card-title">
                        Tổng Kết Kinh Doanh Ngày: <span style="color: var(--portal-primary);">${reportDate}</span>
                    </h3>
                    <div class="portal-card-subtitle">Chốt ca doanh thu và dòng tiền thực thu trong ngày</div>
                </div>
                <form action="${pageContext.request.contextPath}/manager/revenue" method="GET" style="margin: 0; display: flex; gap: 8px; align-items: center;">
                    <label style="font-size: 13px; font-weight: 600; color: var(--portal-text-secondary);">Chọn Ngày:</label>
                    <input type="date" name="date" value="${reportDate}" class="portal-input" />
                    <button type="submit" class="portal-btn portal-btn-primary">
                        Xem Báo Cáo
                    </button>
                </form>
            </div>

            <!-- Các thẻ KPI thống kê trong ngày -->
            <div class="portal-kpi-grid" style="margin-bottom: 20px;">
                <div class="portal-kpi-card" style="border-left: 4px solid #3b82f6;">
                    <div class="portal-kpi-label">Tổng Thực Thu Trong Ngày</div>
                    <div class="portal-kpi-value" style="color: #1e3a8a; font-size: 24px;">
                        <fmt:formatNumber value="${dailyReport.tongTienThucThu}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                    </div>
                    <div class="portal-kpi-desc">Dòng tiền thanh toán đã xác nhận</div>
                </div>

                <div class="portal-kpi-card" style="border-left: 4px solid #16a34a;">
                    <div class="portal-kpi-label">Đơn Đặt Phòng Mới</div>
                    <div class="portal-kpi-value" style="color: #14532d; font-size: 24px;">
                        ${dailyReport.soDonDatMoi} <span style="font-size: 14px; font-weight: 600; color: #64748b;">đơn</span>
                    </div>
                    <div class="portal-kpi-desc">Tạo mới trên web & tại quầy</div>
                </div>

                <div class="portal-kpi-card" style="border-left: 4px solid #eab308;">
                    <div class="portal-kpi-label">Phòng Check-In</div>
                    <div class="portal-kpi-value" style="color: #854d0e; font-size: 24px;">
                        ${dailyReport.soPhongCheckIn} <span style="font-size: 14px; font-weight: 600; color: #64748b;">lượt</span>
                    </div>
                    <div class="portal-kpi-desc">Khách làm thủ tục nhận phòng</div>
                </div>

                <div class="portal-kpi-card" style="border-left: 4px solid #a855f7;">
                    <div class="portal-kpi-label">Phòng Check-Out</div>
                    <div class="portal-kpi-value" style="color: #6b21a8; font-size: 24px;">
                        ${dailyReport.soPhongCheckOut} <span style="font-size: 14px; font-weight: 600; color: #64748b;">lượt</span>
                    </div>
                    <div class="portal-kpi-desc">Khách đã trả phòng & quyết toán</div>
                </div>
            </div>

            <!-- Chi tiết phương thức thanh toán -->
            <div style="background: #f8fafc; border-radius: 10px; padding: 18px; border: 1px solid var(--portal-border);">
                <div style="font-size: 13.5px; font-weight: 700; color: var(--portal-text-primary); margin-bottom: 10px;">
                    Cơ Cấu Dòng Tiền Theo Phương Thức Thanh Toán:
                </div>
                <div style="display: flex; gap: 30px; flex-wrap: wrap;">
                    <div>
                        <span style="color: var(--portal-text-muted); font-size: 13px;">Tiền Mặt:</span>
                        <strong style="color: var(--portal-text-primary); margin-left: 6px;">
                            <fmt:formatNumber value="${dailyReport.thuTienMat}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                        </strong>
                    </div>
                    <div>
                        <span style="color: var(--portal-text-muted); font-size: 13px;">Chuyển Khoản / Ví Điện Tử:</span>
                        <strong style="color: var(--portal-text-primary); margin-left: 6px;">
                            <fmt:formatNumber value="${dailyReport.thuChuyenKhoan}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                        </strong>
                    </div>
                    <div>
                        <span style="color: var(--portal-text-muted); font-size: 13px;">Thẻ Tín Dụng:</span>
                        <strong style="color: var(--portal-text-primary); margin-left: 6px;">
                            <fmt:formatNumber value="${dailyReport.thuTheNganHang}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                        </strong>
                    </div>
                </div>
            </div>
        </div>

        <!-- PHẦN 2: TRA CỨU DOANH THU THEO KHOẢNG THỜI GIAN -->
        <div class="portal-card">
            <h3 class="portal-card-title" style="margin-bottom: 16px;">
                Tra Cứu Doanh Thu Khoảng Thời Gian Tùy Chọn
            </h3>
            <form action="${pageContext.request.contextPath}/manager/revenue" method="GET" style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
                <input type="hidden" name="date" value="${reportDate}" />
                <div>
                    <label style="font-size: 13px; font-weight: 600; color: var(--portal-text-secondary); display: block; margin-bottom: 4px;">Từ Ngày:</label>
                    <input type="date" name="fromDate" value="${filterFromDate}" required class="portal-input" />
                </div>
                <div>
                    <label style="font-size: 13px; font-weight: 600; color: var(--portal-text-secondary); display: block; margin-bottom: 4px;">Đến Ngày:</label>
                    <input type="date" name="toDate" value="${filterToDate}" required class="portal-input" />
                </div>
                <div style="align-self: flex-end;">
                    <button type="submit" class="portal-btn portal-btn-primary">
                        Tính Doanh Thu
                    </button>
                </div>
            </form>

            <c:if test="${not empty rangeRevenue}">
                <div style="margin-top: 18px; padding: 16px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px;">
                    <span style="font-size: 14px; color: #166534;">
                        Tổng doanh thu thực tế từ ngày <strong>${filterFromDate}</strong> đến <strong>${filterToDate}</strong>:
                    </span>
                    <span style="font-size: 22px; font-weight: 800; color: #15803d; margin-left: 10px;">
                        <fmt:formatNumber value="${rangeRevenue}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                    </span>
                </div>
            </c:if>
        </div>

        <!-- PHẦN 3: LỊCH SỬ DOANH THU THEO THÁNG -->
        <div class="portal-card">
            <div class="portal-card-header">
                <div>
                    <h3 class="portal-card-title">Tổng Kết Doanh Thu Các Tháng Gần Đây</h3>
                    <div class="portal-card-subtitle">Lịch sử doanh thu các tháng gần nhất đã ghi nhận giao dịch</div>
                </div>
            </div>

            <div class="portal-table-wrapper">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th>Năm</th>
                            <th>Tháng</th>
                            <th style="text-align: center;">Số Lượt Giao Dịch</th>
                            <th style="text-align: center;">Số Hóa Đơn Đã Quyết Toán</th>
                            <th style="text-align: right;">Tổng Doanh Thu Thực Thu</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty monthlyList}">
                                <c:forEach var="m" items="${monthlyList}">
                                    <tr>
                                        <td style="font-weight: 700;">${m.nam}</td>
                                        <td style="color: var(--portal-primary); font-weight: 600;">Tháng ${m.thang}</td>
                                        <td style="text-align: center;">${m.soLuotGiaoDich} giao dịch</td>
                                        <td style="text-align: center;">${m.soHoaDonDaThanhToan} hóa đơn</td>
                                        <td style="text-align: right; font-weight: 800; color: #16a34a; font-size: 15px;">
                                            <fmt:formatNumber value="${m.tongDoanhThuThucThu}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="5" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                        Chưa có dữ liệu doanh thu tháng nào được ghi nhận.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />
