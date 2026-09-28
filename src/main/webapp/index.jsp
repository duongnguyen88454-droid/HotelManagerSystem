<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.mycompany.hotelmanagersystem.util.DBContext" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // Kiểm tra trạng thái kết nối Cơ sở dữ liệu QuanLyKhachSan
    boolean isDbConnected = DBContext.testConnection();
    request.setAttribute("isDbConnected", isDbConnected);
    request.setAttribute("pageTitle", "Trang Chủ - Kiểm Thử Hệ Thống Khách Sạn");
%>

<jsp:include page="/views/common/header.jsp" />
<jsp:include page="/views/common/navbar.jsp" />

<div class="container">
    <!-- Hộp thông báo trạng thái kết nối Cơ sở dữ liệu -->
    <div class="card">
        <h2 class="card-title">🔍 Bảng Kiểm Tra Sức Khỏe Hệ Thống (Health Check)</h2>
        
        <c:choose>
            <c:when test="${isDbConnected}">
                <div class="alert alert-success">
                    <strong>✅ KẾT NỐI DATABASE THÀNH CÔNG!</strong><br>
                    Ứng dụng đã kết nối thông suốt với Cơ sở dữ liệu <code>QuanLyKhachSan</code> trên Microsoft SQL Server qua cổng 1433.
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-danger">
                    <strong>❌ KẾT NỐI DATABASE THẤT BẠI!</strong><br>
                    Không thể kết nối tới SQL Server <code>QuanLyKhachSan</code>.<br>
                    <em>Vui lòng kiểm tra lại:</em> Dịch vụ SQL Server (MSSQLSERVER) đã bật chưa, cổng 1433 đã mở chưa, và tài khoản <code>sa</code> / mật khẩu trong file <code>DBContext.java</code> đã đúng chưa.
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Quy ước bảng màu trạng thái phòng cho các giai đoạn sau -->
    <div class="card">
        <h3 class="card-title">🎨 Bảng Quy Ước Màu Sắc Trạng Thái Phòng (Room Status Legend)</h3>
        <p style="margin-bottom: 12px; font-size: 0.9rem; color: var(--text-muted);">
            Dùng xuyên suốt trên Sơ đồ phòng của Lễ tân, Buồng phòng và Dashboard Quản lý:
        </p>
        <div style="display: flex; gap: 12px; flex-wrap: wrap;">
            <span class="badge badge-available" style="padding: 6px 14px; font-size: 0.85rem;">🟩 Available (Trống sạch)</span>
            <span class="badge badge-occupied" style="padding: 6px 14px; font-size: 0.85rem;">🟥 Occupied (Đang ở)</span>
            <span class="badge badge-dirty" style="padding: 6px 14px; font-size: 0.85rem;">🟨 Dirty (Phòng bẩn)</span>
            <span class="badge badge-cleaning" style="padding: 6px 14px; font-size: 0.85rem;">🟧 Cleaning (Đang dọn)</span>
            <span class="badge badge-damaged" style="padding: 6px 14px; font-size: 0.85rem;">⬛ Damaged (Hư hại)</span>
        </div>
    </div>

    <!-- Lối tắt kiểm thử các phân hệ nghiệp vụ -->
    <div class="card">
        <h3 class="card-title">🚀 Lối Tắt Kiểm Thử Các Phân Hệ (Quick Access)</h3>
        <p style="margin-bottom: 16px; font-size: 0.9rem;">
            Chọn phân hệ bạn muốn truy cập để chuẩn bị cho các giai đoạn phát triển tiếp theo:
        </p>
        
        <div class="grid grid-cols-2">
            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">👤 1. Phân Hệ Khách Hàng (Guest)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Tìm kiếm phòng trống, xem chi tiết hạng phòng, đặt phòng online và tra cứu lịch sử đặt phòng.
                </p>
                <a href="${pageContext.request.contextPath}/views/guest/home.jsp" class="btn btn-outline">Vào Portal Khách Hàng</a>
            </div>

            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">🛎️ 2. Phân Hệ Lễ Tân (Receptionist)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Sơ đồ phòng trực quan thời gian thực, thủ tục Check-in nhận phòng, gọi thêm dịch vụ gia tăng và Check-out.
                </p>
                <a href="${pageContext.request.contextPath}/views/receptionist/room_map.jsp" class="btn btn-outline">Vào Sơ Đồ Lễ Tân</a>
            </div>

            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">🧹 3. Phân Hệ Buồng Phòng (Housekeeper)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Danh sách phòng cần dọn dẹp hàng ngày, cập nhật tiến độ Nhận việc / Hoàn thành, lập biên bản hư hại.
                </p>
                <a href="${pageContext.request.contextPath}/views/housekeeper/task_list.jsp" class="btn btn-outline">Vào Bảng Buồng Phòng</a>
            </div>

            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">📊 4. Phân Hệ Quản Lý (Manager)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Dashboard tỷ lệ lấp đầy phòng, báo cáo tổng hợp doanh thu theo ngày / tháng, thống kê dịch vụ ưa chuộng.
                </p>
                <a href="${pageContext.request.contextPath}/views/manager/dashboard.jsp" class="btn btn-outline">Vào Dashboard Quản Lý</a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
