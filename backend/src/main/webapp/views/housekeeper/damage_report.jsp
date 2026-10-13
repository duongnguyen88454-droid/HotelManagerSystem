<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Lập Biên Bản Báo Cáo Hư Hại - Buồng Phòng"/>
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeper/damage_report.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="tasks" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Biên Bản Báo Cáo Sự Cố Hư Hại Cơ Sở Vật Chất</h1>
                <p>Ghi nhận chi tiết đồ vật hư hại sau ca dọn phòng để chuyển đội kỹ thuật bảo trì và khóa phòng</p>
            </div>
            <div class="portal-header-right">
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="portal-btn portal-btn-secondary">
                    Quay Lại Danh Sách Phòng
                </a>
            </div>
        </header>

        <!-- Thông tin phòng xảy ra sự cố -->
        <div class="portal-card" style="padding: 20px 24px; margin-bottom: 20px;">
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px;">
                <div>
                    <div style="font-size: 12px; color: var(--portal-text-muted); font-weight: 700; text-transform: uppercase;">Phòng Xảy Ra Sự Cố</div>
                    <div style="font-size: 16px; font-weight: 700; color: #b91c1c; margin-top: 4px;">Phòng ${task.soPhong} (${task.tenLoaiPhong})</div>
                </div>
                <div>
                    <div style="font-size: 12px; color: var(--portal-text-muted); font-weight: 700; text-transform: uppercase;">Mã Nhiệm Vụ</div>
                    <div style="font-size: 15px; font-weight: 700; color: var(--portal-text-primary); margin-top: 4px;">#${task.maNhiemVu}</div>
                </div>
                <div>
                    <div style="font-size: 12px; color: var(--portal-text-muted); font-weight: 700; text-transform: uppercase;">Nhân Viên Phát Hiện</div>
                    <div style="font-size: 14px; font-weight: 600; color: var(--portal-text-primary); margin-top: 4px;">${sessionScope.CURRENT_USER.hoTen} (${sessionScope.CURRENT_USER.maDinhDanh})</div>
                </div>
                <div>
                    <div style="font-size: 12px; color: var(--portal-text-muted); font-weight: 700; text-transform: uppercase;">Thời Điểm Lập Biên Bản</div>
                    <div style="font-size: 14px; font-weight: 600; color: var(--portal-text-secondary); margin-top: 4px;"><%= new java.text.SimpleDateFormat("HH:mm dd/MM/yyyy").format(new java.util.Date()) %></div>
                </div>
            </div>
        </div>

        <!-- Form lập biên bản -->
        <form action="${pageContext.request.contextPath}/housekeeper/damage-report" method="POST" onsubmit="return validateReportForm();">
            <input type="hidden" name="taskId" value="${task.maNhiemVu}" />

            <div class="portal-card" style="padding: 24px; margin-bottom: 20px;">
                <h3 style="margin: 0 0 16px 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">
                    Danh Sách Các Mục Hư Hại Cần Bảo Trì
                </h3>

                <!-- Container chứa các dòng hư hại động -->
                <div id="damageItemsContainer">
                    <!-- Mục 1 mặc định -->
                    <div class="damage-item" id="damageItem_1" style="background: #f8fafc; border: 1px solid var(--portal-border); border-radius: 10px; padding: 18px; margin-bottom: 16px;">
                        <div class="damage-item-header" style="margin-bottom: 12px;">
                            <span class="damage-item-title" style="font-weight: 700; color: var(--portal-primary);">Mục 1</span>
                        </div>
                        <div class="form-group" style="margin-bottom: 14px;">
                            <label style="display: block; font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); margin-bottom: 6px;">Phân loại hư hại <span style="color: #dc2626;">*</span></label>
                            <select name="maLoaiHuHai" class="portal-input select-category" style="width: 100%;" required>
                                <option value="">-- Vui lòng chọn loại hư hại --</option>
                                <c:forEach items="${damageCategories}" var="cat">
                                    <option value="${cat.maLoaiHuHai}">${cat.tenLoaiHuHai}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group" style="margin-bottom: 0;">
                            <label style="display: block; font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); margin-bottom: 6px;">Mô tả cụ thể vị trí và tình trạng hư hỏng <span style="color: #dc2626;">*</span></label>
                            <textarea name="moTaChiTiet" class="portal-input" rows="2" style="width: 100%; box-sizing: border-box;" placeholder="Ví dụ: Gương treo bồn rửa mặt bị nứt đường chéo góc trái..." required></textarea>
                        </div>
                    </div>
                </div>

                <!-- Nút thêm mục hư hại -->
                <button type="button" class="portal-btn portal-btn-secondary" onclick="addDamageItem()">
                    + Thêm Mục Hư Hại Khác
                </button>
            </div>

            <!-- Ghi chú chung -->
            <div class="portal-card" style="padding: 24px; margin-bottom: 24px;">
                <h3 style="margin: 0 0 12px 0; font-size: 15px; font-weight: 700; color: var(--portal-text-primary);">
                    Ghi Chú Tổng Quan Cho Đội Bảo Trì (Tùy chọn)
                </h3>
                <textarea name="moTaChung" class="portal-input" rows="3" style="width: 100%; box-sizing: border-box;" placeholder="Nhập tóm tắt bối cảnh phát hiện hư hại sau khi khách rời đi..."></textarea>
                <div style="color: var(--portal-text-muted); font-size: 12.5px; margin-top: 10px;">
                    Lưu ý: Sau khi xác nhận, phòng <strong>${task.soPhong}</strong> sẽ tự động chuyển sang trạng thái <strong>Hư Hại (Damaged)</strong> và biên bản sự cố được gửi đến Quản Lý.
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 12px; margin-bottom: 40px;">
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="portal-btn portal-btn-secondary">Hủy Bỏ</a>
                <button type="submit" class="portal-btn portal-btn-danger">
                    Xác Nhận Lập Biên Bản & Khóa Phòng Bảo Trì
                </button>
            </div>
        </form>
    </main>
