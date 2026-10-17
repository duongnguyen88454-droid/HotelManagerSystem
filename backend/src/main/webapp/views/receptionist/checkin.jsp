<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Quầy Tiếp Đón Check-in" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="receptionist/checkin.css" />
</jsp:include>

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="checkin" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <!-- Khối thẻ tìm kiếm và bảng danh sách tiếp nhận -->
        <div class="card card-flush">
            <div class="card-toolbar">
                <form action="${pageContext.request.contextPath}/receptionist/checkin" method="GET" class="flex items-center gap-3 flex-wrap flex-1">
                    <input type="text" name="keyword" value="${keyword}" class="form-control" style="max-width: 380px;" placeholder="Tìm kiếm theo Mã BK, Tên khách, SĐT hoặc CCCD...">
                    <button type="submit" class="btn btn-primary">Tra Cứu</button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/receptionist/checkin" class="btn btn-secondary">Đặt Lại</a>
                    </c:if>
                    <span class="text-sm text-muted" style="margin-left: auto;">Nhấp vào dòng đơn bất kỳ để xem chi tiết và bàn giao phòng</span>
                </form>
            </div>

            <div class="table-wrapper">
                <table class="table arrival-table">
                    <thead>
                        <tr>
                            <th style="width: 110px;">Mã BK</th>
                            <th>Khách Đại Diện</th>
                            <th>Số Điện Thoại</th>
                            <th>Số CCCD</th>
                            <th>Ngày Nhận</th>
                            <th>Ngày Trả</th>
                            <th class="text-center">Số Lượng Phòng</th>
                            <th class="text-center">Trạng Thái Tiếp Nhận</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${arrivalList}" var="item">
                            <tr class="clickable-row" onclick="openCheckInDetailModal('${item.maBooking}')" title="Nhấp để xem chi tiết đơn ${item.maBooking}" style="cursor: pointer;">
                                <td><strong class="mono text-secondary">${item.maBooking}</strong></td>
                                <td><strong class="text-primary">${item.tenKhachHang}</strong></td>
                                <td class="mono">${item.soDienThoai}</td>
                                <td class="mono">${item.soCccd}</td>
                                <td class="mono">${item.ngayNhanDuKien}</td>
                                <td class="mono">${item.ngayTraDuKien}</td>
                                <td class="text-center fw-bold">${item.soPhongDaNhan} / ${item.tongSoPhong} phòng</td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${item.soPhongDaNhan eq 0}">
                                            <span class="badge badge-info">${item.trangThaiTiepNhan}</span>
                                        </c:when>
                                        <c:when test="${item.soPhongDaNhan lt item.tongSoPhong}">
                                            <span class="badge badge-warning">${item.trangThaiTiepNhan}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-success">${item.trangThaiTiepNhan}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty arrivalList}">
                            <tr>
                                <td colspan="8">
                                    <div class="empty-state">
                                        <p>Không có đơn đặt phòng nào phù hợp trong danh sách chờ tiếp nhận.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- ========================================================================= -->
