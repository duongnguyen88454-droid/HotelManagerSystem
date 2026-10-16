<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Nhân Sự & Tài Khoản" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="employees" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Quản Lý Nhân Sự và Tài Khoản (HR)</h1>
                <p>Quản lý hồ sơ nhân viên, theo dõi ngày vào/nghỉ việc và kiểm soát khóa tài khoản</p>
            </div>
            <div class="portal-header-right">
                <a href="${pageContext.request.contextPath}/manager/dashboard" class="portal-btn portal-btn-secondary">
                    Quay Lại Dashboard
                </a>
            </div>
        </header>

        <!-- Thông báo kết quả -->
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

        <!-- Bảng danh sách nhân sự -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); background: #f8fafc; display: flex; justify-content: space-between; align-items: center;">
                <h3 class="portal-card-title">
                    Danh Sách Hồ Sơ Nhân Viên Toàn Khách Sạn (${not empty employees ? employees.size() : 0} nhân sự)
                </h3>
                <button type="button" class="portal-btn portal-btn-primary" onclick="openCreateEmployeeModal()">
                    + Thêm Nhân Viên Mới
                </button>
            </div>

            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th>Mã NV</th>
                            <th>Họ Và Tên</th>
                            <th>Tài Khoản & Vai Trò</th>
                            <th>Liên Hệ</th>
                            <th>Ngày Vào Làm</th>
                            <th style="text-align: center;">Trạng Thái NV</th>
                            <th style="text-align: center;">Tài Khoản</th>
                            <th style="text-align: center;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty employees}">
                                <c:forEach var="emp" items="${employees}">
                                    <tr>
                                        <td style="font-weight: 700; color: var(--portal-primary);">
                                            ${emp.employeeId}
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; color: var(--portal-text-primary); font-size: 14.5px;">${emp.fullName}</div>
                                            <c:if test="${emp.resignationDate != null}">
                                                <div style="color: #ef4444; font-size: 12px; margin-top: 2px;">Nghỉ việc: ${emp.resignationDate}</div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <div style="font-weight: 600; color: var(--portal-text-secondary);">${emp.userName}</div>
                                            <div style="margin-top: 3px;">
                                                <span class="badge-pill badge-partial">${emp.role}</span>
                                            </div>
                                        </td>
                                        <td style="font-size: 13px; color: var(--portal-text-secondary);">
                                            <div>SĐT: ${emp.phone}</div>
                                            <div style="margin-top: 2px; color: var(--portal-text-muted);">Email: ${emp.email}</div>
                                        </td>
                                        <td style="color: var(--portal-text-muted); font-size: 13px;">
                                            ${emp.hireDate}
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${emp.employeeStatus == 'Working'}">
                                                    <span class="badge-pill badge-available">Đang Làm Việc</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-occupied">Đã Nghỉ Việc</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${emp.accountStatus == 'Active'}">
                                                    <span class="badge-pill badge-available">Đang Mở</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-damaged">Đã Khóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;">
                                            <div style="display: flex; gap: 6px; justify-content: center; align-items: center;">
                                                <button type="button" class="portal-btn portal-btn-secondary" style="padding: 6px 12px; font-size: 12px;"
                                                        onclick="openEditAccountModal('${emp.employeeId}', '${emp.fullName}', '${emp.userName}', '${emp.role}', '${emp.accountStatus}')">
                                                    ⚙ Đổi Tài Khoản
                                                </button>
                                                <c:choose>
                                                    <c:when test="${emp.employeeStatus == 'Working'}">
                                                        <form action="${pageContext.request.contextPath}/manager/employees" method="POST" style="margin: 0; display: inline-block;"
                                                              onsubmit="return confirmResignation(this);">
                                                            <input type="hidden" name="action" value="resign" />
                                                            <input type="hidden" name="employeeId" value="${emp.employeeId}" />
                                                            <input type="hidden" name="employeeName" value="${emp.fullName}" />
                                                            <button type="submit" class="portal-btn portal-btn-danger" style="padding: 6px 12px; font-size: 12px;">
                                                                Nghỉ Việc
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <form action="${pageContext.request.contextPath}/manager/employees" method="POST" style="margin: 0; display: inline-block;"
                                                              onsubmit="return confirmReinstate(this);">
                                                            <input type="hidden" name="action" value="reinstate" />
                                                            <input type="hidden" name="employeeId" value="${emp.employeeId}" />
                                                            <input type="hidden" name="employeeName" value="${emp.fullName}" />
                                                            <button type="submit" class="portal-btn portal-btn-primary" style="padding: 6px 12px; font-size: 12px;">
                                                                Kích Hoạt Lại
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" style="padding: 30px; text-align: center; color: var(--portal-text-muted);">Chưa có dữ liệu nhân sự.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- Modal 1: Thêm Nhân Viên Mới -->
<div id="createEmployeeModal" class="portal-modal-backdrop" style="display: none; align-items: center; justify-content: center;">
    <div class="portal-modal-card" style="max-width: 520px;">
        <div style="background: #f8fafc; padding: 16px 20px; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">Thêm Hồ Sơ Nhân Viên Mới</h3>
            <button type="button" onclick="closeModal('createEmployeeModal')" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--portal-text-muted); font-weight: 700;">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/manager/employees" method="POST" style="margin: 0; padding: 24px;">
            <input type="hidden" name="action" value="create" />

            <div style="margin-bottom: 14px;">
                <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Họ Và Tên <span style="color: #ef4444;">*</span></label>
                <input type="text" name="fullName" required class="portal-input" placeholder="Ví dụ: Nguyễn Văn An" style="width: 100%; box-sizing: border-box;" />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                <div>
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Số Điện Thoại <span style="color: #ef4444;">*</span></label>
                    <input type="text" name="phone" required class="portal-input" placeholder="0901234567" style="width: 100%; box-sizing: border-box;" />
                </div>
                <div>
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Email <span style="color: #ef4444;">*</span></label>
                    <input type="email" name="email" required class="portal-input" placeholder="an.nv@hotel.com" style="width: 100%; box-sizing: border-box;" />
                </div>
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Vị Trí / Vai Trò <span style="color: #ef4444;">*</span></label>
                <select name="role" required class="portal-input" style="width: 100%; box-sizing: border-box;">
                    <option value="Receptionist">Lễ Tân (Receptionist)</option>
                    <option value="Housekeeper">Buồng Phòng (Housekeeper)</option>
                </select>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 20px;">
                <div>
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Tên Đăng Nhập <span style="color: #ef4444;">*</span></label>
                    <input type="text" name="userName" required class="portal-input" placeholder="letan2" style="width: 100%; box-sizing: border-box;" />
                </div>
                <div>
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Mật Khẩu Khởi Tạo <span style="color: #ef4444;">*</span></label>
                    <input type="password" name="password" required class="portal-input" placeholder="••••••••" style="width: 100%; box-sizing: border-box;" />
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid var(--portal-border); padding-top: 16px;">
                <button type="button" onclick="closeModal('createEmployeeModal')" class="portal-btn portal-btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="portal-btn portal-btn-primary">Lưu Nhân Viên Mới</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal 2: Cập Nhật Tài Khoản Nhân Viên -->
