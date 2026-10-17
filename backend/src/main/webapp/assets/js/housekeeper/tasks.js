function openInspectionModal(taskId, roomNumber, roomType) {
    document.getElementById('modalTaskId').value = taskId;
    document.getElementById('modalTaskIdText').innerText = 'Mã nhiệm vụ: #' + taskId;
    document.getElementById('modalRoomInfo').innerText = 'Phòng ' + roomNumber + ' (' + roomType + ')';
    document.getElementById('modalHasDamage').checked = false;
    toggleDamageNotice(false);
    var modal = document.getElementById('inspectionModal');
    if (modal) modal.style.display = 'flex';
}

function closeInspectionModal() {
    var modal = document.getElementById('inspectionModal');
    if (modal) modal.style.display = 'none';
}

function toggleDamageNotice(hasDamage) {
    var cleanBox = document.getElementById('cleanNoticeBox');
    var damageBox = document.getElementById('damageNoticeBox');
    var btnSubmit = document.getElementById('btnSubmitModal');
    if (!cleanBox || !damageBox || !btnSubmit) return;

    if (hasDamage) {
        cleanBox.style.display = 'none';
        damageBox.style.display = 'block';
        btnSubmit.style.background = '#dc2626';
        btnSubmit.innerText = 'Tiếp Tục Lập Biên Bản Hư Hại';
    } else {
        cleanBox.style.display = 'block';
        damageBox.style.display = 'none';
        btnSubmit.style.background = '#16a34a';
        btnSubmit.innerText = 'Xác Nhận Dọn Xong Phòng Sạch';
    }
}

/* ========================================================================== */
/* MODAL XEM CHI TIẾT NHIỆM VỤ CŨ                                             */
/* ========================================================================== */
function openTaskDetailModalFromBtn(btn) {
    if (!btn || !btn.dataset) return;
    var d = btn.dataset;
    openTaskDetailModal(
        d.taskid,
        d.room,
        d.roomtype,
        d.status,
        d.staffname,
        d.staffid,
        d.timenhan,
        d.timebatdau,
        d.timeketthuc,
        d.result
    );
}

function openTaskDetailModal(taskId, roomNo, roomType, roomStatus, staffName, staffId, assignedTime, startTime, endTime, result) {
    document.getElementById('dtlTaskId').innerText = '#' + (taskId || '--');
    document.getElementById('dtlRoom').innerText = 'Phòng ' + (roomNo || '--');
    document.getElementById('dtlRoomType').innerText = roomType || '--';
    document.getElementById('dtlStaff').innerText = (staffName || '--') + (staffId ? ' (' + staffId + ')' : '');

    var statusEl = document.getElementById('dtlRoomStatus');
    if (roomStatus === 'Available') {
        statusEl.className = 'badge-pill badge-available';
        statusEl.innerText = 'Đã Sạch (Available)';
    } else if (roomStatus === 'Damaged') {
        statusEl.className = 'badge-pill badge-damaged';
        statusEl.innerText = 'Hư Hại (Damaged)';
    } else {
        statusEl.className = 'badge-pill badge-cleaning';
        statusEl.innerText = roomStatus || '--';
    }

    document.getElementById('dtlTimeAssigned').innerText = assignedTime || '--';
    document.getElementById('dtlTimeStart').innerText = startTime || '--';
    document.getElementById('dtlTimeEnd').innerText = endTime || '--';

    var resultBox = document.getElementById('dtlResultBox');
    var resultText = document.getElementById('dtlResultText');
    if (result === 'CoThietHai' || result === 'Có thiệt hại') {
        resultBox.style.background = '#fef2f2';
        resultBox.style.borderColor = '#fecaca';
        resultText.style.color = '#b91c1c';
        resultText.innerText = 'Có Biên Bản Hư Hại Thiết Bị (Cần Bảo Trì)';
    } else {
        resultBox.style.background = '#f0fdf4';
        resultBox.style.borderColor = '#bbf7d0';
        resultText.style.color = '#15803d';
        resultText.innerText = 'Đạt Chuẩn Vệ Sinh Sạch Sẽ';
    }

    var modal = document.getElementById('taskDetailModal');
    if (modal) modal.style.display = 'flex';
}

function closeTaskDetailModal() {
    var modal = document.getElementById('taskDetailModal');
    if (modal) modal.style.display = 'none';
}

/* ========================================================================== */
/* TÌM KIẾM, LỌC & PHÂN TRANG (10 DÒNG/TRANG) - TAB LỊCH SỬ CỦA TÔI          */
/* ========================================================================== */
var historyPageSize = 10;
var historyCurrentPage = 1;
var historyMatchedRows = [];

function initHistoryPagination() {
    var rows = Array.from(document.querySelectorAll('.history-task-row'));
    if (!rows || rows.length === 0) {
        var pBar = document.getElementById('historyPagination');
        if (pBar) pBar.style.display = 'none';
        return;
    }
    historyMatchedRows = rows;
    historyCurrentPage = 1;
    renderHistoryPage();
}

