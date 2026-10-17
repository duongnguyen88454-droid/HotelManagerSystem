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
    const guests = document.getElementById('filterGuests') ? document.getElementById('filterGuests').value : '';
    const roomType = document.getElementById('filterRoomType') ? document.getElementById('filterRoomType').value : '';
    if (dIn && dOut && dIn < dOut) {
        const contextPath = window.CONTEXT_PATH || '';
        let url = contextPath + '/receptionist/booking?checkIn=' + encodeURIComponent(dIn) + '&checkOut=' + encodeURIComponent(dOut);
        if (guests) {
            url += '&guests=' + encodeURIComponent(guests);
        }
        if (roomType && roomType !== 'ALL') {
            url += '&roomType=' + encodeURIComponent(roomType);
        }
        window.location.href = url;
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
    const step1 = document.getElementById('step1Container');
    const step2 = document.getElementById('step2Container');

    if (stepNumber === 2) {
        const selectedCheckboxes = document.querySelectorAll('input[name="selectedRooms"]:checked');
        if (selectedCheckboxes.length === 0) {
            alert('Vui lòng chọn ít nhất một phòng trống để tiếp tục!');
            return;
        }

        // Đồng bộ danh sách card dịch vụ ở Bước 2
        selectedCheckboxes.forEach(chk => {
            const card = document.getElementById('roomSvcCard_' + chk.value);
            if (card) {
                card.classList.remove('hidden', 'is-hidden');
                card.style.setProperty('display', 'block', 'important');
            }
        });

        // Ẩn các phòng không được chọn
        document.querySelectorAll('input[name="selectedRooms"]:not(:checked)').forEach(chk => {
            const card = document.getElementById('roomSvcCard_' + chk.value);
            if (card) {
                card.style.setProperty('display', 'none', 'important');
                card.querySelectorAll('input[type="number"]').forEach(inp => inp.value = 0);
            }
        });

        step1.style.setProperty('display', 'none', 'important');
        step2.classList.remove('hidden', 'is-hidden');
        step2.style.setProperty('display', 'block', 'important');

        document.getElementById('stepNav1').className = 'step-item completed';
        document.getElementById('stepNav2').className = 'step-item active';

        recalculateStep2Bill();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
        step1.classList.remove('hidden', 'is-hidden');
        step1.style.setProperty('display', 'block', 'important');
        step2.style.setProperty('display', 'none', 'important');

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
    let totalDeposit = 0;
    let selectedCount = 0;

    document.querySelectorAll('input[name="selectedRooms"]:checked').forEach(chk => {
        selectedCount++;
        const price = parseFloat(chk.getAttribute('data-price')) || 0;
        const depPct = parseFloat(chk.getAttribute('data-depositpercent')) || 0;
        const roomTotal = price * nights;
        totalRoomCost += roomTotal;
        totalDeposit += (roomTotal * depPct) / 100.0;

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
    const depElem = document.getElementById('step2SumDepositCost');
    if (depElem) {
        depElem.innerText = formatVnd(totalDeposit);
    }
}

function formatVnd(num) {
    return num.toLocaleString('vi-VN') + ' VNĐ';
}

window.addEventListener('DOMContentLoaded', function() {
    onRoomCheckboxChange();
});
