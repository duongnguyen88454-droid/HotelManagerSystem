<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Lập Biên Bản Báo Cáo Hư Hại - Buồng Phòng" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="housekeeper/damage_report.css" />
</jsp:include>

<div class="portal-wrapper portal-layout">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="tasks" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <div class="page-header">
            <div class="page-header-main">
                <h1 class="page-title">Biên Bản Báo Cáo Sự Cố Hư Hại Cơ Sở Vật Chất</h1>
                <p class="page-subtitle">Ghi nhận chi tiết đồ vật hư hại sau ca dọn phòng để chuyển đội kỹ thuật bảo trì và khóa phòng</p>
            </div>
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn btn-secondary">
                    Quay Lại Danh Sách Phòng
                </a>
            </div>
        </div>

        <!-- Thông tin phòng xảy ra sự cố -->
        <div class="card mb-5">
            <div class="card-body">
                <div class="detail-grid">
                    <div class="detail-item">
                        <span class="detail-label">Phòng Xảy Ra Sự Cố</span>
                        <span class="detail-value text-danger fw-bold text-lg">${task.soPhong} (${task.tenLoaiPhong})</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Mã Nhiệm Vụ</span>
                        <span class="detail-value mono fw-bold">#${task.maNhiemVu}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Nhân Viên Phát Hiện</span>
                        <span class="detail-value fw-semibold">${sessionScope.CURRENT_USER.hoTen} (${sessionScope.CURRENT_USER.maDinhDanh})</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">Thời Điểm Lập Biên Bản</span>
                        <span class="detail-value mono"><%= new java.text.SimpleDateFormat("HH:mm dd/MM/yyyy").format(new java.util.Date()) %></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Form lập biên bản -->
        <form action="${pageContext.request.contextPath}/housekeeper/damage-report" method="POST"
            onsubmit="return validateReportForm();">
            <input type="hidden" name="taskId" value="${task.maNhiemVu}" />

            <div class="card mb-5">
                <div class="card-header">
                    <h2 class="card-title">Danh Sách Các Mục Hư Hại Cần Bảo Trì</h2>
                </div>
                <div class="card-body">
                    <!-- Container chứa các dòng hư hại động -->
                    <div id="damageItemsContainer">
                        <!-- Mục 1 mặc định -->
                        <div class="damage-item card mb-4" id="damageItem_1" style="background: var(--color-surface-alt);">
                            <div class="card-body">
                                <div class="damage-item-header mb-3">
                                    <span class="damage-item-title fw-bold text-primary">Mục 1</span>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Phân loại hư hại <span class="required">*</span></label>
                                    <select name="maLoaiHuHai" class="form-control select-category" required>
                                        <option value="">-- Vui lòng chọn loại hư hại --</option>
                                        <c:forEach items="${damageCategories}" var="cat">
                                            <option value="${cat.maLoaiHuHai}">${cat.tenLoaiHuHai}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="form-group mb-0">
                                    <label class="form-label">Mô tả cụ thể vị trí và tình trạng hư hỏng <span class="required">*</span></label>
                                    <textarea name="moTaChiTiet" class="form-control" rows="2" required></textarea>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Nút thêm mục hư hại -->
                    <button type="button" class="btn btn-secondary" onclick="addDamageItem()">
                        + Thêm Mục Hư Hại Khác
                    </button>
                </div>
            </div>

            <!-- Ghi chú chung -->
            <div class="card mb-6">
                <div class="card-header">
                    <h2 class="card-title">Ghi Chú Tổng Quan Cho Đội Bảo Trì (Tùy chọn)</h2>
                </div>
                <div class="card-body">
                    <textarea name="moTaChung" class="form-control" rows="3"
                        placeholder="Nhập tóm tắt bối cảnh phát hiện hư hại sau khi khách rời đi..."></textarea>
                    <div class="text-xs text-muted mt-2">
                        Lưu ý: Sau khi xác nhận, <strong>${task.soPhong}</strong> sẽ tự động chuyển sang trạng thái <strong>Hư Hại (Damaged)</strong> và biên bản sự cố được gửi đến Quản Lý.
                    </div>
                </div>
            </div>

            <div class="form-actions mb-8">
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn btn-secondary">Hủy Bỏ</a>
                <button type="submit" class="btn btn-danger btn-lg">
                    Xác Nhận Lập Biên Bản &amp; Khóa Phòng Bảo Trì
                </button>
            </div>
        </form>
    </main>
</div>

<!-- Template ẩn cho mục hư hại mới -->
<div id="damageItemTemplate" class="is-hidden">
    <div class="damage-item card mb-4" id="damageItem_INDEX" style="background: var(--color-surface-alt);">
        <div class="card-body">
            <div class="damage-item-header flex justify-between items-center mb-3">
                <span class="damage-item-title fw-bold text-primary">Mục INDEX_DISPLAY</span>
                <button type="button" class="btn btn-danger btn-sm" onclick="removeDamageItem('damageItem_INDEX')">Xóa mục này</button>
            </div>
            <div class="form-group">
                <label class="form-label">Phân loại hư hại <span class="required">*</span></label>
                <select name="maLoaiHuHai" class="form-control select-category" required>
                    <option value="">-- Vui lòng chọn loại hư hại --</option>
                    <c:forEach items="${damageCategories}" var="cat">
                        <option value="${cat.maLoaiHuHai}">${cat.tenLoaiHuHai}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group mb-0">
                <label class="form-label">Mô tả cụ thể vị trí và tình trạng hư hỏng <span class="required">*</span></label>
                <textarea name="moTaChiTiet" class="form-control" rows="2"
                    placeholder="Ví dụ: Rèm cửa ban công bị rách tàn thuốc lá..." required></textarea>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/housekeeper/damage_report.js"></script>

<jsp:include page="/views/common/footer.jsp" />