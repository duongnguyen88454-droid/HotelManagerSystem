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
                                            <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                                <button type="button" class="portal-btn portal-btn-secondary btn-view-damage" style="padding: 7px 12px; font-size: 12.5px;"
                                                        data-mabaocao="${item.maBaoCao}"
                                                        data-sophong="${item.soPhong}"
                                                        data-maphong="${item.maPhong}"
                                                        data-tenloaiphong="${item.tenLoaiPhong}"
                                                        data-tenloaihuhai="${item.tenLoaiHuHai}"
                                                        data-motachitiet="<c:out value='${item.moTaChiTiet}' />"
                                                        data-nhanvien="<c:out value='${item.nhanVienPhatHien}' />"
                                                        data-ngay="<c:out value='${item.ngayPhatHien}' />"
                                                        data-trangthai="${item.trangThaiBaoCao}">
                                                    Chi Tiết
                                                </button>
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
                                            </div>
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

<!-- Modal Xem Chi Tiết Báo Cáo Hư Hại -->
<div id="damageDetailModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.6); z-index: 9999; align-items: center; justify-content: center;">
    <div style="background: #ffffff; border-radius: 12px; width: 560px; max-width: 92%; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); overflow: hidden;">
        <div style="padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #f8fafc;">
            <h3 style="margin: 0; font-size: 17px; font-weight: 700; color: #0f172a;">
                Chi Tiết Sự Cố &amp; Báo Cáo Hư Hại
            </h3>
            <button type="button" onclick="closeDamageModal()" style="background: transparent; border: none; font-size: 20px; cursor: pointer; color: #64748b;">&times;</button>
        </div>
        <div style="padding: 24px; font-size: 14px; line-height: 1.6; color: #334155;">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div style="background: #f1f5f9; padding: 12px; border-radius: 8px;">
                    <div style="font-size: 12px; color: #64748b; font-weight: 600;">MÃ BIÊN BẢN</div>
                    <div id="modalReportId" style="font-size: 15px; font-weight: 700; color: #2563eb; margin-top: 2px;"></div>
                </div>
                <div style="background: #f1f5f9; padding: 12px; border-radius: 8px;">
                    <div style="font-size: 12px; color: #64748b; font-weight: 600;">TRẠNG THÁI HIỆN TẠI</div>
                    <div id="modalStatus" style="font-size: 14px; font-weight: 700; margin-top: 2px;"></div>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div style="border: 1px solid #e2e8f0; padding: 12px; border-radius: 8px;">
                    <div style="font-size: 12px; color: #64748b; font-weight: 600;">THÔNG TIN PHÒNG</div>
                    <div id="modalRoomInfo" style="font-weight: 700; color: #0f172a; margin-top: 2px; font-size: 15px;"></div>
                    <div id="modalRoomType" style="color: #64748b; font-size: 13px;"></div>
                </div>
                <div style="border: 1px solid #e2e8f0; padding: 12px; border-radius: 8px;">
                    <div style="font-size: 12px; color: #64748b; font-weight: 600;">LOẠI THIẾT BỊ HƯ HỎNG</div>
                    <div id="modalDamageType" style="font-weight: 700; color: #dc2626; margin-top: 2px; font-size: 15px;"></div>
                </div>
            </div>

            <div style="border: 1px solid #e2e8f0; padding: 14px; border-radius: 8px; margin-bottom: 16px; background: #fafafa;">
                <div style="font-size: 12px; color: #64748b; font-weight: 600; margin-bottom: 4px;">MÔ TẢ CHI TIẾT SỰ CỐ TỪ HOUSEKEEPER:</div>
                <div id="modalDescription" style="color: #1e293b; font-size: 14px; white-space: pre-wrap;"></div>
            </div>

            <div style="display: flex; justify-content: space-between; font-size: 13px; color: #64748b; padding-top: 4px;">
                <div>Người phát hiện: <strong id="modalReporter" style="color: #0f172a;"></strong></div>
                <div>Thời điểm báo: <strong id="modalReportDate" style="color: #0f172a;"></strong></div>
            </div>
        </div>
        <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end; gap: 10px;">
            <button type="button" class="portal-btn portal-btn-secondary" onclick="closeDamageModal()">Đóng</button>
            <form id="modalResolveForm" action="${pageContext.request.contextPath}/manager/damages" method="POST" style="margin: 0;">
                <input type="hidden" name="action" value="resolve" />
                <input type="hidden" id="modalFormReportId" name="maBaoCao" value="" />
                <input type="hidden" id="modalFormRoomId" name="maPhong" value="" />
                <input type="hidden" id="modalFormRoomNumber" name="soPhong" value="" />
                <button type="submit" class="portal-btn portal-btn-success" onclick="return confirm('Xác nhận nghiệm thu thiết bị đã sửa xong và mở khóa phòng về Khả dụng?');">
                    Nghiệm Thu &amp; Mở Khóa Phòng
                </button>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var modal = document.getElementById('damageDetailModal');
    document.querySelectorAll('.btn-view-damage').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var data = this.dataset;
            document.getElementById('modalReportId').textContent = data.mabaocao;
            document.getElementById('modalRoomInfo').textContent = 'Phòng ' + data.sophong;
            document.getElementById('modalRoomType').textContent = 'Hạng phòng: ' + data.tenloaiphong + ' (ID: ' + data.maphong + ')';
            document.getElementById('modalDamageType').textContent = data.tenloaihuhai;
            document.getElementById('modalDescription').textContent = data.motachitiet || '(Không có mô tả chi tiết)';
            document.getElementById('modalReporter').textContent = data.nhanvien;
            document.getElementById('modalReportDate').textContent = data.ngay;

            var statusEl = document.getElementById('modalStatus');
            if (data.trangthai === 'Pending') {
                statusEl.innerHTML = '<span style="color: #d97706;">Chờ Quản Lý Nghiệm Thu</span>';
            } else if (data.trangthai === 'Confirmed') {
                statusEl.innerHTML = '<span style="color: #2563eb;">Đang Sửa Chữa / Bảo Trì</span>';
            } else {
                statusEl.textContent = data.trangthai;
            }

            document.getElementById('modalFormReportId').value = data.mabaocao;
            document.getElementById('modalFormRoomId').value = data.maphong;
            document.getElementById('modalFormRoomNumber').value = data.sophong;

            modal.style.display = 'flex';
        });
    });
});

function closeDamageModal() {
    document.getElementById('damageDetailModal').style.display = 'none';
}
</script>

<jsp:include page="/views/common/footer.jsp" />
