<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Sơ Đồ Lịch Phòng" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="receptionist/timeline.css" />
</jsp:include>

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái (Sidebar) -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="timeline" />
    </jsp:include>

    <!-- Màn hình bên phải (Workspace) -->
    <main class="portal-main">

        <!-- 1. THANH CÔNG CỤ ĐIỀU HƯỚNG VÀ BỘ LỌC (TOP TOOLBAR) -->
        <div class="timeline-toolbar">
            <div class="toolbar-left">
                <!-- Chuyển đổi chế độ xem: Lưới / Danh Sách -->
                <div class="view-switcher">
                    <span class="view-btn active">Lưới Timeline</span>
                    <a href="${pageContext.request.contextPath}/receptionist/room-map" class="view-btn"
                        title="Chuyển sang dạng danh sách truyền thống">Sơ Đồ Phòng</a>
                </div>

                <!-- Ô tìm kiếm nhanh khách hàng / số phòng / mã đặt phòng -->
                <div class="timeline-search-box">
                    <input type="text" id="timelineSearchInput" class="form-control"
                        placeholder="Tìm kiếm khách hàng, mã đặt phòng, số phòng..."
                        oninput="filterTimelineRows()" />
                </div>
            </div>

            <div class="toolbar-center">
                <!-- Bộ điều hướng tuần (Tuần trước / Tuần sau / Hôm nay) -->
                <div class="date-navigator">
                    <a href="${pageContext.request.contextPath}/receptionist/timeline?startDate=${prevWeek}"
                        class="btn btn-secondary btn-sm" title="Tuần trước">&larr;</a>
                    <span class="pill mono fw-bold">${formattedRange}</span>
                    <a href="${pageContext.request.contextPath}/receptionist/timeline?startDate=${nextWeek}"
                        class="btn btn-secondary btn-sm" title="Tuần sau">&rarr;</a>
                </div>
                <a href="${pageContext.request.contextPath}/receptionist/timeline?startDate=${todayDate}"
                    class="btn btn-primary btn-sm">Hôm Nay</a>
                <input type="date" value="${startDate}" onchange="changeStartDate(this.value)"
                    class="form-control" style="width: 140px; min-height: var(--control-h-sm);"
                    title="Chọn ngày bắt đầu tuần" />
            </div>

            <div class="toolbar-right">
                <a href="${pageContext.request.contextPath}/receptionist/booking" class="btn btn-primary btn-sm">
                    + Đặt Phòng Mới
                </a>
            </div>
        </div>

        <!-- 2. THANH CHÚ GIẢI TRẠNG THÁI (STATUS LEGEND) -->
        <div class="timeline-legend-bar">
            <span class="fw-bold text-secondary">Chú thích:</span>
            <div class="legend-item"><span class="badge badge-danger">Đang sử dụng (Đang ở)</span></div>
            <div class="legend-item"><span class="badge badge-info">Đã đặt trước (Giữ chỗ)</span></div>
            <div class="legend-item"><span class="badge badge-warning">Chờ xác nhận</span></div>
            <div class="legend-item"><span class="badge badge-success">Trống sẵn sàng</span></div>
            <div class="legend-item"><span class="badge badge-info">Đang dọn dẹp</span></div>
            <div class="legend-item"><span class="badge badge-neutral">Hư hại / Bảo trì</span></div>
        </div>

        <!-- 3. BẢNG LƯỚI THỜI GIAN BUỒNG PHÒNG (TIMELINE GRID TABLE) -->
        <div class="card card-flush">
            <div class="table-wrapper">
                <table class="timeline-table" id="timelineGridTable">
                    <thead>
                        <tr>
                            <th class="col-room-header">Phòng / Hạng</th>
                            <c:forEach items="${days}" var="d">
                                <th class="col-day-header ${d.today ? 'day-today' : ''}">
                                    <div class="day-num">${d.dayOfMonth}</div>
                                    <div class="day-name">${d.dayOfWeekName}</div>
                                    <c:if test="${d.today}">
                                        <span class="today-indicator">Hôm nay</span>
                                    </c:if>
                                </th>
                            </c:forEach>
                        </tr>
                    </thead>
                    <tbody>
                        <c:set var="prevFloor" value="0" />
                        <c:forEach items="${roomList}" var="r">
                            <c:if test="${r.soTang ne prevFloor}">
                                <c:set var="prevFloor" value="${r.soTang}" />
                                <tr class="floor-header-row" data-floor="T${r.soTang}">
                                </tr>
                            </c:if>

                            <tr class="room-timeline-row" data-floor="T${r.soTang}"
                                data-room="${r.soPhong}" data-roomtype="${r.tenLoaiPhong}"
                                id="roomRow_${r.maPhong}">
                                <td class="room-cell-info">
                                    <div class="room-no">${r.soPhong}</div>
                                    <div class="room-type-sub" title="${r.tenLoaiPhong}">
                                        ${r.tenLoaiPhong}</div>
                                </td>

                                <c:forEach items="${r.cells}" var="cell">
                                    <c:choose>
                                        <c:when test="${cell.barStart}">
                                            <td colspan="${cell.bookingBar.colSpan}"
                                                class="timeline-cell cell-booked"
                                                data-guest="${cell.bookingBar.tenKhachHang}"
                                                data-bookingid="${cell.bookingBar.maBooking}">
                                                <div class="booking-bar ${cell.bookingBar.cssClass}"
                                                    onclick="openBookingDetail('${cell.bookingBar.maBooking}', '${cell.bookingBar.cssClass}')"
                                                    title="Đơn: ${cell.bookingBar.maBooking} | Khách: ${cell.bookingBar.tenKhachHang} (${cell.bookingBar.soDienThoai}) | Nhận: ${cell.bookingBar.ngayNhanDuKien} - Trả: ${cell.bookingBar.ngayTraDuKien}">
                                                    <div class="bar-guest-name">
                                                        ${cell.bookingBar.tenKhachHang}
                                                    </div>
                                                    <div class="bar-booking-id">Mã:
                                                        ${cell.bookingBar.maBooking}</div>
                                                </div>
                                            </td>
                                        </c:when>

                                        <c:when test="${cell.barCovered}">
                                        </c:when>

                                        <c:otherwise>
                                            <td class="timeline-cell cell-empty ${cell.today ? 'cell-today' : ''}"
                                                onclick="bookEmptyRoom('${r.maPhong}', '${cell.dateStr}', '${cell.nextDateStr}')"
                                                title="Nhấp để đặt ngay phòng ${r.soPhong} từ ngày ${cell.displayDate}">
                                                <div class="empty-cell-btn">
                                                    <span>+</span> <span>Đặt</span>
                                                </div>
                                            </td>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<script>
    window.CONTEXT_PATH = '${pageContext.request.contextPath}';

    function bookEmptyRoom(maPhong, checkIn, checkOut) {
        window.location.href = window.CONTEXT_PATH + '/receptionist/booking?maPhong='
            + encodeURIComponent(maPhong) + '&checkIn=' + encodeURIComponent(checkIn)
            + '&checkOut=' + encodeURIComponent(checkOut);
    }

    function openBookingDetail(maBooking, cssClass) {
        if (cssClass && (cssClass.indexOf('checkedin') !== -1 || cssClass.indexOf('CheckedIn') !== -1)) {
            window.location.href = window.CONTEXT_PATH + '/cashier/booking-detail?maBooking=' + encodeURIComponent(maBooking);
        } else {
            window.location.href = window.CONTEXT_PATH + '/receptionist/checkin?keyword=' + encodeURIComponent(maBooking);
        }
    }

    function changeStartDate(newDate) {
        if (newDate && newDate.trim() !== '') {
            window.location.href = window.CONTEXT_PATH + '/receptionist/timeline?startDate=' + encodeURIComponent(newDate);
        }
    }

    function filterTimelineRows() {
        const input = document.getElementById('timelineSearchInput');
        const query = (input ? input.value : '').trim().toLowerCase();
        const rows = document.querySelectorAll('.room-timeline-row');

        rows.forEach(function (row) {
            const roomNo = (row.getAttribute('data-room') || '').toLowerCase();
            const roomType = (row.getAttribute('data-roomtype') || '').toLowerCase();

            const bookedCells = row.querySelectorAll('.cell-booked');
            let hasMatchedBooking = false;
            bookedCells.forEach(function (cell) {
                const guest = (cell.getAttribute('data-guest') || '').toLowerCase();
                const bId = (cell.getAttribute('data-bookingid') || '').toLowerCase();
                if (guest.includes(query) || bId.includes(query)) {
                    hasMatchedBooking = true;
                }
            });

            if (query === '' || roomNo.includes(query) || roomType.includes(query) || hasMatchedBooking) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    }
</script>

<jsp:include page="/views/common/footer.jsp" />