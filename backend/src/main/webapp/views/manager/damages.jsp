<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Sự Cố & Bảo Trì Phòng" />
</jsp:include>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/portal_layout.css">

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="damages" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="portal-header">
            <div class="portal-header-left">
                <h1>Quản Lý Sự Cố & Bảo Trì Phòng</h1>
                <p>Theo dõi danh sách các phòng hư hỏng, nghiệm thu khắc phục thiết bị và mở khóa phòng Available</p>
            </div>
            <div class="portal-header-right">
                <a href="${pageContext.request.contextPath}/manager/dashboard" class="portal-btn portal-btn-secondary">
                    Quay Lại Dashboard
                </a>
            </div>
        </header>

        <!-- Thông báo kết quả -->
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="portal-alert portal-alert-success">
                ${sessionScope.flashSuccess}
            </div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="portal-alert portal-alert-danger">
                ${sessionScope.flashError}
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>

        <!-- Bảng danh sách sự cố -->
        <div class="portal-card" style="padding: 0; overflow: hidden;">
            <div style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); background: #f8fafc;">
                <h3 class="portal-card-title">Danh Sách Báo Cáo Hư Hại Chờ Nghiệm Thu</h3>
            </div>

            <div class="portal-table-wrapper" style="border: none; border-radius: 0;">
                <table class="portal-table">
                    <thead>
                        <tr>
                            <th>Mã Biên Bản</th>
                            <th>Phòng</th>
                            <th>Hạng Phòng</th>
                            <th>Sự Cố Thiết Bị</th>
                            <th>Chi Tiết Hư Hỏng</th>
                            <th>Người Báo & Ngày Giờ</th>
                            <th style="text-align: center;">Trạng Thái</th>
                            <th style="text-align: center;">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty damagedRooms}">
                                <c:forEach var="item" items="${damagedRooms}">
                                    <tr>
                                        <td style="font-weight: 700; color: var(--portal-primary);">
                                            ${item.maBaoCao}
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; color: var(--portal-text-primary); font-size: 15px;">Phòng ${item.soPhong}</div>
                                            <div style="color: var(--portal-text-muted); font-size: 12px;">ID: ${item.maPhong}</div>
                                        </td>
                                        <td style="color: var(--portal-text-secondary);">
                                            ${item.tenLoaiPhong}
                                        </td>
                                        <td>
                                            <span class="badge-pill badge-damaged">
                                                ${item.tenLoaiHuHai}
                                            </span>
                                        </td>
                                        <td style="color: var(--portal-text-primary); max-width: 250px;">
                                            ${item.moTaChiTiet}
                                        </td>
                                        <td style="font-size: 13px; color: var(--portal-text-muted);">
                                            <div>Người báo: <strong style="color: var(--portal-text-primary);">${item.nhanVienPhatHien}</strong></div>
                                            <div style="margin-top: 2px;">Thời điểm: ${item.ngayPhatHien}</div>
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${item.trangThaiBaoCao == 'Pending'}">
                                                    <span class="badge-pill badge-cleaning">Chờ Xác Nhận</span>
                                                </c:when>
                                                <c:when test="${item.trangThaiBaoCao == 'Confirmed'}">
                                                    <span class="badge-pill badge-occupied">Đang Bảo Trì</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-pill badge-damaged">${item.trangThaiBaoCao}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;">
                                            <form action="${pageContext.request.contextPath}/manager/damages" method="POST" style="margin: 0;"
                                                  onsubmit="return confirm('Xác nhận nghiệm thu thiết bị đã sửa xong và mở khóa Phòng ${item.soPhong} sang trạng thái Khả dụng (Available)?');">
                                                <input type="hidden" name="action" value="resolve" />
                                                <input type="hidden" name="maBaoCao" value="${item.maBaoCao}" />
                                                <input type="hidden" name="maPhong" value="${item.maPhong}" />
                                                <input type="hidden" name="soPhong" value="${item.soPhong}" />
                                                <button type="submit" class="portal-btn portal-btn-success" style="padding: 7px 14px; font-size: 12.5px;">
                                                    Nghiệm Thu Xong
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" style="padding: 40px; text-align: center; color: var(--portal-text-muted);">
                                        <div style="font-weight: 700; font-size: 15px; color: var(--portal-text-secondary);">Không có phòng nào đang báo hỏng hoặc cần bảo trì!</div>
                                        <div style="font-size: 13px; margin-top: 4px;">Toàn bộ cơ sở vật chất phòng ốc của khách sạn đang trong tình trạng hoạt động tốt.</div>
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />
