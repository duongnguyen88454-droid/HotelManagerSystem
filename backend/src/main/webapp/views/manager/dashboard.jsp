<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Ban Giám Đốc - Dashboard Quản Trị" />
    <jsp:param name="zone" value="portal" />
</jsp:include>

<div class="portal-layout">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <!-- Tiêu đề trang -->
        <header class="page-header">
            <div class="page-header-left">
                <h1 class="page-title">Trung Tâm Điều Hành Quản Trị</h1>
                <p class="page-subtitle">Báo cáo tổng hợp vận hành khách sạn, công suất buồng phòng và các lối tắt điều hành</p>
            </div>
            <div class="page-header-right">
                <span class="pill pill-primary">Hôm nay: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Thẻ tóm tắt thông tin người dùng -->
        <div class="card mb-4">
            <div class="text-secondary text-sm">
                Xin chào Quản lý cấp cao: <strong class="text-main">${sessionScope.CURRENT_USER.hoTen}</strong> 
                (Mã: <code class="mono">${sessionScope.CURRENT_USER.maDinhDanh}</code>, Email: <code class="mono">${sessionScope.CURRENT_USER.email}</code>).
            </div>
        </div>

        <!-- Khối thẻ chỉ số KPI công suất buồng phòng -->
        <div class="kpi-grid">
            <!-- Tổng số phòng -->
            <div class="kpi-card border-top-primary">
                <div class="kpi-label">Tổng Số Phòng</div>
                <div class="kpi-value">${not empty occupancy ? occupancy.tongSoPhong : 0} <span class="text-muted text-sm font-semibold">phòng</span></div>
                <div class="kpi-desc">Toàn bộ tài nguyên phòng</div>
            </div>

            <!-- Tỷ lệ lấp đầy -->
            <div class="kpi-card border-top-info">
                <div class="kpi-label">Tỷ Lệ Lấp Đầy</div>
                <div class="kpi-value text-primary">${not empty occupancy ? occupancy.tyLeLapDayPhanTram : 0}%</div>
                <div class="kpi-desc">Tỷ lệ phòng đang có khách</div>
            </div>

            <!-- Đang có khách -->
            <div class="kpi-card border-top-success">
                <div class="kpi-label">Đang Có Khách (Occupied)</div>
                <div class="kpi-value text-success">${not empty occupancy ? occupancy.soPhongDangCoKhach : 0} <span class="text-muted text-sm font-semibold">phòng</span></div>
                <div class="kpi-desc">Đang lưu trú tại khách sạn</div>
            </div>

            <!-- Phòng trống sẵn sàng -->
            <div class="kpi-card border-top-info">
                <div class="kpi-label">Phòng Trống (Available)</div>
                <div class="kpi-value text-info">${not empty occupancy ? occupancy.soPhongTrong : 0} <span class="text-muted text-sm font-semibold">phòng</span></div>
                <div class="kpi-desc">Sẵn sàng tiếp đón khách mới</div>
            </div>

            <!-- Phòng đang dọn -->
            <div class="kpi-card border-top-warning">
                <div class="kpi-label">Đang Dọn (Cleaning)</div>
                <div class="kpi-value text-warning">${not empty occupancy ? occupancy.soPhongDangDon : 0} <span class="text-muted text-sm font-semibold">phòng</span></div>
                <div class="kpi-desc">Buồng phòng đang phụ trách</div>
            </div>

            <!-- Phòng hư hại -->
            <div class="kpi-card border-top-danger">
                <div class="kpi-label">Bảo Trì (Damaged)</div>
                <div class="kpi-value text-danger">${not empty occupancy ? occupancy.soPhongHuHai : 0} <span class="text-muted text-sm font-semibold">phòng</span></div>
                <div class="kpi-desc">Chờ sửa chữa và nghiệm thu</div>
            </div>
        </div>

        <!-- Khối điều hướng các phân hệ quản trị -->
        <div>
            <h3 class="text-main font-bold text-lg mb-4">
                Các Phân Hệ Quản Trị và Báo Cáo
            </h3>

            <div class="grid-3">
                <!-- Thẻ 1: Báo cáo doanh thu -->
                <div class="card flex flex-col justify-between mb-0">
                    <div>
                        <h4 class="card-title mb-2">Báo Cáo Doanh Thu &amp; Night Audit</h4>
                        <p class="text-muted text-sm leading-relaxed mb-4">
                            Chốt ca doanh thu theo ngày, thống kê dòng tiền thực thu (Tiền mặt, Thẻ, CK) và tổng hợp doanh thu theo từng tháng.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/revenue" class="btn btn-primary">
                        Xem Báo Cáo Doanh Thu
                    </a>
                </div>

                <!-- Thẻ 2: Xử lý hư hại & bảo trì -->
                <div class="card flex flex-col justify-between mb-0">
                    <div>
                        <h4 class="card-title mb-2">Nghiệm Thu Khắc Phục Hư Hại</h4>
                        <p class="text-muted text-sm leading-relaxed mb-4">
                            Quản lý các biên bản báo hỏng phòng từ nhân viên buồng phòng, xác nhận bảo trì xong để mở khóa phòng sang trạng thái Sẵn sàng.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/damages" class="btn btn-danger">
                        Xử Lý Hư Hại Phòng (${not empty occupancy ? occupancy.soPhongHuHai : 0})
                    </a>
                </div>

                <!-- Thẻ 3: Quản lý nhân sự & khóa tài khoản -->
                <div class="card flex flex-col justify-between mb-0">
                    <div>
                        <h4 class="card-title mb-2">Quản Lý Nhân Sự &amp; Tài Khoản</h4>
                        <p class="text-muted text-sm leading-relaxed mb-4">
                            Quản lý hồ sơ nhân viên khách sạn, cập nhật trạng thái nghỉ việc tự động kích hoạt khóa tài khoản đăng nhập.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/employees" class="btn btn-primary">
                        Quản Lý Nhân Sự
                    </a>
                </div>

                <!-- Thẻ 5: Xét duyệt hoàn tiền cọc hủy phòng -->
                <div class="card flex flex-col justify-between mb-0">
                    <div>
                        <h4 class="card-title mb-2">Xét Duyệt Hoàn Tiền Cọc Hủy Phòng</h4>
                        <p class="text-muted text-sm leading-relaxed mb-4">
                            Thẩm định các yêu cầu hủy phòng, tiền hoàn trả tính toán tự động qua hàm nghiệp vụ hoàn tiền từ cơ sở dữ liệu.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/refunds" class="btn btn-success">
                        Xét Duyệt Hoàn Cọc
                    </a>
                </div>

                <!-- Thẻ 6: Cấu hình khách sạn & biểu phí -->
                <div class="card flex flex-col justify-between mb-0">
                    <div>
                        <h4 class="card-title mb-2">Cấu Hình Khách Sạn &amp; Biểu Phí</h4>
                        <p class="text-muted text-sm leading-relaxed mb-4">
                            Điều chỉnh giá phòng, phụ phí nhận sớm/trả muộn, % cọc, danh mục loại giường, tiện nghi và dịch vụ tiêu dùng.
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/manager/hotel-config" class="btn btn-outline">
                        Cấu Hình &amp; Biểu Phí
                    </a>
                </div>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />