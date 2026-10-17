<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="/views/common/header.jsp">
                <jsp:param name="title" value="Bàn Làm Việc Buồng Phòng - Danh Sách Nhiệm Vụ" />
                <jsp:param name="zone" value="portal" />
            </jsp:include>

            <div class="portal-wrapper portal-layout">
                <!-- Thanh chức năng bên trái -->
                <jsp:include page="/views/common/portal_sidebar.jsp">
                    <jsp:param name="activeMenu" value="tasks" />
                </jsp:include>

                <!-- Màn hình bên phải -->
                <main class="portal-main">
                    <header class="page-header">
                        <div class="page-header-left">
                            <h1 class="page-title">Bàn Làm Việc Buồng Phòng</h1>
                            <p class="page-subtitle">Quản lý vệ sinh phòng, cập nhật phòng sạch và lập biên bản sự cố hư
                                hại</p>
                        </div>
                        <div class="page-header-right">
                            <span class="pill pill-primary">Ca trực: <%= new
                                    java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
                        </div>
                    </header>

                    <!-- Thanh chuyển Tab rút gọn & bổ sung Lịch Sử Biên Bản Hư Hại -->
                    <div class="tabs">
                        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=TatCa"
                            class="tab-item ${empty currentStatus || currentStatus == 'TatCa' ? 'active' : ''}">Tất
                            Cả</a>
                        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=MyActive"
                            class="tab-item ${currentStatus == 'MyActive' ? 'active' : ''}">Phòng Tôi Đang Dọn</a>
                        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=MyHistory"
                            class="tab-item ${currentStatus == 'MyHistory' ? 'active' : ''}">Lịch Sử Của Tôi</a>
                        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=DamageHistory"
                            class="tab-item ${currentStatus == 'DamageHistory' ? 'active' : ''}">Lịch Sử Sự Cố Hư
                            Hại</a>
                    </div>

                    <!-- Thông báo kết quả thao tác -->
                    <c:if test="${not empty sessionScope.flashSuccess}">
                        <div class="alert alert-success">
                            ${sessionScope.flashSuccess}
                        </div>
                        <c:remove var="flashSuccess" scope="session" />
                    </c:if>
                    <c:if test="${not empty sessionScope.flashError}">
                        <div class="alert alert-danger">
                            ${sessionScope.flashError}
                        </div>
                        <c:remove var="flashError" scope="session" />
                    </c:if>

                    <!-- Banner cảnh báo nếu đang có 1 phòng dọn dở -->
                    <c:if test="${not empty currentActiveTask}">
                        <div class="alert alert-info">
                            Bạn đang tiến hành dọn dẹp <strong>${currentActiveTask.soPhong}</strong>. Vui lòng bấm
                            <strong>Hoàn Tất Dọn Phòng</strong> để hoàn tất trước khi nhận thêm phòng mới.
                        </div>
                    </c:if>

                    <c:choose>
                        <%--=========================================================================--%>
                            <%-- TAB 4: LỊCH SỬ BIÊN BẢN SỰ CỐ HƯ HẠI --%>
                                <%--=========================================================================--%>
                                    <c:when test="${currentStatus == 'DamageHistory'}">
                                        <div class="card p-0">
                                            <div class="card-toolbar">
                                                <h3 class="card-title">Lịch Sử Biên Bản Sự Cố Hư Hại Thiết Bị</h3>
                                                <div class="filter-group">
                                                    <input type="text" id="damageSearchInput" class="form-control"
                                                        placeholder="Tìm số phòng, mã BB, loại hư hại..."
                                                        oninput="applyDamageFilters()">
                                                    <select id="damageStatusFilter" class="form-control"
                                                        onchange="applyDamageFilters()">
                                                        <option value="">-- Tất Cả Trạng Thái --</option>
                                                        <option value="Pending">Chờ Bảo Trì</option>
                                                        <option value="Confirmed">Đang Khắc Phục</option>
                                                        <option value="Resolved">Đã Sửa Xong</option>
                                                    </select>
                                                    <button type="button" class="btn btn-outline"
                                                        onclick="resetDamageFilters()">Đặt Lại</button>
                                                </div>
                                            </div>

                                            <div class="table-wrapper">
                                                <table class="table">
                                                    <thead>
                                                        <tr>
                                                            <th>Mã Biên Bản</th>
                                                            <th>Thông Tin Phòng</th>
                                                            <th>Loại Sự Cố Hư Hại</th>
                                                            <th>Mô Tả / Ghi Chú</th>
                                                            <th>Thời Điểm</th>
                                                            <th class="text-center">Trạng Thái</th>
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
                                                                        <td><strong
                                                                                class="text-primary">#${dmg.maBaoCao}</strong>
                                                                        </td>
                                                                        <td>
                                                                            <div class="font-bold text-main">
                                                                                ${dmg.soPhong}</div>
                                                                            <div class="text-muted text-xs">
                                                                                ${dmg.tenLoaiPhong}</div>
                                                                        </td>
                                                                        <td>
                                                                            <span
                                                                                class="font-semibold text-danger">${dmg.tenLoaiHuHai}</span>
                                                                        </td>
                                                                        <td class="text-secondary text-sm">
                                                                            ${dmg.ghiChuChiTiet}
                                                                        </td>
                                                                        <td class="text-secondary text-xs">
                                                                            <fmt:formatDate
                                                                                value="${dmg.thoiDiemPhatHien}"
                                                                                pattern="HH:mm dd/MM/yyyy" />
                                                                        </td>
                                                                        <td class="text-center">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${dmg.trangThai == 'Resolved'}">
                                                                                    <span
                                                                                        class="badge badge-success badge-pill badge-available">Đã
                                                                                        Sửa Xong</span>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <span
                                                                                        class="badge badge-danger badge-pill badge-damaged">Chờ
                                                                                        Bảo Trì</span>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </td>
                                                                    </tr>
                                                                </c:forEach>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <tr id="emptyDamageRow">
                                                                    <td colspan="6" class="text-center py-6 text-muted">
                                                                        <div class="font-bold text-main">Không Có Biên
                                                                            Bản Hư Hại Nào</div>
                                                                        <div class="text-sm mt-1">Hiện tại không có sự
                                                                            cố hư hại thiết bị nào được ghi nhận.</div>
                                                                    </td>
                                                                </tr>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </tbody>
                                                </table>
                                            </div>

                                            <!-- Thanh phân trang cho Lịch Sử Hư Hại -->
                                            <div id="damagePagination" class="pagination-bar">
                                                <div id="damagePageInfo" class="pagination-info">Đang hiển thị...</div>
                                                <div class="pagination-actions">
                                                    <button type="button" id="btnDamageFirst"
                                                        class="btn btn-outline btn-sm" onclick="goToDamagePage(1)">«
                                                        Đầu</button>
                                                    <button type="button" id="btnDamagePrev"
                                                        class="btn btn-outline btn-sm" onclick="changeDamagePage(-1)">‹
                                                        Trước</button>
                                                    <span id="damageCurrentPageText" class="pagination-current">Trang 1
                                                        / 1</span>
                                                    <button type="button" id="btnDamageNext"
                                                        class="btn btn-outline btn-sm" onclick="changeDamagePage(1)">Sau
                                                        ›</button>
                                                    <button type="button" id="btnDamageLast"
                                                        class="btn btn-outline btn-sm"
                                                        onclick="goToDamageLastPage()">Cuối »</button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:when>

                                    <%--=========================================================================--%>
                                        <%-- CÁC TAB NHIỆM VỤ (Tất Cả, Phòng Tôi Đang Dọn, Lịch Sử Của Tôi) --%>
                                            <%--=========================================================================--%>
                                                <c:otherwise>
                                                    <!-- Bảng danh sách nhiệm vụ dọn phòng -->
                                                    <div class="card p-0">
                                                        <div class="card-toolbar">
                                                            <h3 class="card-title">
                                                                <c:choose>
                                                                    <c:when test="${currentStatus == 'MyHistory'}">Lịch
                                                                        Sử Hoàn Thành Nhiệm Vụ Của Tôi</c:when>
                                                                    <c:when test="${currentStatus == 'MyActive'}">Danh
                                                                        Sách Phòng Tôi Đang Dọn</c:when>
                                                                    <c:otherwise>Danh Sách Nhiệm Vụ Buồng Phòng
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </h3>

                                                            <!-- Bộ lọc nâng cao chỉ hiển thị riêng cho tab Lịch Sử Của Tôi -->
                                                            <c:if test="${currentStatus == 'MyHistory'}">
                                                                <div class="filter-group">
                                                                    <input type="text" id="historySearchInput"
                                                                        class="form-control"
                                                                        placeholder="Tìm số phòng, loại phòng, mã NV..."
                                                                        oninput="applyHistoryFilters()">
                                                                    <select id="historyResultFilter"
                                                                        class="form-control"
                                                                        onchange="applyHistoryFilters()">
                                                                        <option value="">-- Tất Cả Kết Quả --</option>
                                                                        <option value="KhongThietHai">Hoàn Tất Sạch Sẽ
                                                                        </option>
                                                                        <option value="CoThietHai">Có Báo Cáo Hư Hại
                                                                        </option>
                                                                    </select>
                                                                    <input type="date" id="historyDateFilter"
                                                                        class="form-control"
                                                                        onchange="applyHistoryFilters()"
                                                                        title="Lọc theo ngày hoàn thành">
                                                                    <button type="button" class="btn btn-outline"
                                                                        onclick="resetHistoryFilters()">Đặt Lại</button>
                                                                </div>
                                                            </c:if>
                                                        </div>

                                                        <div class="table-wrapper">
                                                            <table class="table">
                                                                <thead>
                                                                    <tr>
                                                                        <th>Thông Tin Phòng</th>
                                                                        <th class="text-center">Tình Trạng Phòng</th>
                                                                        <th>Nhân Viên Đảm Nhận</th>
                                                                        <th>Mốc Thời Gian</th>
                                                                        <th class="text-center">Thao Tác</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="taskTableBody">
                                                                    <c:choose>
                                                                        <c:when test="${not empty taskList}">
                                                                            <c:forEach var="task" items="${taskList}">
                                                                                <fmt:formatDate var="fmtEndDateOnly"
                                                                                    value="${task.thoiGianKetThuc}"
                                                                                    pattern="yyyy-MM-dd" />
                                                                                <fmt:formatDate var="fmtNhan"
                                                                                    value="${task.thoiGianNhan}"
                                                                                    pattern="HH:mm dd/MM/yyyy" />
                                                                                <fmt:formatDate var="fmtBatDau"
                                                                                    value="${task.thoiGianBatDau}"
                                                                                    pattern="HH:mm dd/MM/yyyy" />
                                                                                <fmt:formatDate var="fmtKetThuc"
                                                                                    value="${task.thoiGianKetThuc}"
                                                                                    pattern="HH:mm dd/MM/yyyy" />
                                                                                <tr class="${currentStatus == 'MyHistory' ? 'history-task-row' : ''}"
                                                                                    data-room="${task.soPhong}"
                                                                                    data-roomtype="${task.tenLoaiPhong}"
                                                                                    data-taskid="${task.maNhiemVu}"
                                                                                    data-result="${task.ketQua}"
                                                                                    data-date="${fmtEndDateOnly}">
                                                                                    <!-- Cột 1: Thông tin phòng -->
                                                                                    <td>
                                                                                        <div
                                                                                            class="font-bold text-main">
                                                                                            ${task.soPhong}</div>
                                                                                        <div
                                                                                            class="text-secondary text-sm">
                                                                                            ${task.tenLoaiPhong}</div>
                                                                                        <div
                                                                                            class="text-muted text-xs mt-1">
                                                                                            Mã NV: #${task.maNhiemVu}
                                                                                        </div>
                                                                                    </td>

                                                                                    <!-- Cột 2: Tình trạng nhiệm vụ -->
                                                                                    <td class="text-center">
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${task.trangThaiNhiemVu == 'DaHoanThanh' || task.trangThaiNhiemVu == 'Completed'}">
                                                                                                <span
                                                                                                    class="badge badge-success badge-pill badge-available">Đã
                                                                                                    Hoàn Tất</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${task.trangThaiNhiemVu == 'DangDon' || task.trangThaiNhiemVu == 'InProgress'}">
                                                                                                <span
                                                                                                    class="badge badge-info badge-pill badge-partial">Đang
                                                                                                    Dọn
                                                                                                    (Cleaning)</span>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${task.trangThaiNhiemVu == 'ChoXuLy' || task.trangThaiNhiemVu == 'Pending'}">
                                                                                                <span
                                                                                                    class="badge badge-warning badge-pill badge-cleaning">Chờ
                                                                                                    Dọn (Dirty)</span>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span
                                                                                                    class="badge badge-neutral badge-pill badge-damaged">${task.trangThaiNhiemVu}</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>

                                                                                    <!-- Cột 3: Nhân viên đảm nhận -->
                                                                                    <td>
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${not empty task.tenNV}">
                                                                                                <div
                                                                                                    class="font-semibold text-main">
                                                                                                    ${task.tenNV}
                                                                                                    <c:if
                                                                                                        test="${task.maNV == sessionScope.CURRENT_USER.maDinhDanh || task.maNV == sessionScope.CURRENT_USER.maTaiKhoan}">
                                                                                                        <span
                                                                                                            class="badge badge-success badge-pill badge-available"
                                                                                                            style="padding: 1px 6px; font-size: 11px;">Bạn</span>
                                                                                                    </c:if>
                                                                                                </div>
                                                                                                <div
                                                                                                    class="text-muted text-xs">
                                                                                                    Mã: ${task.maNV}
                                                                                                </div>
                                                                                            </c:when>
                                                                                            <c:otherwise>
                                                                                                <span
                                                                                                    class="text-muted italic">Chưa
                                                                                                    phân công</span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>

                                                                                    <!-- Cột 4: Mốc thời gian -->
                                                                                    <td class="text-secondary text-sm">
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${not empty task.thoiGianKetThuc}">
                                                                                                <div>Hoàn tất:</div>
                                                                                                <strong>
                                                                                                    <fmt:formatDate
                                                                                                        value="${task.thoiGianKetThuc}"
                                                                                                        pattern="HH:mm dd/MM" />
                                                                                                </strong>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${not empty task.thoiGianBatDau}">
                                                                                                <div>Bắt đầu:</div>
                                                                                                <strong>
                                                                                                    <fmt:formatDate
                                                                                                        value="${task.thoiGianBatDau}"
                                                                                                        pattern="HH:mm dd/MM" />
                                                                                                </strong>
                                                                                            </c:when>
                                                                                            <c:when
                                                                                                test="${not empty task.thoiGianNhan}">
                                                                                                <div>Nhận phòng:</div>
                                                                                                <strong>
                                                                                                    <fmt:formatDate
                                                                                                        value="${task.thoiGianNhan}"
                                                                                                        pattern="HH:mm dd/MM" />
                                                                                                </strong>
                                                                                            </c:when>
                                                                                            <c:otherwise>-</c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>

                                                                                    <!-- Cột 5: Thao tác (Hành động) -->
                                                                                    <td class="text-center">
                                                                                        <c:choose>
                                                                                            <%-- 1. Nhiệm vụ đã hoàn tất
                                                                                                hoặc trong Tab Lịch Sử
                                                                                                Của Tôi --%>
                                                                                                <c:when
                                                                                                    test="${task.trangThaiNhiemVu == 'DaHoanThanh' || task.trangThaiNhiemVu == 'Completed' || currentStatus == 'MyHistory'}">
                                                                                                    <div
                                                                                                        class="flex flex-col items-center gap-1">
                                                                                                        <c:choose>
                                                                                                            <c:when
                                                                                                                test="${task.ketQua == 'CoThietHai' || task.ketQua == 'Có thiệt hại'}">
                                                                                                                <span
                                                                                                                    class="text-danger font-bold text-sm">
                                                                                                                    Có
                                                                                                                    Báo
                                                                                                                    Cáo
                                                                                                                    Hư
                                                                                                                    Hại
                                                                                                                </span>
                                                                                                            </c:when>
                                                                                                            <c:otherwise>
                                                                                                                <span
                                                                                                                    class="text-success font-bold text-sm">
                                                                                                                    Hoàn
                                                                                                                    Tất
                                                                                                                    Sạch
                                                                                                                    Sẽ
                                                                                                                </span>
                                                                                                            </c:otherwise>
                                                                                                        </c:choose>
                                                                                                        <button
                                                                                                            type="button"
                                                                                                            class="btn btn-outline btn-sm btn-task-detail"
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

                                                                                                <%-- 2. Nhiệm vụ đang
                                                                                                    dọn dẹp --%>
                                                                                                    <c:when
                                                                                                        test="${task.trangThaiNhiemVu == 'DangDon' || task.trangThaiNhiemVu == 'InProgress'}">
                                                                                                        <c:choose>
                                                                                                            <c:when
                                                                                                                test="${empty task.maNV || task.maNV == sessionScope.CURRENT_USER.maDinhDanh || task.maNV == sessionScope.CURRENT_USER.maTaiKhoan}">
                                                                                                                <button
                                                                                                                    type="button"
                                                                                                                    class="btn btn-success btn-sm"
                                                                                                                    onclick="openInspectionModal('${task.maNhiemVu}', '${task.soPhong}', '${task.tenLoaiPhong}')">
                                                                                                                    Hoàn
                                                                                                                    Tất
                                                                                                                    Dọn
                                                                                                                    Phòng
                                                                                                                </button>
                                                                                                            </c:when>
                                                                                                            <c:otherwise>
                                                                                                                <span
                                                                                                                    class="text-muted text-xs italic">
                                                                                                                    Đang
                                                                                                                    được
                                                                                                                    dọn
                                                                                                                    bởi
                                                                                                                    nhân
                                                                                                                    viên
                                                                                                                    khác
                                                                                                                </span>
                                                                                                            </c:otherwise>
                                                                                                        </c:choose>
                                                                                                    </c:when>

                                                                                                    <%-- 3. Nhiệm vụ chờ
                                                                                                        dọn dẹp --%>
                                                                                                        <c:when
                                                                                                            test="${task.trangThaiNhiemVu == 'ChoXuLy' || task.trangThaiNhiemVu == 'Pending'}">
                                                                                                            <c:choose>
                                                                                                                <c:when
                                                                                                                    test="${not empty currentActiveTask}">
                                                                                                                    <button
                                                                                                                        type="button"
                                                                                                                        class="btn btn-outline btn-sm"
                                                                                                                        disabled
                                                                                                                        style="opacity: 0.6; cursor: not-allowed;"
                                                                                                                        title="Vui lòng hoàn tất phòng đang dọn trước khi nhận thêm">
                                                                                                                        Nhận
                                                                                                                        Việc
                                                                                                                        &amp;
                                                                                                                        Dọn
                                                                                                                    </button>
                                                                                                                </c:when>
                                                                                                                <c:otherwise>
                                                                                                                    <form
                                                                                                                        action="${pageContext.request.contextPath}/housekeeper/task-action"
                                                                                                                        method="POST"
                                                                                                                        class="inline">
                                                                                                                        <input
                                                                                                                            type="hidden"
                                                                                                                            name="action"
                                                                                                                            value="start" />
                                                                                                                        <input
                                                                                                                            type="hidden"
                                                                                                                            name="maNhiemVu"
                                                                                                                            value="${task.maNhiemVu}" />
                                                                                                                        <button
                                                                                                                            type="submit"
                                                                                                                            class="btn btn-primary btn-sm">
                                                                                                                            Nhận
                                                                                                                            Việc
                                                                                                                            &amp;
                                                                                                                            Dọn
                                                                                                                        </button>
                                                                                                                    </form>
                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </c:when>

                                                                                                        <c:otherwise>
                                                                                                            <span
                                                                                                                class="text-muted">-</span>
                                                                                                        </c:otherwise>
                                                                                        </c:choose>
                                                                                    </td>
                                                                                </tr>
                                                                            </c:forEach>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <tr id="emptyTaskRow">
                                                                                <td colspan="5"
                                                                                    class="text-center py-6 text-muted">
                                                                                    <div class="font-bold text-main">
                                                                                        Không Có Nhiệm Vụ Nào Cần Xử Lý
                                                                                    </div>
                                                                                    <div class="text-sm mt-1">Hiện tại
                                                                                        tất cả các phòng trong danh mục
                                                                                        này đều đã hoàn tất.</div>
                                                                                </td>
                                                                            </tr>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </tbody>
                                                            </table>
                                                        </div>

                                                        <!-- Thanh phân trang cho Lịch Sử Của Tôi -->
                                                        <c:if test="${currentStatus == 'MyHistory'}">
                                                            <div id="historyPagination" class="pagination-bar">
                                                                <div id="historyPageInfo" class="pagination-info">Đang
                                                                    hiển thị...</div>
                                                                <div class="pagination-actions">
                                                                    <button type="button" id="btnHistFirst"
                                                                        class="btn btn-outline btn-sm"
                                                                        onclick="goToHistoryPage(1)">« Đầu</button>
                                                                    <button type="button" id="btnHistPrev"
                                                                        class="btn btn-outline btn-sm"
                                                                        onclick="changeHistoryPage(-1)">‹ Trước</button>
                                                                    <span id="historyCurrentPageText"
                                                                        class="pagination-current">Trang 1 / 1</span>
                                                                    <button type="button" id="btnHistNext"
                                                                        class="btn btn-outline btn-sm"
                                                                        onclick="changeHistoryPage(1)">Sau ›</button>
                                                                    <button type="button" id="btnHistLast"
                                                                        class="btn btn-outline btn-sm"
                                                                        onclick="goToHistoryLastPage()">Cuối »</button>
                                                                </div>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                </c:otherwise>
                    </c:choose>
                </main>
            </div>

            <!-- Modal Nghiệm thu hoàn tất dọn phòng (F5.2 & F5.3) -->
            <div id="inspectionModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
                <div class="modal-card max-w-lg">
                    <div class="modal-header">
                        <h3 class="modal-title">Nghiệm Thu Hoàn Tất Dọn Phòng</h3>
                        <button type="button" onclick="closeInspectionModal()" class="modal-close">&times;</button>
                    </div>
                    <form action="${pageContext.request.contextPath}/housekeeper/task-action" method="POST">
                        <div class="modal-body">
                            <input type="hidden" name="action" value="complete" />
                            <input type="hidden" id="modalTaskId" name="maNhiemVu" value="" />

                            <div class="card bg-surface-subtle p-3 mb-4">
                                <div class="font-bold text-main text-base" id="modalRoomInfo">Phòng ---</div>
                                <div class="text-muted text-sm mt-1" id="modalTaskIdText">Mã nhiệm vụ: ---</div>
                                <div class="text-secondary text-sm mt-1">Người kiểm tra:
                                    <strong>${sessionScope.CURRENT_USER.hoTen}</strong></div>
                            </div>

                            <div class="mb-4">
                                <label class="checkbox-card">
                                    <input type="checkbox" id="modalHasDamage" name="hasDamage" value="true"
                                        onchange="toggleDamageNotice(this.checked)" />
                                    <div>
                                        <span class="font-bold text-amber">Phát hiện cơ sở vật chất / thiết bị hư
                                            hại</span>
                                        <div class="text-muted text-xs mt-1">Tích chọn nếu phòng có đồ đạc bị hỏng hóc,
                                            nứt vỡ hoặc cần sửa chữa bảo trì.</div>
                                    </div>
                                </label>
                            </div>

                            <div id="cleanNoticeBox" class="alert alert-success mb-4">
                                Phòng đạt chuẩn vệ sinh sạch sẽ. Bấm xác nhận để mở phòng sang trạng thái <strong>Sẵn
                                    sàng (Available)</strong> đón khách.
                            </div>

                            <div id="damageNoticeBox" class="alert alert-danger mb-4" style="display: none;">
                                Hệ thống sẽ chuyển bạn sang <strong>Màn hình Lập Biên Bản Hư Hại</strong> để điền các
                                mục hư hỏng chi tiết và khóa phòng bảo trì.
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" onclick="closeInspectionModal()" class="btn btn-outline">
                                Hủy Bỏ
                            </button>
                            <button type="submit" id="btnSubmitModal" class="btn btn-success">
                                Xác Nhận Dọn Xong Phòng Sạch
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Modal Chi Tiết Nhiệm Vụ Cũ -->
            <div id="taskDetailModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
                <div class="modal-card max-w-lg">
                    <div class="modal-header">
                        <h3 class="modal-title">Chi Tiết Nhiệm Vụ Dọn Phòng</h3>
                        <button type="button" onclick="closeTaskDetailModal()" class="modal-close">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="detail-grid mb-4">
                            <div class="detail-item">
                                <div class="detail-label">Mã nhiệm vụ</div>
                                <div class="detail-value text-primary" id="dtlTaskId">--</div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">Phòng</div>
                                <div class="detail-value" id="dtlRoom">--</div>
                            </div>
                            <div class="detail-item col-span-2">
                                <div class="detail-label">Hạng phòng</div>
                                <div class="detail-value" id="dtlRoomType">--</div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">Nhân viên thực hiện</div>
                                <div class="detail-value" id="dtlStaff">--</div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">Tình trạng phòng sau dọn</div>
                                <div class="detail-value"><span id="dtlRoomStatus"
                                        class="badge badge-success badge-pill badge-available">--</span></div>
                            </div>
                        </div>

                        <div class="card p-3 mb-4">
                            <div class="font-bold text-xs uppercase text-muted mb-2">Tiến Độ Thời Gian Ca Dọn</div>
                            <div class="flex justify-between py-1 text-sm">
                                <span class="text-secondary">Tiếp nhận phòng:</span>
                                <strong id="dtlTimeAssigned">--</strong>
                            </div>
                            <div class="flex justify-between py-1 text-sm">
                                <span class="text-secondary">Bắt đầu dọn:</span>
                                <strong id="dtlTimeStart">--</strong>
                            </div>
                            <div class="flex justify-between py-1 text-sm">
                                <span class="text-secondary">Hoàn thành nghiệm thu:</span>
                                <strong id="dtlTimeEnd">--</strong>
                            </div>
                        </div>

                        <div class="card p-3" id="dtlResultBox">
                            <div class="text-sm">Kết quả nghiệm thu: <strong id="dtlResultText">--</strong></div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" onclick="closeTaskDetailModal()" class="btn btn-outline">
                            Đóng
                        </button>
                    </div>
                </div>
            </div>

            <script
                src="${pageContext.request.contextPath}/assets/js/housekeeper/tasks.js?v=<%= System.currentTimeMillis() %>"></script>

            <jsp:include page="/views/common/footer.jsp" />