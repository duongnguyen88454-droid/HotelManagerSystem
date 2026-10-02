<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Chi Tiết Đơn Đặt Phòng - ${bookingDetail.maBooking}"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<style>
    /* Styling in ấn */
    @media print {
        .navbar, .footer, .no-print, button, .btn {
            display: none !important;
        }
        .container {
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        .card {
            box-shadow: none !important;
            border: 1px solid #ccc !important;
        }
    }

    /* Modal styling */
    .modal-backdrop {
        position: fixed;
        top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: none;
        justify-content: center;
        align-items: center;
        z-index: 9999;
    }
    .modal-content {
        background: white;
        border-radius: 8px;
        width: 100%;
        max-width: 500px;
        padding: 24px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        animation: modalFadeIn 0.2s ease-out;
    }
    @keyframes modalFadeIn {
        from { opacity: 0; transform: translateY(-15px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>

<div class="container" style="max-width: 1200px; margin-top: 25px; margin-bottom: 60px;">

    <!-- Thanh dẫn hướng & Nút thao tác -->
    <div class="no-print" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 10px;">
        <div style="font-size: 13px; color: #718096;">
            <a href="${pageContext.request.contextPath}/customer/home" style="color: #2b6cb0; text-decoration: none;">Trang Chủ</a>
            &nbsp;&rsaquo;&nbsp;
            <a href="${pageContext.request.contextPath}/customer/history" style="color: #2b6cb0; text-decoration: none;">Lịch Sử Đặt Phòng</a>
            &nbsp;&rsaquo;&nbsp;
            <span style="color: #4a5568; font-weight: 600;">Đơn Đặt ${bookingDetail.maBooking}</span>
        </div>
        <div style="display: flex; gap: 10px;">
            <button onclick="window.print()" 
                    style="background: white; border: 1px solid #cbd5e0; color: #4a5568; padding: 8px 14px; border-radius: 5px; font-size: 13px; font-weight: 600; cursor: pointer;">
                In Phiếu Đặt Phòng
            </button>
            <a href="${pageContext.request.contextPath}/customer/history" 
               style="background: #edf2f7; color: #4a5568; padding: 8px 14px; border-radius: 5px; text-decoration: none; font-size: 13px; font-weight: 600;">
                Về Lịch Sử Đặt Phòng
            </a>
        </div>
    </div>

    <!-- Thông báo kết quả -->
    <c:if test="${param.bookingSuccess == 'true'}">
        <div class="no-print" style="background: #f0fff4; border: 1px solid #9ae6b4; color: #22543d; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px;">
            <strong>Đặt phòng thành công!</strong> Đơn đặt của bạn đã được ghi nhận vào hệ thống. Mã đơn: <strong>${bookingDetail.maBooking}</strong>. Quý khách có thể bổ sung thêm dịch vụ tiện ích bên dưới bất kỳ lúc nào trước khi trả phòng.
        </div>
    </c:if>

    <c:if test="${param.msg == 'service_added'}">
        <div class="no-print" style="background: #f0fff4; border: 1px solid #9ae6b4; color: #22543d; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px;">
            <strong>Thành công:</strong> Dịch vụ mới đã được thêm vào phòng và tự động cập nhật vào chi phí đơn đặt phòng.
        </div>
    </c:if>

    <c:if test="${param.msg == 'service_removed'}">
        <div class="no-print" style="background: #f0fff4; border: 1px solid #9ae6b4; color: #22543d; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px;">
            <strong>Thành công:</strong> Đã hủy dịch vụ khỏi phòng và giảm trừ chi phí tương ứng trên hóa đơn.
        </div>
    </c:if>

    <c:if test="${not empty param.error}">
        <div class="no-print" style="background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; padding: 14px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 14px;">
            <strong>Thông báo lỗi:</strong> ${param.error}
        </div>
    </c:if>

    <!-- THẺ TIÊU ĐỀ ĐƠN ĐẶT PHÒNG & THÔNG TIN CHUNG -->
    <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.06); margin-bottom: 25px;">
        <div style="background: #1a365d; color: white; padding: 18px 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <div style="font-size: 12px; color: #c5a880; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;">
                    Chi Tiết Đơn Đặt Phòng Trực Tuyến
                </div>
                <h2 style="color: white; margin: 4px 0 0 0; font-size: 22px; font-weight: 700;">
                    Mã Đơn: <code>${bookingDetail.maBooking}</code>
                </h2>
                <div style="font-size: 13px; color: #cbd5e0; margin-top: 4px;">
                    Thời gian tạo: <fmt:formatDate value="${bookingDetail.ngayDat}" pattern="dd/MM/yyyy HH:mm:ss"/>
                </div>
            </div>

            <!-- Badges trạng thái không dùng icon -->
            <div style="text-align: right; display: flex; flex-direction: column; align-items: flex-end; gap: 8px;">
                <c:choose>
                    <c:when test="${bookingDetail.trangThaiBooking == 'DaXacNhan'}">
                        <span style="background: #c5a880; color: #1a365d; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 4px;">
                            Đã Xác Nhận
                        </span>
                    </c:when>
                    <c:when test="${bookingDetail.trangThaiBooking == 'DaCheckIn'}">
                        <span style="background: #2f855a; color: white; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 4px;">
                            Đang Lưu Trú (Check-in)
                        </span>
                    </c:when>
                    <c:when test="${bookingDetail.trangThaiBooking == 'DaCheckOut'}">
                        <span style="background: #718096; color: white; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 4px;">
                            Đã Trả Phòng (Check-out)
                        </span>
                    </c:when>
                    <c:when test="${bookingDetail.trangThaiBooking == 'DaHuy'}">
                        <span style="background: #e53e3e; color: white; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 4px;">
                            Đã Hủy
                        </span>
                    </c:when>
                </c:choose>

                <div style="font-size: 12px; color: #e2e8f0;">
                    Hóa đơn: <strong>${bookingDetail.maHoaDon}</strong>
                    <c:choose>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'DaThanhToan'}">
                            <span style="background: #276749; color: white; padding: 2px 6px; border-radius: 3px; margin-left: 5px;">Đã Thanh Toán</span>
                        </c:when>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'ChuaThanhToan'}">
                            <span style="background: #b7791f; color: white; padding: 2px 6px; border-radius: 3px; margin-left: 5px;">Chưa Thanh Toán</span>
                        </c:when>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'DaHuy'}">
                            <span style="background: #9b2c2c; color: white; padding: 2px 6px; border-radius: 3px; margin-left: 5px;">Hóa Đơn Hủy</span>
                        </c:when>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Thông tin liên hệ khách hàng & Ghi chú -->
        <div style="padding: 20px 24px; background: white;">
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 15px; font-size: 13px;">
                <div>
                    <span style="color: #718096; display: block; margin-bottom: 2px;">Họ tên khách hàng:</span>
                    <strong style="color: #2d3748; font-size: 14px;">${bookingDetail.hoTenKhachHang}</strong>
                </div>
                <div>
                    <span style="color: #718096; display: block; margin-bottom: 2px;">Số điện thoại:</span>
                    <strong style="color: #2d3748; font-size: 14px;">${bookingDetail.soDT}</strong>
                </div>
                <div>
                    <span style="color: #718096; display: block; margin-bottom: 2px;">Email:</span>
                    <strong style="color: #2d3748; font-size: 14px;">${bookingDetail.email}</strong>
                </div>
                <div>
                    <span style="color: #718096; display: block; margin-bottom: 2px;">Số CCCD lưu trú:</span>
                    <strong style="color: #2d3748; font-size: 14px;">${not empty bookingDetail.cccd ? bookingDetail.cccd : 'Chưa cập nhật'}</strong>
                </div>
                <div>
                    <span style="color: #718096; display: block; margin-bottom: 2px;">Mã định danh (MaKH):</span>
                    <code>${bookingDetail.maKH}</code>
                </div>
            </div>

            <c:if test="${not empty bookingDetail.ghiChu}">
                <div style="margin-top: 15px; padding: 10px 14px; background: #f7fafc; border-left: 3px solid #cbd5e0; border-radius: 4px; font-size: 13px; color: #4a5568;">
                    <strong>Ghi chú đơn đặt:</strong> ${bookingDetail.ghiChu}
                </div>
            </c:if>
        </div>
    </div>

    <!-- DANH SÁCH CÁC PHÒNG TRONG ĐƠN ĐẶT KÈM DỊCH VỤ GẮN THEO PHÒNG -->
    <h3 style="color: #1a365d; font-size: 18px; font-weight: 700; margin: 0 0 15px 0;">
        Danh Sách Phòng & Dịch Vụ Tiện Ích Đã Đăng Ký
    </h3>

    <div style="display: flex; flex-direction: column; gap: 24px; margin-bottom: 30px;">
        <c:forEach var="room" items="${bookingDetail.danhSachPhong}">
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.06);">
                
                <!-- Room Card Header -->
                <div style="background: #f7fafc; border-bottom: 1px solid #edf2f7; padding: 14px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                    <div>
                        <span style="background: #1a365d; color: white; font-size: 11px; font-weight: 700; padding: 2px 7px; border-radius: 3px; text-transform: uppercase;">
                            ${room.tenLoaiPhong}
                        </span>
                        <h4 style="color: #1a365d; margin: 4px 0 0 0; font-size: 17px; font-weight: 700;">
                            Phòng ${room.soPhong}
                        </h4>
                    </div>

                    <div style="display: flex; gap: 20px; align-items: center; font-size: 13px; color: #4a5568;">
                        <div>
                            Thời gian: <strong><fmt:formatDate value="${room.ngayNhanDuKien}" pattern="dd/MM/yyyy"/></strong>
                            đến <strong><fmt:formatDate value="${room.ngayTraDuKien}" pattern="dd/MM/yyyy"/></strong>
                            <span style="color: #718096;">(${room.soDem} đêm)</span>
                        </div>
                        <div style="text-align: right;">
                            <span style="color: #718096; font-size: 11px; display: block;">Tiền phòng:</span>
                            <strong style="color: #1a365d; font-size: 15px;">
                                <fmt:formatNumber value="${room.tienPhong}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ
                            </strong>
                        </div>
                    </div>
                </div>

                <!-- Bảng Dịch Vụ Của Riêng Phòng Này -->
                <div style="padding: 20px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                        <h5 style="color: #2d3748; margin: 0; font-size: 14px; font-weight: 700;">
                            Dịch Vụ Đi Kèm Của Phòng ${room.soPhong}
                        </h5>

                        <c:if test="${bookingDetail.coTheThemDichVu}">
                            <button type="button" class="no-print"
                                    onclick="openAddServiceModal('${room.maPhong}', '${room.soPhong}')"
                                    style="background: #1a365d; color: white; border: none; padding: 6px 14px; border-radius: 4px; font-size: 12px; font-weight: 600; cursor: pointer;">
                                Thêm Dịch Vụ Cho Phòng Này
                            </button>
                        </c:if>
                    </div>

                    <c:choose>
                        <c:when test="${not empty room.danhSachDichVu}">
                            <div class="table-responsive">
                                <table style="width: 100%; border-collapse: collapse; font-size: 13px; margin: 0;">
                                    <thead>
                                        <tr style="background: #edf2f7; color: #4a5568; text-align: left;">
                                            <th style="padding: 10px 14px;">Tên Dịch Vụ</th>
                                            <th style="padding: 10px 14px; text-align: right;">Đơn Giá</th>
                                            <th style="padding: 10px 14px; text-align: center;">Số Lượng</th>
                                            <th style="padding: 10px 14px; text-align: right;">Thành Tiền</th>
                                            <th style="padding: 10px 14px;">Thời Điểm Gọi</th>
                                            <th style="padding: 10px 14px; text-align: center;">Người Thêm</th>
                                            <c:if test="${bookingDetail.coTheThemDichVu}">
                                                <th style="padding: 10px 14px; text-align: center;" class="no-print">Thao Tác</th>
                                            </c:if>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="dv" items="${room.danhSachDichVu}">
                                            <tr style="border-bottom: 1px solid #edf2f7;">
                                                <td style="padding: 12px 14px; font-weight: 600; color: #2d3748;">
                                                    ${dv.tenDichVu}
                                                    <span style="font-size: 11px; color: #718096; display: block;">Mã: <code>${dv.maDichVu}</code></span>
                                                </td>
                                                <td style="padding: 12px 14px; text-align: right; color: #4a5568;">
                                                    <fmt:formatNumber value="${dv.donGia}" type="number" groupingUsed="true"/> đ
                                                </td>
                                                <td style="padding: 12px 14px; text-align: center; font-weight: 700; color: #1a365d;">
                                                    ${dv.soLuong}
                                                </td>
                                                <td style="padding: 12px 14px; text-align: right; font-weight: 700; color: #2b6cb0;">
                                                    <fmt:formatNumber value="${dv.thanhTien}" type="number" groupingUsed="true"/> đ
                                                </td>
                                                <td style="padding: 12px 14px; color: #718096; font-size: 12px;">
                                                    <fmt:formatDate value="${dv.thoiDiemThem}" pattern="dd/MM/yyyy HH:mm"/>
                                                </td>
                                                <td style="padding: 12px 14px; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${dv.nguoiThem == 'KhachHang'}">
                                                            <span style="background: #ebf8ff; color: #2b6cb0; padding: 2px 6px; border-radius: 3px; font-size: 11px;">Khách Đặt</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span style="background: #edf2f7; color: #4a5568; padding: 2px 6px; border-radius: 3px; font-size: 11px;">Lễ Tân Thêm</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <c:if test="${bookingDetail.coTheThemDichVu}">
                                                    <td style="padding: 12px 14px; text-align: center;" class="no-print">
                                                        <form action="${pageContext.request.contextPath}/customer/booking-detail/add-service" method="POST"
                                                              onsubmit="return confirm('Bạn có chắc muốn hủy dịch vụ [${dv.tenDichVu}] khỏi phòng ${room.soPhong}?');"
                                                              style="margin: 0;">
                                                            <input type="hidden" name="action" value="remove">
                                                            <input type="hidden" name="bookingId" value="${bookingDetail.maBooking}">
                                                            <input type="hidden" name="serviceBookingId" value="${dv.maBookingDichVu}">
                                                            <button type="submit" 
                                                                    style="background: white; border: 1px solid #feb2b2; color: #e53e3e; padding: 3px 8px; border-radius: 4px; font-size: 11px; cursor: pointer;">
                                                                Hủy DV
                                                            </button>
                                                        </form>
                                                    </td>
                                                </c:if>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="background: #f7fafc; border: 1px dashed #cbd5e0; border-radius: 5px; padding: 14px; text-align: center; color: #718096; font-size: 13px;">
                                Phòng này chưa đăng ký dịch vụ bổ sung nào. Quý khách có thể bấm <strong>"Thêm Dịch Vụ Cho Phòng Này"</strong> để gọi dịch vụ bất kỳ lúc nào trước khi trả phòng.
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${room.tongTienDichVuPhong > 0}">
                        <div style="text-align: right; margin-top: 10px; font-size: 13px; color: #4a5568;">
                            Tổng tiền dịch vụ phòng ${room.soPhong}: 
                            <strong style="color: #1a365d; font-size: 14px;">
                                <fmt:formatNumber value="${room.tongTienDichVuPhong}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ
                            </strong>
                        </div>
                    </c:if>
                </div>

            </div>
        </c:forEach>
    </div>

    <!-- TỔNG KẾT TÀI CHÍNH TOÀN BỘ ĐƠN ĐẶT -->
    <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 22px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); margin-bottom: 25px;">
        <div style="display: grid; grid-template-columns: 1fr 380px; gap: 30px; align-items: center;">
            <div>
                <h4 style="color: #1a365d; margin: 0 0 6px 0; font-size: 16px; font-weight: 700;">
                    Tình Trạng Thanh Toán & Hóa Đơn
                </h4>
                <p style="color: #718096; font-size: 13px; margin: 0 0 8px 0; line-height: 1.5;">
                    Tổng chi phí sẽ được tự động cập nhật nếu phát sinh thêm dịch vụ trong thời gian lưu trú. Thanh toán được hoàn tất khi quý khách làm thủ tục Check-out tại quầy lễ tân.
                </p>
                <div style="font-size: 13px; color: #4a5568;">
                    Mã số hóa đơn: <strong>${bookingDetail.maHoaDon}</strong> &nbsp;|&nbsp; 
                    Trạng thái: 
                    <c:choose>
                        <c:when test="${bookingDetail.trangThaiHoaDon == 'DaThanhToan'}">
                            <span style="color: #276749; font-weight: 700;">Đã Thanh Toán Toàn Bộ</span>
                        </c:when>
                        <c:otherwise>
                            <span style="color: #b7791f; font-weight: 700;">Chưa Quyết Toán (Thanh toán tại quầy lễ tân)</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Bảng cộng dồn -->
            <div style="background: #f7fafc; border: 1px solid #edf2f7; border-radius: 6px; padding: 16px;">
                <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px;">
                    <span style="color: #718096;">Tổng tiền phòng:</span>
                    <strong style="color: #2d3748;">
                        <fmt:formatNumber value="${bookingDetail.tongTienPhong}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ
                    </strong>
                </div>

                <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 10px;">
                    <span style="color: #718096;">Tổng tiền dịch vụ:</span>
                    <strong style="color: #2d3748;">
                        <fmt:formatNumber value="${bookingDetail.tongTienDichVu}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ
                    </strong>
                </div>

                <div style="border-top: 1px solid #cbd5e0; padding-top: 10px; display: flex; justify-content: space-between; align-items: baseline;">
                    <span style="font-size: 14px; font-weight: 700; color: #1a365d;">Tổng Chi Phí:</span>
                    <div style="font-size: 20px; font-weight: 800; color: #c53030;">
                        <fmt:formatNumber value="${bookingDetail.tongChiPhiDuKien}" type="number" groupingUsed="true" maxFractionDigits="0"/> đ
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- HÀNG NÚT THAO TÁC CUỐI TRANG -->
    <div class="no-print" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
        <a href="${pageContext.request.contextPath}/customer/history" 
           style="color: #4a5568; background: #edf2f7; padding: 10px 18px; border-radius: 5px; text-decoration: none; font-size: 14px; font-weight: 600;">
            Quay Lại Lịch Sử Đặt Phòng
        </a>

        <!-- Nút hủy đơn nếu đủ điều kiện -->
        <c:if test="${bookingDetail.coTheHuy}">
            <form action="${pageContext.request.contextPath}/customer/history" method="POST"
                  onsubmit="return confirm('Quý khách có chắc chắn muốn hủy đơn đặt phòng [${bookingDetail.maBooking}] không? Sau khi hủy không thể hoàn tác.');"
                  style="margin: 0;">
                <input type="hidden" name="action" value="cancel">
                <input type="hidden" name="bookingId" value="${bookingDetail.maBooking}">
                <button type="submit" 
                        style="background: white; border: 1px solid #feb2b2; color: #e53e3e; padding: 10px 18px; border-radius: 5px; font-size: 14px; font-weight: 600; cursor: pointer;">
                    Hủy Toàn Bộ Đơn Đặt Phòng Này
                </button>
            </form>
        </c:if>
    </div>

