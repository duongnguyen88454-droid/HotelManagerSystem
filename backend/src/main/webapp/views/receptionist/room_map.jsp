<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Danh Sách & Tình Trạng Phòng" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist/room_map.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="room_map" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <c:if test="${param.depositPaid eq 'true'}">
            <div class="portal-alert portal-alert-success">
                Đã ghi nhận giữ chỗ và thu tiền đặt cọc thành công cho đơn đặt phòng ${param.bookingSuccess}!
            </div>
        </c:if>

        <!-- Thẻ tìm kiếm & danh sách phòng -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 16px 20px; background: #f8fafc; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                    <div style="display: inline-flex; border: 1px solid #cbd5e1; border-radius: 6px; overflow: hidden;">
                        <a href="${pageContext.request.contextPath}/receptionist/timeline" style="padding: 7px 14px; font-size: 13px; font-weight: 600; text-decoration: none; color: #475569; background: #ffffff;">&#9638; Lưới</a>
                        <span style="padding: 7px 14px; font-size: 13px; font-weight: 600; background: #0284c7; color: #ffffff;">&#9776; Danh Sách</span>
                    </div>
                    <input type="text" id="filterKeyword" class="portal-input" placeholder="Tìm tên khách, SĐT, số phòng, mã BK..." style="width: 320px;" oninput="applyFilter()">
                    <button type="button" class="portal-btn portal-btn-secondary" onclick="resetFilter()">Đặt Lại</button>
                </div>

                <!-- Chú thích trạng thái -->
                <div style="display: flex; gap: 12px; font-size: 12.5px; align-items: center;">
                    <span class="badge-pill badge-available">Trống Sẵn Sàng</span>
                    <span class="badge-pill badge-occupied">Đang Có Khách</span>
                    <span class="badge-pill badge-cleaning">Đang Dọn</span>
                    <span class="badge-pill badge-damaged">Hư Hại / Bảo Trì</span>
                </div>
            </div>

            <!-- Bảng danh sách phòng -->
            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th style="width: 140px;">Phòng</th>
                            <th>Hạng Phòng</th>
                            <th style="text-align: center; width: 140px;">Trạng Thái</th>
                            <th>Thông Tin Lưu Trú / Đặt Trước</th>
                            <th style="text-align: center; width: 180px;">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="timelineBody">
                        <c:set var="prevFloor" value="0" />
                        <c:forEach items="${roomList}" var="r">
                            <c:if test="${r.soTang ne prevFloor}">
                                <c:set var="prevFloor" value="${r.soTang}" />
                                <tr class="floor-row" data-floor="T${r.soTang}" style="background: #f1f5f9; font-weight: 700; color: #475569;">
                                    <td colspan="5" style="padding: 10px 16px; font-size: 13px; text-transform: uppercase;">
                                        Tầng ${r.soTang}
                                    </td>
                                </tr>
                            </c:if>
                            <tr class="room-row" data-floor="T${r.soTang}" data-status="${r.trangThaiPhong}" data-room="${r.maPhong}">
                                <td>
                                    <strong style="font-size: 15px; color: var(--portal-text-primary);">Phòng ${r.soPhong}</strong>
                                    <div style="font-size: 11.5px; color: var(--portal-text-muted);">Mã: ${r.maPhong}</div>
                                </td>
                                <td>
                                    <span style="font-weight: 600; color: var(--portal-text-secondary);">${r.tenLoaiPhong}</span>
                                </td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${r.trangThaiPhong eq 'Available'}">
                                            <span class="badge-pill badge-available">Trống Sạch</span>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Occupied'}">
                                            <span class="badge-pill badge-occupied">Đang Ở</span>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Cleaning' or r.trangThaiPhong eq 'Dirty'}">
                                            <span class="badge-pill badge-cleaning">Đang Dọn</span>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Damaged'}">
                                            <span class="badge-pill badge-damaged">Hư Hại</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-pill badge-damaged">${r.trangThaiBadgeText}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty r.bookingBars}">
                                            <c:forEach items="${r.bookingBars}" var="bar">
                                                <div style="font-size: 13px; margin-bottom: 4px;">
                                                    <strong style="color: var(--portal-primary);">${bar.tenKhachHang}</strong>
                                                    <span style="color: var(--portal-text-muted);">(${bar.maBooking})</span>: 
                                                    <span>${bar.ngayNhanDuKien} - ${bar.ngayTraDuKien}</span>
                                                    <c:if test="${bar.trangThaiBooking eq 'CheckedIn'}">
                                                        <span class="badge-pill badge-occupied" style="font-size: 11px; padding: 1px 6px;">Đang ở</span>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--portal-text-muted); font-size: 13px;">Chưa có khách đặt trong tuần</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${not empty r.bookingBars}">
                                            <c:forEach items="${r.bookingBars}" var="bar" end="0">
                                                <button type="button" class="portal-btn portal-btn-primary" style="padding: 6px 12px; font-size: 12px;"
                                                        onclick="handleBookingBarClick('${r.maPhong}', '${r.soPhong}', '${bar.maBooking}', '${bar.tenKhachHang}', '${bar.soDienThoai}', '${bar.soCccd}', '${bar.trangThaiBooking}', '${bar.ngayNhanDuKien}', '${bar.ngayTraDuKien}', '${bar.formattedNgayCheckInThucTe}', '${bar.formattedNgayCheckOutThucTe}')">
                                                    Chi Tiết Đơn
                                                </button>
                                            </c:forEach>
                                        </c:when>
                                        <c:when test="${r.trangThaiPhong eq 'Available'}">
                                            <a href="${pageContext.request.contextPath}/receptionist/booking" class="portal-btn portal-btn-secondary" style="padding: 6px 12px; font-size: 12px;">
                                                Đặt Phòng
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--portal-text-muted); font-size: 12px;">--</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty roomList}">
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 36px; color: var(--portal-text-muted);">
                                    Chưa có dữ liệu phòng nào trong hệ thống.
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
<div id="bookingModal" class="pms-modal-backdrop">
    <div class="pms-modal-card">
        <div class="modal-head" id="bookingModalHead" style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); display: flex; justify-content: space-between; align-items: center;">
            <h3 id="bookingModalTitle" style="margin: 0; font-size: 16px; font-weight: 700; color: var(--portal-text-primary);">THÔNG TIN CHI TIẾT ĐẶT PHÒNG</h3>
            <button type="button" class="portal-btn portal-btn-secondary" style="padding: 4px 10px; font-size: 12px;" onclick="closeModal('bookingModal')">Đóng</button>
        </div>
        <div class="modal-body" style="padding: 24px;">
            <input type="hidden" id="bmRoomIdVal" value="">
            <input type="hidden" id="bmRoomNoVal" value="">
            <input type="hidden" id="bmBookingIdVal" value="">
            <div class="detail-grid" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px; font-size: 13.5px; background: #f8fafc; padding: 16px; border-radius: 10px; border: 1px solid var(--portal-border);">
                <div>Mã Booking: <strong id="bmBookingId">--</strong></div>
                <div>Phòng bàn giao: <strong id="bmRoomId" style="color: #15803d;">--</strong></div>
                <div>Khách đại diện: <strong id="bmGuestName">--</strong></div>
                <div>Số điện thoại: <span id="bmPhone">--</span></div>
                <div style="grid-column: span 2;">Số CCCD: <span id="bmCccd">--</span></div>
                <div>Ngày nhận dự kiến: <strong id="bmInDate">--</strong></div>
                <div>Ngày trả dự kiến: <strong id="bmOutDate">--</strong></div>
                <div>Ngày nhận thực tế: <strong id="bmActualIn" style="color: #15803d;">___</strong></div>
                <div>Ngày trả thực tế: <strong id="bmActualOut" style="color: #64748b;">___</strong></div>
            </div>

            <!-- DỊCH VỤ PHÁT SINH & THANH TOÁN (Chỉ hiển thị khi phòng Đang lưu trú) -->
            <div id="occupiedArea">
                <div style="font-weight: 700; color: var(--portal-text-primary); margin-bottom: 8px;">DANH SÁCH DỊCH VỤ PHÁT SINH TẠI PHÒNG:</div>
                <div class="portal-table-wrapper" style="margin-bottom: 12px;">
                    <table class="portal-table svc-table" id="usedServiceTable">
                        <thead>
                            <tr>
                                <th>Tên Dịch Vụ</th>
                                <th style="width: 60px; text-align: center;">SL</th>
                                <th style="width: 110px; text-align: right;">Đơn Giá</th>
                                <th style="width: 120px; text-align: right;">Thành Tiền</th>
                            </tr>
                        </thead>
                        <tbody id="usedServiceList">
                            <tr>
                                <td colspan="4" style="text-align: center; color: var(--portal-text-muted); font-style: italic;">Chưa có dịch vụ phát sinh nào cho phòng này.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div style="text-align: right; font-size: 13.5px; margin-bottom: 16px;">
                    Tổng tiền dịch vụ: <strong style="color: #b91c1c;" id="totalServiceCost">0 đ</strong>
                </div>

                <div style="padding: 16px; background: #eff6ff; border-radius: 10px; border: 1px solid #bfdbfe; font-size: 13.5px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                        <span>Tiền phòng lưu trú:</span>
                        <strong id="dtlRoomCost">Tính theo biểu phí phòng</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                        <span>Tiền dịch vụ phát sinh:</span>
                        <strong style="color: #b91c1c;" id="dtlServiceCostSummary">0 đ</strong>
                    </div>
                    <div style="border-top: 1px dashed #bfdbfe; margin: 8px 0;"></div>
                    <div style="display: flex; justify-content: space-between; font-size: 14px;">
                        <strong>Tổng thanh toán dự kiến khi Check-out:</strong>
                        <strong style="color: #1e3a8a;" id="finalBalance">Quyết toán khi trả phòng</strong>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-foot" style="padding: 16px 24px; border-top: 1px solid var(--portal-border); background: #f8fafc; display: flex; justify-content: flex-end; gap: 8px; flex-wrap: wrap;">
            <a id="btnGoToCheckIn" href="#" class="portal-btn portal-btn-success" style="display: none; text-decoration: none;">Chuyển sang Quầy Check-in</a>
            <button type="button" id="btnOrderService" class="portal-btn portal-btn-primary" onclick="switchToOrderServiceModal()">Thêm Dịch Vụ Phòng</button>
            <button type="button" id="btnCheckOut" class="portal-btn portal-btn-danger" onclick="goToCheckOutCashier()">Check-out Trả Phòng</button>
            <button type="button" class="portal-btn portal-btn-secondary" onclick="closeModal('bookingModal')">Đóng</button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- POPUP MODAL: GỌI THÊM ĐỒ ĂN / DỊCH VỤ TẠI PHÒNG                           -->
