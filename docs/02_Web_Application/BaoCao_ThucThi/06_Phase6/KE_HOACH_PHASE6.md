# KẾ HOẠCH TRIỂN KHAI GIAI ĐOẠN 6 (PHASE 6)
# PHÂN HỆ QUẢN LÝ: DASHBOARD VẬN HÀNH, BÁO CÁO DOANH THU & XỬ LÝ PHÒNG BẢO TRÌ
# (Manager Portal: Operational Dashboard, Revenue Analytics & Maintenance Resolution - Role VT04)

---

> **Mục đích tài liệu:**
> - Định nghĩa chi tiết **yêu cầu nghiệp vụ và kỹ thuật của Phase 6** - phân hệ tối cao dành cho Ban Giám đốc và Quản lý khách sạn (`VT04`).
> - Phân rã công việc **theo từng tính năng (Vertical Slices)**: Dashboard vận hành, Báo cáo chốt ca theo ngày/tháng, Phân tích dịch vụ tiêu thụ, và Nghiệm thu xử lý phòng hư hại chuyển giao từ Phase 5.
> - Khai thác và kiểm chứng 100% các đối tượng CSDL đã thiết kế: View `v_TyLeLapDayPhong`, `v_BaoCaoDoanhThuTheoThang`, `v_ThongKeDichVuBanChay`, `v_DanhSachPhongHuHaiCanBaoTri`; Stored Procedure `sp_BaoCaoTongHopKinhDoanhTheoNgay`, `sp_BaoCaoTongHopKinhDoanhThang`; Function `fn_DoanhThuTheoKhoangThoiGian`.
> - Tuân thủ nghiêm ngặt **ARCHITECTURE_RULES.md** và quy tắc thiết kế giao diện Pure CSS sang trọng.

**Trạng thái:** Đang khởi tạo | **Nhánh Git:** `phase6` | **Phiên bản:** 1.0

---

## 🧭 I. TỔNG QUAN VAI TRÒ & LUỒNG DỮ LIỆU PHASE 6

Phase 6 đóng vai trò là "Trung tâm chỉ huy" (Command Center) của hệ thống khách sạn, nơi hội tụ dữ liệu từ tất cả các giai đoạn trước:
- **Phase 2 (Booking Online):** Đơn đặt mới, doanh thu cọc.
- **Phase 3 (Lễ tân & Dịch vụ):** Phòng đang ở (`Occupied`), dịch vụ gia tăng phát sinh (`BOOKING_DICHVU`).
- **Phase 4 (Thu ngân & Check-out):** Dòng tiền thanh toán thực tế (`THANHTOAN`), hóa đơn quyết toán (`HOADON`).
- **Phase 5 (Buồng phòng & Hư hại):** Trạng thái dọn phòng (`Dirty`, `Cleaning`), biên bản hư hại và phòng bảo trì (`Damaged`).

```
+-----------------------------------------------------------------------------------------------------+
|                                   LUỒNG ĐIỀU PHỐI DỮ LIỆU PHASE 6 (MANAGER)                         |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
|  [DỮ LIỆU CÁC PHÂN HỆ TRƯỚC]                                                                        |
|  Phase 2, 3, 4, 5 (PHONG, THANHTOAN, BOOKING, DICHVU, BAOCAOHUHAI)                                  |
|                             │                                                                       |
|                             ▼                                                                       |
|  ┌───────────────────────────────────────────────────────────────────────────────────────────────┐  |
|  │                              PHÂN HỆ QUẢN LÝ (ROLE VT04)                                      │  |
|  ├──────────────────────────────┬───────────────────────────────┬────────────────────────────────┤  |
|  │ 1. Dashboard Vận Hành (F6.1) │ 2. Doanh Thu & Chốt Ca (F6.2) │ 3. Xử Lý Phòng Hỏng (F6.3)    │  |
|  │ - Tỷ lệ lấp đầy hôm nay (%)  │ - Báo cáo ngày (Night Audit)  │ - Danh sách phòng bảo trì      │  |
|  │ - Cơ cấu trạng thái phòng    │ - Doanh thu Tiền mặt/CK/Thẻ   │ - Phân tích dịch vụ bán chạy   │  |
|  │ - Biểu đồ thanh tiến độ Pure │ - Doanh thu tháng/năm         │ - Nghiệm thu sau sửa chữa      │  |
|  │   CSS không thư viện ngoài   │ - Lọc theo khoảng ngày        │ - Mở lại phòng Available       │  |
|  └──────────────────────────────┴───────────────────────────────┴────────────────────────────────┘  |
+-----------------------------------------------------------------------------------------------------+
```