<!-- MODAL CHI TIẾT ĐƠN ĐẶT PHÒNG & CHỌN PHÒNG BÀN GIAO                        -->
<!-- ========================================================================= -->
<div id="checkInDetailModal" class="modal-backdrop">
    <div class="modal-card modal-lg">
        <div class="modal-head">
            <h3 id="mdlTitle">Chi Tiết Đơn Đặt Phòng</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('checkInDetailModal')">Đóng</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="mdlBookingId" value="">

            <div class="card mb-4" style="background: var(--color-surface-alt);">
                <div class="card-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Khách đại diện</span>
                            <span class="detail-value" id="mdlGuestName">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Số điện thoại</span>
                            <span class="detail-value mono" id="mdlPhone">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Số CCCD</span>
                            <span class="detail-value mono" id="mdlCccd">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Email</span>
                            <span class="detail-value" id="mdlEmail">--</span>
                        </div>
                        <div class="detail-item" style="grid-column: span 2;">
                            <span class="detail-label">Thời gian lưu trú</span>
                            <span class="detail-value">
                                <strong id="mdlStayDates">--</strong> (<span id="mdlNights">0</span> đêm)
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="fw-bold mb-2">DANH SÁCH PHÒNG BÀN GIAO &amp; DỊCH VỤ ĐI KÈM:</div>
            <div class="table-wrapper">
                <table class="table room-select-table">
                    <thead>
                        <tr>
                            <th style="width: 45px; text-align: center;">
                                <input type="checkbox" id="chkSelectAll" onchange="toggleSelectAllRooms(this)" title="Chọn tất cả phòng">
                            </th>
                            <th style="width: 80px;">Phòng</th>
                            <th>Loại Phòng</th>
                            <th>Dịch Vụ Đặt Trước</th>
                            <th class="text-center" style="width: 130px;">Trạng Thái Buồng</th>
                            <th class="text-center" style="width: 140px;">Tình Trạng Nhận</th>
                        </tr>
                    </thead>
                    <tbody id="mdlRoomListBody">
                        <tr>
                            <td colspan="6" class="text-center text-muted">Đang tải danh sách phòng...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div id="cleaningNotice" class="alert alert-warning mt-4 is-hidden">
                Lưu ý: Có phòng đang được dọn dẹp hoặc chưa sẵn sàng, vui lòng kiểm tra với bộ phận buồng phòng trước khi bàn giao chìa khóa!
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" id="btnCancelBooking" class="btn btn-danger" style="margin-right: auto;" onclick="submitCancelSelection()">
                Hủy Phòng Đã Chọn
            </button>
            <a id="btnGoToCashier" href="#" class="btn btn-primary is-hidden">
                Quầy Check-out &amp; Thanh Toán
            </a>
            <button type="button" id="btnConfirmCheckIn" class="btn btn-success" onclick="submitCheckInSelection()">Xác Nhận Bàn Giao</button>
            <button type="button" class="btn btn-secondary" onclick="closeModal('checkInDetailModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL XÁC NHẬN HỦY PHÒNG ĐÃ CHỌN (THAY THẾ CONFIRM & PROMPT NATIVE)       -->
<!-- ========================================================================= -->
<div id="cancelConfirmModal" class="modal-backdrop" style="z-index: 1060; display: none;">
    <div class="modal-card modal-md">
        <div class="modal-head" style="background: #dc2626; color: #ffffff;">
            <h3 style="color: #ffffff; margin: 0; font-size: 16px; font-weight: 700;">Xác Nhận Hủy Phòng Đã Chọn</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('cancelConfirmModal')">Đóng</button>
        </div>
        <div class="modal-body">
            <div class="alert alert-warning mb-3" style="font-size: 13px;">
                <strong id="cancelModalNotice">Bạn có chắc chắn muốn thực hiện hủy?</strong>
            </div>
            <div class="form-group mb-3">
                <label class="form-label font-bold text-xs text-secondary">Mã đơn đặt phòng:</label>
                <input type="text" id="cancelBookingIdInput" class="form-control font-bold" readonly style="background: var(--color-surface-alt);">
            </div>
            <div class="form-group mb-3">
                <label class="form-label font-bold text-xs text-secondary">Phòng áp dụng hủy:</label>
                <input type="text" id="cancelRoomsDisplay" class="form-control" readonly style="background: var(--color-surface-alt);">
            </div>
            <div class="form-group mb-0">
                <label class="form-label font-bold text-xs text-secondary">Lý do hủy phòng <span class="text-danger">*</span>:</label>
                <textarea id="cancelReasonInput" class="form-control" rows="3" placeholder="Nhập lý do khách hủy phòng...">Khách liên hệ yêu cầu hủy phòng</textarea>
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" onclick="closeModal('cancelConfirmModal')">Bỏ Qua</button>
            <button type="button" class="btn btn-danger font-bold" id="btnExecuteCancel" onclick="executeCancelConfirmed()">
                Xác Nhận Hủy Ngay
            </button>
        </div>
    </div>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.AUTO_SELECT_BOOKING = '${autoSelectBooking}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/checkin.js?v=<%= System.currentTimeMillis() %>"></script>

<jsp:include page="/views/common/footer.jsp" />
