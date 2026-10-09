function applyFilters() {
    var keyword = document.getElementById("keywordFilter").value.trim().toLowerCase();

    // Lấy danh sách hạng phòng được tích
    var checkedTypes = [];
    document.querySelectorAll("input[name='typeCheckbox']:checked").forEach(function(cb) {
        checkedTypes.push(cb.value);
    });

    // Lấy danh sách mức giá được tích
    var checkedPrices = [];
    document.querySelectorAll("input[name='priceCheckbox']:checked").forEach(function(cb) {
        checkedPrices.push(cb.value);
    });

    // Lấy sức chứa
    var capacityEl = document.querySelector("input[name='capacityRadio']:checked");
    var minCapacity = capacityEl ? capacityEl.value : "all";

    var cards = document.querySelectorAll(".room-horizontal-card");
    var visibleCount = 0;

    cards.forEach(function(card) {
        var roomName = (card.getAttribute("data-room-name") || "").toLowerCase();
        var roomNumber = (card.getAttribute("data-room-number") || "").toLowerCase();
        var type = card.getAttribute("data-type") || "";
        var price = parseFloat(card.getAttribute("data-price") || 0);
        var capacity = parseInt(card.getAttribute("data-capacity") || 0, 10);

        var matchKeyword = (keyword === "" || roomName.indexOf(keyword) !== -1 || roomNumber.indexOf(keyword) !== -1);
        var matchType = (checkedTypes.length === 0 || checkedTypes.indexOf(type) !== -1);

        var matchPrice = true;
        if (checkedPrices.length > 0) {
            matchPrice = false;
            for (var i = 0; i < checkedPrices.length; i++) {
                var pKey = checkedPrices[i];
                if (pKey === "under_1m" && price < 1000000) matchPrice = true;
                if (pKey === "1m_2m" && price >= 1000000 && price <= 2000000) matchPrice = true;
                if (pKey === "2m_3m" && price > 2000000 && price <= 3000000) matchPrice = true;
                if (pKey === "over_3m" && price > 3000000) matchPrice = true;
            }
        }

        var matchCapacity = true;
        if (minCapacity === "1" && capacity < 1) matchCapacity = false;
        if (minCapacity === "2" && capacity < 2) matchCapacity = false;
        if (minCapacity === "3" && capacity < 3) matchCapacity = false;

        if (matchKeyword && matchType && matchPrice && matchCapacity) {
            card.style.display = "flex";
            visibleCount++;
        } else {
            card.style.display = "none";
        }
    });

    var countDisplay = document.getElementById("roomCountDisplay");
    if (countDisplay) {
        countDisplay.textContent = visibleCount;
    }

    var noMatch = document.getElementById("noMatchMessage");
    if (noMatch) {
        noMatch.style.display = (visibleCount === 0 && cards.length > 0) ? "block" : "none";
    }
}

function resetFilters() {
    var kw = document.getElementById("keywordFilter");
    if (kw) kw.value = "";
    document.querySelectorAll("input[name='typeCheckbox']").forEach(function(cb) { cb.checked = false; });
    document.querySelectorAll("input[name='priceCheckbox']").forEach(function(cb) { cb.checked = false; });
    var allCap = document.querySelector("input[name='capacityRadio'][value='all']");
    if (allCap) allCap.checked = true;
    applyFilters();
}

function sortRooms() {
    var sortVal = document.getElementById("sortSelect").value;
    var container = document.getElementById("roomContainer");
    if (!container) return;

    var cards = Array.from(container.querySelectorAll(".room-horizontal-card"));
    cards.sort(function(a, b) {
        var priceA = parseFloat(a.getAttribute("data-price") || 0);
        var priceB = parseFloat(b.getAttribute("data-price") || 0);
        var capA = parseInt(a.getAttribute("data-capacity") || 0, 10);
        var capB = parseInt(b.getAttribute("data-capacity") || 0, 10);

        if (sortVal === "price_asc") return priceA - priceB;
        if (sortVal === "price_desc") return priceB - priceA;
        if (sortVal === "capacity_desc") return capB - capA;
        return 0;
    });

    cards.forEach(function(card) {
        container.appendChild(card);
    });
}
