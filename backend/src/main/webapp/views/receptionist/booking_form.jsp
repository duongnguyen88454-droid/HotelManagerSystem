<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="pageTitle" value="Tiếp Nhận Đặt Phòng Tại Quầy - Bàn Làm Việc Lễ Tân" />
    <jsp:param name="zone" value="portal" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist/booking_form.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="booking" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <div class="portal-card p-5">

        <!-- STEPPER NAV -->
        <div class="stepper-nav">
            <div id="stepNav1" class="step-item active">
                <span class="step-badge">1</span>
                <span>1. CHỌN THỜI GIAN &amp; PHÒNG KHẢ DỤNG</span>
            </div>
            <div class="step-divider"></div>
            <div id="stepNav2" class="step-item">
                <span class="step-badge">2</span>
                <span>2. HỒ SƠ KHÁCH &amp; DỊCH VỤ PHÒNG</span>
            </div>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger mb-4 font-bold text-xs">
                [Lỗi] ${errorMessage}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/receptionist/booking" method="POST" id="receptionistBookingForm">

            <!-- ========================================================================= -->
            <!-- BƯỚC 1: CHỌN NGÀY & PHÒNG KHẢ DỤNG                                        -->
            <!-- ========================================================================= -->
            <div id="step1Container">
                
                <!-- KHUNG CHỌN TIÊU CHÍ LỌC PHÒNG KHẢ DỤNG (NỔI BẬT TƯƠNG PHẢN VỚI BACKGROUND) -->
                <div class="card p-4 mb-4" style="background-color: #f8fafc; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border-radius: 10px;">
                    <div class="flex items-center gap-4 flex-wrap">
                        <div class="flex items-center gap-2">
                            <label class="form-label font-bold text-secondary text-xs mb-0 nowrap">Ngày nhận:</label>
                            <input type="date" id="dateCheckIn" name="checkIn" value="${checkIn}" 
                                class="form-control" style="background-color: #ffffff; border: 1px solid #cbd5e1; box-shadow: 0 1px 2px rgba(0,0,0,0.05); width: 145px; height: 38px; border-radius: 6px;" onchange="onDateFilterChange()">
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label font-bold text-secondary text-xs mb-0 nowrap">Ngày trả:</label>
                            <input type="date" id="dateCheckOut" name="checkOut" value="${checkOut}" 
                                class="form-control" style="background-color: #ffffff; border: 1px solid #cbd5e1; box-shadow: 0 1px 2px rgba(0,0,0,0.05); width: 145px; height: 38px; border-radius: 6px;" onchange="onDateFilterChange()">
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label font-bold text-secondary text-xs mb-0 nowrap">Số khách:</label>
                            <select id="filterGuests" class="form-control" style="background-color: #ffffff; border: 1px solid #cbd5e1; box-shadow: 0 1px 2px rgba(0,0,0,0.05); width: 120px; height: 38px; border-radius: 6px;" onchange="onDateFilterChange()">
                                <option value="">Tất cả</option>
                                <option value="1" ${paramGuests=='1' ? 'selected' : ''}>1 người</option>
                                <option value="2" ${paramGuests=='2' ? 'selected' : ''}>2 người</option>
                                <option value="3" ${paramGuests=='3' ? 'selected' : ''}>3 người</option>
                                <option value="4" ${paramGuests=='4' ? 'selected' : ''}>4+ người</option>
                            </select>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label font-bold text-secondary text-xs mb-0 nowrap">Hạng phòng:</label>
                            <select id="filterRoomType" class="form-control" style="background-color: #ffffff; border: 1px solid #cbd5e1; box-shadow: 0 1px 2px rgba(0,0,0,0.05); min-width: 160px; height: 38px; border-radius: 6px;" onchange="onDateFilterChange()">
                                <option value="ALL">Tất cả</option>
                                <c:forEach var="rt" items="${roomTypes}">
                                    <option value="${rt.maLoaiPhong}" ${paramRoomType==rt.maLoaiPhong ? 'selected' : ''}>
                                        ${rt.tenLoaiPhong}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <span id="nightsCounter" class="pill pill-primary font-bold" style="height: 38px; display: inline-flex; align-items: center; padding: 0 14px;">1 đêm</span>
                    </div>
                </div>

                <!-- BẢNG PHÒNG TRỐNG (THOÁNG ĐÃNG, KHÔNG CÓ CỘT DỊCH VỤ) -->
                <div class="pms-card p-0 overflow-hidden">
                    <div class="p-4 bg-white border-b flex justify-between items-center">
                        <span class="text-sm font-extrabold text-primary uppercase">
                            Danh Sách Phòng Khả Dụng
                        </span>
                        <span class="text-xs text-muted">
                            Tìm thấy: <strong class="text-primary text-sm">${fn:length(availableRooms)}</strong> phòng trống
                        </span>
                    </div>

                    <c:choose>
                        <c:when test="${empty availableRooms}">
                            <div class="p-6 text-center text-muted text-sm">
                                [Thông báo] Không có phòng nào khả dụng trong khoảng thời gian này. Vui lòng chọn khoảng ngày khác.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="pms-table">
                                    <thead>
                                        <tr>
                                            <th class="w-12 text-center">Chọn</th>
                                            <th class="w-28">Số Phòng</th>
                                            <th>Hạng Phòng</th>
                                            <th class="w-56">Sức Chứa &amp; Loại Giường</th>
                                            <th class="w-40 text-right">Đơn Giá / Đêm</th>
                                            <th class="w-44 text-right">Tạm Tính Tiền Phòng</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="rm" items="${availableRooms}">
                                            <tr>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${rm.maPhong eq preselectedRoomId}">
                                                            <input type="checkbox" name="selectedRooms" value="${rm.maPhong}" id="chk_${rm.maPhong}" checked data-price="${rm.giaPhong}" data-depositpercent="${rm.depositPercent}" data-roomno="${rm.soPhong}" data-typename="${rm.tenLoaiPhong}" onchange="onRoomCheckboxChange()" class="cursor-pointer">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <input type="checkbox" name="selectedRooms" value="${rm.maPhong}" id="chk_${rm.maPhong}" data-price="${rm.giaPhong}" data-depositpercent="${rm.depositPercent}" data-roomno="${rm.soPhong}" data-typename="${rm.tenLoaiPhong}" onchange="onRoomCheckboxChange()" class="cursor-pointer">
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <input type="hidden" name="soPhong_${rm.maPhong}" value="${rm.soPhong}">
                                                    <input type="hidden" name="tenLoaiPhong_${rm.maPhong}" value="${rm.tenLoaiPhong}">
                                                    <input type="hidden" name="maLoaiPhong_${rm.maPhong}" value="${rm.maLoaiPhong}">
                                                    <input type="hidden" name="donGia_${rm.maPhong}" value="${rm.giaPhong}">
                                                </td>
                                                <td>
                                                    <strong class="text-primary text-base font-bold">${rm.soPhong}</strong>
                                                </td>
                                                <td>
                                                    <strong class="text-secondary font-bold">${rm.tenLoaiPhong}</strong>
                                                    <span class="block text-xs text-muted">Mã: ${rm.maLoaiPhong}</span>
                                                </td>
                                                <td>
                                                    <span class="text-secondary font-semibold">${rm.soNguoiToiDa} khách (${rm.loaiGiuong})</span>
                                                </td>
                                                <td class="text-right">
                                                    <strong class="text-secondary text-sm font-bold">
                                                        <fmt:formatNumber value="${rm.giaPhong}" pattern="#,###"/>
                                                    </strong>
                                                    <span class="block text-xs text-muted">VNĐ / đêm</span>
                                                </td>
                                                <td class="text-right">
                                                    <strong id="roomSubtotal_${rm.maPhong}" class="text-primary text-sm font-bold">0 VNĐ</strong>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- THANH TỔNG KẾT & TIẾP TỤC DƯỚI CHÂN BƯỚC 1 -->
                <div class="step-footer-bar">
                    <div>
                        <span class="text-sm text-secondary">Đã chọn: <strong id="step1SelectedCount" class="text-primary text-base">0</strong> phòng</span>
                        <span class="mx-3 text-muted">|</span>
                        <span class="text-sm text-secondary">Tổng tiền phòng tạm tính: <strong id="step1TotalRoomCost" class="text-danger text-base">0 VNĐ</strong></span>
                    </div>
                    <button type="button" id="btnNextToStep2" class="pms-btn pms-btn-primary" onclick="goToStep(2)">
                        Tiếp Tục: Hồ Sơ Khách &amp; Dịch Vụ
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
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div class="form-group mb-0">
                            <label class="pms-label">Họ và Tên khách đại diện <span class="text-danger">*</span></label>
                            <input type="text" id="guestName" name="hoTen" class="pms-input font-semibold" placeholder="Ví dụ: Nguyễn Văn An" required>
                        </div>
                        <div class="form-group mb-0">
                            <label class="pms-label">Địa chỉ Email liên hệ <span class="text-danger">*</span></label>
                            <input type="email" id="guestEmail" name="email" class="pms-input" placeholder="guest@example.com" required>
                        </div>
                    </div>

                    <!-- HÀNG 2: SỐ CCCD & SỐ ĐIỆN THOẠI (BẮT BUỘC) -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div class="form-group mb-0">
                            <label class="pms-label">Số CCCD / Hộ chiếu (12 số) <span class="text-danger">*</span></label>
                            <input type="text" id="guestCccd" name="cccd" class="pms-input font-bold" placeholder="Nhập đủ 12 chữ số..." required maxlength="12" pattern="[0-9]{12}">
                        </div>
                        <div class="form-group mb-0">
                            <label class="pms-label">Số điện thoại liên lạc <span class="text-danger">*</span></label>
                            <input type="text" id="guestPhone" name="soDT" class="pms-input" placeholder="Ví dụ: 0901234567" required>
                        </div>
                    </div>

                    <!-- HÀNG 3: GHI CHÚ -->
                    <div class="form-group mb-0">
                        <label class="pms-label">Ghi chú đơn đặt phòng</label>
                        <textarea name="note" class="pms-input" rows="2" placeholder="Yêu cầu đặc biệt của khách hàng..."></textarea>
                    </div>
                </div>

                <!-- 2. DỊCH VỤ GẮN THEO TỪNG PHÒNG ĐÃ CHỌN -->
                <div class="pms-card">
                    <div class="pms-card-header">
                        <span>2. Dịch Vụ Đi Kèm Cho Từng Phòng Đã Chọn</span>
                        <span class="text-xs text-muted font-normal lowercase">Điều chỉnh số lượng dịch vụ theo nhu cầu thực tế</span>
                    </div>

                    <div id="selectedRoomsSvcContainer">
                        <c:forEach var="rm" items="${availableRooms}">
                            <div id="roomSvcCard_${rm.maPhong}" class="room-svc-card" style="display: none;">
                                <div class="room-svc-header">
                                    <strong class="text-primary text-sm font-bold">${rm.soPhong} - ${rm.tenLoaiPhong}</strong>
                                    <span class="text-primary font-bold text-xs"><fmt:formatNumber value="${rm.giaPhong}" pattern="#,###"/> VNĐ / đêm</span>
                                </div>
                                <div class="p-3">
                                    <div class="table-responsive">
                                        <table class="table table-hover text-xs mb-0">
                                            <thead>
                                                <tr>
                                                    <th>Tên Dịch Vụ</th>
                                                    <th class="w-36 text-right">Đơn Giá</th>
                                                    <th class="w-36 text-center">Số Lượng</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="s" items="${services}">
                                                    <tr>
                                                        <td class="font-semibold text-secondary">${s.tenDichVu}</td>
                                                        <td class="text-right text-muted">
                                                            <fmt:formatNumber value="${s.donGia}" pattern="#,###"/> VNĐ
                                                        </td>
                                                        <td class="text-center">
                                                            <div class="qty-control-box">
                                                                <button type="button" class="pms-btn pms-btn-secondary qty-btn" onclick="changeQty('${rm.maPhong}', '${s.maDichVu}', -1)">-</button>
                                                                <input type="number" id="qty_${rm.maPhong}_${s.maDichVu}" name="svc_${rm.maPhong}_${s.maDichVu}" min="0" max="20" value="0" data-price="${s.donGia}" class="pms-input qty-input" onchange="recalculateStep2Bill()">
                                                                <button type="button" class="pms-btn pms-btn-secondary qty-btn" onclick="changeQty('${rm.maPhong}', '${s.maDichVu}', 1)">+</button>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <!-- 3. TỔNG HỢP CHI PHÍ & XÁC NHẬN ĐƠN (BILLING SUMMARY) -->
                <div class="pms-card bg-light border-2">
                    <div class="pms-card-header border-b-2">
                        <span>3. Tổng Hợp Chi Phí Đặt Phòng</span>
                        <span id="step2SummaryRoomCount" class="text-xs text-muted font-normal">0 phòng</span>
                    </div>

                    <div class="flex justify-between text-sm mb-2 text-secondary">
                        <span>Tiền phòng:</span>
                        <strong id="step2SumRoomCost" class="text-secondary text-base">0 VNĐ</strong>
                    </div>
                    <div class="flex justify-between text-sm mb-3 text-secondary">
                        <span>Tiền dịch vụ đặt trước:</span>
                        <strong id="step2SumServiceCost" class="text-secondary text-base">0 VNĐ</strong>
                    </div>
                    <div class="flex justify-between text-base pt-3 border-t text-primary">
                        <span class="font-extrabold">TỔNG CỘNG THANH TOÁN:</span>
                        <strong id="step2SumTotalCost" class="text-danger text-lg font-bold">0 VNĐ</strong>
                    </div>

                    <!-- KHUNG THU TIỀN CỌC KHI ĐẶT PHÒNG GIỮ CHỖ -->
                    <div class="deposit-box">
                        <div class="flex justify-between items-center mb-2">
                            <span class="font-bold text-primary text-sm">Tiền cọc cần thu để giữ chỗ:</span>
                            <strong id="step2SumDepositCost" class="text-primary text-base font-bold">0 VNĐ</strong>
                        </div>
                        <div class="text-xs text-muted mb-2 font-semibold">Hình thức khách nộp cọc tại quầy:</div>
                        <div class="flex gap-4 items-center flex-wrap">
                            <label class="flex items-center gap-1 text-xs cursor-pointer text-secondary font-semibold">
                                <input type="radio" name="depositPaymentMethod" value="Cash" checked>
                                Tiền mặt (Cash)
                            </label>
                            <label class="flex items-center gap-1 text-xs cursor-pointer text-secondary font-semibold">
                                <input type="radio" name="depositPaymentMethod" value="CreditCard">
                                Quẹt thẻ (POS)
                            </label>
                            <label class="flex items-center gap-1 text-xs cursor-pointer text-secondary font-semibold">
                                <input type="radio" name="depositPaymentMethod" value="BankTransfer">
                                Chuyển khoản (BankTransfer)
                            </label>
                        </div>
                    </div>

                    <!-- HÀNG NÚT ĐIỀU HƯỚNG VÀ XÁC NHẬN -->
                    <div class="flex justify-between items-center mt-5 gap-3 flex-wrap">
                        <button type="button" class="pms-btn pms-btn-secondary" onclick="goToStep(1)">
                            Quay Lại Chọn Phòng
                        </button>
                        <div class="flex gap-2">
                            <button type="submit" name="actionType" value="reserve" class="pms-btn pms-btn-primary py-3 px-4 text-sm font-bold">
                                Xác Nhận Thu Cọc &amp; Giữ Chỗ
                            </button>
                            <button type="submit" name="actionType" value="checkin_now" class="pms-btn pms-btn-success py-3 px-4 text-sm font-bold">
                                Đặt &amp; Nhận Phòng Ngay
                            </button>
                        </div>
                    </div>
                </div>

            </div>

        </form>

        </div>
    </main>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/receptionist/booking_form.js"></script>

<jsp:include page="/views/common/footer.jsp" />
