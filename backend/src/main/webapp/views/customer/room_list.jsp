<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Trang Đặt Phòng - Danh Sách Phòng Khả Dụng" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="container" style="max-width: 1220px; margin-top: 25px; margin-bottom: 90px;">

    <!-- Thanh tìm kiếm và đổi tiêu chí nhanh ở đầu trang (Top Search Summary Bar) -->
    <div style="background: white; border-radius: 8px; border: 1px solid #d2d6dc; padding: 18px 24px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); margin-bottom: 25px;">
        <form action="${pageContext.request.contextPath}/customer/search-rooms" method="GET"
              style="display: flex; flex-wrap: wrap; gap: 14px; align-items: flex-end;">
            
            <div style="flex: 1; min-width: 160px;">
                <label style="font-size: 12px; font-weight: 700; color: #4a5568; display: block; margin-bottom: 5px; text-transform: uppercase;">
                    Ngày Nhận Phòng
                </label>
                <input type="date" name="checkIn" id="filterCheckIn" value="${paramCheckIn}" required
                       style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; color: #2d3748; box-sizing: border-box;">
            </div>

            <div style="flex: 1; min-width: 160px;">
                <label style="font-size: 12px; font-weight: 700; color: #4a5568; display: block; margin-bottom: 5px; text-transform: uppercase;">
                    Ngày Trả Phòng
                </label>
                <input type="date" name="checkOut" id="filterCheckOut" value="${paramCheckOut}" required
                       style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; color: #2d3748; box-sizing: border-box;">
            </div>

            <div style="flex: 1; min-width: 130px;">
                <label style="font-size: 12px; font-weight: 700; color: #4a5568; display: block; margin-bottom: 5px; text-transform: uppercase;">
                    Số Khách
                </label>
                <select name="guests"
                        style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; background: white; color: #2d3748; box-sizing: border-box;">
                    <option value="">Tất cả</option>
                    <option value="1" ${paramGuests=='1' ? 'selected' : ''}>1 người</option>
                    <option value="2" ${paramGuests=='2' ? 'selected' : ''}>2 người</option>
                    <option value="3" ${paramGuests=='3' ? 'selected' : ''}>3 người</option>
                    <option value="4" ${paramGuests=='4' ? 'selected' : ''}>4+ người</option>
                </select>
            </div>

            <div style="flex: 1; min-width: 170px;">
                <label style="font-size: 12px; font-weight: 700; color: #4a5568; display: block; margin-bottom: 5px; text-transform: uppercase;">
                    Hạng Phòng
                </label>
                <select name="roomType"
                        style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; background: white; color: #2d3748; box-sizing: border-box;">
                    <option value="ALL">Tất cả hạng phòng</option>
                    <c:forEach var="rt" items="${roomTypes}">
                        <option value="${rt.maLoaiPhong}" ${paramRoomType==rt.maLoaiPhong ? 'selected' : ''}>
                            ${rt.tenLoaiPhong}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div style="min-width: 130px;">
                <button type="submit"
                        style="width: 100%; background: #dd6b20; color: white; border: none; padding: 10px 18px; border-radius: 5px; font-weight: 700; font-size: 13px; cursor: pointer; transition: background 0.2s;"
                        onmouseover="this.style.background='#c05621'" onmouseout="this.style.background='#dd6b20'">
                    Tìm Kiếm
                </button>
            </div>
        </form>
    </div>

    <!-- Thông báo lỗi nếu có -->
    <c:if test="${not empty errorMessage or not empty param.error}">
        <div style="margin-bottom: 20px; background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; padding: 12px 18px; border-radius: 6px; font-size: 14px;">
            <strong>Thông báo:</strong> ${not empty errorMessage ? errorMessage : param.error}
        </div>
    </c:if>

    <!-- BỐ CỤC CHÍNH 2 CỘT CHUẨN iVIVU (Bộ lọc bên trái + Danh sách thẻ phòng bên phải) -->
    <div style="display: flex; gap: 25px; align-items: flex-start; flex-wrap: wrap;">

        <!-- CỘT TRÁI: BỘ LỌC TÌM KIẾM (FILTER SIDEBAR) -->
        <div style="flex: 0 0 280px; width: 280px; background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); box-sizing: border-box;">
            
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #edf2f7; padding-bottom: 12px; margin-bottom: 18px;">
                <h3 style="color: #1a365d; font-size: 16px; margin: 0; font-weight: 700;">
                    Bộ Lọc Tìm Kiếm
                </h3>
                <a href="javascript:void(0)" onclick="resetFilters()" style="font-size: 12px; color: #dd6b20; text-decoration: none; font-weight: 600;">
                    Xóa tất cả
                </a>
            </div>

            <!-- Tìm kiếm theo số phòng / tên phòng -->
            <div style="margin-bottom: 20px; border-bottom: 1px solid #f0f4f8; padding-bottom: 16px;">
                <label style="display: block; font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 8px;">
                    Tìm Tên / Số Phòng
                </label>
                <input type="text" id="keywordFilter" oninput="applyFilters()" placeholder="Nhập số phòng (VD: 101...)"
                       style="width: 100%; padding: 8px 10px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; box-sizing: border-box;">
            </div>

            <!-- Lọc theo Hạng phòng -->
            <div style="margin-bottom: 20px; border-bottom: 1px solid #f0f4f8; padding-bottom: 16px;">
                <div style="font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 10px;">
                    Hạng Phòng
                </div>
                <c:forEach var="rt" items="${roomTypes}">
                    <label style="display: flex; align-items: center; justify-content: space-between; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                        <span>
                            <input type="checkbox" name="typeCheckbox" value="${rt.maLoaiPhong}" onchange="applyFilters()" style="margin-right: 8px;">
                            ${rt.tenLoaiPhong}
                        </span>
                        <span style="font-size: 11px; color: #a0aec0; background: #edf2f7; padding: 2px 6px; border-radius: 10px;">
                            Tối đa ${rt.soNguoiToiDa} người
                        </span>
                    </label>
                </c:forEach>
            </div>

            <!-- Lọc theo Mức giá (Ngân sách) -->
            <div style="margin-bottom: 20px; border-bottom: 1px solid #f0f4f8; padding-bottom: 16px;">
                <div style="font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 10px;">
                    Ngân Sách / Phòng / Đêm
                </div>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="checkbox" name="priceCheckbox" value="under_1m" onchange="applyFilters()" style="margin-right: 8px;">
                    Dưới 1.000.000 đ
                </label>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="checkbox" name="priceCheckbox" value="1m_2m" onchange="applyFilters()" style="margin-right: 8px;">
                    1.000.000 đ - 2.000.000 đ
                </label>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="checkbox" name="priceCheckbox" value="2m_3m" onchange="applyFilters()" style="margin-right: 8px;">
                    2.000.000 đ - 3.000.000 đ
                </label>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="checkbox" name="priceCheckbox" value="over_3m" onchange="applyFilters()" style="margin-right: 8px;">
                    Trên 3.000.000 đ
                </label>
            </div>

            <!-- Lọc theo Sức chứa -->
            <div>
                <div style="font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 10px;">
                    Sức Chứa Tối Thiểu
                </div>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="radio" name="capacityRadio" value="all" checked onchange="applyFilters()" style="margin-right: 8px;">
                    Tất cả sức chứa
                </label>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="radio" name="capacityRadio" value="1" onchange="applyFilters()" style="margin-right: 8px;">
                    Phòng 1 người
                </label>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="radio" name="capacityRadio" value="2" onchange="applyFilters()" style="margin-right: 8px;">
                    Phòng 2 người
                </label>
                <label style="display: block; font-size: 13px; color: #4a5568; margin-bottom: 8px; cursor: pointer;">
                    <input type="radio" name="capacityRadio" value="3" onchange="applyFilters()" style="margin-right: 8px;">
                    Phòng 3 người trở lên
                </label>
            </div>

        </div>

        <!-- CỘT PHẢI: DANH SÁCH THẺ PHÒNG NẰM NGANG (HORIZONTAL ROOM CARDS) -->
        <div style="flex: 1; min-width: 600px;">
            
            <!-- Tiêu đề kết quả & Sắp xếp -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h2 style="color: #1a365d; margin: 0; font-size: 20px; font-weight: 700;">
                        Kết Quả Phòng Trống Khả Dụng
                    </h2>
                    <p style="color: #718096; margin: 4px 0 0 0; font-size: 13px;">
                        Kỳ nghỉ từ <strong>${paramCheckIn}</strong> đến <strong>${paramCheckOut}</strong>
                        &bull; Hiện có <strong id="roomCountDisplay">${not empty roomList ? roomList.size() : 0}</strong> phòng phù hợp
                    </p>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <span style="font-size: 13px; color: #4a5568; font-weight: 600;">Sắp xếp:</span>
                    <select id="sortSelect" onchange="sortRooms()" 
                            style="padding: 6px 10px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; background: white; color: #2d3748;">
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
                    <div id="roomContainer" style="display: flex; flex-direction: column; gap: 20px;">
                        <c:forEach var="room" items="${roomList}">
                            <div class="room-horizontal-card"
                                 data-room-id="${room.maPhong}"
                                 data-room-number="${room.soPhong}"
                                 data-room-name="${room.soPhong} ${room.tenLoaiPhong}"
                                 data-type="${room.maLoaiPhong}"
                                 data-price="${room.donGia}"
                                 data-capacity="${room.soNguoiToiDa}"
                                 style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; display: flex; flex-direction: row; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.05); transition: box-shadow 0.2s;"
                                 onmouseover="this.style.boxShadow='0 4px 12px rgba(0,0,0,0.08)'"
                                 onmouseout="this.style.boxShadow='0 1px 4px rgba(0,0,0,0.05)'">
                                
                                <!-- Khối 1: Ảnh minh họa bên trái (~250px) -->
                                <div style="flex: 0 0 250px; width: 250px; background: #1a365d; position: relative; display: flex; flex-direction: column; justify-content: space-between; padding: 18px; box-sizing: border-box; color: white;">
                                    <div>
                                        <span style="background: #dd6b20; color: white; font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 3px; text-transform: uppercase;">
                                            Bao Gồm Ăn Sáng
                                        </span>
                                    </div>
                                    <div>
                                        <div style="font-size: 12px; color: #feebc8; font-weight: 600; text-transform: uppercase;">
                                            ${room.tenLoaiPhong}
                                        </div>
                                        <div style="font-size: 22px; font-weight: 700; color: #ffffff; margin-top: 2px;">
                                            Phòng ${room.soPhong}
                                        </div>
                                        <div style="font-size: 11px; color: #cbd5e0; margin-top: 4px;">
                                            Sức chứa tối đa: ${room.soNguoiToiDa} người
                                        </div>
                                    </div>
                                </div>

                                <!-- Khối 2: Thông tin chi tiết ở giữa (flex: 1) -->
                                <div style="flex: 1; padding: 18px 22px; display: flex; flex-direction: column; justify-content: space-between;">
                                    <div>
                                        <div style="display: flex; justify-content: space-between; align-items: baseline;">
                                            <h3 style="color: #1a365d; margin: 0; font-size: 18px; font-weight: 700;">
                                                Phòng ${room.soPhong} - ${room.tenLoaiPhong}
                                            </h3>
                                        </div>
                                        
                                        <div style="display: flex; align-items: center; gap: 8px; margin-top: 6px;">
                                            <span style="background: #276749; color: white; font-size: 11px; font-weight: 700; padding: 2px 6px; border-radius: 3px;">
                                                9.6 Tuyệt Vời
                                            </span>
                                            <span style="font-size: 12px; color: #718096;">
                                                Tiêu chuẩn khách sạn 5 sao
                                            </span>
                                        </div>

                                        <!-- Tags tiện ích nổi bật -->
                                        <div style="display: flex; flex-wrap: wrap; gap: 6px; margin-top: 12px;">
                                            <span style="background: #f7fafc; border: 1px solid #e2e8f0; color: #4a5568; font-size: 12px; padding: 3px 8px; border-radius: 4px;">
                                                Ban công riêng
                                            </span>
                                            <span style="background: #f7fafc; border: 1px solid #e2e8f0; color: #4a5568; font-size: 12px; padding: 3px 8px; border-radius: 4px;">
                                                Điều hòa 2 chiều
                                            </span>
                                            <span style="background: #f7fafc; border: 1px solid #e2e8f0; color: #4a5568; font-size: 12px; padding: 3px 8px; border-radius: 4px;">
                                                Bồn tắm nằm
                                            </span>
                                            <span style="background: #f7fafc; border: 1px solid #e2e8f0; color: #4a5568; font-size: 12px; padding: 3px 8px; border-radius: 4px;">
                                                Wifi tốc độ cao
                                            </span>
                                        </div>
                                    </div>

                                    <div style="margin-top: 14px; font-size: 12px; color: #276749; font-weight: 600;">
                                        Phòng sạch sẽ, đạt chuẩn vệ sinh - Sẵn sàng tiếp đón
                                    </div>
                                </div>

                                <!-- Khối 3: Bảng giá & Nút hành động bên phải (~230px) -->
                                <div style="flex: 0 0 230px; width: 230px; border-left: 1px solid #edf2f7; background: #fafafa; padding: 18px 20px; display: flex; flex-direction: column; justify-content: space-between; text-align: right; box-sizing: border-box;">
                                    <div>
                                        <div style="font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 6px;">
                                            Gói Nghỉ Dưỡng Tiêu Chuẩn
                                        </div>
                                        <div style="font-size: 12px; color: #4a5568; line-height: 1.5;">
                                            <div>Gồm bữa sáng buffet</div>
                                            <div>Nước suối & trà miễn phí</div>
                                            <div>Hỗ trợ nhận phòng 14:00</div>
                                        </div>
                                    </div>

                                    <div style="margin-top: 15px;">
                                        <div style="font-size: 22px; font-weight: 700; color: #dd6b20;">
                                            <fmt:formatNumber value="${room.donGia}" type="number" maxFractionDigits="0"/> đ
                                        </div>
                                        <div style="font-size: 12px; color: #718096; margin-bottom: 12px;">
                                            / phòng / đêm
                                        </div>

                                        <!-- Nút Xem Phòng dẫn sang Trang Chi Tiết Phòng -->
                                        <a href="${pageContext.request.contextPath}/customer/room-detail?maPhong=${room.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                                           style="display: block; width: 100%; box-sizing: border-box; background: #dd6b20; color: white; text-align: center; text-decoration: none; padding: 10px 14px; border-radius: 5px; font-size: 13px; font-weight: 700; transition: background 0.2s;"
                                           onmouseover="this.style.background='#c05621'" onmouseout="this.style.background='#dd6b20'">
                                            Xem Phòng
                                        </a>
                                    </div>
                                </div>

                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 40px; text-align: center;">
                        <h3 style="color: #718096; margin: 0 0 10px 0; font-size: 18px;">
                            Không tìm thấy phòng trống khả dụng nào
                        </h3>
                        <p style="color: #a0aec0; margin: 0 0 20px 0; font-size: 14px;">
                            Rất tiếc trong khoảng thời gian từ ${paramCheckIn} đến ${paramCheckOut} hiện các phòng đã kín chỗ. Quý khách vui lòng chọn khoảng ngày khác.
                        </p>
                        <a href="${pageContext.request.contextPath}/customer/home" 
                           style="display: inline-block; background: #1a365d; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none; font-size: 13px; font-weight: 600;">
                            Quay Lại Trang Chủ
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Khung thông báo khi không có phòng nào khớp bộ lọc JS -->
            <div id="noMatchMessage" style="display: none; background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 35px; text-align: center; margin-top: 15px;">
                <h3 style="color: #718096; margin: 0 0 8px 0; font-size: 16px;">
                    Không có phòng nào thỏa mãn tiêu chí bộ lọc đã chọn
                </h3>
                <p style="color: #a0aec0; margin: 0 0 15px 0; font-size: 13px;">
                    Vui lòng điều chỉnh lại mức giá, hạng phòng hoặc nhấn nút xóa bộ lọc.
                </p>
                <button type="button" onclick="resetFilters()"
                        style="background: #dd6b20; color: white; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; font-weight: 600; cursor: pointer;">
                    Xóa Bộ Lọc Tìm Kiếm
                </button>
            </div>

        </div>
    </div>
