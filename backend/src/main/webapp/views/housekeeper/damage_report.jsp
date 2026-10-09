<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Lập Biên Bản Báo Cáo Hư Hại - Buồng Phòng"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeper/damage_report.css">

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

<script src="${pageContext.request.contextPath}/assets/js/housekeeper/damage_report.js"></script>

<jsp:include page="/views/common/footer.jsp"/>
