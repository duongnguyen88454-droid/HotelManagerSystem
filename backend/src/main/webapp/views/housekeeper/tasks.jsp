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

        <!-- Thanh chuyển Tab rút gọn & bổ sung Lịch Sử Biên Bản Hư Hại -->
        <div class="portal-tabs">
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=TatCa"
               class="portal-tab-item ${empty currentStatus || currentStatus == 'TatCa' ? 'active' : ''}">Tất Cả</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=MyActive"
               class="portal-tab-item ${currentStatus == 'MyActive' ? 'active' : ''}">Phòng Tôi Đang Dọn</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=MyHistory"
               class="portal-tab-item ${currentStatus == 'MyHistory' ? 'active' : ''}">Lịch Sử Của Tôi</a>
            <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=DamageHistory"
               class="portal-tab-item ${currentStatus == 'DamageHistory' ? 'active' : ''}">Lịch Sử Sự Cố Hư Hại</a>
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

        <c:choose>
            <%-- ========================================================================= --%>
            <%-- TAB 4: LỊCH SỬ BIÊN BẢN SỰ CỐ HƯ HẠI                                      --%>
            <%-- ========================================================================= --%>
            <c:when test="${currentStatus == 'DamageHistory'}">
                <div class="portal-card" style="padding: 0; overflow: hidden;">
                    <div style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                        <h3 class="portal-card-title" style="margin: 0;">Lịch Sử Biên Bản Sự Cố Hư Hại Thiết Bị</h3>
                        <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                            <input type="text" id="damageSearchInput" class="portal-input" placeholder="Tìm số phòng, mã BB, loại hư hại..." style="width: 260px;" oninput="applyDamageFilters()">
                            <select id="damageStatusFilter" class="portal-input" style="width: 180px;" onchange="applyDamageFilters()">
                                <option value="">-- Tất Cả Trạng Thái --</option>
                                <option value="Pending">Chờ Bảo Trì</option>
                                <option value="Confirmed">Đang Khắc Phục</option>
                                <option value="Resolved">Đã Sửa Xong</option>
                            </select>
                            <button type="button" class="portal-btn portal-btn-secondary" onclick="resetDamageFilters()">Đặt Lại</button>
                        </div>
                    </div>

                    <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                        <table class="portal-table">
                            <thead>
                                <tr>
                                    <th style="width: 14%;">Mã Biên Bản</th>
                                    <th style="width: 18%;">Thông Tin Phòng</th>
                                    <th style="width: 20%;">Loại Sự Cố Hư Hại</th>
                                    <th style="width: 24%;">Mô Tả / Ghi Chú</th>
                                    <th style="width: 12%;">Thời Điểm</th>
                                    <th style="width: 12%; text-align: center;">Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody id="damageTableBody">
                                <c:choose>
                                    <c:when test="${not empty damageList}">
                                        <c:forEach var="dmg" items="${damageList}">
                                            <tr class="damage-record-row"
                                                data-room="${dmg.soPhong}"
                                                data-reportid="${dmg.maBaoCao}"
                                                data-damagetype="${dmg.tenLoaiHuHai}"
                                                data-desc="${dmg.ghiChuChiTiet}"
                                                data-status="${dmg.trangThai}">
                                                <td><strong style="color: var(--portal-primary);">#${dmg.maBaoCao}</strong></td>
                                                <td>
                                                    <div style="font-weight: 700; color: var(--portal-text-primary);">Phòng ${dmg.soPhong}</div>
                                                    <div style="font-size: 12px; color: var(--portal-text-muted);">${dmg.tenLoaiPhong}</div>
                                                </td>
                                                <td>
                                                    <span style="font-weight: 600; color: #b91c1c;">${dmg.tenLoaiHuHai}</span>
                                                </td>
                                                <td style="font-size: 13px; color: var(--portal-text-secondary);">
                                                    ${dmg.ghiChuChiTiet}
                                                </td>
                                                <td style="font-size: 12.5px; color: var(--portal-text-secondary);">
                                                    <fmt:formatDate value="${dmg.thoiDiemPhatHien}" pattern="HH:mm dd/MM/yyyy" />
                                                </td>
                                                <td style="text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${dmg.trangThai == 'Resolved'}">
                                                            <span class="badge-pill badge-available">Đã Sửa Xong</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-pill badge-damaged">Chờ Bảo Trì</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr id="emptyDamageRow">
                                            <td colspan="6" style="padding: 36px; text-align: center; color: var(--portal-text-muted);">
                                                <div style="font-weight: 700; font-size: 15px; color: var(--portal-text-secondary);">Không Có Biên Bản Hư Hại Nào</div>
                                                <div style="font-size: 13px; margin-top: 4px;">Hiện tại không có sự cố hư hại thiết bị nào được ghi nhận.</div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- Thanh phân trang cho Lịch Sử Hư Hại -->
                    <div id="damagePagination" class="portal-pagination-bar" style="display: flex; justify-content: space-between; align-items: center; padding: 12px 20px; background: #f8fafc; border-top: 1px solid var(--portal-border);">
                        <div id="damagePageInfo" style="font-size: 13px; color: var(--portal-text-muted);">Đang hiển thị...</div>
                        <div style="display: flex; gap: 6px; align-items: center;">
                            <button type="button" id="btnDamageFirst" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="goToDamagePage(1)">« Đầu</button>
                            <button type="button" id="btnDamagePrev" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="changeDamagePage(-1)">‹ Trước</button>
                            <span id="damageCurrentPageText" style="padding: 4px 10px; font-weight: 700; font-size: 13px;">Trang 1 / 1</span>
                            <button type="button" id="btnDamageNext" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="changeDamagePage(1)">Sau ›</button>
                            <button type="button" id="btnDamageLast" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="goToDamageLastPage()">Cuối »</button>
                        </div>
                    </div>
                </div>
            </c:when>

            <%-- ========================================================================= --%>
            <%-- CÁC TAB NHIỆM VỤ (Tất Cả, Phòng Tôi Đang Dọn, Lịch Sử Của Tôi)             --%>
            <%-- ========================================================================= --%>
            <c:otherwise>
                <!-- Bảng danh sách nhiệm vụ dọn phòng -->
                <div class="portal-card" style="padding: 0; overflow: hidden;">
                    <div style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                        <h3 class="portal-card-title" style="margin: 0;">
                            <c:choose>
                                <c:when test="${currentStatus == 'MyHistory'}">Lịch Sử Hoàn Thành Nhiệm Vụ Của Tôi</c:when>
                                <c:when test="${currentStatus == 'MyActive'}">Danh Sách Phòng Tôi Đang Dọn</c:when>
                                <c:otherwise>Danh Sách Nhiệm Vụ Buồng Phòng</c:otherwise>
                            </c:choose>
                        </h3>

                        <!-- Bộ lọc nâng cao chỉ hiển thị riêng cho tab Lịch Sử Của Tôi -->
                        <c:if test="${currentStatus == 'MyHistory'}">
                            <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                                <input type="text" id="historySearchInput" class="portal-input" placeholder="Tìm số phòng, loại phòng, mã NV..." style="width: 240px;" oninput="applyHistoryFilters()">
                                <select id="historyResultFilter" class="portal-input" style="width: 175px;" onchange="applyHistoryFilters()">
                                    <option value="">-- Tất Cả Kết Quả --</option>
                                    <option value="KhongThietHai">Hoàn Tất Sạch Sẽ</option>
                                    <option value="CoThietHai">Có Báo Cáo Hư Hại</option>
                                </select>
                                <input type="date" id="historyDateFilter" class="portal-input" style="width: 145px;" onchange="applyHistoryFilters()" title="Lọc theo ngày hoàn thành">
                                <button type="button" class="portal-btn portal-btn-secondary" onclick="resetHistoryFilters()">Đặt Lại</button>
                            </div>
                        </c:if>
                    </div>

                    <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                        <table class="portal-table">
                            <thead>
                                <tr>
                                    <th style="width: 22%;">Thông Tin Phòng</th>
                                    <th style="width: 18%; text-align: center;">Tình Trạng Phòng</th>
                                    <th style="width: 20%;">Nhân Viên Đảm Nhận</th>
                                    <th style="width: 18%;">Mốc Thời Gian</th>
                                    <th style="width: 22%; text-align: center;">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody id="taskTableBody">
                                <c:choose>
                                    <c:when test="${not empty taskList}">
                                        <c:forEach var="task" items="${taskList}">
                                            <fmt:formatDate var="fmtEndDateOnly" value="${task.thoiGianKetThuc}" pattern="yyyy-MM-dd" />
                                            <fmt:formatDate var="fmtNhan" value="${task.thoiGianNhan}" pattern="HH:mm dd/MM/yyyy" />
                                            <fmt:formatDate var="fmtBatDau" value="${task.thoiGianBatDau}" pattern="HH:mm dd/MM/yyyy" />
                                            <fmt:formatDate var="fmtKetThuc" value="${task.thoiGianKetThuc}" pattern="HH:mm dd/MM/yyyy" />
                                            <tr class="${currentStatus == 'MyHistory' ? 'history-task-row' : ''}"
                                                data-room="${task.soPhong}"
                                                data-roomtype="${task.tenLoaiPhong}"
                                                data-taskid="${task.maNhiemVu}"
                                                data-result="${task.ketQua}"
                                                data-date="${fmtEndDateOnly}">
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
                                                        <c:when test="${not empty task.thoiGianKetThuc}">
                                                            <div>Hoàn tất:</div>
                                                            <strong><fmt:formatDate value="${task.thoiGianKetThuc}" pattern="HH:mm dd/MM" /></strong>
                                                        </c:when>
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
                                                                        Nhận Việc &amp; Dọn
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <form action="${pageContext.request.contextPath}/housekeeper/task-action" method="POST" style="display: inline;">
                                                                        <input type="hidden" name="action" value="start" />
                                                                        <input type="hidden" name="maNhiemVu" value="${task.maNhiemVu}" />
                                                                        <button type="submit" class="portal-btn portal-btn-primary" style="padding: 6px 12px; font-size: 12px;">
                                                                            Nhận Việc &amp; Dọn
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
                                                        <c:when test="${task.trangThaiNhiemVu == 'DaHoanThanh' || task.trangThaiNhiemVu == 'Completed' || currentStatus == 'MyHistory'}">
                                                            <div style="display: flex; flex-direction: column; align-items: center; gap: 5px;">
                                                                <c:choose>
                                                                    <c:when test="${task.ketQua == 'CoThietHai' || task.ketQua == 'Có thiệt hại'}">
                                                                        <span style="color: #b91c1c; font-weight: 700; font-size: 12.5px;">
                                                                            Có Báo Cáo Hư Hại
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span style="color: #15803d; font-weight: 700; font-size: 12.5px;">
                                                                            Hoàn Tất Sạch Sẽ
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <button type="button" class="portal-btn portal-btn-secondary btn-task-detail" style="padding: 3px 8px; font-size: 11.5px;"
                                                                        data-taskid="${task.maNhiemVu}"
                                                                        data-room="${task.soPhong}"
                                                                        data-roomtype="${task.tenLoaiPhong}"
                                                                        data-status="${task.trangThaiPhong}"
                                                                        data-staffname="${task.tenNV}"
                                                                        data-staffid="${task.maNV}"
                                                                        data-timenhan="${fmtNhan}"
                                                                        data-timebatdau="${fmtBatDau}"
                                                                        data-timeketthuc="${fmtKetThuc}"
                                                                        data-result="${task.ketQua}"
                                                                        onclick="openTaskDetailModalFromBtn(this)">
                                                                    Xem Chi Tiết
                                                                </button>
                                                            </div>
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
                                        <tr id="emptyTaskRow">
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

                    <!-- Thanh phân trang cho Lịch Sử Của Tôi -->
                    <c:if test="${currentStatus == 'MyHistory'}">
                        <div id="historyPagination" class="portal-pagination-bar" style="display: flex; justify-content: space-between; align-items: center; padding: 12px 20px; background: #f8fafc; border-top: 1px solid var(--portal-border);">
                            <div id="historyPageInfo" style="font-size: 13px; color: var(--portal-text-muted);">Đang hiển thị...</div>
                            <div style="display: flex; gap: 6px; align-items: center;">
                                <button type="button" id="btnHistFirst" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="goToHistoryPage(1)">« Đầu</button>
                                <button type="button" id="btnHistPrev" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="changeHistoryPage(-1)">‹ Trước</button>
                                <span id="historyCurrentPageText" style="padding: 4px 10px; font-weight: 700; font-size: 13px;">Trang 1 / 1</span>
                                <button type="button" id="btnHistNext" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="changeHistoryPage(1)">Sau ›</button>
                                <button type="button" id="btnHistLast" class="portal-btn portal-btn-secondary" style="padding: 5px 10px; font-size: 12px;" onclick="goToHistoryLastPage()">Cuối »</button>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
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

