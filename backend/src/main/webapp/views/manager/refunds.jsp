<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Xét Duyệt Hoàn Tiền Cọc Hủy Phòng" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="refunds" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Xét Duyệt Hoàn Tiền Cọc Hủy Phòng</h1>
                <p>Quản lý lịch sử hủy phòng và thẩm định tiền hoàn trả tính toán tự động qua hàm nghiệp vụ CSDL</p>
            </div>
            <div class="portal-header-right">
            </div>
        </header>

        <!-- Thông báo kết quả flash message -->
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="portal-alert portal-alert-success">
                ${sessionScope.flashSuccess}
            </div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="portal-alert portal-alert-danger">
                ${sessionScope.flashError}
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>

        <!-- Thống kê nhanh -->
        <c:set var="pendingCount" value="0" />
        <c:set var="completedCount" value="0" />
        <c:set var="rejectedCount" value="0" />
        <c:forEach var="item" items="${cancellations}">
            <c:if test="${item.refundStatus == 'Pending'}"><c:set var="pendingCount" value="${pendingCount + 1}" /></c:if>
            <c:if test="${item.refundStatus == 'Completed'}"><c:set var="completedCount" value="${completedCount + 1}" /></c:if>
            <c:if test="${item.refundStatus == 'Rejected'}"><c:set var="rejectedCount" value="${rejectedCount + 1}" /></c:if>
        </c:forEach>

        <div class="portal-kpi-grid">
            <div class="portal-kpi-card">
                <div class="portal-kpi-label">Tổng Yêu Cầu Hủy</div>
                <div class="portal-kpi-value">${not empty cancellations ? cancellations.size() : 0}</div>
                <div class="portal-kpi-desc">Toàn bộ hồ sơ hủy phòng</div>
            </div>
            <div class="portal-kpi-card" style="border-top: 4px solid #f59e0b;">
                <div class="portal-kpi-label" style="color: #b45309;">Chờ Xét Duyệt (Pending)</div>
                <div class="portal-kpi-value" style="color: #d97706;">${pendingCount}</div>
                <div class="portal-kpi-desc">Cần ban giám đốc thẩm định</div>
            </div>
            <div class="portal-kpi-card" style="border-top: 4px solid #10b981;">
                <div class="portal-kpi-label" style="color: #047857;">Đã Hoàn Trả Cọc</div>
                <div class="portal-kpi-value" style="color: #16a34a;">${completedCount}</div>
                <div class="portal-kpi-desc">Đã xử lý quyết toán hoàn cọc</div>
            </div>
            <div class="portal-kpi-card" style="border-top: 4px solid #ef4444;">
                <div class="portal-kpi-label" style="color: #b91c1c;">Từ Chối Hoàn Tiền</div>
                <div class="portal-kpi-value" style="color: #dc2626;">${rejectedCount}</div>
                <div class="portal-kpi-desc">Hủy sát giờ hoặc vi phạm quy chế</div>
            </div>
        </div>

        <!-- Bảng danh sách hủy phòng -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); background: #f8fafc; display: flex; justify-content: space-between; align-items: center;">
                <h3 class="portal-card-title">
                    Danh Sách Hồ Sơ Hủy Phòng (${not empty cancellations ? cancellations.size() : 0} bản ghi)
                </h3>
            </div>

            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th>Mã Hủy</th>
                            <th>Booking & Phòng</th>
                            <th>Người Hủy & Ngày</th>
                            <th style="text-align: right;">Tiền Cọc</th>
                            <th style="text-align: right;">Phí Phạt</th>
                            <th style="text-align: right; color: #16a34a;">Số Tiền Hoàn</th>
                            <th>Lý Do</th>
                            <th style="text-align: center;">Trạng Thái</th>
                            <th style="text-align: center;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty cancellations}">
                                <c:forEach var="item" items="${cancellations}">
                                    <tr>
                                        <td style="font-weight: 700; color: var(--portal-primary);">
                                            ${item.cancellationId}
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; color: var(--portal-text-primary);">${item.bookingId}</div>
                                            <div style="color: var(--portal-text-muted); font-size: 13px; margin-top: 2px;">Phòng: <strong>${item.roomName}</strong></div>
                                        </td>
                                        <td style="font-size: 13px;">
                                            <div style="font-weight: 600; color: var(--portal-text-secondary);">Người hủy: ${item.cancelledBy}</div>
                                            <div style="color: var(--portal-text-muted); margin-top: 2px;">Thời điểm: ${item.cancellationDate}</div>
                                        </td>
                                        <td style="text-align: right; font-weight: 600; color: var(--portal-text-secondary);">
                                            <fmt:formatNumber value="${item.depositAtCancellation}" type="currency" currencySymbol="VND" maxFractionDigits="0" />
                                        </td>
                                        <td style="text-align: right; color: #dc2626; font-weight: 600;">
                                            <fmt:formatNumber value="${item.cancellationFee}" type="currency" currencySymbol="VND" maxFractionDigits="0" />
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: #16a34a; font-size: 14.5px;">
                                            <fmt:formatNumber value="${item.refundAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0" />
                                        </td>
                                        <td style="font-size: 13px; color: var(--portal-text-secondary); max-width: 200px;">
                                            ${item.reason}
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${item.refundStatus == 'Pending'}">
                                                    <span class="badge-pill badge-cleaning">Chờ Duyệt</span>
                                                </c:when>
                                                <c:when test="${item.refundStatus == 'Completed'}">
                                                    <span class="badge-pill badge-available">Đã Hoàn Trả</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-occupied">Từ Chối</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center; white-space: nowrap;">
                                            <c:choose>
                                                <c:when test="${item.refundStatus == 'Pending'}">
                                                    <div style="display: flex; gap: 6px; justify-content: center;">
                                                        <form action="${pageContext.request.contextPath}/manager/refunds" method="POST" style="margin: 0;"
                                                              onsubmit="return confirmApprove(this);">
                                                            <input type="hidden" name="action" value="approve" />
                                                            <input type="hidden" name="cancellationId" value="${item.cancellationId}" />
                                                            <input type="hidden" name="refundAmount" value="${item.refundAmount}" />
                                                            <button type="submit" class="portal-btn portal-btn-success" style="padding: 5px 10px; font-size: 12px;">
                                                                Duyệt Hoàn
                                                            </button>
                                                        </form>
                                                        <form action="${pageContext.request.contextPath}/manager/refunds" method="POST" style="margin: 0;"
                                                              onsubmit="return confirmReject(this);">
                                                            <input type="hidden" name="action" value="reject" />
                                                            <input type="hidden" name="cancellationId" value="${item.cancellationId}" />
                                                            <button type="submit" class="portal-btn portal-btn-danger" style="padding: 5px 10px; font-size: 12px;">
                                                                Từ Chối
                                                            </button>
                                                        </form>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--portal-text-muted); font-size: 13px;">Đã giải quyết</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">
                                        Chưa có yêu cầu hủy phòng nào trong hệ thống.
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

<script>
function confirmApprove(formEl) {
    var id = formEl.elements["cancellationId"].value;
    var amount = formEl.elements["refundAmount"].value;
    return confirm("Xác nhận duyệt hoàn tiền: Đồng ý hoàn trả cho yêu cầu [" + id + "] số tiền [" + amount + " VND]?");
}
function confirmReject(formEl) {
    var id = formEl.elements["cancellationId"].value;
    return confirm("Xác nhận từ chối hoàn tiền: Bạn có chắc chắn muốn từ chối yêu cầu hoàn tiền [" + id + "]?");
}
</script>

<jsp:include page="/views/common/footer.jsp" />