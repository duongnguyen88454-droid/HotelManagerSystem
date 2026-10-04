# BÁO CÁO KỸ THUẬT BACKEND GIAI ĐOẠN 6 (PHASE 6)
# PHÂN HỆ QUẢN LÝ: DASHBOARD VẬN HÀNH, BÁO CÁO DOANH THU & XỬ LÝ PHÒNG BẢO TRÌ
# (Manager Portal: Operational Dashboard, Revenue Analytics & Maintenance Resolution)

---

## 📌 I. TỔNG QUAN PHÂN HỆ QUẢN LÝ (ROLE VT04)

Phân hệ Quản lý (**Manager Portal**) là "Trung tâm chỉ huy" (Command Center) của hệ thống Quản lý Khách sạn. Đây là nơi hội tụ và tổng hợp toàn bộ dữ liệu phát sinh từ chu trình vận hành qua các giai đoạn trước:
- **Phase 2 (Booking Online):** Doanh thu cọc, số lượng đơn đặt phòng mới.
- **Phase 3 (Lễ tân):** Số phòng đang có khách ở thực tế (`Occupied`), dịch vụ gia tăng phát sinh (`BOOKING_DICHVU`).
- **Phase 4 (Thu ngân):** Dòng tiền thực thu qua hóa đơn quyết toán (`THANHTOAN`, `HOADON`) phân loại theo Tiền mặt, Chuyển khoản, Thẻ.
- **Phase 5 (Buồng phòng):** Tình trạng vệ sinh phòng (`Dirty`, `Cleaning`), biên bản sự cố và các phòng đang bị khóa bảo trì (`Damaged`).

---

## 🗄️ II. DANH MỤC ĐỐI TƯỢNG CSDL & MAPPING TƯƠNG ỨNG

| Chức năng | Đối tượng CSDL | Loại | Mục đích nghiệp vụ |
|:---|:---|:---:|:---|
| **F6.1** | `v_TyLeLapDayPhong` | VIEW | Cung cấp chỉ số công suất phòng thời gian thực: Tổng phòng, Occupied, Available, Cleaning/Dirty, Damaged và Tỷ lệ lấp đầy (%). |
| **F6.2** | `sp_BaoCaoTongHopKinhDoanhTheoNgay` | PROCEDURE | Chốt ca ngày (Night Audit): Số đơn mới, số lượt check-in, số lượt check-out, tổng tiền thực thu và phân loại tiền mặt / chuyển khoản / thẻ. |
| **F6.2** | `v_BaoCaoDoanhThuTheoThang` | VIEW | Tổng hợp doanh thu lịch sử theo tháng/năm, số lượt giao dịch và số hóa đơn đã quyết toán. |
| **F6.2** | `fn_DoanhThuTheoKhoangThoiGian` | FUNCTION | Tính tổng doanh thu thực thu trong khoảng thời gian tùy biến `@TuNgay` đến `@DenNgay`. |
| **F6.3** | `v_ThongKeDichVuBanChay` | VIEW | Thống kê số lượng tiêu thụ và tổng doanh thu tích lũy của từng loại dịch vụ (Minibar, Spa, Giặt ủi...) để xếp hạng Top Seller. |
| **F6.4** | `v_DanhSachPhongHuHaiCanBaoTri` | VIEW | Tra cứu các phòng đang hư hỏng chờ kỹ thuật xử lý (tiếp nhận biên bản từ Phase 5). |
| **F6.4** | `UPDATE BAOCAOHUHAI + PHONG` | TRANSACTION | Giao tác nghiệm thu hoàn tất bảo trì: cập nhật biên bản thành `DaXuLy`, mở khóa phòng về `Available`. |

---

## 🏗️ III. CẤU TRÚC MÃ NGUỒN BACKEND ĐÃ TRIỂN KHAI

Toàn bộ mã nguồn Phase 6 Backend được tổ chức theo chuẩn kiến trúc Feature-based tại package `com.mycompany.hotelmanagersystem.manager`:

```text
backend/src/main/java/com/mycompany/hotelmanagersystem/manager/
├── dto/
│   ├── RoomOccupancyDTO.java       # Chứa số liệu công suất và tỷ lệ lấp đầy (%)
│   ├── DailyAuditReportDTO.java    # Chứa số liệu chốt ca ngày và phân loại dòng tiền
│   ├── MonthlyRevenueDTO.java      # Chứa số liệu doanh thu tổng hợp theo tháng
│   ├── ServiceAnalyticsDTO.java    # Chứa thống kê số lượng tiêu thụ và doanh thu dịch vụ
│   └── DamagedRoomItemDTO.java     # Chứa thông tin biên bản sự cố và phòng bảo trì
├── dao/
│   ├── ManagerDashboardDAO.java    # Truy vấn View v_TyLeLapDayPhong
│   ├── ManagerReportDAO.java       # Gọi SP chốt ca ngày, View doanh thu tháng, Function doanh thu theo khoảng
│   ├── ServiceAnalyticsDAO.java    # Truy vấn View v_ThongKeDichVuBanChay
│   └── MaintenanceDAO.java         # Truy vấn v_DanhSachPhongHuHaiCanBaoTri và Transaction nghiệm thu phòng
├── service/
│   ├── ManagerDashboardService.java# Cung cấp nghiệp vụ tính toán tỷ lệ lấp đầy
│   ├── ManagerReportService.java   # Cung cấp nghiệp vụ báo cáo tài chính và phân tích dịch vụ
│   └── ManagerMaintenanceService.java # Cung cấp nghiệp vụ quản lý và nghiệm thu phòng hỏng
└── controller/
    ├── ManagerPortalServlet.java           # GET /manager/dashboard
    ├── ManagerRevenueReportServlet.java    # GET /manager/revenue
    ├── ManagerServiceAnalyticsServlet.java # GET /manager/services
    └── ManagerDamageResolutionServlet.java # GET & POST /manager/damages
```

