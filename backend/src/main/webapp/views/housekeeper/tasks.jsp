<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Buồng Phòng - Danh Sách Nhiệm Vụ"/>
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeper/tasks.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="tasks" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Bàn Làm Việc Buồng Phòng</h1>
                <p>Quản lý vệ sinh phòng, cập nhật phòng sạch và lập biên bản sự cố hư hại</p>
            </div>
            <div class="portal-header-right">
                <span class="portal-date-pill">Ca trực: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Thanh chuyển Tab lọc trạng thái nhiệm vụ -->
        <div class="portal-tabs">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=TatCa"
               class="portal-tab-item ${empty currentStatus || currentStatus == 'TatCa' ? 'active' : ''}">Tất Cả</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=MyActive"
               class="portal-tab-item ${currentStatus == 'MyActive' ? 'active' : ''}">Phòng Tôi Đang Dọn</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=MyHistory"
               class="portal-tab-item ${currentStatus == 'MyHistory' ? 'active' : ''}">Lịch Sử Của Tôi</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=InProgress"
               class="portal-tab-item ${currentStatus == 'InProgress' || currentStatus == 'DangDon' ? 'active' : ''}">Đang Dọn</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=Completed"
               class="portal-tab-item ${currentStatus == 'Completed' || currentStatus == 'DaHoanThanh' ? 'active' : ''}">Đã Hoàn Thành</a>
        </div>

        <!-- Thông báo kết quả thao tác -->
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="portal-alert portal-alert-success">
                ${sessionScope.flashSuccess}
            </div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="portal-alert portal-alert-danger">
                ${sessionScope.flashError}
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>

        <!-- Banner cảnh báo nếu đang có 1 phòng dọn dở -->
        <c:if test="${not empty currentActiveTask}">
            <div class="portal-alert portal-alert-info">
                Bạn đang tiến hành dọn dẹp <strong>Phòng ${currentActiveTask.soPhong}</strong>. Vui lòng bấm <strong>Hoàn Tất Dọn Phòng</strong> để hoàn tất trước khi nhận thêm phòng mới.
            </div>
        </c:if>

        <!-- Bảng danh sách nhiệm vụ dọn phòng -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--portal-border);">
                <h3 class="portal-card-title">Danh Sách Nhiệm Vụ Buồng Phòng</h3>
            </div>

            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th style="width: 24%;">Thông Tin Phòng</th>
                            <th style="width: 18%; text-align: center;">Tình Trạng Phòng</th>
                            <th style="width: 20%;">Nhân Viên Đảm Nhận</th>
                            <th style="width: 18%;">Mốc Thời Gian</th>
                            <th style="width: 20%; text-align: center;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty taskList}">
                                <c:forEach var="task" items="${taskList}">
                                    <tr>
                                        <!-- Cột 1: Thông tin phòng -->
                                        <td>
                                            <div style="font-weight: 700; color: var(--portal-text-primary); font-size: 15px;">Phòng ${task.soPhong}</div>
                                            <div style="color: var(--portal-text-secondary); font-size: 13px;">${task.tenLoaiPhong}</div>
                                            <div style="color: var(--portal-text-muted); font-size: 11.5px; margin-top: 2px;">Mã NV: #${task.maNhiemVu}</div>
                                        </td>

                                        <!-- Cột 2: Tình trạng phòng -->
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${task.trangThaiPhong == 'Dirty'}">
                                                    <span class="badge-pill badge-cleaning">Chưa Dọn (Dirty)</span>
                                                </c:when>
                                                <c:when test="${task.trangThaiPhong == 'Cleaning'}">
                                                    <span class="badge-pill badge-partial">Đang Dọn (Cleaning)</span>
                                                </c:when>
                                                <c:when test="${task.trangThaiPhong == 'Available'}">
                                                    <span class="badge-pill badge-available">Đã Sạch (Available)</span>
                                                </c:when>
                                                <c:when test="${task.trangThaiPhong == 'Damaged'}">
                                                    <span class="badge-pill badge-damaged">Hư Hại (Damaged)</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-damaged">${task.trangThaiPhong}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Cột 3: Nhân viên đảm nhận -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty task.tenNV}">
                                                    <div style="font-weight: 600; color: var(--portal-text-primary);">
                                                        ${task.tenNV}
                                                        <c:if test="${task.maNV == sessionScope.CURRENT_USER.maDinhDanh || task.maNV == sessionScope.CURRENT_USER.maTaiKhoan}">
                                                            <span class="badge-pill badge-available" style="padding: 1px 6px; font-size: 11px;">Bạn</span>
                                                        </c:if>
                                                    </div>
                                                    <div style="color: var(--portal-text-muted); font-size: 11.5px;">Mã: ${task.maNV}</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--portal-text-muted); font-style: italic;">Chưa phân công</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Cột 4: Mốc thời gian -->
                                        <td style="font-size: 13px; color: var(--portal-text-secondary);">
                                            <c:choose>
                                                <c:when test="${not empty task.thoiGianBatDau}">
                                                    <div>Bắt đầu:</div>
                                                    <strong><fmt:formatDate value="${task.thoiGianBatDau}" pattern="HH:mm dd/MM" /></strong>
                                                </c:when>
                                                <c:when test="${not empty task.thoiGianNhan}">
                                                    <div>Nhận phòng:</div>
                                                    <strong><fmt:formatDate value="${task.thoiGianNhan}" pattern="HH:mm dd/MM" /></strong>
                                                </c:when>
                                                <c:otherwise>-</c:otherwise>
                                            </c:choose>
                                        </td>

                                        <!-- Cột 5: Thao tác (Hành động) -->
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${task.trangThaiNhiemVu == 'ChoXuLy' || task.trangThaiNhiemVu == 'Pending' || task.trangThaiPhong == 'Dirty'}">
                                                    <c:choose>
                                                        <c:when test="${not empty currentActiveTask}">
                                                            <button type="button" class="portal-btn portal-btn-secondary" disabled style="opacity: 0.6; cursor: not-allowed; padding: 6px 12px; font-size: 12px;">
                                                                Nhận Việc & Dọn
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form action="${pageContext.request.contextPath}/housekeeper/task-action" method="POST" style="display: inline;">
                                                                <input type="hidden" name="action" value="start" />
                                                                <input type="hidden" name="maNhiemVu" value="${task.maNhiemVu}" />
                                                                <button type="submit" class="portal-btn portal-btn-primary" style="padding: 6px 12px; font-size: 12px;">
                                                                    Nhận Việc & Dọn
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:when test="${task.trangThaiNhiemVu == 'DangDon' || task.trangThaiNhiemVu == 'InProgress' || task.trangThaiPhong == 'Cleaning'}">
                                                    <c:choose>
                                                        <c:when test="${empty task.maNV || task.maNV == sessionScope.CURRENT_USER.maDinhDanh || task.maNV == sessionScope.CURRENT_USER.maTaiKhoan}">
                                                            <button type="button" class="portal-btn portal-btn-success" style="padding: 6px 12px; font-size: 12px;"
                                                                    onclick="openInspectionModal('${task.maNhiemVu}', '${task.soPhong}', '${task.tenLoaiPhong}')">
                                                                Hoàn Tất Dọn Phòng
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: var(--portal-text-muted); font-size: 12px; font-style: italic;">
                                                                Đang được dọn bởi nhân viên khác
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:when test="${task.trangThaiNhiemVu == 'DaHoanThanh' || task.trangThaiNhiemVu == 'Completed'}">
                                                    <c:choose>
                                                        <c:when test="${task.ketQua == 'CoThietHai'}">
                                                            <span style="color: #b91c1c; font-weight: 700; font-size: 13px;">
                                                                Có Báo Cáo Hư Hại
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #15803d; font-weight: 700; font-size: 13px;">
                                                                Hoàn Tất Sạch Sẽ
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--portal-text-muted);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="5" style="padding: 36px; text-align: center; color: var(--portal-text-muted);">
                                        <div style="font-weight: 700; font-size: 15px; color: var(--portal-text-secondary);">Không Có Nhiệm Vụ Nào Cần Xử Lý</div>
                                        <div style="font-size: 13px; margin-top: 4px;">Hiện tại tất cả các phòng trong danh mục này đều đã hoàn tất.</div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- Modal Nghiệm thu hoàn tất dọn phòng (F5.2 & F5.3) -->
