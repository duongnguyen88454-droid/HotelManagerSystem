<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Lịch Sử Đặt Phòng & Dịch Vụ"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<div class="container" style="max-width: 1200px; margin-top: 25px; margin-bottom: 60px;">

    <!-- Breadcrumb & Tiêu đề -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; flex-wrap: wrap; gap: 15px;">
        <div>
            <div style="font-size: 13px; color: #718096; margin-bottom: 4px;">
                <a href="${pageContext.request.contextPath}/customer/home" style="color: #2b6cb0; text-decoration: none;">Trang Chủ</a>
                &nbsp;&rsaquo;&nbsp;
                <span style="color: #4a5568; font-weight: 600;">Lịch Sử Đặt Phòng</span>
            </div>
            <h2 style="color: #1a365d; margin: 0; font-size: 24px; font-weight: 700;">Danh Sách Đơn Đặt Phòng Của Bạn</h2>
            <p style="color: #718096; margin: 5px 0 0 0; font-size: 14px;">
                Theo dõi trạng thái đơn đặt phòng, hóa đơn và bổ sung dịch vụ tiện ích trước khi nhận và trả phòng.
            </p>
        </div>
        <a href="${pageContext.request.contextPath}/customer/home" 
           style="background: #1a365d; color: white; padding: 10px 18px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 600;">
            Đặt Thêm Phòng Mới
        </a>
    </div>

    <!-- Thông báo kết quả thao tác -->
    <c:if test="${param.cancelSuccess == 'true'}">
        <div style="background: #f0fff4; border: 1px solid #9ae6b4; color: #22543d; padding: 14px 18px; border-radius: 6px; margin-bottom: 25px; font-size: 14px;">
            <strong>Thành công:</strong> Bạn đã hủy đơn đặt phòng thành công. Phòng đã được hoàn trả lại danh sách khả dụng.
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div style="background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; padding: 14px 18px; border-radius: 6px; margin-bottom: 25px; font-size: 14px;">
            <strong>Thông báo:</strong> ${param.error}
        </div>
    </c:if>

    <!-- Danh sách đơn đặt -->
    <c:choose>
        <c:when test="${not empty bookingList}">
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.06);">
                <div class="table-responsive">
                    <table style="width: 100%; border-collapse: collapse; margin: 0; font-size: 14px;">
                        <thead>
                            <tr style="background: #1a365d; color: #ffffff; text-align: left;">
                                <th style="padding: 14px 18px; font-weight: 700;">Mã Đơn / Ngày Đặt</th>
                                <th style="padding: 14px 18px; font-weight: 700;">Thông Tin Phòng</th>
                                <th style="padding: 14px 18px; font-weight: 700;">Kỳ Lưu Trú</th>
                                <th style="padding: 14px 18px; font-weight: 700;">Chi Phí Dự Kiến</th>
                                <th style="padding: 14px 18px; font-weight: 700; text-align: center;">Trạng Thái Đặt</th>
                                <th style="padding: 14px 18px; font-weight: 700; text-align: center;">Hóa Đơn</th>
                                <th style="padding: 14px 18px; font-weight: 700; text-align: center;">Hành Động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${bookingList}">
                                <tr style="border-bottom: 1px solid #edf2f7; transition: background 0.15s;"
                                    onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='white'">
                                    
                                    <!-- Mã Đơn & Thời điểm đặt -->
                                    <td style="padding: 16px 18px; vertical-align: middle;">
                                        <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${item.maBooking}" 
                                           style="font-weight: 700; color: #2b6cb0; text-decoration: none; font-size: 15px;">
                                            ${item.maBooking}
                                        </a>
                                        <div style="font-size: 12px; color: #718096; margin-top: 3px;">
                                            <fmt:formatDate value="${item.ngayDat}" pattern="dd/MM/yyyy HH:mm"/>
                                        </div>
                                    </td>

                                    <!-- Thông tin phòng -->
                                    <td style="padding: 16px 18px; vertical-align: middle;">
                                        <div style="font-weight: 700; color: #1a365d;">
                                            Phòng ${item.soPhong}
                                        </div>
                                        <span style="font-size: 12px; color: #4a5568;">
                                            ${item.tenLoaiPhong}
                                        </span>
                                    </td>

                                    <!-- Kỳ lưu trú -->
                                    <td style="padding: 16px 18px; vertical-align: middle;">
                                        <div style="color: #2d3748; font-weight: 600;">
                                            <fmt:formatDate value="${item.ngayNhanDuKien}" pattern="dd/MM/yyyy"/>
                                            đến
                                            <fmt:formatDate value="${item.ngayTraDuKien}" pattern="dd/MM/yyyy"/>
                                        </div>
                                        <div style="font-size: 12px; color: #718096; margin-top: 2px;">
                                            ${item.soDem} đêm
                                        </div>
                                    </td>

                                    <!-- Chi phí dự kiến -->
                                    <td style="padding: 16px 18px; vertical-align: middle;">
                                        <div style="font-weight: 700; color: #1a365d; font-size: 15px;">
                                            <fmt:formatNumber value="${item.chiPhiDuKien}" type="number" groupingUsed="true"/> đ
                                        </div>
                                    </td>

                                    <!-- Trạng thái Booking -->
                                    <td style="padding: 16px 18px; vertical-align: middle; text-align: center;">
                                        <c:choose>
                                            <c:when test="${item.trangThaiBooking == 'DaXacNhan'}">
                                                <span style="background: #ebf8ff; color: #2b6cb0; border: 1px solid #bee3f8; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 700; display: inline-block;">
                                                    Đã Xác Nhận
                                                </span>
                                            </c:when>
                                            <c:when test="${item.trangThaiBooking == 'DaCheckIn'}">
                                                <span style="background: #f0fff4; color: #276749; border: 1px solid #c6f6d5; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 700; display: inline-block;">
                                                    Đang Ở (Check-in)
                                                </span>
                                            </c:when>
                                            <c:when test="${item.trangThaiBooking == 'DaCheckOut'}">
                                                <span style="background: #edf2f7; color: #4a5568; border: 1px solid #e2e8f0; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 700; display: inline-block;">
                                                    Đã Trả Phòng
                                                </span>
                                            </c:when>
                                            <c:when test="${item.trangThaiBooking == 'DaHuy'}">
                                                <span style="background: #fff5f5; color: #c53030; border: 1px solid #feb2b2; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 700; display: inline-block;">
                                                    Đã Hủy
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="background: #edf2f7; color: #4a5568; padding: 4px 10px; border-radius: 4px; font-size: 12px;">
                                                    ${item.trangThaiBooking}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Hóa đơn -->
                                    <td style="padding: 16px 18px; vertical-align: middle; text-align: center;">
                                        <c:if test="${not empty item.maHoaDon}">
                                            <code style="font-size: 11px; background: #edf2f7; padding: 2px 5px; border-radius: 3px; display: block; margin-bottom: 3px;">
                                                ${item.maHoaDon}
                                            </code>
                                        </c:if>
                                        <c:choose>
                                            <c:when test="${item.trangThaiHoaDon == 'DaThanhToan'}">
                                                <span style="color: #276749; font-weight: 700; font-size: 12px;">Đã Thanh Toán</span>
                                            </c:when>
                                            <c:when test="${item.trangThaiHoaDon == 'ChuaThanhToan'}">
                                                <span style="color: #b7791f; font-weight: 600; font-size: 12px;">Chưa Thanh Toán</span>
                                            </c:when>
                                            <c:when test="${item.trangThaiHoaDon == 'DaHuy'}">
                                                <span style="color: #e53e3e; font-size: 12px;">Đã Hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #718096; font-size: 12px;">-</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Nút thao tác -->
                                    <td style="padding: 16px 18px; vertical-align: middle; text-align: center;">
                                        <div style="display: flex; gap: 8px; justify-content: center; align-items: center; flex-wrap: wrap;">
                                            <!-- Xem chi tiết & Quản lý dịch vụ -->
                                            <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${item.maBooking}"
                                               style="background: #2b6cb0; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 12px; font-weight: 600; white-space: nowrap;">
                                                Chi Tiết & Dịch Vụ
                                            </a>

                                            <!-- Hủy phòng (chỉ khi có thể hủy) -->
                                            <c:if test="${item.coTheHuy}">
                                                <form action="${pageContext.request.contextPath}/customer/history" method="POST" 
                                                      onsubmit="return confirm('Quý khách có chắc chắn muốn hủy đơn đặt phòng [${item.maBooking}] không?');"
                                                      style="margin: 0;">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <input type="hidden" name="bookingId" value="${item.maBooking}">
                                                    <button type="submit" 
                                                            style="background: white; border: 1px solid #feb2b2; color: #e53e3e; padding: 5px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; cursor: pointer; white-space: nowrap;">
                                                        Hủy Đặt
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:when>

        <c:otherwise>
            <!-- Trạng thái chưa có đơn đặt phòng nào -->
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 60px 20px; text-align: center; box-shadow: 0 1px 4px rgba(0,0,0,0.06);">
                <h3 style="color: #1a365d; margin: 0 0 10px 0; font-size: 20px;">Bạn Chưa Có Đơn Đặt Phòng Nào</h3>
                <p style="color: #718096; max-width: 500px; margin: 0 auto 25px auto; font-size: 14px; line-height: 1.6;">
                    Hãy khám phá các hạng phòng nghỉ dưỡng sang trọng với mức giá ưu đãi và nhiều tiện ích tuyệt vời tại khách sạn của chúng tôi.
                </p>
                <div>
                    <a href="${pageContext.request.contextPath}/customer/home" 
                       style="background: #1a365d; color: white; padding: 12px 24px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 700; display: inline-block;">
                        Tìm Kiếm & Đặt Phòng Ngay
                    </a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<jsp:include page="/views/common/footer.jsp"/>
