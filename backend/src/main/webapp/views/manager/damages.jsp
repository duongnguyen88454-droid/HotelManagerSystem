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
                            <p>Theo dõi danh sách các phòng hư hỏng, nghiệm thu khắc phục thiết bị và mở khóa phòng
                                Available</p>
                        </div>
                        <div class="portal-header-right">
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
                        <div
                            style="padding: 18px 24px; border-bottom: 1px solid var(--portal-border); background: #f8fafc;">
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
                                                        <div
                                                            style="font-weight: 700; color: var(--portal-text-primary); font-size: 15px;">
                                                            Phòng ${item.soPhong}</div>
                                                        <div style="color: var(--portal-text-muted); font-size: 12px;">
                                                            ID: ${item.maPhong}</div>
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
                                                        <div>Người báo: <strong
                                                                style="color: var(--portal-text-primary);">${item.nhanVienPhatHien}</strong>
                                                        </div>
                                                        <div style="margin-top: 2px;">Thời điểm: ${item.ngayPhatHien}
                                                        </div>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <c:choose>
                                                            <c:when test="${item.trangThaiBaoCao == 'Pending'}">
                                                                <span class="badge-pill badge-cleaning">Chờ Xác
                                                                    Nhận</span>
                                                            </c:when>
                                                            <c:when test="${item.trangThaiBaoCao == 'Confirmed'}">
                                                                <span class="badge-pill badge-occupied">Đang Bảo
                                                                    Trì</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span
                                                                    class="badge-pill badge-damaged">${item.trangThaiBaoCao}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <div
                                                            style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                                            <button type="button"
                                                                class="portal-btn portal-btn-secondary btn-view-damage"
                                                                style="padding: 7px 12px; font-size: 12.5px;"
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
                                                            <form
                                                                action="${pageContext.request.contextPath}/manager/damages"
                                                                method="POST" style="margin: 0;"
                                                                onsubmit="return confirm('Xác nhận nghiệm thu thiết bị đã sửa xong và mở khóa Phòng ${item.soPhong} sang trạng thái Khả dụng (Available)?');">
                                                                <input type="hidden" name="action" value="resolve" />
                                                                <input type="hidden" name="maBaoCao"
                                                                    value="${item.maBaoCao}" />
                                                                <input type="hidden" name="maPhong"
                                                                    value="${item.maPhong}" />
                                                                <input type="hidden" name="soPhong"
                                                                    value="${item.soPhong}" />
                                                                <button type="submit"
                                                                    class="portal-btn portal-btn-success"
                                                                    style="padding: 7px 14px; font-size: 12.5px;">
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
                                                <td colspan="8"
                                                    style="padding: 40px; text-align: center; color: var(--portal-text-muted);">
                                                    <div
                                                        style="font-weight: 700; font-size: 15px; color: var(--portal-text-secondary);">
                                                        Không có phòng nào đang báo hỏng hoặc cần bảo trì!</div>
                                                    <div style="font-size: 13px; margin-top: 4px;">Toàn bộ cơ sở vật
                                                        chất phòng ốc của khách sạn đang trong tình trạng hoạt động tốt.
                                                    </div>
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

            <!-- Modal Xem Chi Tiết Báo Cáo Hư Hại (Hỗ Trợ Nhiều Loại Hư Hại) -->
            <div id="damageDetailModal"
                style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.65); z-index: 9999; align-items: center; justify-content: center; backdrop-filter: blur(2px);">
                <div
                    style="background: #ffffff; border-radius: 14px; width: 660px; max-width: 94%; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); overflow: hidden;">
                    <!-- Header Modal -->
                    <div
                        style="padding: 18px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; background: #ffffff;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <h3 style="margin: 0; font-size: 17px; font-weight: 700; color: #0f172a;">
                                Chi Tiết Sự Cố &amp; Báo Cáo Hư Hại
                            </h3>
                            <span id="modalStatusBadge" class="badge-pill" style="font-size: 12px;"></span>
                        </div>
                        <button type="button" onclick="closeDamageModal()"
                            style="background: #f1f5f9; border: none; width: 32px; height: 32px; border-radius: 50%; font-size: 18px; cursor: pointer; color: #64748b; display: flex; align-items: center; justify-content: center;">&times;</button>
                    </div>

                    <div
                        style="padding: 22px 24px; font-size: 14px; color: #334155; max-height: calc(85vh - 140px); overflow-y: auto;">
                        <!-- Khối 1: Vị trí phòng & Mã biên bản -->
                        <div
                            style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px 18px; margin-bottom: 18px; display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <div id="modalRoomInfo" style="font-size: 17px; font-weight: 800; color: #0f172a;">
                                </div>
                                <div id="modalRoomType" style="color: #64748b; font-size: 13px; margin-top: 3px;"></div>
                            </div>
                            <div style="text-align: right;">
                                <div
                                    style="font-size: 11px; font-weight: 700; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">
                                    Mã Biên Bản</div>
                                <div id="modalReportId"
                                    style="font-size: 15px; font-weight: 800; color: #2563eb; font-family: monospace;">
                                </div>
                            </div>
                        </div>

                        <!-- Khối 2: Danh sách các hạng mục hư hại -->
                        <div style="margin-bottom: 18px;">
                            <div
                                style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                <label
                                    style="font-size: 12.5px; font-weight: 700; color: #475569; text-transform: uppercase;">
                                    Danh Sách Hạng Mục Hư Hại Cần Xử Lý
                                </label>
                                <span id="modalItemCountBadge"
                                    style="font-size: 12px; font-weight: 600; color: #64748b;"></span>
                            </div>
                            <div class="portal-table-wrapper"
                                style="border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden; margin: 0;">
                                <table class="portal-table" style="width: 100%; border: none;">
                                    <thead>
                                        <tr style="background: #f8fafc;">
                                            <th style="width: 12%; text-align: center; font-size: 12px;">STT</th>
                                            <th style="width: 38%; font-size: 12px;">Phân Loại Sự Cố / Thiết Bị</th>
                                            <th style="width: 50%; font-size: 12px;">Vị Trí &amp; Mô Tả Chi Tiết</th>
                                        </tr>
                                    </thead>
                                    <tbody id="modalDamageItemsTableBody">
                                        <!-- Render bằng JavaScript -->
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Khối 3: Lịch sử ghi nhận từ Housekeeper -->
                        <div
                            style="background: #f1f5f9; border-radius: 8px; padding: 12px 16px; display: grid; grid-template-columns: 1fr 1fr; gap: 14px; font-size: 13px;">
                            <div>
                                <span style="color: #64748b;">Người phát hiện:</span>
                                <div id="modalReporter" style="font-weight: 700; color: #0f172a; margin-top: 2px;">
                                </div>
                            </div>
                            <div>
                                <span style="color: #64748b;">Thời điểm báo cáo:</span>
                                <div id="modalReportDate" style="font-weight: 700; color: #0f172a; margin-top: 2px;">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Footer Modal -->
                    <div
                        style="padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #f8fafc; display: flex; justify-content: flex-end; gap: 10px;">
                        <button type="button" class="portal-btn portal-btn-secondary" onclick="closeDamageModal()"
                            style="padding: 8px 18px;">Đóng</button>
                        <form id="modalResolveForm" action="${pageContext.request.contextPath}/manager/damages"
                            method="POST" style="margin: 0;">
                            <input type="hidden" name="action" value="resolve" />
                            <input type="hidden" id="modalFormReportId" name="maBaoCao" value="" />
                            <input type="hidden" id="modalFormRoomId" name="maPhong" value="" />
                            <input type="hidden" id="modalFormRoomNumber" name="soPhong" value="" />
                            <button type="submit" class="portal-btn portal-btn-success"
                                style="padding: 8px 20px; font-weight: 600;"
                                onclick="return confirm('Xác nhận nghiệm thu thiết bị đã sửa xong và mở khóa phòng về Khả dụng?');">
                                ✓ Nghiệm Thu &amp; Mở Khóa Phòng
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <script>
                function formatDateTimeVN(isoStr) {
                    if (!isoStr) return '-';
                    var dateObj = new Date(isoStr);
                    if (isNaN(dateObj.getTime())) return isoStr;
                    var d = ('0' + dateObj.getDate()).slice(-2);
                    var m = ('0' + (dateObj.getMonth() + 1)).slice(-2);
                    var y = dateObj.getFullYear();
                    var h = ('0' + dateObj.getHours()).slice(-2);
                    var min = ('0' + dateObj.getMinutes()).slice(-2);
                    var s = ('0' + dateObj.getSeconds()).slice(-2);
                    return h + ':' + min + ':' + s + ' - ' + d + '/' + m + '/' + y;
                }

                function escapeHtml(text) {
                    if (!text) return '';
                    var div = document.createElement('div');
                    div.textContent = text;
                    return div.innerHTML;
                }

                document.addEventListener('DOMContentLoaded', function () {
                    var modal = document.getElementById('damageDetailModal');
                    var damageReportsMap = {};

                    // Gom nhóm các mục hư hại theo Mã Biên Bản từ dữ liệu đã render an toàn trên bảng
                    document.querySelectorAll('.btn-view-damage').forEach(function (btn) {
                        var maBaoCao = btn.dataset.mabaocao;
                        if (!maBaoCao) return;
                        if (!damageReportsMap[maBaoCao]) {
                            damageReportsMap[maBaoCao] = {
                                maBaoCao: maBaoCao,
                                soPhong: btn.dataset.sophong || '',
                                maPhong: btn.dataset.maphong || '',
                                tenLoaiPhong: btn.dataset.tenloaiphong || '',
                                ngayPhatHien: btn.dataset.ngay || '',
                                trangThaiBaoCao: btn.dataset.trangthai || '',
                                nhanVienPhatHien: btn.dataset.nhanvien || '',
                                items: []
                            };
                        }
                        damageReportsMap[maBaoCao].items.push({
                            tenLoaiHuHai: btn.dataset.tenloaihuhai || '',
                            moTaChiTiet: btn.dataset.motachitiet || ''
                        });
                    });

                    document.querySelectorAll('.btn-view-damage').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            var maBaoCao = this.dataset.mabaocao;
                            var report = damageReportsMap[maBaoCao];
                            if (!report) {
                                report = {
                                    maBaoCao: maBaoCao,
                                    soPhong: this.dataset.sophong,
                                    maPhong: this.dataset.maphong,
                                    tenLoaiPhong: this.dataset.tenloaiphong,
                                    ngayPhatHien: this.dataset.ngay,
                                    trangThaiBaoCao: this.dataset.trangthai,
                                    nhanVienPhatHien: this.dataset.nhanvien,
                                    items: [{
                                        tenLoaiHuHai: this.dataset.tenloaihuhai,
                                        moTaChiTiet: this.dataset.motachitiet
                                    }]
                                };
                            }

                            // Xử lý khử lặp từ "Phòng"
                            var roomClean = report.soPhong ? (report.soPhong.startsWith('Phòng') ? report.soPhong : ('Phòng ' + report.soPhong)) : '';
                            document.getElementById('modalRoomInfo').textContent = roomClean;
                            document.getElementById('modalRoomType').textContent = 'Hạng phòng: ' + report.tenLoaiPhong + ' • Mã định danh: ' + report.maPhong;
                            document.getElementById('modalReportId').textContent = '#' + report.maBaoCao;
                            document.getElementById('modalReporter').textContent = report.nhanVienPhatHien || '-';
                            document.getElementById('modalReportDate').textContent = formatDateTimeVN(report.ngayPhatHien);

                            // Cập nhật badge trạng thái
                            var statusBadge = document.getElementById('modalStatusBadge');
                            if (report.trangThaiBaoCao === 'Pending') {
                                statusBadge.className = 'badge-pill badge-cleaning';
                                statusBadge.textContent = 'Chờ Xác Nhận';
                            } else if (report.trangThaiBaoCao === 'Confirmed') {
                                statusBadge.className = 'badge-pill badge-occupied';
                                statusBadge.textContent = 'Đang Bảo Trì';
                            } else {
                                statusBadge.className = 'badge-pill badge-damaged';
                                statusBadge.textContent = report.trangThaiBaoCao;
                            }

                            // Render bảng danh sách các mục hư hại
                            var tbody = document.getElementById('modalDamageItemsTableBody');
                            tbody.innerHTML = '';
                            var countBadge = document.getElementById('modalItemCountBadge');
                            countBadge.textContent = '(' + report.items.length + ' mục)';

                            report.items.forEach(function (item, idx) {
                                var tr = document.createElement('tr');
                                var stt = (idx + 1 < 10) ? ('0' + (idx + 1)) : (idx + 1);
                                tr.innerHTML = '<td style="text-align: center; font-weight: 700; color: #64748b; vertical-align: top; padding: 10px 8px;">' + stt + '</td>'
                                    + '<td style="vertical-align: top; padding: 10px 12px;"><span class="badge-pill badge-damaged" style="font-size: 12px; display: inline-block;">⚠️ ' + escapeHtml(item.tenLoaiHuHai) + '</span></td>'
                                    + '<td style="color: #1e293b; font-size: 13.5px; line-height: 1.5; vertical-align: top; padding: 10px 12px;">' + escapeHtml(item.moTaChiTiet || '(Không có mô tả chi tiết)') + '</td>';
                                tbody.appendChild(tr);
                            });

                            // Gán dữ liệu vào form nghiệm thu
                            document.getElementById('modalFormReportId').value = report.maBaoCao;
                            document.getElementById('modalFormRoomId').value = report.maPhong;
                            document.getElementById('modalFormRoomNumber').value = report.soPhong;

                            modal.style.display = 'flex';
                        });
                    });
                });

                function closeDamageModal() {
                    document.getElementById('damageDetailModal').style.display = 'none';
                }
            </script>

            <jsp:include page="/views/common/footer.jsp" />