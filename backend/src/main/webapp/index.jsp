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

                    <!-- 3. KHÁM PHÁ KHÔNG GIAN NGHỈ DƯỠNG & KIẾN TRÚC KHÁCH SẠN (HÌNH ẢNH & MIÊU TẢ THỰC TẾ) -->
                    <section id="danh-sach-phong" class="featured-rooms-section">
                        <div class="section-header">
                            <span class="section-tag">TRẢI NGHIỆM ĐẲNG CẤP</span>
                            <h2>Không Gian &amp; Dịch Vụ Nghỉ Dưỡng Hoàn Mỹ</h2>
                            <div class="section-divider"></div>
                            <p>Khám phá kiến trúc tinh tế, hệ thống phòng nghỉ hướng biển và chuỗi tiện ích đẳng cấp chuẩn 5 sao quốc tế tại Grand Horizon.</p>
                        </div>

                        <div class="rooms-grid">
                            <!-- Thẻ 1: Sảnh đón tiếp -->
                            <article class="room-card">
                                <div style="height: 220px; position: relative; overflow: hidden;">
                                    <img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80" 
                                         alt="Grand Lobby" style="width: 100%; height: 100%; object-fit: cover;" />
                                    <span class="room-visual-tag" style="position: absolute; top: 14px; left: 14px; z-index: 2;">KHÔNG GIAN TIẾP ĐÓN</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 style="color: #1a365d; font-size: 19px; font-weight: 700; margin: 0 0 10px 0;">Sảnh Đón Tiếp Hoàng Gia</h3>
                                    <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0 0 16px 0;">
                                        Kiến trúc tráng lệ với đèn chùm pha lê và sàn cẩm thạch sang trọng, mang đến cảm giác chào đón ấm áp và trang trọng nhất.
                                    </p>
                                    <div style="font-size: 12px; color: #718096; font-weight: 600;">Phục vụ tiếp đón 24/7 &bull; Welcome Drink miễn phí</div>
                                </div>
                            </article>

                            <!-- Thẻ 2: Phòng Ocean Suite -->
                            <article class="room-card">
                                <div style="height: 220px; position: relative; overflow: hidden;">
                                    <img src="https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=800&q=80" 
                                         alt="Ocean Suite" style="width: 100%; height: 100%; object-fit: cover;" />
                                    <span class="room-visual-tag" style="position: absolute; top: 14px; left: 14px; z-index: 2;">PHÒNG NGHỈ THƯỢNG HẠNG</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 style="color: #1a365d; font-size: 19px; font-weight: 700; margin: 0 0 10px 0;">Ocean View Luxury Suite</h3>
                                    <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0 0 16px 0;">
                                        Tầm nhìn panorama ôm trọn bình minh trên biển, ban công thoáng đãng, giường King đệm lông vũ cùng bồn tắm nằm cao cấp.
                                    </p>
                                    <div style="font-size: 12px; color: #718096; font-weight: 600;">View toàn cảnh biển &bull; Ban công riêng &bull; Smart TV 65"</div>
                                </div>
                            </article>

                            <!-- Thẻ 3: Hồ bơi vô cực -->
                            <article class="room-card">
                                <div style="height: 220px; position: relative; overflow: hidden;">
                                    <img src="https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80" 
                                         alt="Infinity Pool" style="width: 100%; height: 100%; object-fit: cover;" />
                                    <span class="room-visual-tag" style="position: absolute; top: 14px; left: 14px; z-index: 2;">TIỆN ÍCH NGOÀI TRỜI</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 style="color: #1a365d; font-size: 19px; font-weight: 700; margin: 0 0 10px 0;">Hồ Bơi Vô Cực Chân Mây</h3>
                                    <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0 0 16px 0;">
                                        Thư giãn trong làn nước trong vắt trên tầng cao, vừa thưởng thức cocktail nhiệt đới vừa ngắm hoàng hôn rực rỡ chân trời.
                                    </p>
                                    <div style="font-size: 12px; color: #718096; font-weight: 600;">Hệ thống nước ấm 4 mùa &bull; Pool Bar phục vụ tại chỗ</div>
                                </div>
                            </article>

                            <!-- Thẻ 4: Ẩm thực cao cấp -->
                            <article class="room-card">
                                <div style="height: 220px; position: relative; overflow: hidden;">
                                    <img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80" 
                                         alt="Fine Dining" style="width: 100%; height: 100%; object-fit: cover;" />
                                    <span class="room-visual-tag" style="position: absolute; top: 14px; left: 14px; z-index: 2;">ẨM THỰC THƯỢNG HẠNG</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 style="color: #1a365d; font-size: 19px; font-weight: 700; margin: 0 0 10px 0;">Nhà Hàng Á - Âu The Horizon</h3>
                                    <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0 0 16px 0;">
                                        Hương vị ẩm thực đa dạng từ hải sản tươi sống địa phương đến bít tết bò Wagyu hảo hạng do bếp trưởng chuẩn sao chế biến.
                                    </p>
                                    <div style="font-size: 12px; color: #718096; font-weight: 600;">Buffet sáng quốc tế &bull; Set menu tiệc tối lãng mạn</div>
                                </div>
                            </article>

                            <!-- Thẻ 5: Spa thư giãn -->
                            <article class="room-card">
                                <div style="height: 220px; position: relative; overflow: hidden;">
                                    <img src="https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80" 
                                         alt="Wellness Spa" style="width: 100%; height: 100%; object-fit: cover;" />
                                    <span class="room-visual-tag" style="position: absolute; top: 14px; left: 14px; z-index: 2;">CHĂM SÓC SỨC KHỎE</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 style="color: #1a365d; font-size: 19px; font-weight: 700; margin: 0 0 10px 0;">Zenith Wellness &amp; Spa</h3>
                                    <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0 0 16px 0;">
                                        Đắm mình trong không gian thảo mộc thiên nhiên, liệu trình massage đá nóng và xông hơi muối Himalaya giúp phục hồi sinh lực.
                                    </p>
                                    <div style="font-size: 12px; color: #718096; font-weight: 600;">Liệu pháp thảo mộc &bull; Xông hơi đá muối &bull; Yoga buổi sáng</div>
                                </div>
                            </article>

                            <!-- Thẻ 6: Phòng gia đình -->
                            <article class="room-card">
                                <div style="height: 220px; position: relative; overflow: hidden;">
                                    <img src="https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80" 
                                         alt="Family Suite" style="width: 100%; height: 100%; object-fit: cover;" />
                                    <span class="room-visual-tag" style="position: absolute; top: 14px; left: 14px; z-index: 2;">KỲ NGHỈ GIA ĐÌNH</span>
                                </div>
                                <div class="room-card-body">
                                    <h3 style="color: #1a365d; font-size: 19px; font-weight: 700; margin: 0 0 10px 0;">Royal Family Retreat</h3>
                                    <p style="color: #4a5568; font-size: 14px; line-height: 1.6; margin: 0 0 16px 0;">
                                        Thiết kế 2 phòng ngủ liên thông, phòng khách rộng rãi và khu bếp tiện lợi, nơi gắn kết trọn vẹn yêu thương cho cả gia đình.
                                    </p>
                                    <div style="font-size: 12px; color: #718096; font-weight: 600;">2 Giường Queen &bull; Khu vực sinh hoạt riêng &bull; Sức chứa 4-5 người</div>
                                </div>
                            </article>
                        </div>

                        <!-- Nút kêu gọi hành động đặt phòng -->
                        <div style="text-align: center; margin-top: 40px;">
                            <a href="${pageContext.request.contextPath}/customer/search-rooms" 
                               style="background: #1a365d; color: white; padding: 14px 36px; border-radius: 6px; font-size: 15px; font-weight: 700; text-decoration: none; display: inline-block; box-shadow: 0 4px 14px rgba(26,54,93,0.3); transition: all 0.2s;"
                               onmouseover="this.style.background='#2b4c7e'; this.style.transform='translateY(-2px)'"
                               onmouseout="this.style.background='#1a365d'; this.style.transform='none'">
                                Khám Phá Danh Sách Phòng Trống &amp; Đặt Ngay &rarr;
                            </a>
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