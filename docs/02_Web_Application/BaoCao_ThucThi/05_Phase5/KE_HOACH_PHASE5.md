# KẾ HOẠCH TRIỂN KHAI GIAI ĐOẠN 5 (PHASE 5)
# PHÂN HỆ BUỒNG PHÒNG & XỬ LÝ HƯ HẠI
# (Housekeeping Portal: Task Management, Clean Handover & Damage Incident - Role VT03)

---

> **Mục đích tài liệu:**
> - Định nghĩa chi tiết **yêu cầu nghiệp vụ và kỹ thuật của Phase 5** để làm căn cứ triển khai và kiểm thử.
> - Phân rã công việc **theo từng chức năng (Feature-Driven / Vertical Slices)**, mỗi tính năng khép kín từ Database, DAO, Service, Controller cho tới Giao diện JSP.
> - Thiết lập cơ chế **chống tranh chấp tài nguyên (Concurrency Control / Race Condition)** khi nhiều nhân viên cùng nhận phòng tại một thời điểm.
> - Cung cấp danh sách **Checklist công việc có thể tick-check (`[ ]`)** để người dùng và AI theo dõi, chỉnh sửa và nghiệm thu tiến độ.

**Trạng thái:** Chuẩn bị triển khai | **Nhánh Git dự kiến:** `phase5` | **Phiên bản tài liệu:** 1.0

---

## 🧭 I. TỔNG QUAN LUỒNG NGHIỆP VỤ & CHU TRÌNH KHÉP KÍN

Trong chu trình khép kín của khách sạn (**The Hotel Guest Cycle**):
$$\text{Check-out (Phase 4)} \longrightarrow \text{Phòng bẩn (Dirty)} \longrightarrow \text{Dọn buồng phòng (Phase 5)} \longrightarrow \begin{cases} \text{Nhánh A: Phòng sạch} \to \text{Available (Quay lại Phase 2)} \\ \text{Nhánh B: Hư hại} \to \text{Damaged (Chờ bảo trì Phase 6)} \end{cases}$$

```
+-----------------------------------------------------------------------------------------------------+
|                                    LUỒNG DỮ LIỆU ĐIỀU PHỐI PHASE 5                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
|  [ĐẦU VÀO TỪ PHASE 4]                                                                              |
|  - Check-out hoàn tất -> Trigger trg_TuDongDonPhongSauCheckOut tự kích hoạt                         |
|  - PHONG.TrangThai = 'Dirty'                                                                        |
|  - NHIEMVUDOPHONG.TrangThai = 'ChoXuLy' (Mã tự sinh 'NV_...')                                       |
|                                     │                                                               |
|                                     ▼                                                               |
|  [PHÂN HỆ BUỒNG PHÒNG - PHASE 5]                                                                    |
|  1. Housekeeper Dashboard: Xem danh sách phòng bẩn, lọc tầng, xem thẻ KPI ca làm việc               |
|  2. Bắt đầu dọn (NhanViec):                                                                        |
|     - Khóa hàng chống tranh chấp (UPDLOCK)                                                          |
|     - NHIEMVUDOPHONG.TrangThai = 'DangDon', MaNV = NV hiện tại, ThoiGianBatDau = GETDATE()          |
|     - PHONG.TrangThai = 'Cleaning' (Màu cam trên sơ đồ Lễ tân)                                      |
|                                     │                                                               |
|                   ┌─────────────────┴─────────────────┐                                             |
|                   ▼                                   ▼                                             |
|          [NHÁNH A: PHÒNG SẠCH SẼ]            [NHÁNH B: CÓ HƯ HỎNG / SỰ CỐ]                          |
|          - Bấm "Hoàn tất phòng sạch"         - Bấm "Báo cáo hư hại"                                 |
|          - NHIEMVUDOPHONG -> 'HoanThanh'     - Mở Form lập biên bản hư hại                          |
|          - KetQua = 'KhongThietHai'          - Chọn đồ hỏng (LOAIHUHAI) + nhập mô tả                |
|          - PHONG -> 'Available' (Xanh lá)    - Chạy Transaction:                                    |
|                   │                            + NHIEMVUDOPHONG -> 'HoanThanh', KetQua='CoThietHai' |
|                   │                            + PHONG -> 'Damaged' (Khóa phòng)                    |
|                   │                            + Tự sinh BAOCAOHUHAI & CHITIETBAOCAOHUHAI           |
|                   │                                   │                                             |
|                   ▼                                   ▼                                             |
|       [QUAY LẠI PHASE 2]                      [CHUYỂN TIẾP PHASE 6]                                 |
|       Khách hàng tìm kiếm và đặt              Quản lý theo dõi danh sách phòng hỏng                 |
|       lại phòng P101, P303 bình thường        để điều phối bảo dưỡng và phạt đền bù                 |
+-----------------------------------------------------------------------------------------------------+
```

