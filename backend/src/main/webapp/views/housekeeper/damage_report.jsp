<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Lập Biên Bản Báo Cáo Hư Hại - Buồng Phòng"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<style>
    .report-container {
        max-width: 960px;
        margin: 28px auto;
        padding: 0 20px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        color: #1e293b;
    }
    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        color: #2563eb;
        text-decoration: none;
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 16px;
    }
    .back-link:hover {
        text-decoration: underline;
    }
    .page-header {
        margin-bottom: 24px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e2e8f0;
    }
    .page-title {
        font-size: 22px;
        font-weight: 700;
        color: #991b1b;
        margin: 0;
    }
    .page-subtitle {
        font-size: 13px;
        color: #64748b;
        margin-top: 4px;
    }
    .info-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 18px 20px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
        font-size: 14px;
    }
    .info-label {
        color: #64748b;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 4px;
    }
    .info-value {
        font-weight: 700;
        color: #0f172a;
    }
    .damage-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 24px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    .damage-item {
        background: #f8fafc;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        padding: 16px;
        margin-bottom: 16px;
        position: relative;
    }
    .damage-item-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 12px;
    }
    .damage-item-title {
        font-weight: 700;
        font-size: 14px;
        color: #334155;
    }
    .form-group {
        margin-bottom: 12px;
    }
    .form-label {
        display: block;
        font-size: 13px;
        font-weight: 600;
        color: #334155;
        margin-bottom: 6px;
    }
    .form-control {
        width: 100%;
        padding: 9px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 14px;
        color: #1e293b;
        box-sizing: border-box;
        background: #ffffff;
    }
    .form-control:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }
    .btn-add-item {
        padding: 8px 16px;
        background: #eff6ff;
        border: 1px dashed #3b82f6;
        color: #1d4ed8;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }
    .btn-add-item:hover {
        background: #dbeafe;
    }
    .btn-delete-item {
        padding: 4px 10px;
        background: #fee2e2;
        border: 1px solid #fecaca;
        color: #991b1b;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
    }
    .btn-delete-item:hover {
        background: #fca5a5;
    }
    .btn-submit {
        padding: 11px 24px;
        background: #dc2626;
        border: none;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        color: #ffffff;
        cursor: pointer;
        transition: background 0.15s ease-in-out;
    }
    .btn-submit:hover {
        background: #b91c1c;
    }
    .btn-cancel {
        padding: 11px 20px;
        background: #f1f5f9;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 14px;
        font-weight: 600;
        color: #475569;
        cursor: pointer;
        text-decoration: none;
        display: inline-block;
    }
    .btn-cancel:hover {
        background: #e2e8f0;
    }
</style>

<div class="report-container">
    <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="back-link">&larr; Quay lại danh sách phòng</a>

    <div class="page-header">
        <h1 class="page-title">Biên Bản Báo Cáo Sự Cố Hư Hại Cơ Sở Vật Chất</h1>
        <div class="page-subtitle">Ghi nhận chi tiết đồ vật hư hại sau ca dọn phòng để chuyển đội kỹ thuật bảo trì và khóa phòng</div>
    </div>

    <!-- Thông tin phòng xảy ra sự cố -->
    <div class="info-card">
        <div class="info-grid">
            <div>
                <div class="info-label">Phòng xảy ra sự cố</div>
                <div class="info-value" style="font-size: 16px; color: #b91c1c;">Phòng ${task.soPhong} (${task.tenLoaiPhong})</div>
            </div>
            <div>
                <div class="info-label">Mã nhiệm vụ</div>
                <div class="info-value">#${task.maNhiemVu}</div>
            </div>
            <div>
                <div class="info-label">Nhân viên phát hiện</div>
                <div class="info-value">${sessionScope.CURRENT_USER.hoTen} (${sessionScope.CURRENT_USER.maDinhDanh})</div>
            </div>
            <div>
                <div class="info-label">Thời điểm lập biên bản</div>
                <div class="info-value"><%= new java.text.SimpleDateFormat("HH:mm dd/MM/yyyy").format(new java.util.Date()) %></div>
            </div>
        </div>
    </div>

    <!-- Form lập biên bản -->
    <form action="${pageContext.request.contextPath}/housekeeper/damage-report" method="POST" onsubmit="return validateReportForm();">
        <input type="hidden" name="taskId" value="${task.maNhiemVu}" />

        <div class="damage-card">
            <h3 style="margin: 0 0 16px 0; font-size: 16px; font-weight: 700; color: #0f172a;">
                Danh Sách Các Mục Hư Hại Cần Bảo Trì
            </h3>

            <!-- Container chứa các dòng hư hại động -->
            <div id="damageItemsContainer">
                <!-- Mục 1 mặc định -->
                <div class="damage-item" id="damageItem_1">
                    <div class="damage-item-header">
                        <span class="damage-item-title">Mục 1</span>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phân loại hư hại <span style="color: #dc2626;">*</span></label>
                        <select name="maLoaiHuHai" class="form-control select-category" required>
                            <option value="">-- Vui lòng chọn loại hư hại --</option>
                            <c:forEach items="${damageCategories}" var="cat">
                                <option value="${cat.maLoaiHuHai}">${cat.tenLoaiHuHai}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                        <label class="form-label">Mô tả cụ thể vị trí và tình trạng hư hỏng <span style="color: #dc2626;">*</span></label>
                        <textarea name="moTaChiTiet" class="form-control" rows="2" placeholder="Ví dụ: Gương treo bồn rửa mặt bị nứt đường chéo góc trái..." required></textarea>
                    </div>
                </div>
            </div>

            <!-- Nút thêm mục hư hại -->
            <button type="button" class="btn-add-item" onclick="addDamageItem()">
                + Thêm Mục Hư Hại Khác
            </button>
        </div>

        <!-- Ghi chú chung -->
        <div class="damage-card">
            <h3 style="margin: 0 0 14px 0; font-size: 15px; font-weight: 700; color: #0f172a;">
                Ghi Chú Tổng Quan Cho Đội Bảo Trì (Tùy chọn)
            </h3>
            <textarea name="moTaChung" class="form-control" rows="3" placeholder="Nhập tóm tắt bối cảnh phát hiện hư hại sau khi khách rời đi..."></textarea>
            <div style="color: #64748b; font-size: 12px; margin-top: 8px;">
                * Lưu ý: Sau khi xác nhận, phòng <strong>${task.soPhong}</strong> sẽ tự động chuyển sang trạng thái <strong>Hư Hại (Damaged)</strong> và biên bản sự cố được gửi đến Quản Lý.
            </div>
        </div>

        <div style="display: flex; justify-content: flex-end; gap: 12px; margin-bottom: 50px;">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn-cancel">Hủy Bỏ</a>
            <button type="submit" class="btn-submit">
                Xác Nhận Lập Biên Bản &amp; Khóa Phòng Bảo Trì
            </button>
        </div>
    </form>
</div>

<!-- Template ẩn cho mục hư hại mới -->
<div id="damageItemTemplate" style="display: none;">
    <div class="damage-item" id="damageItem_INDEX">
        <div class="damage-item-header">
            <span class="damage-item-title">Mục INDEX_DISPLAY</span>
            <button type="button" class="btn-delete-item" onclick="removeDamageItem('damageItem_INDEX')">Xóa mục này</button>
        </div>
        <div class="form-group">
            <label class="form-label">Phân loại hư hại <span style="color: #dc2626;">*</span></label>
            <select name="maLoaiHuHai" class="form-control select-category" required>
                <option value="">-- Vui lòng chọn loại hư hại --</option>
                <c:forEach items="${damageCategories}" var="cat">
                    <option value="${cat.maLoaiHuHai}">${cat.tenLoaiHuHai}</option>
                </c:forEach>
            </select>
        </div>
        <div class="form-group" style="margin-bottom: 0;">
            <label class="form-label">Mô tả cụ thể vị trí và tình trạng hư hỏng <span style="color: #dc2626;">*</span></label>
            <textarea name="moTaChiTiet" class="form-control" rows="2" placeholder="Ví dụ: Rèm cửa ban công bị rách tàn thuốc lá..." required></textarea>
        </div>
    </div>
</div>

<script>
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
</script>

<jsp:include page="/views/common/footer.jsp"/>
