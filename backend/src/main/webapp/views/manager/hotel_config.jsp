<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Cấu Hình Khách Sạn &amp; Biểu Phí" />
    <jsp:param name="zone" value="portal" />
</jsp:include>

<div class="portal-layout">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="hotel_config" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="page-header">
            <div class="page-header-left">
                <h1 class="page-title">Cấu Hình Khách Sạn và Biểu Phí</h1>
                <p class="page-subtitle">Quản lý Hạng phòng, Biểu phí phạt/cọc, Danh mục Loại giường, Tiện nghi và Dịch vụ tiêu dùng</p>
            </div>
            <div class="page-header-right">
                <span class="pill pill-primary">Ca trực: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Thông báo kết quả flash message -->
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

        <!-- Tab navigation -->
        <div class="tabs">
            <button type="button" onclick="switchTab('tab-roomtype')" id="btn-tab-roomtype" class="tab-item active">
                1. Hạng Phòng và Biểu Phí
            </button>
            <button type="button" onclick="switchTab('tab-bedtype')" id="btn-tab-bedtype" class="tab-item">
                2. Loại Giường
            </button>
            <button type="button" onclick="switchTab('tab-amenity')" id="btn-tab-amenity" class="tab-item">
                3. Tiện Nghi Buồng Phòng
            </button>
            <button type="button" onclick="switchTab('tab-service')" id="btn-tab-service" class="tab-item">
                4. Dịch Vụ Bổ Sung
            </button>
            <button type="button" onclick="switchTab('tab-room')" id="btn-tab-room" class="tab-item">
                5. Quản Lý Phòng Vật Lý
            </button>
        </div>

        <!-- TAB 1: HẠNG PHÒNG & BIỂU PHÍ (READONLY TABLE) -->
        <div id="tab-roomtype" class="config-tab-content is-active">
            <div class="card p-0">
                <div class="card-toolbar">
                    <div>
                        <h3 class="card-title">
                            Cấu Hình Hạng Phòng, Biểu Phí &amp; Tiện Ích
                        </h3>
                        <p class="text-muted text-xs mt-1">
                            Thông tin hạng phòng được sử dụng tự động trong đặt phòng trực tuyến, tính hóa đơn và phạt/cọc.
                        </p>
                    </div>
                    <button type="button" id="btnOpenAddRoomType" class="btn btn-primary btn-sm" onclick="openAddRoomTypeModal()">
                        + Thêm Hạng Phòng Mới
                    </button>
                </div>

                <div class="table-wrapper">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Mã Hạng</th>
                                <th>Tên Hạng Phòng</th>
                                <th class="text-center">Sức Chứa</th>
                                <th>Giường Ngủ</th>
                                <th>Tiện Nghi Buồng Phòng</th>
                                <th class="text-right">Giá Gốc (VND)</th>
                                <th class="text-right">Phụ Phí Sớm/Muộn</th>
                                <th class="text-center">% Cọc</th>
                                <th class="text-center">Trạng Thái</th>
                                <th class="text-center">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="rt" items="${roomTypes}">
                                <tr>
                                    <td><strong class="text-primary">${rt.maLoaiPhong}</strong></td>
                                    <td class="font-semibold text-main">${rt.tenLoaiPhong}</td>
                                    <td class="text-center">
                                        <span class="badge badge-neutral">${rt.soNguoiToiDa} người</span>
                                    </td>
                                    <td class="text-secondary text-xs">
                                        <c:choose>
                                            <c:when test="${not empty rt.loaiGiuong}">
                                                <span class="text-main font-semibold">${rt.loaiGiuong}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted italic">Chưa cấu hình</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-secondary text-xs" style="max-width: 220px;">
                                        <c:choose>
                                            <c:when test="${not empty rt.tienNghi}">
                                                <span title="${rt.tienNghi}" class="truncate block">
                                                    ${rt.tienNghi}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted italic">Chưa cấu hình</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-right font-bold text-main mono">
                                        <fmt:formatNumber value="${rt.giaPhong}" pattern="#,##0" /> đ
                                    </td>
                                    <td class="text-right text-muted text-xs mono">
                                        +<fmt:formatNumber value="${rt.earlyCheckInFee}" pattern="#,##0" /> /
                                        +<fmt:formatNumber value="${rt.lateCheckOutFee}" pattern="#,##0" />
                                    </td>
                                    <td class="text-center font-semibold text-main mono">
                                        ${rt.depositPercent}%
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${rt.trangThai == 'Active'}">
                                                <span class="badge badge-success badge-active">Áp Dụng</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-danger badge-inactive">Tạm Dừng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <button type="button"
                                            class="btn btn-outline btn-sm btn-edit-roomtype"
                                            data-id="${rt.maLoaiPhong}"
                                            data-name="<c:out value="${rt.tenLoaiPhong}" />"
                                            data-capacity="${rt.soNguoiToiDa}"
                                            data-price="${rt.giaPhong}"
                                            data-early="${rt.earlyCheckInFee}"
                                            data-late="${rt.lateCheckOutFee}"
                                            data-deposit="${rt.depositPercent}"
                                            data-active="${rt.trangThai == 'Active' ? 'true' : 'false'}"
                                            data-beds="${rt.bedTypeIdsWithQty}"
                                            data-amenities="${rt.amenityIds}"
                                            onclick="openEditRoomTypeModal(this)">
                                            Sửa
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- TAB 2: LOẠI GIƯỜNG -->
        <div id="tab-bedtype" class="config-tab-content">
            <div class="grid-sidebar-content">
                <!-- Form Thêm Loại Giường -->
                <div class="card p-4">
                    <h4 class="card-title text-base mb-3">Thêm Loại Giường Mới</h4>
                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                        <input type="hidden" name="action" value="add_bedtype" />
                        <div class="form-group mb-4">
                            <label class="form-label">Tên Loại Giường <span class="text-danger">*</span></label>
                            <input type="text" name="bedTypeName" placeholder="Ví dụ: Giường King Size 2m x 2m" required maxlength="50" class="form-control" />
                        </div>
                        <button type="submit" class="btn btn-primary w-full">
                            Thêm Vào Hệ Thống
                        </button>
                    </form>
                </div>

                <!-- Bảng danh sách Loại Giường -->
                <div class="card p-0">
                    <div class="card-toolbar">
                        <h3 class="card-title">
                            Danh Sách Loại Giường Khách Sạn
                        </h3>
                    </div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã Giường</th>
                                    <th>Tên Loại Giường</th>
                                    <th class="text-center">Trạng Thái</th>
                                    <th class="text-center">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${bedTypes}">
                                    <tr>
                                        <td><strong class="text-primary">${b.bedTypeId}</strong></td>
                                        <td class="font-semibold text-main">${b.bedTypeName}</td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${b.active}">
                                                    <span class="badge badge-success badge-active">Đang Dùng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger badge-inactive">Tạm Khóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST" class="inline">
                                                <input type="hidden" name="action" value="toggle_bedtype" />
                                                <input type="hidden" name="bedTypeId" value="${b.bedTypeId}" />
                                                <input type="hidden" name="isActive" value="${not b.active}" />
                                                <c:choose>
                                                    <c:when test="${b.active}">
                                                        <button type="submit" class="btn btn-danger btn-sm">Khóa</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="submit" class="btn btn-success btn-sm">Mở</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB 3: TIỆN NGHI BUỒNG PHÒNG (ROOMSERVICE) -->
        <div id="tab-amenity" class="config-tab-content">
            <div class="grid-sidebar-content">
                <!-- Form Thêm Tiện Nghi -->
                <div class="card p-4">
                    <h4 class="card-title text-base mb-3">Thêm Tiện Nghi Buồng Phòng</h4>
                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                        <input type="hidden" name="action" value="add_amenity" />
                        <div class="form-group mb-4">
                            <label class="form-label">Tên Tiện Nghi <span class="text-danger">*</span></label>
                            <input type="text" name="amenityName" placeholder="Ví dụ: Bồn tắm massage cao cấp" required maxlength="100" class="form-control" />
                        </div>
                        <button type="submit" class="btn btn-primary w-full">
                            Thêm Tiện Nghi
                        </button>
                    </form>
                </div>

                <!-- Bảng danh sách Tiện Nghi -->
                <div class="card p-0">
                    <div class="card-toolbar">
                        <h3 class="card-title">
                            Danh Sách Tiện Nghi Trang Bị Buồng Phòng
                        </h3>
                    </div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã Tiện Nghi</th>
                                    <th>Tên Tiện Nghi</th>
                                    <th class="text-center">Trạng Thái</th>
                                    <th class="text-center">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="a" items="${amenities}">
                                    <tr>
                                        <td><strong class="text-primary">${a.roomServiceId}</strong></td>
                                        <td class="font-semibold text-main">${a.roomServiceName}</td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${a.active}">
                                                    <span class="badge badge-success badge-active">Đang Dùng</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger badge-inactive">Tạm Khóa</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST" class="inline">
                                                <input type="hidden" name="action" value="toggle_amenity" />
                                                <input type="hidden" name="amenityId" value="${a.roomServiceId}" />
                                                <input type="hidden" name="isActive" value="${not a.active}" />
                                                <c:choose>
                                                    <c:when test="${a.active}">
                                                        <button type="submit" class="btn btn-danger btn-sm">Khóa</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="submit" class="btn btn-success btn-sm">Mở</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB 4: DỊCH VỤ BỔ SUNG -->
        <div id="tab-service" class="config-tab-content">
            <!-- Form ẩn cập nhật từng dịch vụ tiêu dùng đặt ngoài bảng -->
            <c:forEach var="s" items="${services}">
                <form id="form-srv-${s.maDichVu}" action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                    <input type="hidden" name="action" value="update_service" />
                    <input type="hidden" name="serviceId" value="${s.maDichVu}" />
                </form>
            </c:forEach>

            <div class="grid-sidebar-content">
                <!-- Form Thêm Dịch Vụ -->
                <div class="card p-4">
                    <h4 class="card-title text-base mb-3">Thêm Dịch Vụ Tiêu Dùng</h4>
                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                        <input type="hidden" name="action" value="add_service" />
                        <div class="form-group mb-3">
                            <label class="form-label">Tên Dịch Vụ <span class="text-danger">*</span></label>
                            <input type="text" name="serviceName" placeholder="Ví dụ: Tiệc Buffet Sáng Cao Cấp" required maxlength="100" class="form-control" />
                        </div>
                        <div class="form-group mb-4">
                            <label class="form-label">Đơn Giá (VND)</label>
                            <input type="number" step="1000" name="basePrice" placeholder="Ví dụ: 150000" required min="0" class="form-control" />
                        </div>
                        <button type="submit" class="btn btn-primary w-full">
                            Thêm Dịch Vụ
                        </button>
                    </form>
                </div>

                <!-- Bảng danh sách Dịch Vụ -->
                <div class="card p-0">
                    <div class="card-toolbar">
                        <h3 class="card-title">
                            Danh Mục Dịch Vụ Tiêu Dùng Phục Vụ Khách
                        </h3>
                    </div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã DV</th>
                                    <th>Tên Dịch Vụ</th>
                                    <th class="text-right">Đơn Giá (VND)</th>
                                    <th class="text-center">Trạng Thái</th>
                                    <th class="text-center">Lưu Cập Nhật</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${services}">
                                    <tr>
                                        <td><strong class="text-primary">${s.maDichVu}</strong></td>
                                        <td class="font-semibold text-main">${s.tenDichVu}</td>
                                        <td class="text-right">
                                            <input type="number" form="form-srv-${s.maDichVu}" step="1000"
                                                min="0" name="basePrice" value="${s.donGia}" required
                                                class="form-control text-right mono" style="width: 120px; display: inline-block;" />
                                        </td>
                                        <td class="text-center">
                                            <select form="form-srv-${s.maDichVu}" name="isActive" class="form-control text-xs" style="width: 130px; display: inline-block;">
                                                <c:choose>
                                                    <c:when test="${s.trangThai == 'Active'}">
                                                        <option value="true" selected="selected">Hoạt Động</option>
                                                        <option value="false">Tạm Tắt</option>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <option value="true">Hoạt Động</option>
                                                        <option value="false" selected="selected">Tạm Tắt</option>
                                                    </c:otherwise>
                                                </c:choose>
                                            </select>
                                        </td>
                                        <td class="text-center">
                                            <button type="submit" form="form-srv-${s.maDichVu}" class="btn btn-primary btn-sm">
                                                Lưu
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB 5: PHÒNG VẬT LÝ (ROOM) -->
        <div id="tab-room" class="config-tab-content">
            <!-- Form ẩn cập nhật trạng thái vận hành của từng phòng -->
            <c:forEach var="rm" items="${physicalRooms}">
                <form id="form-room-${rm.roomId}" action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                    <input type="hidden" name="action" value="update_room_status" />
                    <input type="hidden" name="roomId" value="${rm.roomId}" />
                </form>
            </c:forEach>

            <div class="grid-sidebar-content">
                <!-- Form Thêm Phòng Mới -->
                <div class="card p-4">
                    <h4 class="card-title text-base mb-3">Thêm Phòng Vật Lý Mới</h4>
                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                        <input type="hidden" name="action" value="add_room" />
                        <div class="form-group mb-3">
                            <label class="form-label">
                                Tên / Số Phòng <span class="text-danger">*</span>
                            </label>
                            <input type="text" name="roomName" placeholder="Ví dụ: 101 hoặc Phòng 101" required maxlength="50" class="form-control" />
                            <span class="text-muted text-xs mt-1 block">Mã phòng sẽ do hệ thống tự động sinh (Ví dụ: RM001).</span>
                        </div>
                        <div class="form-group mb-4">
                            <label class="form-label">
                                Hạng Phòng Thuộc Về <span class="text-danger">*</span>
                            </label>
                            <select name="roomTypeId" required class="form-control">
                                <option value="">-- Chọn Hạng Phòng --</option>
                                <c:forEach var="rt" items="${roomTypes}">
                                    <option value="${rt.maLoaiPhong}">${rt.tenLoaiPhong}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary w-full">
                            Thêm Phòng Vào Hệ Thống
                        </button>
                    </form>
                </div>

                <!-- Bảng Danh Sách Phòng Vật Lý -->
                <div class="card p-0">
                    <div class="card-toolbar">
                        <div>
                            <h3 class="card-title">
                                Danh Sách Phòng Vật Lý Trong Khách Sạn
                            </h3>
                            <p class="text-muted text-xs mt-1">
                                Quản lý số phòng thực tế, trạng thái vận hành, tình trạng buồng phòng và khách cư trú.
                            </p>
                        </div>
                        <span class="pill pill-primary">
                            Tổng: ${fn:length(physicalRooms)} phòng
                        </span>
                    </div>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã Phòng</th>
                                    <th>Tên Phòng</th>
                                    <th>Hạng Phòng</th>
                                    <th class="text-center">Tình Trạng Buồng</th>
                                    <th class="text-center">Khách Ở</th>
                                    <th class="text-center">Vận Hành</th>
                                    <th class="text-center">Lưu</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="rm" items="${physicalRooms}">
                                    <tr>
                                        <td><strong><c:out value="${rm.roomId}" /></strong></td>
                                        <td class="font-semibold text-main"><c:out value="${rm.roomName}" /></td>
                                        <td><span class="font-semibold text-primary"><c:out value="${rm.roomTypeName}" /></span></td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${rm.housekeepingStatus == 'Clean'}">
                                                    <span class="badge badge-success">Sạch Sẽ</span>
                                                </c:when>
                                                <c:when test="${rm.housekeepingStatus == 'Cleaning'}">
                                                    <span class="badge badge-info">Đang Dọn</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger">Cần Dọn</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${rm.occupancyStatus == 'Occupied'}">
                                                    <span class="badge badge-warning">Đang Có Khách</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-neutral">Trống</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <select form="form-room-${rm.roomId}" name="roomStatus" class="form-control text-xs" style="width: 170px; display: inline-block;">
                                                <option value="Available" ${rm.roomStatus == 'Available' ? 'selected="selected"' : ''}>Hoạt Động</option>
                                                <option value="Maintenance" ${rm.roomStatus == 'Maintenance' ? 'selected="selected"' : ''}>Bảo Trì</option>
                                                <option value="OutOfService" ${rm.roomStatus == 'OutOfService' ? 'selected="selected"' : ''}>Ngưng Dùng</option>
                                            </select>
                                        </td>
                                        <td class="text-center">
                                            <button type="submit" form="form-room-${rm.roomId}" class="btn btn-primary btn-sm">
                                                Lưu
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- ========================================== -->
<!-- MODAL 1: THÊM HẠNG PHÒNG MỚI (ROOMTYPE)     -->
<!-- ========================================== -->
<div id="addRoomTypeModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
    <div class="modal-card max-w-lg" style="width: 680px; max-width: 95%; max-height: 90vh; overflow-y: auto;">
        <div class="modal-header">
            <h3 class="modal-title">Thêm Hạng Phòng Mới</h3>
            <button type="button" onclick="closeAddRoomTypeModal()" class="modal-close">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
            <div class="modal-body">
                <input type="hidden" name="action" value="add_roomtype" />

                <!-- KHỐI 1: THÔNG TIN HẠNG PHÒNG & GIÁ -->
                <h4 class="card-title text-sm border-bottom pb-2 mb-3">
                    1. Thông Tin Chung &amp; Biểu Phí
                </h4>
                
                <!-- Hàng 1: Tên Hạng Phòng & Sức Chứa -->
                <div class="grid-2 mb-3">
                    <div class="form-group">
                        <label class="form-label">Tên Hạng Phòng <span class="text-danger">*</span></label>
                        <input type="text" name="roomTypeName" placeholder="Ví dụ: Executive Ocean Suite" required maxlength="50" class="form-control" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Sức Chứa (Người) <span class="text-danger">*</span></label>
                        <input type="number" name="capacity" min="1" max="20" value="2" required class="form-control" />
                    </div>
                </div>

                <!-- Hàng 2: Giá Gốc & % Đặt Cọc -->
                <div class="grid-2 mb-3">
                    <div class="form-group">
                        <label class="form-label">Giá Gốc (VND / Đêm) <span class="text-danger">*</span></label>
                        <input type="number" step="1000" name="basePrice" placeholder="1500000" required min="0" class="form-control mono" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">% Đặt Cọc (0 - 100) <span class="text-danger">*</span></label>
                        <input type="number" name="depositPercent" value="30" min="0" max="100" required class="form-control mono" />
                    </div>
                </div>

                <!-- Hàng 3: Phí Nhận Sớm & Phí Trả Muộn -->
                <div class="grid-2 mb-4">
                    <div class="form-group">
                        <label class="form-label">Phí Nhận Sớm (VND)</label>
                        <input type="number" step="1000" name="earlyFee" value="0" required min="0" class="form-control mono" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phí Trả Muộn (VND)</label>
                        <input type="number" step="1000" name="lateFee" value="0" required min="0" class="form-control mono" />
                    </div>
                </div>

                <!-- KHỐI 2: CẤU HÌNH LOẠI GIƯỜNG (BẢNG ĐỘNG) -->
                <div class="flex justify-between items-center mb-2">
                    <h4 class="card-title text-sm mb-0">2. Cấu Hình Loại Giường Ngủ</h4>
                    <button type="button" class="btn btn-outline btn-sm" onclick="addBedRow('add')">
                        + Thêm Loại Giường
                    </button>
                </div>
                <div class="table-wrapper border rounded mb-4">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Loại Giường</th>
                                <th class="text-center" style="width: 140px;">Số Lượng</th>
                                <th class="text-center" style="width: 80px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="addBedTableBody">
                        </tbody>
                    </table>
                </div>

                <!-- KHỐI 3: TIỆN NGHI BUỒNG PHÒNG (BẢNG ĐỘNG) -->
                <div class="flex justify-between items-center mb-2">
                    <h4 class="card-title text-sm mb-0">3. Tiện Nghi Trang Bị Cho Hạng Phòng</h4>
                    <button type="button" class="btn btn-outline btn-sm" onclick="addAmenityRow('add')">
                        + Thêm Tiện Nghi
                    </button>
                </div>
                <div class="table-wrapper border rounded mb-4">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Tiện Nghi Buồng Phòng</th>
                                <th class="text-center" style="width: 80px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="addAmenityTableBody">
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeAddRoomTypeModal()">Hủy Bỏ</button>
                <button type="submit" class="btn btn-success font-bold">Lưu Hạng Phòng Vào Hệ Thống</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================== -->
