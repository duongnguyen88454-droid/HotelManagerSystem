<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="/views/common/header.jsp">
                <jsp:param name="title" value="Quản Lý Nhân Sự & Tài Khoản" />
                <jsp:param name="zone" value="portal" />
            </jsp:include>

            <div class="portal-layout">
                <!-- Thanh chức năng bên trái -->
                <jsp:include page="/views/common/portal_sidebar.jsp">
                    <jsp:param name="activeMenu" value="employees" />
                </jsp:include>

                <!-- Màn hình bên phải -->
                <main class="portal-main">
                    <header class="page-header">
                        <div class="page-header-left">
                            <h1 class="page-title">Quản Lý Nhân Sự và Tài Khoản</h1>
                            <p class="page-subtitle">Quản lý hồ sơ nhân viên</p>
                        </div>
                        <div class="page-header-right">
                            <span class="pill pill-primary">Ca trực: <%= new
                                    java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
                        </div>
                    </header>

                    <!-- Thông báo kết quả -->
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

                    <!-- Bảng danh sách nhân sự -->
                    <div class="card p-0">
                        <div class="card-toolbar">
                            <h3 class="card-title">
                                Danh Sách Hồ Sơ Nhân Viên Toàn Khách Sạn (${not empty employees ? employees.size() : 0}
                                nhân sự)
                            </h3>
                            <button type="button" class="btn btn-primary" onclick="openCreateEmployeeModal()">
                                + Thêm Nhân Viên Mới
                            </button>
                        </div>

                        <div class="table-wrapper">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Mã NV</th>
                                        <th>Họ Và Tên</th>
                                        <th>Tài Khoản &amp; Vai Trò</th>
                                        <th>Liên Hệ</th>
                                        <th>Ngày Vào Làm</th>
                                        <th class="text-center">Trạng Thái NV</th>
                                        <th class="text-center">Tài Khoản</th>
                                        <th class="text-center">Hành Động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty employees}">
                                            <c:forEach var="emp" items="${employees}">
                                                <tr>
                                                    <td>
                                                        <strong class="text-primary">${emp.employeeId}</strong>
                                                    </td>
                                                    <td>
                                                        <div class="font-bold text-main">${emp.fullName}</div>
                                                        <c:if test="${emp.resignationDate != null}">
                                                            <div class="text-danger text-xs mt-1">Nghỉ việc:
                                                                ${emp.resignationDate}</div>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <div class="font-semibold text-secondary">${emp.userName}</div>
                                                        <div class="mt-1">
                                                            <span
                                                                class="badge badge-info badge-pill badge-partial">${emp.role}</span>
                                                        </div>
                                                    </td>
                                                    <td class="text-secondary text-xs">
                                                        <div>SĐT: ${emp.phone}</div>
                                                        <div class="text-muted mt-1">Email: ${emp.email}</div>
                                                    </td>
                                                    <td class="text-muted text-xs">
                                                        ${emp.hireDate}
                                                    </td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${emp.employeeStatus == 'Working'}">
                                                                <span
                                                                    class="badge badge-success badge-pill badge-available">Đang
                                                                    Làm Việc</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span
                                                                    class="badge badge-danger badge-pill badge-occupied">Đã
                                                                    Nghỉ Việc</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${emp.accountStatus == 'Active'}">
                                                                <span
                                                                    class="badge badge-success badge-pill badge-available">Đang
                                                                    Mở</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span
                                                                    class="badge badge-danger badge-pill badge-damaged">Đã
                                                                    Khóa</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <div class="flex items-center justify-center gap-1">
                                                            <button type="button" class="btn btn-outline btn-sm"
                                                                onclick="openEditAccountModal('${emp.employeeId}', '${emp.fullName}', '${emp.userName}', '${emp.role}', '${emp.accountStatus}')">
                                                                Đổi Tài Khoản
                                                            </button>
                                                            <c:choose>
                                                                <c:when test="${emp.employeeStatus == 'Working'}">
                                                                    <form
                                                                        action="${pageContext.request.contextPath}/manager/employees"
                                                                        method="POST" class="inline"
                                                                        onsubmit="return confirmResignation(this);">
                                                                        <input type="hidden" name="action"
                                                                            value="resign" />
                                                                        <input type="hidden" name="employeeId"
                                                                            value="${emp.employeeId}" />
                                                                        <input type="hidden" name="employeeName"
                                                                            value="${emp.fullName}" />
                                                                        <button type="submit"
                                                                            class="btn btn-danger btn-sm">
                                                                            Nghỉ Việc
                                                                        </button>
                                                                    </form>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <form
                                                                        action="${pageContext.request.contextPath}/manager/employees"
                                                                        method="POST" class="inline"
                                                                        onsubmit="return confirmReinstate(this);">
                                                                        <input type="hidden" name="action"
                                                                            value="reinstate" />
                                                                        <input type="hidden" name="employeeId"
                                                                            value="${emp.employeeId}" />
                                                                        <input type="hidden" name="employeeName"
                                                                            value="${emp.fullName}" />
                                                                        <button type="submit"
                                                                            class="btn btn-primary btn-sm">
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
                                                <td colspan="8" class="text-center py-6 text-muted">Chưa có dữ liệu nhân
                                                    sự.</td>
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
            <div id="createEmployeeModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
                <div class="modal-card max-w-lg">
                    <div class="modal-header">
                        <h3 class="modal-title">Thêm Hồ Sơ Nhân Viên Mới</h3>
                        <button type="button" onclick="closeModal('createEmployeeModal')"
                            class="modal-close">&times;</button>
                    </div>
                    <form action="${pageContext.request.contextPath}/manager/employees" method="POST">
                        <div class="modal-body">
                            <input type="hidden" name="action" value="create" />

                            <div class="form-group mb-3">
                                <label class="form-label">Họ Và Tên <span class="text-danger">*</span></label>
                                <input type="text" name="fullName" required class="form-control"
                                    placeholder="Ví dụ: Nguyễn Văn An" />
                            </div>

                            <div class="grid-2 mb-3">
                                <div class="form-group">
                                    <label class="form-label">Số Điện Thoại <span class="text-danger">*</span></label>
                                    <input type="text" name="phone" required class="form-control"
                                        placeholder="0901234567" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Email <span class="text-danger">*</span></label>
                                    <input type="email" name="email" required class="form-control"
                                        placeholder="an.nv@hotel.com" />
                                </div>
                            </div>

                            <div class="form-group mb-3">
                                <label class="form-label">Vị Trí / Vai Trò <span class="text-danger">*</span></label>
                                <select name="role" required class="form-control">
                                    <option value="Receptionist">Lễ Tân (Receptionist)</option>
                                    <option value="Housekeeper">Buồng Phòng (Housekeeper)</option>
                                </select>
                            </div>

                            <div class="grid-2 mb-3">
                                <div class="form-group">
                                    <label class="form-label">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                    <input type="text" name="userName" required class="form-control"
                                        placeholder="letan2" />
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Mật Khẩu Khởi Tạo <span
                                            class="text-danger">*</span></label>
                                    <input type="password" name="password" required class="form-control"
                                        placeholder="••••••••" />
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" onclick="closeModal('createEmployeeModal')"
                                class="btn btn-outline">Hủy Bỏ</button>
                            <button type="submit" class="btn btn-primary">Lưu Nhân Viên Mới</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Modal 2: Cập Nhật Tài Khoản Nhân Viên -->
            <div id="editAccountModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
                <div class="modal-card max-w-lg">
                    <div class="modal-header">
                        <h3 class="modal-title">Thay Đổi Tài Khoản Nhân Viên</h3>
                        <button type="button" onclick="closeModal('editAccountModal')"
                            class="modal-close">&times;</button>
                    </div>
                    <form action="${pageContext.request.contextPath}/manager/employees" method="POST">
                        <div class="modal-body">
                            <input type="hidden" name="action" value="update_account" />
                            <input type="hidden" id="editEmployeeId" name="employeeId" value="" />

                            <div class="card bg-surface-subtle p-3 mb-3">
                                <div class="text-muted text-xs">Nhân viên được điều chỉnh:</div>
                                <div class="font-bold text-main text-base" id="editEmployeeName">--</div>
                                <div class="text-secondary text-xs mt-1" id="editEmployeeIdLabel">Mã NV: --</div>
                            </div>

                            <div class="form-group mb-3">
                                <label class="form-label">Tên Đăng Nhập <span class="text-danger">*</span></label>
                                <input type="text" id="editUserName" name="userName" required class="form-control" />
                            </div>

                            <div class="form-group mb-3">
                                <label class="form-label">
                                    Mật Khẩu Mới
                                    <span class="text-muted text-xs font-normal">(Để trống nếu giữ nguyên)</span>
                                </label>
                                <input type="password" name="newPassword" class="form-control"
                                    placeholder="Nhập mật khẩu mới nếu muốn đổi" />
                            </div>

                            <div class="grid-2 mb-3">
                                <div class="form-group">
                                    <label class="form-label">Vai Trò / Phân Quyền</label>
                                    <select id="editRole" name="role" required class="form-control">
                                        <option value="Receptionist">Lễ Tân (Receptionist)</option>
                                        <option value="Housekeeper">Buồng Phòng (Housekeeper)</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Trạng Thái Tài Khoản</label>
                                    <select id="editAccountStatus" name="accountStatus" required class="form-control">
                                        <option value="Active">Đang Mở (Active)</option>
                                        <option value="Locked">Đã Khóa (Locked)</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" onclick="closeModal('editAccountModal')" class="btn btn-outline">Hủy
                                Bỏ</button>
                            <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
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