function openInspectionModal(taskId, roomNumber, roomType) {
    document.getElementById('modalTaskId').value = taskId;
    document.getElementById('modalTaskIdText').innerText = 'Mã nhiệm vụ: #' + taskId;
    document.getElementById('modalRoomInfo').innerText = 'Phòng ' + roomNumber + ' (' + roomType + ')';
    document.getElementById('modalHasDamage').checked = false;
    toggleDamageNotice(false);
    var modal = document.getElementById('inspectionModal');
    modal.style.display = 'flex';
}

function closeInspectionModal() {
    document.getElementById('inspectionModal').style.display = 'none';
}

function toggleDamageNotice(hasDamage) {
    var cleanBox = document.getElementById('cleanNoticeBox');
    var damageBox = document.getElementById('damageNoticeBox');
    var btnSubmit = document.getElementById('btnSubmitModal');
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