---

## 🗄️ II. BẢNG MAPPING ĐỐI TƯỢNG DATABASE LIÊN QUAN

| Tên Bảng / Đối Tượng DB | Vai Trò & Nghiệp Vụ Trong Phase 5 |
|:---|:---|
| `NHIEMVUDOPHONG` | Bảng lõi quản lý nhiệm vụ dọn phòng (`MaNhiemVu`, `MaPhong`, `MaNV`, `ThoiGianNhan`, `ThoiGianBatDau`, `ThoiGianKetThuc`, `TrangThai`, `KetQua`). |
| `PHONG` | Đồng bộ trạng thái phòng: `Dirty` (bẩn) $\to$ `Cleaning` (đang dọn) $\to$ `Available` (sạch) hoặc `Damaged` (hư hỏng). |
| `LOAIHUHAI` | Bảng danh mục đồ vật hư hại chuẩn (`MaLoaiHuHai`, `TenLoaiHuHai`, `MoTa`): Vỡ kính, hỏng điều hòa, rách nệm, hỏng khóa từ... |
| `BAOCAOHUHAI` | Bảng lưu biên bản sự cố (`MaBaoCao`, `MaNhiemVu`, `NgayPhatHien`, `MoTa`, `TrangThai = 'ChoXuLy'`). |
| `CHITIETBAOCAOHUHAI` | Chi tiết món đồ bị hỏng trong biên bản (`MaBaoCao`, `MaLoaiHuHai`, `MoTaChiTiet`). |
| `v_DanhSachPhongCanDonDep` | View phục vụ Dashboard buồng phòng (lấy phòng `ChoXuLy`, `DangDon` kèm thông tin tầng, loại phòng, nhân viên). |
| `v_DanhSachPhongHuHaiCanBaoTri` | View phục vụ màn hình tra cứu các phòng đang hỏng chờ sửa chữa. |
| `sp_CapNhatTienDoDonPhong` | Thủ tục cập nhật tiến độ `NhanViec` và `HoanThanh` (kết quả `KhongThietHai`). |
| `sp_Transaction_HoanTatDonPhongVaLapBienBan` | Transaction nguyên tử: Hoàn tất dọn dẹp $\to$ khóa phòng `Damaged` $\to$ tạo biên bản hư hại. |

---

## 🏗️ III. KIẾN TRÚC MÃ NGUỒN (TUÂN THỦ ARCHITECTURE_RULES.MD)

Toàn bộ mã nguồn Phase 5 được đóng gói cô lập trong package: `com.mycompany.hotelmanagersystem.housekeeping`:

```
src/main/java/com/mycompany/hotelmanagersystem/housekeeping/
├── controller/
│   ├── HousekeepingDashboardServlet.java       # /housekeeper/dashboard (Xem dashboard & lọc)
│   ├── HousekeepingTaskActionServlet.java      # /housekeeper/task-action (Bắt đầu dọn & Hoàn thành)
│   └── HousekeepingDamageReportServlet.java    # /housekeeper/damage-report (Lập biên bản & Tra cứu)
├── service/
│   ├── HousekeepingTaskService.java            # Nghiệp vụ điều phối dọn dẹp, kiểm tra trạng thái
│   └── DamageReportService.java                # Nghiệp vụ lập biên bản và quản lý danh mục hư hại
├── dao/
│   ├── HousekeepingTaskDAO.java                # Tương tác NHIEMVUDOPHONG, view v_DanhSachPhongCanDonDep
│   └── DamageReportDAO.java                    # Tương tác LOAIHUHAI, BAOCAOHUHAI, CHITIETBAOCAOHUHAI
└── dto/
    ├── HousekeepingTaskDTO.java                # Dữ liệu hiển thị 1 nhiệm vụ trên bảng
    ├── HousekeepingSummaryDTO.java             # Dữ liệu 4 thẻ thống kê KPI
    ├── DamageCategoryDTO.java                  # Dữ liệu danh mục loại hư hại
    ├── DamageReportDTO.java                    # Dữ liệu biên bản hư hại hiển thị
    └── DamageReportFormDTO.java                # Dữ liệu nhận từ form submit biên bản
```

