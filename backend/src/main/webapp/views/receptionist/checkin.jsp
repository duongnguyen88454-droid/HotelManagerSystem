<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Quầy Tiếp Đón Check-in" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist/checkin.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="checkin" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <!-- Khối thẻ tìm kiếm và bảng danh sách tiếp nhận -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div class="toolbar-header" style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--portal-border);">
                <form action="${pageContext.request.contextPath}/receptionist/checkin" method="GET" style="display: flex; gap: 10px; align-items: center; margin: 0; width: 100%; flex-wrap: wrap;">
                    <input type="text" name="keyword" value="${keyword}" class="portal-input" placeholder="Tìm kiếm theo Mã BK, Tên khách, SĐT hoặc CCCD..." style="width: 380px;">
                    <button type="submit" class="portal-btn portal-btn-primary">Tra Cứu</button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/receptionist/checkin" class="portal-btn portal-btn-secondary">Đặt Lại</a>
                    </c:if>
                    <span style="color: var(--portal-text-muted); font-size: 12.5px; margin-left: auto;">Nhấp vào dòng đơn bất kỳ để xem chi tiết và bàn giao phòng</span>
                </form>
            </div>

            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table arrival-table">
                    <thead>
                        <tr>
                            <th style="width: 110px;">Mã BK</th>
                            <th>Khách Đại Diện</th>
                            <th>Số Điện Thoại</th>
                            <th>Số CCCD</th>
                            <th>Ngày Nhận</th>
                            <th>Ngày Trả</th>
                            <th style="text-align: center;">Số Lượng Phòng</th>
                            <th style="text-align: center;">Trạng Thái Tiếp Nhận</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${arrivalList}" var="item">
                            <tr class="clickable-row" onclick="openCheckInDetailModal('${item.maBooking}')" title="Nhấp để xem chi tiết đơn ${item.maBooking}">
                                <td><strong style="color: var(--portal-primary);">${item.maBooking}</strong></td>
                                <td style="font-weight: 700; color: var(--portal-text-primary);">${item.tenKhachHang}</td>
                                <td>${item.soDienThoai}</td>
                                <td>${item.soCccd}</td>
                                <td>${item.ngayNhanDuKien}</td>
                                <td>${item.ngayTraDuKien}</td>
                                <td style="text-align: center; font-weight: 700;">${item.soPhongDaNhan} / ${item.tongSoPhong} phòng</td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${item.soPhongDaNhan eq 0}">
                                            <span class="badge-pill badge-waiting">${item.trangThaiTiepNhan}</span>
                                        </c:when>
                                        <c:when test="${item.soPhongDaNhan lt item.tongSoPhong}">
                                            <span class="badge-pill badge-partial">${item.trangThaiTiepNhan}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-pill badge-available">${item.trangThaiTiepNhan}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty arrivalList}">
                            <tr>
                                <td colspan="8" style="text-align: center; color: var(--portal-text-muted); padding: 36px;">
                                    Không có đơn đặt phòng nào phù hợp trong danh sách chờ tiếp nhận.
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
<div id="checkInDetailModal" class="pms-modal-backdrop">
    <div class="pms-modal-card">
        <div class="modal-head" style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center;">
            <h3 id="mdlTitle" style="margin: 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">CHI TIẾT ĐƠN ĐẶT PHÒNG - BK</h3>
            <button type="button" class="portal-btn portal-btn-secondary" style="padding: 4px 10px; font-size: 12px;" onclick="closeModal('checkInDetailModal')">Đóng</button>
        </div>
        <div class="modal-body" style="padding: 24px;">
            <input type="hidden" id="mdlBookingId" value="">

            <div class="detail-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px; font-size: 13.5px; background: #f8fafc; padding: 16px; border-radius: 10px; border: 1px solid var(--portal-border);">
                <div>Khách đại diện: <strong id="mdlGuestName">--</strong></div>
                <div>Số điện thoại: <span id="mdlPhone">--</span></div>
                <div>Số CCCD: <span id="mdlCccd">--</span></div>
                <div>Email: <span id="mdlEmail">--</span></div>
                <div style="grid-column: span 2;">Thời gian lưu trú: <strong id="mdlStayDates">--</strong> (<span id="mdlNights">0</span> đêm)</div>
            </div>

            <div style="font-weight: 700; color: var(--portal-text-primary); margin-bottom: 10px; font-size: 14px;">DANH SÁCH PHÒNG BÀN GIAO & DỊCH VỤ ĐI KÈM:</div>
            <div class="portal-table-wrapper">
                <table class="portal-table room-select-table">
                    <thead>
                        <tr>
                            <th style="width: 45px; text-align: center;">
                                <input type="checkbox" id="chkSelectAll" onchange="toggleSelectAllRooms(this)" title="Chọn tất cả phòng">
                            </th>
                            <th style="width: 80px;">Phòng</th>
                            <th>Loại Phòng</th>
                            <th>Dịch Vụ Đặt Trước</th>
                            <th style="width: 120px; text-align: center;">Trạng Thái Buồng</th>
                            <th style="width: 140px; text-align: center;">Tình Trạng Nhận</th>
                        </tr>
                    </thead>
                    <tbody id="mdlRoomListBody">
                        <tr>
                            <td colspan="6" style="text-align: center; color: var(--portal-text-muted);">Đang tải danh sách phòng...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div id="cleaningNotice" style="display: none; margin-top: 14px; padding: 10px 14px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; color: #b45309; font-size: 12.5px; font-weight: 600;">
                Lưu ý: Có phòng đang được dọn dẹp hoặc chưa sẵn sàng, vui lòng kiểm tra với bộ phận buồng phòng trước khi bàn giao chìa khóa!
            </div>
        </div>
        <div class="modal-foot" style="padding: 16px 24px; border-top: 1px solid var(--portal-border); background: #f8fafc; display: flex; justify-content: flex-end; align-items: center; gap: 10px;">
            <button type="button" id="btnCancelBooking" class="portal-btn portal-btn-danger" style="margin-right: auto; display: inline-flex; align-items: center; gap: 6px;" onclick="submitCancelSelection()">
                <i class="fas fa-ban"></i> Hủy Phòng / Đơn Đặt
            </button>
            <a id="btnGoToCashier" href="#" class="portal-btn portal-btn-primary" style="display: none; text-decoration: none; align-items: center; justify-content: center;">
                Quầy Check-out &amp; Thanh Toán
            </a>
            <button type="button" id="btnConfirmCheckIn" class="portal-btn portal-btn-success" onclick="submitCheckInSelection()">Xác Nhận Bàn Giao</button>
            <button type="button" class="portal-btn portal-btn-secondary" onclick="closeModal('checkInDetailModal')">Đóng</button>
        </div>
    </div>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.AUTO_SELECT_BOOKING = '${autoSelectBooking}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/checkin.js?v=<%= System.currentTimeMillis() %>"></script>

<jsp:include page="/views/common/footer.jsp" />
