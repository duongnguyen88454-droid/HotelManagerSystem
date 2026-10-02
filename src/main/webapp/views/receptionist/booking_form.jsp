<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Tiếp Nhận Đặt Phòng Tại Quầy - Bàn Làm Việc Lễ Tân" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<style>
    .pms-wrap {
        background-color: #f8fafc;
        min-height: calc(100vh - 120px);
        padding: 24px 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    .pms-container {
        max-width: 1350px;
        margin: 0 auto;
        padding: 0 20px;
    }

    /* STEPPER HEADER */
    .stepper-nav {
        display: flex;
        align-items: center;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 14px 24px;
        margin-bottom: 24px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }

    .step-item {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 14px;
        font-weight: 700;
        color: #94a3b8;
    }

    .step-item.active {
        color: #0284c7;
    }

    .step-item.completed {
        color: #16a34a;
    }

    .step-badge {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        font-weight: 800;
        background: #e2e8f0;
        color: #475569;
    }

    .step-item.active .step-badge {
        background: #0284c7;
        color: #ffffff;
    }

    .step-item.completed .step-badge {
        background: #16a34a;
        color: #ffffff;
    }

    .step-divider {
        flex: 1;
        height: 2px;
        background: #e2e8f0;
        margin: 0 20px;
    }

    /* CARDS */
    .pms-card {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
        padding: 20px;
        margin-bottom: 20px;
    }

    .pms-card-header {
        font-size: 14px;
        font-weight: 800;
        color: #1e293b;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border-bottom: 2px solid #0284c7;
        padding-bottom: 10px;
        margin-bottom: 16px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .pms-label {
        display: block;
        font-size: 12px;
        font-weight: 700;
        color: #475569;
        margin-bottom: 6px;
    }

    .pms-input {
        width: 100%;
        padding: 9px 12px;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        font-size: 13px;
        color: #0f172a;
        background: #ffffff;
        box-sizing: border-box;
    }

    .pms-input:focus {
        outline: none;
        border-color: #0284c7;
        box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
    }

    .pms-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 10px 20px;
        font-size: 13px;
        font-weight: 700;
        border-radius: 6px;
        border: none;
        cursor: pointer;
        text-decoration: none;
        transition: all 0.2s;
    }

    .pms-btn-primary {
        background: #0284c7;
        color: #ffffff;
    }

    .pms-btn-primary:hover {
        background: #0369a1;
    }

    .pms-btn-success {
        background: #16a34a;
        color: #ffffff;
    }

    .pms-btn-success:hover {
        background: #15803d;
    }

    .pms-btn-secondary {
        background: #e2e8f0;
        color: #334155;
    }

    .pms-btn-secondary:hover {
        background: #cbd5e1;
    }

    /* DATA TABLE */
    .pms-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        font-size: 13px;
    }

    .pms-table th {
        background: #f8fafc;
        color: #475569;
        font-weight: 700;
        padding: 12px 14px;
        border-bottom: 2px solid #e2e8f0;
        text-align: left;
    }

    .pms-table td {
        padding: 12px 14px;
        border-bottom: 1px solid #f1f5f9;
        vertical-align: middle;
        color: #1e293b;
    }

    .pms-table tr:hover td {
        background-color: #f8fafc;
    }

    .step-footer-bar {
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 16px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 20px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
    }
</style>

