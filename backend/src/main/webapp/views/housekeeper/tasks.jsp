<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Buồng Phòng - Danh Sách Nhiệm Vụ"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/housekeeper/tasks.css">

<div class="hk-container">
    <!-- Header trang -->
    <div class="hk-header">
        <div>
            <h1 class="hk-title">Bàn Làm Việc Buồng Phòng</h1>
            <div class="hk-subtitle">Quản lý vệ sinh phòng, cập nhật phòng sạch và lập biên bản sự cố hư hại</div>
        </div>
        <div class="hk-user-badge">
            <div>Nhân viên: <span class="hk-user-name">${sessionScope.CURRENT_USER.hoTen}</span> (${sessionScope.CURRENT_USER.maDinhDanh})</div>
            <div class="hk-user-role">Vai trò: ${sessionScope.CURRENT_USER.role}</div>
        </div>
    </div>

    <!-- Thanh chuyển Tab lọc trạng thái nhiệm vụ (Không dùng thẻ KPI) -->
    <div class="hk-tabs">
        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=TatCa"
           class="hk-tab-item ${empty currentStatus || currentStatus == 'TatCa' ? 'active' : ''}">Tất Cả</a>
        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=ChoXuLy"
           class="hk-tab-item ${currentStatus == 'ChoXuLy' ? 'active' : ''}">Chờ Xử Lý</a>
        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=DangDon"
           class="hk-tab-item ${currentStatus == 'DangDon' ? 'active' : ''}">Đang Dọn</a>
        <a href="${pageContext.request.contextPath}/housekeeper/tasks?status=DaHoanThanh"
           class="hk-tab-item ${currentStatus == 'DaHoanThanh' ? 'active' : ''}">Đã Hoàn Thành</a>
    </div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${not empty sessionScope.flashSuccess}">
        <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-left: 4px solid #16a34a; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; font-size: 13px; color: #166534;">
            ${sessionScope.flashSuccess}
        </div>
        <c:remove var="flashSuccess" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.flashError}">
        <div style="background: #fef2f2; border: 1px solid #fecaca; border-left: 4px solid #dc2626; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; font-size: 13px; color: #991b1b;">
            ${sessionScope.flashError}
        </div>
        <c:remove var="flashError" scope="session" />
    </c:if>

    <!-- Banner cảnh báo nếu đang có 1 phòng dọn dở -->
    <c:if test="${not empty currentActiveTask}">
        <div style="background: #eff6ff; border: 1px solid #bfdbfe; border-left: 4px solid #2563eb; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; font-size: 13px; color: #1e40af;">
            Bạn đang tiến hành dọn dẹp <strong>Phòng ${currentActiveTask.soPhong}</strong>. Vui lòng bấm <strong>Xong Sạch</strong> hoặc <strong>Báo Hỏng</strong> để hoàn tất trước khi nhận thêm phòng mới.
        </div>
    </c:if>

    <!-- Bảng danh sách nhiệm vụ dọn phòng (5 Cột Tinh Gọn) -->
    <div class="hk-card">
        <table class="hk-table">
            <thead>
                <tr>
                    <th style="width: 24%;">Thông Tin Phòng</th>
                    <th style="width: 16%;">Tình Trạng Phòng</th>
                    <th style="width: 20%;">Nhân Viên Đảm Nhận</th>
                    <th style="width: 16%;">Mốc Thời Gian</th>
                    <th style="width: 24%; text-align: center;">Thao Tác</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty taskList}">
                        <c:forEach var="task" items="${taskList}">
                            <tr>
                                <!-- Cột 1: Thông tin phòng -->
                                <td>
                                    <div class="room-number">Phòng ${task.soPhong}</div>
                                    <div class="room-type">${task.tenLoaiPhong}</div>
                                    <div class="task-id">Mã NV: #${task.maNhiemVu}</div>
                                </td>

                                <!-- Cột 2: Tình trạng phòng -->
                                <td>
                                    <c:choose>
                                        <c:when test="${task.trangThaiPhong == 'Dirty'}">
                                            <span class="badge-room-status room-dirty">Chưa Dọn (Dirty)</span>
                                        </c:when>
                                        <c:when test="${task.trangThaiPhong == 'Cleaning'}">
                                            <span class="badge-room-status room-cleaning">Đang Dọn (Cleaning)</span>
                                        </c:when>
                                        <c:when test="${task.trangThaiPhong == 'Available'}">
                                            <span class="badge-room-status room-available">Đã Sạch (Available)</span>
                                        </c:when>
                                        <c:when test="${task.trangThaiPhong == 'Damaged'}">
                                            <span class="badge-room-status room-damaged">Hư Hại (Damaged)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-room-status">${task.trangThaiPhong}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- Cột 3: Nhân viên đảm nhận -->
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty task.tenNV}">
                                            <div style="font-weight: 600; color: #334155;">
                                                ${task.tenNV}
                                                <c:if test="${task.maNV == sessionScope.CURRENT_USER.maDinhDanh}">
                                                    <span class="badge-you">Bạn</span>
                                                </c:if>
                                            </div>
                                            <div style="color: #94a3b8; font-size: 11px;">Mã NV: ${task.maNV}</div>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8; font-style: italic;">Chưa phân công</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- Cột 4: Mốc thời gian -->
                                <td style="font-size: 13px; color: #475569;">
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
                                        <c:when test="${task.trangThaiNhiemVu == 'ChoXuLy' || task.trangThaiPhong == 'Dirty'}">
                                            <c:choose>
                                                <c:when test="${not empty currentActiveTask}">
                                                    <button type="button" class="btn-action-start" disabled
                                                            style="background: #94a3b8; cursor: not-allowed; opacity: 0.6;"
                                                            title="Bạn đang dọn phòng ${currentActiveTask.soPhong}, hãy hoàn tất trước khi nhận phòng mới">
                                                        Nhận Việc &amp; Dọn
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="${pageContext.request.contextPath}/housekeeper/task-action" method="POST" style="display: inline;">
                                                        <input type="hidden" name="action" value="start" />
                                                        <input type="hidden" name="maNhiemVu" value="${task.maNhiemVu}" />
                                                        <button type="submit" class="btn-action-start" title="Tiếp nhận dọn phòng này">
                                                            Nhận Việc &amp; Dọn
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:when test="${task.trangThaiNhiemVu == 'DangDon' || task.trangThaiPhong == 'Cleaning'}">
                                            <c:choose>
                                                <c:when test="${empty task.maNV || task.maNV == sessionScope.CURRENT_USER.maDinhDanh}">
                                                    <button type="button" class="btn-action-clean"
                                                            onclick="openInspectionModal('${task.maNhiemVu}', '${task.soPhong}', '${task.tenLoaiPhong}')"
                                                            title="Nghiệm thu dọn phòng và kiểm tra tình trạng">
                                                        Nghiệm Thu &amp; Hoàn Tất
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #64748b; font-size: 12px; font-style: italic;">
                                                        Đang được dọn bởi nhân viên khác
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:when test="${task.trangThaiNhiemVu == 'DaHoanThanh'}">
                                            <c:choose>
                                                <c:when test="${task.ketQua == 'CoThietHai'}">
                                                    <span style="color: #b91c1c; font-weight: 600; font-size: 13px;">
                                                        Có Báo Cáo Hư Hại
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #15803d; font-weight: 600; font-size: 13px;">
                                                        Hoàn Tất Sạch Sẽ
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8;">-</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" class="empty-state">
                                <div class="empty-state-title">Không Có Nhiệm Vụ Nào Cần Xử Lý</div>
                                <div class="empty-state-desc">Hiện tại tất cả các phòng trong danh mục này đều đã hoàn tất.</div>
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>

