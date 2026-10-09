// 1. TÌM KIẾM VA BỘ LỌC TIMELINE
function applyFilter() {
    const kw = document.getElementById('filterKeyword').value.trim().toLowerCase();
    const floor = document.getElementById('filterFloor').value;
    const status = document.getElementById('filterStatus').value;
    const rows = document.querySelectorAll('.room-row');

    rows.forEach(r => {
        const rFloor = r.getAttribute('data-floor');
        const rStatus = r.getAttribute('data-status');
        const rText = r.innerText.toLowerCase();

        let matchKw = (kw === '' || rText.includes(kw));
        let matchFloor = (floor === 'ALL' || rFloor === floor);
        let matchStatus = (status === 'ALL' || rStatus === status);

        r.style.display = (matchKw && matchFloor && matchStatus) ? '' : 'none';
    });

    // Ẩn tiêu đề tầng nếu không có phòng nào trong tầng hiển thị
    document.querySelectorAll('.floor-row').forEach(floorRow => {
        const fl = floorRow.getAttribute('data-floor');
        const visible = document.querySelectorAll('.room-row[data-floor="' + fl + '"]:not([style*="display: none"])');
        floorRow.style.display = (visible.length > 0) ? '' : 'none';
    });
}

function resetFilter() {
    document.getElementById('filterKeyword').value = '';
    document.getElementById('filterFloor').value = 'ALL';
    document.getElementById('filterStatus').value = 'ALL';
    applyFilter();
}

// 2. MODAL CONTROLS
function openModal(modalId) {
    document.getElementById(modalId).style.display = 'flex';
}
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Điều phối click vào Booking Bar (Thống nhất 1 modal bookingModal duy nhất)
function handleBookingBarClick(roomId, roomNo, bookingId, guestName, phone, cccd, status, inDate, outDate, actualIn, actualOut) {
    const contextPath = window.CONTEXT_PATH || '';
    document.getElementById('bmRoomIdVal').value = roomId || '';
    document.getElementById('bmRoomNoVal').value = roomNo || roomId || '';
    document.getElementById('bmBookingIdVal').value = bookingId || '';

    document.getElementById('bmBookingId').innerText = bookingId || '--';
    document.getElementById('bmRoomId').innerText = roomId + (roomNo ? (' (Phòng ' + roomNo + ')') : '');
    document.getElementById('bmGuestName').innerText = guestName || '--';
    document.getElementById('bmPhone').innerText = phone || '--';
    document.getElementById('bmCccd').innerText = cccd || '--';
    document.getElementById('bmInDate').innerText = inDate || '--';
    document.getElementById('bmOutDate').innerText = outDate || '--';
    document.getElementById('bmActualIn').innerText = (actualIn && actualIn.trim() !== '') ? actualIn : '___';
    document.getElementById('bmActualOut').innerText = (actualOut && actualOut.trim() !== '') ? actualOut : '___';

    const modalTitle = document.getElementById('bookingModalTitle');
    const modalHead = document.getElementById('bookingModalHead');
    const occupiedArea = document.getElementById('occupiedArea');
    const btnOrderService = document.getElementById('btnOrderService');
    const btnCheckOut = document.getElementById('btnCheckOut');

    // Đồng bộ màu header chuẩn navy blue
    if (modalHead) modalHead.style.background = '#1e3a8a';

    // Đồng bộ thông tin sẵn cho modal gọi dịch vụ nếu cần
    document.getElementById('ordRoomId').value = roomId || '';
    document.getElementById('ordBookingId').value = bookingId || '';
    document.getElementById('modalOrderServiceTitle').innerText = 'GỌI THÊM ĐỒ UỐNG / DỊCH VỤ - PHÒNG ' + (roomNo || roomId);

    const btnGoToCheckIn = document.getElementById('btnGoToCheckIn');

    if (status === 'DaCheckIn') {
        modalTitle.innerText = 'THÔNG TIN CHI TIẾT PHÒNG ĐANG LƯU TRÚ - ' + roomId;
        occupiedArea.style.display = 'block';
        btnOrderService.style.display = '';
        btnCheckOut.style.display = '';
        if (btnGoToCheckIn) btnGoToCheckIn.style.display = 'none';
        loadServicesUsed(bookingId, roomId);
    } else {
        modalTitle.innerText = 'THÔNG TIN CHI TIẾT ĐẶT PHÒNG - ' + roomId;
        occupiedArea.style.display = 'none';
        btnOrderService.style.display = 'none';
        btnCheckOut.style.display = 'none';
        if (btnGoToCheckIn) {
            btnGoToCheckIn.style.display = '';
            btnGoToCheckIn.href = contextPath + '/receptionist/checkin?maBooking=' + encodeURIComponent(bookingId);
        }
    }

    openModal('bookingModal');
}

// Hỗ trợ tương thích ngược
function openRoomDetailModal(roomId, bookingId, guestName, phone, cccd, inDate, outDate, actualIn, actualOut) {
    handleBookingBarClick(roomId, roomId, bookingId, guestName, phone, cccd, 'DaCheckIn', inDate, outDate, actualIn, actualOut);
}

