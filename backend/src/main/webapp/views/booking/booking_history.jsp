<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Lịch Sử Đặt Phòng & Dịch Vụ" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="container my-6">

    <!-- Breadcrumb & Tiêu đề -->
    <div class="flex justify-between items-center mb-5 flex-wrap gap-4">
        <div>
            <nav class="breadcrumb-nav mb-1" aria-label="Breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/customer/home">Trang Chủ</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Lịch Sử Đặt Phòng</li>
                </ol>
            </nav>
            <h1 class="page-title text-2xl font-bold text-primary m-0">
                Danh Sách Đơn Đặt Phòng Của Bạn
            </h1>
            <p class="text-secondary text-sm mt-1 mb-0">
                Theo dõi trạng thái đơn đặt phòng, hóa đơn và bổ sung dịch vụ tiện ích trước khi nhận và trả phòng.
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/customer/home" class="btn btn-primary">
            Đặt Thêm Phòng Mới
        </a>
    </div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${param.cancelSuccess == 'true'}">
        <div class="alert alert-success mb-5">
            <strong>Thành công:</strong> Bạn đã hủy đơn đặt phòng thành công. Phòng đã được hoàn trả lại danh sách khả dụng.
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="alert alert-danger mb-5">
            <strong>Thông báo:</strong> ${param.error}
        </div>
    </c:if>

    <!-- Danh sách đơn đặt -->
    <c:choose>
        <c:when test="${not empty bookingList}">
            <div class="card p-0 shadow-sm overflow-hidden">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Mã Đơn / Ngày Đặt</th>
                                <th>Thông Tin Phòng</th>
                                <th>Kỳ Lưu Trú</th>
                                <th>Chi Phí Dự Kiến</th>
                                <th class="text-center">Trạng Thái Đặt</th>
                                <th class="text-center">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${bookingList}">
                                <tr>
                                    <!-- Mã Đơn & Thời điểm đặt -->
                                    <td class="align-middle">
                                        <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${item.maBooking}"
                                            class="font-bold text-primary hover:underline text-base font-mono">
                                            ${item.maBooking}
                                        </a>
                                        <div class="text-xs text-muted mt-1">
                                            <fmt:formatDate value="${item.ngayDat}" pattern="dd/MM/yyyy HH:mm" />
                                        </div>
                                    </td>

                                    <!-- Thông tin phòng -->
                                    <td class="align-middle">
                                        <div class="font-bold text-primary">
                                            ${item.soPhong}
                                        </div>
                                        <span class="text-xs text-secondary">
                                            ${item.tenLoaiPhong}
                                        </span>
                                    </td>

                                    <!-- Kỳ lưu trú -->
                                    <td class="align-middle">
                                        <div class="text-secondary font-semibold text-sm">
                                            <fmt:formatDate value="${item.ngayNhanDuKien}" pattern="dd/MM/yyyy" />
                                            đến
                                            <fmt:formatDate value="${item.ngayTraDuKien}" pattern="dd/MM/yyyy" />
                                        </div>
                                    </td>

                                    <!-- Chi phí dự kiến -->
                                    <td class="align-middle">
                                        <div class="font-bold text-primary text-base">
                                            <fmt:formatNumber value="${item.chiPhiDuKien}" type="number" groupingUsed="true" /> đ
                                        </div>
                                    </td>

                                    <!-- Trạng thái Booking -->
                                    <td class="align-middle text-center">
                                        <c:choose>
                                            <c:when test="${item.trangThaiBooking == 'Confirmed'}">
                                                <span class="badge badge-primary">
                                                    Đã Xác Nhận
                                                </span>
                                            </c:when>
                                            <c:when test="${item.trangThaiBooking == 'CheckedIn'}">
                                                <span class="badge badge-success">
                                                    Đang Ở (Check-in)
                                                </span>
                                            </c:when>
                                            <c:when test="${item.trangThaiBooking == 'CheckedOut'}">
                                                <span class="badge badge-secondary">
                                                    Đã Trả Phòng
                                                </span>
                                            </c:when>
                                            <c:when test="${item.trangThaiBooking == 'Cancelled'}">
                                                <span class="badge badge-danger">
                                                    Đã Hủy
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-secondary">
                                                    ${item.trangThaiBooking}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Nút thao tác -->
                                    <td class="align-middle text-center">
                                        <div class="flex gap-2 justify-center items-center flex-wrap">
                                            <!-- Xem chi tiết & Quản lý dịch vụ -->
                                            <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${item.maBooking}"
                                                class="btn btn-secondary btn-sm whitespace-nowrap">
                                                Chi Tiết &amp; Dịch Vụ
                                            </a>

                                            <!-- Hủy phòng (chỉ khi có thể hủy) -->
                                            <c:if test="${item.coTheHuy}">
                                                <button type="button" 
                                                        class="btn btn-outline btn-danger btn-sm whitespace-nowrap"
                                                        onclick="openCancelModal('${item.maBooking}')">
                                                    Hủy Toàn Bộ Đơn
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:when>

        <c:otherwise>
            <!-- Trạng thái chưa có đơn đặt phòng nào -->
            <div class="card p-6 text-center shadow-sm my-6">
                <div class="mb-4">
                    <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="text-muted">
                        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                        <line x1="16" y1="2" x2="16" y2="6"></line>
                        <line x1="8" y1="2" x2="8" y2="6"></line>
                        <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
                </div>
                <h3 class="text-xl font-bold text-primary mb-2">Bạn Chưa Có Đơn Đặt Phòng Nào</h3>
                <p class="text-secondary text-sm max-w-md mx-auto mb-5 leading-relaxed">
                    Hãy khám phá các hạng phòng nghỉ dưỡng sang trọng với mức giá ưu đãi và nhiều tiện ích tuyệt vời tại khách sạn của chúng tôi.
                </p>
                <div>
                    <a href="${pageContext.request.contextPath}/customer/home" class="btn btn-primary px-6 py-3 font-bold">
                        Tìm Kiếm &amp; Đặt Phòng Ngay
                    </a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

</div>

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