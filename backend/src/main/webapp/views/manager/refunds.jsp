<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Xét Duyệt Hoàn Tiền Cọc Hủy Phòng" />
    <jsp:param name="zone" value="portal" />
</jsp:include>

<div class="portal-layout">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="refunds" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="page-header">
            <div class="page-header-left">
                <h1 class="page-title">Xét Duyệt Hoàn Tiền Cọc Hủy Phòng</h1>
                <p class="page-subtitle">Quản lý lịch sử hủy phòng và thẩm định tiền hoàn trả tính toán tự động qua hàm nghiệp vụ CSDL</p>
            </div>
            <div class="page-header-right">
                <span class="pill pill-primary">Ca trực: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Thông báo kết quả flash message -->
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="alert alert-success">
                ${sessionScope.flashSuccess}
            </div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger">
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

        <div class="kpi-grid">
            <div class="kpi-card border-top-primary">
                <div class="kpi-label">Tổng Yêu Cầu Hủy</div>
                <div class="kpi-value">${not empty cancellations ? cancellations.size() : 0}</div>
                <div class="kpi-desc">Toàn bộ hồ sơ hủy phòng</div>
            </div>
            <div class="kpi-card border-top-warning">
                <div class="kpi-label text-warning">Chờ Xét Duyệt (Pending)</div>
                <div class="kpi-value text-warning">${pendingCount}</div>
                <div class="kpi-desc">Cần ban giám đốc thẩm định</div>
            </div>
            <div class="kpi-card border-top-success">
                <div class="kpi-label text-success">Đã Hoàn Trả Cọc</div>
                <div class="kpi-value text-success">${completedCount}</div>
                <div class="kpi-desc">Đã xử lý quyết toán hoàn cọc</div>
            </div>
            <div class="kpi-card border-top-danger">
                <div class="kpi-label text-danger">Từ Chối Hoàn Tiền</div>
                <div class="kpi-value text-danger">${rejectedCount}</div>
                <div class="kpi-desc">Hủy sát giờ hoặc vi phạm quy chế</div>
            </div>
        </div>

        <!-- Bảng danh sách hủy phòng -->
        <div class="card p-0">
            <div class="card-toolbar">
                <h3 class="card-title">
                    Danh Sách Hồ Sơ Hủy Phòng (${not empty cancellations ? cancellations.size() : 0} bản ghi)
                </h3>
            </div>

            <div class="table-wrapper">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Mã Hủy</th>
                            <th>Booking &amp; Phòng</th>
                            <th>Người Hủy &amp; Ngày</th>
                            <th class="text-right">Tiền Cọc</th>
                            <th class="text-right">Phí Phạt</th>
                            <th class="text-right text-success">Số Tiền Hoàn</th>
                            <th>Lý Do</th>
                            <th class="text-center">Trạng Thái</th>
                            <th class="text-center">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty cancellations}">
                                <c:forEach var="item" items="${cancellations}">
                                    <tr>
                                        <td>
                                            <strong class="text-primary">${item.cancellationId}</strong>
                                        </td>
                                        <td>
                                            <div class="font-bold text-main">${item.bookingId}</div>
                                            <div class="text-muted text-xs mt-1">Phòng: <strong>${item.roomName}</strong></div>
                                        </td>
                                        <td class="text-xs">
                                            <div class="font-semibold text-secondary">Người hủy: ${item.cancelledBy}</div>
                                            <div class="text-muted mt-1">Thời điểm: ${item.cancellationDate}</div>
                                        </td>
                                        <td class="text-right font-semibold text-secondary mono">
                                            <fmt:formatNumber value="${item.depositAtCancellation}" type="currency" currencySymbol="VND" maxFractionDigits="0" />
                                        </td>
                                        <td class="text-right text-danger font-semibold mono">
                                            <fmt:formatNumber value="${item.cancellationFee}" type="currency" currencySymbol="VND" maxFractionDigits="0" />
                                        </td>
                                        <td class="text-right font-bold text-success mono text-sm">
                                            <fmt:formatNumber value="${item.refundAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0" />
                                        </td>
                                        <td class="text-secondary text-xs" style="max-width: 200px;">
                                            ${item.reason}
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.refundStatus == 'Pending'}">
                                                    <span class="badge badge-warning badge-pill badge-cleaning">Chờ Duyệt</span>
                                                </c:when>
                                                <c:when test="${item.refundStatus == 'Completed'}">
                                                    <span class="badge badge-success badge-pill badge-available">Đã Hoàn Trả</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger badge-pill badge-occupied">Từ Chối</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center nowrap">
                                            <c:choose>
                                                <c:when test="${item.refundStatus == 'Pending'}">
                                                    <div class="flex items-center justify-center gap-1">
                                                        <button type="button" class="btn btn-success btn-sm font-semibold"
                                                                onclick="openApproveModal('${item.cancellationId}', '${item.refundAmount}')">
                                                            Duyệt Hoàn
                                                        </button>
                                                        <button type="button" class="btn btn-danger btn-sm font-semibold"
                                                                onclick="openRejectModal('${item.cancellationId}')">
                                                            Từ Chối
                                                        </button>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted text-xs">Đã giải quyết</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" class="text-center py-6 text-muted">
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

