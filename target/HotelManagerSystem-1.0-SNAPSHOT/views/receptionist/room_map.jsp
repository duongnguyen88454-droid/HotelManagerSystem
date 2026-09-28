<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Lễ Tân - Sơ Đồ Phòng"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<div class="container" style="max-width: 900px; margin-top: 40px; margin-bottom: 50px;">
    <div class="card" style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 30px;">
        <div style="display: flex; align-items: center; justify-content: space-between; border-bottom: 2px solid #edf2f7; padding-bottom: 15px; margin-bottom: 20px;">
            <div>
                <h2 style="color: #1a365d; margin: 0;">📋 BÀN LÀM VIỆC LỄ TÂN</h2>
                <p style="color: #718096; margin: 5px 0 0 0; font-size: 14px;">Quản lý nhận/trả phòng, sơ đồ phòng và dịch vụ phát sinh</p>
            </div>
            <span class="badge" style="background: #319795; color: white; padding: 6px 14px; border-radius: 20px; font-weight: 600;">
                ${sessionScope.CURRENT_USER.tenVaiTro} (${sessionScope.CURRENT_USER.maVaiTro})
            </span>
        </div>

        <div class="alert alert-success" style="margin-bottom: 25px;">
            <strong>✓ Đăng nhập thành công!</strong> Xin chào nhân viên lễ tân: <strong>${sessionScope.CURRENT_USER.hoTen}</strong> 
            (Mã NV: <code>${sessionScope.CURRENT_USER.maDinhDanh}</code>, Email: <code>${sessionScope.CURRENT_USER.email}</code>).
        </div>

        <div style="background: #f7fafc; padding: 20px; border-radius: 8px; border-left: 4px solid #319795;">
            <h4 style="color: #234e52; margin-top: 0;">📌 Giai Đoạn 3 Chuẩn Bị Xây Dựng:</h4>
            <p style="color: #4a5568; line-height: 1.6; margin-bottom: 0;">
                Tại đây sẽ hiển thị lưới sơ đồ phòng (Room Grid) theo thời gian thực với các màu sắc trực quan (Available, Occupied, Dirty, Cleaning, Damaged), popup Check-in nhận phòng và form gọi thêm dịch vụ.
            </p>
        </div>
    </div>
</div>

<jsp:include page="/views/common/footer.jsp"/>