</div>

<!-- Thanh giỏ hàng nổi chân trang nếu có phòng trong giỏ -->
<c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
    <div style="position: fixed; bottom: 0; left: 0; right: 0; background: #1a365d; color: white; padding: 14px 24px; box-shadow: 0 -4px 16px rgba(0,0,0,0.18); z-index: 1000; border-top: 2px solid #c5a880;">
        <div style="max-width: 1220px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <span style="font-size: 15px; font-weight: 700; color: #fbd38d;">
                    Đơn đặt phòng đang chọn: ${sessionScope.BOOKING_CART.totalRoomCount} phòng
                </span>
                <span style="margin: 0 8px; color: #718096;">|</span>
                <span style="font-size: 14px; color: #e2e8f0;">
                    Tạm tính: 
                    <strong style="color: #ffffff; font-size: 16px;">
                        <fmt:formatNumber value="${sessionScope.BOOKING_CART.grandTotal}" type="number" maxFractionDigits="0"/> đ
                    </strong>
                </span>
            </div>
            <div style="display: flex; gap: 12px; align-items: center;">
                <a href="${pageContext.request.contextPath}/customer/cart?action=view" 
                   style="background: #dd6b20; color: white; padding: 9px 18px; border-radius: 5px; text-decoration: none; font-size: 13px; font-weight: 700; transition: background 0.2s;"
                   onmouseover="this.style.background='#c05621'" onmouseout="this.style.background='#dd6b20'">
                    Kiểm Tra Giỏ & Xác Nhận Đặt
                </a>
            </div>
        </div>
    </div>
