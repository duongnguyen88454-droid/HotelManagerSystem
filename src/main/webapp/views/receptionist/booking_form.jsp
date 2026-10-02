<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Đặt Phòng Tại Quầy - Bàn Làm Việc Lễ Tân" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="content-wrapper" style="background-color: #f1f5f9; min-height: calc(100vh - 120px); padding: 24px 0;">
    <div class="container-fluid" style="max-width: 1400px; margin: 0 auto; padding: 0 20px;">

        <!-- HEADER & ACTIONS -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px;">
            <div>
                <h2 style="color: #0f172a; margin: 0; font-size: 22px; font-weight: 800;">TIẾP NHẬN ĐẶT PHÒNG TẠI QUẦY (WALK-IN)</h2>
                <p style="color: #64748b; margin: 4px 0 0 0; font-size: 13px;">Tạo đơn đặt phòng trực tiếp cho khách vãng lai nhận dạng qua số CCCD</p>
            </div>
            <div style="display: flex; gap: 10px;">
                <a href="${pageContext.request.contextPath}/receptionist/room-map" class="pms-btn pms-btn-secondary" style="text-decoration: none;">[ Sơ Đồ Phòng ]</a>
                <a href="${pageContext.request.contextPath}/receptionist/checkin" class="pms-btn pms-btn-secondary" style="text-decoration: none;">[ Quầy Tiếp Đón Check-in ]</a>
            </div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" style="background-color: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; font-weight: 600;">
                [Lỗi] ${errorMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/receptionist/booking" method="POST" id="receptionistBookingForm">
            <div style="display: grid; grid-template-columns: 380px 1fr; gap: 20px; align-items: start;">

                <!-- CỘT TRÁI: THÔNG TIN KHÁCH HÀNG & THỜI GIAN -->
                <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <h3 style="font-size: 15px; font-weight: 700; color: #1e293b; margin-top: 0; margin-bottom: 16px; border-bottom: 2px solid #0284c7; padding-bottom: 8px;">
                        1. HỒ SƠ KHÁCH LƯU TRÚ
                    </h3>

                    <!-- TRA CỨU CCCD -->
                    <div style="margin-bottom: 14px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">
                            Số CCCD (12 số) <span style="color: #ef4444;">*</span>
                        </label>
                        <div style="display: flex; gap: 8px;">
                            <input type="text" id="guestCccd" name="cccd" class="pms-input" placeholder="Nhập 12 chữ số..." required maxlength="12" pattern="[0-9]{12}" style="flex: 1;" onblur="autoLookupCustomer()">
                            <button type="button" class="pms-btn pms-btn-secondary" onclick="autoLookupCustomer()">[ Tra Cứu ]</button>
                        </div>
                        <span id="lookupStatus" style="font-size: 11px; display: block; margin-top: 4px;"></span>
                    </div>

                    <!-- HỌ VÀ TÊN -->
                    <div style="margin-bottom: 14px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">
                            Họ và Tên khách đại diện <span style="color: #ef4444;">*</span>
                        </label>
                        <input type="text" id="guestName" name="hoTen" class="pms-input" placeholder="Ví dụ: Nguyễn Văn An" required style="width: 100%;">
                    </div>

                    <!-- SỐ ĐIỆN THOẠI -->
                    <div style="margin-bottom: 14px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">
                            Số điện thoại liên lạc <span style="color: #ef4444;">*</span>
                        </label>
                        <input type="text" id="guestPhone" name="soDT" class="pms-input" placeholder="Ví dụ: 0901234567" required style="width: 100%;">
                    </div>

                    <!-- EMAIL -->
                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">
                            Địa chỉ Email (nếu có)
                        </label>
                        <input type="email" id="guestEmail" name="email" class="pms-input" placeholder="guest@example.com" style="width: 100%;">
                    </div>

                    <h3 style="font-size: 15px; font-weight: 700; color: #1e293b; margin-top: 24px; margin-bottom: 16px; border-bottom: 2px solid #0284c7; padding-bottom: 8px;">
                        2. THỜI GIAN LƯU TRÚ
                    </h3>

                    <!-- NGÀY NHẬN & TRẢ -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 14px;">
                        <div>
                            <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Ngày nhận</label>
                            <input type="date" id="dateCheckIn" name="checkIn" value="${checkIn}" class="pms-input" style="width: 100%;" onchange="refreshAvailableRooms()">
                        </div>
                        <div>
                            <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Ngày trả</label>
                            <input type="date" id="dateCheckOut" name="checkOut" value="${checkOut}" class="pms-input" style="width: 100%;" onchange="refreshAvailableRooms()">
                        </div>
                    </div>

                    <div style="margin-bottom: 16px;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Ghi chú đơn đặt phòng</label>
                        <textarea name="note" class="pms-input" rows="3" style="width: 100%; resize: vertical;" placeholder="Khách có yêu cầu đặc biệt..."></textarea>
                    </div>

                    <!-- NÚT HÀNH ĐỘNG -->
                    <div style="display: flex; flex-direction: column; gap: 10px; margin-top: 24px;">
                        <button type="submit" name="actionType" value="checkin_now" class="pms-btn pms-btn-success" style="padding: 12px; font-size: 14px; font-weight: 700;">
                            [ Đặt & Nhận Phòng Ngay ]
                        </button>
                        <button type="submit" name="actionType" value="reserve" class="pms-btn pms-btn-primary" style="padding: 10px; font-size: 13px;">
                            [ Đặt Phòng Giữ Chỗ (Chờ Nhận) ]
                        </button>
                    </div>
                </div>

                <!-- CỘT PHẢI: DANH SÁCH PHÒNG TRỐNG & DỊCH VỤ -->
                <div style="background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; border-bottom: 2px solid #0284c7; padding-bottom: 8px;">
                        <h3 style="font-size: 15px; font-weight: 700; color: #1e293b; margin: 0;">
                            3. CHỌN PHÒNG TRỐNG KHẢ DỤNG
                        </h3>
                        <span style="font-size: 12px; color: #64748b; font-weight: 600;">
                            Tìm thấy: <strong style="color: #0284c7;">${availableRooms.size()}</strong> phòng khả dụng
                        </span>
                    </div>

                    <c:choose>
                        <c:when test="${empty availableRooms}">
                            <div style="padding: 30px; text-align: center; color: #94a3b8; background: #f8fafc; border-radius: 6px;">
                                [Thông báo] Không có phòng nào khả dụng trong khoảng thời gian này. Vui lòng chọn khoảng ngày khác.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="max-height: 520px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 6px;">
                                <table class="pms-table" style="width: 100%; border-collapse: collapse;">
                                    <thead>
                                        <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; text-align: left;">
                                            <th style="width: 40px; text-align: center; padding: 10px 8px;">Chọn</th>
                                            <th style="padding: 10px 12px;">Số Phòng</th>
                                            <th style="padding: 10px 12px;">Hạng Phòng</th>
                                            <th style="padding: 10px 12px;">Tầng</th>
                                            <th style="padding: 10px 12px; text-align: right;">Đơn Giá / Đêm</th>
                                            <th style="padding: 10px 12px;">Thêm Dịch Vụ Phòng</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="rm" items="${availableRooms}">
                                            <tr style="border-bottom: 1px solid #f1f5f9;">
                                                <td style="text-align: center; padding: 10px 8px;">
                                                    <input type="checkbox" name="selectedRooms" value="${rm.maPhong}" id="chk_${rm.maPhong}"
                                                        <c:if test="${rm.maPhong eq preselectedRoomId}">checked</c:if>
                                                        onchange="toggleRoomServices('${rm.maPhong}')">
                                                    <input type="hidden" name="soPhong_${rm.maPhong}" value="${rm.soPhong}">
                                                    <input type="hidden" name="tenLoaiPhong_${rm.maPhong}" value="${rm.tenLoaiPhong}">
                                                    <input type="hidden" name="maLoaiPhong_${rm.maPhong}" value="${rm.maLoaiPhong}">
                                                    <input type="hidden" name="donGia_${rm.maPhong}" value="${rm.giaMoiDem}">
                                                </td>
                                                <td style="padding: 10px 12px; font-weight: 700; color: #0f172a;">
                                                    ${rm.soPhong}
                                                </td>
                                                <td style="padding: 10px 12px; color: #475569;">
                                                    ${rm.tenLoaiPhong}
                                                </td>
                                                <td style="padding: 10px 12px; color: #64748b;">
                                                    Tầng ${rm.soTang}
                                                </td>
                                                <td style="padding: 10px 12px; text-align: right; font-weight: 700; color: #0284c7;">
                                                    <fmt:formatNumber value="${rm.giaMoiDem}" type="currency" currencySymbol="" maxFractionDigits="0"/> VNĐ
                                                </td>
                                                <td style="padding: 10px 12px;">
                                                    <div id="svcBox_${rm.maPhong}" style="display: <c:choose><c:when test='${rm.maPhong eq preselectedRoomId}'>block</c:when><c:otherwise>none</c:otherwise></c:choose>;">
                                                        <c:forEach var="s" items="${services}">
                                                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; font-size: 11px;">
                                                                <span>${s.tenDichVu} (<fmt:formatNumber value="${s.donGia}" type="currency" currencySymbol="" maxFractionDigits="0"/>đ):</span>
                                                                <input type="number" name="svc_${rm.maPhong}_${s.maDichVu}" min="0" max="20" value="0" style="width: 50px; padding: 2px 4px; font-size: 11px; border: 1px solid #cbd5e1; border-radius: 4px; text-align: center;">
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                    <span id="svcPlaceholder_${rm.maPhong}" style="color: #94a3b8; font-style: italic; font-size: 11px; display: <c:choose><c:when test='${rm.maPhong eq preselectedRoomId}'>none</c:when><c:otherwise>inline</c:otherwise></c:choose>;">
                                                        (Tích chọn phòng để mở menu dịch vụ)
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </form>

    </div>
</div>

<script>
    function autoLookupCustomer() {
        const cccd = document.getElementById('guestCccd').value.trim();
        const statusSpan = document.getElementById('lookupStatus');

        if (!cccd || cccd.length !== 12) {
            statusSpan.innerText = '';
            return;
        }

        statusSpan.innerText = 'Đang tra cứu dữ liệu khách cũ...';
        statusSpan.style.color = '#0284c7';

        fetch('${pageContext.request.contextPath}/receptionist/booking?action=lookup-customer&cccd=' + encodeURIComponent(cccd))
            .then(res => res.json())
            .then(data => {
                if (data.found) {
                    document.getElementById('guestName').value = data.hoTen || '';
                    document.getElementById('guestPhone').value = data.soDT || '';
                    document.getElementById('guestEmail').value = data.email || '';
                    statusSpan.innerText = '[Khách cũ] Đã tự động điền hồ sơ khách lưu trú.';
                    statusSpan.style.color = '#15803d';
                } else {
                    statusSpan.innerText = '[Khách mới] Chưa có lịch sử lưu trú, vui lòng điền thông tin.';
                    statusSpan.style.color = '#b45309';
                }
            })
            .catch(err => {
                statusSpan.innerText = '[Lỗi kết nối tra cứu]';
                statusSpan.style.color = '#dc2626';
            });
    }

    function toggleRoomServices(roomId) {
        const chk = document.getElementById('chk_' + roomId);
        const svcBox = document.getElementById('svcBox_' + roomId);
        const placeholder = document.getElementById('svcPlaceholder_' + roomId);

        if (chk.checked) {
            svcBox.style.display = 'block';
            placeholder.style.display = 'none';
        } else {
            svcBox.style.display = 'none';
            placeholder.style.display = 'inline';
        }
    }

    function refreshAvailableRooms() {
        const dIn = document.getElementById('dateCheckIn').value;
        const dOut = document.getElementById('dateCheckOut').value;
        if (dIn && dOut && dIn < dOut) {
            window.location.href = '${pageContext.request.contextPath}/receptionist/booking?checkIn=' + encodeURIComponent(dIn) + '&checkOut=' + encodeURIComponent(dOut);
        }
    }
</script>

<jsp:include page="/views/common/footer.jsp" />
