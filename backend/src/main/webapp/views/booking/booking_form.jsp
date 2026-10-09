<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <jsp:include page="/views/common/header.jsp">
                <jsp:param name="title" value="Điền Thông Tin & Xác Nhận Đặt Phòng" />
            </jsp:include>
            <jsp:include page="/views/common/navbar.jsp" />

            <div class="container" style="max-width: 1100px; margin-top: 25px; margin-bottom: 90px;">

                <!-- Breadcrumb -->
                <div style="margin-bottom: 20px; font-size: 13px; color: #718096;">
                    <a href="${pageContext.request.contextPath}/customer/home"
                        style="color: #2b6cb0; text-decoration: none;">Trang Chủ</a>
                    <span style="margin: 0 8px;">/</span>
                    <a href="${pageContext.request.contextPath}/customer/search-rooms"
                        style="color: #2b6cb0; text-decoration: none;">Tìm Phòng</a>
                    <span style="margin: 0 8px;">/</span>
                    <span style="color: #2d3748; font-weight: 600;">Điền Thông Tin & Dịch Vụ Bổ Sung</span>
                </div>

                <!-- Thông báo lỗi (nếu có) -->
                <c:if test="${not empty errorMessage}">
                    <div
                        style="margin-bottom: 20px; background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; padding: 14px 18px; border-radius: 6px; font-size: 14px;">
                        <strong>Lỗi:</strong> ${errorMessage}
                    </div>
                </c:if>

                <c:choose>
                    <%-- TRƯỜNG HỢP 1: KHÁCH ĐANG CẤU HÌNH VÀ CHỌN DỊCH VỤ CHO MỘT PHÒNG CỤ THỂ --%>
                        <c:when test="${not empty currentRoom}">

                            <div
                                style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 22px 28px; box-shadow: 0 1px 4px rgba(0,0,0,0.05); margin-bottom: 25px;">
                                <div
                                    style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                                    <div>
                                        <span
                                            style="background: #1a365d; color: white; font-size: 11px; font-weight: 700; padding: 3px 8px; border-radius: 3px; text-transform: uppercase;">
                                            ${currentRoom.tenLoaiPhong}
                                        </span>
                                        <h1
                                            style="color: #1a365d; margin: 8px 0 4px 0; font-size: 24px; font-weight: 700;">
                                            Cấu Hình Phòng ${currentRoom.soPhong} & Dịch Vụ Kèm Theo
                                        </h1>
                                        <p style="color: #718096; margin: 0; font-size: 14px;">
                                            Thời gian lưu trú: từ <strong>${currentRoom.ngayNhan}</strong> đến
                                            <strong>${currentRoom.ngayTra}</strong>
                                            (${currentRoom.soDem} đêm)
                                        </p>
                                    </div>
                                    <div style="text-align: right;">
                                        <div style="font-size: 12px; color: #718096;">Tiền phòng cơ bản:</div>
                                        <div style="font-size: 24px; font-weight: 700; color: #dd6b20;">
                                            <fmt:formatNumber value="${currentRoom.tongTienDuKien}" type="number"
                                                maxFractionDigits="0" /> đ
                                        </div>
                                        <div style="font-size: 12px; color: #a0aec0;">(
                                            <fmt:formatNumber value="${currentRoom.donGia}" type="number"
                                                maxFractionDigits="0" /> đ x ${currentRoom.soDem} đêm)
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Form điền thông tin và dịch vụ -->
                            <form id="addRoomForm" action="${pageContext.request.contextPath}/customer/cart/add"
                                method="POST" onsubmit="handleFormSubmit(event)">
                                <input type="hidden" name="maPhong" value="${currentRoom.maPhong}">
                                <input type="hidden" name="roomId" value="${currentRoom.maPhong}">
                                <input type="hidden" name="checkIn"
                                    value="${not empty paramCheckIn ? paramCheckIn : currentRoom.ngayNhan}">
                                <input type="hidden" name="checkOut"
                                    value="${not empty paramCheckOut ? paramCheckOut : currentRoom.ngayTra}">
                                <input type="hidden" name="isAjax" value="true">

                                <!-- Lựa chọn dịch vụ bổ sung kèm theo phòng này -->
                                <div
                                    style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                                    <div
                                        style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #edf2f7; padding-bottom: 10px; margin-bottom: 18px;">
                                        <h3 style="color: #1a365d; font-size: 17px; margin: 0; font-weight: 700;">
                                            Thêm Dịch Vụ Kèm Theo Cho Phòng ${currentRoom.soPhong}
                                        </h3>
                                        <span style="font-size: 12px; color: #718096;">
                                            Tùy chọn - Có thể bỏ qua nếu bạn chỉ muốn thuê phòng
                                        </span>
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty activeServices}">
                                            <div style="overflow-x: auto;">
                                                <table style="width: 100%; border-collapse: collapse; font-size: 13px;">
                                                    <thead>
                                                        <tr
                                                            style="background: #f7fafc; border-bottom: 2px solid #edf2f7; text-align: left;">
                                                            <th style="padding: 12px; width: 60px; text-align: center;">
                                                                Chọn</th>
                                                            <th style="padding: 12px;">Tên Dịch Vụ</th>
                                                            <th style="padding: 12px; width: 140px; text-align: right;">
                                                                Đơn Giá</th>
                                                            <th
                                                                style="padding: 12px; width: 140px; text-align: center;">
                                                                Số Lượng</th>
                                                            <th style="padding: 12px; width: 150px; text-align: right;">
                                                                Thành Tiền</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="svc" items="${activeServices}">
                                                            <fmt:formatNumber var="rawDonGia" value="${svc.donGia}"
                                                                groupingUsed="false" maxFractionDigits="0" />
                                                            <tr style="border-bottom: 1px solid #edf2f7;"
                                                                id="row_${svc.maDichVu}">
                                                                <td style="padding: 12px; text-align: center;">
                                                                    <input type="checkbox"
                                                                        name="service_${svc.maDichVu}"
                                                                        value="${svc.maDichVu}" id="cb_${svc.maDichVu}"
                                                                        data-service-id="${svc.maDichVu}"
                                                                        data-unit-price="${rawDonGia}"
                                                                        onchange="toggleService(this)"
                                                                        style="width: 18px; height: 18px; cursor: pointer;">
                                                                </td>
                                                                <td style="padding: 12px;">
                                                                    <label for="cb_${svc.maDichVu}"
                                                                        style="font-weight: 600; color: #2d3748; cursor: pointer;">
                                                                        ${svc.tenDichVu}
                                                                    </label>
                                                                </td>
                                                                <td
                                                                    style="padding: 12px; text-align: right; color: #4a5568;">
                                                                    <fmt:formatNumber value="${svc.donGia}"
                                                                        type="number" maxFractionDigits="0" /> đ
                                                                </td>
                                                                <td style="padding: 12px; text-align: center;">
                                                                    <input type="number" name="qty_${svc.maDichVu}"
                                                                        id="qty_${svc.maDichVu}" value="1" min="1"
                                                                        max="20" disabled
                                                                        data-service-id="${svc.maDichVu}"
                                                                        data-unit-price="${rawDonGia}"
                                                                        onchange="updateServiceSubtotal(this)"
                                                                        style="width: 70px; padding: 6px; text-align: center; border: 1px solid #cbd5e0; border-radius: 4px; font-size: 13px;">
                                                                </td>
                                                                <td style="padding: 12px; text-align: right; font-weight: 700; color: #2d3748;"
                                                                    id="subtotal_${svc.maDichVu}">
                                                                    0 đ
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <p style="color: #a0aec0; margin: 0; font-size: 13px;">Hiện tại khách sạn
                                                chưa kích hoạt dịch vụ bổ sung nào.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Khối 3: Tóm tắt chi phí & Nút hành động chính -->
                                <div
                                    style="background: white; border-radius: 8px; border: 1px solid #d2d6dc; padding: 22px 28px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                                    <div>
                                        <div style="font-size: 13px; color: #718096;">
                                            Tiền phòng: <strong id="displayRoomPrice">
                                                <fmt:formatNumber value="${currentRoom.tongTienDuKien}" type="number"
                                                    maxFractionDigits="0" /> đ
                                            </strong>
                                            + Dịch vụ thêm: <strong id="displayServiceTotal">0 đ</strong>
                                        </div>
                                        <div
                                            style="font-size: 18px; font-weight: 700; color: #1a365d; margin-top: 4px;">
                                            Tổng Chi Phí Dự Kiến Phòng Này:
                                            <span id="displayGrandTotal"
                                                style="color: #dd6b20; font-size: 24px; margin-left: 8px;">
                                                <fmt:formatNumber value="${currentRoom.tongTienDuKien}" type="number"
                                                    maxFractionDigits="0" /> đ
                                            </span>
                                        </div>
                                    </div>

                                    <div style="display: flex; gap: 12px; align-items: center;">
                                        <a href="${pageContext.request.contextPath}/customer/room-detail?maPhong=${currentRoom.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                                            style="background: #edf2f7; color: #4a5568; padding: 12px 18px; border-radius: 5px; text-decoration: none; font-size: 14px; font-weight: 600;">
                                            Quay Lại Xem Phòng
                                        </a>

                                        <!-- Nút Thêm Vào Booking - Kích hoạt Modal Popup -->
                                        <button type="submit" id="submitBtn"
                                            style="background: #1a365d; color: white; border: none; padding: 12px 24px; border-radius: 5px; font-size: 15px; font-weight: 700; cursor: pointer; transition: background 0.2s;"
                                            onmouseover="this.style.background='#2a4365'"
                                            onmouseout="this.style.background='#1a365d'">
                                            Thêm Vào Booking
                                        </button>
                                    </div>
                                </div>
                            </form>

                        </c:when>

                        <%-- TRƯỜNG HỢP 2: MÀN HÌNH XEM LẠI TOÀN BỘ GIỎ HÀNG & CHỐT ĐẶT ĐƠN (CHECKOUT) --%>
                            <c:otherwise>

                                <div
                                    style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 22px 28px; box-shadow: 0 1px 4px rgba(0,0,0,0.05); margin-bottom: 25px;">
                                    <h1 style="color: #1a365d; margin: 0 0 6px 0; font-size: 24px; font-weight: 700;">
                                        Rà Soát Đơn Đặt Phòng & Xác Nhận Chốt Đơn
                                    </h1>
                                    <p style="color: #718096; margin: 0; font-size: 14px;">
                                        Dưới đây là toàn bộ danh sách phòng và các dịch vụ bạn đã chọn. Vui lòng kiểm
                                        tra kỹ trước khi bấm hoàn tất.
                                    </p>
                                </div>

                                <!-- Bảng chi tiết toàn bộ các phòng trong giỏ hàng -->
                                <div
                                    style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                                    <h3
                                        style="color: #1a365d; font-size: 17px; margin: 0 0 16px 0; font-weight: 700; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">
                                        Danh Sách Các Phòng Đã Chọn (${bookingCart.totalRoomCount} phòng)
                                    </h3>

                                    <c:forEach var="entry" items="${bookingCart.items}">
                                        <c:set var="item" value="${entry.value}" />
                                        <div
                                            style="background: #f7fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 18px; margin-bottom: 16px;">
                                            <div
                                                style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 15px;">
                                                <div>
                                                    <div style="font-size: 16px; font-weight: 700; color: #1a365d;">
                                                        Phòng ${item.soPhong} - ${item.tenLoaiPhong}
                                                    </div>
                                                    <div style="font-size: 13px; color: #718096; margin-top: 4px;">
                                                        Kỳ lưu trú: <strong>${item.ngayNhan}</strong> đến
                                                        <strong>${item.ngayTra}</strong> (${item.soDem} đêm)
                                                    </div>
                                                    <div style="font-size: 13px; color: #4a5568; margin-top: 4px;">
                                                        Tiền phòng:
                                                        <fmt:formatNumber value="${item.tienPhong}" type="number"
                                                            maxFractionDigits="0" /> đ
                                                        &bull; Tiền dịch vụ:
                                                        <fmt:formatNumber value="${item.tongTienDichVu}" type="number"
                                                            maxFractionDigits="0" /> đ
                                                    </div>

                                                    <c:if test="${not empty item.selectedServices}">
                                                        <div style="margin-top: 8px; font-size: 12px; color: #2b6cb0;">
                                                            <strong>Dịch vụ kèm:</strong>
                                                            <c:forEach var="s" items="${item.selectedServices}"
                                                                varStatus="loop">
                                                                ${s.tenDichVu} (x${s.soLuong})<c:if
                                                                    test="${!loop.last}">, </c:if>
                                                            </c:forEach>
                                                        </div>
                                                    </c:if>
                                                </div>

                                                <div style="text-align: right;">
                                                    <div style="font-size: 18px; font-weight: 700; color: #dd6b20;">
                                                        <fmt:formatNumber value="${item.tongTienPhongVaDichVu}"
                                                            type="number" maxFractionDigits="0" /> đ
                                                    </div>
                                                    <form
                                                        action="${pageContext.request.contextPath}/customer/cart/remove"
                                                        method="POST" style="margin-top: 8px;">
                                                        <input type="hidden" name="roomId" value="${item.maPhong}">
                                                        <button type="submit"
                                                            style="background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; padding: 4px 10px; border-radius: 4px; font-size: 12px; cursor: pointer;">
                                                            Xóa Khỏi Giỏ
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>

                                    <div
                                        style="text-align: right; border-top: 1px dashed #cbd5e0; padding-top: 16px; margin-top: 10px;">
                                        <div style="font-size: 15px; color: #718096;">Tổng Cộng Toàn Bộ Đơn Hàng:</div>
                                        <div
                                            style="font-size: 28px; font-weight: 700; color: #dd6b20; margin-top: 2px;">
                                            <fmt:formatNumber value="${bookingCart.grandTotal}" type="number"
                                                maxFractionDigits="0" /> đ
                                        </div>
                                    </div>
                                </div>

                                <!-- Form xác nhận chốt đơn -->
                                <form action="${pageContext.request.contextPath}/customer/booking" method="POST">
                                    <!-- Khối thông tin khách hàng lưu trú đại diện (Xác minh hồ sơ theo CCCD) -->
                                    <div
                                        style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                                        <div
                                            style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #edf2f7; padding-bottom: 10px; margin-bottom: 18px;">
                                            <h3 style="color: #1a365d; font-size: 17px; margin: 0; font-weight: 700;">
                                                Thông Tin Khách Hàng Lưu Trú (Đại Diện Nhận Phòng)
                                            </h3>
                                            <c:choose>
                                                <c:when test="${not empty savedGuest.cccd || not empty sessionScope.SAVED_CCCD}">
                                                    <span
                                                        style="font-size: 12px; color: #276749; background: #f0fff4; border: 1px solid #9ae6b4; padding: 3px 10px; border-radius: 4px; font-weight: 600;">
                                                        ✓ Đã tự động điền từ hồ sơ lưu trú
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span
                                                        style="font-size: 12px; color: #718096; background: #edf2f7; border: 1px solid #cbd5e0; padding: 3px 10px; border-radius: 4px;">
                                                        Nhập 1 lần duy nhất - Hệ thống sẽ tự động lưu lại
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div
                                            style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px;">
                                            <div>
                                                <label
                                                    style="display: block; font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 6px;">
                                                    Họ và Tên Khách Hàng: <span style="color: #e53e3e;">*</span>
                                                </label>
                                                <input type="text" name="customerName"
                                                    value="${not empty savedGuest.hoTen ? savedGuest.hoTen : (not empty sessionScope.CURRENT_USER.hoTen ? sessionScope.CURRENT_USER.hoTen : sessionScope.CURRENT_USER.hoTenTaiKhoan)}" required
                                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 14px; box-sizing: border-box;">
                                            </div>

                                            <div>
                                                <label
                                                    style="display: block; font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 6px;">
                                                    Số Điện Thoại Liên Hệ: <span style="color: #e53e3e;">*</span>
                                                </label>
                                                <input type="text" name="customerPhone"
                                                    value="${not empty savedGuest.soDT ? savedGuest.soDT : sessionScope.CURRENT_USER.soDT}" required
                                                    placeholder="Ví dụ: 0901234567"
                                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 14px; box-sizing: border-box;">
                                            </div>

                                            <div>
                                                <label
                                                    style="display: block; font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 6px;">
                                                    Địa Chỉ Email: <span style="color: #e53e3e;">*</span>
                                                </label>
                                                <input type="email" name="customerEmail"
                                                    value="${not empty savedGuest.email ? savedGuest.email : sessionScope.CURRENT_USER.email}" required
                                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 14px; box-sizing: border-box;">
                                            </div>

                                            <div>
                                                <label
                                                    style="display: block; font-size: 13px; font-weight: 700; color: #2d3748; margin-bottom: 6px;">
                                                    Số CCCD Người Lưu Trú (12 chữ số): <span style="color: #e53e3e;">*</span>
                                                </label>
                                                <input type="text" name="customerCccd" required pattern="[0-9]{12}" maxlength="12"
                                                    value="${not empty savedGuest.cccd ? savedGuest.cccd : sessionScope.SAVED_CCCD}"
                                                    placeholder="Ví dụ: 001202001234 (12 số)"
                                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 14px; box-sizing: border-box;">
                                            </div>
                                        </div>
                                    </div>

                                    <div
                                        style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                                        <h3
                                            style="color: #1a365d; font-size: 17px; margin: 0 0 14px 0; font-weight: 700; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">
                                            Ghi Chú Chung Cho Đơn Đặt Phòng
                                        </h3>
                                        <textarea name="note" rows="3"
                                            placeholder="Nhập ghi chú chung cho toàn bộ chuyến đi nếu có..."
                                            style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; box-sizing: border-box;"></textarea>
                                    </div>

                                    <div
                                        style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                                        <a href="${pageContext.request.contextPath}/customer/search-rooms"
                                            style="background: #edf2f7; color: #4a5568; padding: 12px 20px; border-radius: 5px; text-decoration: none; font-size: 14px; font-weight: 600;">
                                            + Đặt Thêm Phòng Khác
                                        </a>

                                        <button type="submit"
                                            style="background: #dd6b20; color: white; border: none; padding: 14px 28px; border-radius: 5px; font-size: 16px; font-weight: 700; cursor: pointer; transition: background 0.2s;"
                                            onmouseover="this.style.background='#c05621'"
                                            onmouseout="this.style.background='#dd6b20'">
                                            Xác Nhận Đặt Toàn Bộ Đơn Phòng
                                        </button>
                                    </div>
                                </form>

                            </c:otherwise>
                </c:choose>

            </div>

            <!-- CỬA SỔ NHỎ / POPUP MODAL TÓM TẮT & LỰA CHỌN NGHIỆP VỤ (BƯỚC 5) -->
            <div id="bookingPopupModal"
                style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.55); z-index: 9999; align-items: center; justify-content: center;">
                <div
                    style="background: white; border-radius: 10px; width: 90%; max-width: 550px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.25); animation: modalFadeIn 0.25s ease-out;">

                    <!-- Header modal -->
                    <div
                        style="background: #1a365d; color: white; padding: 18px 24px; display: flex; justify-content: space-between; align-items: center;">
                        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: #ffffff;">
                            Đã Thêm Phòng Vào Đơn Đặt Thành Công!
                        </h3>
                        <button type="button" onclick="closePopupModal()"
                            style="background: none; border: none; color: #cbd5e0; font-size: 20px; cursor: pointer; line-height: 1;">&times;</button>
                    </div>

                    <!-- Body modal -->
                    <div style="padding: 24px;" id="modalBodyContent">

                        <div
                            style="background: #f0fff4; border: 1px solid #9ae6b4; color: #276749; padding: 10px 14px; border-radius: 6px; font-size: 13px; font-weight: 600; margin-bottom: 16px;">
                            Phòng đã được lưu trữ an toàn trong giỏ hàng phiên làm việc của bạn.
                        </div>

                        <!-- Bảng tóm tắt phòng vừa thêm -->
                        <div
                            style="background: #f7fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 16px; margin-bottom: 18px; font-size: 13px; line-height: 1.8;">
                            <div style="display: flex; justify-content: space-between;">
                                <span style="color: #718096;">Phòng đã chọn:</span>
                                <strong id="modalRoomName" style="color: #1a365d;">Phòng ...</strong>
                            </div>
                            <div style="display: flex; justify-content: space-between;">
                                <span style="color: #718096;">Thời gian ở:</span>
                                <strong id="modalPeriod">...</strong>
                            </div>
                            <div style="display: flex; justify-content: space-between;">
                                <span style="color: #718096;">Tiền phòng:</span>
                                <span id="modalRoomPrice">0 đ</span>
                            </div>
                            <div style="display: flex; justify-content: space-between;">
                                <span style="color: #718096;">Dịch vụ bổ sung:</span>
                                <span id="modalServicePrice">0 đ</span>
                            </div>
                            <div
                                style="border-top: 1px dashed #cbd5e0; margin-top: 8px; padding-top: 8px; display: flex; justify-content: space-between; font-size: 15px; font-weight: 700; color: #1a365d;">
                                <span>Tổng phòng này:</span>
                                <span id="modalRoomTotal" style="color: #dd6b20;">0 đ</span>
                            </div>
                        </div>

                        <!-- Tình trạng giỏ hàng tổng thể -->
                        <div style="font-size: 13px; color: #4a5568; margin-bottom: 22px; text-align: center;">
                            Đơn booking của bạn hiện đang có <strong id="modalCartRooms">1 phòng</strong>.
                            <br>Tổng tiền tạm tính toàn bộ đơn: <strong id="modalGrandTotal"
                                style="color: #1a365d; font-size: 15px;">0 đ</strong>
                        </div>

                        <!-- 2 LỰA CHỌN NGHIỆP VỤ -->
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                            <!-- Nút 1: Quay lại đặt tiếp -->
                            <a id="modalContinueBtn" href="${pageContext.request.contextPath}/customer/search-rooms"
                                style="display: block; text-align: center; background: #ffffff; color: #1a365d; border: 2px solid #1a365d; padding: 11px 14px; border-radius: 6px; font-size: 13px; font-weight: 700; text-decoration: none; transition: all 0.2s;"
                                onmouseover="this.style.background='#f7fafc'"
                                onmouseout="this.style.background='#ffffff'">
                                Quay Lại Đặt Tiếp
                            </a>

                            <!-- Nút 2: Xác nhận đặt booking -->
                            <a id="modalCheckoutBtn" href="${pageContext.request.contextPath}/customer/booking"
                                style="display: block; text-align: center; background: #dd6b20; color: white; border: none; padding: 12px 14px; border-radius: 6px; font-size: 13px; font-weight: 700; text-decoration: none; transition: background 0.2s;"
                                onmouseover="this.style.background='#c05621'"
                                onmouseout="this.style.background='#dd6b20'">
                                Xác Nhận Đặt Booking
                            </a>
                        </div>

                    </div>

                </div>
            </div>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/booking/booking_form.css">

            <fmt:formatNumber var="rawBasePrice" value="${not empty currentRoom ? currentRoom.tongTienDuKien : 0}"
                groupingUsed="false" maxFractionDigits="0" />
            <!-- JAVASCRIPT TÍNH TOÁN DỊCH VỤ & XỬ LÝ POPUP MODAL -->
            <script>
                window.CONTEXT_PATH = '${pageContext.request.contextPath}';
                window.BASE_ROOM_PRICE = parseFloat('${not empty rawBasePrice ? rawBasePrice : 0}') || 0;
            </script>
            <script src="${pageContext.request.contextPath}/assets/js/booking/booking_form.js"></script>

            <jsp:include page="/views/common/footer.jsp" />