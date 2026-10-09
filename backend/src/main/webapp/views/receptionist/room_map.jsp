<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <jsp:include page="/views/common/header.jsp">
            <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Sơ Đồ Phòng Timeline" />
        </jsp:include>
        <jsp:include page="/views/common/navbar.jsp" />

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/receptionist/room_map.css">

        <div class="pms-container">
            <!-- TIÊU ĐỀ BÀN LÀM VIỆC LỄ TÂN -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <div>
                    <h2 style="color: #0f172a; margin: 0; font-size: 22px; font-weight: 800;">BÀN LÀM VIỆC LỄ TÂN - SƠ
                        ĐỒ PHÒNG TIMELINE</h2>
                    <p style="color: #64748b; margin: 4px 0 0 0; font-size: 13px;">Hệ thống Quản lý Đặt phòng &amp; Tiếp
                        đón Khách hàng thời gian thực</p>
                </div>
                <div style="display: flex; gap: 10px;">
                    <a href="${pageContext.request.contextPath}/receptionist/checkin"
                        class="pms-btn pms-btn-success" style="text-decoration: none;">[ Quầy Tiếp Đón Check-in ]</a>
                    <a href="${pageContext.request.contextPath}/receptionist/booking"
                        class="pms-btn pms-btn-primary" style="text-decoration: none;">[ Đặt phòng mới ]</a>
                    <a href="${pageContext.request.contextPath}/receptionist/room-map?startDate=${startDate}"
                        class="pms-btn pms-btn-secondary">[ Tải lại sơ đồ ]</a>
                </div>
            </div>

            <!-- MAIN PMS CARD -->
            <div class="pms-card">
                <!-- BỘ LỌC TÌM KIẾM VÀ ĐIỀU HƯỚNG -->
                <div class="filter-toolbar">
                    <div class="filter-group">
                        <input type="text" id="filterKeyword" class="pms-input"
                            placeholder="Tìm tên khách, SĐT, số phòng, mã BK..." style="width: 260px;"
                            oninput="applyFilter()">
                        <select id="filterFloor" class="pms-select" onchange="applyFilter()">
                            <option value="ALL">Tất cả các tầng</option>
                            <option value="T1">Tầng 1</option>
                            <option value="T2">Tầng 2</option>
                            <option value="T3">Tầng 3</option>
                            <option value="T4">Tầng 4</option>
                        </select>
                        <select id="filterStatus" class="pms-select" onchange="applyFilter()">
                            <option value="ALL">Tất cả trạng thái buồng</option>
                            <option value="Available">Đã dọn sạch</option>
                            <option value="Occupied">Đang có khách</option>
                            <option value="Dirty">Bẩn chờ dọn</option>
                            <option value="Cleaning">Đang dọn dẹp</option>
                            <option value="Damaged">Bảo trì</option>
                            <option value="Booked">Đã giữ chỗ</option>
                        </select>
                        <button type="button" class="pms-btn pms-btn-secondary" onclick="resetFilter()">[ Đặt lại
                            ]</button>
                    </div>
                    <div class="filter-group">
                        <a href="${pageContext.request.contextPath}/receptionist/room-map?startDate=${prevWeek}"
                            class="pms-btn pms-btn-secondary">[ &lt; Tuần trước ]</a>
                        <strong style="font-size: 13px; color: #1e293b;">Tuần: ${not empty formattedWeek ? formattedWeek : '29/09/2026 - 05/10/2026'}</strong>
                        <a href="${pageContext.request.contextPath}/receptionist/room-map?startDate=${nextWeek}"
                            class="pms-btn pms-btn-secondary">[ Tuần sau &gt; ]</a>
                    </div>
                </div>

                <!-- 3. CHÚ GIẢI MÀU SẮC DẢI ĐẶT PHÒNG -->
                <div class="legend-bar">
                    <strong>Chú thích dải đặt phòng:</strong>
                    <span class="legend-tag"><span class="legend-box bar-confirmed"></span> [ Thanh Xanh Lá ]: Đặt trước
                        chờ nhận</span>
                    <span class="legend-tag"><span class="legend-box bar-occupied"></span> [ Thanh Đỏ ]: Đang lưu trú
                        tại phòng</span>
                    <span class="legend-tag"><span class="legend-box bar-checkout-today"></span> [ Thanh Cam ]: Trả
                        phòng hôm nay</span>
                    <span class="legend-tag"><span class="legend-box"
                            style="border: 1px solid #cbd5e1; background: #fff;"></span> [ Ô Trắng ]: Phòng trống sẵn
                        sàng</span>
                </div>

                <!-- 4. LƯỚI MA TRẬN TIMELINE GANTT -->
                <div class="timeline-wrapper">
                    <table class="timeline-table">
                        <thead>
                            <tr>
                                <th class="room-col-header">PHÒNG &amp; LOẠI PHÒNG</th>
                                <th class="status-col-header">TRẠNG THÁI</th>
                                <c:choose>
                                    <c:when test="${not empty dayHeaders}">
                                        <c:forEach items="${dayHeaders}" var="dh">
                                            <th class="day-col-header">${dh}</th>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <th class="day-col-header">Thứ 2</th>
                                        <th class="day-col-header">Thứ 3</th>
                                        <th class="day-col-header">Thứ 4</th>
                                        <th class="day-col-header">Thứ 5</th>
                                        <th class="day-col-header">Thứ 6</th>
                                        <th class="day-col-header">Thứ 7</th>
                                        <th class="day-col-header">Chủ Nhật</th>
                                    </c:otherwise>
                                </c:choose>
                            </tr>
                        </thead>
                        <tbody id="timelineBody">
                            <c:set var="prevFloor" value="0" />
                            <c:forEach items="${roomList}" var="r">
                                <c:if test="${r.soTang ne prevFloor}">
                                    <c:set var="prevFloor" value="${r.soTang}" />
                                    <tr class="floor-row" data-floor="T${r.soTang}">
                                        <td colspan="9">-- TẦNG ${r.soTang} --</td>
                                    </tr>
                                </c:if>
                                <tr class="room-row" data-floor="T${r.soTang}" data-status="${r.trangThaiPhong}"
                                    data-room="${r.maPhong}">
                                    <td class="room-cell-info">
                                        <div style="margin-bottom: 3px;">
                                            <span style="font-size: 13px; font-weight: 800; color: #0f172a;">Phòng ${r.soPhong}</span>
                                        </div>
                                        <div>
                                            <span style="font-size: 11px; color: #64748b;">${r.tenLoaiPhong}</span>
                                        </div>
                                    </td>
                                    <td style="text-align: center; vertical-align: middle; padding: 6px;">
                                        <span class="${r.trangThaiCssClass}"
                                            style="font-size: 10px; padding: 3px 8px; border-radius: 4px; display: inline-block;">
                                            ${r.trangThaiBadgeText}
                                        </span>
                                    </td>
                                    <c:forEach var="dayIdx" begin="1" end="7">
                                        <td class="timeline-grid-cell" data-day="${dayIdx}">
                                            <c:forEach items="${r.bookingBars}" var="bar">
                                                <c:if test="${bar.startCol eq dayIdx}">
                                                    <div class="booking-bar ${bar.cssClass} span-${bar.colSpan}"
                                                        style="left: 12px; z-index: 10;"
                                                        title="[${bar.maBooking}] ${bar.tenKhachHang} (${bar.trangThaiBooking eq 'DaCheckIn' ? 'Đang lưu trú' : 'Đã xác nhận'})"
                                                        onclick="handleBookingBarClick('${r.maPhong}', '${r.soPhong}', '${bar.maBooking}', '${bar.tenKhachHang}', '${bar.soDienThoai}', '${bar.soCccd}', '${bar.trangThaiBooking}', '${bar.ngayNhanDuKien}', '${bar.ngayTraDuKien}', '${bar.formattedNgayCheckInThucTe}', '${bar.formattedNgayCheckOutThucTe}')">
                                                        ${bar.tenKhachHang}
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                        </td>
                                    </c:forEach>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty roomList}">
                                <tr>
                                    <td colspan="9" style="text-align: center; padding: 30px; color: #64748b;">Chưa có dữ liệu phòng nào trong hệ thống.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========================================================================= -->
        <!-- POPUP MODAL NỔI TRUNG TÂM THỐNG NHẤT: THÔNG TIN BOOKING & PHÒNG          -->
        <!-- ========================================================================= -->
        <div id="bookingModal" class="pms-modal-backdrop">
            <div class="pms-modal-card">
                <div class="modal-head" id="bookingModalHead">
                    <h3 id="bookingModalTitle">THÔNG TIN CHI TIẾT ĐẶT PHÒNG</h3>
                    <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;"
                        onclick="closeModal('bookingModal')">[ Đóng ]</button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="bmRoomIdVal" value="">
                    <input type="hidden" id="bmRoomNoVal" value="">
                    <input type="hidden" id="bmBookingIdVal" value="">
                    <div class="detail-grid">
                        <div>Mã Booking: <strong id="bmBookingId">--</strong></div>
                        <div>Phòng bàn giao: <strong id="bmRoomId" style="color: #15803d;">--</strong></div>
                        <div>Khách đại diện: <strong id="bmGuestName">--</strong></div>
                        <div>Số điện thoại: <span id="bmPhone">--</span></div>
                        <div style="grid-column: span 2;">Số CCCD: <span id="bmCccd">--</span></div>
                        <div>Ngày nhận dự kiến: <strong id="bmInDate">--</strong></div>
                        <div>Ngày trả dự kiến: <strong id="bmOutDate">--</strong></div>
                        <div>Ngày nhận thực tế: <strong id="bmActualIn" style="color: #15803d;">___</strong></div>
                        <div>Ngày trả thực tế: <strong id="bmActualOut" style="color: #64748b;">___</strong></div>
                    </div>

                    <!-- DỊCH VỤ PHÁT SINH & THANH TOÁN (Chỉ hiển thị khi phòng Đang lưu trú) -->
                    <div id="occupiedArea">
                        <div style="font-weight: 700; color: #0f172a; margin-bottom: 6px;">DANH SÁCH DỊCH VỤ PHÁT SINH TẠI PHÒNG:</div>
                        <table class="svc-table" id="usedServiceTable">
                            <thead>
                                <tr>
                                    <th>Tên Dịch Vụ</th>
                                    <th style="width: 60px; text-align: center;">SL</th>
                                    <th style="width: 100px; text-align: right;">Đơn Giá</th>
                                    <th style="width: 110px; text-align: right;">Thành Tiền</th>
                                </tr>
                            </thead>
                            <tbody id="usedServiceList">
                                <tr>
                                    <td colspan="4" style="text-align: center; color: #94a3b8; font-style: italic;">Chưa có dịch vụ phát sinh nào cho phòng này.</td>
                                </tr>
                            </tbody>
                        </table>
                        <div style="text-align: right; font-size: 13px; margin-top: 8px;">
                            Tổng tiền dịch vụ: <strong style="color: #b91c1c;" id="totalServiceCost">0 đ</strong>
                        </div>

                        <div
                            style="margin-top: 15px; padding: 12px; background: #eff6ff; border-radius: 6px; border: 1px solid #bfdbfe;">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                                <span>Tiền phòng lưu trú:</span>
                                <strong id="dtlRoomCost">Tính theo biểu phí phòng</strong>
                            </div>
                            <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                                <span>Tiền dịch vụ phát sinh:</span>
                                <strong style="color: #b91c1c;" id="dtlServiceCostSummary">0 đ</strong>
                            </div>
                            <div style="border-top: 1px dashed #bfdbfe; margin: 8px 0;"></div>
                            <div style="display: flex; justify-content: space-between; font-size: 14px;">
                                <strong>Tổng thanh toán dự kiến khi Check-out:</strong>
                                <strong style="color: #1e3a8a;" id="finalBalance">Quyết toán khi trả phòng</strong>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-foot">
                    <a id="btnGoToCheckIn" href="#" class="pms-btn pms-btn-success" style="display: none; text-decoration: none;">[ Chuyển sang Quầy Check-in ]</a>
                    <button type="button" id="btnOrderService" class="pms-btn pms-btn-primary" onclick="switchToOrderServiceModal()">[ Thêm dịch vụ phòng ]</button>
                    <button type="button" id="btnCheckOut" class="pms-btn pms-btn-danger"
                        onclick="goToCheckOutCashier()">[ Check-out trả phòng ]</button>
                    <button type="button" class="pms-btn pms-btn-secondary" onclick="closeModal('bookingModal')">[ Đóng ]</button>
                </div>
            </div>
        </div>

        <!-- ========================================================================= -->
        <!-- 3. POPUP MODAL NỔI TRUNG TÂM: GỌI THÊM ĐỒ ĂN / DỊCH VỤ TẠI PHÒNG           -->
        <!-- ========================================================================= -->
        <div id="orderServiceModal" class="pms-modal-backdrop">
            <div class="pms-modal-card">
                <div class="modal-head" style="background: #1e3a8a;">
                    <h3 id="modalOrderServiceTitle">GỌI THÊM ĐỒ UỐNG / DỊCH VỤ TẠI PHÒNG</h3>
                    <button type="button" class="pms-btn pms-btn-secondary" style="padding: 4px 10px; font-size: 11px;"
                        onclick="closeModal('orderServiceModal')">[ Đóng ]</button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="ordRoomId" value="">
                    <input type="hidden" id="ordBookingId" value="">

                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: 700; display: block; margin-bottom: 6px;">1. CHỌN MÓN / DỊCH VỤ CỤ
                            THỂ:</label>
                        <select id="serviceSelect" class="pms-select" style="width: 100%; padding: 10px;"
                            onchange="updatePriceCalculation()">
                            <option value="DV05" data-price="30000" data-unit="Lon" selected>Nước uống Mini Bar (DV05) -
                                30.000 đ/Lon</option>
                            <option value="DV01" data-price="150000" data-unit="Suất">Ăn sáng Buffet (DV01) - 150.000
                                đ/Suất</option>
                            <option value="DV02" data-price="60000" data-unit="Bộ">Giặt ủi quần áo (DV02) - 60.000 đ/Bộ
                            </option>
                            <option value="DV03" data-price="350000" data-unit="Chuyến">Đưa đón sân bay (DV03) - 350.000
                                đ/Chuyến</option>
                            <option value="DV04" data-price="450000" data-unit="Lượt">Massage &amp; Spa Body (DV04) -
                                450.000 đ/Lượt</option>
                            <option value="DV06" data-price="180000" data-unit="Ngày">Thuê xe máy tự lái (DV06) -
                                180.000 đ/Ngày</option>
                        </select>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: 700; display: block; margin-bottom: 6px;">2. SỐ LƯỢNG:</label>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <button type="button" class="pms-btn pms-btn-secondary" onclick="adjustQty(-1)">[ Giảm
                                ]</button>
                            <input type="number" id="orderQty" class="pms-input" value="1" min="1" max="20"
                                style="width: 70px; text-align: center; font-weight: 700;"
                                onchange="updatePriceCalculation()">
                            <button type="button" class="pms-btn pms-btn-secondary" onclick="adjustQty(1)">[ Tăng
                                ]</button>
                            <span id="unitText" style="color: #64748b; font-weight: 600;">(Lon)</span>
                        </div>
                    </div>

                    <div
                        style="background: #f8fafc; border: 1px solid #cbd5e1; padding: 14px; border-radius: 6px; margin-bottom: 15px;">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-size: 13px; color: #475569;">Thành tiền tạm tính:</span>
                            <strong id="subtotalText" style="font-size: 18px; color: #1e3a8a;">30.000 đ</strong>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <label style="font-weight: 700; display: block; margin-bottom: 6px;">3. GHI CHÚ BỔ SUNG:</label>
                        <input type="text" id="orderNote" class="pms-input" style="width: 100%; box-sizing: border-box;"
                            placeholder="Ví dụ: Khách gọi từ điện thoại phòng, xin thêm 1 xô đá lạnh...">
                    </div>

                    <div style="color: #64748b; font-size: 12px;">
                        Lưu ý: Tiền dịch vụ sẽ tự động ghi vào CSDL và cộng dồn vào hóa đơn thanh toán khi trả phòng.
                    </div>
                </div>
                <div class="modal-foot">
                    <button type="button" class="pms-btn pms-btn-primary" onclick="saveServiceOrderReal()">[ Lưu dịch vụ
                        vào phòng ]</button>
                    <button type="button" class="pms-btn pms-btn-secondary" onclick="backToRoomDetail()">[ Quay lại
                        ]</button>
                </div>
            </div>
        </div>

        <script>
            window.CONTEXT_PATH = '${pageContext.request.contextPath}';
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/receptionist/room_map.js"></script>

        <jsp:include page="/views/common/footer.jsp" />