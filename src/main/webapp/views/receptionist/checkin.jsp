<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<style>
    .pms-container {
        max-width: 1350px;
        margin: 20px auto;
        padding: 0 20px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }

    .pms-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        margin-bottom: 20px;
    }

    .toolbar-header {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        align-items: center;
        gap: 15px;
        padding: 16px 20px;
        background: #f8fafc;
        border-bottom: 1px solid #e2e8f0;
        border-radius: 8px 8px 0 0;
    }

    .pms-input {
        padding: 8px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 5px;
        font-size: 13px;
        background: #ffffff;
        color: #1e293b;
    }

    .pms-btn {
        padding: 8px 16px;
        border-radius: 5px;
        font-size: 13px;
        font-weight: 700;
        cursor: pointer;
        border: none;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: opacity 0.2s;
    }

    .pms-btn:hover {
        opacity: 0.9;
    }

    .pms-btn-primary {
        background: #1e3a8a;
        color: #ffffff;
    }

    .pms-btn-success {
        background: #15803d;
        color: #ffffff;
    }

    .pms-btn-secondary {
        background: #e2e8f0;
        color: #334155;
    }

    .arrival-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }

    .arrival-table th {
        background: #f8fafc;
        color: #334155;
        font-weight: 700;
        text-align: left;
        padding: 12px 14px;
        border-bottom: 1px solid #cbd5e1;
    }

    .arrival-table td {
        padding: 12px 14px;
        border-bottom: 1px solid #f1f5f9;
        color: #1e293b;
        vertical-align: middle;
    }

    .clickable-row {
        cursor: pointer;
        transition: background 0.15s ease-in-out;
    }

    .clickable-row:hover {
        background: #f1f5f9;
    }

    .badge-clean {
        background: #15803d;
        color: #ffffff;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-dirty {
        background: #b45309;
        color: #ffffff;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-cleaning {
        background: #d97706;
        color: #ffffff;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-damaged {
        background: #475569;
        color: #ffffff;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-occupied {
        background: #b91c1c;
        color: #ffffff;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-waiting {
        background: #e0e7ff;
        color: #3730a3;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-partial {
        background: #fef3c7;
        color: #b45309;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .badge-full {
        background: #dcfce7;
        color: #15803d;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 11px;
        font-weight: 700;
        display: inline-block;
    }

    .pms-modal-backdrop {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(15, 23, 42, 0.6);
        display: none;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    }

    .pms-modal-card {
        background: #ffffff;
        width: 820px;
        max-width: 95%;
        border-radius: 8px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        overflow: hidden;
        display: flex;
        flex-direction: column;
    }

    .modal-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 14px 20px;
        background: #1e3a8a;
        color: #ffffff;
    }

    .modal-head h3 {
        margin: 0;
        font-size: 16px;
        font-weight: 700;
    }

    .modal-body {
        padding: 22px 24px;
        max-height: 75vh;
        overflow-y: auto;
        color: #1e293b;
        font-size: 13px;
        line-height: 1.6;
    }

    .modal-foot {
        padding: 14px 20px;
        background: #f8fafc;
        border-top: 1px solid #e2e8f0;
        display: flex;
        justify-content: flex-end;
        gap: 10px;
    }

    .detail-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        margin-bottom: 16px;
        background: #f8fafc;
        padding: 14px;
        border-radius: 6px;
        border: 1px solid #e2e8f0;
    }

    .room-select-table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 8px;
    }

    .room-select-table th,
    .room-select-table td {
        border: 1px solid #cbd5e1;
        padding: 9px 12px;
        text-align: left;
    }

    .room-select-table th {
        background: #f1f5f9;
        font-weight: 700;
    }
