<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Điền Thông Tin & Xác Nhận Đặt Phòng" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking/booking_form.css">

<div class="container my-6">

    <!-- Breadcrumb -->
    <nav class="breadcrumb-nav mb-4" aria-label="Breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/home">Trang Chủ</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/search-rooms">Tìm Phòng</a></li>
            <li class="breadcrumb-item active" aria-current="page">Điền Thông Tin & Dịch Vụ Bổ Sung</li>
        </ol>
    </nav>

    <!-- Thông báo lỗi (nếu có) -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger mb-4">
            <strong>Lỗi:</strong> ${errorMessage}
        </div>
    </c:if>

    <c:choose>
        <%-- TRƯỜNG HỢP 1: KHÁCH ĐANG CẤU HÌNH VÀ CHỌN DỊCH VỤ CHO MỘT PHÒNG CỤ THỂ --%>
        <c:when test="${not empty currentRoom}">

            <div class="card p-5 mb-5 shadow-sm">
                <div class="flex justify-between items-center flex-wrap gap-4">
                    <div>
                        <span class="badge badge-primary uppercase mb-2">
                            ${currentRoom.tenLoaiPhong}
                        </span>
                        <h1 class="page-title text-2xl font-bold text-primary mt-1 mb-1">
                            Cấu Hình ${currentRoom.soPhong} &amp; Dịch Vụ Kèm Theo
                        </h1>
                        <p class="text-secondary text-sm m-0">
                            Thời gian lưu trú: từ <strong>${currentRoom.ngayNhan}</strong> đến
                            <strong>${currentRoom.ngayTra}</strong> (${currentRoom.soDem} đêm)
                        </p>
                    </div>
                    <div class="text-right">
                        <div class="text-xs text-muted">Tiền phòng cơ bản:</div>
                        <div class="text-2xl font-bold text-accent">
                            <fmt:formatNumber value="${currentRoom.tongTienDuKien}" type="number" maxFractionDigits="0" /> đ
                        </div>
                        <div class="text-xs text-muted">
                            (<fmt:formatNumber value="${currentRoom.donGia}" type="number" maxFractionDigits="0" /> đ x ${currentRoom.soDem} đêm)
                        </div>
                        <c:if test="${currentRoom.tienCoc > 0}">
                            <div class="text-xs text-primary font-semibold mt-1">
                                Tiền cọc cần thanh toán:
                                <fmt:formatNumber value="${currentRoom.tienCoc}" type="number" maxFractionDigits="0" /> đ
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Form điền thông tin và dịch vụ -->
            <form id="addRoomForm" action="${pageContext.request.contextPath}/customer/cart/add"
                method="POST" onsubmit="handleFormSubmit(event)">
                <input type="hidden" name="maPhong" value="${currentRoom.maPhong}">
                <input type="hidden" name="roomId" value="${currentRoom.maPhong}">
                <input type="hidden" name="checkIn" value="${not empty paramCheckIn ? paramCheckIn : currentRoom.ngayNhan}">
                <input type="hidden" name="checkOut" value="${not empty paramCheckOut ? paramCheckOut : currentRoom.ngayTra}">
                <input type="hidden" name="isAjax" value="true">

                <!-- Lựa chọn dịch vụ bổ sung kèm theo phòng này -->
                <div class="card p-5 mb-5 shadow-sm">
                    <div class="flex justify-between items-center border-b pb-3 mb-4">
                        <h3 class="card-title text-base font-bold text-primary m-0">
                            Thêm Dịch Vụ Kèm Theo Cho ${currentRoom.soPhong}
                        </h3>
                        <span class="text-xs text-muted">
                            Tùy chọn - Có thể bỏ qua nếu bạn chỉ muốn thuê phòng
                        </span>
                    </div>

                    <c:choose>
                        <c:when test="${not empty activeServices}">
                            <div class="table-responsive">
                                <table class="table table-hover booking-service-table">
                                    <thead>
                                        <tr>
                                            <th class="text-center w-12">Chọn</th>
                                            <th>Tên Dịch Vụ</th>
                                            <th class="text-right">Đơn Giá</th>
                                            <th class="text-center">Số Lượng</th>
                                            <th class="text-right">Thành Tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="svc" items="${activeServices}">
                                            <fmt:formatNumber var="rawDonGia" value="${svc.donGia}" groupingUsed="false" maxFractionDigits="0" />
                                            <tr id="row_${svc.maDichVu}">
                                                <td class="text-center">
                                                    <input type="checkbox"
                                                        class="booking-service-cb"
                                                        name="service_${svc.maDichVu}"
                                                        value="${svc.maDichVu}"
                                                        id="cb_${svc.maDichVu}"
                                                        data-service-id="${svc.maDichVu}"
                                                        data-unit-price="${rawDonGia}"
                                                        onchange="toggleService(this)">
                                                </td>
                                                <td>
                                                    <label for="cb_${svc.maDichVu}" class="font-semibold text-secondary cursor-pointer">
                                                        ${svc.tenDichVu}
                                                    </label>
                                                </td>
                                                <td class="text-right text-muted">
                                                    <fmt:formatNumber value="${svc.donGia}" type="number" maxFractionDigits="0" /> đ
                                                </td>
                                                <td class="text-center">
                                                    <input type="number"
                                                        name="qty_${svc.maDichVu}"
                                                        id="qty_${svc.maDichVu}"
                                                        value="1"
                                                        min="1"
                                                        max="20"
                                                        disabled
                                                        class="booking-service-qty"
                                                        data-service-id="${svc.maDichVu}"
                                                        data-unit-price="${rawDonGia}"
                                                        onchange="updateServiceSubtotal(this)">
                                                </td>
                                                <td class="text-right font-bold text-secondary" id="subtotal_${svc.maDichVu}">
                                                    0 đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted text-sm m-0">Hiện tại khách sạn chưa kích hoạt dịch vụ bổ sung nào.</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Khối 3: Tóm tắt chi phí & Nút hành động chính -->
                <div class="card p-5 shadow-md flex justify-between items-center flex-wrap gap-4">
                    <div>
                        <div class="text-sm text-secondary">
                            Tiền phòng: <strong id="displayRoomPrice" class="text-primary font-bold">
                                <fmt:formatNumber value="${currentRoom.tongTienDuKien}" type="number" maxFractionDigits="0" /> đ
                            </strong>
                            &nbsp;+ Dịch vụ thêm: <strong id="displayServiceTotal" class="text-primary font-bold">0 đ</strong>
                        </div>
                        <div class="text-lg font-bold text-primary mt-1">
                            Tổng Chi Phí Dự Kiến Phòng Này:
                            <span id="displayGrandTotal" class="text-accent text-2xl font-bold ml-2">
                                <fmt:formatNumber value="${currentRoom.tongTienDuKien}" type="number" maxFractionDigits="0" /> đ
                            </span>
                        </div>
                    </div>

                    <div class="flex gap-3 items-center">
                        <a href="${pageContext.request.contextPath}/customer/room-detail?maPhong=${currentRoom.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                            class="btn btn-secondary">
                            Quay Lại Xem Phòng
                        </a>

                        <!-- Nút Thêm Vào Booking - Kích hoạt Modal Popup -->
                        <button type="submit" id="submitBtn" class="btn btn-primary px-5 py-3 text-base font-bold">
                            Thêm Vào Booking
                        </button>
                    </div>
                </div>
            </form>

        </c:when>

        <%-- TRƯỜNG HỢP 2: MÀN HÌNH XEM LẠI TOÀN BỘ GIỎ HÀNG & CHỐT ĐẶT ĐƠN (CHECKOUT) --%>
        <c:otherwise>

            <c:choose>
                <%-- 2.1: Giỏ hàng trống --%>
                <c:when test="${empty bookingCart || bookingCart.totalRoomCount == 0}">
                    <div class="card p-6 text-center shadow-sm my-6">
                        <div class="mb-4">
                            <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="text-muted">
                                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                                <polyline points="9 22 9 12 15 12 15 22"></polyline>
                            </svg>
                        </div>
                        <h2 class="text-xl font-bold text-primary mb-2">
                            Giỏ Đặt Phòng Của Bạn Hiện Đang Trống
                        </h2>
                        <p class="text-secondary text-sm max-w-md mx-auto mb-5 leading-relaxed">
                            Bạn chưa thêm phòng nào vào đơn đặt hoặc đã xóa hết phòng khỏi giỏ.
                            Vui lòng tìm kiếm phòng theo ngày nhận và trả phòng phù hợp để bắt đầu kỳ nghỉ!
                        </p>
                        <div>
                            <a href="${pageContext.request.contextPath}/customer/search-rooms" class="btn btn-primary px-6 py-3">
                                Tìm Kiếm &amp; Đặt Phòng Ngay
                            </a>
                        </div>
                    </div>
                </c:when>

                <%-- 2.2: Giỏ hàng có phòng cần rà soát --%>
                <c:otherwise>

                    <div class="card p-5 mb-5 shadow-sm">
                        <h1 class="page-title text-2xl font-bold text-primary m-0">
                            Rà Soát Đơn Đặt Phòng &amp; Xác Nhận Chốt Đơn
                        </h1>
                    </div>

                    <!-- Form xác nhận chốt đơn -->
                    <form id="checkoutBookingForm" action="${pageContext.request.contextPath}/customer/booking" method="POST">
                        <!-- 1. KHỐI THÔNG TIN KHÁCH HÀNG LƯU TRÚ ĐẠI DIỆN -->
                        <div class="card p-5 mb-5 shadow-sm">
                            <div class="flex justify-between items-center border-b pb-3 mb-4">
                                <h3 class="card-title text-base font-bold text-primary m-0">
                                    Thông Tin Khách Hàng Lưu Trú (Đại Diện Nhận Phòng)
                                </h3>
                                <c:choose>
                                    <c:when test="${not empty savedGuest.cccd || not empty sessionScope.SAVED_CCCD}">
                                        <span class="badge badge-success">
                                            Đã tự động điền từ hồ sơ lưu trú
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">
                                            Nhập 1 lần duy nhất - Hệ thống sẽ tự động lưu lại
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                                <div class="form-group mb-0">
                                    <label class="form-label font-bold text-secondary text-xs">
                                        Họ và Tên Khách Hàng <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" name="customerName"
                                        value="${not empty savedGuest.hoTen ? savedGuest.hoTen : (not empty sessionScope.CURRENT_USER.hoTen ? sessionScope.CURRENT_USER.hoTen : sessionScope.CURRENT_USER.hoTenTaiKhoan)}"
                                        required class="form-control">
                                </div>

                                <div class="form-group mb-0">
                                    <label class="form-label font-bold text-secondary text-xs">
                                        Số Điện Thoại Liên Hệ <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" name="customerPhone"
                                        value="${not empty savedGuest.soDT ? savedGuest.soDT : sessionScope.CURRENT_USER.soDT}"
                                        required placeholder="" class="form-control">
                                </div>

                                <div class="form-group mb-0">
                                    <label class="form-label font-bold text-secondary text-xs">
                                        Địa Chỉ Email <span class="text-danger">*</span>
                                    </label>
                                    <input type="email" name="customerEmail"
                                        value="${not empty savedGuest.email ? savedGuest.email : sessionScope.CURRENT_USER.email}"
                                        required class="form-control">
                                </div>

                                <div class="form-group mb-0">
                                    <label class="form-label font-bold text-secondary text-xs">
                                        Số CCCD Người Lưu Trú (12 chữ số) <span class="text-danger">*</span>
                                    </label>
                                    <input type="text" name="customerCccd" required
                                        pattern="[0-9]{12}" maxlength="12"
                                        value="${not empty savedGuest.cccd ? savedGuest.cccd : sessionScope.SAVED_CCCD}"
                                        placeholder="" class="form-control">
                                </div>
                            </div>
                        </div>

                        <!-- 2. KHỐI DANH SÁCH CÁC PHÒNG ĐÃ CHỌN -->
                        <div class="card p-5 mb-5 shadow-sm">
                            <h3 class="card-title text-base font-bold text-primary pb-3 mb-4 border-b">
                                Danh Sách Các Phòng Đã Chọn (${bookingCart.totalRoomCount} phòng)
                            </h3>

                            <c:forEach var="entry" items="${bookingCart.items}">
                                <c:set var="item" value="${entry.value}" />
                                <div class="card p-4 mb-3 border bg-light">
                                    <div class="flex justify-between items-start flex-wrap gap-4">
                                        <div>
                                            <div class="text-base font-bold text-primary">
                                                ${item.soPhong} - ${item.tenLoaiPhong}
                                            </div>
                                            <div class="text-xs text-muted mt-1">
                                                Kỳ lưu trú:
                                                <strong>${item.ngayNhan}</strong> đến <strong>${item.ngayTra}</strong>
                                                (${item.soDem} đêm)
                                            </div>
                                            <div class="text-xs text-secondary mt-1">
                                                Tiền phòng:
                                                <fmt:formatNumber value="${item.tienPhong}" type="number" maxFractionDigits="0" /> đ
                                                &bull; Tiền dịch vụ:
                                                <fmt:formatNumber value="${item.tongTienDichVu}" type="number" maxFractionDigits="0" /> đ
                                                <c:if test="${item.tienCoc > 0}">
                                                    &bull; Cọc:
                                                    <fmt:formatNumber value="${item.tienCoc}" type="number" maxFractionDigits="0" /> đ
                                                </c:if>
                                            </div>

                                            <c:if test="${not empty item.selectedServices}">
                                                <div class="mt-2 text-xs text-primary font-medium">
                                                    <strong>Dịch vụ kèm:</strong>
                                                    <c:forEach var="s" items="${item.selectedServices}" varStatus="loop">
                                                        ${s.tenDichVu} (x${s.soLuong})<c:if test="${!loop.last}">, </c:if>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                        </div>

                                        <div class="text-right">
                                            <div class="text-lg font-bold text-accent">
                                                <fmt:formatNumber value="${item.tongTienPhongVaDichVu}" type="number" maxFractionDigits="0" /> đ
                                            </div>
                                            <button type="button"
                                                onclick="openRemoveRoomModal('${item.maPhong}', '${item.soPhong} - ${item.tenLoaiPhong}')"
                                                class="btn btn-outline btn-danger btn-sm mt-2">
                                                Xóa Khỏi Giỏ
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>

                            <div class="text-right pt-4 border-t mt-3">
                                <div class="text-sm text-muted">Tổng Cộng Toàn Bộ Đơn Hàng:</div>
                                <div class="text-2xl font-bold text-accent mt-1">
                                    <fmt:formatNumber value="${bookingCart.grandTotal}" type="number" maxFractionDigits="0" /> đ
                                </div>
                                <c:if test="${bookingCart.totalDeposit > 0}">
                                    <div class="text-sm font-semibold text-primary mt-1">
                                        Tiền cọc cần thanh toán:
                                        <fmt:formatNumber value="${bookingCart.totalDeposit}" type="number" maxFractionDigits="0" /> đ
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- 3. KHỐI GHI CHÚ CHUNG -->
                        <div class="card p-5 mb-5 shadow-sm">
                            <h3 class="card-title text-base font-bold text-primary pb-3 mb-3 border-b">
                                Ghi Chú Chung Cho Đơn Đặt Phòng
                            </h3>
                            <textarea name="note" rows="3" class="form-control"
                                placeholder="Nhập ghi chú chung cho toàn bộ chuyến đi nếu có..."></textarea>
                        </div>

                        <!-- 4. HÀNG NÚT THAO TÁC -->
                        <div class="flex justify-between items-center flex-wrap gap-4">
                            <a href="${pageContext.request.contextPath}/customer/search-rooms" class="btn btn-secondary">
                                + Đặt Thêm Phòng Khác
                            </a>

                            <button type="submit" class="btn btn-primary px-6 py-3 text-base font-bold">
                                Xác Nhận Đặt Toàn Bộ Đơn Phòng
                            </button>
                        </div>
                    </form>

                    <!-- Modal Xác Nhận Xóa Phòng Khỏi Giỏ Chuẩn UI/UX -->
                    <div id="removeRoomModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 1050; align-items: center; justify-content: center;">
                        <div class="card p-6 shadow-lg animate-in" style="max-width: 440px; width: 90%; background: #ffffff; border-radius: var(--radius-lg, 12px); border: 1px solid var(--color-border, #e2e8f0);">
                            <div class="flex items-center gap-3 mb-4 text-danger">
                                <div style="width: 40px; height: 40px; border-radius: 50%; background: #fee2e2; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <polyline points="3 6 5 6 21 6"></polyline>
                                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                        <line x1="10" y1="11" x2="10" y2="17"></line>
                                        <line x1="14" y1="11" x2="14" y2="17"></line>
                                    </svg>
                                </div>
                                <div>
                                    <h3 class="m-0 text-lg font-bold text-gray-900">Xác Nhận Xóa Phòng</h3>
                                    <p class="text-xs text-muted m-0">Loại bỏ phòng nghỉ này khỏi giỏ hàng hiện tại</p>
                                </div>
                            </div>
                            <p class="text-secondary text-sm mb-4">
                                Bạn có chắc chắn muốn xóa <strong id="modalRemoveRoomName" class="text-primary font-bold"></strong> khỏi đơn đặt phòng không?
                            </p>
                            <div class="flex justify-end gap-3">
                                <button type="button" class="btn btn-secondary btn-sm" onclick="closeRemoveRoomModal()">
                                    Giữ Lại
                                </button>
                                <button type="button" class="btn btn-danger btn-sm font-semibold" onclick="submitRemoveRoom()">
                                    Xác Nhận Xóa
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Form ẩn xử lý xóa phòng khỏi giỏ an toàn -->
                    <form id="hiddenRemoveForm" action="${pageContext.request.contextPath}/customer/cart/remove"
                        method="POST" style="display: none;">
                        <input type="hidden" name="roomId" id="removeRoomIdInput">
                    </form>
                    <script>
                        function openRemoveRoomModal(roomId, roomName) {
                            var input = document.getElementById('removeRoomIdInput');
                            var text = document.getElementById('modalRemoveRoomName');
                            var modal = document.getElementById('removeRoomModal');
                            if (input) input.value = roomId;
                            if (text) text.textContent = roomName ? '[' + roomName + ']' : '[' + roomId + ']';
                            if (modal) modal.style.display = 'flex';
                        }

                        function closeRemoveRoomModal() {
                            var modal = document.getElementById('removeRoomModal');
                            if (modal) modal.style.display = 'none';
                        }

                        function submitRemoveRoom() {
                            var form = document.getElementById('hiddenRemoveForm');
                            if (form) form.submit();
                        }

                        // Đóng modal khi bấm ra ngoài phần backdrop
                        window.addEventListener('click', function(event) {
                            var modal = document.getElementById('removeRoomModal');
                            if (event.target === modal) {
                                closeRemoveRoomModal();
                            }
                        });
                    </script>

                </c:otherwise>
            </c:choose>

        </c:otherwise>
    </c:choose>

