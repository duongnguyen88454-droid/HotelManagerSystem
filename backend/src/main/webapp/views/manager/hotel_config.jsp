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
                <p>Quản lý Hạng phòng, Biểu phí phạt/cọc, Danh mục Loại giường, Tiện nghi và Dịch vụ tiêu dùng</p>
            </div>
            <div class="portal-header-right">
                <a href="${pageContext.request.contextPath}/manager/dashboard" class="portal-btn portal-btn-secondary">
                    Quay Lại Dashboard
                </a>
            </div>
        </header>

    <!-- Thông báo kết quả flash message -->
    <c:if test="${not empty sessionScope.flashSuccess}">
        <div style="background: #f0fdf4; border-left: 4px solid #16a34a; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; color: #166534; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
            ${sessionScope.flashSuccess}
        </div>
        <c:remove var="flashSuccess" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.flashError}">
        <div style="background: #fef2f2; border-left: 4px solid #dc2626; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; color: #991b1b; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
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

    <!-- TAB 1: HẠNG PHÒNG & BIỂU PHÍ -->
    <div id="tab-roomtype" class="config-tab-content">
        <!-- Form ẩn cập nhật từng loại phòng đặt ngoài bảng để chuẩn hóa DOM -->
        <c:forEach var="rt" items="${roomTypes}">
            <form id="form-rt-${rt.maLoaiPhong}" action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                <input type="hidden" name="action" value="update_roomtype" />
                <input type="hidden" name="roomTypeId" value="${rt.maLoaiPhong}" />
            </form>
        </c:forEach>

        <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
            <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                    Cấu Hình Giá Phòng, Phụ Phí Check-in/out và Tỷ Lệ Đặt Cọc
                </h3>
                <p style="margin: 4px 0 0; font-size: 13px; color: #64748b;">
                    Các giá trị này được sử dụng tự động trong tính tiền hóa đơn (Invoice) và hủy phòng hoàn cọc (CancellationHistory).
                </p>
            </div>

            <div style="overflow-x: auto;">
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                    <thead>
                        <tr style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                            <th style="padding: 14px 16px;">Mã Hạng</th>
                            <th style="padding: 14px 16px;">Tên Hạng Phòng</th>
                            <th style="padding: 14px 16px; text-align: center;">Sức Chứa</th>
                            <th style="padding: 14px 16px; text-align: right;">Giá Gốc (VND)</th>
                            <th style="padding: 14px 16px; text-align: right;">Phí Nhận Sớm</th>
                            <th style="padding: 14px 16px; text-align: right;">Phí Trả Muộn</th>
                            <th style="padding: 14px 16px; text-align: center;">% Đặt Cọc</th>
                            <th style="padding: 14px 16px; text-align: center;">Trạng Thái</th>
                            <th style="padding: 14px 16px; text-align: center;">Cập Nhật</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="rt" items="${roomTypes}">
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 14px 16px; font-weight: 700; color: #3b82f6;">
                                    ${rt.maLoaiPhong}
                                </td>
                                <td style="padding: 14px 16px; font-weight: 600; color: #0f172a;">
                                    ${rt.tenLoaiPhong}
                                </td>
                                <td style="padding: 14px 16px; text-align: center; color: #64748b;">
                                    ${rt.soNguoiToiDa} người
                                </td>
                                <td style="padding: 14px 16px; text-align: right;">
                                    <input type="number" form="form-rt-${rt.maLoaiPhong}" step="1000" name="basePrice" value="${rt.giaPhong}" required
                                           style="width: 110px; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right; font-weight: 600;" />
                                </td>
                                <td style="padding: 14px 16px; text-align: right;">
                                    <input type="number" form="form-rt-${rt.maLoaiPhong}" step="1000" name="earlyFee" value="${rt.earlyCheckInFee}" required
                                           style="width: 95px; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;" />
                                </td>
                                <td style="padding: 14px 16px; text-align: right;">
                                    <input type="number" form="form-rt-${rt.maLoaiPhong}" step="1000" name="lateFee" value="${rt.lateCheckOutFee}" required
                                           style="width: 95px; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right;" />
                                </td>
                                <td style="padding: 14px 16px; text-align: center;">
                                    <input type="number" form="form-rt-${rt.maLoaiPhong}" step="1" min="0" max="100" name="depositPercent" value="${rt.depositPercent}" required
                                           style="width: 60px; padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: center;" /> %
                                </td>
                                <td style="padding: 14px 16px; text-align: center;">
                                    <select form="form-rt-${rt.maLoaiPhong}" name="isActive" style="padding: 6px 8px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 13px;">
                                        <c:choose>
                                            <c:when test="${rt.trangThai == 'Active'}">
                                                <option value="true" selected="selected">Áp Dụng</option>
                                                <option value="false">Tạm Dừng</option>
                                            </c:when>
                                            <c:otherwise>
                                                <option value="true">Áp Dụng</option>
                                                <option value="false" selected="selected">Tạm Dừng</option>
                                            </c:otherwise>
                                        </c:choose>
                                    </select>
                                </td>
                                <td style="padding: 14px 16px; text-align: center;">
                                    <button type="submit" form="form-rt-${rt.maLoaiPhong}" class="btn-save">
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

    <!-- TAB 2: LOẠI GIƯỜNG (BEDTYPE) -->
    <div id="tab-bedtype" class="config-tab-content" style="display: none;">
        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
            <!-- Form Thêm Loại Giường -->
            <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                <h4 style="margin: 0 0 14px; color: #0f172a; font-size: 16px; font-weight: 700;">Thêm Loại Giường Mới</h4>
                <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                    <input type="hidden" name="action" value="add_bedtype" />
                    <div style="margin-bottom: 12px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Mã Loại Giường</label>
                        <input type="text" name="bedTypeId" placeholder="Ví dụ: KING, QUEEN, SINGLE..." required maxlength="10"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Tên Loại Giường</label>
                        <input type="text" name="bedTypeName" placeholder="Ví dụ: Giường King Size 2m x 2m" required maxlength="50"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <button type="submit" class="btn-add">
                        Thêm Vào Hệ Thống
                    </button>
                </form>
            </div>

            <!-- Bảng danh sách Loại Giường -->
            <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                        Danh Sách Loại Giường Khách Sạn (Bảng BedType - 3NF)
                    </h3>
                </div>
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                    <thead>
                        <tr style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                            <th style="padding: 12px 16px;">Mã Giường</th>
                            <th style="padding: 12px 16px;">Tên Loại Giường</th>
                            <th style="padding: 12px 16px; text-align: center;">Trạng Thái</th>
                            <th style="padding: 12px 16px; text-align: center;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="b" items="${bedTypes}">
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 12px 16px; font-weight: 700; color: #3b82f6;">${b.bedTypeId}</td>
                                <td style="padding: 12px 16px; font-weight: 600; color: #0f172a;">${b.bedTypeName}</td>
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
                                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST" style="margin: 0;">
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
            <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                <h4 style="margin: 0 0 14px; color: #0f172a; font-size: 16px; font-weight: 700;">Thêm Tiện Nghi Buồng Phòng</h4>
                <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                    <input type="hidden" name="action" value="add_amenity" />
                    <div style="margin-bottom: 12px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Mã Tiện Nghi</label>
                        <input type="text" name="amenityId" placeholder="Ví dụ: SMART_TV, BATHTUB, BALCONY..." required maxlength="10"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Tên Tiện Nghi</label>
                        <input type="text" name="amenityName" placeholder="Ví dụ: Bồn tắm massage cao cấp" required maxlength="100"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <button type="submit" class="btn-add">
                        Thêm Tiện Nghi
                    </button>
                </form>
            </div>

            <!-- Bảng danh sách Tiện Nghi -->
            <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                        Danh Sách Tiện Nghi Trang Bị Buồng Phòng (Bảng RoomService - 3NF)
                    </h3>
                </div>
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                    <thead>
                        <tr style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
                            <th style="padding: 12px 16px;">Mã Tiện Nghi</th>
                            <th style="padding: 12px 16px;">Tên Tiện Nghi</th>
                            <th style="padding: 12px 16px; text-align: center;">Trạng Thái</th>
                            <th style="padding: 12px 16px; text-align: center;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${amenities}">
                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                <td style="padding: 12px 16px; font-weight: 700; color: #3b82f6;">${a.roomServiceId}</td>
                                <td style="padding: 12px 16px; font-weight: 600; color: #0f172a;">${a.roomServiceName}</td>
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
                                    <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST" style="margin: 0;">
                                        <input type="hidden" name="action" value="toggle_amenity" />
                                        <input type="hidden" name="amenityId" value="${a.roomServiceId}" />
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
            <form id="form-srv-${s.maDichVu}" action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                <input type="hidden" name="action" value="update_service" />
                <input type="hidden" name="serviceId" value="${s.maDichVu}" />
            </form>
        </c:forEach>

        <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
            <!-- Form Thêm Dịch Vụ -->
            <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); height: fit-content;">
                <h4 style="margin: 0 0 14px; color: #0f172a; font-size: 16px; font-weight: 700;">Thêm Dịch Vụ Tiêu Dùng</h4>
                <form action="${pageContext.request.contextPath}/manager/hotel-config" method="POST">
                    <input type="hidden" name="action" value="add_service" />
                    <div style="margin-bottom: 12px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Mã Dịch Vụ</label>
                        <input type="text" name="serviceId" placeholder="Ví dụ: SRV_BUFFET, SRV_SPA..." required maxlength="10"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <div style="margin-bottom: 12px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Tên Dịch Vụ</label>
                        <input type="text" name="serviceName" placeholder="Ví dụ: Tiệc Buffet Sáng Cao Cấp" required maxlength="100"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 13px; font-weight: 600; color: #475569; margin-bottom: 4px;">Đơn Giá (VND)</label>
                        <input type="number" step="1000" name="basePrice" placeholder="Ví dụ: 150000" required min="0"
                               style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box;" />
                    </div>
                    <button type="submit" class="btn-add">
                        Thêm Dịch Vụ
                    </button>
                </form>
            </div>

            <!-- Bảng danh sách Dịch Vụ -->
            <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
                <div style="padding: 16px 20px; border-bottom: 1px solid #e2e8f0; background: #f8fafc;">
                    <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: #1e293b;">
                        Danh Mục Dịch Vụ Tiêu Dùng Phục Vụ Khách (Bảng Service - 3NF)
                    </h3>
                </div>
                <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 14px;">
                    <thead>
                        <tr style="background: #ffffff; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 600;">
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
                                <td style="padding: 12px 16px; font-weight: 700; color: #3b82f6;">${s.maDichVu}</td>
                                <td style="padding: 12px 16px; font-weight: 600; color: #0f172a;">${s.tenDichVu}</td>
                                <td style="padding: 12px 16px; text-align: right;">
                                    <input type="number" form="form-srv-${s.maDichVu}" step="1000" min="0" name="basePrice" value="${s.donGia}" required
                                           style="width: 110px; padding: 4px 8px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: right; font-weight: 600;" />
                                </td>
                                <td style="padding: 12px 16px; text-align: center;">
                                    <select form="form-srv-${s.maDichVu}" name="isActive" style="padding: 4px 6px; border: 1px solid #cbd5e1; border-radius: 4px; font-size: 12px;">
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
                                <td style="padding: 12px 16px; text-align: center;">
                                    <button type="submit" form="form-srv-${s.maDichVu}" class="btn-save-sm">
                                        Lưu
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
    </div>
    </main>
</div>

<script>
function switchTab(tabId) {
    document.querySelectorAll('.config-tab-content').forEach(function(el) {
        el.style.display = 'none';
    });
    document.querySelectorAll('[id^="btn-tab-"]').forEach(function(btn) {
        btn.style.borderBottomColor = 'transparent';
        btn.style.color = '#64748b';
        btn.style.fontWeight = '600';
    });

    document.getElementById(tabId).style.display = 'block';
    var activeBtn = document.getElementById('btn-' + tabId);
    activeBtn.style.borderBottomColor = '#3b82f6';
    activeBtn.style.color = '#1d4ed8';
    activeBtn.style.fontWeight = '700';
}
</script>

<jsp:include page="/views/common/footer.jsp" />