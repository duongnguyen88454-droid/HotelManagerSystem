<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Ban Giám Đốc - Dashboard Quản Trị" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <!-- Tiêu đề trang -->
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Trung Tâm Điều Hành Quản Trị</h1>
                <p>Báo cáo tổng hợp vận hành khách sạn, công suất buồng phòng và các lối tắt điều hành</p>
            </div>
            <div class="portal-header-right">
                <span class="portal-date-pill">Hôm nay: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Thẻ tóm tắt thông tin người dùng -->
        <div class="portal-card" style="padding: 18px 24px;">
            <div style="font-size: 14px; color: var(--portal-text-secondary);">
                Xin chào Quản lý cấp cao: <strong style="color: var(--portal-text-primary);">${sessionScope.CURRENT_USER.hoTen}</strong> 
                (Mã: <code>${sessionScope.CURRENT_USER.maDinhDanh}</code>, Email: <code>${sessionScope.CURRENT_USER.email}</code>).
            </div>
        </div>

        <!-- Khối thẻ chỉ số KPI công suất buồng phòng -->
        <div class="portal-kpi-grid">
            <!-- Tổng số phòng -->
            <div class="portal-kpi-card" style="border-top: 4px solid #3b82f6;">
                <div class="portal-kpi-label">Tổng Số Phòng</div>
                <div class="portal-kpi-value">${not empty occupancy ? occupancy.tongSoPhong : 0} <span style="font-size: 14px; font-weight: 600; color: #64748b;">phòng</span></div>
                <div class="portal-kpi-desc">Toàn bộ tài nguyên phòng</div>
            </div>

            <!-- Tỷ lệ lấp đầy -->
            <div class="portal-kpi-card" style="border-top: 4px solid #8b5cf6;">
                <div class="portal-kpi-label">Tỷ Lệ Lấp Đầy</div>
                <div class="portal-kpi-value" style="color: #6d28d9;">${not empty occupancy ? occupancy.tyLeLapDayPhanTram : 0}%</div>
                <div class="portal-kpi-desc">Tỷ lệ phòng đang có khách</div>
            </div>

            <!-- Đang có khách -->
            <div class="portal-kpi-card" style="border-top: 4px solid #10b981;">
                <div class="portal-kpi-label">Đang Có Khách (Occupied)</div>
                <div class="portal-kpi-value" style="color: #047857;">${not empty occupancy ? occupancy.soPhongDangCoKhach : 0} <span style="font-size: 14px; font-weight: 600; color: #64748b;">phòng</span></div>
                <div class="portal-kpi-desc">Đang lưu trú tại khách sạn</div>
            </div>

            <!-- Phòng trống sẵn sàng -->
            <div class="portal-kpi-card" style="border-top: 4px solid #06b6d4;">
                <div class="portal-kpi-label">Phòng Trống (Available)</div>
                <div class="portal-kpi-value" style="color: #0e7490;">${not empty occupancy ? occupancy.soPhongTrong : 0} <span style="font-size: 14px; font-weight: 600; color: #64748b;">phòng</span></div>
                <div class="portal-kpi-desc">Sẵn sàng tiếp đón khách mới</div>
            </div>

            <!-- Phòng đang dọn -->
            <div class="portal-kpi-card" style="border-top: 4px solid #f59e0b;">
                <div class="portal-kpi-label">Đang Dọn (Cleaning)</div>
                <div class="portal-kpi-value" style="color: #b45309;">${not empty occupancy ? occupancy.soPhongDangDon : 0} <span style="font-size: 14px; font-weight: 600; color: #64748b;">phòng</span></div>
                <div class="portal-kpi-desc">Buồng phòng đang phụ trách</div>
            </div>

            <!-- Phòng hư hại -->
            <div class="portal-kpi-card" style="border-top: 4px solid #ef4444;">
                <div class="portal-kpi-label">Bảo Trì (Damaged)</div>
                <div class="portal-kpi-value" style="color: #b91c1c;">${not empty occupancy ? occupancy.soPhongHuHai : 0} <span style="font-size: 14px; font-weight: 600; color: #64748b;">phòng</span></div>
                <div class="portal-kpi-desc">Chờ sửa chữa và nghiệm thu</div>
            </div>
        </div>

        <!-- Khối điều hướng các phân hệ quản trị -->
        <div>
            <h3 style="color: var(--portal-text-primary); font-size: 18px; font-weight: 700; margin-bottom: 16px;">
                Các Phân Hệ Quản Trị và Báo Cáo
            </h3>

            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 20px;">
                <!-- Thẻ 1: Báo cáo doanh thu -->
                <div class="portal-card" style="margin-bottom: 0; display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <h4 style="margin: 0 0 8px 0; color: var(--portal-text-primary); font-size: 17px; font-weight: 700;">Báo Cáo Doanh Thu & Night Audit</h4>
                        <p style="color: var(--portal-text-muted); font-size: 13.5px; line-height: 1.5; margin: 0 0 16px 0;">
                            Chốt ca doanh thu theo ngày, thống kê dòng tiền thực thu (Tiền mặt, Thẻ, CK) và tổng hợp doanh thu theo từng tháng.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/revenue" class="portal-btn portal-btn-primary">
                        Xem Báo Cáo Doanh Thu
                    </a>
                </div>

                <!-- Thẻ 2: Xử lý hư hại & bảo trì -->
                <div class="portal-card" style="margin-bottom: 0; display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <h4 style="margin: 0 0 8px 0; color: var(--portal-text-primary); font-size: 17px; font-weight: 700;">Nghiệm Thu Khắc Phục Hư Hại</h4>
                        <p style="color: var(--portal-text-muted); font-size: 13.5px; line-height: 1.5; margin: 0 0 16px 0;">
                            Quản lý các biên bản báo hỏng phòng từ nhân viên buồng phòng, xác nhận bảo trì xong để mở khóa phòng sang trạng thái Sẵn sàng.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/damages" class="portal-btn portal-btn-danger">
                        Xử Lý Hư Hại Phòng (${not empty occupancy ? occupancy.soPhongHuHai : 0})
                    </a>
                </div>

                <!-- Thẻ 3: Quản lý nhân sự & khóa tài khoản -->
                <div class="portal-card" style="margin-bottom: 0; display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <h4 style="margin: 0 0 8px 0; color: var(--portal-text-primary); font-size: 17px; font-weight: 700;">Quản Lý Nhân Sự & Tài Khoản</h4>
                        <p style="color: var(--portal-text-muted); font-size: 13.5px; line-height: 1.5; margin: 0 0 16px 0;">
                            Quản lý hồ sơ nhân viên khách sạn, cập nhật trạng thái nghỉ việc tự động kích hoạt khóa tài khoản đăng nhập.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/employees" class="portal-btn portal-btn-primary">
                        Quản Lý Nhân Sự
                    </a>
                </div>

                <!-- Thẻ 5: Xét duyệt hoàn tiền cọc hủy phòng -->
                <div class="portal-card" style="margin-bottom: 0; display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <h4 style="margin: 0 0 8px 0; color: var(--portal-text-primary); font-size: 17px; font-weight: 700;">Xét Duyệt Hoàn Tiền Cọc Hủy Phòng</h4>
                        <p style="color: var(--portal-text-muted); font-size: 13.5px; line-height: 1.5; margin: 0 0 16px 0;">
                            Thẩm định các yêu cầu hủy phòng, tiền hoàn trả tính toán tự động qua hàm nghiệp vụ hoàn tiền từ cơ sở dữ liệu.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/refunds" class="portal-btn portal-btn-success">
                        Xét Duyệt Hoàn Cọc
                    </a>
                </div>

                <!-- Thẻ 6: Cấu hình khách sạn & biểu phí -->
                <div class="portal-card" style="margin-bottom: 0; display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <h4 style="margin: 0 0 8px 0; color: var(--portal-text-primary); font-size: 17px; font-weight: 700;">Cấu Hình Khách Sạn & Biểu Phí</h4>
                        <p style="color: var(--portal-text-muted); font-size: 13.5px; line-height: 1.5; margin: 0 0 16px 0;">
                            Điều chỉnh giá phòng, phụ phí nhận sớm/trả muộn, % cọc, danh mục loại giường (BedType), tiện nghi và dịch vụ tiêu dùng.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/hotel-config" class="portal-btn portal-btn-secondary">
                        Cấu Hình & Biểu Phí
                    </a>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />