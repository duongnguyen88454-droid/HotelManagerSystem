<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <jsp:include page="/views/common/header.jsp">
                <jsp:param name="title" value="Cổng Khách Hàng - Trang Chủ Khách Sạn" />
            </jsp:include>
            <jsp:include page="/views/common/navbar.jsp" />

            <div class="container" style="max-width: 1200px; margin-top: 25px; margin-bottom: 90px;">

                <!-- Banner chào mừng thương hiệu sang trọng -->
                <div
                    style="background: linear-gradient(135deg, #1a365d 0%, #2a4365 100%); color: white; padding: 36px 40px; border-radius: 10px; box-shadow: 0 4px 16px rgba(0,0,0,0.08); margin-bottom: 30px;">
                    <div
                        style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">
                        <div style="max-width: 750px;">
                            <span
                                style="background: rgba(197, 168, 128, 0.25); color: #feebc8; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 4px; text-transform: uppercase; letter-spacing: 1px;">
                                Hệ Thống Nghỉ Dưỡng & Khách Sạn Cao Cấp
                            </span>
                            <h1
                                style="color: #ffffff; margin: 12px 0 8px 0; font-size: 28px; font-weight: 700; line-height: 1.3;">
                                Kính Chào Quý Khách, ${sessionScope.CURRENT_USER.hoTen}!
                            </h1>
                            <p style="color: #e2e8f0; margin: 0; font-size: 15px; line-height: 1.6;">
                                Trải nghiệm kỳ nghỉ dưỡng đẳng cấp với không gian sang trọng, dịch vụ chuyên nghiệp và
                                tiện nghi hiện đại bậc nhất. Vui lòng nhập tiêu chí lưu trú bên dưới để tìm kiếm và đặt
                                phòng ưng ý.
                            </p>
                        </div>
                        <div
                            style="background: rgba(255,255,255,0.08); padding: 16px 24px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.18); text-align: right; min-width: 220px;">
                            <div style="font-size: 12px; color: #cbd5e0; margin-bottom: 2px;">Tài khoản hội viên:</div>
                            <div style="font-size: 18px; font-weight: 700; color: #fbd38d;">
                                ${sessionScope.CURRENT_USER.maDinhDanh}</div>
                            <div style="margin-top: 8px;">
                                <a href="${pageContext.request.contextPath}/customer/history"
                                    style="color: #ffffff; text-decoration: underline; font-size: 13px; font-weight: 500;">
                                    Lịch sử đơn đặt phòng
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Thanh tìm kiếm phòng trung tâm (Search Bar) -->
                <div
                    style="background: white; border-radius: 10px; border: 1px solid #d2d6dc; padding: 26px 28px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 40px;">
                    <div style="margin-bottom: 18px; border-bottom: 1px solid #edf2f7; padding-bottom: 12px;">
                        <h2 style="color: #1a365d; margin: 0; font-size: 18px; font-weight: 700;">
                            Tìm Kiếm Phòng Nghỉ Phù Hợp
                        </h2>
                        <p style="font-size: 13px; color: #718096; margin: 4px 0 0 0;">
                            Lựa chọn thời gian nhận - trả phòng và số lượng khách để khám phá các phòng khả dụng tốt
                            nhất.
                        </p>
                    </div>

                    <form action="${pageContext.request.contextPath}/customer/search-rooms" method="GET">
                        <div
                            style="display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 18px; align-items: end;">

                            <!-- Ngày nhận phòng -->
                            <div>
                                <label for="checkInInput"
                                    style="display: block; font-weight: 600; color: #2d3748; margin-bottom: 7px; font-size: 13px;">
                                    Ngày Nhận Phòng:
                                </label>
                                <input type="date" id="checkInInput" name="checkIn" value="${paramCheckIn}" required
                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; color: #2d3748; box-sizing: border-box;">
                            </div>

                            <!-- Ngày trả phòng -->
                            <div>
                                <label for="checkOutInput"
                                    style="display: block; font-weight: 600; color: #2d3748; margin-bottom: 7px; font-size: 13px;">
                                    Ngày Trả Phòng:
                                </label>
                                <input type="date" id="checkOutInput" name="checkOut" value="${paramCheckOut}" required
                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; color: #2d3748; box-sizing: border-box;">
                            </div>

                            <!-- Số lượng khách -->
                            <div>
                                <label for="guestsSelect"
                                    style="display: block; font-weight: 600; color: #2d3748; margin-bottom: 7px; font-size: 13px;">
                                    Số Lượng Khách:
                                </label>
                                <select id="guestsSelect" name="guests"
                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; background: white; color: #2d3748; box-sizing: border-box;">
                                    <option value="">Tất cả sức chứa</option>
                                    <option value="1">1 người</option>
                                    <option value="2">2 người</option>
                                    <option value="3">3 người</option>
                                    <option value="4">4 người</option>
                                </select>
                            </div>

                            <!-- Hạng phòng -->
                            <div>
                                <label for="roomTypeSelect"
                                    style="display: block; font-weight: 600; color: #2d3748; margin-bottom: 7px; font-size: 13px;">
                                    Hạng Phòng Nghỉ:
                                </label>
                                <select id="roomTypeSelect" name="roomType"
                                    style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e0; border-radius: 6px; font-size: 14px; background: white; color: #2d3748; box-sizing: border-box;">
                                    <option value="ALL">Tất cả hạng phòng</option>
                                    <c:forEach var="rt" items="${roomTypes}">
                                        <option value="${rt.maLoaiPhong}">${rt.tenLoaiPhong} (tối đa ${rt.soNguoiToiDa}
                                            người)</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Nút tìm kiếm phòng nổi bật -->
                            <div>
                                <button type="submit"
                                    style="width: 100%; background: #dd6b20; color: white; border: none; padding: 11px 18px; font-size: 14px; font-weight: 700; border-radius: 6px; cursor: pointer; transition: background 0.2s;"
                                    onmouseover="this.style.background='#c05621'"
                                    onmouseout="this.style.background='#dd6b20'">
                                    Tìm Kiếm Phòng
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Giới thiệu không gian nghỉ dưỡng & dịch vụ tiêu chuẩn 5 sao -->
                <div style="margin-bottom: 40px;">
                    <div style="text-align: center; margin-bottom: 30px;">
                        <span
                            style="color: #c5a880; font-weight: 700; font-size: 12px; text-transform: uppercase; letter-spacing: 1.5px;">
                            Tiêu Chuẩn Dịch Vụ
                        </span>
                        <h2 style="color: #1a365d; margin: 6px 0 10px 0; font-size: 24px; font-weight: 700;">
                            Trải Nghiệm Nghỉ Dưỡng Hoàn Hảo
                        </h2>
                        <p style="color: #718096; max-width: 700px; margin: 0 auto; font-size: 14px; line-height: 1.6;">
                            Chúng tôi mang đến hệ thống phòng nghỉ thanh lịch, kiến trúc giao thoa giữa nét cổ điển và
                            hiện đại, cùng chuỗi tiện ích đẳng cấp phục vụ trọn vẹn mọi nhu cầu lưu trú của quý khách.
                        </p>
                    </div>

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 24px;">

                        <!-- Thẻ tiện ích 1 -->
                        <div
                            style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
                            <div
                                style="font-size: 12px; font-weight: 700; color: #c5a880; text-transform: uppercase; margin-bottom: 6px;">
                                Không Gian Lưu Trú
                            </div>
                            <h3 style="color: #1a365d; font-size: 17px; margin: 0 0 10px 0; font-weight: 700;">
                                Phòng Nghỉ Sang Trọng & Tiện Nghi
                            </h3>
                            <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0;">
                                Toàn bộ phòng nghỉ đều được trang bị giường đệm cao cấp, ban công thoáng đãng với view
                                biển hoặc thành phố, phòng tắm đứng hoặc bồn tắm nằm cao cấp cùng hệ thống điều hòa và
                                Wifi tốc độ cao.
                            </p>
                        </div>

                        <!-- Thẻ tiện ích 2 -->
                        <div
                            style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
                            <div
                                style="font-size: 12px; font-weight: 700; color: #c5a880; text-transform: uppercase; margin-bottom: 6px;">
                                Ẩm Thực Thượng Hạng
                            </div>
                            <h3 style="color: #1a365d; font-size: 17px; margin: 0 0 10px 0; font-weight: 700;">
                                Buffet Sáng & Thực Đơn Á - Âu
                            </h3>
                            <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0;">
                                Thưởng thức bữa sáng tự chọn phong phú tại nhà hàng trung tâm với nguyên liệu tươi ngon
                                chọn lọc mỗi ngày. Hỗ trợ đặt kèm suất buffet sáng ngay trong quá trình đặt phòng thuận
                                tiện.
                            </p>
                        </div>

                        <!-- Thẻ tiện ích 3 -->
                        <div
                            style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
                            <div
                                style="font-size: 12px; font-weight: 700; color: #c5a880; text-transform: uppercase; margin-bottom: 6px;">
                                Dịch Vụ Chu Đáo
                            </div>
                            <h3 style="color: #1a365d; font-size: 17px; margin: 0 0 10px 0; font-weight: 700;">
                                Đưa Đón Sân Bay & Giặt Ủi
                            </h3>
                            <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0;">
                                Đội ngũ lễ tân và hỗ trợ trực 24/7. Cung cấp dịch vụ xe đón tiễn sân bay an toàn, dịch
                                vụ giặt ủi lấy nhanh và hỗ trợ tư vấn các chương trình tham quan địa phương chu đáo.
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Thanh giỏ hàng nổi cố định ở chân trang (Bottom Sticky Bar) nếu trong giỏ đã có phòng -->
            <c:if test="${not empty sessionScope.BOOKING_CART and sessionScope.BOOKING_CART.totalRoomCount > 0}">
                <div
                    style="position: fixed; bottom: 0; left: 0; right: 0; background: #1a365d; color: white; padding: 14px 24px; box-shadow: 0 -4px 16px rgba(0,0,0,0.18); z-index: 1000; border-top: 2px solid #c5a880;">
                    <div
                        style="max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                        <div>
                            <span style="font-size: 15px; font-weight: 700; color: #fbd38d;">
                                Đơn đặt phòng đang chọn: ${sessionScope.BOOKING_CART.totalRoomCount} phòng
                            </span>
                            <span style="margin: 0 8px; color: #718096;">|</span>
                            <span style="font-size: 14px; color: #e2e8f0;">
                                Tạm tính:
                                <strong style="color: #ffffff; font-size: 16px;">
                                    <fmt:formatNumber value="${sessionScope.BOOKING_CART.grandTotal}" type="number"
                                        maxFractionDigits="0" /> đ
                                </strong>
                            </span>
                        </div>
                        <div style="display: flex; gap: 12px; align-items: center;">
                            <a href="${pageContext.request.contextPath}/customer/cart?action=view"
                                style="background: #dd6b20; color: white; padding: 9px 18px; border-radius: 5px; text-decoration: none; font-size: 13px; font-weight: 700; transition: background 0.2s;"
                                onmouseover="this.style.background='#c05621'"
                                onmouseout="this.style.background='#dd6b20'">
                                Kiểm Tra Giỏ & Xác Nhận Đặt
                            </a>
                        </div>
                    </div>
                </div>
            </c:if>

            <jsp:include page="/views/common/footer.jsp" />