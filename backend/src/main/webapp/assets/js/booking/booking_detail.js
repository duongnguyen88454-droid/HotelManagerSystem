function openAddServiceModal(roomId, roomNumber) {
    document.getElementById('modalRoomId').value = roomId;
    document.getElementById('modalTitle').innerText = 'Thêm Dịch Vụ Cho Phòng ' + roomNumber;
    document.getElementById('modalServiceSelect').selectedIndex = 0;
    document.getElementById('modalQuantity').value = 1;
    document.getElementById('modalPricePreview').innerText = '0 đ';
    document.getElementById('addServiceModal').style.display = 'flex';
}

function closeAddServiceModal() {
    document.getElementById('addServiceModal').style.display = 'none';
}

function updateModalPricePreview() {
    const select = document.getElementById('modalServiceSelect');
    const selectedOption = select.options[select.selectedIndex];
    const unitPrice = parseFloat(selectedOption.getAttribute('data-price')) || 0;
    const qty = parseInt(document.getElementById('modalQuantity').value) || 0;
    const total = unitPrice * qty;
    document.getElementById('modalPricePreview').innerText = total.toLocaleString('vi-VN') + ' đ';
}

window.onclick = function(event) {
    const modal = document.getElementById('addServiceModal');
    if (event.target === modal) {
        closeAddServiceModal();
    }
};