<!-- MODAL 2: CHỈNH SỬA HẠNG PHÒNG (ROOMTYPE)    -->
<!-- ========================================== -->
<div id="editRoomTypeModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
    <div class="modal-card max-w-lg" style="width: 680px; max-width: 95%; max-height: 90vh; overflow-y: auto;">
        <div class="modal-header">
            <h3 class="modal-title">Chỉnh Sửa Hạng Phòng &amp; Biểu Phí</h3>
            <button type="button" onclick="closeEditRoomTypeModal()" class="modal-close">&times;</button>
        </div>

        <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
            <div class="modal-body">
                <input type="hidden" name="action" value="update_roomtype" />
                <input type="hidden" name="roomTypeId" id="editRoomTypeId" />

                <!-- Khối Mã Hạng Phòng (Khóa, chỉ xem) -->
                <div class="card bg-surface-subtle p-3 mb-3 flex items-center gap-3">
                    <span class="text-xs font-bold text-secondary">MÃ HẠNG PHÒNG:</span>
                    <input type="text" id="editRoomTypeCodeDisplay" disabled class="font-bold text-primary mono text-base" style="background: transparent; border: none; outline: none;" />
                    <span class="text-muted text-xs" style="margin-left: auto;">(Mã định danh duy nhất - Không thể đổi)</span>
                </div>

                <!-- KHỐI 1: THÔNG TIN CHUNG & BIỂU PHÍ -->
                <h4 class="card-title text-sm border-bottom pb-2 mb-3">
                    1. Thông Tin Chung &amp; Biểu Phí
                </h4>
                <div class="grid-3 mb-3">
                    <div class="form-group">
                        <label class="form-label">Tên Hạng Phòng <span class="text-danger">*</span></label>
                        <input type="text" name="roomTypeName" id="editRoomTypeName" required maxlength="50" class="form-control" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Sức Chứa (Người) <span class="text-danger">*</span></label>
                        <input type="number" name="capacity" id="editCapacity" min="1" max="20" required class="form-control" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Trạng Thái</label>
                        <select name="isActive" id="editIsActive" class="form-control">
                            <option value="true">Áp Dụng</option>
                            <option value="false">Tạm Dừng</option>
                        </select>
                    </div>
                </div>

                <!-- Hàng 2: Giá Gốc & % Đặt Cọc -->
                <div class="grid-2 mb-3">
                    <div class="form-group">
                        <label class="form-label">Giá Gốc (VND/Đêm) <span class="text-danger">*</span></label>
                        <input type="number" step="1000" name="basePrice" id="editBasePrice" required min="0" class="form-control mono" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">% Đặt Cọc (0 - 100) <span class="text-danger">*</span></label>
                        <input type="number" name="depositPercent" id="editDepositPercent" min="0" max="100" required class="form-control mono" />
                    </div>
                </div>

                <!-- Hàng 3: Phí Nhận Sớm & Phí Trả Muộn -->
                <div class="grid-2 mb-4">
                    <div class="form-group">
                        <label class="form-label">Phí Nhận Sớm (VND)</label>
                        <input type="number" step="1000" name="earlyFee" id="editEarlyFee" required min="0" class="form-control mono" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Phí Trả Muộn (VND)</label>
                        <input type="number" step="1000" name="lateFee" id="editLateFee" required min="0" class="form-control mono" />
                    </div>
                </div>

                <!-- KHỐI 2: CẤU HÌNH LOẠI GIƯỜNG (BẢNG ĐỘNG) -->
                <div class="flex justify-between items-center mb-2">
                    <h4 class="card-title text-sm mb-0">2. Cấu Hình Loại Giường Ngủ</h4>
                    <button type="button" class="btn btn-outline btn-sm" onclick="addBedRow('edit')">
                        + Thêm Loại Giường
                    </button>
                </div>
                <div class="table-wrapper border rounded mb-4">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Loại Giường</th>
                                <th class="text-center" style="width: 140px;">Số Lượng</th>
                                <th class="text-center" style="width: 80px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="editBedTableBody">
                        </tbody>
                    </table>
                </div>

                <!-- KHỐI 3: TIỆN NGHI BUỒNG PHÒNG (BẢNG ĐỘNG) -->
                <div class="flex justify-between items-center mb-2">
                    <h4 class="card-title text-sm mb-0">3. Tiện Nghi Trang Bị Cho Hạng Phòng</h4>
                    <button type="button" class="btn btn-outline btn-sm" onclick="addAmenityRow('edit')">
                        + Thêm Tiện Nghi
                    </button>
                </div>
                <div class="table-wrapper border rounded mb-4">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Tiện Nghi Buồng Phòng</th>
                                <th class="text-center" style="width: 80px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="editAmenityTableBody">
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeEditRoomTypeModal()">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary font-bold">Cập Nhật Hạng Phòng</button>
            </div>
        </form>
    </div>