function applyHistoryFilters() {
    var keyword = (document.getElementById('historySearchInput') ? document.getElementById('historySearchInput').value : '').trim().toLowerCase();
    var resultFilter = document.getElementById('historyResultFilter') ? document.getElementById('historyResultFilter').value : '';
    var dateFilter = document.getElementById('historyDateFilter') ? document.getElementById('historyDateFilter').value : '';

    var allRows = Array.from(document.querySelectorAll('.history-task-row'));
    historyMatchedRows = allRows.filter(function(row) {
        var room = (row.getAttribute('data-room') || '').toLowerCase();
        var roomType = (row.getAttribute('data-roomtype') || '').toLowerCase();
        var taskId = (row.getAttribute('data-taskid') || '').toLowerCase();
        var resVal = row.getAttribute('data-result') || '';
        var rowDate = row.getAttribute('data-date') || '';

        var matchKeyword = (!keyword || room.indexOf(keyword) !== -1 || roomType.indexOf(keyword) !== -1 || taskId.indexOf(keyword) !== -1);
        
        var matchResult = true;
        if (resultFilter === 'KhongThietHai') {
            matchResult = (resVal === 'KhongThietHai' || resVal === 'Không thiệt hại' || resVal === '');
        } else if (resultFilter === 'CoThietHai') {
            matchResult = (resVal === 'CoThietHai' || resVal === 'Có thiệt hại');
        }

        var matchDate = (!dateFilter || rowDate === dateFilter);

        return matchKeyword && matchResult && matchDate;
    });

    historyCurrentPage = 1; // Luôn reset về Trang 1 khi lọc
    renderHistoryPage();
}

function resetHistoryFilters() {
    if (document.getElementById('historySearchInput')) document.getElementById('historySearchInput').value = '';
    if (document.getElementById('historyResultFilter')) document.getElementById('historyResultFilter').selectedIndex = 0;
    if (document.getElementById('historyDateFilter')) document.getElementById('historyDateFilter').value = '';
    applyHistoryFilters();
}

function renderHistoryPage() {
    var allRows = Array.from(document.querySelectorAll('.history-task-row'));
    allRows.forEach(function(r) { r.style.display = 'none'; });

    var total = historyMatchedRows.length;
    var totalPages = Math.ceil(total / historyPageSize) || 1;
    if (historyCurrentPage > totalPages) historyCurrentPage = totalPages;
    if (historyCurrentPage < 1) historyCurrentPage = 1;

    var start = (historyCurrentPage - 1) * historyPageSize;
    var end = start + historyPageSize;

    historyMatchedRows.slice(start, end).forEach(function(row) {
        row.style.display = '';
    });

    var pBar = document.getElementById('historyPagination');
    if (!pBar) return;

    if (total === 0) {
        document.getElementById('historyPageInfo').innerText = 'Không tìm thấy nhiệm vụ nào phù hợp điều kiện lọc.';
        document.getElementById('historyCurrentPageText').innerText = 'Trang 0 / 0';
        document.getElementById('btnHistFirst').disabled = true;
        document.getElementById('btnHistPrev').disabled = true;
        document.getElementById('btnHistNext').disabled = true;
        document.getElementById('btnHistLast').disabled = true;
        return;
    }

    pBar.style.display = 'flex';
    var actualEnd = Math.min(end, total);
    document.getElementById('historyPageInfo').innerText = 'Hiển thị ' + (start + 1) + ' - ' + actualEnd + ' trên tổng số ' + total + ' nhiệm vụ';
    document.getElementById('historyCurrentPageText').innerText = 'Trang ' + historyCurrentPage + ' / ' + totalPages;

    document.getElementById('btnHistFirst').disabled = (historyCurrentPage === 1);
    document.getElementById('btnHistPrev').disabled = (historyCurrentPage === 1);
    document.getElementById('btnHistNext').disabled = (historyCurrentPage === totalPages);
    document.getElementById('btnHistLast').disabled = (historyCurrentPage === totalPages);
}

function goToHistoryPage(page) {
    historyCurrentPage = page;
    renderHistoryPage();
}

function changeHistoryPage(delta) {
    historyCurrentPage += delta;
    renderHistoryPage();
}

function goToHistoryLastPage() {
    var totalPages = Math.ceil(historyMatchedRows.length / historyPageSize) || 1;
    historyCurrentPage = totalPages;
    renderHistoryPage();
}

/* ========================================================================== */
/* TÌM KIẾM, LỌC & PHÂN TRANG (10 DÒNG/TRANG) - TAB LỊCH SỬ BIÊN BẢN HƯ HẠI   */
/* ========================================================================== */
var damagePageSize = 10;
var damageCurrentPage = 1;
var damageMatchedRows = [];

