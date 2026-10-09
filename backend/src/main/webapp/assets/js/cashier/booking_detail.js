function toggleSelectAllRooms(master) {
    const checkboxes = document.querySelectorAll('.room-selectable');
    checkboxes.forEach(cb => {
        cb.checked = master.checked;
    });
}
