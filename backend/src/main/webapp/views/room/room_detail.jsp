<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Chi Tiết ${room.soPhong} - ${room.tenLoaiPhong}" />
    <jsp:param name="zone" value="public" />
</jsp:include>
<jsp:include page="/views/common/navbar.jsp" />

<div class="public-container my-6">

    <!-- Breadcrumb điều hướng -->
    <div class="mb-4 text-xs text-muted">
        <a href="${pageContext.request.contextPath}/customer/home" class="text-primary">Trang Chủ</a>
        <span class="mx-2">/</span>
        <a href="${pageContext.request.contextPath}/customer/search-rooms?checkIn=${paramCheckIn}&checkOut=${paramCheckOut}" class="text-primary">Kết Quả Tìm Phòng</a>
        <span class="mx-2">/</span>
        <span class="text-main font-semibold">Chi Tiết ${room.soPhong}</span>
    </div>

    <!-- Header Tên phòng & Hạng phòng -->
    <div class="card p-4 mb-4">
        <div class="flex justify-between items-center flex-wrap gap-3">
            <div>
                <span class="badge badge-primary text-xs uppercase font-bold">
                    ${room.tenLoaiPhong}
                </span>
                <h1 class="text-primary font-bold text-2xl mt-2 mb-1">
                    ${room.soPhong} - ${room.tenLoaiPhong}
                </h1>
                <div class="text-xs text-muted flex gap-3 flex-wrap">
                    <span class="text-success font-semibold">Trạng thái: Sẵn sàng đón khách</span>
                </div>
            </div>
            <div class="text-right">
                <div class="text-xs text-muted">Đơn giá niêm yết:</div>
                <div class="text-2xl font-bold text-warning mono">
                    <fmt:formatNumber value="${room.donGia}" type="number" maxFractionDigits="0"/> đ
                </div>
                <div class="text-xs text-muted">/ phòng / đêm</div>
            </div>
        </div>
    </div>

    <!-- BỐ CỤC 2 CỘT: Cột trái Chi tiết 2/3 + Cột phải Tóm tắt 1/3 -->
    <div class="grid-content-sidebar">

        <!-- CỘT TRÁI: THÔNG SỐ, TIỆN ÍCH VÀ DỊCH VỤ MIỄN PHÍ -->
        <div>
            <!-- Banner minh họa phòng sang trọng với ảnh view phòng thực tế -->
            <div class="card p-0 mb-4 room-detail-hero-banner">
                <img src="${not empty room.hinhAnhMinhHoa ? room.hinhAnhMinhHoa : 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=1200&q=80'}"
                     alt="${room.tenLoaiPhong}"
                     class="room-detail-hero-img"
                     onerror="this.src='https://images.unsplash.com/photo-1618773928121-c32242e63f39?auto=format&fit=crop&w=800&q=80';" />
                <div class="room-detail-hero-overlay"></div>
                
                <div class="room-detail-hero-content flex flex-col justify-center items-center text-center p-4 text-inverse">
                    <div class="text-xs font-bold text-amber uppercase">
                        Không Gian Nghỉ Dưỡng Sang Trọng
                    </div>
                    <div class="text-2xl font-bold text-inverse mt-1">
                        ${room.soPhong}
                    </div>
                    <div class="text-sm text-muted mt-1">
                        ${room.tenLoaiPhong} &bull; Sức chứa ${room.soNguoiToiDa} khách &bull; Đầy đủ tiện nghi theo chuẩn khách sạn
                    </div>
                </div>
            </div>

            <!-- Khối 1: Thông số kỹ thuật chi tiết của phòng -->
            <div class="card p-4 mb-4">
                <h3 class="card-title border-bottom pb-2 mb-3">
                    Thông Số Kỹ Thuật &amp; Cấu Hình Phòng
                </h3>
                
                <div class="detail-grid">
                    <div class="card bg-surface-subtle p-3">
                        <div class="detail-label uppercase font-semibold">Hạng Phòng</div>
                        <div class="detail-value font-bold text-main mt-1">${room.tenLoaiPhong}</div>
                    </div>

                    <div class="card bg-surface-subtle p-3">
                        <div class="detail-label uppercase font-semibold">Sức Chứa Tối Đa</div>
                        <div class="detail-value font-bold text-main mt-1">${room.soNguoiToiDa} khách</div>
                    </div>

                    <div class="card bg-surface-subtle p-3">
                        <div class="detail-label uppercase font-semibold">Cấu Hình Giường</div>
                        <div class="detail-value font-bold text-main mt-1">${room.loaiGiuong}</div>
                    </div>

                    <div class="card bg-surface-subtle p-3">
                        <div class="detail-label uppercase font-semibold">Trạng Thái Phòng</div>
                        <div class="detail-value font-bold text-success mt-1">Sẵn Sàng Đón Khách</div>
                    </div>
                </div>
            </div>

            <!-- Khối 2: Các dịch vụ & Tiện ích đi kèm phòng từ CSDL 3NF -->
            <div class="card p-4 mb-4">
                <div class="flex justify-between items-center border-bottom pb-2 mb-3">
                    <h3 class="card-title mb-0">
                        Các Dịch Vụ &amp; Tiện Ích Đi Kèm Phòng
                    </h3>
                    <span class="badge badge-success text-xs font-bold">
                        Bao Gồm Trong Giá Phòng
                    </span>
                </div>

                <div class="grid-2">
                    <c:forEach var="tn" items="${room.danhSachTienNghi}">
                        <div class="card bg-surface-subtle p-3 flex items-center gap-2">
                            <span class="badge badge-success badge-sm">&#10003;</span>
                            <div>
                                <strong class="text-main text-sm">${tn}</strong>
                                <div class="text-xs text-muted">Trang bị sẵn sàng phục vụ kỳ nghỉ của quý khách.</div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty room.danhSachTienNghi}">
                        <div class="text-muted text-xs italic">
                            Phòng tiêu chuẩn trang bị đầy đủ nội thất cơ bản theo chuẩn khách sạn.
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Khối 3: Nội quy & Chính sách nhận trả phòng -->
            <div class="card p-4">
                <h3 class="card-title border-bottom pb-2 mb-3">
                    Chính Sách Nhận Phòng &amp; Lưu Ý
                </h3>
                <ul class="text-secondary text-sm leading-relaxed" style="padding-left: var(--space-4);">
                    <li><strong>Giờ nhận phòng tiêu chuẩn:</strong> Từ 14:00 chiều ngày nhận phòng.</li>
                    <li><strong>Giờ trả phòng tiêu chuẩn:</strong> Trước 12:00 trưa ngày trả phòng.</li>
                    <li><strong>Hủy phòng:</strong> Miễn phí hủy phòng trước 24 giờ trước thời điểm nhận phòng.</li>
                    <li>Không hút thuốc lá trong phòng nghỉ; vui lòng xuất trình CCCD/Hộ chiếu khi làm thủ tục tại quầy lễ tân.</li>
                </ul>
            </div>
        </div>

        <!-- CỘT PHẢI: BẢNG TỔNG KẾT VÀ NÚT ĐẶT PHÒNG (STICKY SUMMARY) -->
        <div>
            <div class="card p-4" style="position: sticky; top: 20px;">
                <h3 class="card-title border-bottom pb-2 mb-3">
                    Tóm Tắt Đặt Phòng Này
                </h3>

                <div class="text-secondary text-sm leading-relaxed mb-4">
                    <div class="flex justify-between py-1">
                        <span class="text-muted">Phòng số:</span>
                        <strong class="text-primary">${room.soPhong}</strong>
                    </div>
                    <div class="flex justify-between py-1">
                        <span class="text-muted">Hạng phòng:</span>
                        <strong class="text-main">${room.tenLoaiPhong}</strong>
                    </div>
                    <div class="flex justify-between py-1">
                        <span class="text-muted">Ngày nhận:</span>
                        <strong class="text-main">${room.ngayNhan}</strong>
                    </div>
                    <div class="flex justify-between py-1">
                        <span class="text-muted">Ngày trả:</span>
                        <strong class="text-main">${room.ngayTra}</strong>
                    </div>
                    <div class="flex justify-between py-1">
                        <span class="text-muted">Số đêm ở:</span>
                        <strong class="text-warning font-bold">${room.soDem} đêm</strong>
                    </div>
                </div>

                <div class="border-top pt-3 mb-4">
                    <div class="flex justify-between text-xs text-muted mb-1">
                        <span>Đơn giá/đêm:</span>
                        <span class="mono"><fmt:formatNumber value="${room.donGia}" type="number" maxFractionDigits="0"/> đ</span>
                    </div>
                    <div class="flex justify-between items-baseline font-bold text-main text-base">
                        <span>Tiền phòng dự kiến:</span>
                        <span class="text-warning text-xl mono font-bold">
                            <fmt:formatNumber value="${room.tongTienDuKien}" type="number" maxFractionDigits="0"/> đ
                        </span>
                    </div>
                    <div class="text-xs text-muted text-right mt-1">
                        (Chưa bao gồm các dịch vụ bổ sung tùy chọn)
                    </div>
                </div>

                <!-- Nút Đặt Phòng Này hoặc cảnh báo đã có khách -->
                <c:choose>
                    <c:when test="${isAvailable}">
                        <a href="${pageContext.request.contextPath}/customer/booking?action=prepare&maPhong=${room.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                           class="btn btn-primary w-full mb-2">
                            Đặt Phòng Này
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-danger text-center font-bold text-xs mb-2">
                            Phòng đã có khách đặt trong khoảng thời gian này
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Nút Quay lại danh sách tìm kiếm -->
                <a href="${pageContext.request.contextPath}/customer/search-rooms?checkIn=${paramCheckIn}&checkOut=${paramCheckOut}"
                   class="btn btn-outline w-full">
                    Quay Lại Danh Sách Phòng
                </a>
            </div>
        </div>

    </div>

</div>

<jsp:include page="/views/common/footer.jsp" />
