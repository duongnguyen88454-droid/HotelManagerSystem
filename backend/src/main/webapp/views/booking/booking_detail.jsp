<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Chi Tiết Đơn Đặt Phòng - ${bookingDetail.maBooking}" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking/booking_detail.css">

<div class="container my-6">
    <div class="no-print flex justify-between items-center mb-4 flex-wrap gap-3">
        <!-- Breadcrumb -->
        <nav class="breadcrumb-nav mb-0" aria-label="Breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/home">Trang Chủ</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/history">Lịch Sử Đặt Phòng</a></li>
                <li class="breadcrumb-item active" aria-current="page">Đơn Đặt ${bookingDetail.maBooking}</li>
            </ol>
        </nav>
        <div class="flex gap-2">
            <button onclick="window.print()" class="btn btn-secondary btn-sm">
                In Phiếu Đặt Phòng
            </button>
            <a href="${pageContext.request.contextPath}/customer/history" class="btn btn-secondary btn-sm">
                Về Lịch Sử Đặt Phòng
            </a>
        </div>
    </div>

    <!-- Thông báo kết quả -->
    <c:if test="${param.depositSuccess == 'true'}">
        <div class="no-print alert alert-success mb-4 font-semibold">
            Xác nhận nộp cọc thành công! Khách sạn đã ghi nhận tiền đặt cọc và kích hoạt bảo đảm giữ chỗ cho đơn đặt ${bookingDetail.maBooking}.
        </div>
    </c:if>

    <c:if test="${param.bookingSuccess == 'true'}">
        <div class="no-print alert alert-success mb-4">
            <strong>Đặt phòng thành công!</strong> Đơn đặt của bạn đã được ghi nhận vào hệ thống. Mã đơn:
            <strong>${bookingDetail.maBooking}</strong>. Quý khách có thể bổ sung thêm dịch vụ tiện ích bên dưới bất kỳ lúc nào trước khi trả phòng.
        </div>
    </c:if>

    <c:if test="${param.msg == 'service_added'}">
        <div class="no-print alert alert-success mb-4">
            <strong>Thành công:</strong> Dịch vụ mới đã được thêm vào phòng và tự động cập nhật vào chi phí đơn đặt phòng.
        </div>
    </c:if>

    <c:if test="${param.msg == 'service_removed'}">
        <div class="no-print alert alert-success mb-4">
            <strong>Thành công:</strong> Đã hủy dịch vụ khỏi phòng và giảm trừ chi phí tương ứng trên hóa đơn.
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="no-print alert alert-danger mb-4">
            <strong>Thông báo lỗi:</strong> ${param.error}
        </div>
    </c:if>

    <!-- THẺ TIÊU ĐỀ ĐƠN ĐẶT PHÒNG & THÔNG TIN CHUNG -->
    <div class="card p-0 mb-5 shadow-sm overflow-hidden">
        <div class="bg-primary text-white p-5 flex justify-between items-center flex-wrap gap-4">
            <div>
                <div class="text-xs uppercase tracking-wide opacity-80 font-bold">
                    Chi Tiết Đơn Đặt Phòng Trực Tuyến
                </div>
                <h1 class="page-title text-2xl font-bold text-white mt-1 mb-1">
                    Mã Đơn: <code>${bookingDetail.maBooking}</code>
                </h1>
                <div class="text-xs opacity-90">
                    Thời gian tạo: <fmt:formatDate value="${bookingDetail.ngayDat}" pattern="dd/MM/yyyy HH:mm:ss" />
                </div>
            </div>

            <div class="text-right flex flex-col items-end gap-2">
                <c:choose>
                    <c:when test="${bookingDetail.trangThaiBooking == 'Confirmed'}">
                        <span class="badge badge-primary px-3 py-1 font-bold">
                            Đã Xác Nhận
                        </span>
                    </c:when>
                    <c:when test="${bookingDetail.trangThaiBooking == 'CheckedIn'}">
                        <span class="badge badge-success px-3 py-1 font-bold">
                            Đang Lưu Trú (Check-in)
                        </span>
                    </c:when>
                    <c:when test="${bookingDetail.trangThaiBooking == 'CheckedOut'}">
                        <span class="badge badge-secondary px-3 py-1 font-bold">
                            Đã Trả Phòng (Check-out)
                        </span>
                    </c:when>
                    <c:when test="${bookingDetail.trangThaiBooking == 'Cancelled'}">
                        <span class="badge badge-danger px-3 py-1 font-bold">
                            Đã Hủy
                        </span>
                    </c:when>
                </c:choose>

                <div class="text-xs opacity-90">
                    Hóa đơn: <strong>${bookingDetail.maHoaDon}</strong>
                    <c:choose>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'Paid'}">
                            <span class="badge badge-success ml-1">Đã Quyết Toán Đủ</span>
                        </c:when>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'PartiallyPaid'}">
                            <span class="badge badge-primary ml-1">Đã Nộp Cọc (Giữ Chỗ)</span>
                        </c:when>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'Unpaid'}">
                            <span class="badge badge-warning ml-1">Chưa Nộp Cọc / Chưa Thanh Toán</span>
                        </c:when>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'Cancelled'}">
                            <span class="badge badge-danger ml-1">Hóa Đơn Hủy</span>
                        </c:when>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Thông tin liên hệ khách hàng & Ghi chú -->
        <div class="p-5">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 text-xs">
                <div>
                    <span class="text-muted block mb-1">Họ tên khách hàng:</span>
                    <strong class="text-secondary text-sm font-bold">${bookingDetail.hoTenKhachHang}</strong>
                </div>
                <div>
                    <span class="text-muted block mb-1">Số điện thoại:</span>
                    <strong class="text-secondary text-sm font-bold">${bookingDetail.soDT}</strong>
                </div>
                <div>
                    <span class="text-muted block mb-1">Email:</span>
                    <strong class="text-secondary text-sm font-bold">${bookingDetail.email}</strong>
                </div>
                <div>
                    <span class="text-muted block mb-1">Số CCCD lưu trú:</span>
                    <strong class="text-secondary text-sm font-bold">
                        ${not empty bookingDetail.cccd ? bookingDetail.cccd : 'Chưa cập nhật'}
                    </strong>
                </div>
                <div>
                    <span class="text-muted block mb-1">Mã định danh (MaKH):</span>
                    <code class="text-sm font-mono">${bookingDetail.maKH}</code>
                </div>
            </div>

            <c:if test="${not empty bookingDetail.ghiChu}">
                <div class="alert alert-secondary mt-4 p-3 text-xs mb-0">
                    <strong>Ghi chú đơn đặt:</strong> ${bookingDetail.ghiChu}
                </div>
            </c:if>
        </div>
    </div>

    <!-- DANH SÁCH CÁC PHÒNG TRONG ĐƠN ĐẶT KÈM DỊCH VỤ GẮN THEO PHÒNG -->
    <h3 class="card-title text-lg font-bold text-primary mb-3">
        Danh Sách Phòng &amp; Dịch Vụ Tiện Ích Đã Đăng Ký
    </h3>

    <div class="flex flex-col gap-5 mb-5">
        <c:forEach var="room" items="${bookingDetail.danhSachPhong}">
            <div class="card p-0 shadow-sm overflow-hidden">

                <!-- Room Card Header -->
                <div class="bg-light border-b p-4 flex justify-between items-center flex-wrap gap-3">
                    <div>
                        <span class="badge badge-primary uppercase mb-1">
                            ${room.tenLoaiPhong}
                        </span>
                        <h4 class="text-base font-bold text-primary m-0">
                            ${room.soPhong}
                        </h4>
                    </div>

                    <div class="flex gap-4 items-center text-xs text-secondary">
                        <div>
                            Thời gian: <strong><fmt:formatDate value="${room.ngayNhanDuKien}" pattern="dd/MM/yyyy" /></strong>
                            đến <strong><fmt:formatDate value="${room.ngayTraDuKien}" pattern="dd/MM/yyyy" /></strong>
                            <span class="text-muted">(${room.soDem} đêm)</span>
                        </div>
                        <div class="text-right">
                            <span class="text-muted block text-xs">Tiền phòng:</span>
                            <strong class="text-primary text-sm font-bold">
                                <fmt:formatNumber value="${room.tienPhong}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                            </strong>
                            <c:if test="${room.tienCoc > 0}">
                                <span class="text-primary block text-xs mt-1">
                                    Tiền cọc: <fmt:formatNumber value="${room.tienCoc}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                                </span>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Bảng Dịch Vụ Của Riêng Phòng Này -->
                <div class="p-4">
                    <div class="flex justify-between items-center mb-3">
                        <h5 class="text-sm font-bold text-secondary m-0">
                            Dịch Vụ Đi Kèm Của ${room.soPhong}
                        </h5>

                        <c:if test="${bookingDetail.coTheThemDichVu}">
                            <button type="button" class="no-print btn btn-primary btn-sm"
                                onclick="openAddServiceModal('${room.maPhong}', '${room.soPhong}')">
                                Thêm Dịch Vụ Cho Phòng Này
                            </button>
                        </c:if>
                    </div>

                    <c:choose>
                        <c:when test="${not empty room.danhSachDichVu}">
                            <div class="table-responsive">
                                <table class="table table-hover text-xs mb-0">
                                    <thead>
                                        <tr>
                                            <th>Tên Dịch Vụ</th>
                                            <th class="text-right">Đơn Giá</th>
                                            <th class="text-center">Số Lượng</th>
                                            <th class="text-right">Thành Tiền</th>
                                            <th>Thời Điểm Gọi</th>
                                            <th class="text-center">Người Thêm</th>
                                            <c:if test="${bookingDetail.coTheThemDichVu}">
                                                <th class="text-center no-print">Thao Tác</th>
                                            </c:if>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="dv" items="${room.danhSachDichVu}">
                                            <tr>
                                                <td class="font-semibold text-secondary">
                                                    ${dv.tenDichVu}
                                                    <span class="text-muted block text-xs">Mã: <code>${dv.maDichVu}</code></span>
                                                </td>
                                                <td class="text-right text-muted">
                                                    <fmt:formatNumber value="${dv.donGia}" type="number" groupingUsed="true" /> đ
                                                </td>
                                                <td class="text-center font-bold text-primary">
                                                    ${dv.soLuong}
                                                </td>
                                                <td class="text-right font-bold text-primary">
                                                    <fmt:formatNumber value="${dv.thanhTien}" type="number" groupingUsed="true" /> đ
                                                </td>
                                                <td class="text-muted text-xs">
                                                    <fmt:formatDate value="${dv.thoiDiemThem}" pattern="dd/MM/yyyy HH:mm" />
                                                </td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${dv.nguoiThem == 'KhachHang'}">
                                                            <span class="badge badge-primary text-xs">Khách Đặt</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-secondary text-xs">Lễ Tân Thêm</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <c:if test="${bookingDetail.coTheThemDichVu}">
                                                    <td class="text-center no-print">
                                                        <form action="${pageContext.request.contextPath}/customer/booking-detail/add-service"
                                                            method="POST"
                                                            onsubmit="return confirm('Bạn có chắc muốn hủy dịch vụ [${dv.tenDichVu}] khỏi ${room.soPhong}?');"
                                                            class="m-0">
                                                            <input type="hidden" name="action" value="remove">
                                                            <input type="hidden" name="bookingId" value="${bookingDetail.maBooking}">
                                                            <input type="hidden" name="serviceBookingId" value="${dv.maBookingDichVu}">
                                                            <button type="submit" class="btn btn-outline btn-danger btn-sm py-1 px-2 text-xs">
                                                                Hủy DV
                                                            </button>
                                                        </form>
                                                    </td>
                                                </c:if>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="card p-4 text-center text-muted text-xs border bg-light">
                                <c:choose>
                                    <c:when test="${bookingDetail.coTheThemDichVu}">
                                        Phòng này chưa đăng ký dịch vụ bổ sung nào. Quý khách có thể bấm <strong>"Thêm Dịch Vụ Cho Phòng Này"</strong> để gọi dịch vụ.
                                    </c:when>
                                    <c:otherwise>
                                        Phòng này không đăng ký dịch vụ bổ sung trước. Đơn đặt phòng đã được xác nhận và đặt cọc, quý khách có nhu cầu sử dụng thêm dịch vụ vui lòng liên hệ quầy lễ tân khi làm thủ tục nhận phòng.
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${room.tongTienDichVuPhong > 0}">
                        <div class="text-right mt-3 text-xs text-secondary">
                            Tổng tiền dịch vụ ${room.soPhong}:
                            <strong class="text-primary text-sm font-bold">
                                <fmt:formatNumber value="${room.tongTienDichVuPhong}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                            </strong>
                        </div>
                    </c:if>
                </div>

            </div>
        </c:forEach>
    </div>

    <!-- TỔNG KẾT TÀI CHÍNH TOÀN BỘ ĐƠN ĐẶT -->
    <div class="card p-5 mb-5 shadow-sm">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 items-center">
            <div class="lg:col-span-2">
                <h4 class="card-title text-base font-bold text-primary mb-2">
                    Tình Trạng Thanh Toán &amp; Hóa Đơn
                </h4>
                <p class="text-muted text-xs mb-3 leading-relaxed">
                    Tổng chi phí sẽ được tự động cập nhật nếu phát sinh thêm dịch vụ trong thời gian lưu trú. Thanh toán được hoàn tất khi quý khách làm thủ tục Check-out tại quầy lễ tân.
                </p>
                <div class="text-xs text-secondary">
                    Mã số hóa đơn: <strong>${bookingDetail.maHoaDon}</strong> &nbsp;|&nbsp;
                    Trạng thái:
                    <c:choose>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'Paid'}">
                            <span class="text-success font-bold">Đã Thanh Toán Toàn Bộ</span>
                        </c:when>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'PartiallyPaid' || bookingDetail.trangThaiHoaDon == 'Partial'}">
                            <span class="text-primary font-bold">Đã Nộp Tiền Cọc (Số còn lại quyết toán tại quầy)</span>
                        </c:when>
                        <c:otherwise>
                            <span class="text-warning font-bold">Chưa Quyết Toán (Thanh toán tại quầy lễ tân)</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Bảng cộng dồn -->
            <div class="card p-4 border bg-light">
                <div class="flex justify-between text-xs mb-2 text-secondary">
                    <span class="text-muted">Tổng tiền phòng:</span>
                    <strong class="font-bold">
                        <fmt:formatNumber value="${bookingDetail.tongTienPhong}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                    </strong>
                </div>

                <div class="flex justify-between text-xs mb-2 text-secondary">
                    <span class="text-muted">Tổng tiền dịch vụ:</span>
                    <strong class="font-bold">
                        <fmt:formatNumber value="${bookingDetail.tongTienDichVu}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                    </strong>
                </div>

                <c:if test="${bookingDetail.tongTienCoc > 0}">
                    <div class="flex justify-between text-xs mb-2 text-primary">
                        <span>Tiền cọc cần thanh toán:</span>
                        <strong class="font-bold">
                            <fmt:formatNumber value="${bookingDetail.tongTienCoc}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                        </strong>
                    </div>
                </c:if>

                <div class="border-t pt-2 mt-2 flex justify-between items-baseline">
                    <span class="text-sm font-bold text-primary">Tổng Chi Phí:</span>
                    <div class="text-xl font-bold text-danger">
                        <fmt:formatNumber value="${bookingDetail.tongChiPhiDuKien}" type="number" groupingUsed="true" maxFractionDigits="0" /> đ
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- HÀNG NÚT THAO TÁC CUỐI TRANG -->
    <div class="no-print flex justify-between items-center flex-wrap gap-4">
        <a href="${pageContext.request.contextPath}/customer/history" class="btn btn-secondary">
            Quay Lại Lịch Sử Đặt Phòng
        </a>

        <div class="flex gap-3 items-center flex-wrap">
            <!-- Nút Nộp Cọc nếu đơn chưa nộp cọc -->
            <c:if test="${bookingDetail.trangThaiHoaDon == 'Unpaid' && bookingDetail.trangThaiBooking != 'Cancelled'}">
                <a href="${pageContext.request.contextPath}/customer/deposit?bookingId=${bookingDetail.maBooking}" class="btn btn-primary">
                    Thanh Toán Tiền Cọc Ngay
                </a>
            </c:if>

            <!-- Nút hủy đơn nếu đủ điều kiện -->
            <c:if test="${bookingDetail.coTheHuy}">
                <button type="button" class="btn btn-outline btn-danger" onclick="openCancelModal('${bookingDetail.maBooking}')">
                    Hủy Toàn Bộ Đơn Đặt Phòng Này
                </button>
            </c:if>
        </div>
    </div>

    <!-- Banner chính sách hủy đơn trực tuyến -->
    <c:if test="${bookingDetail.coTheHuy}">
        <div class="no-print alert alert-warning mt-4 text-xs leading-relaxed">
            <strong>Lưu ý về chính sách hủy đơn:</strong> Thao tác hủy trực tuyến trên website sẽ tiến hành
            <strong>hủy toàn bộ</strong> đơn đặt phòng này. Nếu quý khách chỉ có nhu cầu <strong>hủy một phần</strong> (hủy riêng từng phòng) hoặc bảo lưu tiền cọc, vui lòng liên hệ trực tiếp hotline khách sạn <strong>1900 6868</strong> để được nhân viên lễ tân hỗ trợ xử lý linh hoạt.
        </div>
    </c:if>

