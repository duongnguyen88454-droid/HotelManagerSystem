<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Sơ Đồ Phòng Timeline"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<style type="text/css">
    /* RESET VA THEME ENTERPRISE PMS */
    .pms-container { max-width: 1440px; margin: 25px auto 60px auto; padding: 0 20px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
    .pms-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); margin-bottom: 20px; }
    
    /* KPI TOOLBAR */
    .kpi-bar { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; padding: 14px 20px; background: #f8fafc; border-bottom: 1px solid #e2e8f0; border-radius: 8px 8px 0 0; }
    .kpi-item { display: inline-flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600; color: #334155; }
    
    /* TEXT BADGES */
    .badge-clean { background: #15803d; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; }
    .badge-dirty { background: #b45309; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; }
    .badge-cleaning { background: #d97706; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; }
    .badge-damaged, .badge-maintenance { background: #475569; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; }
    .badge-occupied { background: #b91c1c; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; }
    .badge-booked { background: #4338ca; color: #ffffff; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; }
    
    /* CONTROLS VA FILTER */
    .filter-toolbar { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 15px; padding: 16px 20px; border-bottom: 1px solid #e2e8f0; }
    .filter-group { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .pms-input, .pms-select { padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 5px; font-size: 13px; background: #ffffff; color: #1e293b; }
    .pms-btn { padding: 8px 16px; border-radius: 5px; font-size: 13px; font-weight: 700; cursor: pointer; border: none; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; }
    .pms-btn-primary { background: #1e3a8a; color: #ffffff; }
    .pms-btn-primary:hover { background: #172554; }
    .pms-btn-success { background: #15803d; color: #ffffff; }
    .pms-btn-danger { background: #b91c1c; color: #ffffff; }
    .pms-btn-secondary { background: #e2e8f0; color: #334155; }
    .pms-btn-secondary:hover { background: #cbd5e1; }
    
    /* LEGEND */
    .legend-bar { display: flex; flex-wrap: wrap; gap: 20px; padding: 10px 20px; background: #ffffff; border-bottom: 1px solid #f1f5f9; font-size: 12px; color: #475569; }
    .legend-tag { display: inline-flex; align-items: center; gap: 6px; }
    .legend-box { width: 14px; height: 14px; border-radius: 3px; display: inline-block; }
    
    /* TIMELINE GANTT TABLE */
    .timeline-wrapper { overflow-x: auto; max-width: 100%; }
    .timeline-table { width: 100%; border-collapse: collapse; min-width: 1100px; font-size: 12px; }
    .timeline-table th, .timeline-table td { border: 1px solid #e2e8f0; padding: 0; text-align: center; }
    .timeline-table th { background: #f8fafc; color: #334155; font-weight: 700; height: 44px; }
    .room-col-header { width: 175px; min-width: 175px; text-align: left !important; padding: 8px 14px !important; }
    .day-col-header { min-width: 140px; }
    
    .floor-row td { background: #f1f5f9; font-weight: 700; text-align: left; padding: 8px 14px; color: #1e293b; font-size: 13px; }
    .room-row { height: 58px; }
    .room-cell-info { text-align: left !important; padding: 6px 12px !important; vertical-align: middle; }
    .timeline-grid-cell { position: relative; height: 58px; background: #ffffff; }
    .timeline-grid-cell:hover { background: #f8fafc; }
    
    /* BOOKING BARS */
    .booking-bar {
        position: absolute; top: 8px; bottom: 8px; border-radius: 6px;
        display: flex; align-items: center; justify-content: center; text-align: center;
        padding: 0 10px; font-size: 12px; font-weight: 700;
        color: #ffffff; cursor: pointer; z-index: 5; box-shadow: 0 2px 4px rgba(0,0,0,0.15);
        border: 1px solid rgba(255, 255, 255, 0.4);
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis; transition: all 0.15s ease;
    }
    .booking-bar:hover { transform: translateY(-1px); box-shadow: 0 4px 8px rgba(0,0,0,0.25); }
    .bar-confirmed { background: #16a34a; border-left: 4px solid #14532d; }
    .bar-occupied { background: #dc2626; border-left: 4px solid #7f1d1d; }
    .bar-checkout-today { background: #ea580c; border-left: 4px solid #7c2d12; }
    
    /* CENTERED POPUP MODAL VA BACKDROP OVERLAY */
    .pms-modal-backdrop {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(15, 23, 42, 0.65); z-index: 1000;
        display: none; align-items: center; justify-content: center; backdrop-filter: blur(2px);
    }
    .pms-modal-card {
        background: #ffffff; border-radius: 10px; width: 100%; max-width: 680px;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.25); overflow: hidden;
        border: 1px solid #cbd5e1; animation: modalPop 0.2s ease-out;
    }
    @keyframes modalPop { from { opacity: 0; transform: scale(0.96); } to { opacity: 1; transform: scale(1); } }
    .modal-head { display: flex; justify-content: space-between; align-items: center; padding: 14px 20px; background: #1e3a8a; color: #ffffff; }
    .modal-head h3 { margin: 0; font-size: 16px; font-weight: 700; }
    .modal-body { padding: 22px 24px; max-height: 75vh; overflow-y: auto; color: #1e293b; font-size: 13px; line-height: 1.6; }
    .modal-foot { padding: 14px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; background: #f8fafc; padding: 14px; border-radius: 6px; border: 1px solid #e2e8f0; }
    .svc-table { width: 100%; border-collapse: collapse; margin-top: 8px; }
    .svc-table th, .svc-table td { border: 1px solid #cbd5e1; padding: 8px 10px; text-align: left; }
    .svc-table th { background: #f1f5f9; font-weight: 700; }
</style>

<div class="pms-container">
    <!-- TIÊU ĐỀ BÀN LÀM VIỆC LỄ TÂN -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
        <div>
            <h2 style="color: #0f172a; margin: 0; font-size: 22px; font-weight: 800;">BÀN LÀM VIỆC LỄ TÂN - SƠ ĐỒ PHÒNG TIMELINE</h2>
            <p style="color: #64748b; margin: 4px 0 0 0; font-size: 13px;">Hệ thống Quản lý Đặt phòng &amp; Tiếp đón Khách hàng thời gian thực</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <button class="pms-btn pms-btn-primary" onclick="alert('Chức năng đặt phòng nhanh tại quầy sẽ được kích hoạt ở các bước tiếp theo.')">[ Đặt phòng mới ]</button>
            <a href="${pageContext.request.contextPath}/receptionist/room-map" class="pms-btn pms-btn-secondary">[ Tải lại sơ đồ ]</a>
        </div>
    </div>

    <!-- MAIN PMS CARD -->
    <div class="pms-card">
        <!-- 1. KPI TOOLBAR -->
        <div class="kpi-bar">
            <span class="kpi-item">Tổng số phòng: <strong>${kpi != null ? kpi.tongSoPhong : 0}</strong></span>
            <span style="color: #cbd5e1;">|</span>
            <span class="kpi-item"><span class="badge-clean">[Đã dọn]</span> : <strong>${kpi != null ? kpi.soPhongAvailable : 0}</strong></span>
            <span class="kpi-item"><span class="badge-occupied">[Đang có khách]</span> : <strong>${kpi != null ? kpi.soPhongOccupied : 0}</strong></span>
            <span class="kpi-item"><span class="badge-dirty">[Bẩn chờ dọn]</span> : <strong>${kpi != null ? kpi.soPhongDirty : 0}</strong></span>
            <span class="kpi-item"><span class="badge-cleaning">[Đang dọn]</span> : <strong>${kpi != null ? kpi.soPhongCleaning : 0}</strong></span>
            <span class="kpi-item"><span class="badge-damaged">[Bảo trì]</span> : <strong>${kpi != null ? kpi.soPhongDamaged : 0}</strong></span>
            <c:if test="${kpi != null and kpi.soPhongBooked gt 0}">
                <span class="kpi-item"><span class="badge-booked" style="background:#e0e7ff;color:#3730a3;font-weight:700;padding:3px 8px;border-radius:4px;font-size:11px;">[Đã giữ chỗ]</span> : <strong>${kpi.soPhongBooked}</strong></span>
            </c:if>
            <span style="color: #cbd5e1;">|</span>
            <span class="kpi-item">Tỷ lệ lấp đầy: <strong style="color: #1e3a8a;">${kpi != null ? kpi.formattedOccupancyRate : '0.0%'}</strong></span>
        </div>

        <!-- 2. BỘ LỌC TÌM KIẾM VA ĐIỀU HƯỚNG -->
        <div class="filter-toolbar">
            <div class="filter-group">
                <input type="text" id="filterKeyword" class="pms-input" placeholder="Tìm tên khách, SĐT, số phòng, mã BK..." style="width: 260px;" oninput="applyFilter()">
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
                <button type="button" class="pms-btn pms-btn-secondary" onclick="resetFilter()">[ Đặt lại ]</button>
            </div>
            <div class="filter-group">
                <button class="pms-btn pms-btn-secondary" onclick="alert('Đang xem tuần hiện tại 29/09/2026 - 05/10/2026')">[ &lt; Tuần trước ]</button>
                <strong style="font-size: 13px; color: #1e293b;">Tuần: 29/09/2026 - 05/10/2026</strong>
                <button class="pms-btn pms-btn-secondary" onclick="alert('Đang xem tuần hiện tại 29/09/2026 - 05/10/2026')">[ Tuần sau &gt; ]</button>
            </div>
        </div>

        <!-- 3. CHÚ GIẢI MÀU SẮC DẢI ĐẶT PHÒNG -->
        <div class="legend-bar">
            <strong>Chú thích dải đặt phòng:</strong>
            <span class="legend-tag"><span class="legend-box bar-confirmed"></span> [ Thanh Xanh Lá ]: Đặt trước chờ nhận</span>
            <span class="legend-tag"><span class="legend-box bar-occupied"></span> [ Thanh Đỏ ]: Đang lưu trú tại phòng</span>
            <span class="legend-tag"><span class="legend-box bar-checkout-today"></span> [ Thanh Cam ]: Trả phòng hôm nay</span>
            <span class="legend-tag"><span class="legend-box" style="border: 1px solid #cbd5e1; background: #fff;"></span> [ Ô Trắng ]: Phòng trống sẵn sàng</span>
        </div>

        <!-- 4. LƯỚI MA TRẬN TIMELINE GANTT -->
        <div class="timeline-wrapper">
            <table class="timeline-table">
                <thead>
                    <tr>
                        <th class="room-col-header">PHÒNG &amp; LOẠI PHÒNG</th>
                        <th class="day-col-header">Thứ 2 (29/09)</th>
                        <th class="day-col-header">Thứ 3 (30/09)</th>
                        <th class="day-col-header">Thứ 4 (01/10)</th>
                        <th class="day-col-header">Thứ 5 (02/10)</th>
                        <th class="day-col-header">Thứ 6 (03/10)</th>
                        <th class="day-col-header">Thứ 7 (04/10)</th>
                        <th class="day-col-header">Chủ Nhật (05/10)</th>
                    </tr>
                </thead>
                <tbody id="timelineBody">
                    <c:set var="prevFloor" value="0" />
                    <c:forEach items="${roomList}" var="r">
                        <c:if test="${r.soTang ne prevFloor}">
                            <c:set var="prevFloor" value="${r.soTang}" />
                            <tr class="floor-row" data-floor="T${r.soTang}"><td colspan="8">-- TẦNG ${r.soTang} --</td></tr>
                        </c:if>
                        <tr class="room-row" data-floor="T${r.soTang}" data-status="${r.trangThaiPhong}" data-room="${r.maPhong}">
                            <td class="room-cell-info">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 3px;">
                                    <span style="font-size: 13px; font-weight: 800; color: #0f172a;">Phòng ${r.soPhong}</span>
                                    <span class="${r.trangThaiCssClass}" style="font-size: 10px; padding: 2px 6px;">${r.trangThaiBadgeText}</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <span style="font-size: 11px; color: #64748b;">${r.tenLoaiPhong}</span>
                                    <c:if test="${r.trangThaiPhong eq 'Occupied'}">
                                        <button type="button" class="pms-btn pms-btn-primary" style="padding: 1px 5px; font-size: 10px;" onclick="openServiceOrderForRoom('${r.maPhong}', '${r.soPhong}')">[Gọi DV]</button>
                                    </c:if>
                                </div>
                            </td>
                            <c:choose>
                                <c:when test="${r.trangThaiPhong eq 'Dirty'}">
                                    <td class="timeline-grid-cell" colspan="7" style="background: #fafaf9; color: #a8a29e; font-style: italic; line-height: 58px;">Phòng vừa trả khách, đang chờ buồng phòng dọn dẹp</td>
                                </c:when>
                                <c:when test="${r.trangThaiPhong eq 'Damaged'}">
                                    <td class="timeline-grid-cell" colspan="7" style="background: #f1f5f9; color: #64748b; font-weight: 600; line-height: 58px;">Phòng tạm khóa để bảo trì: ${not empty r.moTa ? r.moTa : 'Thiết bị hư hỏng'}</td>
                                </c:when>
                                <c:when test="${r.trangThaiPhong eq 'Cleaning'}">
                                    <td class="timeline-grid-cell" colspan="7" style="background: #fffbeb; color: #92400e; font-style: italic; font-weight: 600; line-height: 58px;">Nhân viên buồng phòng đang tiến hành vệ sinh</td>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="dayIdx" begin="1" end="7">
                                        <td class="timeline-grid-cell" data-day="${dayIdx}">
                                            <c:forEach items="${r.bookingBars}" var="bar">
                                                <c:if test="${bar.startCol eq dayIdx}">
                                                    <div class="booking-bar ${bar.cssClass}" 
                                                         style="left: 6px; width: calc(${bar.colSpan * 100}% - 12px); z-index: 10;"
                                                         title="[${bar.maBooking}] ${bar.tenKhachHang} (${bar.trangThaiBooking eq 'DaCheckIn' ? 'Đang lưu trú' : 'Đã xác nhận'})"
                                                         onclick="handleBookingBarClick('${r.maPhong}', '${r.soPhong}', '${bar.maBooking}', '${bar.tenKhachHang}', '${bar.soDienThoai}', '${bar.soCccd}', '${bar.trangThaiBooking}', '${bar.ngayNhanDuKien}', '${bar.ngayTraDuKien}')">
                                                        ${bar.tenKhachHang}
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </td>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty roomList}">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 30px; color: #64748b;">Chưa có dữ liệu phòng nào trong hệ thống.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- 1. POPUP MODAL NỔI TRUNG TÂM: CHI TIẾT PHÒNG ĐANG LƯU TRÚ (PHÒNG 202)      -->
<!-- ========================================================================= -->
<div id="roomDetailModal" class="pms-modal-backdrop">
    <div class="pms-modal-card">
        <div class="modal-head">
            <h3 id="modalRoomDetailTitle">THÔNG TIN CHI TIẾT PHÒNG ĐANG LƯU TRÚ - P202</h3>
            <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="closeModal('roomDetailModal')">[ Đóng ]</button>
        </div>
        <div class="modal-body">
            <div class="detail-grid">
                <div>Mã Booking: <strong id="dtlBookingId">--</strong></div>
                <div>Trạng thái: <span class="badge-occupied">[Đang có khách]</span></div>
                <div>Khách đại diện: <strong id="dtlGuestName">--</strong></div>
                <div>Số điện thoại: <span id="dtlPhone">--</span></div>
                <div>Số CCCD: <span id="dtlCccd">--</span></div>
                <div>Thời gian ở: <strong id="dtlStayDuration">--</strong></div>
            </div>

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

            <div style="margin-top: 15px; padding: 12px; background: #eff6ff; border-radius: 6px; border: 1px solid #bfdbfe;">
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
        <div class="modal-foot">
            <button type="button" class="pms-btn pms-btn-primary" onclick="switchToOrderServiceModal()">[ Thêm dịch vụ phòng ]</button>
            <button type="button" class="pms-btn pms-btn-danger" onclick="alert('Đã sẵn sàng chuyển dữ liệu sang phân hệ Thu ngân (Giai đoạn 4) để quyết toán!')">[ Check-out trả phòng ]</button>
            <button type="button" class="pms-btn pms-btn-secondary" onclick="closeModal('roomDetailModal')">[ Đóng ]</button>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- 2. POPUP MODAL NỔI TRUNG TÂM: XÁC NHẬN THỦ TỤC CHECK-IN NHẬN PHÒNG        -->
<!-- ========================================================================= -->
<div id="checkInModal" class="pms-modal-backdrop">
    <div class="pms-modal-card">
        <div class="modal-head" style="background: #15803d;">
            <h3>XÁC NHẬN THỦ TỤC CHECK-IN NHẬN PHÒNG</h3>
            <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="closeModal('checkInModal')">[ Đóng ]</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="ciRoomIdVal" value="">
            <div class="detail-grid">
                <div>Mã Booking: <strong id="ciBookingId">BK003</strong></div>
                <div>Khách đại diện: <strong id="ciGuestName">Mai Đức Quang</strong></div>
                <div>Số điện thoại: <span id="ciPhone">0987.654.321</span></div>
                <div>Số CCCD: <span id="ciCccd">079198003344</span></div>
                <div>Thời gian ở: <strong id="ciDates">29/09/2026 -> 01/10/2026</strong></div>
                <div>Phòng bàn giao: <strong id="ciRoomId" style="color: #15803d;">P101</strong></div>
            </div>

            <div style="background: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 15px;">
                <div style="font-weight: 700; margin-bottom: 8px;">THỦ TỤC TIẾP NHẬN TẠI QUẦY:</div>
                <label style="display: block; margin-bottom: 6px;"><input type="checkbox" id="chkCccd" checked> [x] Đã đối chiếu bản gốc CCCD / Hộ chiếu của khách</label>
                <label style="display: block; margin-bottom: 6px;"><input type="checkbox" id="chkKey" checked> [x] Đã bàn giao 02 chìa khóa thẻ từ cho khách</label>
            </div>

            <div style="background: #f8fafc; padding: 12px; border-radius: 6px; border: 1px solid #e2e8f0; margin-bottom: 15px;">
                <div style="font-weight: 700; margin-bottom: 8px;">GHI CHÚ TIẾP ĐÓN / DỊCH VỤ BAN ĐẦU:</div>
                <input type="text" id="ciNote" class="pms-input" style="width: 100%; box-sizing: border-box;" placeholder="Nhập ghi chú tiếp đón (nếu có)...">
            </div>

            <div style="color: #64748b; font-size: 12px;">
                Lưu ý: Sau khi xác nhận, phòng bàn giao trên Timeline sẽ lập tức chuyển sang trạng thái <strong>[ Đang có khách ] (Màu Đỏ)</strong>.
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" class="pms-btn pms-btn-success" onclick="confirmCheckInReal()">[ Xác nhận Check-in & Giao phòng ]</button>
            <button type="button" class="pms-btn pms-btn-secondary" onclick="closeModal('checkInModal')">[ Hủy bỏ ]</button>
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
            <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="closeModal('orderServiceModal')">[ Đóng ]</button>
        </div>
        <div class="modal-body">
            <input type="hidden" id="ordRoomId" value="">
            <input type="hidden" id="ordBookingId" value="">

            <div style="margin-bottom: 15px;">
                <label style="font-weight: 700; display: block; margin-bottom: 6px;">1. CHỌN MÓN / DỊCH VỤ CỤ THỂ:</label>
                <select id="serviceSelect" class="pms-select" style="width: 100%; padding: 10px;" onchange="updatePriceCalculation()">
                    <option value="DV05" data-price="30000" data-unit="Lon" selected>Nước uống Mini Bar (DV05) - 30.000 đ/Lon</option>
                    <option value="DV01" data-price="150000" data-unit="Suất">Ăn sáng Buffet (DV01) - 150.000 đ/Suất</option>
                    <option value="DV02" data-price="60000" data-unit="Bộ">Giặt ủi quần áo (DV02) - 60.000 đ/Bộ</option>
                    <option value="DV03" data-price="350000" data-unit="Chuyến">Đưa đón sân bay (DV03) - 350.000 đ/Chuyến</option>
                    <option value="DV04" data-price="450000" data-unit="Lượt">Massage &amp; Spa Body (DV04) - 450.000 đ/Lượt</option>
                    <option value="DV06" data-price="180000" data-unit="Ngày">Thuê xe máy tự lái (DV06) - 180.000 đ/Ngày</option>
                </select>
            </div>

            <div style="margin-bottom: 15px;">
                <label style="font-weight: 700; display: block; margin-bottom: 6px;">2. SỐ LƯỢNG:</label>
                <div style="display: flex; align-items: center; gap: 10px;">
                    <button type="button" class="pms-btn pms-btn-secondary" onclick="adjustQty(-1)">[ Giảm ]</button>
                    <input type="number" id="orderQty" class="pms-input" value="1" min="1" max="20" style="width: 70px; text-align: center; font-weight: 700;" onchange="updatePriceCalculation()">
                    <button type="button" class="pms-btn pms-btn-secondary" onclick="adjustQty(1)">[ Tăng ]</button>
                    <span id="unitText" style="color: #64748b; font-weight: 600;">(Lon)</span>
                </div>
            </div>

            <div style="background: #f8fafc; border: 1px solid #cbd5e1; padding: 14px; border-radius: 6px; margin-bottom: 15px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 13px; color: #475569;">Thành tiền tạm tính:</span>
                    <strong id="subtotalText" style="font-size: 18px; color: #1e3a8a;">30.000 đ</strong>
                </div>
            </div>

            <div style="margin-bottom: 15px;">
                <label style="font-weight: 700; display: block; margin-bottom: 6px;">3. GHI CHÚ BỔ SUNG:</label>
                <input type="text" id="orderNote" class="pms-input" style="width: 100%; box-sizing: border-box;" placeholder="Ví dụ: Khách gọi từ điện thoại phòng, xin thêm 1 xô đá lạnh...">
            </div>

            <div style="color: #64748b; font-size: 12px;">
                Lưu ý: Tiền dịch vụ sẽ tự động ghi vào CSDL và cộng dồn vào hóa đơn thanh toán khi trả phòng.
            </div>
        </div>
        <div class="modal-foot">
            <button type="button" class="pms-btn pms-btn-primary" onclick="saveServiceOrderReal()">[ Lưu dịch vụ vào phòng ]</button>
            <button type="button" class="pms-btn pms-btn-secondary" onclick="backToRoomDetail()">[ Quay lại ]</button>
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

    // Điều phối click vào Booking Bar
    function handleBookingBarClick(roomId, roomNo, bookingId, guestName, phone, cccd, status, inDate, outDate) {
        if (status === 'DaCheckIn') {
            openRoomDetailModal(roomId, bookingId, guestName, phone, cccd, inDate, outDate);
        } else {
            openCheckInModal(roomId, roomNo, bookingId, guestName, phone, cccd, inDate, outDate);
        }
    }

    // Mở Modal Chi Tiết Phòng Đang Ở
    function openRoomDetailModal(roomId, bookingId, guestName, phone, cccd, inDate, outDate) {
        document.getElementById('modalRoomDetailTitle').innerText = 'THÔNG TIN CHI TIẾT PHÒNG ĐANG LƯU TRÚ - ' + roomId;
        document.getElementById('dtlBookingId').innerText = bookingId || '--';
        document.getElementById('dtlGuestName').innerText = guestName || '--';
        document.getElementById('dtlPhone').innerText = phone || '--';
        document.getElementById('dtlCccd').innerText = cccd || '--';
        document.getElementById('dtlStayDuration').innerText = (inDate && outDate) ? (inDate + ' -> ' + outDate) : '--';

        document.getElementById('ordRoomId').value = roomId;
        document.getElementById('ordBookingId').value = bookingId || '';
        document.getElementById('modalOrderServiceTitle').innerText = 'GỌI THÊM ĐỒ UỐNG / DỊCH VỤ - PHÒNG ' + roomId;

        loadServicesUsed(bookingId, roomId);
        openModal('roomDetailModal');
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

    // Mở Modal Check-in
    function openCheckInModal(roomId, roomNo, bookingId, guestName, phone, cccd, inDate, outDate) {
        document.getElementById('ciRoomIdVal').value = roomId;
        document.getElementById('ciRoomId').innerText = roomId + ' (Phòng ' + roomNo + ')';
        document.getElementById('ciBookingId').innerText = bookingId;
        document.getElementById('ciGuestName').innerText = guestName;
        document.getElementById('ciPhone').innerText = phone;
        document.getElementById('ciCccd').innerText = cccd;
        document.getElementById('ciDates').innerText = inDate + ' -> ' + outDate;
        document.getElementById('chkCccd').checked = true;
        openModal('checkInModal');
    }

    // Chuyển sang Modal Gọi Dịch Vụ
    function switchToOrderServiceModal() {
        closeModal('roomDetailModal');
        openModal('orderServiceModal');
        updatePriceCalculation();
    }

    // Quay lại Modal Chi Tiết Phòng
    function backToRoomDetail() {
        closeModal('orderServiceModal');
        openModal('roomDetailModal');
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
                openRoomDetailModal(roomId, bookingId, '', '', '', '', '');
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
        const chkCccd = document.getElementById('chkCccd');
        if (!chkCccd || !chkCccd.checked) {
            alert('[Cảnh báo] Vui lòng xác nhận đã đối chiếu CCCD / Hộ chiếu bản gốc của khách!');
            return;
        }

        const bookingId = document.getElementById('ciBookingId').innerText.trim();
        const roomId = document.getElementById('ciRoomIdVal').value.trim();
        const note = document.getElementById('ciNote') ? document.getElementById('ciNote').value.trim() : '';

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
                closeModal('checkInModal');
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
            const badgeSpan = roomRow.querySelector('.room-cell-info span[class*="badge-"]');
            if (badgeSpan) {
                badgeSpan.className = 'badge-occupied';
                badgeSpan.innerText = '[Đang có khách]';
            }
            const bar = roomRow.querySelector('.booking-bar');
            if (bar) {
                bar.className = 'booking-bar bar-occupied';
                const guestName = document.getElementById('ciGuestName').innerText;
                const phone = document.getElementById('ciPhone').innerText;
                const cccd = document.getElementById('ciCccd').innerText;
                bar.innerText = guestName;
                bar.title = '[' + bookingId + '] ' + guestName + ' (Đang lưu trú)';
                bar.setAttribute('onclick', "openRoomDetailModal('" + roomId + "', '" + bookingId + "', '" + guestName + "', '" + phone + "', '" + cccd + "', '', '')");
            }
        }
    }
</script>

<jsp:include page="/views/common/footer.jsp"/>