**Quy tắc giới hạn bất biến:**
- File dài $\le 200$ dòng (Ngưỡng cứng: 300).
- Method dài $\le 30$ dòng (Ngưỡng cứng: 50).
- Độ phức tạp chu trình (Cyclomatic Complexity) $\le 10$ (Ngưỡng cứng: 15).
- Controller tuyệt đối không import DAO/JDBC. Service không import `HttpServlet` hoặc `java.sql.*`.
- Giao diện JSP: **Thuần CSS Typography, sang trọng, tuyệt đối KHÔNG icon / emoji**.

---

## 📋 IV. CHI TIẾT TỪNG CHỨC NĂNG (FEATURE-DRIVEN WBS & CHECKLIST)

---

### 🔹 CHỨC NĂNG 1: BẢNG ĐIỀU PHỐI & THEO DÕI NHIỆM VỤ DỌN PHÒNG (F5.1)
> **Mục tiêu:** Cung cấp màn hình trung tâm cho nhân viên buồng phòng (`VT03`) nắm bắt công việc trong ca, lọc theo trạng thái phòng, đảm bảo 1 nhân viên chỉ dọn 1 phòng tại một thời điểm.

- [x] **Task 1.1 (DTO):** Tạo `HousekeeperTaskDTO.java`.
- [x] **Task 1.2 (DAO):** Viết `HousekeeperTaskDAO.getTasks(String statusFilter)` lọc các phòng `Dirty` và `Cleaning`.
- [x] **Task 1.3 (DAO):** Viết `HousekeeperTaskDAO.getTaskById(...)` lấy chi tiết nhiệm vụ và phòng.
- [x] **Task 1.4 (Service):** Viết `HousekeeperTaskService.getTaskList(...)` và tính toán `currentActiveTask`.
- [x] **Task 1.5 (Controller):** Tạo `HousekeeperPortalServlet.java` (`GET /housekeeper/tasks`), tiếp nhận bộ lọc và chuyển tiếp dữ liệu.
- [x] **Task 1.6 (UI/JSP):** Tạo `src/main/webapp/views/housekeeper/tasks.jsp`:
  - Thanh tab lọc trạng thái (Tất Cả, Chờ Xử Lý, Đang Dọn, Đã Hoàn Thành).
  - Bảng danh sách nhiệm vụ 5 cột chuẩn mực, các badge màu sắc hài hòa.
  - Banner cảnh báo công việc đang dọn dẹp và cơ chế vô hiệu hóa các nút nhận việc khác khi đang có phòng dọn dở.
- [x] **Task 1.7 (Security & Menu):** Bổ sung menu "Buồng Phòng" trên `views/common/navbar.jsp` cho vai trò `VT03` (và Quản lý `VT04`). `AuthFilter.java` bảo vệ route `/housekeeper/*`.

---

### 🔹 CHỨC NĂNG 2: TIẾP NHẬN DỌN DẸP & NGHIỆM THU PHÒNG SẠCH (F5.2)
> **Mục tiêu:** Xử lý 2 thao tác nghiệp vụ cốt lõi: Bắt đầu dọn phòng (`NhanViec`) và Nghiệm thu phòng sạch (`HoanThanh` $\to$ `Available`). Tích hợp cơ chế khóa hàng nguyên tử chống tranh chấp khi 2 nhân viên cùng nhận việc một lúc.

#### Cơ chế kỹ thuật chống tranh chấp đồng thời (Concurrency Control):
- Áp dụng khóa hàng `WITH (UPDLOCK, ROWLOCK)` trong câu lệnh UPDATE:
  ```sql
  UPDATE NHIEMVUDOPHONG WITH (UPDLOCK, ROWLOCK)
  SET MaNV = @MaNV, ThoiGianBatDau = GETDATE(), TrangThai = 'DangDon'
  WHERE MaNhiemVu = @MaNhiemVu AND TrangThai = 'ChoXuLy';
  ```