---

## 🗄️ II. BẢNG MAPPING ĐỐI TƯỢNG DATABASE LIÊN KẾT

| Đối tượng Database | Loại | Vai Trò & Nghiệp Vụ Trong Phase 6 |
|:---|:---:|:---|
| `v_TyLeLapDayPhong` | VIEW | Thống kê số lượng phòng Occupied, Available, Cleaning/Dirty, Damaged và tỷ lệ lấp đầy %. |
| `v_BaoCaoDoanhThuTheoThang` | VIEW | Báo cáo xu hướng tài chính hàng tháng (số giao dịch, số hóa đơn, thực thu). |
| `v_ThongKeDichVuBanChay` | VIEW | Xếp hạng tiêu thụ và doanh thu các mặt hàng dịch vụ (Minibar, Spa, Giặt là...). |
| `v_DanhSachPhongHuHaiCanBaoTri` | VIEW | Tra cứu danh sách các phòng hư hại đang chờ xử lý bảo trì (từ Phase 5 bàn giao). |
| `sp_BaoCaoTongHopKinhDoanhTheoNgay` | PROCEDURE | Chốt ca ngày (Night Audit): số đơn mới, check-in, check-out, thực thu phân loại phương thức trả. |
| `sp_BaoCaoTongHopKinhDoanhThang` | PROCEDURE | Báo cáo quản trị tổng kết theo Tháng/Năm: Tổng booking, số đơn hoàn thành, số đơn hủy, thực thu. |
| `fn_DoanhThuTheoKhoangThoiGian` | FUNCTION | Hàm tính tổng doanh thu thực tế trong khoảng thời gian tùy chọn `@TuNgay` đến `@DenNgay`. |

---

## 🏗️ III. KIẾN TRÚC MÃ NGUỒN (TUÂN THỦ ARCHITECTURE_RULES.MD)

Toàn bộ mã nguồn Phase 6 được tổ chức cô lập trong package: `com.mycompany.hotelmanagersystem.manager`:

```
src/main/java/com/mycompany/hotelmanagersystem/manager/
├── controller/
│   ├── ManagerDashboardServlet.java        # GET /manager/dashboard (Dashboard vận hành)
│   ├── ManagerRevenueReportServlet.java    # GET /manager/revenue (Báo cáo ngày/tháng/khoảng ngày)
│   ├── ManagerServiceAnalyticsServlet.java # GET /manager/services (Thống kê dịch vụ bán chạy)
│   └── ManagerDamageResolutionServlet.java # GET & POST /manager/damages (Quản lý & Nghiệm thu phòng hỏng)
├── service/
│   ├── ManagerDashboardService.java        # Xử lý số liệu vận hành và tỷ lệ lấp đầy
│   ├── ManagerReportService.java           # Xử lý báo cáo tài chính và chốt ca
│   └── ManagerMaintenanceService.java      # Nghiệp vụ duyệt sửa chữa và hoàn tất bảo trì
├── dao/
│   ├── ManagerDashboardDAO.java            # Truy vấn v_TyLeLapDayPhong
│   ├── ManagerReportDAO.java               # Gọi SP báo cáo ngày/tháng, v_BaoCaoDoanhThu, fn_DoanhThu
│   ├── ServiceAnalyticsDAO.java            # Truy vấn v_ThongKeDichVuBanChay
│   └── MaintenanceDAO.java                 # Truy vấn v_DanhSachPhongHuHaiCanBaoTri & mở lại phòng
└── dto/
    ├── RoomOccupancyDTO.java               # DTO chứa chỉ số công suất phòng
    ├── DailyAuditReportDTO.java            # DTO báo cáo chốt ca ngày
    ├── MonthlyRevenueDTO.java              # DTO doanh thu theo tháng
    ├── ServiceAnalyticsDTO.java            # DTO thống kê dịch vụ
    └── DamagedRoomItemDTO.java             # DTO danh sách phòng hư hỏng chờ bảo trì
```