<!-- Modal Chi Tiết Nhiệm Vụ Cũ -->
<div id="taskDetailModal" class="portal-modal-backdrop" style="display: none; align-items: center; justify-content: center;">
    <div class="portal-modal-card" style="max-width: 580px;">
        <div style="background: #f8fafc; padding: 16px 20px; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">Chi Tiết Nhiệm Vụ Dọn Phòng</h3>
            <button type="button" onclick="closeTaskDetailModal()" style="background: none; border: none; font-size: 18px; cursor: pointer; color: var(--portal-text-muted); font-weight: 700;">Đóng</button>
        </div>
        <div style="padding: 24px;">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; background: #f8fafc; border: 1px solid var(--portal-border); border-radius: 8px; padding: 16px; margin-bottom: 18px; font-size: 13.5px;">
                <div>Mã nhiệm vụ: <strong id="dtlTaskId" style="color: var(--portal-primary);">--</strong></div>
                <div>Phòng: <strong id="dtlRoom" style="color: var(--portal-text-primary);">--</strong></div>
                <div style="grid-column: span 2;">Hạng phòng: <span id="dtlRoomType">--</span></div>
                <div>Nhân viên thực hiện: <strong id="dtlStaff">--</strong></div>
                <div>Tình trạng phòng sau dọn: <span id="dtlRoomStatus" class="badge-pill badge-available">--</span></div>
            </div>

            <div style="background: #ffffff; border: 1px solid var(--portal-border); border-radius: 8px; padding: 16px; margin-bottom: 18px; font-size: 13px;">
                <div style="font-weight: 700; margin-bottom: 10px; color: var(--portal-text-secondary); text-transform: uppercase; font-size: 12px;">Tiến Độ Thời Gian Ca Dọn</div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span>Tiếp nhận phòng:</span>
                    <strong id="dtlTimeAssigned">--</strong>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span>Bắt đầu dọn:</span>
                    <strong id="dtlTimeStart">--</strong>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span>Hoàn thành nghiệm thu:</span>
                    <strong id="dtlTimeEnd">--</strong>
                </div>
            </div>

            <div style="padding: 14px; border-radius: 8px; border: 1px solid var(--portal-border); font-size: 13.5px;" id="dtlResultBox">
                <div>Kết quả nghiệm thu: <strong id="dtlResultText">--</strong></div>
            </div>

            <div style="display: flex; justify-content: flex-end; margin-top: 20px; border-top: 1px solid var(--portal-border); padding-top: 16px;">
                <button type="button" onclick="closeTaskDetailModal()" class="portal-btn portal-btn-secondary">
                    Đóng
                </button>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/housekeeper/tasks.js?v=<%= System.currentTimeMillis() %>"></script>

<jsp:include page="/views/common/footer.jsp"/>