function openCheckInModal(roomId, roomNo, bookingId, guestName, phone, cccd, inDate, outDate) {
    handleBookingBarClick(roomId, roomNo, bookingId, guestName, phone, cccd, 'XacNhan', inDate, outDate, '___', '___');
}

// Tải danh sách dịch vụ phòng đã dùng từ API (FN-3.5)
function loadServicesUsed(bookingId, roomId) {
    const contextPath = window.CONTEXT_PATH || '';
    const tbody = document.getElementById('usedServiceList');
    tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #64748b;">Đang tải danh sách dịch vụ...</td></tr>';

    const url = contextPath + '/api/receptionist/services?action=usage&maBooking='
        + encodeURIComponent(bookingId || '') + '&maPhong=' + encodeURIComponent(roomId || '');

    fetch(url)
        .then(res => res.json())
        .then(data => {
            if (data.success && data.services && data.services.length > 0) {
                tbody.innerHTML = '';
                data.services.forEach(s => {
                    const tr = document.createElement('tr');
                    tr.innerHTML = '<td>' + escapeHtml(s.tenDichVu) + '</td>'
                        + '<td style="text-align: center;">' + s.soLuong + '</td>'
                        + '<td style="text-align: right;">' + s.donGia.toLocaleString('vi-VN') + ' đ</td>'
                        + '<td style="text-align: right; font-weight: 600;">' + s.thanhTien.toLocaleString('vi-VN') + ' đ</td>';
                    tbody.appendChild(tr);
                });
                const formattedCost = data.totalCost.toLocaleString('vi-VN') + ' đ';
                document.getElementById('totalServiceCost').innerText = formattedCost;
                const dtlSummary = document.getElementById('dtlServiceCostSummary');
                if (dtlSummary) dtlSummary.innerText = formattedCost;
            } else {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #94a3b8; font-style: italic;">Chưa có dịch vụ phát sinh nào cho phòng này.</td></tr>';
                document.getElementById('totalServiceCost').innerText = '0 đ';
                const dtlSummary = document.getElementById('dtlServiceCostSummary');
                if (dtlSummary) dtlSummary.innerText = '0 đ';
            }
        })
        .catch(err => {
            tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #ef4444;">Lỗi khi tải dịch vụ: ' + err.message + '</td></tr>';
            const dtlSummary = document.getElementById('dtlServiceCostSummary');
            if (dtlSummary) dtlSummary.innerText = '0 đ';
        });
}

// Mở trực tiếp Modal Gọi Dịch Vụ từ nút trên thẻ phòng
function openServiceOrderForRoom(roomId, roomNo) {
    const contextPath = window.CONTEXT_PATH || '';
    document.getElementById('ordRoomId').value = roomId;
    document.getElementById('modalOrderServiceTitle').innerText = 'GỌI THÊM ĐỒ UỐNG / DỊCH VỤ - PHÒNG ' + roomNo;

    fetch(contextPath + '/api/receptionist/services?action=usage&maPhong=' + encodeURIComponent(roomId))
        .then(res => res.json())
        .then(data => {
            if (data.maBooking) {
                document.getElementById('ordBookingId').value = data.maBooking;
            }
            openModal('orderServiceModal');
            updatePriceCalculation();
        })
        .catch(() => {
            openModal('orderServiceModal');
            updatePriceCalculation();
        });
}

// Chuyển sang Modal Gọi Dịch Vụ
function switchToOrderServiceModal() {
    closeModal('bookingModal');
    openModal('orderServiceModal');
    updatePriceCalculation();
}

// Quay lại Modal Chi Tiết Phòng
function backToRoomDetail() {
    closeModal('orderServiceModal');
    openModal('bookingModal');
}

// Chuyển sang phân hệ Thu Ngân để quyết toán / trả phòng
function goToCheckOutCashier() {
    const contextPath = window.CONTEXT_PATH || '';
    var bookingId = document.getElementById('bmBookingIdVal').value;
    if (bookingId && bookingId.trim() !== '') {
        window.location.href = contextPath + '/cashier/booking-detail?maBooking=' + encodeURIComponent(bookingId.trim());
    } else {
        window.location.href = contextPath + '/cashier/dashboard';
    }
}

// 3. TÍNH TOÁN VA GỌI DỊCH VỤ
function adjustQty(delta) {
    const qtyInput = document.getElementById('orderQty');
    let current = parseInt(qtyInput.value) || 1;
    current += delta;
    if (current < 1) current = 1;
    if (current > 20) current = 20;
    qtyInput.value = current;
    updatePriceCalculation();
}

function updatePriceCalculation() {
    const select = document.getElementById('serviceSelect');
    const selectedOpt = select.options[select.selectedIndex];
    const price = parseInt(selectedOpt.getAttribute('data-price')) || 0;
    const unit = selectedOpt.getAttribute('data-unit') || '';
    const qty = parseInt(document.getElementById('orderQty').value) || 1;

    document.getElementById('unitText').innerText = '(' + unit + ')';
    const subtotal = price * qty;
    document.getElementById('subtotalText').innerText = subtotal.toLocaleString('vi-VN') + ' đ';
}

function changeServiceCategory() {
    updatePriceCalculation();
}

