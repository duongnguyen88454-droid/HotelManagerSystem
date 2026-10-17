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

            const isCancelled = (r.trangThaiDatPhong === 'Cancelled');

            // Cột checkbox
            let chkHtml = '';
            if (isCancelled || r.daNhanPhong) {
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
            if (isCancelled) {
                checkInStatusHtml = '<span class="badge badge-danger" style="background: #fee2e2; color: #b91c1c; border: 1px solid #f87171; font-weight: 700; padding: 2px 8px; border-radius: 4px;">Đã hủy cọc</span>';
                tr.style.opacity = '0.7';
                tr.style.background = '#fef2f2';
            } else if (r.daNhanPhong) {
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
    const btnCancel = document.getElementById('btnCancelBooking');
    if (btnCancel) {
        btnCancel.innerText = (checkedCount > 0) ? ('Hủy (' + checkedCount + ') Phòng Đã Chọn') : 'Hủy Phòng Đã Chọn';
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

let pendingCancelRoomIds = [];

function submitCancelSelection() {
    const maBooking = document.getElementById('mdlBookingId').value.trim();
    if (!maBooking) {
        alert('Không tìm thấy mã đơn đặt phòng!');
        return;
    }

    const checkedBoxes = document.querySelectorAll('input[name="selectedRoom"]:checked');
    if (checkedBoxes.length === 0) {
        alert('Vui lòng tích chọn ít nhất một phòng cần hủy!');
        return;
    }

    pendingCancelRoomIds = [];
    checkedBoxes.forEach(cb => pendingCancelRoomIds.push(cb.value));

    document.getElementById('cancelBookingIdInput').value = maBooking;
    document.getElementById('cancelRoomsDisplay').value = pendingCancelRoomIds.join(', ') + ' (' + pendingCancelRoomIds.length + ' phòng)';
    document.getElementById('cancelModalNotice').innerText = 'Xác nhận hủy ' + pendingCancelRoomIds.length + ' phòng đã chọn khỏi đơn ' + maBooking + '. Các phòng khác vẫn được giữ nguyên!';
    document.getElementById('cancelReasonInput').value = 'Khách liên hệ yêu cầu hủy phòng ' + pendingCancelRoomIds.join(', ');

    openModal('cancelConfirmModal');
}

function executeCancelConfirmed() {
    const maBooking = document.getElementById('cancelBookingIdInput').value.trim();
    const reason = document.getElementById('cancelReasonInput').value.trim();

    if (!reason) {
        alert('Vui lòng nhập lý do hủy phòng!');
        return;
    }

    const btn = document.getElementById('btnExecuteCancel');
    if (btn) {
        btn.disabled = true;
        btn.innerText = 'Đang xử lý...';
    }

    const params = new URLSearchParams();
    params.append('action', 'cancel');
    params.append('maBooking', maBooking);
    params.append('reason', reason);

    if (pendingCancelRoomIds.length > 0) {
        pendingCancelRoomIds.forEach(id => {
            params.append('maPhong[]', id);
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
                closeModal('cancelConfirmModal');
                closeModal('checkInDetailModal');
                window.location.reload();
            } else {
                alert('[Lỗi Hủy Phòng] ' + (data.message || 'Không thể thực hiện hủy phòng'));
                if (btn) {
                    btn.disabled = false;
                    btn.innerText = 'Xác Nhận Hủy Ngay';
                }
            }
        })
        .catch(err => {
            alert('[Lỗi kết nối] Không thể gửi yêu cầu đến máy chủ: ' + err.message);
            if (btn) {
                btn.disabled = false;
                btn.innerText = 'Xác Nhận Hủy Ngay';
            }
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