</c:if>

<!-- JAVASCRIPT BỘ LỌC CỘT TRÁI & SẮP XẾP TỨC THỜI -->
<script>
function applyFilters() {
    var keyword = document.getElementById("keywordFilter").value.trim().toLowerCase();
    
    // Lấy danh sách hạng phòng được tích
    var checkedTypes = [];
    document.querySelectorAll("input[name='typeCheckbox']:checked").forEach(function(cb) {
        checkedTypes.push(cb.value);
    });

    // Lấy danh sách mức giá được tích
    var checkedPrices = [];
    document.querySelectorAll("input[name='priceCheckbox']:checked").forEach(function(cb) {
        checkedPrices.push(cb.value);
    });

    // Lấy sức chứa
    var capacityEl = document.querySelector("input[name='capacityRadio']:checked");
    var minCapacity = capacityEl ? capacityEl.value : "all";

    var cards = document.querySelectorAll(".room-horizontal-card");
    var visibleCount = 0;

    cards.forEach(function(card) {
        var roomName = (card.getAttribute("data-room-name") || "").toLowerCase();
        var roomNumber = (card.getAttribute("data-room-number") || "").toLowerCase();
        var type = card.getAttribute("data-type") || "";
        var price = parseFloat(card.getAttribute("data-price") || 0);
        var capacity = parseInt(card.getAttribute("data-capacity") || 0, 10);

        var matchKeyword = (keyword === "" || roomName.indexOf(keyword) !== -1 || roomNumber.indexOf(keyword) !== -1);
        var matchType = (checkedTypes.length === 0 || checkedTypes.indexOf(type) !== -1);
        
        var matchPrice = true;
        if (checkedPrices.length > 0) {
            matchPrice = false;
            for (var i = 0; i < checkedPrices.length; i++) {
                var pKey = checkedPrices[i];
                if (pKey === "under_1m" && price < 1000000) matchPrice = true;
                if (pKey === "1m_2m" && price >= 1000000 && price <= 2000000) matchPrice = true;
                if (pKey === "2m_3m" && price > 2000000 && price <= 3000000) matchPrice = true;
                if (pKey === "over_3m" && price > 3000000) matchPrice = true;
            }
        }

        var matchCapacity = true;
        if (minCapacity === "1" && capacity < 1) matchCapacity = false;
        if (minCapacity === "2" && capacity < 2) matchCapacity = false;
        if (minCapacity === "3" && capacity < 3) matchCapacity = false;

        if (matchKeyword && matchType && matchPrice && matchCapacity) {
            card.style.display = "flex";
            visibleCount++;
        } else {
            card.style.display = "none";
        }
    });

    var countDisplay = document.getElementById("roomCountDisplay");
    if (countDisplay) {
        countDisplay.textContent = visibleCount;
    }

    var noMatch = document.getElementById("noMatchMessage");
    if (noMatch) {
        noMatch.style.display = (visibleCount === 0 && cards.length > 0) ? "block" : "none";
    }
}

