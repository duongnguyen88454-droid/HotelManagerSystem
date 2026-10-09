<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Tiếp Nhận Đặt Phòng Tại Quầy - Bàn Làm Việc Lễ Tân" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist/booking_form.css">

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
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/booking_form.js"></script>

<jsp:include page="/views/common/footer.jsp" />
