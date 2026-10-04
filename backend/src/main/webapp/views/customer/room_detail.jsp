<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Chi Tiết Phòng ${room.soPhong} - ${room.tenLoaiPhong}" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="container" style="max-width: 1200px; margin-top: 25px; margin-bottom: 90px;">

    <!-- Breadcrumb điều hướng -->
    <div style="margin-bottom: 20px; font-size: 13px; color: #718096;">
        <a href="${pageContext.request.contextPath}/customer/home" style="color: #2b6cb0; text-decoration: none;">Trang Chủ</a>
        <span style="margin: 0 8px;">/</span>
        <a href="${pageContext.request.contextPath}/customer/search-rooms?checkIn=${paramCheckIn}&checkOut=${paramCheckOut}" style="color: #2b6cb0; text-decoration: none;">Kết Quả Tìm Phòng</a>
        <span style="margin: 0 8px;">/</span>
        <span style="color: #2d3748; font-weight: 600;">Chi Tiết Phòng ${room.soPhong}</span>
    </div>

    <!-- Header Tên phòng & Hạng phòng -->
    <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px 28px; box-shadow: 0 1px 4px rgba(0,0,0,0.05); margin-bottom: 25px;">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
            <div>
                <span style="background: #1a365d; color: white; font-size: 11px; font-weight: 700; padding: 3px 10px; border-radius: 3px; text-transform: uppercase;">
                    ${room.tenLoaiPhong}
                </span>
                <h1 style="color: #1a365d; margin: 8px 0 6px 0; font-size: 26px; font-weight: 700;">
                    Phòng ${room.soPhong} - ${room.tenLoaiPhong}
                </h1>
                <div style="font-size: 13px; color: #718096; display: flex; gap: 15px; flex-wrap: wrap;">
                    <span>Tiêu chuẩn nghỉ dưỡng 5 sao</span>
                    <span>&bull;</span>
                    <span>Đánh giá xuất sắc 9.6/10</span>
                    <span>&bull;</span>
                    <span style="color: #276749; font-weight: 600;">Trạng thái: Sẵn sàng phục vụ</span>
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
                        Không Gian Nghỉ Dưỡng Thượng Lưu
                    </div>
                    <div style="font-size: 28px; font-weight: 700; margin-top: 6px;">
                        Phòng Nghỉ ${room.soPhong}
                    </div>
                    <div style="font-size: 14px; color: #e2e8f0; margin-top: 6px;">
                        Thiết kế sang trọng &bull; Ban công thoáng đãng &bull; Đầy đủ tiện nghi cao cấp
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
                            Kích Thước / Diện Tích
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #2d3748; margin-top: 4px;">
                            ${room.dienTich} m²
                        </div>
                    </div>

                    <div style="background: #f7fafc; padding: 14px 16px; border-radius: 6px; border: 1px solid #edf2f7;">
                        <div style="font-size: 12px; color: #718096; font-weight: 600; text-transform: uppercase;">
                            Sức Chứa Tối Đa
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #2d3748; margin-top: 4px;">
                            ${room.soNguoiToiDa} người lớn (+ 1 trẻ em)
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
                            Hướng Nhìn / View
                        </div>
                        <div style="font-size: 16px; font-weight: 700; color: #2d3748; margin-top: 4px;">
                            Hướng Biển / Ban Công Thoáng
                        </div>
                    </div>
                </div>

                <c:if test="${not empty room.moTa}">
                    <div style="margin-top: 18px; font-size: 14px; color: #4a5568; line-height: 1.6; background: #fffaf0; padding: 12px 16px; border-radius: 6px; border: 1px solid #feebc8;">
                        <strong>Mô tả chi tiết:</strong> ${room.moTa}
                    </div>
                </c:if>
            </div>

            <!-- Khối 2: Các dịch vụ & Tiện ích MIỄN PHÍ đi kèm phòng -->
            <div style="background: white; border-radius: 8px; border: 1px solid #e2e8f0; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.04); margin-bottom: 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #edf2f7; padding-bottom: 10px; margin-bottom: 18px;">
                    <h3 style="color: #1a365d; font-size: 17px; margin: 0; font-weight: 700;">
                        Các Dịch Vụ & Tiện Ích Miễn Phí Đi Kèm Phòng
                    </h3>
                    <span style="background: #f0fff4; color: #276749; border: 1px solid #9ae6b4; font-size: 12px; font-weight: 700; padding: 3px 8px; border-radius: 3px;">
                        Bao Gồm Trong Giá Phòng
                    </span>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px;">
                    
                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                        <div>
                            <strong style="color: #2d3748; font-size: 14px;">Bữa sáng buffet tự chọn:</strong>
                            <div style="font-size: 13px; color: #718096;">Phục vụ hàng ngày từ 06:30 đến 09:30 tại nhà hàng trung tâm.</div>
                        </div>
                    </div>

                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                        <div>
                            <strong style="color: #2d3748; font-size: 14px;">Nước khoáng & Trà/Cà phê setup:</strong>
                            <div style="font-size: 13px; color: #718096;">02 chai nước suối tinh khiết và gói trà/cà phê bổ sung mỗi ngày.</div>
                        </div>
                    </div>

                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                        <div>
                            <strong style="color: #2d3748; font-size: 14px;">Hồ bơi vô cực & Phòng Gym:</strong>
                            <div style="font-size: 13px; color: #718096;">Sử dụng miễn phí không giới hạn trong suốt kỳ lưu trú.</div>
                        </div>
                    </div>

                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                        <div>
                            <strong style="color: #2d3748; font-size: 14px;">Internet Wifi tốc độ cao:</strong>
                            <div style="font-size: 13px; color: #718096;">Phủ sóng cáp quang toàn bộ khuôn viên và trong phòng nghỉ.</div>
                        </div>
                    </div>

                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                        <div>
                            <strong style="color: #2d3748; font-size: 14px;">Dọn phòng & Thay khăn hàng ngày:</strong>
                            <div style="font-size: 13px; color: #718096;">Đội ngũ Housekeeping phục vụ tiêu chuẩn vệ sinh 5 sao.</div>
                        </div>
                    </div>

                    <div style="display: flex; align-items: flex-start; gap: 10px;">
                        <span style="color: #276749; font-weight: 700; font-size: 16px; line-height: 1;">✓</span>
                        <div>
                            <strong style="color: #2d3748; font-size: 14px;">Tiện nghi phòng tắm cao cấp:</strong>
                            <div style="font-size: 13px; color: #718096;">Áo choàng tắm, máy sấy tóc, két sắt an toàn và đồ dùng cá nhân.</div>
                        </div>
                    </div>
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
                        <strong style="color: #1a365d;">Phòng ${room.soPhong}</strong>
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

                <!-- Nút Đặt Phòng Này dẫn sang Bước 4 (Trang Điền Thông Tin) -->
                <a href="${pageContext.request.contextPath}/customer/booking?action=prepare&maPhong=${room.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                   style="display: block; width: 100%; box-sizing: border-box; background: #dd6b20; color: white; text-align: center; text-decoration: none; padding: 12px 16px; border-radius: 5px; font-size: 15px; font-weight: 700; transition: background 0.2s; margin-bottom: 10px;"
                   onmouseover="this.style.background='#c05621'" onmouseout="this.style.background='#dd6b20'">
                    Đặt Phòng Này
                </a>

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