<div id="inspectionModal" class="portal-modal-backdrop" style="display: none; align-items: center; justify-content: center;">
    <div class="portal-modal-card" style="max-width: 520px;">
        <div style="background: #f8fafc; padding: 16px 20px; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">Nghiệm Thu Hoàn Tất Dọn Phòng</h3>
            <button type="button" onclick="closeInspectionModal()" style="background: none; border: none; font-size: 18px; cursor: pointer; color: var(--portal-text-muted); font-weight: 700;">Đóng</button>
        </div>
        <form action="${pageContext.request.contextPath}/housekeeper/task-action" method="POST" style="margin: 0; padding: 24px;">
            <input type="hidden" name="action" value="complete" />
            <input type="hidden" id="modalTaskId" name="maNhiemVu" value="" />

            <div style="background: #f8fafc; border: 1px solid var(--portal-border); border-radius: 8px; padding: 14px; margin-bottom: 18px;">
                <div style="font-weight: 700; font-size: 16px; color: var(--portal-text-primary);" id="modalRoomInfo">Phòng ---</div>
                <div style="color: var(--portal-text-muted); font-size: 13px; margin-top: 4px;" id="modalTaskIdText">Mã nhiệm vụ: ---</div>
                <div style="color: var(--portal-text-secondary); font-size: 13px; margin-top: 4px;">Người kiểm tra: <strong>${sessionScope.CURRENT_USER.hoTen}</strong></div>
            </div>

            <div style="margin-bottom: 16px;">
                <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; padding: 12px; background: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px;">
                    <input type="checkbox" id="modalHasDamage" name="hasDamage" value="true" onchange="toggleDamageNotice(this.checked)" style="width: 18px; height: 18px; margin-top: 2px; cursor: pointer;" />
                    <div>
                        <span style="font-weight: 700; color: #92400e; font-size: 14px;">Phát hiện cơ sở vật chất / thiết bị hư hại</span>
                        <div style="color: #78350f; font-size: 12px; margin-top: 2px;">Tích chọn nếu phòng có đồ đạc bị hỏng hóc, nứt vỡ hoặc cần sửa chữa bảo trì.</div>
                    </div>
                </label>
            </div>

            <div id="cleanNoticeBox" style="font-size: 13px; color: #166534; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 12px; border-radius: 8px; margin-bottom: 20px;">
                Phòng đạt chuẩn vệ sinh sạch sẽ. Bấm xác nhận để mở phòng sang trạng thái <strong>Sẵn sàng (Available)</strong> đón khách.
            </div>

            <div id="damageNoticeBox" style="display: none; font-size: 13px; color: #991b1b; background: #fef2f2; border: 1px solid #fecaca; padding: 12px; border-radius: 8px; margin-bottom: 20px;">
                Hệ thống sẽ chuyển bạn sang <strong>Màn hình Lập Biên Bản Hư Hại</strong> để điền các mục hư hỏng chi tiết và khóa phòng bảo trì.
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid var(--portal-border); padding-top: 16px;">
                <button type="button" onclick="closeInspectionModal()" class="portal-btn portal-btn-secondary">
                    Hủy Bỏ
                </button>
                <button type="submit" id="btnSubmitModal" class="portal-btn portal-btn-success">
                    Xác Nhận Dọn Xong Phòng Sạch
                </button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/housekeeper/tasks.js"></script>

<jsp:include page="/views/common/footer.jsp"/>