- Nếu `@@ROWCOUNT == 0`: Ném thông báo lỗi rõ ràng kèm tên nhân viên đã nhận trước, không để xảy ra Lost Update.
- Ràng buộc quyền sở hữu ca dọn: Chỉ nhân viên đang tiếp nhận phòng đó mới có quyền bấm Hoàn tất hoặc Báo hư hại.

- [x] **Task 2.1 (Database Update):** Cập nhật thủ tục `sp_CapNhatTienDoDonPhong` trong `database/04_Procedure.sql`:
  - Thêm khóa hàng `UPDLOCK, ROWLOCK` khi thực hiện `HanhDong = 'NhanViec'`.
  - Bổ sung kiểm tra quyền sở hữu `MaNV` khi `HanhDong = 'HoanThanh'`.
  - Deploy lên SQL Server (`localhost\SQLEXPRESS`).
- [x] **Task 2.2 (DAO):** Viết `HousekeeperTaskDAO.updateTaskProgress(...)` gọi Stored Procedure.
- [x] **Task 2.3 (Service):** Viết `HousekeeperTaskService.startCleaning(String maNhiemVu, String maNV)` và `completeClean(String maNhiemVu, String maNV)`.
- [x] **Task 2.4 (Controller):** Tạo `HousekeeperTaskActionServlet.java` (`POST /housekeeper/task-action`):
  - Nhận `action = start` $\to$ Gọi nhận việc.
  - Nhận `action = complete` $\to$ Gọi hoàn tất sạch.
  - Xử lý Flash message lưu vào `HttpSession` (`flashSuccess` hoặc `flashError`).
  - Redirect về `/housekeeper/tasks`.
- [x] **Task 2.5 (UI Integration):** Cập nhật `tasks.jsp`:
  - Nút **[ Nhận Việc & Dọn ]** gửi POST kèm kiểm tra 1 nhân viên 1 phòng.
  - Nút **[ Xong Sạch ]** gửi POST kèm hộp thoại xác nhận JavaScript `confirm()`.
  - Hiển thị hộp thông báo Flash Alert trên đầu trang khi nhận việc thành công hoặc khi xảy ra tranh chấp công việc.

---

### 🔹 CHỨC NĂNG 3: LẬP BIÊN BẢN SỰ CỐ HƯ HẠI & KHÓA PHÒNG BẢO TRÌ (F5.3)
> **Mục tiêu:** Khi đang dọn phòng mà phát hiện sự cố (vỡ kính, hỏng máy lạnh, rách nệm...), nhân viên lập biên bản báo cáo hư hại. Hệ thống chạy Transaction: hoàn tất nhiệm vụ, khóa phòng sang `Damaged` và lưu biên bản vào CSDL.

- [x] **Task 3.1 (DTO):** Tạo `DamageCategoryDTO.java` và `DamageDetailItemDTO.java`.
- [x] **Task 3.2 (DAO):** Viết `DamageReportDAO.getAllDamageCategories()` truy vấn danh mục động từ bảng `LOAIHUHAI`.
- [x] **Task 3.3 (DAO):** Viết `DamageReportDAO.createDamageReportAndLockRoom(...)` thực hiện Transaction lập biên bản đa mục hư hại và khóa phòng `Damaged`.
- [x] **Task 3.4 (Service):** Viết `HousekeeperTaskService.submitDamageReport(...)` kiểm tra tính hợp lệ và chống chọn trùng loại hư hại.
- [x] **Task 3.5 (Controller):** Tạo `HousekeeperDamageReportServlet.java` (`/housekeeper/damage-report`):
  - `doGet`: Nhận `taskId`, tải thông tin phòng, nạp danh mục `LOAIHUHAI` động từ CSDL, forward sang form.
  - `doPost`: Tiếp nhận biên bản đa mục hư hại, gọi service lưu CSDL và redirect về `/housekeeper/tasks`.
- [x] **Task 3.6 (UI/JSP):**
  - Trên `tasks.jsp`: Tích hợp Modal phân nhánh thông minh dựa trên checkbox "Phát hiện hư hại".
  - Tạo `views/housekeeper/damage_report.jsp`:
    - Thẻ thông tin phòng xảy ra sự cố.
    - Danh sách động các mục hư hại với khả năng thêm nhiều mục (+ Thêm Mục Hư Hại Khác) và xóa mục.
    - Dropdown chọn loại hư hại nạp động 100% từ bảng `LOAIHUHAI` (bỏ hardcode "Other").
    - Khung nhập văn bản mô tả cụ thể vị trí và tình trạng hư hỏng cho từng mục.
    - Nút bấm **"Xác Nhận Lập Biên Bản & Khóa Phòng Bảo Trì"** và nút "Hủy Bỏ / Quay Lại".