<!-- ========================================================================= -->
<div id="orderServiceModal" class="pms-modal-backdrop">
    <div class="pms-modal-card">
        <div class="modal-head" style="padding: 18px 24px; background: #1e3a8a; color: #ffffff; display: flex; justify-content: space-between; align-items: center;">
            <h3 id="modalOrderServiceTitle" style="margin: 0; font-size: 16px; font-weight: 700; color: #ffffff;">GỌI THÊM ĐỒ UỐNG / DỊCH VỤ TẠI PHÒNG</h3>
            <button type="button" class="portal-btn portal-btn-secondary" style="padding: 4px 10px; font-size: 12px;" onclick="closeModal('orderServiceModal')">Đóng</button>
        </div>
        <div class="modal-body" style="padding: 24px;">
            <input type="hidden" id="ordRoomId" value="">
            <input type="hidden" id="ordBookingId" value="">

            <div style="margin-bottom: 16px;">
                <label style="font-weight: 700; display: block; margin-bottom: 6px; font-size: 13.5px;">1. Chọn Món / Dịch Vụ Cụ Thể:</label>
                <select id="serviceSelect" class="portal-input" style="width: 100%; padding: 10px;" onchange="updatePriceCalculation()">
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
                            <option value="SRV004" data-price="350000" data-unit="Lượt">Gói Massage & Spa Thư Giãn (SRV004) - 350.000 đ/Lượt</option>
                            <option value="SRV006" data-price="20000" data-unit="Lon">Nước Ngọt Lon Tiện Lợi (SRV006) - 20.000 đ/Lon</option>
                        </c:otherwise>
                    </c:choose>
                </select>
            </div>

            <div style="margin-bottom: 16px;">
                <label style="font-weight: 700; display: block; margin-bottom: 6px; font-size: 13.5px;">2. Số Lượng:</label>
                <div style="display: flex; align-items: center; gap: 10px;">
                    <button type="button" class="portal-btn portal-btn-secondary" onclick="adjustQty(-1)">-</button>
                    <input type="number" id="orderQty" class="portal-input" value="1" min="1" max="20" style="width: 70px; text-align: center; font-weight: 700;" onchange="updatePriceCalculation()">
                    <button type="button" class="portal-btn portal-btn-secondary" onclick="adjustQty(1)">+</button>
                    <span id="unitText" style="color: var(--portal-text-muted); font-weight: 600;">(Lon)</span>
                </div>
            </div>

            <div style="background: #f8fafc; border: 1px solid var(--portal-border); padding: 14px; border-radius: 8px; margin-bottom: 16px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 13px; color: var(--portal-text-secondary);">Thành tiền tạm tính:</span>
                    <strong id="subtotalText" style="font-size: 18px; color: var(--portal-primary);">30.000 đ</strong>
                </div>
            </div>

            <div style="margin-bottom: 16px;">
                <label style="font-weight: 700; display: block; margin-bottom: 6px; font-size: 13.5px;">3. Ghi Chú Bổ Sung:</label>
                <input type="text" id="orderNote" class="portal-input" style="width: 100%; box-sizing: border-box;" placeholder="Ví dụ: Khách gọi từ điện thoại phòng, xin thêm 1 xô đá lạnh...">
            </div>

            <div style="color: var(--portal-text-muted); font-size: 12.5px;">
                Lưu ý: Tiền dịch vụ sẽ tự động ghi vào CSDL và cộng dồn vào hóa đơn thanh toán khi trả phòng.
            </div>
        </div>
        <div class="modal-foot" style="padding: 16px 24px; border-top: 1px solid var(--portal-border); background: #f8fafc; display: flex; justify-content: flex-end; gap: 8px;">
            <button type="button" class="portal-btn portal-btn-primary" onclick="saveServiceOrderReal()">Lưu Dịch Vụ Vào Phòng</button>
            <button type="button" class="portal-btn portal-btn-secondary" onclick="backToRoomDetail()">Quay Lại</button>
        </div>
    </div>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/room_map.js"></script>

<jsp:include page="/views/common/footer.jsp" />