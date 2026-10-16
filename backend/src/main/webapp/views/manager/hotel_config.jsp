<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <jsp:include page="/views/common/header.jsp">
                <jsp:param name="title" value="Cấu Hình Khách Sạn &amp; Biểu Phí" />
            </jsp:include>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manager/manager.css">

            <div class="portal-wrapper">
                <!-- Thanh chức năng bên trái -->
                <jsp:include page="/views/common/portal_sidebar.jsp">
                    <jsp:param name="activeMenu" value="hotel_config" />
                </jsp:include>

                <!-- Màn hình bên phải -->
                <main class="portal-main">
                    <header class="portal-header">
                        <div class="portal-header-left">
                            <h1>Cấu Hình Khách Sạn và Biểu Phí</h1>
                            <p>Quản lý Hạng phòng, Biểu phí phạt/cọc, Danh mục Loại giường, Tiện nghi và Dịch vụ tiêu
                                dùng</p>
                        </div>
                        <div class="portal-header-right">
                        </div>
                    </header>

                    <!-- Thông báo kết quả flash message -->
                    <c:if test="${not empty sessionScope.flashSuccess}">
                        <div
                            style="background: #f0fdf4; border-left: 4px solid #16a34a; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; color: #166534; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                            ${sessionScope.flashSuccess}
                        </div>
                        <c:remove var="flashSuccess" scope="session" />
                    </c:if>
                    <c:if test="${not empty sessionScope.flashError}">
                        <div
                            style="background: #fef2f2; border-left: 4px solid #dc2626; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; color: #991b1b; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                            ${sessionScope.flashError}
                        </div>
                        <c:remove var="flashError" scope="session" />
                    </c:if>

                    <!-- Tab navigation -->
                    <div style="display: flex; gap: 8px; border-bottom: 2px solid #e2e8f0; margin-bottom: 24px;">
                        <button type="button" onclick="switchTab('tab-roomtype')" id="btn-tab-roomtype"
                            style="padding: 12px 20px; font-weight: 700; border: none; background: transparent; cursor: pointer; border-bottom: 3px solid #3b82f6; color: #1d4ed8; font-size: 15px;">
                            1. Hạng Phòng và Biểu Phí
                        </button>
                        <button type="button" onclick="switchTab('tab-bedtype')" id="btn-tab-bedtype"
                            style="padding: 12px 20px; font-weight: 600; border: none; background: transparent; cursor: pointer; border-bottom: 3px solid transparent; color: #64748b; font-size: 15px;">
                            2. Loại Giường (BedType)
                        </button>
                        <button type="button" onclick="switchTab('tab-amenity')" id="btn-tab-amenity"
                            style="padding: 12px 20px; font-weight: 600; border: none; background: transparent; cursor: pointer; border-bottom: 3px solid transparent; color: #64748b; font-size: 15px;">
                            3. Tiện Nghi Buồng Phòng
                        </button>
                        <button type="button" onclick="switchTab('tab-service')" id="btn-tab-service"
                            style="padding: 12px 20px; font-weight: 600; border: none; background: transparent; cursor: pointer; border-bottom: 3px solid transparent; color: #64748b; font-size: 15px;">
                            4. Dịch Vụ Bổ Sung (Service)
                        </button>
                    </div>

                    <!-- TAB 1: HẠNG PHÒNG & BIỂU PHÍ (READONLY TABLE) -->
                    <div id="tab-roomtype" class="config-tab-content">
                        <!-- Bảng Cấu Hình Biểu Phí Chiếm 100% Chiều Rộng Thoải Mái -->
                        <div
                            style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                            <div
                                style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                                        Cấu Hình Hạng Phòng, Biểu Phí &amp; Tiện Ích
                                    </h3>
                                    <p style="margin: 4px 0 0; font-size: 13px; color: #64748b;">
                                        Thông tin hạng phòng được sử dụng tự động trong đặt phòng trực tuyến, tính hóa
                                        đơn và phạt/cọc.
                                    </p>
                                </div>
                                <!-- Nút Mở Modal Thêm Hạng Phòng -->
                                <button type="button" id="btnOpenAddRoomType" class="portal-btn portal-btn-primary"
                                    onclick="openAddRoomTypeModal()"
                                    style="display: flex; align-items: center; gap: 6px; font-weight: 700; padding: 9px 16px;">
                                    Thêm Hạng Phòng Mới
                                </button>
                            </div>

                            <div style="overflow-x: auto;">
                                <table
                                    style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                                    <thead>
                                        <tr
                                            style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                                            <th style="padding: 14px 16px;">Mã Hạng</th>
                                            <th style="padding: 14px 16px;">Tên Hạng Phòng</th>
                                            <th style="padding: 14px 16px; text-align: center;">Sức Chứa</th>
                                            <th style="padding: 14px 16px;">Giường Ngủ</th>
                                            <th style="padding: 14px 16px;">Tiện Nghi Buồng Phòng</th>
                                            <th style="padding: 14px 16px; text-align: right;">Giá Gốc (VND)</th>
                                            <th style="padding: 14px 16px; text-align: right;">Phụ Phí Sớm/Muộn</th>
                                            <th style="padding: 14px 16px; text-align: center;">% Cọc</th>
                                            <th style="padding: 14px 16px; text-align: center;">Trạng Thái</th>
                                            <th style="padding: 14px 16px; text-align: center;">Hành Động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="rt" items="${roomTypes}">
                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="padding: 14px 16px; font-weight: 700; color: #2563eb;">
                                                    ${rt.maLoaiPhong}
                                                </td>
                                                <td style="padding: 14px 16px; font-weight: 600; color: #0f172a;">
                                                    ${rt.tenLoaiPhong}
                                                </td>
                                                <td style="padding: 14px 16px; text-align: center; color: #475569;">
                                                    <span
                                                        style="background: #f1f5f9; padding: 3px 8px; border-radius: 4px; font-size: 12.5px; font-weight: 600;">${rt.soNguoiToiDa}
                                                        người</span>
                                                </td>
                                                <td style="padding: 14px 16px; color: #334155; font-size: 13px;">
                                                    <c:choose>
                                                        <c:when test="${not empty rt.loaiGiuong}">
                                                            <span
                                                                style="color: #1e293b; font-weight: 500;">${rt.loaiGiuong}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #94a3b8; font-style: italic;">Chưa cấu
                                                                hình</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td
                                                    style="padding: 14px 16px; color: #475569; font-size: 13px; max-width: 220px;">
                                                    <c:choose>
                                                        <c:when test="${not empty rt.tienNghi}">
                                                            <span title="${rt.tienNghi}"
                                                                style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; text-overflow: ellipsis;">
                                                                ${rt.tienNghi}
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="color: #94a3b8; font-style: italic;">Chưa cấu
                                                                hình</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td
                                                    style="padding: 14px 16px; text-align: right; font-weight: 700; color: #0f172a;">
                                                    <fmt:formatNumber value="${rt.giaPhong}" pattern="#,##0" /> đ
                                                </td>
                                                <td
                                                    style="padding: 14px 16px; text-align: right; font-size: 12.5px; color: #64748b;">
                                                    +
                                                    <fmt:formatNumber value="${rt.earlyCheckInFee}" pattern="#,##0" /> /
                                                    +
                                                    <fmt:formatNumber value="${rt.lateCheckOutFee}" pattern="#,##0" />
                                                </td>
                                                <td
                                                    style="padding: 14px 16px; text-align: center; font-weight: 600; color: #334155;">
                                                    ${rt.depositPercent}%
                                                </td>
                                                <td style="padding: 14px 16px; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${rt.trangThai == 'Active'}">
                                                            <span class="badge-active">Áp Dụng</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-inactive">Tạm Dừng</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 14px 16px; text-align: center;">
                                                    <button type="button"
                                                        class="portal-btn portal-btn-sm portal-btn-outline-primary btn-edit-roomtype"
                                                        data-id="${rt.maLoaiPhong}" data-name="<c:out value="
                                                        ${rt.tenLoaiPhong}" />"
                                                    data-capacity="${rt.soNguoiToiDa}"
                                                    data-price="${rt.giaPhong}"
                                                    data-early="${rt.earlyCheckInFee}"
                                                    data-late="${rt.lateCheckOutFee}"
                                                    data-deposit="${rt.depositPercent}"
                                                    data-active="${rt.trangThai == 'Active' ? 'true' : 'false'}"
                                                    data-beds="${rt.bedTypeIdsWithQty}"
                                                    data-amenities="${rt.amenityIds}"
                                                    onclick="openEditRoomTypeModal(this)"
                                                    style="padding: 5px 12px; font-size: 13px; font-weight: 600;
                                                    border-radius: 6px; cursor: pointer;">
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

                    <!-- TAB 2: LOẠI GIƯỜNG (BEDTYPE) -->
                    <div id="tab-bedtype" class="config-tab-content" style="display: none;">
                        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
                            <!-- Form Thêm Loại Giường -->
                            <div
                                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                                <h4 style="margin: 0 0 14px; color: #0f172a; font-size: 16px; font-weight: 700;">Thêm
                                    Loại Giường Mới</h4>
                                <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                                    <input type="hidden" name="action" value="add_bedtype" />
                                    <div style="margin-bottom: 16px;">
                                        <label
                                            style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Tên
                                            Loại Giường <span style="color: red;">*</span></label>
                                        <input type="text" name="bedTypeName"
                                            placeholder="Ví dụ: Giường King Size 2m x 2m" required maxlength="50"
                                            style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                                    </div>
                                    <button type="submit" class="btn-add">
                                        Thêm Vào Hệ Thống
                                    </button>
                                </form>
                            </div>

                            <!-- Bảng danh sách Loại Giường -->
                            <div
                                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                                <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                                        Danh Sách Loại Giường Khách Sạn (Bảng BedType - 3NF)
                                    </h3>
                                </div>
                                <table
                                    style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                                    <thead>
                                        <tr
                                            style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                                            <th style="padding: 12px 16px;">Mã Giường</th>
                                            <th style="padding: 12px 16px;">Tên Loại Giường</th>
                                            <th style="padding: 12px 16px; text-align: center;">Trạng Thái</th>
                                            <th style="padding: 12px 16px; text-align: center;">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="b" items="${bedTypes}">
                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="padding: 12px 16px; font-weight: 700; color: #3b82f6;">
                                                    ${b.bedTypeId}</td>
                                                <td style="padding: 12px 16px; font-weight: 600; color: #0f172a;">
                                                    ${b.bedTypeName}</td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${b.active}">
                                                            <span class="badge-active">Đang Dùng</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-inactive">Tạm Khóa</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <form
                                                        action="${pageContext.request.contextPath}/manager/hotel-config"
                                                        method="POST" style="margin: 0;">
                                                        <input type="hidden" name="action" value="toggle_bedtype" />
                                                        <input type="hidden" name="bedTypeId" value="${b.bedTypeId}" />
                                                        <input type="hidden" name="isActive" value="${not b.active}" />
                                                        <c:choose>
                                                            <c:when test="${b.active}">
                                                                <button type="submit" class="btn-lock">Khóa</button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button type="submit" class="btn-unlock">Mở</button>
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

                    <!-- TAB 3: TIỆN NGHI BUỒNG PHÒNG (ROOMSERVICE) -->
                    <div id="tab-amenity" class="config-tab-content" style="display: none;">
                        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
                            <!-- Form Thêm Tiện Nghi -->
                            <div
                                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                                <h4 style="margin: 0 0 14px; color: #0f172a; font-size: 16px; font-weight: 700;">Thêm
                                    Tiện Nghi Buồng Phòng</h4>
                                <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                                    <input type="hidden" name="action" value="add_amenity" />
                                    <div style="margin-bottom: 16px;">
                                        <label
                                            style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Tên
                                            Tiện Nghi <span style="color: red;">*</span></label>
                                        <input type="text" name="amenityName"
                                            placeholder="Ví dụ: Bồn tắm massage cao cấp" required maxlength="100"
                                            style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                                    </div>
                                    <button type="submit" class="btn-add">
                                        Thêm Tiện Nghi
                                    </button>
                                </form>
                            </div>

                            <!-- Bảng danh sách Tiện Nghi -->
                            <div
                                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                                <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                                        Danh Sách Tiện Nghi Trang Bị Buồng Phòng (Bảng RoomService - 3NF)
                                    </h3>
                                </div>
                                <table
                                    style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                                    <thead>
                                        <tr
                                            style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                                            <th style="padding: 12px 16px;">Mã Tiện Nghi</th>
                                            <th style="padding: 12px 16px;">Tên Tiện Nghi</th>
                                            <th style="padding: 12px 16px; text-align: center;">Trạng Thái</th>
                                            <th style="padding: 12px 16px; text-align: center;">Thao Tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="a" items="${amenities}">
                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="padding: 12px 16px; font-weight: 700; color: #3b82f6;">
                                                    ${a.roomServiceId}</td>
                                                <td style="padding: 12px 16px; font-weight: 600; color: #0f172a;">
                                                    ${a.roomServiceName}</td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${a.active}">
                                                            <span class="badge-active">Đang Dùng</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-inactive">Tạm Khóa</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <form
                                                        action="${pageContext.request.contextPath}/manager/hotel-config"
                                                        method="POST" style="margin: 0;">
                                                        <input type="hidden" name="action" value="toggle_amenity" />
                                                        <input type="hidden" name="amenityId"
                                                            value="${a.roomServiceId}" />
                                                        <input type="hidden" name="isActive" value="${not a.active}" />
                                                        <c:choose>
                                                            <c:when test="${a.active}">
                                                                <button type="submit" class="btn-lock">Khóa</button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button type="submit" class="btn-unlock">Mở</button>
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

                    <!-- TAB 4: DỊCH VỤ BỔ SUNG (SERVICE) -->
                    <div id="tab-service" class="config-tab-content" style="display: none;">
                        <!-- Form ẩn cập nhật từng dịch vụ tiêu dùng đặt ngoài bảng -->
                        <c:forEach var="s" items="${services}">
                            <form id="form-srv-${s.maDichVu}"
                                action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                                <input type="hidden" name="action" value="update_service" />
                                <input type="hidden" name="serviceId" value="${s.maDichVu}" />
                            </form>
                        </c:forEach>

                        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
                            <!-- Form Thêm Dịch Vụ -->
                            <div
                                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                                <h4 style="margin: 0 0 14px; color: #0f172a; font-size: 16px; font-weight: 700;">Thêm
                                    Dịch Vụ Tiêu Dùng</h4>
                                <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                                    <input type="hidden" name="action" value="add_service" />
                                    <div style="margin-bottom: 12px;">
                                        <label
                                            style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Tên
                                            Dịch Vụ <span style="color: red;">*</span></label>
                                        <input type="text" name="serviceName"
                                            placeholder="Ví dụ: Tiệc Buffet Sáng Cao Cấp" required maxlength="100"
                                            style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                                    </div>
                                    <div style="margin-bottom: 16px;">
                                        <label
                                            style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Đơn
                                            Giá (VND)</label>
                                        <input type="number" step="1000" name="basePrice" placeholder="Ví dụ: 150000"
                                            required min="0"
                                            style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                                    </div>
                                    <button type="submit" class="btn-add">
                                        Thêm Dịch Vụ
                                    </button>
                                </form>
                            </div>

                            <!-- Bảng danh sách Dịch Vụ -->
                            <div
                                style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                                <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                                        Danh Mục Dịch Vụ Tiêu Dùng Phục Vụ Khách (Bảng Service - 3NF)
                                    </h3>
                                </div>
                                <table
                                    style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                                    <thead>
                                        <tr
                                            style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                                            <th style="padding: 12px 16px;">Mã DV</th>
                                            <th style="padding: 12px 16px;">Tên Dịch Vụ</th>
                                            <th style="padding: 12px 16px; text-align: right;">Đơn Giá (VND)</th>
                                            <th style="padding: 12px 16px; text-align: center;">Trạng Thái</th>
                                            <th style="padding: 12px 16px; text-align: center;">Lưu Cập Nhật</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="s" items="${services}">
                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="padding: 12px 16px; font-weight: 700; color: #3b82f6;">
                                                    ${s.maDichVu}</td>
                                                <td style="padding: 12px 16px; font-weight: 600; color: #0f172a;">
                                                    ${s.tenDichVu}</td>
                                                <td style="padding: 12px 16px; text-align: right;">
                                                    <input type="number" form="form-srv-${s.maDichVu}" step="1000"
                                                        min="0" name="basePrice" value="${s.donGia}" required
                                                        style="width: 110px; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right; font-weight: 600;" />
                                                </td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <select form="form-srv-${s.maDichVu}" name="isActive"
                                                        style="padding: 4px 6px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 12px;">
                                                        <c:choose>
                                                            <c:when test="${s.trangThai == 'Active'}">
                                                                <option value="true" selected="selected">Hoạt Động
                                                                </option>
                                                                <option value="false">Tạm Tắt</option>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <option value="true">Hoạt Động</option>
                                                                <option value="false" selected="selected">Tạm Tắt
                                                                </option>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </select>
                                                </td>
                                                <td style="padding: 12px 16px; text-align: center;">
                                                    <button type="submit" form="form-srv-${s.maDichVu}"
                                                        class="btn-save-sm">
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
                </main>
            </div>

            <!-- ========================================== -->
            <!-- MODAL 1: THÊM HẠNG PHÒNG MỚI (ROOMTYPE)     -->
            <!-- ========================================== -->
            <div id="addRoomTypeModal"
                style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.65); z-index: 99999; align-items: center; justify-content: center; backdrop-filter: blur(2px);">
                <div
                    style="background: #ffffff; border-radius: 12px; width: 680px; max-width: 95%; max-height: 90vh; overflow-y: auto; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
                    <div
                        style="padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; position: sticky; top: 0; z-index: 10;">
                        <h3 style="margin: 0; font-size: 17px; font-weight: 700; color: #0f172a;">Thêm Hạng Phòng Mới
                            (RoomType)</h3>
                        <button type="button" onclick="closeAddRoomTypeModal()"
                            style="background: transparent; border: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1;">&times;</button>
                    </div>

                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST"
                        style="padding: 24px;">
                        <input type="hidden" name="action" value="add_roomtype" />

                        <!-- KHỐI 1: THÔNG TIN HẠNG PHÒNG & GIÁ -->
                        <h4
                            style="margin: 0 0 14px; font-size: 15px; color: #1e293b; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                            1. Thông Tin Chung &amp; Biểu Phí</h4>
                        <!-- Hàng 1: Tên Hạng Phòng & Sức Chứa -->
                        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px; margin-bottom: 14px;">
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #334155;">Tên
                                    Hạng Phòng <span style="color: red;">*</span></label>
                                <input type="text" name="roomTypeName" placeholder="Ví dụ: Executive Ocean Suite"
                                    required maxlength="50"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #334155;">Sức
                                    Chứa (Người) <span style="color: red;">*</span></label>
                                <input type="number" name="capacity" min="1" max="20" value="2" required
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                        </div>
                        <!-- Hàng 2: Giá Gốc & % Đặt Cọc -->
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">Giá
                                    Gốc (VND / Đêm) <span style="color: red;">*</span></label>
                                <input type="number" step="1000" name="basePrice" placeholder="1500000" required min="0"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">%
                                    Đặt Cọc (0 - 100) <span style="color: red;">*</span></label>
                                <input type="number" name="depositPercent" value="30" min="0" max="100" required
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                        </div>
                        <!-- Hàng 3: Phí Nhận Sớm & Phí Trả Muộn -->
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">Phí
                                    Nhận Sớm (VND)</label>
                                <input type="number" step="1000" name="earlyFee" value="0" required min="0"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">Phí
                                    Trả Muộn (VND)</label>
                                <input type="number" step="1000" name="lateFee" value="0" required min="0"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                        </div>

                        <!-- KHỐI 2: CẤU HÌNH LOẠI GIƯỜNG (BẢNG ĐỘNG) -->
                        <div
                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #1e293b;">2. Cấu Hình Loại Giường Ngủ</h4>
                            <button type="button" class="portal-btn portal-btn-sm portal-btn-outline-primary"
                                onclick="addBedRow('add')"
                                style="padding: 5px 12px; font-weight: 600; font-size: 13px;">
                                Thêm Loại Giường
                            </button>
                        </div>
                        <div
                            style="border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden; margin-bottom: 20px;">
                            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                <thead style="background: #f1f5f9; border-bottom: 1px solid #cbd5e1; color: #475569;">
                                    <tr>
                                        <th style="padding: 10px 12px; text-align: left;">Loại Giường</th>
                                        <th style="padding: 10px 12px; text-align: center; width: 140px;">Số Lượng</th>
                                        <th style="padding: 10px 12px; text-align: center; width: 80px;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody id="addBedTableBody">
                                </tbody>
                            </table>
                        </div>

                        <!-- KHỐI 3: TIỆN NGHI BUỒNG PHÒNG (BẢNG ĐỘNG) -->
                        <div
                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #1e293b;">3. Tiện Nghi Trang Bị Cho Hạng Phòng
                            </h4>
                            <button type="button" class="portal-btn portal-btn-sm portal-btn-outline-primary"
                                onclick="addAmenityRow('add')"
                                style="padding: 5px 12px; font-weight: 600; font-size: 13px;">
                                Thêm Tiện Nghi
                            </button>
                        </div>
                        <div
                            style="border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden; margin-bottom: 24px;">
                            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                <thead style="background: #f1f5f9; border-bottom: 1px solid #cbd5e1; color: #475569;">
                                    <tr>
                                        <th style="padding: 10px 12px; text-align: left;">Tiện Nghi Buồng Phòng</th>
                                        <th style="padding: 10px 12px; text-align: center; width: 80px;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody id="addAmenityTableBody">
                                </tbody>
                            </table>
                        </div>

                        <div
                            style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                            <button type="button" class="portal-btn portal-btn-secondary"
                                onclick="closeAddRoomTypeModal()">Hủy Bỏ</button>
                            <button type="submit" class="portal-btn portal-btn-success" style="font-weight: 700;">Lưu
                                Hạng Phòng Vào Hệ Thống</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- MODAL 2: CHỈNH SỬA HẠNG PHÒNG (ROOMTYPE)    -->
            <!-- ========================================== -->
            <div id="editRoomTypeModal"
                style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.65); z-index: 99999; align-items: center; justify-content: center; backdrop-filter: blur(2px);">
                <div
                    style="background: #ffffff; border-radius: 12px; width: 680px; max-width: 95%; max-height: 90vh; overflow-y: auto; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);">
                    <div
                        style="padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc; position: sticky; top: 0; z-index: 10;">
                        <h3 style="margin: 0; font-size: 17px; font-weight: 700; color: #0f172a;">Chỉnh Sửa Hạng Phòng
                            &amp; Biểu Phí</h3>
                        <button type="button" onclick="closeEditRoomTypeModal()"
                            style="background: transparent; border: none; font-size: 24px; cursor: pointer; color: #64748b; line-height: 1;">&times;</button>
                    </div>

                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST"
                        style="padding: 24px;">
                        <input type="hidden" name="action" value="update_roomtype" />
                        <input type="hidden" name="roomTypeId" id="editRoomTypeId" />

                        <!-- Khối Mã Hạng Phòng (Khóa, chỉ xem) -->
                        <div
                            style="display: flex; align-items: center; gap: 12px; background: #f1f5f9; border: 1px solid #cbd5e1; border-radius: 8px; padding: 10px 14px; margin-bottom: 20px;">
                            <span style="font-size: 13px; font-weight: 600; color: #475569;">MÃ HẠNG PHÒNG:</span>
                            <input type="text" id="editRoomTypeCodeDisplay" disabled
                                style="background: transparent; border: none; font-size: 15px; font-weight: 700; color: #1e40af; outline: none;" />
                            <span style="margin-left: auto; font-size: 12px; color: #64748b;">(Mã định danh duy nhất -
                                Không thể đổi)</span>
                        </div>

                        <!-- KHỐI 1: THÔNG TIN CHUNG & BIỂU PHÍ -->
                        <h4
                            style="margin: 0 0 12px; font-size: 15px; color: #1e293b; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">
                            1. Thông Tin Chung &amp; Biểu Phí</h4>
                        <div style="display: grid; grid-template-columns: 2fr 1fr 1fr; gap: 14px; margin-bottom: 14px;">
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #334155;">Tên
                                    Hạng Phòng <span style="color: red;">*</span></label>
                                <input type="text" name="roomTypeName" id="editRoomTypeName" required maxlength="50"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #334155;">Sức
                                    Chứa (Người) <span style="color: red;">*</span></label>
                                <input type="number" name="capacity" id="editCapacity" min="1" max="20" required
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #334155;">Trạng
                                    Thái</label>
                                <select name="isActive" id="editIsActive"
                                    style="width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box; font-size: 13px;">
                                    <option value="true">Áp Dụng</option>
                                    <option value="false">Tạm Dừng</option>
                                </select>
                            </div>
                        </div>

                        <!-- Hàng 2: Giá Gốc & % Đặt Cọc -->
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 14px;">
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">Giá
                                    Gốc (VND/Đêm) <span style="color: red;">*</span></label>
                                <input type="number" step="1000" name="basePrice" id="editBasePrice" required min="0"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">%
                                    Đặt Cọc (0 - 100) <span style="color: red;">*</span></label>
                                <input type="number" name="depositPercent" id="editDepositPercent" min="0" max="100"
                                    required
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                        </div>
                        <!-- Hàng 3: Phí Nhận Sớm & Phí Trả Muộn -->
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 20px;">
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">Phí
                                    Nhận Sớm (VND)</label>
                                <input type="number" step="1000" name="earlyFee" id="editEarlyFee" required min="0"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                            <div>
                                <label
                                    style="display: block; font-size: 13px; font-weight: 600; margin-bottom: 4px; color: #475569;">Phí
                                    Trả Muộn (VND)</label>
                                <input type="number" step="1000" name="lateFee" id="editLateFee" required min="0"
                                    style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                            </div>
                        </div>

                        <!-- KHỐI 2: CẤU HÌNH LOẠI GIƯỜNG (BẢNG ĐỘNG) -->
                        <div
                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #1e293b;">2. Cấu Hình Loại Giường Ngủ</h4>
                            <button type="button" class="portal-btn portal-btn-sm portal-btn-outline-primary"
                                onclick="addBedRow('edit')"
                                style="padding: 5px 12px; font-weight: 600; font-size: 13px;">
                                Thêm Loại Giường
                            </button>
                        </div>
                        <div
                            style="border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden; margin-bottom: 20px;">
                            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                <thead style="background: #f1f5f9; border-bottom: 1px solid #cbd5e1; color: #475569;">
                                    <tr>
                                        <th style="padding: 10px 12px; text-align: left;">Loại Giường</th>
                                        <th style="padding: 10px 12px; text-align: center; width: 140px;">Số Lượng</th>
                                        <th style="padding: 10px 12px; text-align: center; width: 80px;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody id="editBedTableBody">
                                </tbody>
                            </table>
                        </div>

                        <!-- KHỐI 3: TIỆN NGHI BUỒNG PHÒNG (BẢNG ĐỘNG) -->
                        <div
                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h4 style="margin: 0; font-size: 15px; color: #1e293b;">3. Tiện Nghi Trang Bị Cho Hạng Phòng
                            </h4>
                            <button type="button" class="portal-btn portal-btn-sm portal-btn-outline-primary"
                                onclick="addAmenityRow('edit')"
                                style="padding: 5px 12px; font-weight: 600; font-size: 13px;">
                                Thêm Tiện Nghi
                            </button>
                        </div>
                        <div
                            style="border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden; margin-bottom: 24px;">
                            <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                <thead style="background: #f1f5f9; border-bottom: 1px solid #cbd5e1; color: #475569;">
                                    <tr>
                                        <th style="padding: 10px 12px; text-align: left;">Tiện Nghi Buồng Phòng</th>
                                        <th style="padding: 10px 12px; text-align: center; width: 80px;">Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody id="editAmenityTableBody">
                                </tbody>
                            </table>
                        </div>

                        <div
                            style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #e2e8f0; padding-top: 16px;">
                            <button type="button" class="portal-btn portal-btn-secondary"
                                onclick="closeEditRoomTypeModal()">Hủy Bỏ</button>
                            <button type="submit" class="portal-btn portal-btn-primary" style="font-weight: 700;">Cập
                                Nhật Hạng Phòng</button>
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
                        el.style.display = 'none';
                    });
                    document.querySelectorAll('[id^="btn-tab-"]').forEach(function (btn) {
                        btn.style.borderBottomColor = 'transparent';
                        btn.style.color = '#64748b';
                        btn.style.fontWeight = '600';
                    });

                    document.getElementById(tabId).style.display = 'block';
                    var activeBtn = document.getElementById('btn-' + tabId);
                    if (activeBtn) {
                        activeBtn.style.borderBottomColor = '#3b82f6';
                        activeBtn.style.color = '#1d4ed8';
                        activeBtn.style.fontWeight = '700';
                    }
                }

                function addBedRow(mode, selectedBedId, qtyVal) {
                    var tbody = document.getElementById(mode + 'BedTableBody');
                    if (!tbody) return;
                    var row = document.createElement('tr');
                    row.style.borderBottom = '1px solid #e2e8f0';

                    var qty = (qtyVal && parseInt(qtyVal, 10) > 0) ? parseInt(qtyVal, 10) : 1;
                    var initialBedId = selectedBedId || '';

                    row.innerHTML =
                        '<td style="padding: 8px 12px;">' +
                        '<select name="selectedBedTypes" required onchange="onBedSelectChange(this)" style="width: 100%; padding: 6px 10px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 13px;">' +
                        bedOptionsHtml +
                        '</select>' +
                        '</td>' +
                        '<td style="padding: 8px 12px; text-align: center;">' +
                        '<input type="number" class="bed-qty-input" name="bedQty_' + initialBedId + '" value="' + qty + '" min="1" step="1" required ' +
                        'onkeydown="if(event.key===\'.\'||event.key===\'-\'||event.key===\'e\'||event.key===\'+\')event.preventDefault();" ' +
                        'oninput="validatePositiveInt(this)" onblur="ensurePositiveInt(this)" style="width: 100px; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: center; font-size: 13px; font-weight: 600;" />' +
                        '</td>' +
                        '<td style="padding: 8px 12px; text-align: center;">' +
                        '<button type="button" class="portal-btn portal-btn-sm portal-btn-secondary" onclick="this.closest(\'tr\').remove()" style="padding: 4px 10px; font-size: 12px;">Xóa</button>' +
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
                    row.style.borderBottom = '1px solid #e2e8f0';

                    row.innerHTML =
                        '<td style="padding: 8px 12px;">' +
                        '<select name="selectedAmenities" required style="width: 100%; padding: 6px 10px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 13px;">' +
                        amenityOptionsHtml +
                        '</select>' +
                        '</td>' +
                        '<td style="padding: 8px 12px; text-align: center;">' +
                        '<button type="button" class="portal-btn portal-btn-sm portal-btn-secondary" onclick="this.closest(\'tr\').remove()" style="padding: 4px 10px; font-size: 12px;">Xóa</button>' +
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