<!-- Modal Nghiệm thu hoàn tất dọn phòng (F5.2 & F5.3) -->
<div id="inspectionModal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); align-items: center; justify-content: center;">
    <div style="background: #ffffff; width: 100%; max-width: 520px; border-radius: 8px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); overflow: hidden; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;">
        <div style="background: #f8fafc; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
            <h3 style="margin: 0; font-size: 17px; font-weight: 700; color: #0f172a;">Nghiệm Thu Hoàn Tất Dọn Phòng</h3>
            <button type="button" onclick="closeInspectionModal()" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #64748b;">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/housekeeper/task-action" method="POST" style="margin: 0; padding: 20px;">
            <input type="hidden" name="action" value="complete" />
            <input type="hidden" id="modalTaskId" name="maNhiemVu" value="" />

            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 14px; margin-bottom: 18px;">
                <div style="font-weight: 700; font-size: 16px; color: #0f172a;" id="modalRoomInfo">Phòng ---</div>
                <div style="color: #64748b; font-size: 13px; margin-top: 4px;" id="modalTaskIdText">Mã nhiệm vụ: ---</div>
                <div style="color: #334155; font-size: 13px; margin-top: 4px;">Người kiểm tra: <strong>${sessionScope.CURRENT_USER.hoTen}</strong></div>
            </div>

            <div style="margin-bottom: 16px;">
                <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; padding: 12px; background: #fffbeb; border: 1px solid #fef3c7; border-radius: 6px;">
                    <input type="checkbox" id="modalHasDamage" name="hasDamage" value="true" onchange="toggleDamageNotice(this.checked)" style="width: 18px; height: 18px; margin-top: 2px; cursor: pointer;" />
                    <div>
                        <span style="font-weight: 700; color: #92400e; font-size: 14px;">Phát hiện cơ sở vật chất / thiết bị hư hại</span>
                        <div style="color: #78350f; font-size: 12px; margin-top: 2px;">Tích chọn nếu phòng có đồ đạc bị hỏng hóc, nứt vỡ hoặc cần sửa chữa bảo trì.</div>
                    </div>
                </label>
            </div>

            <div id="cleanNoticeBox" style="font-size: 13px; color: #166534; background: #f0fdf4; border: 1px solid #bbf7d0; padding: 12px; border-radius: 6px; margin-bottom: 20px;">
                Phòng đạt chuẩn vệ sinh sạch sẽ. Bấm xác nhận để mở phòng sang trạng thái <strong>Sẵn sàng (Available)</strong> đón khách.
            </div>

            <div id="damageNoticeBox" style="display: none; font-size: 13px; color: #991b1b; background: #fef2f2; border: 1px solid #fecaca; padding: 12px; border-radius: 6px; margin-bottom: 20px;">
                Hệ thống sẽ chuyển bạn sang <strong>Màn hình Lập Biên Bản Hư Hại</strong> để điền các mục hư hỏng chi tiết và khóa phòng bảo trì.
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                <button type="button" onclick="closeInspectionModal()" style="padding: 9px 18px; background: #f1f5f9; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 14px; font-weight: 600; color: #475569; cursor: pointer;">
                    Hủy Bỏ
                </button>
                <button type="submit" id="btnSubmitModal" style="padding: 9px 20px; background: #16a34a; border: none; border-radius: 6px; font-size: 14px; font-weight: 600; color: #ffffff; cursor: pointer; transition: background 0.15s ease-in-out;">
                    Xác Nhận Dọn Xong Phòng Sạch
                </button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/housekeeper/tasks.js"></script>

<jsp:include page="/views/common/footer.jsp"/>
