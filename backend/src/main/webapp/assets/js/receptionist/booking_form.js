function calculateNights() {
    const dIn = new Date(document.getElementById('dateCheckIn').value);
    const dOut = new Date(document.getElementById('dateCheckOut').value);
    const diffTime = dOut - dIn;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays > 0 ? diffDays : 1;
}

function onDateFilterChange() {
    const dIn = document.getElementById('dateCheckIn').value;
    const dOut = document.getElementById('dateCheckOut').value;
    if (dIn && dOut && dIn < dOut) {
        const contextPath = window.CONTEXT_PATH || '';
        window.location.href = contextPath + '/receptionist/booking?checkIn=' + encodeURIComponent(dIn) + '&checkOut=' + encodeURIComponent(dOut);
    }
}

function onRoomCheckboxChange() {
    const nights = calculateNights();
    let totalRoomCost = 0;
    let selectedCount = 0;

    document.querySelectorAll('input[name="selectedRooms"]').forEach(chk => {
        const price = parseFloat(chk.getAttribute('data-price')) || 0;
        const subtotalSpan = document.getElementById('roomSubtotal_' + chk.value);
        if (subtotalSpan) {
            subtotalSpan.innerText = formatVnd(price * nights);
        }

        if (chk.checked) {
            selectedCount++;
            totalRoomCost += price * nights;
        }
    });

    document.getElementById('nightsCounter').innerText = nights + ' đêm';
    document.getElementById('step1SelectedCount').innerText = selectedCount;
    document.getElementById('step1TotalRoomCost').innerText = formatVnd(totalRoomCost);
}

function goToStep(stepNumber) {
    if (stepNumber === 2) {
        const selectedCheckboxes = document.querySelectorAll('input[name="selectedRooms"]:checked');
        if (selectedCheckboxes.length === 0) {
            alert('[Cảnh báo] Vui lòng tích chọn ít nhất một phòng trống để tiếp tục!');
            return;
        }

        // Đồng bộ danh sách card dịch vụ ở Bước 2
        selectedCheckboxes.forEach(chk => {
            const card = document.getElementById('roomSvcCard_' + chk.value);
            if (card) {
                card.style.display = 'block';
            }
        });

        // Ẩn các phòng không được chọn
        document.querySelectorAll('input[name="selectedRooms"]:not(:checked)').forEach(chk => {
            const card = document.getElementById('roomSvcCard_' + chk.value);
            if (card) {
                card.style.display = 'none';
                card.querySelectorAll('input[type="number"]').forEach(inp => inp.value = 0);
            }
        });

        document.getElementById('step1Container').style.display = 'none';
        document.getElementById('step2Container').style.display = 'block';

        document.getElementById('stepNav1').className = 'step-item completed';
        document.getElementById('stepNav2').className = 'step-item active';

        recalculateStep2Bill();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
        document.getElementById('step1Container').style.display = 'block';
        document.getElementById('step2Container').style.display = 'none';

        document.getElementById('stepNav1').className = 'step-item active';
        document.getElementById('stepNav2').className = 'step-item';

        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

function changeQty(roomId, svcId, delta) {
    const inp = document.getElementById('qty_' + roomId + '_' + svcId);
    if (inp) {
        let val = parseInt(inp.value) || 0;
        val += delta;
        if (val < 0) val = 0;
        if (val > 20) val = 20;
        inp.value = val;
        recalculateStep2Bill();
    }
}

function recalculateStep2Bill() {
    const nights = calculateNights();
    let totalRoomCost = 0;
    let totalSvcCost = 0;
    let selectedCount = 0;

    document.querySelectorAll('input[name="selectedRooms"]:checked').forEach(chk => {
        selectedCount++;
        const price = parseFloat(chk.getAttribute('data-price')) || 0;
        totalRoomCost += price * nights;

        const card = document.getElementById('roomSvcCard_' + chk.value);
        if (card) {
            card.querySelectorAll('input[type="number"]').forEach(inp => {
                const qty = parseInt(inp.value) || 0;
                const svcPrice = parseFloat(inp.getAttribute('data-price')) || 0;
                totalSvcCost += qty * svcPrice;
            });
        }
    });

    document.getElementById('step2SummaryRoomCount').innerText = selectedCount + ' phòng (' + nights + ' đêm)';
    document.getElementById('step2SumRoomCost').innerText = formatVnd(totalRoomCost);
    document.getElementById('step2SumServiceCost').innerText = formatVnd(totalSvcCost);
    document.getElementById('step2SumTotalCost').innerText = formatVnd(totalRoomCost + totalSvcCost);
}

function formatVnd(num) {
    return num.toLocaleString('vi-VN') + ' VNĐ';
}

window.addEventListener('DOMContentLoaded', function() {
    onRoomCheckboxChange();
});