**Nguyên tắc kiến trúc bất biến:**
- Tách các DAO chuyên biệt (`ManagerDashboardDAO`, `ManagerReportDAO`, `ServiceAnalyticsDAO`, `MaintenanceDAO`) để đảm bảo không file nào vượt quá 200 dòng.
- Không import DAO/JDBC vào Controller; không import `HttpServlet*` vào Service/DAO.
- Giao diện JSP: Chuẩn Pure CSS typography, các thanh tiến độ / biểu đồ trực quan dựng bằng CSS bar thuần, tuyệt đối không dùng icon/emoji.

---

## 📋 IV. CHI TIẾT TỪNG CHỨC NĂNG (VERTICAL SLICES & CHECKLIST)

---

### 🔹 CHỨC NĂNG 1: DASHBOARD VẬN HÀNH & CÔNG SUẤT PHÒNG (F6.1)
> **Mục tiêu:** Cung cấp cho Quản lý cái nhìn toàn cảnh về tình trạng hoạt động của khách sạn theo thời gian thực (real-time).

- [ ] **Task 1.1 (DTO):** Tạo `RoomOccupancyDTO.java`.
- [ ] **Task 1.2 (DAO):** Viết `ManagerDashboardDAO.getOccupancySummary()` truy vấn từ `v_TyLeLapDayPhong`.
- [ ] **Task 1.3 (Service):** Viết `ManagerDashboardService.getOccupancySummary()`.
- [ ] **Task 1.4 (Controller):** Tạo `ManagerDashboardServlet.java` (`GET /manager/dashboard`).
- [ ] **Task 1.5 (UI/JSP):** Tạo `views/manager/dashboard.jsp`:
  - 5 Thẻ chỉ số vận hành: Tổng số phòng, Đang có khách, Phòng sạch sẵn sàng, Đang dọn dẹp, Đang hư hỏng.
  - Thẻ lớn tỷ lệ lấp đầy phòng (%) kèm thanh tiến độ phân đoạn trực quan (Occupied / Available / Cleaning / Damaged) bằng Pure CSS.
  - Phím tắt điều hướng nhanh tới các phân hệ nghiệp vụ.
- [ ] **Task 1.6 (Security & Navbar):** Cập nhật menu điều hướng trên `views/common/navbar.jsp` cho vai trò Quản lý (`VT04`). Kiểm tra `AuthFilter.java` bảo vệ route `/manager/*`.

---

### 🔹 CHỨC NĂNG 2: BÁO CÁO DOANH THU & CHỐT CA NGÀY / THÁNG (F6.2)
> **Mục tiêu:** Cung cấp công cụ kiểm soát tài chính cho quản lý gồm Báo cáo chốt ca ngày (Night Audit), Báo cáo doanh thu tháng và Tra cứu theo khoảng thời gian.

- [ ] **Task 2.1 (DTO):** Tạo `DailyAuditReportDTO.java` và `MonthlyRevenueDTO.java`.
- [ ] **Task 2.2 (DAO):** Viết `ManagerReportDAO`:
  - `getDailyAuditReport(LocalDate reportDate)`: Gọi `sp_BaoCaoTongHopKinhDoanhTheoNgay`.
  - `getMonthlyRevenueList()`: Truy vấn từ `v_BaoCaoDoanhThuTheoThang`.
  - `getRevenueByRange(LocalDate fromDate, LocalDate toDate)`: Gọi hàm `fn_DoanhThuTheoKhoangThoiGian`.
- [ ] **Task 2.3 (Service):** Viết `ManagerReportService.getDailyReport(...)`, `getMonthlyRevenueList()`, `getRevenueByRange(...)`.
- [ ] **Task 2.4 (Controller):** Tạo `ManagerRevenueReportServlet.java` (`GET /manager/revenue`):
  - Nhận tham số chọn ngày (mặc định hôm nay), hoặc chọn khoảng ngày `fromDate` - `toDate`.
- [ ] **Task 2.5 (UI/JSP):** Tạo `views/manager/revenue_report.jsp`:
  - Bảng tổng kết chốt ca ngày: Số đơn mới, lượt check-in, lượt check-out, tổng tiền thực thu.
  - Bảng cơ cấu phương thức thu tiền: Tiền mặt, Chuyển khoản, Thẻ ngân hàng.
  - Bộ lọc tùy chọn tra cứu doanh thu theo khoảng ngày linh hoạt.
  - Bảng lịch sử doanh thu theo các tháng gần nhất.

---

### 🔹 CHỨC NĂNG 3: PHÂN TÍCH TIÊU THỤ DỊCH VỤ GIA TĂNG (F6.3)
> **Mục tiêu:** Giúp quản lý đánh giá hiệu quả kinh doanh của từng loại hình dịch vụ trong khách sạn.

