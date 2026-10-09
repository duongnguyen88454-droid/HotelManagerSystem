<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist/checkin.css">

<div class="pms-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
        <div>
            <h2 style="color: #0f172a; margin: 0; font-size: 22px; font-weight: 800;">QUẦY TIẾP ĐÓN - THỦ TỤC CHECK-IN NHẬN PHÒNG</h2>
            <p style="color: #64748b; margin: 4px 0 0 0; font-size: 13px;">Tra cứu đơn đặt phòng và thực hiện bàn giao chìa khóa cho khách tại quầy</p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/receptionist/room-map" class="pms-btn pms-btn-secondary">[ Xem Sơ Đồ Phòng Timeline ]</a>
        </div>
    </div>

    <!-- MAIN PMS CARD -->
    <div class="pms-card">
        <div class="toolbar-header">
            <form action="${pageContext.request.contextPath}/receptionist/checkin" method="GET" style="display: flex; gap: 10px; align-items: center; margin: 0; width: 100%;">
                <input type="text" name="keyword" value="${keyword}" class="pms-input" placeholder="Tìm kiếm theo Mã BK, Tên khách, SĐT hoặc CCCD..." style="width: 360px;">
                <button type="submit" class="pms-btn pms-btn-primary">[ Tra cứu ]</button>
                <c:if test="${not empty keyword}">
                    <a href="${pageContext.request.contextPath}/receptionist/checkin" class="pms-btn pms-btn-secondary">[ Đặt lại ]</a>
                </c:if>
                <span style="color: #64748b; font-size: 12px; margin-left: auto;">Nhấp vào dòng đơn bất kỳ để xem chi tiết và bàn giao phòng</span>
            </form>
        </div>

        <div style="overflow-x: auto;">
            <table class="arrival-table">
                <thead>
                    <tr>
                        <th style="width: 100px;">Mã BK</th>
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
                            <td><strong>${item.maBooking}</strong></td>
                            <td style="font-weight: 700; color: #1e3a8a;">${item.tenKhachHang}</td>
                            <td>${item.soDienThoai}</td>
                            <td>${item.soCccd}</td>
                            <td>${item.ngayNhanDuKien}</td>
                            <td>${item.ngayTraDuKien}</td>
                            <td style="text-align: center; font-weight: 700;">${item.soPhongDaNhan} / ${item.tongSoPhong} phòng</td>
                            <td style="text-align: center;">
                                <c:choose>
                                    <c:when test="${item.soPhongDaNhan eq 0}">
                                        <span class="badge-waiting">${item.trangThaiTiepNhan}</span>
                                    </c:when>
                                    <c:when test="${item.soPhongDaNhan lt item.tongSoPhong}">
                                        <span class="badge-partial">${item.trangThaiTiepNhan}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-full">${item.trangThaiTiepNhan}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty arrivalList}">
                        <tr>
                            <td colspan="8" style="text-align: center; color: #64748b; padding: 30px;">Không có đơn đặt phòng nào phù hợp trong danh sách chờ tiếp nhận.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- MODAL CHI TIẾT ĐƠN ĐẶT PHÒNG & CHỌN PHÒNG BÀN GIAO                        -->
<!-- ========================================================================= -->
<div id="checkInDetailModal" class="pms-modal-backdrop">
    <div class="pms-modal-card">
        <div class="modal-head">
            <h3 id="mdlTitle">CHI TIẾT ĐƠN ĐẶT PHÒNG - BK</h3>
            <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="closeModal('checkInDetailModal')">[ Đóng ]</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="mdlBookingId" value="">

            <div class="detail-grid">
                <div>Khách đại diện: <strong id="mdlGuestName">--</strong></div>
                <div>Số điện thoại: <span id="mdlPhone">--</span></div>
                <div>Số CCCD: <span id="mdlCccd">--</span></div>
                <div>Email: <span id="mdlEmail">--</span></div>
                <div style="grid-column: span 2;">Thời gian lưu trú: <strong id="mdlStayDates">--</strong> (<span id="mdlNights">0</span> đêm)</div>
            </div>

            <div style="font-weight: 700; color: #0f172a; margin-bottom: 6px;">DANH SÁCH PHÒNG BÀN GIAO &amp; DỊCH VỤ ĐI KÈM:</div>
            <table class="room-select-table">
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
                        <td colspan="6" style="text-align: center; color: #64748b;">Đang tải danh sách phòng...</td>
                    </tr>
                </tbody>
            </table>

            <div id="cleaningNotice" style="display: none; margin-top: 14px; padding: 10px 14px; background: #fffbeb; border: 1px solid #fde68a; border-radius: 6px; color: #b45309; font-size: 12px; font-weight: 600;">
                Lưu ý: Có phòng đang được dọn dẹp hoặc chưa sẵn sàng, vui lòng kiểm tra với bộ phận buồng phòng trước khi bàn giao chìa khóa!
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" id="btnConfirmCheckIn" class="pms-btn pms-btn-success" onclick="submitCheckInSelection()">[ Xác nhận ]</button>
            <button type="button" class="pms-btn pms-btn-secondary" onclick="closeModal('checkInDetailModal')">[ Đóng ]</button>
        </div>
    </div>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.AUTO_SELECT_BOOKING = '${autoSelectBooking}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/checkin.js"></script>

<jsp:include page="/views/common/footer.jsp" />
