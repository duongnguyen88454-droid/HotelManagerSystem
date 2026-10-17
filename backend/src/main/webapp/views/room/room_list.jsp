<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Trang Đặt Phòng - Danh Sách Phòng Khả Dụng" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="public-container my-6">

    <!-- Thanh tìm kiếm và đổi tiêu chí nhanh ở đầu trang (Top Search Summary Bar) -->
    <div class="card p-4 mb-5">
        <form action="${pageContext.request.contextPath}/customer/search-rooms" method="GET" class="flex flex-wrap gap-3 items-end">
            <div class="flex-1 min-w-40">
                <label class="form-label uppercase font-bold text-xs text-secondary mb-1">
                    Ngày Nhận Phòng
                </label>
                <input type="date" name="checkIn" id="filterCheckIn" value="${paramCheckIn}" required class="form-control text-sm">
            </div>

            <div class="flex-1 min-w-40">
                <label class="form-label uppercase font-bold text-xs text-secondary mb-1">
                    Ngày Trả Phòng
                </label>
                <input type="date" name="checkOut" id="filterCheckOut" value="${paramCheckOut}" required class="form-control text-sm">
            </div>

            <div class="flex-1 min-w-32">
                <label class="form-label uppercase font-bold text-xs text-secondary mb-1">
                    Số Khách
                </label>
                <select name="guests" class="form-control text-sm">
                    <option value="">Tất cả</option>
                    <option value="1" ${paramGuests=='1' ? 'selected' : ''}>1 người</option>
                    <option value="2" ${paramGuests=='2' ? 'selected' : ''}>2 người</option>
                    <option value="3" ${paramGuests=='3' ? 'selected' : ''}>3 người</option>
                    <option value="4" ${paramGuests=='4' ? 'selected' : ''}>4+ người</option>
                </select>
            </div>

            <div class="flex-1 min-w-44">
                <label class="form-label uppercase font-bold text-xs text-secondary mb-1">
                    Hạng Phòng
                </label>
                <select name="roomType" class="form-control text-sm">
                    <option value="ALL">Tất cả hạng phòng</option>
                    <c:forEach var="rt" items="${roomTypes}">
                        <option value="${rt.maLoaiPhong}" ${paramRoomType==rt.maLoaiPhong ? 'selected' : ''}>
                            ${rt.tenLoaiPhong}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="min-w-32">
                <button type="submit" class="btn btn-primary w-full">
                    Tìm Kiếm
                </button>
            </div>
        </form>
    </div>

    <!-- Thông báo lỗi nếu có -->
    <c:if test="${not empty errorMessage or not empty param.error}">
        <div class="alert alert-danger mb-4">
            <strong>Thông báo:</strong> ${not empty errorMessage ? errorMessage : param.error}
        </div>
    </c:if>

    <!-- BỐ CỤC CHÍNH 2 CỘT (Bộ lọc bên trái + Danh sách thẻ phòng bên phải) -->
    <div class="grid-sidebar-content">

        <!-- CỘT TRÁI: BỘ LỌC TÌM KIẾM (FILTER SIDEBAR) -->
        <div class="card p-4">
            <div class="flex justify-between items-center border-bottom pb-3 mb-4">
                <h3 class="text-primary font-bold text-base mb-0">
                    Bộ Lọc Tìm Kiếm
                </h3>
                <a href="javascript:void(0)" onclick="resetFilters()" class="text-warning text-xs font-semibold">
                    Xóa tất cả
                </a>
            </div>

            <!-- Tìm kiếm theo số phòng / tên phòng -->
            <div class="border-bottom pb-3 mb-3">
                <label class="form-label font-bold text-xs text-secondary mb-2">
                    Tìm Tên / Số Phòng
                </label>
                <input type="text" id="keywordFilter" oninput="applyFilters()" placeholder="Nhập số phòng (VD: 101...)" class="form-control text-sm">
            </div>

            <!-- Lọc theo Hạng phòng -->
            <div class="border-bottom pb-3 mb-3">
                <div class="font-bold text-xs text-secondary uppercase mb-2">
                    Hạng Phòng
                </div>
                <c:forEach var="rt" items="${roomTypes}">
                    <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                        <input type="checkbox" name="typeCheckbox" value="${rt.maLoaiPhong}" onchange="applyFilters()" class="mr-2">
                        <span>${rt.tenLoaiPhong}</span>
                    </label>
                </c:forEach>
            </div>

            <!-- Lọc theo Loại Giường (BedType 3NF) -->
            <c:if test="${not empty bedTypes}">
                <div class="border-bottom pb-3 mb-3">
                    <div class="font-bold text-xs text-secondary uppercase mb-2">
                        Loại Giường
                    </div>
                    <c:forEach var="bt" items="${bedTypes}">
                        <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                            <input type="checkbox" name="bedCheckbox" value="${bt.bedTypeName}" onchange="applyFilters()" class="mr-2">
                            <span>${bt.bedTypeName}</span>
                        </label>
                    </c:forEach>
                </div>
            </c:if>

            <!-- Lọc theo Mức giá (Ngân sách) -->
            <div class="border-bottom pb-3 mb-3">
                <div class="font-bold text-xs text-secondary uppercase mb-2">
                    Ngân Sách / Phòng / Đêm
                </div>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="checkbox" name="priceCheckbox" value="under_1m" onchange="applyFilters()" class="mr-2">
                    <span>Dưới 1.000.000 đ</span>
                </label>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="checkbox" name="priceCheckbox" value="1m_2m" onchange="applyFilters()" class="mr-2">
                    <span>1.000.000 đ - 2.000.000 đ</span>
                </label>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="checkbox" name="priceCheckbox" value="2m_3m" onchange="applyFilters()" class="mr-2">
                    <span>2.000.000 đ - 3.000.000 đ</span>
                </label>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="checkbox" name="priceCheckbox" value="over_3m" onchange="applyFilters()" class="mr-2">
                    <span>Trên 3.000.000 đ</span>
                </label>
            </div>

            <!-- Lọc theo Sức chứa -->
            <div>
                <div class="font-bold text-xs text-secondary uppercase mb-2">
                    Sức Chứa Tối Thiểu
                </div>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="radio" name="capacityRadio" value="all" checked onchange="applyFilters()" class="mr-2">
                    <span>Tất cả sức chứa</span>
                </label>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="radio" name="capacityRadio" value="1" onchange="applyFilters()" class="mr-2">
                    <span>Phòng 1 người</span>
                </label>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="radio" name="capacityRadio" value="2" onchange="applyFilters()" class="mr-2">
                    <span>Phòng 2 người</span>
                </label>
                <label class="flex items-center text-sm text-secondary mb-2 cursor-pointer">
                    <input type="radio" name="capacityRadio" value="3" onchange="applyFilters()" class="mr-2">
                    <span>Phòng 3 người trở lên</span>
                </label>
            </div>
        </div>

        <!-- CỘT PHẢI: DANH SÁCH THẺ PHÒNG NẰM NGANG (HORIZONTAL ROOM CARDS) -->
        <div>
            <!-- Tiêu đề kết quả & Sắp xếp -->
            <div class="flex justify-between items-center mb-4 flex-wrap gap-2">
                <div>
                    <h2 class="text-primary font-bold text-xl mb-0">
                        Kết Quả Phòng Trống Khả Dụng
                    </h2>
                    <p class="text-muted text-xs mt-1">
                        Kỳ nghỉ từ <strong>${paramCheckIn}</strong> đến <strong>${paramCheckOut}</strong>
                        &bull; Hiện có <strong id="roomCountDisplay" class="text-primary">${not empty roomList ? roomList.size() : 0}</strong> phòng phù hợp
                    </p>
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-xs text-secondary font-semibold">Sắp xếp:</span>
                    <select id="sortSelect" onchange="sortRooms()" class="form-control text-xs">
                        <option value="default">Mặc định (Đề xuất)</option>
                        <option value="price_asc">Giá phòng tăng dần</option>
                        <option value="price_desc">Giá phòng giảm dần</option>
                        <option value="capacity_desc">Sức chứa nhiều nhất</option>
                    </select>
                </div>
            </div>

            <!-- Danh sách các thẻ phòng dạng ngang -->
            <c:choose>
                <c:when test="${not empty roomList}">
                    <div id="roomContainer" class="flex flex-col gap-4">
                        <c:forEach var="room" items="${roomList}">
                            <div class="room-horizontal-card"
                                 data-room-id="${room.maPhong}"
                                 data-room-number="${room.soPhong}"
                                 data-room-name="${room.soPhong} ${room.tenLoaiPhong}"
                                 data-type="${room.maLoaiPhong}"
                                 data-price="${room.donGia}"
                                 data-capacity="${room.soNguoiToiDa}"
                                 data-bed="${room.loaiGiuong}">
                                
                                <!-- Khối 1: Ảnh minh họa phòng -->
                                <div class="room-card-media">
                                    <img src="${not empty room.hinhAnhMinhHoa ? room.hinhAnhMinhHoa : 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80'}"
                                         alt="${room.tenLoaiPhong}"
                                         onerror="this.src='https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&q=80';" />
                                    <div class="media-overlay"></div>
                                    
                                    <div class="media-content">
                                        <span class="badge badge-primary text-xs uppercase font-bold">
                                            ${room.tenLoaiPhong}
                                        </span>
                                    </div>
                                    <div class="media-content">
                                        <div class="text-xs text-amber font-bold uppercase">
                                            MÃ PHÒNG: ${room.maPhong}
                                        </div>
                                        <div class="text-2xl font-bold text-inverse mt-1">
                                            ${room.soPhong}
                                        </div>
                                        <div class="text-xs text-muted mt-1">
                                            Sức chứa tối đa: ${room.soNguoiToiDa} người
                                        </div>
                                    </div>
                                </div>

                                <!-- Khối 2: Thông tin chi tiết ở giữa -->
                                <div class="room-card-body">
                                    <div>
                                        <div class="flex justify-between items-baseline">
                                            <h3 class="text-primary font-bold text-lg mb-0">
                                                ${room.soPhong} - ${room.tenLoaiPhong}
                                            </h3>
                                        </div>
                                        
                                        <div class="flex items-center gap-2 mt-1">
                                            <span class="badge badge-success text-xs font-bold">
                                                Sẵn Sàng
                                            </span>
                                            <span class="text-xs text-muted">
                                                Tiêu chuẩn nghỉ dưỡng cao cấp
                                            </span>
                                        </div>

                                        <!-- Tags tiện ích nổi bật & Cấu hình giường chuẩn 3NF -->
                                        <div class="room-amenities-wrap">
                                            <span class="badge badge-info text-xs">
                                                Giường: ${room.loaiGiuong}
                                            </span>
                                            <span class="badge badge-neutral text-xs">
                                                Sức chứa ${room.soNguoiToiDa} người
                                            </span>
                                            <c:forEach var="tn" items="${room.danhSachTienNghi}">
                                                <span class="badge badge-neutral text-xs">
                                                    ${tn}
                                                </span>
                                            </c:forEach>
                                        </div>
                                    </div>

                                    <div class="mt-3 text-xs text-success font-semibold">
                                        Phòng sạch sẽ, đạt chuẩn vệ sinh - Sẵn sàng tiếp đón
                                    </div>
                                </div>

                                <!-- Khối 3: Bảng giá & Nút hành động bên phải -->
                                <div class="room-card-pricing">
                                    <div>
                                        <div class="text-xs font-bold text-primary mb-1">
                                            Chính Sách &amp; Quy Định
                                        </div>
                                        <div class="text-xs text-secondary leading-relaxed">
                                            <div>Đặt phòng trực tuyến nhanh chóng</div>
                                            <div>Nhận phòng từ 14:00 chiều</div>
                                            <div>Trả phòng trước 12:00 trưa</div>
                                        </div>
                                    </div>

                                    <div class="mt-3">
                                        <div class="text-2xl font-bold text-warning mono">
                                            <fmt:formatNumber value="${room.donGia}" type="number" maxFractionDigits="0"/> đ
                                        </div>
                                        <div class="text-xs text-muted mb-3">
                                            / phòng / đêm
                                        </div>

                                        <!-- Nút Xem Phòng dẫn sang Trang Chi Tiết Phòng -->
                                        <a href="${pageContext.request.contextPath}/customer/room-detail?maPhong=${room.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                                           class="btn btn-primary w-full">
                                            Xem Phòng
                                        </a>
                                    </div>
                                </div>

                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card p-6 text-center">
                        <h3 class="text-secondary font-bold text-lg mb-2">
                            Không tìm thấy phòng trống khả dụng nào
                        </h3>
                        <p class="text-muted text-sm mb-4">
                            Rất tiếc trong khoảng thời gian từ ${paramCheckIn} đến ${paramCheckOut} hiện các phòng đã kín chỗ. Quý khách vui lòng chọn khoảng ngày khác.
                        </p>
                        <a href="${pageContext.request.contextPath}/customer/home" class="btn btn-primary">
                            Quay Lại Trang Chủ
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Khung thông báo khi không có phòng nào khớp bộ lọc JS -->
            <div id="noMatchMessage" class="card p-6 text-center mt-4 hidden">
                <h3 class="text-secondary font-bold text-base mb-2">
                    Không có phòng nào thỏa mãn tiêu chí bộ lọc đã chọn
                </h3>
                <p class="text-muted text-xs mb-3">
                    Vui lòng điều chỉnh lại mức giá, hạng phòng hoặc nhấn nút xóa bộ lọc.
                </p>
                <button type="button" onclick="resetFilters()" class="btn btn-outline btn-sm">
                    Xóa Bộ Lọc Tìm Kiếm
                </button>
            </div>

        </div>
    </div>