<!-- FORM ẨN DÙNG ĐỂ SUBMIT DỮ LIỆU AN TOÀN -->
<form id="refundActionForm" action="${pageContext.request.contextPath}/manager/refunds" method="POST" style="display: none;">
    <input type="hidden" name="action" id="refundActionType" value="" />
    <input type="hidden" name="cancellationId" id="refundCancellationId" value="" />
</form>

<!-- MODAL XÁC NHẬN DUYỆT HOÀN TIỀN -->
<div id="approveRefundModal" class="modal-backdrop" style="display: none; z-index: 1060;">
    <div class="modal-card modal-md">
        <div class="modal-head" style="background: #16a34a; color: #ffffff;">
            <h3 style="color: #ffffff; margin: 0; font-size: 16px; font-weight: 700;">Xác Nhận Duyệt Hoàn Tiền Cọc</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('approveRefundModal')">Đóng</button>
        </div>
        <div class="modal-body">
            <p class="text-secondary text-sm mb-3">Bạn có chắc chắn muốn phê duyệt hoàn trả tiền cọc cho yêu cầu sau:</p>
            <div class="card p-3 mb-3" style="background: var(--color-surface-alt);">
                <div class="flex justify-between mb-2 text-sm">
                    <span class="text-muted">Mã yêu cầu hủy:</span>
                    <strong id="approveModalId" class="text-primary mono">--</strong>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-muted">Số tiền hoàn trả:</span>
                    <strong id="approveModalAmount" class="text-success mono font-bold">--</strong>
                </div>
            </div>
            <div class="text-xs text-muted">Thao tác này sẽ ghi nhận trạng thái Đã Hoàn Trả và cập nhật vào báo cáo tài chính.</div>
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" onclick="closeModal('approveRefundModal')">Bỏ Qua</button>
            <button type="button" class="btn btn-success font-bold" onclick="submitRefundAction('approve')">Xác Nhận Duyệt Hoàn</button>
        </div>
    </div>
</div>

<!-- MODAL XÁC NHẬN TỪ CHỐI HOÀN TIỀN -->
<div id="rejectRefundModal" class="modal-backdrop" style="display: none; z-index: 1060;">
    <div class="modal-card modal-md">
        <div class="modal-head" style="background: #dc2626; color: #ffffff;">
            <h3 style="color: #ffffff; margin: 0; font-size: 16px; font-weight: 700;">Xác Nhận Từ Chối Hoàn Tiền</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('rejectRefundModal')">Đóng</button>
        </div>
        <div class="modal-body">
            <div class="alert alert-warning mb-3 text-sm">
                Xác nhận từ chối hoàn trả tiền cọc cho yêu cầu: <strong id="rejectModalId" class="mono text-danger">--</strong>
            </div>
            <p class="text-muted text-xs">Yêu cầu hủy phòng này sẽ được đánh dấu trạng thái "Từ Chối" và không hoàn trả tiền cọc.</p>
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" onclick="closeModal('rejectRefundModal')">Bỏ Qua</button>
            <button type="button" class="btn btn-danger font-bold" onclick="submitRefundAction('reject')">Xác Nhận Từ Chối</button>
        </div>
    </div>
</div>

<script>
let currentTargetId = '';

function openApproveModal(id, amount) {
    currentTargetId = id;
    document.getElementById('approveModalId').innerText = id;
    var num = parseFloat(amount) || 0;
    document.getElementById('approveModalAmount').innerText = num.toLocaleString('vi-VN') + ' đ';
    document.getElementById('approveRefundModal').style.display = 'flex';
}

function openRejectModal(id) {
    currentTargetId = id;
    document.getElementById('rejectModalId').innerText = id;
    document.getElementById('rejectRefundModal').style.display = 'flex';
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

function submitRefundAction(action) {
    document.getElementById('refundActionType').value = action;
    document.getElementById('refundCancellationId').value = currentTargetId;
    document.getElementById('refundActionForm').submit();
}
</script>

<jsp:include page="/views/common/footer.jsp" />