// Thoát ký tự HTML an toàn
function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.innerText = text;
    return div.innerHTML;
}

// Gọi Dịch Vụ Thật Qua API (FN-3.4)
function saveServiceOrderReal() {
    const contextPath = window.CONTEXT_PATH || '';
    const bookingId = document.getElementById('ordBookingId').value.trim();
    const roomId = document.getElementById('ordRoomId').value.trim();
    const select = document.getElementById('serviceSelect');
    const maDichVu = select.value;
    const svcName = select.options[select.selectedIndex].text.split(' - ')[0];
    const qty = parseInt(document.getElementById('orderQty').value) || 1;
    const note = document.getElementById('orderNote').value.trim();

    if (!maDichVu) {
        alert('[Cảnh báo] Vui lòng chọn một dịch vụ!');
        return;
    }

    const params = new URLSearchParams();
    params.append('maBooking', bookingId);
    params.append('maPhong', roomId);
    params.append('maDichVu', maDichVu);
    params.append('soLuong', qty);
    params.append('ghiChu', note);

    fetch(contextPath + '/api/receptionist/services', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: params.toString()
    })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert('[Thành công] Đã ghi nhận ' + qty + ' x ' + svcName + ' vào phòng ' + roomId + '!');
                closeModal('orderServiceModal');
                loadServicesUsed(bookingId, roomId);
                openModal('bookingModal');
            } else {
                alert('[Lỗi] Không thể thêm dịch vụ: ' + (data.message || 'Lỗi không xác định'));
            }
        })
        .catch(err => {
            alert('[Lỗi kết nối] Không thể kết nối đến máy chủ lễ tân: ' + err.message);
        });
}

// Xác Nhận Check-In Thật (Gửi AJAX POST đến ReceptionistCheckInServlet)
function confirmCheckInReal() {
    const contextPath = window.CONTEXT_PATH || '';
    const bookingId = document.getElementById('bmBookingIdVal').value.trim();
    const roomId = document.getElementById('bmRoomIdVal').value.trim();
    const note = document.getElementById('bmNote') ? document.getElementById('bmNote').value.trim() : '';

    const params = new URLSearchParams();
    params.append('maBooking', bookingId);
    params.append('maPhong', roomId);
    params.append('ghiChu', note);
    params.append('chkCccd', 'true');

    fetch(contextPath + '/receptionist/checkin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: params.toString()
    })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert('[Thành công] ' + data.message);
                closeModal('bookingModal');
                updateTimelineAfterCheckIn(roomId, bookingId);
            } else {
                alert('[Lỗi Check-in] ' + data.message);
            }
        })
        .catch(err => {
            alert('[Lỗi kết nối] Không thể kết nối đến máy chủ lễ tân.');
        });
}

// Cập nhật DOM tức thì sau khi Check-In thành công
function updateTimelineAfterCheckIn(roomId, bookingId) {
    const roomRow = document.querySelector('.room-row[data-room="' + roomId + '"]');
    if (roomRow) {
        roomRow.setAttribute('data-status', 'Occupied');
        const badgeSpan = roomRow.querySelector('span[class*="badge-"]');
        if (badgeSpan) {
            badgeSpan.className = 'badge-occupied';
            badgeSpan.innerText = '[Đang có khách]';
        }
        const bar = roomRow.querySelector('.booking-bar');
        if (bar) {
            bar.classList.remove('bar-confirmed');
            bar.classList.add('bar-occupied');
            const guestName = document.getElementById('bmGuestName').innerText;
            const phone = document.getElementById('bmPhone').innerText;
            const cccd = document.getElementById('bmCccd').innerText;
            const inDate = document.getElementById('bmInDate') ? document.getElementById('bmInDate').innerText : '';
            const outDate = document.getElementById('bmOutDate') ? document.getElementById('bmOutDate').innerText : '';
            const roomNo = document.getElementById('bmRoomNoVal') ? document.getElementById('bmRoomNoVal').value : roomId;
            const now = new Date();
            const nowStr = now.getFullYear() + '-'
                + String(now.getMonth() + 1).padStart(2, '0') + '-'
                + String(now.getDate()).padStart(2, '0') + ' '
                + String(now.getHours()).padStart(2, '0') + ':'
                + String(now.getMinutes()).padStart(2, '0') + ':'
                + String(now.getSeconds()).padStart(2, '0');
            bar.innerText = guestName;
            bar.title = '[' + bookingId + '] ' + guestName + ' (Đang lưu trú)';
            bar.setAttribute('onclick', "handleBookingBarClick('" + roomId + "', '" + roomNo + "', '" + bookingId + "', '" + guestName + "', '" + phone + "', '" + cccd + "', 'DaCheckIn', '" + inDate + "', '" + outDate + "', '" + nowStr + "', '___')");
        }
    }
}

// Xử lý thông báo khi tạo đơn đặt phòng thành công từ màn hình Đặt phòng mới
document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const bSuccess = urlParams.get('bookingSuccess');
    if (bSuccess) {
        alert('[Thành công] Đã tiếp nhận đơn đặt phòng mới: ' + bSuccess);
    }
});