- [ ] **Task 3.1 (DTO):** Tạo `ServiceAnalyticsDTO.java`.
- [ ] **Task 3.2 (DAO):** Viết `ServiceAnalyticsDAO.getServiceAnalytics()` truy vấn từ `v_ThongKeDichVuBanChay`.
- [ ] **Task 3.3 (Service):** Viết `ManagerReportService.getServiceAnalytics()`.
- [ ] **Task 3.4 (Controller):** Tạo `ManagerServiceAnalyticsServlet.java` (`GET /manager/services`).
- [ ] **Task 3.5 (UI/JSP):** Tạo `views/manager/service_analytics.jsp`:
  - Bảng thống kê dịch vụ: Tên dịch vụ, Đơn giá hiện tại, Tổng số lượt đã bán, Tổng doanh thu tích lũy.
  - Xếp hạng dịch vụ bán chạy nhất (Top seller).

---

### 🔹 CHỨC NĂNG 4: ĐIỀU PHỐI & NGHIỆM THU PHÒNG BẢO TRÌ (F6.4)
> **Mục tiêu:** Tiếp nhận các phòng hư hỏng do buồng phòng báo cáo từ Phase 5, quản lý theo dõi và thực hiện nghiệm thu sửa chữa xong để mở lại phòng sạch sẽ (`Available`).

- [ ] **Task 4.1 (DTO):** Tạo `DamagedRoomItemDTO.java`.
- [ ] **Task 4.2 (DAO):** Viết `MaintenanceDAO`:
  - `getPendingDamagedRooms()`: Truy vấn từ `v_DanhSachPhongHuHaiCanBaoTri`.
  - `resolveDamagedRoom(String maBaoCao, String maPhong)`: Cập nhật `BAOCAOHUHAI.TrangThai = 'DaXuLy'` và `PHONG.TrangThai = 'Available'`.
- [ ] **Task 4.3 (Service):** Viết `ManagerMaintenanceService.getPendingDamagedRooms()` và `resolveDamagedRoom(...)`.
- [ ] **Task 4.4 (Controller):** Tạo `ManagerDamageResolutionServlet.java` (`/manager/damages`):
  - `doGet`: Hiển thị danh sách phòng hỏng đang chờ bảo trì.
  - `doPost`: Tiếp nhận lệnh "Nghiệm thu hoàn tất bảo trì" $\to$ chuyển phòng về `Available`.
- [ ] **Task 4.5 (UI/JSP):** Tạo `views/manager/damages.jsp`:
  - Bảng quản lý chi tiết: Mã biên bản, Số phòng, Hạng phòng, Loại hư hại, Chi tiết sự cố, Người báo cáo, Thời điểm báo cáo.
  - Nút bấm **[ Nghiệm Thu & Mở Lại Phòng ]** kèm hộp thoại xác nhận.

---

### 🔹 CHỨC NĂNG 5: KIỂM THỬ KHÉP KÍN E2E & PROJECT FINAL QUALITY GATE (F6.5)
> **Mục tiêu:** Kiểm thử toàn vẹn toàn bộ chu trình 6 giai đoạn và nghiệm thu đồ án đạt chất lượng cao nhất.

- [ ] **Test 6.1 (Kiểm thử Dashboard & Tỷ lệ lấp đầy):** Mở `/manager/dashboard`, so khớp các chỉ số phòng với thực tế trong CSDL.
- [ ] **Test 6.2 (Kiểm thử Báo cáo chốt ca ngày):** Mở `/manager/revenue`, xác nhận khoản thanh toán từ hóa đơn check-out của Phase 4 hiển thị chính xác.
- [ ] **Test 6.3 (Kiểm thử Phân tích dịch vụ):** Xác nhận các dịch vụ đã gọi ở Phase 3 hiển thị đúng số lượng và doanh thu.
- [ ] **Test 6.4 (Kiểm thử Nghiệm thu phòng bảo trì):** Bấm nghiệm thu phòng `P103` đang `Damaged` $\to$ CSDL mở khóa `P103` thành `Available`, quay lại trang tìm phòng Phase 2 thấy `P103` xuất hiện lại.
- [ ] **Final Quality Gate:**
  - `mvn checkstyle:check`: 0 violations.
  - `mvn test`: 7/7 ArchUnit tests passed.
  - `mvn package`: BUILD SUCCESS.
