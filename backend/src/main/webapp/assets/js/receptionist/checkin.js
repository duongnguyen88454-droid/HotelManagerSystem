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
    const btnGoToCashier = document.getElementById('btnGoToCashier');
    if (btnGoToCashier) {
        btnGoToCashier.style.display = 'none';
    }

    const contextPath = window.CONTEXT_PATH || '';
    const url = contextPath + '/receptionist/checkin?action=detail&maBooking=' + encodeURIComponent(maBooking);

    fetch(url)
        .then(res => {
            if (!res.ok) {
                throw new Error('Máy chủ phản hồi mã lỗi ' + res.status);
            }
            return res.json();
        })
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
                chkHtml = '<input type="checkbox" name="selectedRoom" value="' + escapeHtml(r.maPhong) + '" onchange="updateSelectAllState()">';
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
    chkAll.checked = false;
    chkAll.disabled = !anyAvailableToSelect;

    const btnConfirm = document.getElementById('btnConfirmCheckIn');
    btnConfirm.disabled = true;

    // Nút chuyển sang quầy Check-out & Thanh toán nếu đơn có phòng đã nhận
    const btnGoToCashier = document.getElementById('btnGoToCashier');
    const hasAnyCheckedIn = data.rooms && data.rooms.some(r => r.daNhanPhong);
    if (btnGoToCashier) {
        if (hasAnyCheckedIn) {
            const bookingId = data.maBooking || document.getElementById('mdlBookingId').value;
            btnGoToCashier.href = (window.CONTEXT_PATH || '') + '/cashier/booking-detail?maBooking=' + encodeURIComponent(bookingId);
            btnGoToCashier.style.display = 'inline-flex';
        } else {
            btnGoToCashier.style.display = 'none';
        }
    }
}

function toggleSelectAllRooms(masterChk) {
    const checkboxes = document.querySelectorAll('input[name="selectedRoom"]');
    checkboxes.forEach(cb => {
        if (!cb.disabled) {
            cb.checked = masterChk.checked;
        }
    });
    updateSelectAllState();
}

function updateSelectAllState() {
    const checkboxes = document.querySelectorAll('input[name="selectedRoom"]');
    const checkedCount = document.querySelectorAll('input[name="selectedRoom"]:checked').length;
    const chkAll = document.getElementById('chkSelectAll');
    if (chkAll) {
        chkAll.checked = (checkboxes.length > 0 && checkedCount === checkboxes.length);
    }
    const btnConfirm = document.getElementById('btnConfirmCheckIn');
    if (btnConfirm) {
        btnConfirm.disabled = (checkedCount === 0);
    }
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

    const contextPath = window.CONTEXT_PATH || '';
    fetch(contextPath + '/receptionist/checkin', {
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

function submitCancelSelection() {
    const maBooking = document.getElementById('mdlBookingId').value.trim();
    if (!maBooking) {
        alert('[Lỗi] Không tìm thấy mã đơn đặt phòng!');
        return;
    }

    const checkedBoxes = document.querySelectorAll('input[name="selectedRoom"]:checked');
    let confirmMsg = '';
    const isSingleRooms = checkedBoxes.length > 0;

    if (isSingleRooms) {
        confirmMsg = 'Bạn có chắc chắn muốn HỦY ' + checkedBoxes.length + ' phòng đã chọn trong đơn ' + maBooking + ' không?';
    } else {
        confirmMsg = 'Bạn chưa chọn phòng cụ thể nào.\nBạn có chắc chắn muốn HỦY TOÀN BỘ đơn đặt phòng ' + maBooking + ' không?';
    }

    if (!confirm(confirmMsg)) {
        return;
    }

    const reason = prompt('Nhập lý do hủy phòng / đơn đặt phòng:', 'Khách liên hệ yêu cầu hủy phòng');
    if (reason === null) {
        return; // Người dùng ấn Cancel trong prompt
    }

    const params = new URLSearchParams();
    params.append('action', 'cancel');
    params.append('maBooking', maBooking);
    params.append('reason', reason.trim());

    if (isSingleRooms) {
        checkedBoxes.forEach(cb => {
            params.append('maPhong[]', cb.value);
        });
    }

    const contextPath = window.CONTEXT_PATH || '';
    fetch(contextPath + '/receptionist/checkin', {
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
                alert('[Lỗi Hủy Phòng] ' + (data.message || 'Không thể thực hiện hủy phòng'));
            }
        })
        .catch(err => {
            alert('[Lỗi kết nối] Không thể gửi yêu cầu đến máy chủ: ' + err.message);
        });
}

function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.innerText = text;
    return div.innerHTML;
}

// Tự động mở modal nếu chuyển từ Sơ đồ phòng sang kèm mã Booking
document.addEventListener('DOMContentLoaded', function() {
    if (window.AUTO_SELECT_BOOKING && window.AUTO_SELECT_BOOKING.trim() !== '') {
        openCheckInDetailModal(window.AUTO_SELECT_BOOKING);
    }
});