</div>

<!-- MODAL THÊM DỊCH VỤ CHO PHÒNG CỤ THỂ -->
<div id="addServiceModal" class="modal-backdrop">
    <div class="modal-content">
        <div class="flex justify-between items-center mb-4 pb-2 border-b">
            <h4 id="modalTitle" class="modal-title text-base font-bold text-primary m-0">
                Thêm Dịch Vụ Cho Phòng
            </h4>
            <button type="button" onclick="closeAddServiceModal()" class="text-muted hover:text-dark bg-transparent border-0 text-2xl cursor-pointer p-0 leading-none">
                &times;
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/customer/booking-detail/add-service" method="POST">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="bookingId" value="${bookingDetail.maBooking}">
            <input type="hidden" id="modalRoomId" name="roomId" value="">

            <div class="form-group mb-3">
                <label class="form-label font-semibold text-secondary text-xs">
                    Chọn Dịch Vụ:
                </label>
                <select id="modalServiceSelect" name="serviceId" required onchange="updateModalPricePreview()" class="form-control">
                    <option value="" data-price="0">-- Vui lòng chọn dịch vụ --</option>
                    <c:forEach var="svc" items="${activeServices}">
                        <option value="${svc.maDichVu}" data-price="${svc.donGia}">
                            ${svc.tenDichVu} (<fmt:formatNumber value="${svc.donGia}" type="number" groupingUsed="true" /> đ)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group mb-3">
                <label class="form-label font-semibold text-secondary text-xs">
                    Số Lượng:
                </label>
                <input type="number" id="modalQuantity" name="quantity" min="1" max="50" value="1" required
                    oninput="updateModalPricePreview()" class="form-control">
            </div>

            <div class="card p-3 mb-4 border bg-light flex justify-between items-center">
                <span class="text-xs text-muted">Thành tiền dự kiến:</span>
                <strong id="modalPricePreview" class="text-base text-primary font-bold">0 đ</strong>
            </div>

            <div class="flex gap-2 justify-end">
                <button type="button" onclick="closeAddServiceModal()" class="btn btn-secondary btn-sm">
                    Hủy Bỏ
                </button>
                <button type="submit" class="btn btn-primary btn-sm font-bold">
                    Xác Nhận Thêm Dịch Vụ
                </button>
            </div>
        </form>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/booking/booking_detail.js"></script>

