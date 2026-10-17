<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Bàn Làm Việc Thu Ngân - Quyết Toán & Hóa Đơn" />
    <jsp:param name="zone" value="portal" />
    <jsp:param name="pageCss" value="cashier/cashier_dashboard.css" />
</jsp:include>

<div class="portal-wrapper">
    <!-- Thanh chức năng bên trái (Sidebar) -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="cashier" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <div class="card card-flush">
            <!-- Thanh tìm kiếm tích hợp trên đầu bảng -->
            <div class="card-toolbar">
                <form action="${pageContext.request.contextPath}/cashier/dashboard" method="GET" class="flex items-center gap-2 flex-1" style="max-width: 580px;">
                    <input type="text" name="keyword" value="${keyword}" class="form-control" style="flex: 1;"
                           placeholder="Tìm kiếm theo Tên khách, CCCD, SĐT hoặc Mã Booking..." />
                    <button type="submit" class="btn btn-primary" style="white-space: nowrap;">Tìm Kiếm</button>
                    <c:if test="${not empty keyword}">
                        <a href="${pageContext.request.contextPath}/cashier/dashboard" class="btn btn-secondary" style="white-space: nowrap;">Đặt Lại</a>
                    </c:if>
                </form>
                <span class="pill">
                    ${not empty bookingList ? bookingList.size() : 0} đơn cần thanh toán
                </span>
            </div>

            <!-- Bảng danh sách đơn theo chuẩn table đồng bộ -->
            <div class="table-wrapper">
                <c:choose>
                    <c:when test="${not empty bookingList}">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mã Booking</th>
                                    <th>Khách Hàng</th>
                                    <th>Thông Tin Liên Hệ</th>
                                    <th>Phòng Lưu Trú</th>
                                    <th>Trạng Thái Phòng</th>
                                    <th class="text-right">Tổng Chi Phí</th>
                                    <th class="text-right">Đã Trả / Còn Thiếu</th>
                                    <th class="text-center">Trạng Thái Thu</th>
                                    <th class="text-right">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="item" items="${bookingList}">
                                    <tr>
                                        <td>
                                            <strong class="text-secondary">${item.maBooking}</strong>
                                            <c:if test="${not empty item.maHoaDon}">
                                                <div class="text-xs text-muted">HĐ: ${item.maHoaDon}</div>
                                            </c:if>
                                        </td>
                                        <td>
                                            <strong class="text-primary">${item.tenKhach}</strong>
                                        </td>
                                        <td>
                                            <div>CCCD: ${item.cccd}</div>
                                            <div class="text-xs text-muted">SĐT: ${item.soDT}</div>
                                        </td>
                                        <td>
                                            <span class="badge badge-danger">${item.danhSachPhong}</span>
                                            <div class="text-xs text-muted mt-2">
                                                Tổng ${item.tongSoPhong} phòng
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${item.soPhongChuaTra > 0}">
                                                    <span class="badge badge-info">Còn ${item.soPhongChuaTra} phòng ở</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-success">Đã trả hết phòng</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-right">
                                            <strong class="mono"><fmt:formatNumber value="${item.tongTien != null ? item.tongTien : item.chiPhiDuKien}" pattern="#,##0" /> đ</strong>
                                        </td>
                                        <td class="text-right">
                                            <div class="text-success text-sm mono">
                                                Đã trả: <fmt:formatNumber value="${item.daThanhToan != null ? item.daThanhToan : 0}" pattern="#,##0" /> đ
                                            </div>
                                            <div class="text-danger text-sm fw-bold mono mt-2">
                                                Còn thiếu: <fmt:formatNumber value="${item.soTienConNo != null ? item.soTienConNo : (item.chiPhiDuKien - (item.daThanhToan != null ? item.daThanhToan : 0))}" pattern="#,##0" /> đ
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.trangThaiHoaDon == 'Paid'}">
                                                    <span class="badge badge-success">Đã thanh toán đủ</span>
                                                </c:when>
                                                <c:when test="${item.trangThaiHoaDon == 'PartiallyPaid' || item.trangThaiHoaDon == 'Partial' || (item.daThanhToan != null && item.daThanhToan > 0)}">
                                                    <span class="badge badge-warning">Thanh toán một phần</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger">Chưa thanh toán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-right">
                                            <c:choose>
                                                <c:when test="${item.soPhongChuaTra > 0}">
                                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                                       class="btn btn-primary btn-sm">
                                                        Chi Tiết &amp; Trả Phòng
                                                    </a>
                                                </c:when>
                                                <c:when test="${item.trangThaiHoaDon == 'Paid' || (item.soTienConNo != null && item.soTienConNo le 0)}">
                                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                                       class="btn btn-success btn-sm">
                                                        Xem Chi Tiết &amp; HĐ
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/cashier/booking-detail?maBooking=${item.maBooking}"
                                                       class="btn btn-warning btn-sm">
                                                        Quyết Toán Công Nợ
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <div class="empty-state-title">Không tìm thấy đơn đặt phòng nào cần thanh toán</div>
                            <p>Thử tìm kiếm với từ khóa khác hoặc kiểm tra lại trạng thái lưu trú của khách hàng.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/views/common/footer.jsp" />
