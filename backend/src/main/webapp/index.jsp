<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <% com.mycompany.hotelmanagersystem.room.service.RoomService roomService=new
                com.mycompany.hotelmanagersystem.room.service.RoomService(); try {
                java.util.List<com.mycompany.hotelmanagersystem.room.model.RoomType> activeRoomTypes =
                roomService.getActiveRoomTypes();
                request.setAttribute("activeRoomTypes", activeRoomTypes);
                } catch (Exception e) {
                request.setAttribute("activeRoomTypes", java.util.Collections.emptyList());
                }
                %>

                <jsp:include page="/views/common/header.jsp">
                    <jsp:param name="title" value="Grand Horizon Hotel & Suites - Khách Sạn Nghỉ Dưỡng Cao Cấp" />
                </jsp:include>
                <jsp:include page="/views/common/navbar.jsp" />

                <!-- Nhúng tài nguyên CSS chuyên biệt cho trang chủ khách sạn -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home/landing.css">

                <main class="landing-main">
                    <!-- 1. HERO SECTION SANG TRỌNG (THUẦN TYPOGRAPHY, TUYỆT ĐỐI KHÔNG DÙNG ICON) -->
                    <section class="hero-section">
                        <div class="hero-overlay"></div>
                        <div class="hero-content">
                            <span class="hero-badge">THƯƠNG HIỆU NGHỈ DƯỠNG TIÊU CHUẨN 5 SAO</span>
                            <h1 class="hero-title">
                                Kỳ Nghỉ Thượng Lưu Đẳng Cấp
                                <span class="hero-highlight">Grand Horizon Hotel & Suites</span>
                            </h1>
                            <p class="hero-subtitle">
                                Đắm chìm trong không gian kiến trúc thanh lịch hòa quyện cùng chuỗi tiện nghi đương đại.
                                Nơi mang lại sự an yên trọn vẹn và trải nghiệm lưu trú đáng nhớ cho kỳ nghỉ của quý
                                khách.
                            </p>
                            <div class="hero-actions">
                                <a href="#danh-sach-phong" class="btn-hero-primary">Khám Phá Các Hạng Phòng</a>
                                <c:choose>
                                    <c:when test="${not empty sessionScope.CURRENT_USER}">
                                        <a href="${pageContext.request.contextPath}/customer/home"
                                            class="btn-hero-outline">Vào Cổng Đặt Phòng</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/customer/home"
                                            class="btn-hero-outline">Đăng Nhập Để Đặt Phòng</a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </section>

                    <!-- 2. THANH TÌM KIẾM & TRA CỨU PHÒNG NHANH -->
                    <section class="quick-booking-container">
                        <div class="booking-card">
                            <div class="booking-card-header">
                                <h3>Tra Cứu Phòng Nghỉ Trực Tuyến</h3>
                                <p>Khách hàng cần đăng nhập tài khoản để hoàn tất thủ tục giữ chỗ</p>
                            </div>

                            <form action="${pageContext.request.contextPath}/customer/search-rooms" method="GET"
                                class="booking-form-grid">
                                <div class="form-group">
                                    <label for="checkInInput">Ngày Nhận Phòng</label>
                                    <input type="date" id="checkInInput" name="checkIn" required>
                                </div>
                                <div class="form-group">
                                    <label for="checkOutInput">Ngày Trả Phòng</label>
                                    <input type="date" id="checkOutInput" name="checkOut" required>
                                </div>
                                <div class="form-group">
                                    <label for="guestsSelect">Số Lượng Khách</label>
                                    <select id="guestsSelect" name="guests">
                                        <option value="">Tất cả sức chứa</option>
                                        <option value="1">1 Người lớn</option>
                                        <option value="2" selected>2 Người lớn</option>
                                        <option value="3">3 Người lớn</option>
                                        <option value="4">4+ Người lớn</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="roomTypeSelect">Hạng Phòng</label>
                                    <select id="roomTypeSelect" name="roomType">
                                        <option value="ALL">Tất cả hạng phòng</option>
                                        <c:forEach var="rt" items="${activeRoomTypes}">
                                            <option value="${rt.maLoaiPhong}">${rt.tenLoaiPhong}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn-search-room">Tìm Kiếm Phòng</button>
                                </div>
                            </form>
                        </div>
                    </section>

                    <!-- 3. DANH SÁCH CÁC HẠNG PHÒNG ĐỂ KHÁCH HÀNG LƯỚT VÀ XEM THÔNG TIN -->
                    <section id="danh-sach-phong" class="featured-rooms-section">
                        <div class="section-header">
                            <span class="section-tag">BỘ SƯU TẬP PHÒNG NGHỈ</span>
                            <h2>Không Gian Nghỉ Dưỡng Hoàn Mỹ</h2>
                            <div class="section-divider"></div>
                            <p>Quý khách có thể xem thông số chi tiết của từng hạng phòng. Khi tiến hành đặt phòng, hệ
                                thống sẽ yêu cầu đăng nhập tài khoản.</p>
                        </div>

                        <div class="rooms-grid">
                            <c:choose>
                                <c:when test="${not empty activeRoomTypes}">
                                    <c:forEach var="rt" items="${activeRoomTypes}">
                                        <article class="room-card">
                                            <div class="room-visual-banner">
                                                <span class="room-visual-tag">TIÊU CHUẨN 5 SAO</span>
                                                <h3 class="room-visual-title">${rt.tenLoaiPhong}</h3>
                                            </div>
                                            <div class="room-card-body">
                                                <div class="room-specs-table">
                                                    <div class="spec-item">
                                                        <span class="spec-title">Diện Tích</span>
                                                        <span class="spec-data">${rt.dienTich} m²</span>
                                                    </div>
                                                    <div class="spec-item">
                                                        <span class="spec-title">Loại Giường</span>
                                                        <span class="spec-data">${rt.loaiGiuong}</span>
                                                    </div>
                                                    <div class="spec-item">
                                                        <span class="spec-title">Sức Chứa Tối Đa</span>
                                                        <span class="spec-data">${rt.soNguoiToiDa} Khách</span>
                                                    </div>
                                                    <div class="spec-item">
                                                        <span class="spec-title">Dịch Vụ Kèm Theo</span>
                                                        <span class="spec-data">Wifi, Dọn phòng</span>
                                                    </div>
                                                </div>

                                                <div class="room-card-footer">
                                                    <div class="room-price-display">
                                                        <span class="room-price-label">Giá niêm yết</span>
                                                        <div>
                                                            <span class="room-price-amount">
                                                                <fmt:formatNumber value="${rt.giaPhong}"
                                                                    type="number" /> VNĐ
                                                            </span>
                                                            <span class="room-price-unit">/ đêm</span>
                                                        </div>
                                                    </div>

                                                    <!-- NÚT ĐẶT PHÒNG: NẾU CHƯA ĐĂNG NHẬP THÌ YÊU CẦU ĐĂNG NHẬP -->
                                                    <c:choose>
                                                        <c:when
                                                            test="${not empty sessionScope.CURRENT_USER and sessionScope.CURRENT_USER.customer}">
                                                            <a href="${pageContext.request.contextPath}/customer/search-rooms?roomType=${rt.maLoaiPhong}"
                                                                class="btn-book-action">
                                                                Đặt Phòng Này
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/login?redirect=${pageContext.request.contextPath}/customer/search-rooms"
                                                                class="btn-book-action auth-required">
                                                                Đăng Nhập Để Đặt
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <!-- Fallback nếu đang bảo trì dữ liệu -->
                                    <div
                                        style="grid-column: 1 / -1; text-align: center; padding: 40px; background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0;">
                                        <p style="color: #718096; margin: 0; font-size: 15px;">Hệ thống đang cập nhật
                                            danh mục phòng nghỉ. Quý khách vui lòng liên hệ quầy tiếp đón để được hỗ
                                            trợ.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </section>

                    <!-- 4. CHUỖI TIỆN ÍCH DỊCH VỤ 5 SAO (0 ICON, DÙNG CHỮ VÀ SỐ THỨ TỰ) -->
                    <section class="amenities-section">
                        <div class="amenities-container">
                            <div class="section-header">
                                <span class="section-tag">TIỆN NGHI ĐẲNG CẤP</span>
                                <h2>Dịch Vụ Tiêu Chuẩn Quốc Tế</h2>
                                <div class="section-divider"></div>
                                <p>Trọn vẹn từng khoảnh khắc nghỉ dưỡng với hệ thống tiện ích chăm sóc thể chất và tinh
                                    thần</p>
                            </div>

                            <div class="amenities-grid">
                                <div class="amenity-card">
                                    <span class="amenity-index">01</span>
                                    <h4>Ẩm Thực Á - Âu Thượng Hạng</h4>
                                    <p>Thực đơn gọi món phong phú cùng buffet sáng chuẩn mực quốc tế được chế biến bởi
                                        các đầu bếp hàng đầu.</p>
                                </div>
                                <div class="amenity-card">
                                    <span class="amenity-index">02</span>
                                    <h4>Hồ Bơi Vô Cực Trên Cao</h4>
                                    <p>Không gian thư giãn thoáng đãng ngắm trọn toàn cảnh thành phố với làn nước ấm
                                        trong vắt suốt cả ngày.</p>
                                </div>
                                <div class="amenity-card">
                                    <span class="amenity-index">03</span>
                                    <h4>Chăm Sóc Sức Khỏe & Spa</h4>
                                    <p>Liệu pháp mát-xa thảo dược và xông hơi đá muối giúp phục hồi năng lượng và tinh
                                        thần sảng khoái.</p>
                                </div>
                                <div class="amenity-card">
                                    <span class="amenity-index">04</span>
                                    <h4>Đưa Đón VIP & Hỗ Trợ 24/7</h4>
                                    <p>Đội ngũ tiếp đón chuyên nghiệp phục vụ đưa đón sân bay và sẵn sàng giải đáp mọi
                                        yêu cầu lưu trú.</p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- 5. LỐI VÀO DÀNH CHO CÁN BỘ NHÂN VIÊN & QUẢN LÝ -->
                    <section class="staff-portal-strip">
                        <div class="portal-strip-box">
                            <div class="portal-strip-text">
                                <span class="badge-staff-label">CỔNG VẬN HÀNH NỘI BỘ</span>
                                <h4>Khu Vực Dành Cho Cán Bộ Nhân Viên</h4>
                                <p>Dành riêng cho nhân viên Lễ tân, Buồng phòng, Thu ngân và Quản trị khách sạn.</p>
                            </div>
                            <div class="portal-strip-links">
                                <c:choose>
                                    <c:when
                                        test="${not empty sessionScope.CURRENT_USER and not sessionScope.CURRENT_USER.customer}">
                                        <c:if test="${sessionScope.CURRENT_USER.receptionist}">
                                            <a href="${pageContext.request.contextPath}/receptionist/room-map"
                                                class="btn-portal-entry">Sơ Đồ Phòng</a>
                                        </c:if>
                                        <c:if test="${sessionScope.CURRENT_USER.housekeeper}">
                                            <a href="${pageContext.request.contextPath}/housekeeper/tasks"
                                                class="btn-portal-entry">Buồng Phòng</a>
                                        </c:if>
                                        <c:if test="${sessionScope.CURRENT_USER.manager}">
                                            <a href="${pageContext.request.contextPath}/manager/dashboard"
                                                class="btn-portal-entry">Dashboard Quản Trị</a>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/login" class="btn-portal-entry">Đăng
                                            Nhập Cán Bộ</a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </section>
                </main>

                <!-- Nhúng tập tin kịch bản xử lý ngày tháng -->
                <script src="${pageContext.request.contextPath}/assets/js/home/landing.js"></script>

                <jsp:include page="/views/common/footer.jsp" />