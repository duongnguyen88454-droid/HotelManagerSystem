<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title" value="Quản Lý Sự Cố & Bảo Trì Phòng" />
    <jsp:param name="zone" value="portal" />
</jsp:include>

<div class="portal-layout">
    <!-- Thanh chức năng bên trái -->
    <jsp:include page="/views/common/portal_sidebar.jsp">
        <jsp:param name="activeMenu" value="damages" />
    </jsp:include>

    <!-- Màn hình bên phải -->
    <main class="portal-main">
        <header class="page-header">
            <div class="page-header-left">
                <h1 class="page-title">Quản Lý Sự Cố &amp; Bảo Trì Phòng</h1>
                <p class="page-subtitle">Theo dõi danh sách các phòng hư hỏng, nghiệm thu khắc phục thiết bị và mở khóa phòng Available</p>
            </div>
            <div class="page-header-right">
                <span class="pill pill-primary">Ca trực: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></span>
            </div>
        </header>

        <!-- Thông báo kết quả -->
        <c:if test="${not empty sessionScope.flashSuccess}">
            <div class="alert alert-success">
                ${sessionScope.flashSuccess}
            </div>
            <c:remove var="flashSuccess" scope="session" />
        </c:if>
        <c:if test="${not empty sessionScope.flashError}">
            <div class="alert alert-danger">
                ${sessionScope.flashError}
            </div>
            <c:remove var="flashError" scope="session" />
        </c:if>

        <!-- Bảng danh sách sự cố -->
        <div class="card p-0">
            <div class="card-toolbar">
                <h3 class="card-title">Danh Sách Báo Cáo Hư Hại Chờ Nghiệm Thu</h3>
            </div>

            <div class="table-wrapper">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Mã Biên Bản</th>
                            <th>Phòng</th>
                            <th>Hạng Phòng</th>
                            <th>Sự Cố Thiết Bị</th>
                            <th>Chi Tiết Hư Hỏng</th>
                            <th>Người Báo &amp; Ngày Giờ</th>
                            <th class="text-center">Trạng Thái</th>
                            <th class="text-center">Hành Động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty damagedRooms}">
                                <c:forEach var="item" items="${damagedRooms}">
                                    <tr>
                                        <td>
                                            <strong class="text-primary">${item.maBaoCao}</strong>
                                        </td>
                                        <td>
                                            <div class="font-bold text-main">Phòng ${item.soPhong}</div>
                                            <div class="text-muted text-xs">ID: ${item.maPhong}</div>
                                        </td>
                                        <td class="text-secondary">
                                            ${item.tenLoaiPhong}
                                        </td>
                                        <td>
                                            <span class="badge badge-danger badge-pill badge-damaged">
                                                ${item.tenLoaiHuHai}
                                            </span>
                                        </td>
                                        <td class="text-main" style="max-width: 250px;">
                                            ${item.moTaChiTiet}
                                        </td>
                                        <td class="text-muted text-xs">
                                            <div>Người báo: <strong class="text-main">${item.nhanVienPhatHien}</strong></div>
                                            <div class="mt-1">Thời điểm: ${item.ngayPhatHien}</div>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${item.trangThaiBaoCao == 'Pending'}">
                                                    <span class="badge badge-warning badge-pill badge-cleaning">Chờ Xác Nhận</span>
                                                </c:when>
                                                <c:when test="${item.trangThaiBaoCao == 'Confirmed'}">
                                                    <span class="badge badge-info badge-pill badge-occupied">Đang Bảo Trì</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-danger badge-pill badge-damaged">${item.trangThaiBaoCao}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <div class="flex items-center justify-center gap-2">
                                                <button type="button"
                                                    class="btn btn-outline btn-sm btn-view-damage"
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
                                                    method="POST" class="inline"
                                                    onsubmit="return confirm('Xác nhận nghiệm thu thiết bị đã sửa xong và mở khóa Phòng ${item.soPhong} sang trạng thái Khả dụng (Available)?');">
                                                    <input type="hidden" name="action" value="resolve" />
                                                    <input type="hidden" name="maBaoCao" value="${item.maBaoCao}" />
                                                    <input type="hidden" name="maPhong" value="${item.maPhong}" />
                                                    <input type="hidden" name="soPhong" value="${item.soPhong}" />
                                                    <button type="submit" class="btn btn-success btn-sm">
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
                                    <td colspan="8" class="text-center py-6 text-muted">
                                        <div class="font-bold text-main">Không có phòng nào đang báo hỏng hoặc cần bảo trì!</div>
                                        <div class="text-sm mt-1">Toàn bộ cơ sở vật chất phòng ốc của khách sạn đang trong tình trạng hoạt động tốt.</div>
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
<div id="damageDetailModal" class="modal-backdrop portal-modal-backdrop" style="display: none;">
    <div class="modal-card max-w-lg" style="width: 660px; max-width: 94%;">
        <!-- Header Modal -->
        <div class="modal-header">
            <div class="flex items-center gap-2">
                <h3 class="modal-title">
                    Chi Tiết Sự Cố &amp; Báo Cáo Hư Hại
                </h3>
                <span id="modalStatusBadge" class="badge badge-pill text-xs"></span>
            </div>
            <button type="button" onclick="closeDamageModal()" class="modal-close">&times;</button>
        </div>

        <div class="modal-body" style="max-height: calc(85vh - 140px); overflow-y: auto;">
            <!-- Khối 1: Vị trí phòng & Mã biên bản -->
            <div class="card bg-surface-subtle p-3 mb-4 flex justify-between items-center">
                <div>
                    <div id="modalRoomInfo" class="font-bold text-main text-base"></div>
                    <div id="modalRoomType" class="text-muted text-xs mt-1"></div>
                </div>
                <div class="text-right">
                    <div class="text-xs font-bold text-muted uppercase">Mã Biên Bản</div>
                    <div id="modalReportId" class="font-bold text-primary mono text-base"></div>
                </div>
            </div>

            <!-- Khối 2: Danh sách các hạng mục hư hại -->
            <div class="mb-4">
                <div class="flex justify-between items-center mb-2">
                    <label class="text-xs font-bold text-secondary uppercase">
                        Danh Sách Hạng Mục Hư Hại Cần Xử Lý
                    </label>
                    <span id="modalItemCountBadge" class="text-xs text-muted font-semibold"></span>
                </div>
                <div class="table-wrapper border rounded">
                    <table class="table">
                        <thead>
                            <tr>
                                <th class="text-center text-xs" style="width: 12%;">STT</th>
                                <th class="text-xs" style="width: 38%;">Phân Loại Sự Cố / Thiết Bị</th>
                                <th class="text-xs" style="width: 50%;">Vị Trí &amp; Mô Tả Chi Tiết</th>
                            </tr>
                        </thead>
                        <tbody id="modalDamageItemsTableBody">
                            <!-- Render bằng JavaScript -->
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Khối 3: Lịch sử ghi nhận từ Housekeeper -->
            <div class="card bg-surface-subtle p-3 grid-2 text-sm">
                <div>
                    <span class="text-muted">Người phát hiện:</span>
                    <div id="modalReporter" class="font-bold text-main mt-1"></div>
                </div>
                <div>
                    <span class="text-muted">Thời điểm báo cáo:</span>
                    <div id="modalReportDate" class="font-bold text-main mt-1"></div>
                </div>
            </div>
        </div>

        <!-- Footer Modal -->
        <div class="modal-footer">
            <button type="button" class="btn btn-outline" onclick="closeDamageModal()">Đóng</button>
            <form id="modalResolveForm" action="${pageContext.request.contextPath}/manager/damages" method="POST" class="inline">
                <input type="hidden" name="action" value="resolve" />
                <input type="hidden" id="modalFormReportId" name="maBaoCao" value="" />
                <input type="hidden" id="modalFormRoomId" name="maPhong" value="" />
                <input type="hidden" id="modalFormRoomNumber" name="soPhong" value="" />
                <button type="submit" class="btn btn-success"
                    onclick="return confirm('Xác nhận nghiệm thu thiết bị đã sửa xong và mở khóa phòng về Khả dụng?');">
                    Nghiệm Thu &amp; Mở Khóa Phòng
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
                    statusBadge.className = 'badge badge-warning badge-pill badge-cleaning';
                    statusBadge.textContent = 'Chờ Xác Nhận';
                } else if (report.trangThaiBaoCao === 'Confirmed') {
                    statusBadge.className = 'badge badge-info badge-pill badge-occupied';
                    statusBadge.textContent = 'Đang Bảo Trì';
                } else {
                    statusBadge.className = 'badge badge-danger badge-pill badge-damaged';
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
                    tr.innerHTML = '<td class="text-center font-bold text-muted py-2">' + stt + '</td>'
                        + '<td class="py-2"><span class="badge badge-danger badge-pill badge-damaged">' + escapeHtml(item.tenLoaiHuHai) + '</span></td>'
                        + '<td class="text-main text-sm leading-relaxed py-2">' + escapeHtml(item.moTaChiTiet || '(Không có mô tả chi tiết)') + '</td>';
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