function initDamagePagination() {
    var rows = Array.from(document.querySelectorAll('.damage-record-row'));
    if (!rows || rows.length === 0) {
        var pBar = document.getElementById('damagePagination');
        if (pBar) pBar.style.display = 'none';
        return;
    }
    damageMatchedRows = rows;
    damageCurrentPage = 1;
    renderDamagePage();
}

function applyDamageFilters() {
    var keyword = (document.getElementById('damageSearchInput') ? document.getElementById('damageSearchInput').value : '').trim().toLowerCase();
    var statusVal = document.getElementById('damageStatusFilter') ? document.getElementById('damageStatusFilter').value : '';

    var allRows = Array.from(document.querySelectorAll('.damage-record-row'));
    damageMatchedRows = allRows.filter(function(row) {
        var room = (row.getAttribute('data-room') || '').toLowerCase();
        var reportId = (row.getAttribute('data-reportid') || '').toLowerCase();
        var dmgType = (row.getAttribute('data-damagetype') || '').toLowerCase();
        var desc = (row.getAttribute('data-desc') || '').toLowerCase();
        var st = row.getAttribute('data-status') || '';

        var matchKeyword = (!keyword || room.indexOf(keyword) !== -1 || reportId.indexOf(keyword) !== -1 || dmgType.indexOf(keyword) !== -1 || desc.indexOf(keyword) !== -1);
        var matchStatus = (!statusVal || st === statusVal);

        return matchKeyword && matchStatus;
    });

    damageCurrentPage = 1; // Luôn reset về Trang 1 khi lọc
    renderDamagePage();
}

function resetDamageFilters() {
    if (document.getElementById('damageSearchInput')) document.getElementById('damageSearchInput').value = '';
    if (document.getElementById('damageStatusFilter')) document.getElementById('damageStatusFilter').selectedIndex = 0;
    applyDamageFilters();
}

function renderDamagePage() {
    var allRows = Array.from(document.querySelectorAll('.damage-record-row'));
    allRows.forEach(function(r) { r.style.display = 'none'; });

    var total = damageMatchedRows.length;
    var totalPages = Math.ceil(total / damagePageSize) || 1;
    if (damageCurrentPage > totalPages) damageCurrentPage = totalPages;
    if (damageCurrentPage < 1) damageCurrentPage = 1;

    var start = (damageCurrentPage - 1) * damagePageSize;
    var end = start + damagePageSize;

    damageMatchedRows.slice(start, end).forEach(function(row) {
        row.style.display = '';
    });

    var pBar = document.getElementById('damagePagination');
    if (!pBar) return;

    if (total === 0) {
        document.getElementById('damagePageInfo').innerText = 'Không tìm thấy biên bản hư hại nào phù hợp điều kiện lọc.';
        document.getElementById('damageCurrentPageText').innerText = 'Trang 0 / 0';
        document.getElementById('btnDamageFirst').disabled = true;
        document.getElementById('btnDamagePrev').disabled = true;
        document.getElementById('btnDamageNext').disabled = true;
        document.getElementById('btnDamageLast').disabled = true;
        return;
    }

    pBar.style.display = 'flex';
    var actualEnd = Math.min(end, total);
    document.getElementById('damagePageInfo').innerText = 'Hiển thị ' + (start + 1) + ' - ' + actualEnd + ' trên tổng số ' + total + ' biên bản';
    document.getElementById('damageCurrentPageText').innerText = 'Trang ' + damageCurrentPage + ' / ' + totalPages;

    document.getElementById('btnDamageFirst').disabled = (damageCurrentPage === 1);
    document.getElementById('btnDamagePrev').disabled = (damageCurrentPage === 1);
    document.getElementById('btnDamageNext').disabled = (damageCurrentPage === totalPages);
    document.getElementById('btnDamageLast').disabled = (damageCurrentPage === totalPages);
}

function goToDamagePage(page) {
    damageCurrentPage = page;
    renderDamagePage();
}

function changeDamagePage(delta) {
    damageCurrentPage += delta;
    renderDamagePage();
}

function goToDamageLastPage() {
    var totalPages = Math.ceil(damageMatchedRows.length / damagePageSize) || 1;
    damageCurrentPage = totalPages;
    renderDamagePage();
}

/* ========================================================================== */
/* KHỞI CHẠY KHI TẢI TRANG                                                    */
/* ========================================================================== */
document.addEventListener('DOMContentLoaded', function() {
    initHistoryPagination();
    initDamagePagination();
});

window.addEventListener('click', function(e) {
    var inspModal = document.getElementById('inspectionModal');
    var dtlModal = document.getElementById('taskDetailModal');
    if (e.target === inspModal) closeInspectionModal();
    if (e.target === dtlModal) closeTaskDetailModal();
});

window.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeInspectionModal();
        closeTaskDetailModal();
    }
});

