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

    <!-- Trạng thái phiên làm việc hiện tại -->
    <div class="card">
        <h3 class="card-title">👤 Trạng Thái Đăng Nhập Hiện Tại (User Session)</h3>
        <c:choose>
            <c:when test="${not empty sessionScope.CURRENT_USER}">
                <div class="alert alert-info" style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <strong>Đang đăng nhập:</strong> ${sessionScope.CURRENT_USER.hoTen} | 
                        <strong>Vai trò:</strong> <span class="badge" style="background: #1a365d; color: white;">${sessionScope.CURRENT_USER.tenVaiTro} (${sessionScope.CURRENT_USER.maVaiTro})</span> | 
                        <strong>Mã định danh:</strong> <code>${sessionScope.CURRENT_USER.maDinhDanh}</code> | 
                        <strong>Email:</strong> <code>${sessionScope.CURRENT_USER.email}</code>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-primary" style="background: #e53e3e; border: none; padding: 6px 14px;">Đăng Xuất</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-warning" style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <strong>Chưa đăng nhập!</strong> Bạn đang truy cập hệ thống với tư cách khách vãng lai.
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary" style="padding: 6px 14px;">Đăng Nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-outline" style="padding: 6px 14px; margin-left: 8px;">Đăng Ký Mới</a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Lối tắt kiểm thử các phân hệ nghiệp vụ -->
    <div class="card">
        <h3 class="card-title">🚀 Lối Tắt Kiểm Thử Các Phân Hệ (Được Bảo Vệ Bởi AuthFilter)</h3>
        <p style="margin-bottom: 16px; font-size: 0.9rem;">
            Nhấp vào từng phân hệ để kiểm tra cơ chế phân quyền (nếu chưa đăng nhập hoặc sai vai trò, hệ thống sẽ tự động chặn):
        </p>
        
        <div class="grid grid-cols-2">
            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">👤 1. Phân Hệ Khách Hàng (Customer - VT01)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Tìm kiếm phòng trống, xem chi tiết hạng phòng, đặt phòng online và tra cứu lịch sử đặt phòng.
                </p>
                <a href="${pageContext.request.contextPath}/customer/home" class="btn btn-outline">Vào Portal Khách Hàng (/customer/home)</a>
            </div>

            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">🛎️ 2. Phân Hệ Lễ Tân (Receptionist - VT02)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Sơ đồ phòng trực quan thời gian thực, thủ tục Check-in nhận phòng, gọi thêm dịch vụ gia tăng và Check-out.
                </p>
                <a href="${pageContext.request.contextPath}/receptionist/room-map" class="btn btn-outline">Vào Sơ Đồ Lễ Tân (/receptionist/room-map)</a>
            </div>

            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">🧹 3. Phân Hệ Buồng Phòng (Housekeeper - VT03)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Danh sách phòng cần dọn dẹp hàng ngày, cập nhật tiến độ Nhận việc / Hoàn thành, lập biên bản hư hại.
                </p>
                <a href="${pageContext.request.contextPath}/housekeeper/tasks" class="btn btn-outline">Vào Bảng Buồng Phòng (/housekeeper/tasks)</a>
            </div>

            <div style="border: 1px solid var(--border-color); border-radius: 6px; padding: 16px;">
                <h4 style="color: var(--primary-color); margin-bottom: 8px;">📊 4. Phân Hệ Quản Lý (Manager - VT04)</h4>
                <p style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 12px;">
                    Dashboard tỷ lệ lấp đầy phòng, báo cáo tổng hợp doanh thu theo ngày / tháng, thống kê dịch vụ ưa chuộng.
                </p>
                <a href="${pageContext.request.contextPath}/manager/dashboard" class="btn btn-outline">Vào Dashboard Quản Lý (/manager/dashboard)</a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp" />
