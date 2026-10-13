<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Thanh Toán Đặt Cọc - ${bookingDetail.maBooking}"/>
</jsp:include>
<jsp:include page="/views/common/navbar.jsp"/>

<div class="container" style="max-width: 1100px; margin-top: 30px; margin-bottom: 60px;">

    <!-- Breadcrumb dẫn hướng -->
    <div style="font-size: 13px; color: #718096; margin-bottom: 24px;">
        <a href="${pageContext.request.contextPath}/customer/home" style="color: #2b6cb0; text-decoration: none;">Trang Chủ</a>
        &nbsp;&rsaquo;&nbsp;
        <a href="${pageContext.request.contextPath}/customer/history" style="color: #2b6cb0; text-decoration: none;">Lịch Sử Đặt Phòng</a>
        &nbsp;&rsaquo;&nbsp;
        <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${bookingDetail.maBooking}" style="color: #2b6cb0; text-decoration: none;">Đơn Đặt ${bookingDetail.maBooking}</a>
        &nbsp;&rsaquo;&nbsp;
        <span style="color: #4a5568; font-weight: 600;">Thanh Toán Tiền Cọc</span>
    </div>

    <!-- Thông báo lỗi (nếu có) -->
    <c:if test="${not empty errorMessage}">
        <div style="background: #fff5f5; border-left: 4px solid #e53e3e; color: #c53030; padding: 14px 18px; border-radius: 6px; margin-bottom: 24px; font-size: 14px; font-weight: 600;">
            ${errorMessage}
        </div>
    </c:if>

    <!-- Tiêu đề trang -->
    <div style="background: linear-gradient(135deg, #1a365d 0%, #2b6cb0 100%); color: white; padding: 24px 28px; border-radius: 8px; margin-bottom: 25px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.07);">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <h2 style="margin: 0 0 6px 0; font-size: 22px; font-weight: 700; color: white;">
                    Xác Nhận Đặt Cọc Giữ Chỗ Phòng
                </h2>
                <div style="font-size: 13px; color: #e2e8f0;">
                    Mã đơn đặt phòng: <strong>${bookingDetail.maBooking}</strong> &nbsp;|&nbsp; 
                    Khách hàng: <strong>${bookingDetail.hoTenKhachHang}</strong> (${bookingDetail.soDT})
                </div>
            </div>
            <div style="background: rgba(255, 255, 255, 0.15); border: 1px solid rgba(255, 255, 255, 0.25); padding: 8px 16px; border-radius: 6px; font-size: 13px; text-align: right;">
                <span style="display: block; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.85;">Thời hạn hoàn tất cọc</span>
                <strong style="font-size: 15px; color: #feebc8;">10 Phút Giữ Chỗ</strong>
            </div>
        </div>
    </div>

    <!-- Bố cục 2 cột -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 24px; align-items: start;">

        <!-- CỘT TRÁI: THÔNG TIN ĐƠN ĐẶT VÀ CHI PHÍ CỌC -->
        <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);">
            <h3 style="font-size: 16px; font-weight: 700; color: #1a365d; margin: 0 0 16px 0; border-bottom: 2px solid #edf2f7; padding-bottom: 10px;">
                Chi Tiết Tiền Cọc Theo Phòng
            </h3>

            <div style="margin-bottom: 20px;">
                <c:forEach var="room" items="${bookingDetail.danhSachPhong}" varStatus="status">
                    <div style="border: 1px solid #edf2f7; border-radius: 6px; padding: 14px; margin-bottom: 12px; background: #f7fafc;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                            <strong style="color: #2d3748; font-size: 14px;">
                                Phòng ${room.soPhong} <span style="font-size: 12px; color: #718096; font-weight: 500;">(${room.tenLoaiPhong})</span>
                            </strong>
                            <span style="font-size: 12px; color: #4a5568; background: #edf2f7; padding: 2px 8px; border-radius: 4px;">
                                ${room.soDem} đêm
                            </span>
                        </div>
                        <div style="font-size: 12px; color: #718096; margin-bottom: 8px;">
                            Nhận phòng: <fmt:formatDate value="${room.ngayNhanDuKien}" pattern="dd/MM/yyyy"/> &rarr; Trả phòng: <fmt:formatDate value="${room.ngayTraDuKien}" pattern="dd/MM/yyyy"/>
                        </div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px; border-top: 1px dashed #e2e8f0; padding-top: 8px;">
                            <span style="color: #718096;">Tiền phòng:</span>
                            <span style="color: #4a5568; font-weight: 600;">
                                <fmt:formatNumber value="${room.tienPhong}" type="number" groupingUsed="true"/> đ
                            </span>
                        </div>
                        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-top: 4px;">
                            <span style="color: #2b6cb0; font-weight: 600;">Số tiền cọc cần nộp:</span>
                            <strong style="color: #2b6cb0;">
                                <fmt:formatNumber value="${room.tienCoc}" type="number" groupingUsed="true"/> đ
                            </strong>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Tổng kết tài chính -->
            <div style="background: #ebf8ff; border: 1px solid #bee3f8; border-radius: 6px; padding: 16px; margin-bottom: 16px;">
                <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px; color: #4a5568;">
                    <span>Tổng tiền phòng:</span>
                    <strong><fmt:formatNumber value="${bookingDetail.tongTienPhong}" type="number" groupingUsed="true"/> đ</strong>
                </div>
                <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px; color: #4a5568;">
                    <span>Tổng tiền dịch vụ:</span>
                    <strong><fmt:formatNumber value="${bookingDetail.tongTienDichVu}" type="number" groupingUsed="true"/> đ</strong>
                </div>
                <div style="border-top: 1px solid #cbd5e0; padding-top: 10px; margin-top: 6px; display: flex; justify-content: space-between; align-items: baseline;">
                    <div>
                        <strong style="font-size: 14px; color: #1a365d; display: block;">SỐ TIỀN CỌC CẦN THANH TOÁN:</strong>
                        <span style="font-size: 11px; color: #718096;">(Thanh toán phần còn lại khi Check-out)</span>
                    </div>
                    <div style="font-size: 22px; font-weight: 800; color: #c53030;">
                        <fmt:formatNumber value="${bookingDetail.tongTienCoc}" type="number" groupingUsed="true"/> đ
                    </div>
                </div>
            </div>

            <div style="font-size: 12px; color: #718096; line-height: 1.5; background: #fffaf0; border: 1px solid #feebc8; border-radius: 6px; padding: 12px;">
                <strong style="color: #dd6b20;">Lưu ý về quy định giữ chỗ:</strong> Hệ thống tự động khóa giữ phòng trong vòng <strong>10 phút</strong> kể từ khi tạo đơn. Sau khi chuyển khoản thành công, vui lòng nhấn nút xác nhận bên cạnh để hệ thống ghi nhận giao dịch nộp cọc.
            </div>
        </div>

        <!-- CỘT PHẢI: QUÉT MÃ VIETQR VÀ NÚT XÁC NHẬN -->
        <div style="background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 24px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04); text-align: center;">
            <h3 style="font-size: 16px; font-weight: 700; color: #1a365d; margin: 0 0 16px 0; border-bottom: 2px solid #edf2f7; padding-bottom: 10px;">
                Quét Mã QR Chuyển Khoản Nhanh
            </h3>

            <!-- VietQR Code Image -->
            <div style="background: #f7fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0; display: inline-block; margin-bottom: 18px; max-width: 100%;">
                <img src="https://img.vietqr.io/image/MB-0333884549-compact2.png?amount=${bookingDetail.tongTienCoc}&addInfo=COC%20${bookingDetail.maBooking}&accountName=HOTEL%20MANAGEMENT%20SYSTEM"
                     alt="Mã QR Chuyển Khoản Đặt Cọc"
                     style="width: 280px; max-width: 100%; height: auto; display: block; border-radius: 4px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);">
                <div style="margin-top: 8px; font-size: 11px; color: #718096;">
                    Mở ứng dụng Ngân hàng (App Banking) bất kỳ để quét mã
                </div>
            </div>

            <!-- Bảng chi tiết tài khoản thụ hưởng -->
            <div style="text-align: left; background: #f7fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 14px; margin-bottom: 20px; font-size: 13px;">
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span style="color: #718096;">Ngân hàng:</span>
                    <strong style="color: #2d3748;">MB Bank (Ngân Hàng TMCP Quân Đội)</strong>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span style="color: #718096;">Số tài khoản:</span>
                    <strong style="color: #1a365d; font-size: 14px; font-family: monospace;">0333884549</strong>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span style="color: #718096;">Chủ tài khoản:</span>
                    <strong style="color: #2d3748;">HOTEL MANAGEMENT SYSTEM</strong>
                </div>
                <div style="display: flex; justify-content: space-between; margin-bottom: 6px;">
                    <span style="color: #718096;">Số tiền cọc:</span>
                    <strong style="color: #c53030; font-size: 14px;">
                        <fmt:formatNumber value="${bookingDetail.tongTienCoc}" type="number" groupingUsed="true"/> đ
                    </strong>
                </div>
                <div style="display: flex; justify-content: space-between; border-top: 1px dashed #cbd5e0; padding-top: 6px; margin-top: 6px;">
                    <span style="color: #718096;">Nội dung CK:</span>
                    <strong style="color: #2b6cb0; font-size: 14px; font-family: monospace;">COC ${bookingDetail.maBooking}</strong>
                </div>
            </div>

            <!-- Nút bấm xác nhận thanh toán -->
            <form action="${pageContext.request.contextPath}/customer/deposit" method="POST" style="margin: 0;">
                <input type="hidden" name="bookingId" value="${bookingDetail.maBooking}">
                <input type="hidden" name="paymentMethod" value="BankTransfer">

                <button type="submit"
                        style="width: 100%; background: #2f855a; color: white; border: none; padding: 14px 20px; border-radius: 6px; font-size: 15px; font-weight: 700; cursor: pointer; box-shadow: 0 4px 6px rgba(47, 133, 90, 0.25); transition: background 0.2s;"
                        onmouseover="this.style.background='#276749'"
                        onmouseout="this.style.background='#2f855a'">
                    Tôi Đã Hoàn Tất Chuyển Khoản
                </button>
            </form>

            <div style="margin-top: 14px;">
                <a href="${pageContext.request.contextPath}/customer/booking-detail?bookingId=${bookingDetail.maBooking}"
                   style="color: #718096; font-size: 13px; text-decoration: none;">
                    &larr; Xem lại chi tiết đơn đặt phòng
                </a>
            </div>
        </div>

    </div>

</div>

<jsp:include page="/views/common/footer.jsp"/>
