var itemCounter = 1;

function addDamageItem() {
    itemCounter++;
    var container = document.getElementById('damageItemsContainer');
    var templateHtml = document.getElementById('damageItemTemplate').innerHTML;
    var newHtml = templateHtml.replace(/INDEX_DISPLAY/g, itemCounter).replace(/INDEX/g, itemCounter);
    var div = document.createElement('div');
    div.innerHTML = newHtml;
    container.appendChild(div.firstElementChild);
    renumberItems();
}

function removeDamageItem(elementId) {
    var el = document.getElementById(elementId);
    if (el) {
        el.remove();
        renumberItems();
    }
}

function renumberItems() {
    var container = document.getElementById('damageItemsContainer');
    var items = container.getElementsByClassName('damage-item');
    for (var i = 0; i < items.length; i++) {
        var titleEl = items[i].querySelector('.damage-item-title');
        if (titleEl) {
            titleEl.innerText = 'Mục ' + (i + 1);
        }
    }
}

function validateReportForm() {
    var selects = document.querySelectorAll('#damageItemsContainer .select-category');
    var selectedValues = [];
    for (var i = 0; i < selects.length; i++) {
        var val = selects[i].value;
        if (!val) {
            alert('Vui lòng chọn loại hư hại cho Mục ' + (i + 1) + '!');
            selects[i].focus();
            return false;
        }
        if (selectedValues.indexOf(val) !== -1) {
            alert('Bạn đang chọn trùng loại hư hại ở Mục ' + (i + 1) + '. Mỗi loại hư hại chỉ được chọn 1 lần trong biên bản!');
            selects[i].focus();
            return false;
        }
        selectedValues.push(val);
    }
    return confirm('Xác nhận lập biên bản với ' + selects.length + ' mục hư hại và khóa phòng để bảo trì?');
}
