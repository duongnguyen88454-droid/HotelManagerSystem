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
                    <jsp:param name="zone" value="public" />
                </jsp:include>
                <jsp:include page="/views/common/navbar.jsp" />

                <!-- Nhúng tài nguyên CSS chuyên biệt cho trang chủ khách sạn -->
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home/landing.css">

                <main class="landing-main">
                    <!-- 1. HERO SECTION SANG TRỌNG ĐẲNG CẤP -->
                    <section class="hero-section">
                        <div class="hero-overlay"></div>
                        <div class="hero-content">
                            <div class="hero-badge-wrap">
                                <span class="hero-badge">✦ THƯƠNG HIỆU NGHỈ DƯỠNG TIÊU CHUẨN 5 SAO QUỐC TẾ ✦</span>
                            </div>
                            <h1 class="hero-title">
                                Kỳ Nghỉ Thượng Lưu Đẳng Cấp
                                <span class="hero-highlight">Grand Horizon Hotel &amp; Suites</span>
                            </h1>
                            <p class="hero-subtitle">
                                Hòa mình vào không gian kiến trúc tráng lệ ôm trọn vịnh biển thanh bình. Nơi khởi nguồn
                                của những khoảnh khắc nghỉ dưỡng riêng tư và thăng hoa cảm xúc.
                            </p>
                            <div class="hero-actions">
                                <a href="#danh-sach-phong" class="btn-hero-primary">Khám Phá Các Hạng Phòng</a>
                                <c:choose>
                                    <c:when test="${not empty sessionScope.CURRENT_USER}">
                                        <a href="${pageContext.request.contextPath}/customer/home"
                                            class="btn-hero-outline">Vào Cổng Đặt Phòng</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/login" class="btn-hero-outline">Đăng
                                            Nhập Khách Hàng</a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </section>

                    <!-- 2. FLOATING LUXURY SEARCH BAR -->
                    <section class="quick-booking-container">
                        <div class="booking-card">
                            <div class="booking-card-header flex justify-between items-center flex-wrap gap-2">
                                <div>
                                    <h3>Tra Cứu &amp; Giữ Chỗ Trực Tuyến</h3>
                                    <p>Khám phá phòng nghỉ còn trống và trải nghiệm mức giá ưu đãi tốt nhất hôm nay</p>
                                </div>
                                <span class="badge badge-success text-xs font-semibold">Bảo đảm giá tốt nhất</span>
                            </div>

                            <form action="${pageContext.request.contextPath}/customer/search-rooms" method="GET"
                                class="booking-form-flex">
                                <div class="search-field">
                                    <label for="checkInInput" class="search-label">Ngày Nhận Phòng</label>
                                    <input type="date" id="checkInInput" name="checkIn" required class="search-input">
                                </div>
                                <div class="search-field">
                                    <label for="checkOutInput" class="search-label">Ngày Trả Phòng</label>
                                    <input type="date" id="checkOutInput" name="checkOut" required class="search-input">
                                </div>
                                <div class="search-field">
                                    <label for="guestsSelect" class="search-label">Số Lượng Khách</label>
                                    <select id="guestsSelect" name="guests" class="search-input">
                                        <option value="">Tất cả</option>
                                        <option value="1">1 Người lớn</option>
                                        <option value="2" selected>2 Người lớn</option>
                                        <option value="3">3 Người lớn</option>
                                        <option value="4">4+ Người lớn</option>
                                    </select>
                                </div>
                                <div class="search-field">
                                    <label for="roomTypeSelect" class="search-label">Hạng Phòng Nghỉ</label>
                                    <select id="roomTypeSelect" name="roomType" class="search-input">
                                        <option value="ALL">Tất cả hạng phòng</option>
                                        <c:forEach var="rt" items="${activeRoomTypes}">
                                            <option value="${rt.maLoaiPhong}">${rt.tenLoaiPhong}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="search-action">
                                    <button type="submit" class="btn-search-room">
                                        Tìm Phòng Ngay
                                    </button>
                                </div>
                            </form>
                        </div>
                    </section>

                    <!-- 3. DẢI CHỈ SỐ ẤN TƯỢNG (LUXURY STATS BAR) -->
                    <section class="stats-bar-section">
                        <div class="stats-grid">
                            <div class="stat-item">
                                <div class="stat-number">150+</div>
                                <div class="stat-label">Phòng Nghỉ &amp; Biệt Thự Biển</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">4.9 / 5</div>
                                <div class="stat-label">Đánh Giá Hài Lòng Tuyệt Đối</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">24 / 7</div>
                                <div class="stat-label">Quản Gia Phục Vụ Riêng</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-number">100%</div>
                                <div class="stat-label">Tiêu Chuẩn 5 Sao Quốc Tế</div>
                            </div>
                        </div>
                    </section>

                    <!-- 3. KHÁM PHÁ KHÔNG GIAN NGHỈ DƯỠNG & KIẾN TRÚC KHÁCH SẠN -->
                    <section id="danh-sach-phong" class="featured-rooms-section">
                        <div class="section-header">
                            <span class="section-tag">TRẢI NGHIỆM ĐẲNG CẤP</span>
                            <h2>Không Gian &amp; Dịch Vụ Nghỉ Dưỡng Hoàn Mỹ</h2>
                            <div class="section-divider"></div>
                            <p>Khám phá kiến trúc tinh tế, hệ thống phòng nghỉ hướng biển và chuỗi tiện ích đẳng cấp
                                chuẩn 5 sao quốc tế tại Grand Horizon.</p>
                        </div>

                        <div class="rooms-grid">
                            <!-- Thẻ 1: Sảnh đón tiếp -->
                            <article class="room-card">
                                <div class="room-image-wrapper">
                                    <img src="https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80"
                                        alt="Grand Lobby" class="room-image-cover" />
                                    <span class="room-visual-tag">KHÔNG GIAN TIẾP ĐÓN</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 class="room-card-title">Sảnh Đón Tiếp Hoàng Gia</h3>
                                    <p class="room-card-desc">
                                        Kiến trúc tráng lệ với đèn chùm pha lê và sàn cẩm thạch sang trọng, mang đến cảm
                                        giác chào đón ấm áp và trang trọng nhất.
                                    </p>
                                    <div class="room-card-features">Phục vụ tiếp đón 24/7 &bull; Welcome Drink miễn phí
                                    </div>
                                </div>
                            </article>

                            <!-- Thẻ 2: Phòng Ocean Suite -->
                            <article class="room-card">
                                <div class="room-image-wrapper">
                                    <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80"
                                        alt="Ocean Suite" class="room-image-cover" />
                                    <span class="room-visual-tag">PHÒNG NGHỈ THƯỢNG HẠNG</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 class="room-card-title">Ocean View Luxury Suite</h3>
                                    <p class="room-card-desc">
                                        Tầm nhìn panorama ôm trọn bình minh trên biển, ban công thoáng đãng, giường King
                                        đệm lông vũ cùng bồn tắm nằm cao cấp.
                                    </p>
                                    <div class="room-card-features">View toàn cảnh biển &bull; Ban công riêng &bull;
                                        Smart TV 65"</div>
                                </div>
                            </article>

                            <!-- Thẻ 3: Hồ bơi vô cực -->
                            <article class="room-card">
                                <div class="room-image-wrapper">
                                    <img src="https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80"
                                        alt="Infinity Pool" class="room-image-cover" />
                                    <span class="room-visual-tag">TIỆN ÍCH NGOÀI TRỜI</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 class="room-card-title">Hồ Bơi Vô Cực Chân Mây</h3>
                                    <p class="room-card-desc">
                                        Thư giãn trong làn nước trong vắt trên tầng cao, vừa thưởng thức cocktail nhiệt
                                        đới vừa ngắm hoàng hôn rực rỡ chân trời.
                                    </p>
                                    <div class="room-card-features">Hệ thống nước ấm 4 mùa &bull; Pool Bar phục vụ tại
                                        chỗ</div>
                                </div>
                            </article>

                            <!-- Thẻ 4: Ẩm thực cao cấp -->
                            <article class="room-card">
                                <div class="room-image-wrapper">
                                    <img src="https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80"
                                        alt="Fine Dining" class="room-image-cover" />
                                    <span class="room-visual-tag">ẨM THỰC THƯỢNG HẠNG</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 class="room-card-title">Nhà Hàng Á - Âu The Horizon</h3>
                                    <p class="room-card-desc">
                                        Hương vị ẩm thực đa dạng từ hải sản tươi sống địa phương đến bít tết bò Wagyu
                                        hảo hạng do bếp trưởng chuẩn sao chế biến.
                                    </p>
                                    <div class="room-card-features">Buffet sáng quốc tế &bull; Set menu tiệc tối lãng
                                        mạn</div>
                                </div>
                            </article>

                            <!-- Thẻ 5: Spa thư giãn -->
                            <article class="room-card">
                                <div class="room-image-wrapper">
                                    <img src="https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=800&q=80"
                                        alt="Wellness Spa" class="room-image-cover" />
                                    <span class="room-visual-tag">CHĂM SÓC SỨC KHỎE</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 class="room-card-title">Zenith Wellness &amp; Spa</h3>
                                    <p class="room-card-desc">
                                        Đắm mình trong không gian thảo mộc thiên nhiên, liệu trình massage đá nóng và
                                        xông hơi muối Himalaya giúp phục hồi sinh lực.
                                    </p>
                                    <div class="room-card-features">Liệu pháp thảo mộc &bull; Xông hơi đá muối &bull;
                                        Yoga buổi sáng</div>
                                </div>
                            </article>

                            <!-- Thẻ 6: Phòng gia đình -->
                            <article class="room-card">
                                <div class="room-image-wrapper">
                                    <img src="https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&q=80"
                                        alt="Family Suite" class="room-image-cover" />
                                    <span class="room-visual-tag">KỲ NGHỈ GIA ĐÌNH</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 class="room-card-title">Royal Family Retreat</h3>
                                    <p class="room-card-desc">
                                        Thiết kế 2 phòng ngủ liên thông, phòng khách rộng rãi và khu bếp tiện lợi, nơi
                                        gắn kết trọn vẹn yêu thương cho cả gia đình.
                                    </p>
                                    <div class="room-card-features">2 Giường Queen &bull; Khu vực sinh hoạt riêng &bull;
                                        Sức chứa 4-5 người</div>
                                </div>
                            </article>
                        </div>

                        <!-- Nút kêu gọi hành động đặt phòng -->
                        <div class="text-center mt-6">
                            <a href="${pageContext.request.contextPath}/customer/search-rooms" class="cta-explore-btn">
                                Khám Phá Danh Sách Phòng Trống &amp; Đặt Ngay &rarr;
                            </a>
                        </div>
                    </section>

                    <!-- 4. CHUỖI TIỆN ÍCH DỊCH VỤ 5 SAO -->
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
                                    <h4>Chăm Sóc Sức Khỏe &amp; Spa</h4>
                                    <p>Liệu pháp mát-xa thảo dược và xông hơi đá muối giúp phục hồi năng lượng và tinh
                                        thần sảng khoái.</p>
                                </div>
                                <div class="amenity-card">
                                    <span class="amenity-index">04</span>
                                    <h4>Đưa Đón VIP &amp; Hỗ Trợ 24/7</h4>
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