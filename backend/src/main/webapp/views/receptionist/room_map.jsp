<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Danh Sách &amp; Tình Trạng Phòng" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="receptionist/room_map.css" />
</jsp:include>

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="room_map" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <c:if test="${param.depositPaid eq 'true'}">
            <div class="alert alert-success">
                Đã ghi nhận giữ chỗ và thu tiền đặt cọc thành công cho đơn đặt phòng ${param.bookingSuccess}!
            </div>
        </c:if>

        <!-- Thẻ tìm kiếm & danh sách phòng -->
        <div class="card card-flush">
            <div class="card-toolbar">
                <div class="flex items-center gap-3 flex-wrap">
                    <div class="flex" style="border: 1px solid var(--color-border); border-radius: var(--radius-md); overflow: hidden;">
                        <a href="${pageContext.request.contextPath}/receptionist/timeline" class="btn btn-secondary btn-sm" style="border-radius: 0;">Lưới Timeline</a>
                        <span class="btn btn-primary btn-sm" style="border-radius: 0;">Sơ Đồ Phòng</span>
                    </div>
                    <input type="text" id="filterKeyword" class="form-control" placeholder="Tìm tên khách, SĐT, số phòng, mã BK..." style="max-width: 320px;" oninput="applyFilter()">
                    <button type="button" class="btn btn-secondary btn-sm" onclick="resetFilter()">Đặt Lại</button>
                </div>

                <!-- Chú thích trạng thái -->
                <div class="flex items-center gap-2">
                    <span class="badge badge-success">Trống Sẵn Sàng</span>
                    <span class="badge badge-danger">Đang Có Khách</span>
                    <span class="badge badge-info">Đang Dọn</span>
                    <span class="badge badge-neutral">Hư Hại / Bảo Trì</span>
                </div>
            </div>

            <!-- Bảng danh sách phòng -->
            <div class="table-wrapper">
                <table class="table">
                    <thead>
                        <tr>
                            <th style="width: 140px;">Phòng</th>
                            <th>Hạng Phòng</th>
                            <th class="text-center" style="width: 140px;">Trạng Thái</th>
                            <th>Thông Tin Lưu Trú / Đặt Trước</th>
                            <th class="text-center" style="width: 180px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="timelineBody">
                        <c:set var="prevFloor" value="0" />
                        <c:forEach items="${roomList}" var="r">
                            <c:if test="${r.soTang ne prevFloor}">
                                <c:set var="prevFloor" value="${r.soTang}" />
                                <tr class="floor-row" data-floor="T${r.soTang}" style="background: var(--color-surface-alt); font-weight: 700;">
                                    <td colspan="5" class="text-secondary">
                                        Tầng ${r.soTang}
                                    </td>
                                </tr>
                            </c:if>
                            <tr class="room-row" data-floor="T${r.soTang}" data-status="${r.trangThaiPhong}" data-room="${r.maPhong}">
                                <td>
                                    <strong class="text-primary text-md">${r.soPhong}</strong>
                                    <div class="text-xs text-muted mono">Mã: ${r.maPhong}</div>
                                </td>
                                <td>
                                    <span class="fw-semibold text-secondary">${r.tenLoaiPhong}</span>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${r.trangThaiPhong eq 'Available'}">
                                            <span class="badge badge-success">Trống Sạch</span>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Occupied'}">
                                            <span class="badge badge-danger">Đang Ở</span>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Cleaning' or r.trangThaiPhong eq 'Dirty'}">
                                            <span class="badge badge-info">Đang Dọn</span>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Damaged'}">
                                            <span class="badge badge-neutral">Hư Hại</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-neutral">${r.trangThaiBadgeText}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty r.bookingBars}">
                                            <c:forEach items="${r.bookingBars}" var="bar">
                                                <div class="text-sm mb-1">
                                                    <strong class="text-primary">${bar.tenKhachHang}</strong>
                                                    <span class="text-muted mono">(${bar.maBooking})</span>: 
                                                    <span class="mono">${bar.ngayNhanDuKien} - ${bar.ngayTraDuKien}</span>
                                                    <c:if test="${bar.trangThaiBooking eq 'CheckedIn'}">
                                                        <span class="badge badge-danger text-xs ml-1">Đang ở</span>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted text-sm">Chưa có khách đặt trong tuần</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${not empty r.bookingBars}">
                                            <c:forEach items="${r.bookingBars}" var="bar" end="0">
                                                <div class="flex items-center justify-center gap-1">
                                                    <button type="button" class="btn btn-primary btn-sm"
                                                            onclick="handleBookingBarClick('${r.maPhong}', '${r.soPhong}', '${bar.maBooking}', '${bar.tenKhachHang}', '${bar.soDienThoai}', '${bar.soCccd}', '${bar.trangThaiBooking}', '${bar.ngayNhanDuKien}', '${bar.ngayTraDuKien}', '${bar.formattedNgayCheckInThucTe}', '${bar.formattedNgayCheckOutThucTe}')">
                                                        Chi Tiết Đơn
                                                    </button>
                                                    <c:if test="${bar.trangThaiBooking eq 'CheckedIn' or r.trangThaiPhong eq 'Occupied'}">
                                                        <button type="button" class="btn btn-success btn-sm"
                                                                onclick="openServiceOrderForRoom('${r.maPhong}', '${r.soPhong}')"
                                                                title="Gọi thêm đồ ăn, đồ uống hoặc dịch vụ cho phòng ${r.soPhong}">
                                                            + Dịch Vụ
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Available'}">
                                            <a href="${pageContext.request.contextPath}/receptionist/booking" class="btn btn-secondary btn-sm">
                                                Đặt Phòng
                                            </a>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Occupied'}">
                                            <button type="button" class="btn btn-success btn-sm"
                                                    onclick="openServiceOrderForRoom('${r.maPhong}', '${r.soPhong}')"
                                                    title="Gọi thêm đồ ăn, đồ uống hoặc dịch vụ cho phòng ${r.soPhong}">
                                                + Dịch Vụ
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted text-sm">--</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty roomList}">
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <p>Chưa có dữ liệu phòng nào trong hệ thống.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- ========================================================================= -->
<!-- POPUP MODAL NỔI TRUNG TÂM: THÔNG TIN BOOKING & PHÒNG                      -->
<!-- ========================================================================= -->
<div id="bookingModal" class="modal-backdrop">
    <div class="modal-card modal-lg">
        <div class="modal-head" id="bookingModalHead">
            <h3 id="bookingModalTitle">Thông Tin Chi Tiết Đặt Phòng</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('bookingModal')">Đóng</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="bmRoomIdVal" value="">
            <input type="hidden" id="bmRoomNoVal" value="">
            <input type="hidden" id="bmBookingIdVal" value="">

            <div class="card mb-4" style="background: var(--color-surface-alt);">
                <div class="card-body">
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Mã Booking</span>
                            <span class="detail-value mono" id="bmBookingId">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Phòng bàn giao</span>
                            <span class="detail-value text-success fw-bold" id="bmRoomId">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Khách đại diện</span>
                            <span class="detail-value fw-bold text-primary" id="bmGuestName">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Số điện thoại</span>
                            <span class="detail-value mono" id="bmPhone">--</span>
                        </div>
                        <div class="detail-item" style="grid-column: span 2;">
                            <span class="detail-label">Số CCCD</span>
                            <span class="detail-value mono" id="bmCccd">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Ngày nhận dự kiến</span>
                            <span class="detail-value mono" id="bmInDate">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Ngày trả dự kiến</span>
                            <span class="detail-value mono" id="bmOutDate">--</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Ngày nhận thực tế</span>
                            <span class="detail-value text-success mono" id="bmActualIn">___</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Ngày trả thực tế</span>
                            <span class="detail-value text-muted mono" id="bmActualOut">___</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- DỊCH VỤ PHÁT SINH & THANH TOÁN -->
            <div id="occupiedArea">
                <div class="fw-bold mb-2">DANH SÁCH DỊCH VỤ PHÁT SINH TẠI PHÒNG:</div>
                <div class="table-wrapper mb-3">
                    <table class="table" id="usedServiceTable">
                        <thead>
                            <tr>
                                <th>Tên Dịch Vụ</th>
                                <th class="text-center" style="width: 60px;">SL</th>
                                <th class="text-right" style="width: 120px;">Đơn Giá</th>
                                <th class="text-right" style="width: 130px;">Thành Tiền</th>
                            </tr>
                        </thead>
                        <tbody id="usedServiceList">
                            <tr>
                                <td colspan="4" class="text-center text-muted" style="font-style: italic;">Chưa có dịch vụ phát sinh nào cho phòng này.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="text-right mb-4">
                    Tổng tiền dịch vụ: <strong class="text-danger mono text-md" id="totalServiceCost">0 đ</strong>
                </div>

                <div class="card mb-4" style="background: var(--color-primary-soft); border-color: var(--color-info-border);">
                    <div class="card-body">
                        <div class="flex justify-between mb-2">
                            <span>Tiền phòng lưu trú:</span>
                            <strong id="dtlRoomCost" class="mono">Tính theo biểu phí phòng</strong>
                        </div>
                        <div class="flex justify-between mb-2">
                            <span>Tiền dịch vụ phát sinh:</span>
                            <strong class="text-danger mono" id="dtlServiceCostSummary">0 đ</strong>
                        </div>
                        <hr style="margin: var(--space-2) 0; border: none; border-top: 1px solid var(--color-border);" />
                        <div class="flex justify-between text-md">
                            <strong>Tổng thanh toán dự kiến khi Check-out:</strong>
                            <strong class="text-primary mono" id="finalBalance">Quyết toán khi trả phòng</strong>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-foot">
            <a id="btnGoToCheckIn" href="#" class="btn btn-success is-hidden">Chuyển sang Quầy Check-in</a>
            <button type="button" id="btnOrderService" class="btn btn-primary" onclick="switchToOrderServiceModal()">Thêm Dịch Vụ Phòng</button>
            <button type="button" id="btnCheckOut" class="btn btn-danger" onclick="goToCheckOutCashier()">Check-out Trả Phòng</button>
            <button type="button" class="btn btn-secondary" onclick="closeModal('bookingModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- POPUP MODAL: GỌI THÊM ĐỒ ĂN / DỊCH VỤ TẠI PHÒNG                           -->