<!-- Modal Xác Nhận Hủy Đơn Đặt Phòng Chuẩn UI/UX -->
<div id="cancelModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 1050; align-items: center; justify-content: center;">
    <div class="card p-6 shadow-lg animate-in" style="max-width: 460px; width: 90%; background: #ffffff; border-radius: var(--radius-lg, 12px); border: 1px solid var(--color-border, #e2e8f0);">
        <div class="flex items-center gap-3 mb-4 text-danger">
            <div style="width: 40px; height: 40px; border-radius: 50%; background: #fee2e2; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="8" x2="12" y2="12"></line>
                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
            </div>
            <div>
                <h3 class="m-0 text-lg font-bold text-gray-900">Xác Nhận Hủy Đơn</h3>
                <p class="text-xs text-muted m-0">Thao tác không thể hoàn tác sau khi thực hiện</p>
            </div>
        </div>
        <p class="text-secondary text-sm mb-3">
            Bạn có chắc chắn muốn hủy toàn bộ phòng trong đơn đặt <strong id="modalBookingIdText" class="text-primary font-mono font-bold"></strong> không?
        </p>
        <div class="alert alert-warning text-xs p-3 mb-4" style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 6px; color: #92400e;">
            <strong>Lưu ý:</strong> Toàn bộ phòng trong đơn sẽ được hoàn trả về danh sách khả dụng. Nếu quý khách chỉ muốn hủy riêng từng phòng, vui lòng liên hệ hotline <strong>1900 6868</strong> để được hỗ trợ.
        </div>
        <div class="flex justify-end gap-3">
            <button type="button" class="btn btn-secondary btn-sm" onclick="closeCancelModal()">
                Quay Lại
            </button>
            <button type="button" class="btn btn-danger btn-sm font-semibold" onclick="submitCancelBooking()">
                Xác Nhận Hủy Đơn
            </button>
        </div>
    </div>
</div>

<!-- Form Submit Hủy Đơn (Ẩn) -->
<form id="cancelBookingForm" action="${pageContext.request.contextPath}/customer/history" method="POST" style="display: none;">
    <input type="hidden" name="action" value="cancel">
    <input type="hidden" name="bookingId" id="cancelBookingIdInput" value="">
</form>

<script>
function openCancelModal(bookingId) {
    var input = document.getElementById('cancelBookingIdInput');
    var text = document.getElementById('modalBookingIdText');
    var modal = document.getElementById('cancelModal');
    if (input) input.value = bookingId;
    if (text) text.textContent = '[' + bookingId + ']';
    if (modal) modal.style.display = 'flex';
}

function closeCancelModal() {
    var modal = document.getElementById('cancelModal');
    if (modal) modal.style.display = 'none';
}

function submitCancelBooking() {
    var form = document.getElementById('cancelBookingForm');
    if (form) form.submit();
}

// Đóng modal khi bấm ra ngoài phần backdrop
window.addEventListener('click', function(event) {
    var modal = document.getElementById('cancelModal');
    if (event.target === modal) {
        closeCancelModal();
    }
});
</script>

<jsp:include page="/views/common/footer.jsp" />