<div class="pms-wrap">
    <div class="pms-container">

        <!-- HEADER & ACTIONS -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
            <div>
                <h2 style="color: #0f172a; margin: 0; font-size: 22px; font-weight: 800;">TIẾP NHẬN ĐẶT PHÒNG TẠI QUẦY (WALK-IN)</h2>
                <p style="color: #64748b; margin: 4px 0 0 0; font-size: 13px;">Quy trình tiếp nhận đặt phòng doanh nghiệp: Chọn phòng khả dụng & Điền hồ sơ lưu trú</p>
            </div>
            <div style="display: flex; gap: 10px;">
                <a href="${pageContext.request.contextPath}/receptionist/room-map" class="pms-btn pms-btn-secondary">[ Sơ Đồ Phòng ]</a>
                <a href="${pageContext.request.contextPath}/receptionist/checkin" class="pms-btn pms-btn-secondary">[ Quầy Check-in ]</a>
            </div>
        </div>

        <!-- STEPPER NAV -->
        <div class="stepper-nav">
            <div id="stepNav1" class="step-item active">
                <span class="step-badge">1</span>
                <span>1. CHỌN THỜI GIAN & PHÒNG KHẢ DỤNG</span>
            </div>
            <div class="step-divider"></div>
            <div id="stepNav2" class="step-item">
                <span class="step-badge">2</span>
                <span>2. HỒ SƠ KHÁCH & DỊCH VỤ PHÒNG</span>
            </div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div style="background-color: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; font-weight: 700; font-size: 13px;">
                [Lỗi] ${errorMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/receptionist/booking" method="POST" id="receptionistBookingForm">

            <!-- ========================================================================= -->
            <!-- BƯỚC 1: CHỌN NGÀY & PHÒNG KHẢ DỤNG                                        -->
            <!-- ========================================================================= -->
            <div id="step1Container">
                
                <!-- KHUNG CHỌN NGÀY -->
                <div class="pms-card" style="padding: 16px 20px;">
                    <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px;">
                        <div style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <label style="font-size: 13px; font-weight: 700; color: #334155;">Ngày nhận:</label>
                                <input type="date" id="dateCheckIn" name="checkIn" value="${checkIn}" class="pms-input" style="width: 160px; padding: 6px 10px;" onchange="onDateFilterChange()">
                            </div>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <label style="font-size: 13px; font-weight: 700; color: #334155;">Ngày trả:</label>
                                <input type="date" id="dateCheckOut" name="checkOut" value="${checkOut}" class="pms-input" style="width: 160px; padding: 6px 10px;" onchange="onDateFilterChange()">
                            </div>
                            <span id="nightsCounter" style="background: #e0f2fe; color: #0369a1; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 700;">1 đêm</span>
                        </div>
                        <button type="button" class="pms-btn pms-btn-secondary" style="padding: 7px 14px;" onclick="onDateFilterChange()">
                            [ Cập Nhật Phòng ]
                        </button>
                    </div>
                </div>

                <!-- BẢNG PHÒNG TRỐNG (THOÁNG ĐÃNG, KHÔNG CÓ CỘT DỊCH VỤ) -->
                <div class="pms-card" style="padding: 0; overflow: hidden;">
                    <div style="padding: 16px 20px; background: #ffffff; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                        <span style="font-size: 14px; font-weight: 800; color: #0f172a; text-transform: uppercase;">
                            Danh Sách Phòng Khả Dụng
                        </span>
                        <span style="font-size: 13px; color: #64748b;">
                            Tìm thấy: <strong style="color: #0284c7; font-size: 14px;">${fn:length(availableRooms)}</strong> phòng trống
                        </span>
                    </div>

                    <c:choose>
                        <c:when test="${empty availableRooms}">
                            <div style="padding: 40px; text-align: center; color: #94a3b8; font-size: 14px;">
                                [Thông báo] Không có phòng nào khả dụng trong khoảng thời gian này. Vui lòng chọn khoảng ngày khác.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="pms-table">
                                <thead>
                                    <tr>
                                        <th style="width: 50px; text-align: center;">Chọn</th>
                                        <th style="width: 110px;">Số Phòng</th>
                                        <th>Hạng Phòng</th>
                                        <th style="width: 220px;">Sức Chứa & Loại Giường</th>
                                        <th style="width: 160px; text-align: right;">Đơn Giá / Đêm</th>
                                        <th style="width: 180px; text-align: right;">Tạm Tính Tiền Phòng</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="rm" items="${availableRooms}">
                                        <tr>
                                            <td style="text-align: center;">
                                                <c:choose>
                                                    <c:when test="${rm.maPhong eq preselectedRoomId}">
                                                        <input type="checkbox" name="selectedRooms" value="${rm.maPhong}" id="chk_${rm.maPhong}" checked data-price="${rm.giaPhong}" data-roomno="${rm.soPhong}" data-typename="${rm.tenLoaiPhong}" onchange="onRoomCheckboxChange()" style="width: 18px; height: 18px; cursor: pointer;">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <input type="checkbox" name="selectedRooms" value="${rm.maPhong}" id="chk_${rm.maPhong}" data-price="${rm.giaPhong}" data-roomno="${rm.soPhong}" data-typename="${rm.tenLoaiPhong}" onchange="onRoomCheckboxChange()" style="width: 18px; height: 18px; cursor: pointer;">
                                                    </c:otherwise>
                                                </c:choose>
                                                <input type="hidden" name="soPhong_${rm.maPhong}" value="${rm.soPhong}">
                                                <input type="hidden" name="tenLoaiPhong_${rm.maPhong}" value="${rm.tenLoaiPhong}">
                                                <input type="hidden" name="maLoaiPhong_${rm.maPhong}" value="${rm.maLoaiPhong}">
                                                <input type="hidden" name="donGia_${rm.maPhong}" value="${rm.giaPhong}">
                                            </td>
                                            <td>
                                                <strong style="color: #0284c7; font-size: 15px;">P.${rm.soPhong}</strong>
                                            </td>
                                            <td>
                                                <strong style="color: #1e293b;">${rm.tenLoaiPhong}</strong>
                                                <span style="display: block; font-size: 11px; color: #64748b;">Mã: ${rm.maLoaiPhong}</span>
                                            </td>
                                            <td>
                                                <span style="color: #334155; font-weight: 600;">${rm.soNguoiToiDa} khách (${rm.loaiGiuong})</span>
                                            </td>
                                            <td style="text-align: right;">
                                                <strong style="color: #0f172a; font-size: 14px;">
                                                    <fmt:formatNumber value="${rm.giaPhong}" pattern="#,###"/>
                                                </strong>
                                                <span style="display: block; font-size: 11px; color: #64748b;">VNĐ / đêm</span>
                                            </td>
                                            <td style="text-align: right;">
                                                <strong id="roomSubtotal_${rm.maPhong}" style="color: #0369a1; font-size: 14px;">0 VNĐ</strong>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- THANH TỔNG KẾT & TIẾP TỤC DƯỚI CHÂN BƯỚC 1 -->
                <div class="step-footer-bar">
                    <div>
                        <span style="font-size: 14px; color: #475569;">Đã chọn: <strong id="step1SelectedCount" style="color: #0284c7; font-size: 16px;">0</strong> phòng</span>
                        <span style="margin: 0 12px; color: #cbd5e1;">|</span>
                        <span style="font-size: 14px; color: #475569;">Tổng tiền phòng tạm tính: <strong id="step1TotalRoomCost" style="color: #dc2626; font-size: 16px;">0 VNĐ</strong></span>
                    </div>
                    <button type="button" id="btnNextToStep2" class="pms-btn pms-btn-primary" onclick="goToStep(2)">
                        [ Tiếp Tục: Nhập Thông Tin & Dịch Vụ -> ]
                    </button>
                </div>

            </div>

            <!-- ========================================================================= -->
            <!-- BƯỚC 2: HỒ SƠ KHÁCH HÀNG & PHÂN BỔ DỊCH VỤ                                 -->
            <!-- ========================================================================= -->
            <div id="step2Container" style="display: none;">

                <!-- 1. HỒ SƠ KHÁCH LƯU TRÚ (TÊN VÀ EMAIL NẰM TRÊN CÙNG, TẤT CẢ BẮT BUỘC) -->
                <div class="pms-card">
                    <div class="pms-card-header">
                        <span>1. Hồ Sơ Khách Lưu Trú (Bắt Buộc Nhập Đầy Đủ)</span>
                    </div>

                    <!-- HÀNG 1: HỌ VÀ TÊN & EMAIL (BẮT BUỘC) -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 16px;">
                        <div>
                            <label class="pms-label">Họ và Tên khách đại diện <span style="color: #ef4444;">*</span></label>
                            <input type="text" id="guestName" name="hoTen" class="pms-input" placeholder="Ví dụ: Nguyễn Văn An" required style="font-weight: 600;">
                        </div>
                        <div>
                            <label class="pms-label">Địa chỉ Email liên hệ <span style="color: #ef4444;">*</span></label>
                            <input type="email" id="guestEmail" name="email" class="pms-input" placeholder="guest@example.com" required>
                        </div>
                    </div>

                    <!-- HÀNG 2: SỐ CCCD & SỐ ĐIỆN THOẠI (BẮT BUỘC) -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 16px;">
                        <div>
                            <label class="pms-label">Số CCCD / Hộ chiếu (12 số) <span style="color: #ef4444;">*</span></label>
                            <input type="text" id="guestCccd" name="cccd" class="pms-input" placeholder="Nhập đủ 12 chữ số..." required maxlength="12" pattern="[0-9]{12}" style="font-weight: 700;">
                        </div>
                        <div>
                            <label class="pms-label">Số điện thoại liên lạc <span style="color: #ef4444;">*</span></label>
                            <input type="text" id="guestPhone" name="soDT" class="pms-input" placeholder="Ví dụ: 0901234567" required>
                        </div>
                    </div>

                    <!-- HÀNG 3: GHI CHÚ -->
                    <div>
                        <label class="pms-label">Ghi chú đơn đặt phòng</label>
                        <textarea name="note" class="pms-input" rows="2" placeholder="Yêu cầu đặc biệt của khách hàng..."></textarea>
                    </div>
                </div>

                <!-- 2. DỊCH VỤ GẮN THEO TỪNG PHÒNG ĐÃ CHỌN -->
                <div class="pms-card">
                    <div class="pms-card-header">
                        <span>2. Dịch Vụ Đi Kèm Cho Từng Phòng Đã Chọn</span>
                        <span style="font-size: 12px; color: #64748b; font-weight: 600; text-transform: none;">Điều chỉnh số lượng dịch vụ theo nhu cầu thực tế</span>
                    </div>

                    <div id="selectedRoomsSvcContainer">
                        <c:forEach var="rm" items="${availableRooms}">
                            <div id="roomSvcCard_${rm.maPhong}" class="room-svc-card" style="display: none; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 16px; overflow: hidden; background: #ffffff;">
                                <div style="background: #f1f5f9; padding: 10px 16px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center;">
                                    <strong style="color: #0f172a; font-size: 14px;">Phòng P.${rm.soPhong} - ${rm.tenLoaiPhong}</strong>
                                    <span style="color: #0284c7; font-weight: 700; font-size: 13px;"><fmt:formatNumber value="${rm.giaPhong}" pattern="#,###"/> VNĐ / đêm</span>
                                </div>
                                <div style="padding: 12px 16px;">
                                    <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                        <thead>
                                            <tr style="border-bottom: 1px solid #e2e8f0; color: #64748b; font-size: 12px; text-align: left;">
                                                <th style="padding-bottom: 6px;">Tên Dịch Vụ</th>
                                                <th style="padding-bottom: 6px; width: 150px; text-align: right;">Đơn Giá</th>
                                                <th style="padding-bottom: 6px; width: 140px; text-align: center;">Số Lượng</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="s" items="${services}">
                                                <tr style="border-bottom: 1px solid #f8fafc;">
                                                    <td style="padding: 8px 0; color: #1e293b; font-weight: 600;">${s.tenDichVu}</td>
                                                    <td style="padding: 8px 0; text-align: right; color: #475569;">
                                                        <fmt:formatNumber value="${s.donGia}" pattern="#,###"/> VNĐ
                                                    </td>
                                                    <td style="padding: 8px 0; text-align: center;">
                                                        <div style="display: inline-flex; align-items: center; gap: 4px;">
                                                            <button type="button" class="pms-btn pms-btn-secondary" style="padding: 2px 8px; font-size: 12px; border-radius: 4px;" onclick="changeQty('${rm.maPhong}', '${s.maDichVu}', -1)">-</button>
                                                            <input type="number" id="qty_${rm.maPhong}_${s.maDichVu}" name="svc_${rm.maPhong}_${s.maDichVu}" min="0" max="20" value="0" data-price="${s.donGia}" class="pms-input" style="width: 48px; text-align: center; padding: 4px 6px;" onchange="recalculateStep2Bill()">
                                                            <button type="button" class="pms-btn pms-btn-secondary" style="padding: 2px 8px; font-size: 12px; border-radius: 4px;" onclick="changeQty('${rm.maPhong}', '${s.maDichVu}', 1)">+</button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- 3. TỔNG HỢP CHI PHÍ & XÁC NHẬN ĐƠN (BILLING SUMMARY) -->
                <div class="pms-card" style="background: #f8fafc; border: 2px solid #cbd5e1;">
                    <div class="pms-card-header" style="border-bottom-color: #475569;">
                        <span>3. Tổng Hợp Chi Phí Đặt Phòng</span>
                        <span id="step2SummaryRoomCount" style="font-size: 13px; color: #64748b; text-transform: none;">0 phòng</span>
                    </div>

                    <div style="display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 8px; color: #475569;">
                        <span>Tiền phòng:</span>
                        <strong id="step2SumRoomCost" style="color: #0f172a; font-size: 15px;">0 VNĐ</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; font-size: 14px; margin-bottom: 12px; color: #475569;">
                        <span>Tiền dịch vụ đặt trước:</span>
                        <strong id="step2SumServiceCost" style="color: #0f172a; font-size: 15px;">0 VNĐ</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between; font-size: 16px; padding-top: 12px; border-top: 2px dashed #cbd5e1; color: #0f172a;">
                        <span style="font-weight: 800;">TỔNG CỘNG THANH TOÁN:</span>
                        <strong id="step2SumTotalCost" style="color: #dc2626; font-size: 18px;">0 VNĐ</strong>
                    </div>

                    <!-- HÀNG NÚT ĐIỀU HƯỚNG VÀ XÁC NHẬN -->
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; gap: 12px; flex-wrap: wrap;">
                        <button type="button" class="pms-btn pms-btn-secondary" onclick="goToStep(1)">
                            [ <- Quay Lại Chọn Phòng ]
                        </button>
                        <div style="display: flex; gap: 10px;">
                            <button type="submit" name="actionType" value="checkin_now" class="pms-btn pms-btn-success" style="padding: 12px 20px; font-size: 14px;">
                                [ Đặt & Nhận Phòng Ngay ]
                            </button>
                            <button type="submit" name="actionType" value="reserve" class="pms-btn pms-btn-primary" style="padding: 12px 20px; font-size: 14px;">
                                [ Đặt Phòng Giữ Chỗ (Chờ Nhận) ]
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </form>

    </div>
</div>

<script>
    function calculateNights() {
        const dIn = new Date(document.getElementById('dateCheckIn').value);
        const dOut = new Date(document.getElementById('dateCheckOut').value);
        const diffTime = dOut - dIn;
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        return diffDays > 0 ? diffDays : 1;
    }

    function onDateFilterChange() {
        const dIn = document.getElementById('dateCheckIn').value;
        const dOut = document.getElementById('dateCheckOut').value;
        if (dIn && dOut && dIn < dOut) {
            window.location.href = '${pageContext.request.contextPath}/receptionist/booking?checkIn=' + encodeURIComponent(dIn) + '&checkOut=' + encodeURIComponent(dOut);
        }
    }

    function onRoomCheckboxChange() {
        const nights = calculateNights();
        let totalRoomCost = 0;
        let selectedCount = 0;

        document.querySelectorAll('input[name="selectedRooms"]').forEach(chk => {
            const price = parseFloat(chk.getAttribute('data-price')) || 0;
            const subtotalSpan = document.getElementById('roomSubtotal_' + chk.value);
            if (subtotalSpan) {
                subtotalSpan.innerText = formatVnd(price * nights);
            }

            if (chk.checked) {
                selectedCount++;
                totalRoomCost += price * nights;
            }
        });

        document.getElementById('nightsCounter').innerText = nights + ' đêm';
        document.getElementById('step1SelectedCount').innerText = selectedCount;
        document.getElementById('step1TotalRoomCost').innerText = formatVnd(totalRoomCost);
    }

    function goToStep(stepNumber) {
        if (stepNumber === 2) {
            const selectedCheckboxes = document.querySelectorAll('input[name="selectedRooms"]:checked');
            if (selectedCheckboxes.length === 0) {
                alert('[Cảnh báo] Vui lòng tích chọn ít nhất một phòng trống để tiếp tục!');
                return;
            }

            // Đồng bộ danh sách card dịch vụ ở Bước 2
            selectedCheckboxes.forEach(chk => {
                const card = document.getElementById('roomSvcCard_' + chk.value);
                if (card) {
                    card.style.display = 'block';
                }
            });

            // Ẩn các phòng không được chọn
            document.querySelectorAll('input[name="selectedRooms"]:not(:checked)').forEach(chk => {
                const card = document.getElementById('roomSvcCard_' + chk.value);
                if (card) {
                    card.style.display = 'none';
                    card.querySelectorAll('input[type="number"]').forEach(inp => inp.value = 0);
                }
            });

            document.getElementById('step1Container').style.display = 'none';
            document.getElementById('step2Container').style.display = 'block';

            document.getElementById('stepNav1').className = 'step-item completed';
            document.getElementById('stepNav2').className = 'step-item active';

            recalculateStep2Bill();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        } else {
            document.getElementById('step1Container').style.display = 'block';
            document.getElementById('step2Container').style.display = 'none';

            document.getElementById('stepNav1').className = 'step-item active';
            document.getElementById('stepNav2').className = 'step-item';

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
    }

    function changeQty(roomId, svcId, delta) {
        const inp = document.getElementById('qty_' + roomId + '_' + svcId);
        if (inp) {
            let val = parseInt(inp.value) || 0;
            val += delta;
            if (val < 0) val = 0;
            if (val > 20) val = 20;
            inp.value = val;
            recalculateStep2Bill();
        }
    }

    function recalculateStep2Bill() {
        const nights = calculateNights();
        let totalRoomCost = 0;
        let totalSvcCost = 0;
        let selectedCount = 0;

        document.querySelectorAll('input[name="selectedRooms"]:checked').forEach(chk => {
            selectedCount++;
            const price = parseFloat(chk.getAttribute('data-price')) || 0;
            totalRoomCost += price * nights;

            const card = document.getElementById('roomSvcCard_' + chk.value);
            if (card) {
                card.querySelectorAll('input[type="number"]').forEach(inp => {
                    const qty = parseInt(inp.value) || 0;
                    const svcPrice = parseFloat(inp.getAttribute('data-price')) || 0;
                    totalSvcCost += qty * svcPrice;
                });
            }
        });

        document.getElementById('step2SummaryRoomCount').innerText = selectedCount + ' phòng (' + nights + ' đêm)';
        document.getElementById('step2SumRoomCost').innerText = formatVnd(totalRoomCost);
        document.getElementById('step2SumServiceCost').innerText = formatVnd(totalSvcCost);
        document.getElementById('step2SumTotalCost').innerText = formatVnd(totalRoomCost + totalSvcCost);
    }

    function formatVnd(num) {
        return num.toLocaleString('vi-VN') + ' VNĐ';
    }

    window.addEventListener('DOMContentLoaded', function() {
        onRoomCheckboxChange();
    });
</script>

<jsp:include page="/views/common/footer.jsp" />
