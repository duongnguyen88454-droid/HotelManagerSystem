function getBaseRoomPrice() {
    return window.BASE_ROOM_PRICE || 0;
}

function formatVND(amount) {
    return new Intl.NumberFormat('vi-VN').format(Math.round(amount)) + ' đ';
}

function toggleService(target, optPrice) {
    var svcId, unitPrice, cb;
    if (typeof target === 'object' && target !== null && target.getAttribute) {
        cb = target;
        svcId = cb.getAttribute("data-service-id") || cb.value;
        unitPrice = parseFloat(cb.getAttribute("data-unit-price") || 0);
    } else {
        svcId = target;
        unitPrice = parseFloat(optPrice || 0);
        cb = document.getElementById("cb_" + svcId);
    }

    var qtyInput = document.getElementById("qty_" + svcId);
    if (cb && qtyInput) {
        qtyInput.disabled = !cb.checked;
        if (!cb.checked) {
            qtyInput.value = 1;
        }
    }
    updateServiceSubtotal(target, optPrice);
}

function updateServiceSubtotal(target, optPrice) {
    var svcId, unitPrice;
    if (typeof target === 'object' && target !== null && target.getAttribute) {
        svcId = target.getAttribute("data-service-id") || target.value;
        unitPrice = parseFloat(target.getAttribute("data-unit-price") || 0);
    } else {
        svcId = target;
        unitPrice = parseFloat(optPrice || 0);
    }

    var cb = document.getElementById("cb_" + svcId);
    var qtyInput = document.getElementById("qty_" + svcId);
    var subtotalEl = document.getElementById("subtotal_" + svcId);

    var subtotal = 0;
    if (cb && cb.checked && qtyInput) {
        var qty = parseInt(qtyInput.value, 10);
        if (isNaN(qty) || qty < 1) qty = 1;
        subtotal = qty * unitPrice;
    }

    if (subtotalEl) {
        subtotalEl.textContent = formatVND(subtotal);
    }

    calculateTotal();
}

function calculateTotal() {
    var totalSvc = 0;
    var checkboxes = document.querySelectorAll("input[type='checkbox'][name^='service_']:checked");

    checkboxes.forEach(function (cb) {
        var svcId = cb.value;
        var qtyInput = document.getElementById("qty_" + svcId);
        var qty = qtyInput ? parseInt(qtyInput.value, 10) : 1;
        if (isNaN(qty) || qty < 1) qty = 1;

        var subtotalEl = document.getElementById("subtotal_" + svcId);
        if (subtotalEl) {
            var rawText = subtotalEl.textContent.replace(/[^0-9]/g, '');
            var subVal = parseFloat(rawText);
            if (!isNaN(subVal)) {
                totalSvc += subVal;
            }
        }
    });

    var displaySvc = document.getElementById("displayServiceTotal");
    if (displaySvc) displaySvc.textContent = formatVND(totalSvc);

    var grandTotal = getBaseRoomPrice() + totalSvc;
    var displayGrand = document.getElementById("displayGrandTotal");
    if (displayGrand) displayGrand.textContent = formatVND(grandTotal);
}

function handleFormSubmit(event) {
    event.preventDefault();
    var form = document.getElementById("addRoomForm");
    if (!form) return;

    var btn = document.getElementById("submitBtn");
    if (btn) {
        btn.disabled = true;
        btn.textContent = "Đang xử lý...";
    }

    var formData = new FormData(form);
    var searchParams = new URLSearchParams(formData);

    fetch(form.action, {
        method: "POST",
        body: searchParams,
        headers: {
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
            "X-Requested-With": "XMLHttpRequest"
        }
    })
        .then(function (res) {
            return res.json();
        })
        .then(function (data) {
            if (btn) {
                btn.disabled = false;
                btn.textContent = "Thêm Vào Booking";
            }

            if (data.success) {
                // Cập nhật dữ liệu vào popup modal
                document.getElementById("modalRoomName").textContent = data.soPhong + " (" + data.tenLoaiPhong + ")";
                document.getElementById("modalPeriod").textContent = data.checkIn + " đến " + data.checkOut + " (" + data.soDem + " đêm)";
                document.getElementById("modalRoomPrice").textContent = formatVND(data.roomPrice);
                document.getElementById("modalServicePrice").textContent = formatVND(data.serviceTotal);
                document.getElementById("modalRoomTotal").textContent = formatVND(data.roomTotal);
                document.getElementById("modalCartRooms").textContent = data.cartTotalRooms + " phòng";
                document.getElementById("modalGrandTotal").textContent = formatVND(data.cartGrandTotal);

                // Nút quay lại đặt tiếp dẫn về kết quả tìm kiếm
                var contextPath = window.CONTEXT_PATH || '';
                var continueUrl = contextPath + "/customer/search-rooms?checkIn=" + encodeURIComponent(data.checkIn) + "&checkOut=" + encodeURIComponent(data.checkOut);
                document.getElementById("modalContinueBtn").href = continueUrl;

                // Hiển thị modal
                var modal = document.getElementById("bookingPopupModal");
                if (modal) modal.style.display = "flex";
            } else {
                alert(data.message || "Có lỗi xảy ra khi thêm phòng!");
            }
        })
        .catch(function (err) {
            if (btn) {
                btn.disabled = false;
                btn.textContent = "Thêm Vào Booking";
            }
            // Fallback: nếu lỗi fetch thì submit thông thường
            form.submit();
        });
}

function closePopupModal() {
    var modal = document.getElementById("bookingPopupModal");
    if (modal) modal.style.display = "none";
}