</div>

<!-- MODAL THÊM DỊCH VỤ CHO PHÒNG CỤ THỂ -->
<div id="addServiceModal" class="modal-backdrop">
    <div class="modal-content">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">
            <h4 id="modalTitle" style="color: #1a365d; margin: 0; font-size: 16px; font-weight: 700;">
                Thêm Dịch Vụ Cho Phòng
            </h4>
            <button type="button" onclick="closeAddServiceModal()" 
                    style="background: none; border: none; font-size: 22px; cursor: pointer; color: #a0aec0; line-height: 1;">
                &times;
            </button>
        </div>

        <form action="${pageContext.request.contextPath}/customer/booking-detail/add-service" method="POST">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="bookingId" value="${bookingDetail.maBooking}">
            <input type="hidden" id="modalRoomId" name="roomId" value="">

            <div style="margin-bottom: 16px;">
                <label style="font-size: 13px; font-weight: 600; color: #4a5568; display: block; margin-bottom: 6px;">
                    Chọn Dịch Vụ:
                </label>
                <select id="modalServiceSelect" name="serviceId" required onchange="updateModalPricePreview()"
                        style="width: 100%; padding: 9px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; background: white;">
                    <option value="" data-price="0">-- Vui lòng chọn dịch vụ --</option>
                    <c:forEach var="svc" items="${activeServices}">
                        <option value="${svc.maDichVu}" data-price="${svc.donGia}">
                            ${svc.tenDichVu} (<fmt:formatNumber value="${svc.donGia}" type="number" groupingUsed="true"/> đ)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div style="margin-bottom: 18px;">
                <label style="font-size: 13px; font-weight: 600; color: #4a5568; display: block; margin-bottom: 6px;">
                    Số Lượng:
                </label>
                <input type="number" id="modalQuantity" name="quantity" min="1" max="50" value="1" required 
                       oninput="updateModalPricePreview()"
                       style="width: 100%; padding: 9px; border: 1px solid #cbd5e0; border-radius: 5px; font-size: 13px; box-sizing: border-box;">
            </div>

            <div style="background: #f7fafc; border: 1px solid #edf2f7; border-radius: 5px; padding: 12px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                <span style="font-size: 13px; color: #718096;">Thành tiền dự kiến:</span>
                <strong id="modalPricePreview" style="font-size: 16px; color: #2b6cb0;">0 đ</strong>
            </div>

            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                <button type="button" onclick="closeAddServiceModal()" 
                        style="background: #edf2f7; color: #4a5568; border: none; padding: 9px 16px; border-radius: 5px; font-size: 13px; font-weight: 600; cursor: pointer;">
                    Hủy Bỏ
                </button>
                <button type="submit" 
                        style="background: #1a365d; color: white; border: none; padding: 9px 18px; border-radius: 5px; font-size: 13px; font-weight: 700; cursor: pointer;">
                    Xác Nhận Thêm Dịch Vụ
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    function openAddServiceModal(roomId, roomNumber) {
        document.getElementById('modalRoomId').value = roomId;
        document.getElementById('modalTitle').innerText = 'Thêm Dịch Vụ Cho Phòng ' + roomNumber;
        document.getElementById('modalServiceSelect').selectedIndex = 0;
        document.getElementById('modalQuantity').value = 1;
        document.getElementById('modalPricePreview').innerText = '0 đ';
        document.getElementById('addServiceModal').style.display = 'flex';
    }

    function closeAddServiceModal() {
        document.getElementById('addServiceModal').style.display = 'none';
    }

    function updateModalPricePreview() {
        const select = document.getElementById('modalServiceSelect');
        const selectedOption = select.options[select.selectedIndex];
        const unitPrice = parseFloat(selectedOption.getAttribute('data-price')) || 0;
        const qty = parseInt(document.getElementById('modalQuantity').value) || 0;
        const total = unitPrice * qty;
        document.getElementById('modalPricePreview').innerText = total.toLocaleString('vi-VN') + ' đ';
    }

    window.onclick = function(event) {
        const modal = document.getElementById('addServiceModal');
        if (event.target === modal) {
            closeAddServiceModal();
        }
    };
</script>

<jsp:include page="/views/common/footer.jsp"/>