function resetFilters() {
    var kw = document.getElementById("keywordFilter");
    if (kw) kw.value = "";
    document.querySelectorAll("input[name='typeCheckbox']").forEach(function(cb) { cb.checked = false; });
    document.querySelectorAll("input[name='priceCheckbox']").forEach(function(cb) { cb.checked = false; });
    var allCap = document.querySelector("input[name='capacityRadio'][value='all']");
    if (allCap) allCap.checked = true;
    applyFilters();
}

function sortRooms() {
    var sortVal = document.getElementById("sortSelect").value;
    var container = document.getElementById("roomContainer");
    if (!container) return;

    var cards = Array.from(container.querySelectorAll(".room-horizontal-card"));
    cards.sort(function(a, b) {
        var priceA = parseFloat(a.getAttribute("data-price") || 0);
        var priceB = parseFloat(b.getAttribute("data-price") || 0);
        var capA = parseInt(a.getAttribute("data-capacity") || 0, 10);
        var capB = parseInt(b.getAttribute("data-capacity") || 0, 10);

        if (sortVal === "price_asc") return priceA - priceB;
        if (sortVal === "price_desc") return priceB - priceA;
        if (sortVal === "capacity_desc") return capB - capA;
        return 0;
    });

    cards.forEach(function(card) {
        container.appendChild(card);
    });
}
</script>

<jsp:include page="/views/common/footer.jsp" />