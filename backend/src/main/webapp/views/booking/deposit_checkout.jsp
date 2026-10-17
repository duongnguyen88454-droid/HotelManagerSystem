<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thanh Toán Đặt Cọc - ${bookingDetail.maBooking}" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="container my-6">

    <!-- Breadcrumb -->
    <nav class="breadcrumb-nav mb-4" aria-label="Breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/home">Trang Chủ</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/history">Lịch Sử Đặt Phòng</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${bookingDetail.maBooking}">Đơn Đặt ${bookingDetail.maBooking}</a></li>
            <li class="breadcrumb-item active" aria-current="page">Thanh Toán Tiền Cọc</li>
        </ol>
    </nav>

    <!-- Thông báo lỗi (nếu có) -->
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger mb-4">
            ${errorMessage}
        </div>
    </c:if>

    <!-- Tiêu đề trang -->
    <div class="card p-5 mb-5 bg-primary text-white shadow-md">
        <div class="flex justify-between items-center flex-wrap gap-3">
            <div>
                <h1 class="page-title text-2xl font-bold text-white m-0">
                    Xác Nhận Đặt Cọc Giữ Chỗ Phòng
                </h1>
                <div class="text-sm opacity-90 mt-1">
                    <c:choose>
                        <c:when test="${not empty bookingDetail.maBooking && bookingDetail.maBooking != 'CHO_THANH_TOAN'}">
                            Mã đơn đặt phòng: <strong>${bookingDetail.maBooking}</strong> &nbsp;|&nbsp;
                        </c:when>
                        <c:otherwise>
                            Trạng thái: <strong>Chờ Thanh Toán Để Tạo Đơn</strong> &nbsp;|&nbsp;
                        </c:otherwise>
                    </c:choose>
                    Khách hàng: <strong>${bookingDetail.hoTenKhachHang}</strong> (${bookingDetail.soDT})
                </div>
            </div>
            <div class="badge badge-secondary px-4 py-2 text-right">
                <span class="block text-xs uppercase tracking-wide opacity-80">Quy trình</span>
                <strong class="text-sm font-bold text-primary">Thanh Toán Để Chốt Phòng</strong>
            </div>
        </div>
    </div>

    <!-- Bố cục 2 cột -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">

        <!-- CỘT TRÁI: THÔNG TIN ĐƠN ĐẶT VÀ CHI PHÍ CỌC -->
        <div class="card p-5 shadow-sm">
            <h3 class="card-title text-base font-bold text-primary pb-3 mb-4 border-b">
                Chi Tiết Tiền Cọc Theo Phòng
            </h3>

            <div class="mb-4">
                <c:forEach var="room" items="${bookingDetail.danhSachPhong}" varStatus="status">
                    <div class="card p-3 mb-3 border bg-light">
                        <div class="flex justify-between items-center mb-1">
                            <strong class="text-secondary text-sm">
                                Phòng ${room.soPhong} <span class="text-xs text-muted font-normal">(${room.tenLoaiPhong})</span>
                            </strong>
                            <span class="badge badge-secondary text-xs">
                                ${room.soDem} đêm
                            </span>
                        </div>
                        <div class="text-xs text-muted mb-2">
                            Nhận phòng: <fmt:formatDate value="${room.ngayNhanDuKien}" pattern="dd/MM/yyyy" />
                            &rarr; Trả phòng: <fmt:formatDate value="${room.ngayTraDuKien}" pattern="dd/MM/yyyy" />
                        </div>
                        <div class="flex justify-between text-xs pt-2 border-t">
                            <span class="text-muted">Tiền phòng:</span>
                            <span class="font-semibold text-secondary">
                                <fmt:formatNumber value="${room.tienPhong}" type="number" groupingUsed="true" /> đ
                            </span>
                        </div>
                        <div class="flex justify-between text-xs mt-1">
                            <span class="text-primary font-semibold">Số tiền cọc cần nộp:</span>
                            <strong class="text-primary">
                                <fmt:formatNumber value="${room.tienCoc}" type="number" groupingUsed="true" /> đ
                            </strong>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Tổng kết tài chính -->
            <div class="card p-4 mb-4 border bg-light">
                <div class="flex justify-between text-sm mb-2 text-secondary">
                    <span>Tổng tiền phòng:</span>
                    <strong class="font-bold">
                        <fmt:formatNumber value="${bookingDetail.tongTienPhong}" type="number" groupingUsed="true" /> đ
                    </strong>
                </div>
                <div class="flex justify-between text-sm mb-2 text-secondary">
                    <span>Tổng tiền dịch vụ:</span>
                    <strong class="font-bold">
                        <fmt:formatNumber value="${bookingDetail.tongTienDichVu}" type="number" groupingUsed="true" /> đ
                    </strong>
                </div>
                <div class="border-t pt-3 mt-2 flex justify-between items-baseline">
                    <div>
                        <strong class="text-sm text-primary block">SỐ TIỀN CỌC CẦN THANH TOÁN:</strong>
                        <span class="text-xs text-muted">(Thanh toán phần còn lại khi Check-out)</span>
                    </div>
                    <div class="text-2xl font-bold text-danger">
                        <fmt:formatNumber value="${bookingDetail.tongTienCoc}" type="number" groupingUsed="true" /> đ
                    </div>
                </div>
            </div>

            <div class="alert alert-warning text-xs leading-relaxed m-0">
                <strong>Lưu ý về quy định giữ chỗ:</strong> Hệ thống tự động khóa giữ phòng trong vòng <strong>10 phút</strong> kể từ khi tạo đơn. Sau khi chuyển khoản thành công, vui lòng nhấn nút xác nhận bên cạnh để hệ thống ghi nhận giao dịch nộp cọc.
            </div>
        </div>

        <!-- CỘT PHẢI: QUÉT MÃ VIETQR VÀ NÚT XÁC NHẬN -->
        <div class="card p-5 shadow-sm text-center">
            <h3 class="card-title text-base font-bold text-primary pb-3 mb-4 border-b">
                Quét Mã QR Chuyển Khoản Nhanh
            </h3>

            <!-- VietQR Code Image -->
            <div class="card p-4 border bg-light inline-block mb-4 max-w-full">
                <img src="https://img.vietqr.io/image/MB-0333884549-compact2.png?amount=${bookingDetail.tongTienCoc}&addInfo=COC%20${bookingDetail.maBooking}&accountName=HOTEL%20MANAGEMENT%20SYSTEM"
                    alt="Mã QR Chuyển Khoản Đặt Cọc"
                    class="mx-auto block rounded shadow-sm max-w-full qr-image">
                <div class="mt-2 text-xs text-muted">
                    Mở ứng dụng Ngân hàng (App Banking) bất kỳ để quét mã
                </div>
            </div>

            <!-- Bảng chi tiết tài khoản thụ hưởng -->
            <div class="card p-3 mb-4 border bg-light text-left text-xs">
                <div class="flex justify-between mb-2">
                    <span class="text-muted">Ngân hàng:</span>
                    <strong class="text-secondary">MB Bank (Ngân Hàng TMCP Quân Đội)</strong>
                </div>
                <div class="flex justify-between mb-2">
                    <span class="text-muted">Số tài khoản:</span>
                    <strong class="text-primary text-sm font-mono font-bold">0333884549</strong>
                </div>
                <div class="flex justify-between mb-2">
                    <span class="text-muted">Chủ tài khoản:</span>
                    <strong class="text-secondary">HOTEL MANAGEMENT SYSTEM</strong>
                </div>
                <div class="flex justify-between mb-2">
                    <span class="text-muted">Số tiền cọc:</span>
                    <strong class="text-danger text-sm font-bold">
                        <fmt:formatNumber value="${bookingDetail.tongTienCoc}" type="number" groupingUsed="true" /> đ
                    </strong>
                </div>
                <div class="flex justify-between border-t pt-2 mt-1">
                    <span class="text-muted">Nội dung CK:</span>
                    <strong class="text-primary text-sm font-mono font-bold">
                        <c:choose>
                            <c:when test="${not empty bookingDetail.maBooking && bookingDetail.maBooking != 'CHO_THANH_TOAN'}">
                                COC ${bookingDetail.maBooking}
                            </c:when>
                            <c:otherwise>
                                COC ${bookingDetail.soDT}
                            </c:otherwise>
                        </c:choose>
                    </strong>
                </div>
            </div>

            <!-- Nút bấm xác nhận thanh toán -->
            <form action="${pageContext.request.contextPath}/customer/deposit" method="POST" class="m-0">
                <input type="hidden" name="bookingId"
                    value="${bookingDetail.maBooking != 'CHO_THANH_TOAN' ? bookingDetail.maBooking : ''}">
                <input type="hidden" name="paymentMethod" value="BankTransfer">

                <button type="submit" class="btn btn-success w-full py-3 text-base font-bold shadow-md">
                    Tôi Đã Hoàn Tất Chuyển Khoản &amp; Xác Nhận Đặt Phòng
                </button>
            </form>

            <div class="mt-3">
                <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${bookingDetail.maBooking}"
                    class="text-xs text-muted hover:underline">
                    &larr; Xem lại chi tiết đơn đặt phòng
                </a>
            </div>
        </div>

    </div>

</div>

<jsp:include page="/views/common/footer.jsp" />