<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Chi Tiết ${room.soPhong} - ${room.tenLoaiPhong}" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="container" style="max-width: 1200px; margin-top: 25px; margin-bottom: 90px;">

    <!-- Breadcrumb điều hướng -->
    <div style="margin-bottom: 20px; font-size: 13px; color: #718096;">
        <a href="${pageContext.request.contextPath}/customer/home" style="color: #2b6cb0; text-decoration: none;">Trang Chủ</a>
        <span style="margin: 0 8px;">/</span>
        <a href="${pageContext.request.contextPath}/customer/search-rooms?checkIn=${paramCheckIn}&checkOut=${paramCheckOut}" style="color: #2b6cb0; text-decoration: none;">Kết Quả Tìm Phòng</a>
        <span style="margin: 0 8px;">/</span>
        <span style="color: #2d3748; font-weight: 600;">Chi Tiết ${room.soPhong}</span>
    </div>

    <!-- Header Tên phòng & Hạng phòng -->
    <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px 28px; box-shadow: 0 1px 4px rgba(0,0,0,0.05); margin-bottom: 25px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <span style="background: #1a365d; color: white; font-size: 11px; font-weight: 700; padding: 3px 10px; border-radius: 3px; text-transform: uppercase;">
                    ${room.tenLoaiPhong}
                </span>
                <h1 style="color: #1a365d; margin: 8px 0 6px 0; font-size: 26px; font-weight: 700;">
                    ${room.soPhong} - ${room.tenLoaiPhong}
                </h1>
                <div style="font-size: 13px; color: #718096; display: flex; gap: 15px; flex-wrap: wrap;">
                    <span style="color: #276749; font-weight: 600;">✓ Trạng thái: Sẵn sàng đón khách</span>
                </div>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 12px; color: #718096;">Đơn giá niêm yết:</div>
                <div style="font-size: 26px; font-weight: 700; color: #dd6b20;">
                    <fmt:formatNumber value="${room.donGia}" type="number" maxFractionDigits="0"/> đ
                </div>
                <div style="font-size: 12px; color: #a0aec0;">/ phòng / đêm</div>
            </div>
        </div>
    </div>

    <!-- BỐ CỤC 2 CỘT: Cột trái Thông tin chi tiết + Cột phải Tóm tắt đặt phòng -->
    <div style="display: flex; gap: 25px; align-items: flex-start; flex-wrap: wrap;">

        <!-- CỘT TRÁI: THÔNG SỐ, TIỆN ÍCH VÀ DỊCH VỤ MIỄN PHÍ -->
        <div style="flex: 1; min-width: 650px;">
            
            <!-- Banner minh họa phòng sang trọng -->
            <div style="background: linear-gradient(135deg, #1a365d 0%, #2b6cb0 100%); height: 220px; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: white; margin-bottom: 25px; box-shadow: inset 0 0 40px rgba(0,0,0,0.2);">
                <div style="text-align: center; padding: 20px;">
                    <div style="font-size: 13px; font-weight: 700; color: #fbd38d; text-transform: uppercase; letter-spacing: 1px;">
                        Không Gian Nghỉ Dưỡng Sang Trọng
                    </div>
                    <div style="font-size: 28px; font-weight: 700; margin-top: 6px;">
                        ${room.soPhong}
                    </div>
                    <div style="font-size: 14px; color: #e2e8f0; margin-top: 6px;">
                        ${room.tenLoaiPhong} &bull; Sức chứa ${room.soNguoiToiDa} khách &bull; Đầy đủ tiện nghi theo chuẩn khách sạn
                    </div>
                </div>
            </div>

            <!-- Khối 1: Thông số kỹ thuật chi tiết của phòng -->
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                <h3 style="color: #1a365d; font-size: 17px; margin: 0 0 18px 0; font-weight: 700; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">
                    Thông Số Kỹ Thuật & Cấu Hình Phòng
                </h3>
                
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px;">
                    
                    <div style="background: #f7fafc; padding: 14px 16px; border-radius: 6px; border: 1px solid #edf2f7;">
                        <div style="font-size: 12px; color: #718096; font-weight: 600; text-transform: uppercase;">
                            Hạng Phòng
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #2d3748; margin-top: 4px;">
                            ${room.tenLoaiPhong}
                        </div>
                    </div>

                    <div style="background: #f7fafc; padding: 14px 16px; border-radius: 6px; border: 1px solid #edf2f7;">
                        <div style="font-size: 12px; color: #718096; font-weight: 600; text-transform: uppercase;">
                            Sức Chứa Tối Đa
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #2d3748; margin-top: 4px;">
                            ${room.soNguoiToiDa} khách
                        </div>
                    </div>

                    <div style="background: #f7fafc; padding: 14px 16px; border-radius: 6px; border: 1px solid #edf2f7;">
                        <div style="font-size: 12px; color: #718096; font-weight: 600; text-transform: uppercase;">
                            Cấu Hình Giường
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #2d3748; margin-top: 4px;">
                            ${room.loaiGiuong}
                        </div>
                    </div>

                    <div style="background: #f7fafc; padding: 14px 16px; border-radius: 6px; border: 1px solid #edf2f7;">
                        <div style="font-size: 12px; color: #718096; font-weight: 600; text-transform: uppercase;">
                            Trạng Thái Phòng
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #276749; margin-top: 4px;">
                            Sẵn Sàng Đón Khách
                        </div>
                    </div>
                </div>
            </div>

            <!-- Khối 2: Các dịch vụ & Tiện ích đi kèm phòng từ CSDL 3NF -->
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #edf2f7; padding-bottom: 10px; margin-bottom: 18px;">
                    <h3 style="color: #1a365d; font-size: 17px; margin: 0; font-weight: 700;">
                        Các Dịch Vụ & Tiện Ích Đi Kèm Phòng
                    </h3>
                    <span style="background: #f0fff4; color: #276749; border: 1px solid #9ae6b4; font-size: 12px; font-weight: 700; padding: 3px 8px; border-radius: 3px;">
                        Bao Gồm Trong Giá Phòng
                    </span>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px;">
                    <c:forEach var="tn" items="${room.danhSachTienNghi}">
                        <div style="display: flex; align-items: center; gap: 10px; background: #f7fafc; padding: 12px 16px; border-radius: 6px; border: 1px solid #edf2f7;">
                            <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                            <div>
                                <strong style="color: #2d3748; font-size: 14px;">${tn}</strong>
                                <div style="font-size: 12px; color: #718096;">Trang bị sẵn sàng phục vụ kỳ nghỉ của quý khách.</div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty room.danhSachTienNghi}">
                        <div style="font-size: 13px; color: #718096; font-style: italic;">
                            Phòng tiêu chuẩn trang bị đầy đủ nội thất cơ bản theo chuẩn khách sạn.
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Khối 3: Nội quy & Chính sách nhận trả phòng -->
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);">
                <h3 style="color: #1a365d; font-size: 17px; margin: 0 0 14px 0; font-weight: 700; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">
                    Chính Sách Nhận Phòng & Lưu Ý
                </h3>
                <ul style="margin: 0; padding-left: 20px; font-size: 13px; color: #4a5568; line-height: 1.8;">
                    <li><strong>Giờ nhận phòng tiêu chuẩn:</strong> Từ 14:00 chiều ngày nhận phòng.</li>
                    <li><strong>Giờ trả phòng tiêu chuẩn:</strong> Trước 12:00 trưa ngày trả phòng.</li>
                    <li><strong>Hủy phòng:</strong> Miễn phí hủy phòng trước 24 giờ trước thời điểm nhận phòng.</li>
                    <li>Không hút thuốc lá trong phòng nghỉ; vui lòng xuất trình CCCD/Hộ chiếu khi làm thủ tục tại quầy lễ tân.</li>
                </ul>
            </div>

        </div>

        <!-- CỘT PHẢI: BẢNG TỔNG KẾT VÀ NÚT ĐẶT PHÒNG (STICKY SUMMARY) -->
        <div style="flex: 0 0 340px; width: 340px;">
            <div style="background: white; border-radius: 8px; border: 1px solid #d2d6dc; padding: 22px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); position: sticky; top: 20px;">
                
                <h3 style="color: #1a365d; font-size: 17px; margin: 0 0 14px 0; font-weight: 700; border-bottom: 1px solid #edf2f7; padding-bottom: 10px;">
                    Tóm Tắt Đặt Phòng Này
                </h3>

                <div style="font-size: 13px; color: #4a5568; margin-bottom: 16px; line-height: 1.8;">
                    <div style="display: flex; justify-content: space-between;">
                        <span>Phòng số:</span>
                        <strong style="color: #1a365d;">${room.soPhong}</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>Hạng phòng:</span>
                        <strong>${room.tenLoaiPhong}</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>Ngày nhận:</span>
                        <strong>${room.ngayNhan}</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>Ngày trả:</span>
                        <strong>${room.ngayTra}</strong>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>Số đêm ở:</span>
                        <strong style="color: #dd6b20;">${room.soDem} đêm</strong>
                    </div>
                </div>

                <div style="border-top: 1px dashed #cbd5e0; padding-top: 14px; margin-bottom: 18px;">
                    <div style="display: flex; justify-content: space-between; font-size: 13px; color: #718096; margin-bottom: 6px;">
                        <span>Đơn giá/đêm:</span>
                        <span><fmt:formatNumber value="${room.donGia}" type="number" maxFractionDigits="0"/> đ</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; font-size: 16px; font-weight: 700; color: #1a365d;">
                        <span>Tiền phòng dự kiến:</span>
                        <span style="color: #dd6b20; font-size: 20px;">
                            <fmt:formatNumber value="${room.tongTienDuKien}" type="number" maxFractionDigits="0"/> đ
                        </span>
                    </div>
                    <div style="font-size: 11px; color: #a0aec0; text-align: right; margin-top: 2px;">
                        (Chưa bao gồm các dịch vụ bổ sung tùy chọn)
                    </div>
                </div>

                <!-- Nút Đặt Phòng Này hoặc cảnh báo đã có khách -->
                <c:choose>
                    <c:when test="${isAvailable}">
                        <a href="${pageContext.request.contextPath}/customer/booking?action=prepare&maPhong=${room.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                           style="display: block; width: 100%; box-sizing: border-box; background: #dd6b20; color: white; text-align: center; text-decoration: none; padding: 12px 16px; border-radius: 5px; font-size: 15px; font-weight: 700; transition: background 0.2s; margin-bottom: 10px;"
                           onmouseover="this.style.background='#c05621'" onmouseout="this.style.background='#dd6b20'">
                            Đặt Phòng Này
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div style="background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; padding: 12px; border-radius: 5px; font-size: 13px; font-weight: 700; text-align: center; margin-bottom: 10px;">
                            Phòng đã có khách đặt trong khoảng thời gian này
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Nút Quay lại danh sách tìm kiếm -->
                <a href="${pageContext.request.contextPath}/customer/search-rooms?checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                   style="display: block; width: 100%; box-sizing: border-box; background: #edf2f7; color: #4a5568; text-align: center; text-decoration: none; padding: 10px 16px; border-radius: 5px; font-size: 13px; font-weight: 600; transition: background 0.2s;"
                   onmouseover="this.style.background='#e2e8f0'" onmouseout="this.style.background='#edf2f7'">
                    Quay Lại Danh Sách Phòng
                </a>

            </div>
        </div>

    </div>

</div>

<jsp:include page="/views/common/footer.jsp" />
