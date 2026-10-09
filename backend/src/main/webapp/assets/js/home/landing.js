/**
 * Grand Horizon Hotel & Resort - Landing Page Logic
 * Xử lý ngày nhận/trả phòng và ràng buộc tìm kiếm phòng
 */
document.addEventListener('DOMContentLoaded', function () {
    const checkInInput = document.getElementById('checkInInput');
    const checkOutInput = document.getElementById('checkOutInput');

    if (!checkInInput || !checkOutInput) {
        return;
    }

    const today = new Date();
    const tomorrow = new Date();
    tomorrow.setDate(today.getDate() + 1);

    const formatDate = function (d) {
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    };

    const todayStr = formatDate(today);
    const tomorrowStr = formatDate(tomorrow);

    // Gán ngày mặc định nếu chưa có giá trị
    if (!checkInInput.value) {
        checkInInput.value = todayStr;
    }
    checkInInput.min = todayStr;

    if (!checkOutInput.value) {
        checkOutInput.value = tomorrowStr;
    }
    checkOutInput.min = tomorrowStr;

    // Khi thay đổi ngày nhận phòng, đảm bảo ngày trả phòng ít nhất sau 1 ngày
    checkInInput.addEventListener('change', function () {
        if (!this.value) return;

        const selectedIn = new Date(this.value);
        const minOut = new Date(selectedIn);
        minOut.setDate(selectedIn.getDate() + 1);

        const minOutStr = formatDate(minOut);
        checkOutInput.min = minOutStr;

        if (checkOutInput.value && checkOutInput.value <= this.value) {
            checkOutInput.value = minOutStr;
        }
    });
});