</div>

<!-- Templates ẩn danh mục Loại Giường & Tiện Nghi chuẩn cú pháp HTML/JSP -->
<select id="bedTypeOptionsTemplate" style="display: none;">
    <option value="">-- Chọn Loại Giường --</option>
    <c:forEach var="b" items="${bedTypes}">
        <option value="${b.bedTypeId}"><c:out value="${b.bedTypeName}" /></option>
    </c:forEach>
</select>

<select id="amenityOptionsTemplate" style="display: none;">
    <option value="">-- Chọn Tiện Nghi --</option>
    <c:forEach var="a" items="${amenities}">
        <option value="${a.roomServiceId}"><c:out value="${a.roomServiceName}" /></option>
    </c:forEach>
</select>

<script>
    var bedOptionsHtml = document.getElementById('bedTypeOptionsTemplate').innerHTML;
    var amenityOptionsHtml = document.getElementById('amenityOptionsTemplate').innerHTML;

    function switchTab(tabId) {
        document.querySelectorAll('.config-tab-content').forEach(function (el) {
            el.classList.remove('is-active');
            el.style.display = 'none';
        });
        document.querySelectorAll('[id^="btn-tab-"]').forEach(function (btn) {
            btn.classList.remove('active');
        });

        var targetContent = document.getElementById(tabId);
        if (targetContent) {
            targetContent.classList.add('is-active');
            targetContent.style.display = 'block';
        }
        var activeBtn = document.getElementById('btn-' + tabId);
        if (activeBtn) {
            activeBtn.classList.add('active');
        }
    }

    function addBedRow(mode, selectedBedId, qtyVal) {
        var tbody = document.getElementById(mode + 'BedTableBody');
        if (!tbody) return;
        var row = document.createElement('tr');

        var qty = (qtyVal && parseInt(qtyVal, 10) > 0) ? parseInt(qtyVal, 10) : 1;
        var initialBedId = selectedBedId || '';

        row.innerHTML =
            '<td class="py-2">' +
            '<select name="selectedBedTypes" required onchange="onBedSelectChange(this)" class="form-control text-sm">' +
            bedOptionsHtml +
            '</select>' +
            '</td>' +
            '<td class="py-2 text-center">' +
            '<input type="number" class="bed-qty-input form-control text-center mono font-bold" name="bedQty_' + initialBedId + '" value="' + qty + '" min="1" step="1" required ' +
            'onkeydown="if(event.key===\'.\'||event.key===\'-\'||event.key===\'e\'||event.key===\'+\')event.preventDefault();" ' +
            'oninput="validatePositiveInt(this)" onblur="ensurePositiveInt(this)" style="width: 100px; display: inline-block;" />' +
            '</td>' +
            '<td class="py-2 text-center">' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="this.closest(\'tr\').remove()">Xóa</button>' +
            '</td>';

        tbody.appendChild(row);
        if (initialBedId) {
            var sel = row.querySelector('select');
            if (sel) sel.value = initialBedId;
        }
    }

    function onBedSelectChange(selectElem) {
        var row = selectElem.closest('tr');
        if (!row) return;
        var qtyInput = row.querySelector('.bed-qty-input');
        if (qtyInput) {
            qtyInput.name = 'bedQty_' + selectElem.value;
        }
    }

    function validatePositiveInt(input) {
        if (input.value === '') return;
        var val = parseInt(input.value, 10);
        if (isNaN(val) || val < 1) {
            input.value = 1;
        } else {
            input.value = val;
        }
    }

    function ensurePositiveInt(input) {
        var val = parseInt(input.value, 10);
        if (isNaN(val) || val < 1) {
            input.value = 1;
        } else {
            input.value = val;
        }
    }

    function addAmenityRow(mode, selectedAmenityId) {
        var tbody = document.getElementById(mode + 'AmenityTableBody');
        if (!tbody) return;
        var row = document.createElement('tr');

        row.innerHTML =
            '<td class="py-2">' +
            '<select name="selectedAmenities" required class="form-control text-sm">' +
            amenityOptionsHtml +
            '</select>' +
            '</td>' +
            '<td class="py-2 text-center">' +
            '<button type="button" class="btn btn-outline btn-sm" onclick="this.closest(\'tr\').remove()">Xóa</button>' +
            '</td>';

        tbody.appendChild(row);
        if (selectedAmenityId) {
            var sel = row.querySelector('select');
            if (sel) sel.value = selectedAmenityId;
        }
    }

    function openAddRoomTypeModal() {
        var modal = document.getElementById('addRoomTypeModal');
        if (modal) {
            var bedTbody = document.getElementById('addBedTableBody');
            var amenityTbody = document.getElementById('addAmenityTableBody');
            if (bedTbody) bedTbody.innerHTML = '';
            if (amenityTbody) amenityTbody.innerHTML = '';

            // Tự động thêm 1 dòng giường và 1 dòng tiện nghi ban đầu
            addBedRow('add');
            addAmenityRow('add');

            modal.style.display = 'flex';
        }
    }

    function closeAddRoomTypeModal() {
        var modal = document.getElementById('addRoomTypeModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }

    function openEditRoomTypeModal(btn) {
        if (!btn || !btn.dataset) return;
        var d = btn.dataset;
        document.getElementById('editRoomTypeId').value = d.id || '';
        document.getElementById('editRoomTypeCodeDisplay').value = d.id || '';
        document.getElementById('editRoomTypeName').value = d.name || '';
        document.getElementById('editCapacity').value = d.capacity || '2';
        document.getElementById('editBasePrice').value = d.price || '0';
        document.getElementById('editEarlyFee').value = d.early || '0';
        document.getElementById('editLateFee').value = d.late || '0';
        document.getElementById('editDepositPercent').value = d.deposit || '30';
        document.getElementById('editIsActive').value = (d.active === 'true' || d.active === true) ? 'true' : 'false';

        var bedTbody = document.getElementById('editBedTableBody');
        var amenityTbody = document.getElementById('editAmenityTableBody');
        if (bedTbody) bedTbody.innerHTML = '';
        if (amenityTbody) amenityTbody.innerHTML = '';

        // Render danh sách loại giường hiện có
        if (d.beds) {
            var pairs = d.beds.split(',');
            pairs.forEach(function (pair) {
                var parts = pair.split(':');
                if (parts.length >= 2) {
                    var bedId = parts[0].trim();
                    var qty = parts[1].trim();
                    if (bedId) {
                        addBedRow('edit', bedId, qty);
                    }
                }
            });
        }
        if (bedTbody && bedTbody.children.length === 0) {
            addBedRow('edit');
        }

        // Render danh sách tiện nghi hiện có
        if (d.amenities) {
            var aIds = d.amenities.split(',');
            aIds.forEach(function (aId) {
                var trimmed = aId.trim();
                if (trimmed) {
                    addAmenityRow('edit', trimmed);
                }
            });
        }
        if (amenityTbody && amenityTbody.children.length === 0) {
            addAmenityRow('edit');
        }

        var editModal = document.getElementById('editRoomTypeModal');
        if (editModal) {
            editModal.style.display = 'flex';
        }
    }

    function closeEditRoomTypeModal() {
        var modal = document.getElementById('editRoomTypeModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }

    // Lắng nghe sự kiện click backdrop và phím Escape
    window.addEventListener('click', function (e) {
        var addModal = document.getElementById('addRoomTypeModal');
        var editModal = document.getElementById('editRoomTypeModal');
        if (e.target === addModal) closeAddRoomTypeModal();
        if (e.target === editModal) closeEditRoomTypeModal();
    });

    window.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            closeAddRoomTypeModal();
            closeEditRoomTypeModal();
        }
    });

    // Gắn trực tiếp event listener cho nút Thêm Hạng Phòng khi DOM sẵn sàng
    document.addEventListener('DOMContentLoaded', function () {
        var btn = document.getElementById('btnOpenAddRoomType');
        if (btn) {
            btn.addEventListener('click', openAddRoomTypeModal);
        }
    });
</script>

<jsp:include page="/views/common/footer.jsp" />