<!-- ========================================================================= -->
<div id="orderServiceModal" class="modal-backdrop">
    <div class="modal-card modal-md">
        <div class="modal-head">
            <h3 id="modalOrderServiceTitle">Gọi Thêm Đồ Uống / Dịch Vụ Tại Phòng</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('orderServiceModal')">Đóng</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="ordRoomId" value="">
            <input type="hidden" id="ordBookingId" value="">

            <div class="form-group">
                <label class="form-label">1. Chọn Món / Dịch Vụ Cụ Thể:</label>
                <select id="serviceSelect" class="form-control" onchange="updatePriceCalculation()">
                    <c:choose>
                        <c:when test="${not empty serviceList}">
                            <c:forEach var="svc" items="${serviceList}" varStatus="status">
                                <option value="${svc.maDichVu}" data-price="${svc.donGia}" data-unit="Lượt" ${status.first ? 'selected' : ''}>
                                    ${svc.tenDichVu} (${svc.maDichVu}) - <fmt:formatNumber value="${svc.donGia}" pattern="#,##0" /> đ
                                </option>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <option value="SRV005" data-price="15000" data-unit="Lon" selected>Nước Khoáng Đóng Chai (SRV005) - 15.000 đ/Lon</option>
                            <option value="SRV001" data-price="120000" data-unit="Suất">Buffet Sáng Cao Cấp (SRV001) - 120.000 đ/Suất</option>
                            <option value="SRV002" data-price="50000" data-unit="Bộ">Giặt Là Lấy Ngay (SRV002) - 50.000 đ/Bộ</option>
                            <option value="SRV003" data-price="250000" data-unit="Chuyến">Đưa Đón Sân Bay Chu Đáo (SRV003) - 250.000 đ/Chuyến</option>
                            <option value="SRV004" data-price="350000" data-unit="Lượt">Gói Massage &amp; Spa Thư Giãn (SRV004) - 350.000 đ/Lượt</option>
                            <option value="SRV006" data-price="20000" data-unit="Lon">Nước Ngọt Lon Tiện Lợi (SRV006) - 20.000 đ/Lon</option>
                        </c:otherwise>
                    </c:choose>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">2. Số Lượng:</label>
                <div class="flex items-center gap-2">
                    <button type="button" class="btn btn-secondary btn-sm" onclick="adjustQty(-1)">-</button>
                    <input type="number" id="orderQty" class="form-control text-center fw-bold" value="1" min="1" max="20" style="width: 70px;" onchange="updatePriceCalculation()">
                    <button type="button" class="btn btn-secondary btn-sm" onclick="adjustQty(1)">+</button>
                    <span id="unitText" class="text-muted fw-semibold">(Lon)</span>
                </div>
            </div>

            <div class="card mb-4" style="background: var(--color-surface-alt);">
                <div class="card-body flex justify-between items-center" style="padding: var(--space-3) var(--space-4);">
                    <span class="text-secondary text-sm">Thành tiền tạm tính:</span>
                    <strong id="subtotalText" class="text-primary text-xl mono">30.000 đ</strong>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">3. Ghi Chú Bổ Sung:</label>
                <input type="text" id="orderNote" class="form-control" placeholder="Ví dụ: Khách gọi từ điện thoại phòng, xin thêm 1 xô đá lạnh...">
            </div>

            <div class="text-xs text-muted">
                Lưu ý: Tiền dịch vụ sẽ tự động ghi vào CSDL và cộng dồn vào hóa đơn thanh toán khi trả phòng.
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-primary" onclick="saveServiceOrderReal()">Lưu Dịch Vụ Vào Phòng</button>
            <button type="button" class="btn btn-secondary" onclick="backToRoomDetail()">Quay Lại</button>
        </div>
    </div>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/room_map.js"></script>

<jsp:include page="/views/common/footer.jsp" />