</div>

<!-- Template ẩn cho mục hư hại mới -->
<div id="damageItemTemplate" style="display: none;">
    <div class="damage-item" id="damageItem_INDEX" style="background: #f8fafc; border: 1px solid var(--portal-border); border-radius: 10px; padding: 18px; margin-bottom: 16px;">
        <div class="damage-item-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <span class="damage-item-title" style="font-weight: 700; color: var(--portal-primary);">Mục INDEX_DISPLAY</span>
            <button type="button" class="portal-btn portal-btn-danger" style="padding: 3px 8px; font-size: 11px;" onclick="removeDamageItem('damageItem_INDEX')">Xóa mục này</button>
        </div>
        <div class="form-group" style="margin-bottom: 14px;">
            <label style="display: block; font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); margin-bottom: 6px;">Phân loại hư hại <span style="color: #dc2626;">*</span></label>
            <select name="maLoaiHuHai" class="portal-input select-category" style="width: 100%;" required>
                <option value="">-- Vui lòng chọn loại hư hại --</option>
                <c:forEach items="${damageCategories}" var="cat">
                    <option value="${cat.maLoaiHuHai}">${cat.tenLoaiHuHai}</option>
                </c:forEach>
            </select>
        </div>
        <div class="form-group" style="margin-bottom: 0;">
            <label style="display: block; font-size: 13px; font-weight: 700; color: var(--portal-text-secondary); margin-bottom: 6px;">Mô tả cụ thể vị trí và tình trạng hư hỏng <span style="color: #dc2626;">*</span></label>
            <textarea name="moTaChiTiet" class="portal-input" rows="2" style="width: 100%; box-sizing: border-box;" placeholder="Ví dụ: Rèm cửa ban công bị rách tàn thuốc lá..." required></textarea>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/housekeeper/damage_report.js"></script>

<jsp:include page="/views/common/footer.jsp"/>