</div>

<!-- Thanh giỏ hàng nổi chân trang nếu có phòng trong giỏ -->
<c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
    <div class="cart-floating-bar">
        <div class="public-container flex justify-between items-center flex-wrap gap-3">
            <div>
                <span class="font-bold text-base text-amber">
                    Đơn đặt phòng đang chọn: ${sessionScope.BOOKING_CART.totalRoomCount} phòng
                </span>
                <span class="mx-2 text-muted">|</span>
                <span class="text-sm">
                    Tạm tính: 
                    <strong class="text-inverse text-lg mono ml-1">
                        <fmt:formatNumber value="${sessionScope.BOOKING_CART.grandTotal}" type="number" maxFractionDigits="0"/> đ
                    </strong>
                </span>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/customer/cart?action=view" class="btn btn-warning">
                    Kiểm Tra Giỏ &amp; Xác Nhận Đặt
                </a>
            </div>
        </div>
    </div>
</c:if>

<!-- JAVASCRIPT BỘ LỌC CỘT TRÁI & SẮP XẾP TỨC THỜI -->
<script src="${pageContext.request.contextPath}/assets/js/room/room_list.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        var today = new Date().toISOString().split("T")[0];
        var checkInInput = document.getElementById("filterCheckIn");
        var checkOutInput = document.getElementById("filterCheckOut");

        if (checkInInput && checkOutInput) {
            if (!checkInInput.getAttribute("min")) {
                checkInInput.setAttribute("min", today);
            }
            checkInInput.addEventListener("change", function() {
                var selectedIn = checkInInput.value;
                if (selectedIn) {
                    var nextDay = new Date(selectedIn);
                    nextDay.setDate(nextDay.getDate() + 1);
                    var minOut = nextDay.toISOString().split("T")[0];
                    checkOutInput.setAttribute("min", minOut);
                    if (checkOutInput.value && checkOutInput.value <= selectedIn) {
                        checkOutInput.value = minOut;
                    }
                }
            });
        }
    });
</script>

<jsp:include page="/views/common/footer.jsp" />