---

## ⚙️ IV. CÁCH HOẠT ĐỘNG & LUỒNG XỬ LÝ (FLOW OF EXECUTION)

### 1. Luồng F6.1: Dashboard Vận Hành Real-time (`GET /manager/dashboard`)
```
[Client / UI] ──(GET /manager/dashboard)──> [ManagerPortalServlet]
                                                    │
                                                    ▼
                                       [ManagerDashboardService]
                                                    │
                                                    ▼
                                        [ManagerDashboardDAO]
                                                    │ (SELECT)
                                                    ▼
                                      [View: v_TyLeLapDayPhong]
                                                    │
                                                    ▼
                         [Trích xuất: Tổng, Occupied, Available, Dirty, Damaged, %]
                                                    │
[Forward JSP / JSON Response] <─────────────────────┘
```
- **Cách hoạt động:** Khi Quản lý truy cập Dashboard, hệ thống tức thời quét toàn bộ bảng vật lý `PHONG` qua View `v_TyLeLapDayPhong`. Dữ liệu trả về phân tách rõ 4 trạng thái vận hành và công thức tính tỷ lệ lấp đầy:
  $$\text{Tỷ lệ lấp đầy (\%)} = \frac{\text{Số phòng Occupied}}{\text{Tổng số phòng}} \times 100$$

---

### 2. Luồng F6.2: Báo Cáo Doanh Thu & Chốt Ca (`GET /manager/revenue`)
- **Trường hợp 1 (Mặc định hoặc chọn ngày):**
  - Servlet nhận tham số `date` (nếu rỗng mặc định `LocalDate.now()`).
  - `ManagerReportService` gọi Stored Procedure `sp_BaoCaoTongHopKinhDoanhTheoNgay`.
  - Stored Procedure tổng hợp dữ liệu từ `BOOKING`, `BOOKING_PHONG` và `THANHTOAN`, bóc tách dòng tiền thành 3 cột: `ThuTienMat`, `ThuChuyenKhoan`, `ThuTheNganHang`.
  - Đồng thời truy vấn View `v_BaoCaoDoanhThuTheoThang` để nạp lịch sử các tháng trước.
- **Trường hợp 2 (Lọc theo khoảng ngày tùy biến):**
  - Servlet nhận `fromDate` và `toDate`.
  - Gọi Scalar Function `dbo.fn_DoanhThuTheoKhoangThoiGian(fromDate, toDate)` trả về tổng thực thu chính xác của khoảng thời gian đó.

---

### 3. Luồng F6.3: Phân Tích Tiêu Thụ Dịch Vụ Gia Tăng (`GET /manager/services`)
- **Cách hoạt động:**
  - `ManagerServiceAnalyticsServlet` gọi `ManagerReportService.getServiceAnalytics()`.
  - DAO truy vấn View `v_ThongKeDichVuBanChay`. View thực hiện `LEFT JOIN` giữa bảng `DICHVU` và `BOOKING_DICHVU`, gom nhóm theo mã dịch vụ và tính tổng doanh thu.
  - Danh sách được sắp xếp giảm dần theo doanh thu (`ORDER BY TongDoanhThuDichVu DESC`), giúp ban giám đốc nhận diện ngay mặt hàng sinh lời cao nhất.

---

### 4. Luồng F6.4: Nghiệm Thu Hoàn Tất Bảo Trì Phòng Hư Hỏng (`/manager/damages`)
```
[Giai đoạn 5: Buồng phòng báo cáo hư hại] 
               │
               ▼
   [PHONG.TrangThai = 'Damaged']
   [BAOCAOHUHAI.TrangThai = 'ChoXuLy']
               │
               ▼
[GET /manager/damages] ──> Truy vấn v_DanhSachPhongHuHaiCanBaoTri
               │           (Hiển thị danh sách cho Quản lý theo dõi & gọi thợ sửa)
               │
               ▼
[POST /manager/damages] (action=resolve, maBaoCao=..., maPhong=...)
               │
               ▼
[MaintenanceDAO: Transaction 2 bước]
   Step 1: UPDATE BAOCAOHUHAI SET TrangThai = 'DaXuLy' WHERE MaBaoCao = ?
   Step 2: UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = ?
   Commit!
               │
               ▼
[Phòng mở lại Available] ──> Khách hàng ở Phase 2 tìm phòng thấy ngay phòng này!
```

---

## 🏆 V. KẾT QUẢ KIỂM TRA CHẤT LƯỢNG (QUALITY GATE)

Toàn bộ mã nguồn mới đã được tích hợp vào hệ thống và vượt qua 100% các tiêu chuẩn kiểm thử khắt khe:

1. **Checkstyle Compliance:**
   - **Kết quả:** `0 Checkstyle violations`.
   - Tất cả các file đều $\le 200$ dòng, method $\le 30$ dòng, không vi phạm quy ước đặt tên và kiến trúc import.
2. **Kiểm thử kiến trúc Bytecode (ArchUnit):**
   - **Kết quả:** `7/7 ArchUnit tests passed`, `Failures: 0`, `Errors: 0`.
   - Bảo đảm tuyệt đối: Controller không gọi DAO/JDBC; Service không phụ thuộc HttpServlet và java.sql; DAO phụ trách toàn bộ truy vấn CSDL.
3. **Maven Reactor Build:**
   - **Kết quả:** `BUILD SUCCESS` (Tổng cộng 112 source files Java được biên dịch hoàn hảo).