<div id="editAccountModal" class="portal-modal-backdrop" style="display: none; align-items: center; justify-content: center;">
    <div class="portal-modal-card" style="max-width: 480px;">
        <div style="background: #f8fafc; padding: 16px 20px; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center;">
            <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">Thay Đổi Tài Khoản Nhân Viên</h3>
            <button type="button" onclick="closeModal('editAccountModal')" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--portal-text-muted); font-weight: 700;">&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/manager/employees" method="POST" style="margin: 0; padding: 24px;">
            <input type="hidden" name="action" value="update_account" />
            <input type="hidden" id="editEmployeeId" name="employeeId" value="" />

            <div style="background: #f1f5f9; border-radius: 6px; padding: 12px 16px; margin-bottom: 16px;">
                <div style="font-size: 12px; color: var(--portal-text-muted);">Nhân viên được điều chỉnh:</div>
                <div style="font-weight: 700; font-size: 15px; color: var(--portal-text-primary);" id="editEmployeeName">--</div>
                <div style="font-size: 12px; color: var(--portal-text-secondary); margin-top: 2px;" id="editEmployeeIdLabel">Mã NV: --</div>
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Tên Đăng Nhập <span style="color: #ef4444;">*</span></label>
                <input type="text" id="editUserName" name="userName" required class="portal-input" style="width: 100%; box-sizing: border-box;" />
            </div>

            <div style="margin-bottom: 14px;">
                <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">
                    Mật Khẩu Mới
                    <span style="font-size: 12px; font-weight: 400; color: var(--portal-text-muted);">(Để trống nếu giữ nguyên)</span>
                </label>
                <input type="password" name="newPassword" class="portal-input" placeholder="Nhập mật khẩu mới nếu muốn đổi" style="width: 100%; box-sizing: border-box;" />
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 20px;">
                <div>
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Vai Trò / Phân Quyền</label>
                    <select id="editRole" name="role" required class="portal-input" style="width: 100%; box-sizing: border-box;">
                        <option value="Receptionist">Lễ Tân (Receptionist)</option>
                        <option value="Housekeeper">Buồng Phòng (Housekeeper)</option>
                    </select>
                </div>
                <div>
                    <label style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--portal-text-primary);">Trạng Thái Tài Khoản</label>
                    <select id="editAccountStatus" name="accountStatus" required class="portal-input" style="width: 100%; box-sizing: border-box;">
                        <option value="Active">Đang Mở (Active)</option>
                        <option value="Locked">Đã Khóa (Locked)</option>
                    </select>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid var(--portal-border); padding-top: 16px;">
                <button type="button" onclick="closeModal('editAccountModal')" class="portal-btn portal-btn-secondary">Hủy Bỏ</button>
                <button type="submit" class="portal-btn portal-btn-primary">Lưu Thay Đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
function openCreateEmployeeModal() {
    document.getElementById('createEmployeeModal').style.display = 'flex';
}
function openEditAccountModal(empId, fullName, userName, role, accStatus) {
    document.getElementById('editEmployeeId').value = empId;
    document.getElementById('editEmployeeName').innerText = fullName;
    document.getElementById('editEmployeeIdLabel').innerText = 'Mã NV: ' + empId;
    document.getElementById('editUserName').value = userName;
    document.getElementById('editRole').value = role;
    document.getElementById('editAccountStatus').value = accStatus;
    document.getElementById('editAccountModal').style.display = 'flex';
}
function closeModal(modalId) {
    var modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
    }
}
function confirmResignation(formEl) {
    var name = formEl.elements["employeeName"].value;
    return confirm("Xác nhận cho nhân viên [" + name + "] nghỉ việc? Trạng thái sẽ chuyển sang Resigned và tài khoản đăng nhập sẽ tự động bị khóa.");
}
function confirmReinstate(formEl) {
    var name = formEl.elements["employeeName"].value;
    return confirm("Kích hoạt lại nhân viên [" + name + "] và mở khóa tài khoản đăng nhập?");
}
</script>

<jsp:include page="/views/common/footer.jsp" />