</div>

<!-- CỬA SỔ NHỎ / POPUP MODAL TÓM TẮT & LỰA CHỌN NGHIỆP VỤ (BƯỚC 5) -->
<div id="bookingPopupModal" class="booking-modal-backdrop">
    <div class="booking-modal-card">

        <!-- Header modal -->
        <div class="modal-header bg-primary text-white p-4 flex justify-between items-center">
            <h3 class="modal-title text-base font-bold text-white m-0">
                Đã Thêm Phòng Vào Đơn Đặt Thành Công!
            </h3>
            <button type="button" onclick="closePopupModal()" class="text-white hover:opacity-80 bg-transparent border-0 text-xl cursor-pointer p-0 leading-none">&times;</button>
        </div>

        <!-- Body modal -->
        <div class="p-5" id="modalBodyContent">

            <div class="alert alert-success text-xs font-semibold mb-4">
                Phòng đã được lưu trữ an toàn trong giỏ hàng phiên làm việc của bạn.
            </div>

            <!-- Bảng tóm tắt phòng vừa thêm -->
            <div class="card p-4 mb-4 text-xs bg-light border">
                <div class="flex justify-between py-1">
                    <span class="text-muted">Phòng đã chọn:</span>
                    <strong id="modalRoomName" class="text-primary font-bold">...</strong>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-muted">Thời gian ở:</span>
                    <strong id="modalPeriod">...</strong>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-muted">Tiền phòng:</span>
                    <span id="modalRoomPrice" class="font-medium">0 đ</span>
                </div>
                <div class="flex justify-between py-1">
                    <span class="text-muted">Dịch vụ bổ sung:</span>
                    <span id="modalServicePrice" class="font-medium">0 đ</span>
                </div>
                <div class="border-t mt-2 pt-2 flex justify-between text-sm font-bold text-primary">
                    <span>Tổng phòng này:</span>
                    <span id="modalRoomTotal" class="text-accent">0 đ</span>
                </div>
            </div>

            <!-- Tình trạng giỏ hàng tổng thể -->
            <div class="text-xs text-secondary mb-5 text-center">
                Đơn booking của bạn hiện đang có <strong id="modalCartRooms" class="text-primary">1 phòng</strong>.
                <br>Tổng tiền tạm tính toàn bộ đơn: <strong id="modalGrandTotal" class="text-primary text-sm font-bold">0 đ</strong>
            </div>

            <!-- 2 LỰA CHỌN NGHIỆP VỤ -->
            <div class="grid grid-cols-2 gap-3">
                <a id="modalContinueBtn" href="${pageContext.request.contextPath}/customer/search-rooms"
                    class="btn btn-outline text-center text-xs py-2 font-bold">
                    Quay Lại Đặt Tiếp
                </a>

                <a id="modalCheckoutBtn" href="${pageContext.request.contextPath}/customer/booking"
                    class="btn btn-primary text-center text-xs py-2 font-bold">
                    Xác Nhận Đặt Booking
                </a>
            </div>

        </div>

    </div>
</div>

<fmt:formatNumber var="rawBasePrice" value="${not empty currentRoom ? currentRoom.tongTienDuKien : 0}"
    groupingUsed="false" maxFractionDigits="0" />
<!-- JAVASCRIPT TÍNH TOÁN DỊCH VỤ & XỬ LÝ POPUP MODAL -->
<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
    window.BASE_ROOM_PRICE = parseFloat('${not empty rawBasePrice ? rawBasePrice : 0}') || 0;
</script>
<script src="${pageContext.request.contextPath}/assets/js/booking/booking_form.js"></script>

<jsp:include page="/views/common/footer.jsp" />