---

### 🔹 CHỨC NĂNG 4: TRA CỨU & QUẢN LÝ DANH SÁCH PHÒNG HƯ HỎNG (F5.4)
> **Phân định nghiệp vụ:** Nhiệm vụ này thuộc thẩm quyền của **Quản lý (Manager - `VT04`) / Bộ phận Bảo trì**, không thuộc thẩm quyền của Nhân viên Buồng phòng (`VT03`). Do đó đã được thống nhất **chuyển giao sang Phase 6 (Manager Portal)** để quản lý quy trình gọi thợ, thanh toán bảo trì và nghiệm thu phòng sau sửa chữa qua View `v_DanhSachPhongHuHaiCanBaoTri`.

---

### 🔹 CHỨC NĂNG 5: KIỂM THỬ TÍCH HỢP CHU TRÌNH KHÉP KÍN & QUALITY GATE (F5.5)
> **Mục tiêu:** Thực hiện kiểm thử đầu-cuối (E2E Test) trên dữ liệu thực tế và chạy kiểm thử tự động chất lượng kiến trúc.

#### 1. Kịch bản kiểm thử nghiệp vụ (Live Scenario Test):
- [x] **Test 5.1 (Tiếp nhận dữ liệu Phase 4):**
  - Đăng nhập tài khoản Housekeeper (`nhung.lth@hotel.com` / `1234`).
  - Xác nhận nhìn thấy phòng vừa check-out ở Phase 4 ở trạng thái `ChoXuLy`.
- [x] **Test 5.2 (Bắt đầu dọn):**
  - Bấm "Bắt đầu dọn" phòng $\to$ Trạng thái chuyển `DangDon`, sơ đồ phòng Lễ tân chuyển màu cam `Cleaning`.
- [x] **Test 5.3 (Kiểm thử tranh chấp đồng thời - Concurrency Test):**
  - Hai nhân viên cùng bấm nhận 1 phòng: 1 người thành công, 1 người nhận thông báo cảnh báo phòng đã được người khác tiếp nhận.
- [x] **Test 5.4 (Nhánh hoàn thành sạch - Khép kín chu trình):**
  - Bấm "Hoàn tất phòng sạch" $\to$ Phòng chuyển về `Available` (Xanh lá), sẵn sàng cho Phase 2 đặt tiếp.
- [x] **Test 5.5 (Nhánh báo cáo hư hại):**
  - Dọn phòng phát hiện sự cố $\to$ Chuyển sang màn hình lập biên bản riêng $\to$ Thêm nhiều mục hư hại nạp từ CSDL $\to$ Xác nhận $\to$ Khóa phòng `Damaged`, lưu `BAOCAOHUHAI` và `CHITIETBAOCAOHUHAI`.

#### 2. Tiêu chuẩn chất lượng (Quality Gate):
- [x] `mvn checkstyle:check`: **0 violations** (Đạt chuẩn 100% kiến trúc).
- [x] `mvn test`: **7/7 ArchUnit tests passed**.
- [x] `mvn war:exploded`: **BUILD SUCCESS** tạo gói exploded WAR hoàn chỉnh sẵn sàng cho Tomcat.

---

## 📅 V. KẾ HOẠCH HÀNH ĐỘNG TIẾP THEO

1. Bạn có thể tự do mở file này tại:
   `docs/02_Web_Application/BaoCao_ThucThi/05_Phase5/KE_HOACH_PHASE5.md`
   để đọc, ghi chú thêm hoặc điều chỉnh các yêu cầu nghiệp vụ theo ý muốn.
2. Khi bạn sẵn sàng bắt tay vào lập trình, chỉ cần gửi hiệu lệnh:
   **"Bắt đầu tạo nhánh phase5 và triển khai Chức năng 1"**, hệ thống sẽ lập tức tuân thủ quy trình Đề xuất - Thẩm định - Duyệt trước khi code để hoàn thành từng chức năng một cách chuẩn chỉ nhất.
