<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Cổng Khách Hàng - Trang Chủ Khách Sạn" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home/landing.css">

<div class="container my-6">

    <!-- Banner chào mừng thương hiệu sang trọng với ảnh background Resort 5 sao -->
    <div class="customer-hero-banner">
        <div class="flex justify-between items-center flex-wrap gap-4">
            <div class="max-w-2xl">
                <span class="hero-badge">
                    Hệ Thống Nghỉ Dưỡng &amp; Khách Sạn Cao Cấp
                </span>
                <h1 class="page-title text-3xl font-bold text-white mt-3 mb-2 leading-tight">
                    Kính Chào Quý Khách, ${sessionScope.CURRENT_USER.hoTen}!
                </h1>
                <p class="text-sm opacity-90 m-0 leading-relaxed">
                    Trải nghiệm kỳ nghỉ dưỡng đẳng cấp với không gian sang trọng, dịch vụ chuyên nghiệp và tiện nghi hiện đại bậc nhất. Vui lòng nhập tiêu chí lưu trú bên dưới để tìm kiếm và đặt phòng ưng ý.
                </p>
            </div>
        </div>
    </div>

    <!-- Thanh tìm kiếm phòng trung tâm (Search Bar) -->
    <div class="card p-5 mb-6 shadow-sm">
        <div class="border-b pb-3 mb-4">
            <h2 class="card-title text-lg font-bold text-primary m-0">
                Tìm Kiếm Phòng Nghỉ Phù Hợp
            </h2>
            <p class="text-xs text-muted mt-1 mb-0">
                Lựa chọn thời gian nhận - trả phòng và số lượng khách để khám phá các phòng khả dụng tốt nhất.
            </p>
        </div>

        <form action="${pageContext.request.contextPath}/customer/search-rooms" method="GET">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 items-end">

                <!-- Ngày nhận phòng -->
                <div class="form-group mb-0">
                    <label for="checkInInput" class="form-label font-semibold text-secondary text-xs">
                        Ngày Nhận Phòng:
                    </label>
                    <input type="date" id="checkInInput" name="checkIn" value="${paramCheckIn}" required class="form-control">
                </div>

                <!-- Ngày trả phòng -->
                <div class="form-group mb-0">
                    <label for="checkOutInput" class="form-label font-semibold text-secondary text-xs">
                        Ngày Trả Phòng:
                    </label>
                    <input type="date" id="checkOutInput" name="checkOut" value="${paramCheckOut}" required class="form-control">
                </div>

                <!-- Số lượng khách -->
                <div class="form-group mb-0">
                    <label for="guestsSelect" class="form-label font-semibold text-secondary text-xs">
                        Số Lượng Khách:
                    </label>
                    <select id="guestsSelect" name="guests" class="form-control">
                        <option value="">Tất cả sức chứa</option>
                        <option value="1">1 người</option>
                        <option value="2">2 người</option>
                        <option value="3">3 người</option>
                        <option value="4">4 người</option>
                    </select>
                </div>

                <!-- Hạng phòng -->
                <div class="form-group mb-0">
                    <label for="roomTypeSelect" class="form-label font-semibold text-secondary text-xs">
                        Hạng Phòng Nghỉ:
                    </label>
                    <select id="roomTypeSelect" name="roomType" class="form-control">
                        <option value="ALL">Tất cả hạng phòng</option>
                        <c:forEach var="rt" items="${roomTypes}">
                            <option value="${rt.maLoaiPhong}">${rt.tenLoaiPhong}</option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Nút tìm kiếm phòng nổi bật -->
                <div class="form-group mb-0">
                    <button type="submit" class="btn btn-primary w-full py-2 font-bold shadow-sm">
                        Tìm Kiếm Phòng
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Giới thiệu không gian nghỉ dưỡng & dịch vụ tiêu chuẩn 5 sao -->
    <div class="mb-6">
        <div class="text-center mb-5">
            <span class="section-tag">
                Tiêu Chuẩn Dịch Vụ
            </span>
            <h2 class="text-2xl font-bold text-primary mt-1 mb-2">
                Trải Nghiệm Nghỉ Dưỡng Hoàn Hảo
            </h2>
            <p class="text-muted text-sm max-w-xl mx-auto leading-relaxed">
                Chúng tôi mang đến hệ thống phòng nghỉ thanh lịch, kiến trúc giao thoa giữa nét cổ điển và hiện đại, cùng chuỗi tiện ích đẳng cấp phục vụ trọn vẹn mọi nhu cầu lưu trú của quý khách.
            </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
            <!-- Thẻ tiện ích 1 -->
            <div class="customer-feature-card">
                <div class="text-xs font-bold text-accent uppercase mb-2">
                    Không Gian Lưu Trú
                </div>
                <h3 class="text-base font-bold text-primary mb-2">
                    Phòng Nghỉ Sang Trọng &amp; Tiện Nghi
                </h3>
                <p class="text-secondary text-sm leading-relaxed m-0">
                    Toàn bộ phòng nghỉ đều được trang bị giường đệm cao cấp, ban công thoáng đãng với view biển hoặc thành phố, phòng tắm đứng hoặc bồn tắm nằm cao cấp cùng hệ thống điều hòa và Wifi tốc độ cao.
                </p>
            </div>

            <!-- Thẻ tiện ích 2 -->
            <div class="customer-feature-card">
                <div class="text-xs font-bold text-accent uppercase mb-2">
                    Ẩm Thực Thượng Hạng
                </div>
                <h3 class="text-base font-bold text-primary mb-2">
                    Buffet Sáng &amp; Thực Đơn Á - Âu
                </h3>
                <p class="text-secondary text-sm leading-relaxed m-0">
                    Thưởng thức bữa sáng tự chọn phong phú tại nhà hàng trung tâm với nguyên liệu tươi ngon chọn lọc mỗi ngày. Hỗ trợ đặt kèm suất buffet sáng ngay trong quá trình đặt phòng thuận tiện.
                </p>
            </div>

            <!-- Thẻ tiện ích 3 -->
            <div class="customer-feature-card">
                <div class="text-xs font-bold text-accent uppercase mb-2">
                    Dịch Vụ Chu Đáo
                </div>
                <h3 class="text-base font-bold text-primary mb-2">
                    Đưa Đón Sân Bay &amp; Giặt Ủi
                </h3>
                <p class="text-secondary text-sm leading-relaxed m-0">
                    Đội ngũ lễ tân và hỗ trợ trực 24/7. Cung cấp dịch vụ xe đón tiễn sân bay an toàn, dịch vụ giặt ủi lấy nhanh và hỗ trợ tư vấn các chương trình tham quan địa phương chu đáo.
                </p>
            </div>
        </div>
    </div>
</div>

<!-- Thanh giỏ hàng nổi cố định ở chân trang (Bottom Sticky Bar) nếu trong giỏ đã có phòng -->
<c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
    <div class="sticky-cart-bar">
        <div class="container flex justify-between items-center flex-wrap gap-4">
            <div>
                <span class="text-sm font-bold text-warning">
                    Đơn đặt phòng đang chọn: ${sessionScope.BOOKING_CART.totalRoomCount} phòng
                </span>
                <span class="mx-2 opacity-50">|</span>
                <span class="text-xs text-white opacity-90">
                    Tạm tính:
                    <strong class="text-white text-base ml-1">
                        <fmt:formatNumber value="${sessionScope.BOOKING_CART.grandTotal}" type="number" maxFractionDigits="0" /> đ
                    </strong>
                </span>
            </div>
            <div class="flex gap-3 items-center">
                <a href="${pageContext.request.contextPath}/customer/cart?action=view" class="btn btn-primary font-bold text-xs py-2 px-4 shadow-sm">
                    Kiểm Tra Giỏ &amp; Xác Nhận Đặt
                </a>
            </div>
        </div>
    </div>
</c:if>

<jsp:include page="/views/common/footer.jsp" />