</style>

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
    function openModal(modalId) {
        document.getElementById(modalId).style.display = 'flex';
    }

    function closeModal(modalId) {
        document.getElementById(modalId).style.display = 'none';
    }

    function openCheckInDetailModal(maBooking) {
        if (!maBooking) return;

        document.getElementById('mdlTitle').innerText = 'CHI TIẾT ĐƠN ĐẶT PHÒNG - ' + maBooking;
        document.getElementById('mdlBookingId').value = maBooking;
        document.getElementById('mdlRoomListBody').innerHTML = '<tr><td colspan="6" style="text-align: center; color: #64748b;">Đang tải danh sách phòng...</td></tr>';
        document.getElementById('cleaningNotice').style.display = 'none';

        const url = '${pageContext.request.contextPath}/receptionist/checkin?action=detail&maBooking=' + encodeURIComponent(maBooking);

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    renderDetailModal(data);
                    openModal('checkInDetailModal');
                } else {
                    alert('[Lỗi] ' + (data.message || 'Không thể tải dữ liệu đơn đặt phòng!'));
                }
            })
            .catch(err => {
                alert('[Lỗi kết nối] ' + err.message);
            });
    }

    function renderDetailModal(data) {
        document.getElementById('mdlGuestName').innerText = data.tenKhachHang || '--';
        document.getElementById('mdlPhone').innerText = data.soDienThoai || '--';
        document.getElementById('mdlCccd').innerText = data.soCccd || '--';
        document.getElementById('mdlEmail').innerText = data.email || '--';
        document.getElementById('mdlStayDates').innerText = (data.ngayNhanDuKien || '--') + ' đến ' + (data.ngayTraDuKien || '--');
        document.getElementById('mdlNights').innerText = data.soDem || '0';

        const tbody = document.getElementById('mdlRoomListBody');
        tbody.innerHTML = '';

        let hasCleaning = false;
        let anyAvailableToSelect = false;

        if (data.rooms && data.rooms.length > 0) {
            data.rooms.forEach(r => {
                const tr = document.createElement('tr');

                if (r.trangThaiBuong === 'Cleaning' || r.trangThaiBuong === 'Dirty') {
                    hasCleaning = true;
                }

                // Cột checkbox
                let chkHtml = '';
                if (r.daNhanPhong) {
                    chkHtml = '<span style="color: #94a3b8; font-weight: 700;">[--]</span>';
                } else {
                    chkHtml = '<input type="checkbox" name="selectedRoom" value="' + escapeHtml(r.maPhong) + '" checked onchange="updateSelectAllState()">';
                    anyAvailableToSelect = true;
                }

                // Dịch vụ
                let svcsHtml = '<span style="color: #94a3b8; font-style: italic;">(Không có dịch vụ)</span>';
                if (r.dichVu && r.dichVu.length > 0) {
                    svcsHtml = '<div style="line-height: 1.4;">' + r.dichVu.map(s => escapeHtml(s)).join('<br>') + '</div>';
                }

                // Tình trạng nhận phòng
                let checkInStatusHtml = '<span class="badge-waiting">Chờ nhận</span>';
                if (r.daNhanPhong) {
                    checkInStatusHtml = '<span style="color: #15803d; font-weight: 700;">Đã nhận (' + escapeHtml(r.ngayCheckInThucTe) + ')</span>';
                }

                tr.innerHTML = '<td style="text-align: center;">' + chkHtml + '</td>'
                    + '<td><strong>' + escapeHtml(r.maPhong) + '</strong></td>'
                    + '<td>' + escapeHtml(r.tenLoaiPhong) + '</td>'
                    + '<td>' + svcsHtml + '</td>'
                    + '<td style="text-align: center;"><span class="' + escapeHtml(r.trangThaiBuongCss) + '">' + escapeHtml(r.trangThaiBuongText) + '</span></td>'
                    + '<td style="text-align: center;">' + checkInStatusHtml + '</td>';

                tbody.appendChild(tr);
            });
        } else {
            tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #94a3b8;">Không tìm thấy thông tin phòng trong đơn này.</td></tr>';
        }

        if (hasCleaning) {
            document.getElementById('cleaningNotice').style.display = 'block';
        }

        const chkAll = document.getElementById('chkSelectAll');
        chkAll.checked = anyAvailableToSelect;
        chkAll.disabled = !anyAvailableToSelect;

        const btnConfirm = document.getElementById('btnConfirmCheckIn');
        btnConfirm.disabled = !anyAvailableToSelect;
    }

    function toggleSelectAllRooms(masterChk) {
        const checkboxes = document.querySelectorAll('input[name="selectedRoom"]');
        checkboxes.forEach(cb => {
            if (!cb.disabled) {
                cb.checked = masterChk.checked;
            }
        });
    }

    function updateSelectAllState() {
        const checkboxes = document.querySelectorAll('input[name="selectedRoom"]');
        const checkedCount = document.querySelectorAll('input[name="selectedRoom"]:checked').length;
        const chkAll = document.getElementById('chkSelectAll');
        chkAll.checked = (checkboxes.length > 0 && checkedCount === checkboxes.length);
    }

    function submitCheckInSelection() {
        const maBooking = document.getElementById('mdlBookingId').value.trim();
        const checkedBoxes = document.querySelectorAll('input[name="selectedRoom"]:checked');

        if (!maBooking) {
            alert('[Lỗi] Không tìm thấy mã đơn đặt phòng!');
            return;
        }

        if (checkedBoxes.length === 0) {
            alert('[Cảnh báo] Vui lòng tích chọn ít nhất một phòng muốn bàn giao!');
            return;
        }

        const params = new URLSearchParams();
        params.append('maBooking', maBooking);
        checkedBoxes.forEach(cb => {
            params.append('maPhong[]', cb.value);
        });

        fetch('${pageContext.request.contextPath}/receptionist/checkin', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params.toString()
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert('[Thành công] ' + data.message);
                    closeModal('checkInDetailModal');
                    window.location.reload();
                } else {
                    alert('[Lỗi Check-in] ' + (data.message || 'Lỗi không xác định'));
                }
            })
            .catch(err => {
                alert('[Lỗi kết nối] Không thể kết nối đến máy chủ: ' + err.message);
            });
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.innerText = text;
        return div.innerHTML;
    }

    // Tự động mở modal nếu chuyển từ Sơ đồ phòng sang kèm mã Booking
    <c:if test="${not empty autoSelectBooking}">
        document.addEventListener('DOMContentLoaded', function() {
            openCheckInDetailModal('${autoSelectBooking}');
        });
    </c:if>
</script>

<jsp:include page="/views/common/footer.jsp" />
