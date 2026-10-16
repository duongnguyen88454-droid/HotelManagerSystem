function toggleSelectAllRooms(master) {
    const checkboxes = document.querySelectorAll('.room-selectable');
    checkboxes.forEach(cb => {
        cb.checked = master.checked;
    });
}

document.addEventListener('DOMContentLoaded', function() {
    const checkoutForm = document.querySelector('form[action*="/cashier/payment"]');
    if (checkoutForm) {
        checkoutForm.addEventListener('submit', function(e) {
            const selectable = document.querySelectorAll('.room-selectable');
            if (selectable.length > 0) {
                const checked = document.querySelectorAll('.room-selectable:checked');
                if (checked.length === 0) {
                    e.preventDefault();
                    alert('[Cảnh báo] Vui lòng tích chọn ít nhất một phòng cần làm thủ tục trả phòng!');
                }
            }
        });
    }
});

