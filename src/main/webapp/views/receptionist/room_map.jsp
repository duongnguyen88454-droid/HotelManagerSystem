<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <jsp:include page="/views/common/header.jsp">
            <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Sơ Đồ Phòng Timeline" />
        </jsp:include>
        <jsp:include page="/views/common/navbar.jsp" />

        <style type="text/css">
            /* RESET VA THEME ENTERPRISE PMS */
            .pms-container {
                max-width: 1440px;
                margin: 25px auto 60px auto;
                padding: 0 20px;
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            }

            .pms-card {
                background: #ffffff;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
                margin-bottom: 20px;
            }

            /* KPI TOOLBAR */
            .kpi-bar {
                display: flex;
                flex-wrap: wrap;
                gap: 12px;
                align-items: center;
                padding: 14px 20px;
                background: #f8fafc;
                border-bottom: 1px solid #e2e8f0;
                border-radius: 8px 8px 0 0;
            }

            .kpi-item {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                font-size: 13px;
                font-weight: 600;
                color: #334155;
            }

            /* TEXT BADGES */
            .badge-clean {
                background: #15803d;
                color: #ffffff;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
            }

            .badge-dirty {
                background: #b45309;
                color: #ffffff;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
            }

            .badge-cleaning {
                background: #d97706;
                color: #ffffff;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
            }

            .badge-damaged,
            .badge-maintenance {
                background: #475569;
                color: #ffffff;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
            }

            .badge-occupied {
                background: #b91c1c;
                color: #ffffff;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
            }

            .badge-booked {
                background: #4338ca;
                color: #ffffff;
                padding: 3px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
            }

            /* CONTROLS VA FILTER */
            .filter-toolbar {
                display: flex;
                flex-wrap: wrap;
                justify-content: space-between;
                align-items: center;
                gap: 15px;
                padding: 16px 20px;
                background: #f8fafc;
                border-bottom: 1px solid #e2e8f0;
                border-radius: 8px 8px 0 0;
            }

            .filter-group {
                display: flex;
                align-items: center;
                gap: 10px;
                flex-wrap: wrap;
            }

            .pms-input,
            .pms-select {
                padding: 8px 12px;
                border: 1px solid #cbd5e1;
                border-radius: 5px;
                font-size: 13px;
                background: #ffffff;
                color: #1e293b;
            }

            .pms-btn {
                padding: 8px 16px;
                border-radius: 5px;
                font-size: 13px;
                font-weight: 700;
                cursor: pointer;
                border: none;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            .pms-btn-primary {
                background: #1e3a8a;
                color: #ffffff;
            }

            .pms-btn-primary:hover {
                background: #172554;
            }

            .pms-btn-success {
                background: #15803d;
                color: #ffffff;
            }

            .pms-btn-danger {
                background: #b91c1c;
                color: #ffffff;
            }

            .pms-btn-secondary {
                background: #e2e8f0;
                color: #334155;
            }

            .pms-btn-secondary:hover {
                background: #cbd5e1;
            }

            /* LEGEND */
            .legend-bar {
                display: flex;
                flex-wrap: wrap;
                gap: 20px;
                padding: 10px 20px;
                background: #ffffff;
                border-bottom: 1px solid #f1f5f9;
                font-size: 12px;
                color: #475569;
            }

            .legend-tag {
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }

            .legend-box {
                width: 14px;
                height: 14px;
                border-radius: 3px;
                display: inline-block;
            }

            /* TIMELINE GANTT TABLE */
            .timeline-wrapper {
                overflow-x: auto;
                max-width: 100%;
            }

            .timeline-table {
                width: 100%;
                border-collapse: collapse;
                min-width: 1100px;
                font-size: 12px;
            }

            .timeline-table th,
            .timeline-table td {
                border: 1px solid #e2e8f0;
                padding: 0;
                text-align: center;
            }

            .timeline-table th {
                background: #f8fafc;
                color: #334155;
                font-weight: 700;
                height: 44px;
            }

            .room-col-header {
                width: 155px;
                min-width: 155px;
                text-align: center !important;
                padding: 8px 14px !important;
            }

            .status-col-header {
                width: 110px;
                min-width: 110px;
                text-align: center !important;
                padding: 8px 6px !important;
            }

            .day-col-header {
                min-width: 140px;
            }

            .floor-row td {
                background: #f1f5f9;
                font-weight: 700;
                text-align: left;
                padding: 8px 14px;
                color: #1e293b;
                font-size: 13px;
            }

            .room-row {
                height: 58px;
            }

            .room-cell-info {
                text-align: center !important;
                padding: 6px 12px !important;
                vertical-align: middle;
            }

            .timeline-grid-cell {
                position: relative;
                height: 58px;
                background: #ffffff;
            }

            .timeline-grid-cell:hover {
                background: #f8fafc;
            }

            /* BOOKING BARS */
            .booking-bar {
                position: absolute;
                top: 8px;
                bottom: 8px;
                border-radius: 6px;
                display: flex;
                align-items: center;
                justify-content: center;
                text-align: center;
                padding: 0 10px;
                font-size: 12px;
                font-weight: 700;
                color: #ffffff;
                cursor: pointer;
                z-index: 5;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
                border: 1px solid rgba(255, 255, 255, 0.4);
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                transition: all 0.15s ease;
            }

            .booking-bar:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.25);
            }

            .bar-confirmed {
                background: #16a34a;
                border-left: 4px solid #14532d;
            }

            .bar-occupied {
                background: #dc2626;
                border-left: 4px solid #7f1d1d;
            }

            .bar-checkout-today {
                background: #ea580c;
                border-left: 4px solid #7c2d12;
            }

            /* DẢI ĐỘ RỘNG TIMELINE THEO SỐ NGÀY CHIẾM DỤNG (COLSPAN 1-7) */
            .span-1 { width: calc(100% - 12px); }
            .span-2 { width: calc(200% - 12px); }
            .span-3 { width: calc(300% - 12px); }
            .span-4 { width: calc(400% - 12px); }
            .span-5 { width: calc(500% - 12px); }
            .span-6 { width: calc(600% - 12px); }
            .span-7 { width: calc(700% - 12px); }

            /* CENTERED POPUP MODAL VA BACKDROP OVERLAY */
            .pms-modal-backdrop {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(15, 23, 42, 0.65);
                z-index: 1000;
                display: none;
                align-items: center;
                justify-content: center;
                backdrop-filter: blur(2px);
            }

            .pms-modal-card {
                background: #ffffff;
                border-radius: 10px;
                width: 100%;
                max-width: 680px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.25);
                overflow: hidden;
                border: 1px solid #cbd5e1;
                animation: modalPop 0.2s ease-out;
            }

            @keyframes modalPop {
                from {
                    opacity: 0;
                    transform: scale(0.96);
                }

                to {
                    opacity: 1;
                    transform: scale(1);
                }
            }

            .modal-head {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 14px 20px;
                background: #1e3a8a;
                color: #ffffff;
            }

            .modal-head h3 {
                margin: 0;
                font-size: 16px;
                font-weight: 700;
            }

            .modal-body {
                padding: 22px 24px;
                max-height: 75vh;
                overflow-y: auto;
                color: #1e293b;
                font-size: 13px;
                line-height: 1.6;
            }

            .modal-foot {
                padding: 14px 20px;
                background: #f8fafc;
                border-top: 1px solid #e2e8f0;
                display: flex;
                justify-content: flex-end;
                gap: 10px;
            }

            .detail-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 12px;
                margin-bottom: 16px;
                background: #f8fafc;
                padding: 14px;
                border-radius: 6px;
                border: 1px solid #e2e8f0;
            }

            .svc-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 8px;
            }

            .svc-table th,
            .svc-table td {
                border: 1px solid #cbd5e1;
                padding: 8px 10px;
                text-align: left;
            }

            .svc-table th {
                background: #f1f5f9;
                font-weight: 700;
            }
        </style>

        <div class="pms-container">
            <!-- TIÊU ĐỀ BÀN LÀM VIỆC LỄ TÂN -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <div>
                    <h2 style="color: #0f172a; margin: 0; font-size: 22px; font-weight: 800;">BÀN LÀM VIỆC LỄ TÂN - SƠ
                        ĐỒ PHÒNG TIMELINE</h2>
                    <p style="color: #64748b; margin: 4px 0 0 0; font-size: 13px;">Hệ thống Quản lý Đặt phòng &amp; Tiếp
                        đón Khách hàng thời gian thực</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/receptionist/checkin"
                        class="pms-btn pms-btn-success" style="text-decoration: none;">[ Quầy Tiếp Đón Check-in ]</a>
                    <button class="pms-btn pms-btn-primary"
                        onclick="alert('Chức năng đặt phòng nhanh tại quầy sẽ được kích hoạt ở các bước tiếp theo.')">[
                        Đặt phòng mới ]</button>
                    <a href="${pageContext.request.contextPath}/receptionist/room-map?startDate=${startDate}"
                        class="pms-btn pms-btn-secondary">[ Tải lại sơ đồ ]</a>
                </div>
            </div>

            <!-- MAIN PMS CARD -->
            <div class="pms-card">
                <!-- BỘ LỌC TÌM KIẾM VÀ ĐIỀU HƯỚNG -->
                <div class="filter-toolbar">
                    <div class="filter-group">
                        <input type="text" id="filterKeyword" class="pms-input"
                            placeholder="Tìm tên khách, SĐT, số phòng, mã BK..." style="width: 260px;"
                            oninput="applyFilter()">
                        <select id="filterFloor" class="pms-select" onchange="applyFilter()">
                            <option value="ALL">Tất cả các tầng</option>
                            <option value="T1">Tầng 1</option>
                            <option value="T2">Tầng 2</option>
                            <option value="T3">Tầng 3</option>
                            <option value="T4">Tầng 4</option>
                        </select>
                        <select id="filterStatus" class="pms-select" onchange="applyFilter()">
                            <option value="ALL">Tất cả trạng thái buồng</option>
                            <option value="Available">Đã dọn sạch</option>
                            <option value="Occupied">Đang có khách</option>
                            <option value="Dirty">Bẩn chờ dọn</option>
                            <option value="Cleaning">Đang dọn dẹp</option>
                            <option value="Damaged">Bảo trì</option>
                            <option value="Booked">Đã giữ chỗ</option>
                        </select>
                        <button type="button" class="pms-btn pms-btn-secondary" onclick="resetFilter()">[ Đặt lại
                            ]</button>
                    </div>
                    <div class="filter-group">
                        <a href="${pageContext.request.contextPath}/receptionist/room-map?startDate=${prevWeek}"
                            class="pms-btn pms-btn-secondary">[ &lt; Tuần trước ]</a>
                        <strong style="font-size: 13px; color: #1e293b;">Tuần: ${not empty formattedWeek ? formattedWeek : '29/09/2026 - 05/10/2026'}</strong>
                        <a href="${pageContext.request.contextPath}/receptionist/room-map?startDate=${nextWeek}"
                            class="pms-btn pms-btn-secondary">[ Tuần sau &gt; ]</a>
                    </div>
                </div>

                <!-- 3. CHÚ GIẢI MÀU SẮC DẢI ĐẶT PHÒNG -->
                <div class="legend-bar">
                    <strong>Chú thích dải đặt phòng:</strong>
                    <span class="legend-tag"><span class="legend-box bar-confirmed"></span> [ Thanh Xanh Lá ]: Đặt trước
                        chờ nhận</span>
                    <span class="legend-tag"><span class="legend-box bar-occupied"></span> [ Thanh Đỏ ]: Đang lưu trú
                        tại phòng</span>
                    <span class="legend-tag"><span class="legend-box bar-checkout-today"></span> [ Thanh Cam ]: Trả
                        phòng hôm nay</span>
                    <span class="legend-tag"><span class="legend-box"
                            style="border: 1px solid #cbd5e1; background: #fff;"></span> [ Ô Trắng ]: Phòng trống sẵn
                        sàng</span>
                </div>

                <!-- 4. LƯỚI MA TRẬN TIMELINE GANTT -->
                <div class="timeline-wrapper">
                    <table class="timeline-table">
                        <thead>
                            <tr>
                                <th class="room-col-header">PHÒNG &amp; LOẠI PHÒNG</th>
                                <th class="status-col-header">TRẠNG THÁI</th>
                                <c:choose>
                                    <c:when test="${not empty dayHeaders}">
                                        <c:forEach items="${dayHeaders}" var="dh">
                                            <th class="day-col-header">${dh}</th>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <th class="day-col-header">Thứ 2 (29/09)</th>
                                        <th class="day-col-header">Thứ 3 (30/09)</th>
                                        <th class="day-col-header">Thứ 4 (01/10)</th>
                                        <th class="day-col-header">Thứ 5 (02/10)</th>
                                        <th class="day-col-header">Thứ 6 (03/10)</th>
                                        <th class="day-col-header">Thứ 7 (04/10)</th>
                                        <th class="day-col-header">Chủ Nhật (05/10)</th>
                                    </c:otherwise>
                                </c:choose>
                            </tr>
                        </thead>
                        <tbody id="timelineBody">
                            <c:set var="prevFloor" value="0" />
                            <c:forEach items="${roomList}" var="r">
                                <c:if test="${r.soTang ne prevFloor}">
                                    <c:set var="prevFloor" value="${r.soTang}" />
                                    <tr class="floor-row" data-floor="T${r.soTang}">
                                        <td colspan="9">-- TẦNG ${r.soTang} --</td>
                                    </tr>
                                </c:if>
                                <tr class="room-row" data-floor="T${r.soTang}" data-status="${r.trangThaiPhong}"
                                    data-room="${r.maPhong}">
                                    <td class="room-cell-info">
                                        <div style="margin-bottom: 3px;">
                                            <span style="font-size: 13px; font-weight: 800; color: #0f172a;">Phòng ${r.soPhong}</span>
                                        </div>
                                        <div>
                                            <span style="font-size: 11px; color: #64748b;">${r.tenLoaiPhong}</span>
                                        </div>
                                    </td>
                                    <td style="text-align: center; vertical-align: middle; padding: 6px;">
                                        <span class="${r.trangThaiCssClass}"
                                            style="font-size: 10px; padding: 3px 8px; border-radius: 4px; display: inline-block;">
                                            ${r.trangThaiBadgeText}
                                        </span>
                                    </td>
                                    <c:forEach var="dayIdx" begin="1" end="7">
                                        <td class="timeline-grid-cell" data-day="${dayIdx}">
                                            <c:forEach items="${r.bookingBars}" var="bar">
                                                <c:if test="${bar.startCol eq dayIdx}">
                                                    <div class="booking-bar ${bar.cssClass} span-${bar.colSpan}"
                                                        style="left: 6px; z-index: 10;"
                                                        title="[${bar.maBooking}] ${bar.tenKhachHang} (${bar.trangThaiBooking eq 'DaCheckIn' ? 'Đang lưu trú' : 'Đã xác nhận'})"
                                                        onclick="handleBookingBarClick('${r.maPhong}', '${r.soPhong}', '${bar.maBooking}', '${bar.tenKhachHang}', '${bar.soDienThoai}', '${bar.soCccd}', '${bar.trangThaiBooking}', '${bar.ngayNhanDuKien}', '${bar.ngayTraDuKien}', '${bar.formattedNgayCheckInThucTe}', '${bar.formattedNgayCheckOutThucTe}')">
                                                        ${bar.tenKhachHang}
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </td>
                                    </c:forEach>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty roomList}">
                                <tr>
                                    <td colspan="9" style="text-align: center; padding: 30px; color: #64748b;">Chưa có dữ liệu phòng nào trong hệ thống.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========================================================================= -->
        <!-- POPUP MODAL NỔI TRUNG TÂM THỐNG NHẤT: THÔNG TIN BOOKING & PHÒNG          -->
        <!-- ========================================================================= -->
        <div id="bookingModal" class="pms-modal-backdrop">
            <div class="pms-modal-card">
                <div class="modal-head" id="bookingModalHead">
                    <h3 id="bookingModalTitle">THÔNG TIN CHI TIẾT ĐẶT PHÒNG</h3>
                    <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;"
                        onclick="closeModal('bookingModal')">[ Đóng ]</button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="bmRoomIdVal" value="">
                    <input type="hidden" id="bmRoomNoVal" value="">
                    <input type="hidden" id="bmBookingIdVal" value="">
                    <div class="detail-grid">
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
                        <div style="font-weight: 700; color: #0f172a; margin-bottom: 6px;">DANH SÁCH DỊCH VỤ PHÁT SINH TẠI PHÒNG:</div>
                        <table class="svc-table" id="usedServiceTable">
                            <thead>
                                <tr>
                                    <th>Tên Dịch Vụ</th>
                                    <th style="width: 60px; text-align: center;">SL</th>
                                    <th style="width: 100px; text-align: right;">Đơn Giá</th>
                                    <th style="width: 110px; text-align: right;">Thành Tiền</th>
                                </tr>
                            </thead>
                            <tbody id="usedServiceList">
                                <tr>
                                    <td colspan="4" style="text-align: center; color: #94a3b8; font-style: italic;">Chưa có dịch vụ phát sinh nào cho phòng này.</td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="text-align: right; font-size: 13px; margin-top: 8px;">
                            Tổng tiền dịch vụ: <strong style="color: #b91c1c;" id="totalServiceCost">0 đ</strong>
                        </div>

                        <div
                            style="margin-top: 15px; padding: 12px; background: #eff6ff; border-radius: 6px; border: 1px solid #bfdbfe;">
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
                <div class="modal-foot">
                    <a id="btnGoToCheckIn" href="#" class="pms-btn pms-btn-success" style="display: none; text-decoration: none;">[ Chuyển sang Quầy Check-in ]</a>
                    <button type="button" id="btnOrderService" class="pms-btn pms-btn-primary" onclick="switchToOrderServiceModal()">[ Thêm dịch vụ phòng ]</button>
                    <button type="button" id="btnCheckOut" class="pms-btn pms-btn-danger"
                        onclick="alert('Đã sẵn sàng chuyển dữ liệu sang phân hệ Thu ngân (Giai đoạn 4) để quyết toán!')">[ Check-out trả phòng ]</button>
                    <button type="button" class="pms-btn pms-btn-secondary" onclick="closeModal('bookingModal')">[ Đóng ]</button>
                </div>
            </div>
        </div>

        <!-- ========================================================================= -->
        <!-- 3. POPUP MODAL NỔI TRUNG TÂM: GỌI THÊM ĐỒ ĂN / DỊCH VỤ TẠI PHÒNG           -->
        <!-- ========================================================================= -->
        <div id="orderServiceModal" class="pms-modal-backdrop">
            <div class="pms-modal-card">
                <div class="modal-head" style="background: #1e3a8a;">
                    <h3 id="modalOrderServiceTitle">GỌI THÊM ĐỒ UỐNG / DỊCH VỤ TẠI PHÒNG</h3>
                    <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;"
                        onclick="closeModal('orderServiceModal')">[ Đóng ]</button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="ordRoomId" value="">
                    <input type="hidden" id="ordBookingId" value="">

                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: 700; display: block; margin-bottom: 6px;">1. CHỌN MÓN / DỊCH VỤ CỤ
                            THỂ:</label>
                        <select id="serviceSelect" class="pms-select" style="width: 100%; padding: 10px;"
                            onchange="updatePriceCalculation()">
                            <option value="DV05" data-price="30000" data-unit="Lon" selected>Nước uống Mini Bar (DV05) -
                                30.000 đ/Lon</option>
                            <option value="DV01" data-price="150000" data-unit="Suất">Ăn sáng Buffet (DV01) - 150.000
                                đ/Suất</option>
                            <option value="DV02" data-price="60000" data-unit="Bộ">Giặt ủi quần áo (DV02) - 60.000 đ/Bộ
                            </option>
                            <option value="DV03" data-price="350000" data-unit="Chuyến">Đưa đón sân bay (DV03) - 350.000
                                đ/Chuyến</option>
                            <option value="DV04" data-price="450000" data-unit="Lượt">Massage &amp; Spa Body (DV04) -
                                450.000 đ/Lượt</option>
                            <option value="DV06" data-price="180000" data-unit="Ngày">Thuê xe máy tự lái (DV06) -
                                180.000 đ/Ngày</option>
                        </select>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: 700; display: block; margin-bottom: 6px;">2. SỐ LƯỢNG:</label>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <button type="button" class="pms-btn pms-btn-secondary" onclick="adjustQty(-1)">[ Giảm
                                ]</button>
                            <input type="number" id="orderQty" class="pms-input" value="1" min="1" max="20"
                                style="width: 70px; text-align: center; font-weight: 700;"
                                onchange="updatePriceCalculation()">
                            <button type="button" class="pms-btn pms-btn-secondary" onclick="adjustQty(1)">[ Tăng
                                ]</button>
                            <span id="unitText" style="color: #64748b; font-weight: 600;">(Lon)</span>
                        </div>
                    </div>

                    <div
                        style="background: #f8fafc; border: 1px solid #cbd5e1; padding: 14px; border-radius: 6px; margin-bottom: 15px;">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-size: 13px; color: #475569;">Thành tiền tạm tính:</span>
                            <strong id="subtotalText" style="font-size: 18px; color: #1e3a8a;">30.000 đ</strong>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: 700; display: block; margin-bottom: 6px;">3. GHI CHÚ BỔ SUNG:</label>
                        <input type="text" id="orderNote" class="pms-input" style="width: 100%; box-sizing: border-box;"
                            placeholder="Ví dụ: Khách gọi từ điện thoại phòng, xin thêm 1 xô đá lạnh...">
                    </div>

                    <div style="color: #64748b; font-size: 12px;">
                        Lưu ý: Tiền dịch vụ sẽ tự động ghi vào CSDL và cộng dồn vào hóa đơn thanh toán khi trả phòng.
                    </div>
                </div>
                <div class="modal-foot">
                    <button type="button" class="pms-btn pms-btn-primary" onclick="saveServiceOrderReal()">[ Lưu dịch vụ
                        vào phòng ]</button>
                    <button type="button" class="pms-btn pms-btn-secondary" onclick="backToRoomDetail()">[ Quay lại
                        ]</button>
                </div>
            </div>
        </div>

        <script>
            // 1. TÌM KIẾM VA BỘ LỌC TIMELINE
            function applyFilter() {
                const kw = document.getElementById('filterKeyword').value.trim().toLowerCase();
                const floor = document.getElementById('filterFloor').value;
                const status = document.getElementById('filterStatus').value;
                const rows = document.querySelectorAll('.room-row');

                rows.forEach(r => {
                    const rFloor = r.getAttribute('data-floor');
                    const rStatus = r.getAttribute('data-status');
                    const rText = r.innerText.toLowerCase();

                    let matchKw = (kw === '' || rText.includes(kw));
                    let matchFloor = (floor === 'ALL' || rFloor === floor);
                    let matchStatus = (status === 'ALL' || rStatus === status);

                    r.style.display = (matchKw && matchFloor && matchStatus) ? '' : 'none';
                });

                // Ẩn tiêu đề tầng nếu không có phòng nào trong tầng hiển thị
                document.querySelectorAll('.floor-row').forEach(floorRow => {
                    const fl = floorRow.getAttribute('data-floor');
                    const visible = document.querySelectorAll('.room-row[data-floor="' + fl + '"]:not([style*="display: none"])');
                    floorRow.style.display = (visible.length > 0) ? '' : 'none';
                });
            }

            function resetFilter() {
                document.getElementById('filterKeyword').value = '';
                document.getElementById('filterFloor').value = 'ALL';
                document.getElementById('filterStatus').value = 'ALL';
                applyFilter();
            }

            // 2. MODAL CONTROLS
            function openModal(modalId) {
                document.getElementById(modalId).style.display = 'flex';
            }
            function closeModal(modalId) {
                document.getElementById(modalId).style.display = 'none';
            }

            // Điều phối click vào Booking Bar (Thống nhất 1 modal bookingModal duy nhất)
            function handleBookingBarClick(roomId, roomNo, bookingId, guestName, phone, cccd, status, inDate, outDate, actualIn, actualOut) {
                document.getElementById('bmRoomIdVal').value = roomId || '';
                document.getElementById('bmRoomNoVal').value = roomNo || roomId || '';
                document.getElementById('bmBookingIdVal').value = bookingId || '';

                document.getElementById('bmBookingId').innerText = bookingId || '--';
                document.getElementById('bmRoomId').innerText = roomId + (roomNo ? (' (Phòng ' + roomNo + ')') : '');
                document.getElementById('bmGuestName').innerText = guestName || '--';
                document.getElementById('bmPhone').innerText = phone || '--';
                document.getElementById('bmCccd').innerText = cccd || '--';
                document.getElementById('bmInDate').innerText = inDate || '--';
                document.getElementById('bmOutDate').innerText = outDate || '--';
                document.getElementById('bmActualIn').innerText = (actualIn && actualIn.trim() !== '') ? actualIn : '___';
                document.getElementById('bmActualOut').innerText = (actualOut && actualOut.trim() !== '') ? actualOut : '___';

                const modalTitle = document.getElementById('bookingModalTitle');
                const modalHead = document.getElementById('bookingModalHead');
                const occupiedArea = document.getElementById('occupiedArea');
                const btnOrderService = document.getElementById('btnOrderService');
                const btnCheckOut = document.getElementById('btnCheckOut');

                // Đồng bộ màu header chuẩn navy blue
                if (modalHead) modalHead.style.background = '#1e3a8a';

                // Đồng bộ thông tin sẵn cho modal gọi dịch vụ nếu cần
                document.getElementById('ordRoomId').value = roomId || '';
                document.getElementById('ordBookingId').value = bookingId || '';
                document.getElementById('modalOrderServiceTitle').innerText = 'GỌI THÊM ĐỒ UỐNG / DỊCH VỤ - PHÒNG ' + (roomNo || roomId);

                const btnGoToCheckIn = document.getElementById('btnGoToCheckIn');

                if (status === 'DaCheckIn') {
                    modalTitle.innerText = 'THÔNG TIN CHI TIẾT PHÒNG ĐANG LƯU TRÚ - ' + roomId;
                    occupiedArea.style.display = 'block';
                    btnOrderService.style.display = '';
                    btnCheckOut.style.display = '';
                    if (btnGoToCheckIn) btnGoToCheckIn.style.display = 'none';
                    loadServicesUsed(bookingId, roomId);
                } else {
                    modalTitle.innerText = 'THÔNG TIN CHI TIẾT ĐẶT PHÒNG - ' + roomId;
                    occupiedArea.style.display = 'none';
                    btnOrderService.style.display = 'none';
                    btnCheckOut.style.display = 'none';
                    if (btnGoToCheckIn) {
                        btnGoToCheckIn.style.display = '';
                        btnGoToCheckIn.href = '${pageContext.request.contextPath}/receptionist/checkin?maBooking=' + encodeURIComponent(bookingId);
                    }
                }

                openModal('bookingModal');
            }

            // Hỗ trợ tương thích ngược
            function openRoomDetailModal(roomId, bookingId, guestName, phone, cccd, inDate, outDate, actualIn, actualOut) {
                handleBookingBarClick(roomId, roomId, bookingId, guestName, phone, cccd, 'DaCheckIn', inDate, outDate, actualIn, actualOut);
            }

            function openCheckInModal(roomId, roomNo, bookingId, guestName, phone, cccd, inDate, outDate) {
                handleBookingBarClick(roomId, roomNo, bookingId, guestName, phone, cccd, 'XacNhan', inDate, outDate, '___', '___');
            }

            // Tải danh sách dịch vụ phòng đã dùng từ API (FN-3.5)
            function loadServicesUsed(bookingId, roomId) {
                const tbody = document.getElementById('usedServiceList');
                tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #64748b;">Đang tải danh sách dịch vụ...</td></tr>';

                const url = '${pageContext.request.contextPath}/api/receptionist/services?action=usage&maBooking='
                    + encodeURIComponent(bookingId || '') + '&maPhong=' + encodeURIComponent(roomId || '');

                fetch(url)
                    .then(res => res.json())
                    .then(data => {
                        if (data.success && data.services && data.services.length > 0) {
                            tbody.innerHTML = '';
                            data.services.forEach(s => {
                                const tr = document.createElement('tr');
                                tr.innerHTML = '<td>' + escapeHtml(s.tenDichVu) + '</td>'
                                    + '<td style="text-align: center;">' + s.soLuong + '</td>'
                                    + '<td style="text-align: right;">' + s.donGia.toLocaleString('vi-VN') + ' đ</td>'
                                    + '<td style="text-align: right; font-weight: 600;">' + s.thanhTien.toLocaleString('vi-VN') + ' đ</td>';
                                tbody.appendChild(tr);
                            });
                            const formattedCost = data.totalCost.toLocaleString('vi-VN') + ' đ';
                            document.getElementById('totalServiceCost').innerText = formattedCost;
                            const dtlSummary = document.getElementById('dtlServiceCostSummary');
                            if (dtlSummary) dtlSummary.innerText = formattedCost;
                        } else {
                            tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #94a3b8; font-style: italic;">Chưa có dịch vụ phát sinh nào cho phòng này.</td></tr>';
                            document.getElementById('totalServiceCost').innerText = '0 đ';
                            const dtlSummary = document.getElementById('dtlServiceCostSummary');
                            if (dtlSummary) dtlSummary.innerText = '0 đ';
                        }
                    })
                    .catch(err => {
                        tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #ef4444;">Lỗi khi tải dịch vụ: ' + err.message + '</td></tr>';
                        const dtlSummary = document.getElementById('dtlServiceCostSummary');
                        if (dtlSummary) dtlSummary.innerText = '0 đ';
                    });
            }

            // Mở trực tiếp Modal Gọi Dịch Vụ từ nút trên thẻ phòng
            function openServiceOrderForRoom(roomId, roomNo) {
                document.getElementById('ordRoomId').value = roomId;
                document.getElementById('modalOrderServiceTitle').innerText = 'GỌI THÊM ĐỒ UỐNG / DỊCH VỤ - PHÒNG ' + roomNo;

                fetch('${pageContext.request.contextPath}/api/receptionist/services?action=usage&maPhong=' + encodeURIComponent(roomId))
                    .then(res => res.json())
                    .then(data => {
                        if (data.maBooking) {
                            document.getElementById('ordBookingId').value = data.maBooking;
                        }
                        openModal('orderServiceModal');
                        updatePriceCalculation();
                    })
                    .catch(() => {
                        openModal('orderServiceModal');
                        updatePriceCalculation();
                    });
            }

            // Chuyển sang Modal Gọi Dịch Vụ
            function switchToOrderServiceModal() {
                closeModal('bookingModal');
                openModal('orderServiceModal');
                updatePriceCalculation();
            }

            // Quay lại Modal Chi Tiết Phòng
            function backToRoomDetail() {
                closeModal('orderServiceModal');
                openModal('bookingModal');
            }

            // 3. TÍNH TOÁN VA GỌI DỊCH VỤ
            function adjustQty(delta) {
                const qtyInput = document.getElementById('orderQty');
                let current = parseInt(qtyInput.value) || 1;
                current += delta;
                if (current < 1) current = 1;
                if (current > 20) current = 20;
                qtyInput.value = current;
                updatePriceCalculation();
            }

            function updatePriceCalculation() {
                const select = document.getElementById('serviceSelect');
                const selectedOpt = select.options[select.selectedIndex];
                const price = parseInt(selectedOpt.getAttribute('data-price')) || 0;
                const unit = selectedOpt.getAttribute('data-unit') || '';
                const qty = parseInt(document.getElementById('orderQty').value) || 1;

                document.getElementById('unitText').innerText = '(' + unit + ')';
                const subtotal = price * qty;
                document.getElementById('subtotalText').innerText = subtotal.toLocaleString('vi-VN') + ' đ';
            }

            function changeServiceCategory() {
                updatePriceCalculation();
            }

            // Thoát ký tự HTML an toàn
            function escapeHtml(text) {
                if (!text) return '';
                const div = document.createElement('div');
                div.innerText = text;
                return div.innerHTML;
            }

            // Gọi Dịch Vụ Thật Qua API (FN-3.4)
            function saveServiceOrderReal() {
                const bookingId = document.getElementById('ordBookingId').value.trim();
                const roomId = document.getElementById('ordRoomId').value.trim();
                const select = document.getElementById('serviceSelect');
                const maDichVu = select.value;
                const svcName = select.options[select.selectedIndex].text.split(' - ')[0];
                const qty = parseInt(document.getElementById('orderQty').value) || 1;
                const note = document.getElementById('orderNote').value.trim();

                if (!maDichVu) {
                    alert('[Cảnh báo] Vui lòng chọn một dịch vụ!');
                    return;
                }

                const params = new URLSearchParams();
                params.append('maBooking', bookingId);
                params.append('maPhong', roomId);
                params.append('maDichVu', maDichVu);
                params.append('soLuong', qty);
                params.append('ghiChu', note);

                fetch('${pageContext.request.contextPath}/api/receptionist/services', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: params.toString()
                })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            alert('[Thành công] Đã ghi nhận ' + qty + ' x ' + svcName + ' vào phòng ' + roomId + '!');
                            closeModal('orderServiceModal');
                            loadServicesUsed(bookingId, roomId);
                            openModal('bookingModal');
                        } else {
                            alert('[Lỗi] Không thể thêm dịch vụ: ' + (data.message || 'Lỗi không xác định'));
                        }
                    })
                    .catch(err => {
                        alert('[Lỗi kết nối] Không thể kết nối đến máy chủ lễ tân: ' + err.message);
                    });
            }

            // Xác Nhận Check-In Thật (Gửi AJAX POST đến ReceptionistCheckInServlet)
            function confirmCheckInReal() {

                const bookingId = document.getElementById('bmBookingIdVal').value.trim();
                const roomId = document.getElementById('bmRoomIdVal').value.trim();
                const note = document.getElementById('bmNote') ? document.getElementById('bmNote').value.trim() : '';

                const params = new URLSearchParams();
                params.append('maBooking', bookingId);
                params.append('maPhong', roomId);
                params.append('ghiChu', note);
                params.append('chkCccd', 'true');

                fetch('${pageContext.request.contextPath}/receptionist/checkin', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                    body: params.toString()
                })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            alert('[Thành công] ' + data.message);
                            closeModal('bookingModal');
                            updateTimelineAfterCheckIn(roomId, bookingId);
                        } else {
                            alert('[Lỗi Check-in] ' + data.message);
                        }
                    })
                    .catch(err => {
                        alert('[Lỗi kết nối] Không thể kết nối đến máy chủ lễ tân.');
                    });
            }

            // Cập nhật DOM tức thì sau khi Check-In thành công
            function updateTimelineAfterCheckIn(roomId, bookingId) {
                const roomRow = document.querySelector('.room-row[data-room="' + roomId + '"]');
                if (roomRow) {
                    roomRow.setAttribute('data-status', 'Occupied');
                    const badgeSpan = roomRow.querySelector('span[class*="badge-"]');
                    if (badgeSpan) {
                        badgeSpan.className = 'badge-occupied';
                        badgeSpan.innerText = '[Đang có khách]';
                    }
                    const bar = roomRow.querySelector('.booking-bar');
                    if (bar) {
                        bar.classList.remove('bar-confirmed');
                        bar.classList.add('bar-occupied');
                        const guestName = document.getElementById('bmGuestName').innerText;
                        const phone = document.getElementById('bmPhone').innerText;
                        const cccd = document.getElementById('bmCccd').innerText;
                        const inDate = document.getElementById('bmInDate') ? document.getElementById('bmInDate').innerText : '';
                        const outDate = document.getElementById('bmOutDate') ? document.getElementById('bmOutDate').innerText : '';
                        const roomNo = document.getElementById('bmRoomNoVal') ? document.getElementById('bmRoomNoVal').value : roomId;
                        const now = new Date();
                        const nowStr = now.getFullYear() + '-'
                            + String(now.getMonth() + 1).padStart(2, '0') + '-'
                            + String(now.getDate()).padStart(2, '0') + ' '
                            + String(now.getHours()).padStart(2, '0') + ':'
                            + String(now.getMinutes()).padStart(2, '0') + ':'
                            + String(now.getSeconds()).padStart(2, '0');
                        bar.innerText = guestName;
                        bar.title = '[' + bookingId + '] ' + guestName + ' (Đang lưu trú)';
                        bar.setAttribute('onclick', "handleBookingBarClick('" + roomId + "', '" + roomNo + "', '" + bookingId + "', '" + guestName + "', '" + phone + "', '" + cccd + "', 'DaCheckIn', '" + inDate + "', '" + outDate + "', '" + nowStr + "', '___')");
                    }
                }
            }
        </script>

        <jsp:include page="/views/common/footer.jsp" />