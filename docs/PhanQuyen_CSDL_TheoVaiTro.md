# PHÂN TÍCH ỨNG DỤNG CƠ SỞ DỮ LIỆU THEO TỪNG VAI TRÒ
**Dự án: Hệ thống Quản lý Khách sạn (Hotel Management System)**  
**Hệ quản trị CSDL: Microsoft SQL Server 2019 / 2022**

---

## 1. BẢNG MA TRẬN TỔNG HỢP (OVERVIEW MATRIX)

| Thành phần CSDL | Customer (Khách hàng) | Receptionist (Lễ tân) | Housekeeper (Buồng phòng) | Manager (Quản lý) |
| :--- | :--- | :--- | :--- | :--- |
| **Bảo mật (RBAC)** | `role_Customer`<br>• Chỉ thao tác đơn cá nhân<br>• Chặn xem dữ liệu nội bộ | `role_Receptionist`<br>• Toàn quyền vận hành quầy<br>• Chặn sửa giá & xem lương | `role_Housekeeper`<br>• Chỉ xem phòng & dọn dẹp<br>• Chặn xem khách & tiền bạc | `role_Manager`<br>• Toàn quyền tối cao (`dbo`)<br>• Quản trị nhân sự & giá |
| **Stored Procedure** | 3 thủ tục (Đặt phòng, cọc, hủy) | 8 thủ tục (Check-in/out, thu tiền, dịch vụ, báo hỏng...) | 2 thủ tục (Cập nhật dọn phòng, báo hỏng thiết bị) | Toàn quyền 13 thủ tục (Thêm nhân viên, phòng, tài khoản...) |
| **Function** | 7 functions (Tìm phòng, tính tiền phòng, lịch sử...) | 12 functions (Phụ thu sớm/trễ, tiền dịch vụ, sinh mã...) | 2 functions (Sinh mã biên bản sự cố, mã dọn dẹp) | Toàn quyền 27 functions (Báo cáo, kiểm toán, sinh mã) |
| **View** | 2 views (`v_RoomDetails`, `v_CustomerBookingHistory`) | 7 views (Check-in, công nợ, nhiệm vụ buồng, báo hỏng...) | 2 views (`v_HousekeeperTasks`, `v_DamageReports`) | Toàn quyền 11 views (Dashboard, doanh thu, lấp đầy...) |
| **Trigger kích hoạt**| 5 triggers (Chống trùng phòng, tự tạo hóa đơn, đổi trạng thái) | 6 triggers (Check-in/out, phụ thu, tiền dịch vụ, tất toán) | 2 triggers (Đổi phòng sạch sau dọn, chuyển bảo trì khi hỏng) | Được bảo vệ bởi toàn bộ 11 triggers (Khóa tài khoản nghỉ việc...) |
| **Index tối ưu** | `IX_BookingRoom_ConflictCheck`<br>`IX_Booking_CustomerId_CreateDate` | `IX_Invoice_Unpaid`<br>`IX_Payment_InvoiceId` | `IX_RoomCleaningTask_Active` | Toàn bộ 5 Indexes phục vụ Dashboard & Báo cáo tài chính |

---

## 2. VAI TRÒ: CUSTOMER (Khách hàng)
> **Mục tiêu:** Cho phép khách hàng tìm kiếm phòng, đặt phòng online, thanh toán cọc và theo dõi lịch sử lưu trú của bản thân, đồng thời tuyệt đối không để lộ dữ liệu nội bộ và khách hàng khác.

### 🔐 2.1. Security & Phân quyền RBAC (`07_Security_Roles.sql`)
* **Database Role:** `role_Customer` (gán cho User `user_customer`).
* **Quyền được cấp (GRANT):**
  * `SELECT` công khai trên danh mục phòng & dịch vụ: `Room`, `RoomType`, `BedType`, `RoomType_BedType`, `RoomService`, `RoomType_RoomService`, `Service`.
  * `SELECT, INSERT, UPDATE` trên bảng `Customer` (để tự cập nhật hồ sơ cá nhân).
  * `SELECT, INSERT` trên `Booking`, `Booking_Room`, `Booking_Room_Service` (để tạo đơn đặt phòng trực tuyến).
  * `SELECT, INSERT, UPDATE` trên `Invoice` và `SELECT, INSERT` trên `Payment` (để thanh toán tiền cọc online).
* **Quyền bị cấm (DENY):**
  * Chặn hoàn toàn các bảng nội bộ: `Account`, `Employee`, `RoomCleaningTask`, `DamageReport`, `DamageReport_DamageType`.
  * Chặn các View quản lý và báo cáo tài chính: `v_InvoiceRevenueReport`, `v_PaymentReceiptReport`, `v_ReceivableBookings`, `v_HousekeeperTasks`.

### ⚙️ 2.2. Stored Procedure (Thủ tục thực thi) (`04_Procedure.sql`)
* **`sp_XacNhanThanhToanCoc`**: Ghi nhận giao dịch chuyển khoản / nạp tiền cọc qua cổng thanh toán (Momo, VNPay, Ngân hàng).
* **`sp_HuyPhong`**: Khách hàng chủ động hủy phòng trước ngày nhận phòng theo chính sách khách sạn.

### 📐 2.3. Function (Hàm tính toán & Tra cứu) (`02_Function.sql`)
* **`fn_KiemTraPhongTrongTrongKhoang`**: Kiểm tra xem phòng có bị trùng lịch hoặc đang bảo trì trong khoảng ngày khách chọn hay không.
* **`fn_TinhTienPhongBooking`**: Tính trước tiền phòng dự kiến cho khách tham khảo trước khi bấm đặt.
* **`fn_SinhMaBooking`, `fn_SinhMaCustomer`, `fn_SinhMaPayment`**: Tự động sinh mã định danh dạng `BKxxx`, `CUSxxx`, `PAYxxx`.

### 👁️ 2.4. View (Khung nhìn dữ liệu) (`03_View.sql`)
* **`v_RoomDetails`**: Hiển thị thông tin phòng, tiện nghi đi kèm (`AmenitiesDescription`), các loại giường (`BedTypesDescription`) và giá niêm yết.
* **`v_CustomerBookingHistory`**: Màn hình hiển thị danh sách các chuyến lưu trú của khách, ngày đến/đi, tổng tiền và trạng thái đơn.

### ⚡ 2.5. Trigger (Bộ kích hoạt tự động ngầm) (`05_Trigger.sql`)
* **`trg_BookingRoom_KiemTraXungDot`**: Chặn ngay lập tức nếu khách chọn phải phòng đã có người đặt trước (Chống Overbooking).
* **`trg_Booking_TuDongTaoHoaDon`**: Tự động tạo một hóa đơn `Invoice` ở trạng thái `Unpaid` ngay khi khách bấm đặt phòng.
* **`trg_BookingRoom_CapNhatHoaDon`**: Tự động nhân số đêm với giá phòng lúc đặt để cập nhật vào hóa đơn.
* **`trg_Payment_DongBoTrangThaiHoaDon`**: Tự động chuyển hóa đơn sang `PartiallyPaid` khi khách nạp cọc thành công.
* **`trg_Cancellation_DongBoHuyPhong`**: Tự động cập nhật `Cancelled` và giải phóng phòng khi khách hủy đơn thành công.

### 🚀 2.6. Index (Chỉ mục tăng tốc truy vấn) (`06_Index.sql`)
* **`IX_BookingRoom_ConflictCheck`**: Tăng tốc độ kiểm tra phòng trống khi khách tìm kiếm ngày lưu trú trên website.
* **`IX_Booking_CustomerId_CreateDate`**: Tăng tốc tải trang lịch sử đơn đặt phòng cá nhân theo thứ tự mới nhất.

---

## 3. VAI TRÒ: RECEPTIONIST (Nhân viên Lễ tân / Thu ngân)
> **Mục tiêu:** Vận hành toàn bộ quầy lễ tân: Check-in, Check-out, gọi thêm đồ ăn/dịch vụ, thu tiền quyết toán và báo cáo sự cố hư hại.

### 🔐 3.1. Security & Phân quyền RBAC (`07_Security_Roles.sql`)
* **Database Role:** `role_Receptionist` (gán cho User `user_receptionist`).
* **Quyền được cấp (GRANT):**
  * `SELECT, INSERT, UPDATE` trên hầu hết bảng vận hành: `Room`, `Customer`, `Booking`, `Booking_Room`, `Booking_Room_Service`, `Invoice`, `Payment`, `CancellationHistory`, `RoomCleaningTask`, `DamageReport`, `DamageReport_DamageType`.
  * `SELECT` trên `DamageType`.
* **Quyền bị cấm (DENY):**
  * Chặn xem và sửa thông tin nhân viên, tài khoản: `Account`, `Employee` (không xem lương, tài khoản đồng nghiệp).
  * Chặn quyền thay đổi giá niêm yết: `DENY INSERT, UPDATE, DELETE ON RoomType, Service`.
  * Chặn các view tài chính quản lý: `v_InvoiceRevenueReport`, `v_PaymentReceiptReport`.

### ⚙️ 3.2. Stored Procedure (Thủ tục thực thi) (`04_Procedure.sql`)
* **`sp_CheckInNhanPhong`**: Giao phòng cho khách khi khách đến quầy xuất trình CCCD.
* **`sp_CheckOutTraPhong`**: Làm thủ tục trả phòng, chốt giờ ra thực tế.
* **`sp_GoiThemDichVu`**: Ghi nhận các món ăn, nước uống, giặt là khách gọi thêm trong kỳ lưu trú.
* **`sp_GhiNhanThanhToan`**: Thu tiền mặt, quét thẻ và in phiếu thu thanh toán.
* **`sp_HuyPhong`**: Hủy phòng và phạt cọc tại quầy theo quy định.

### 📐 3.3. Function (Hàm tính toán & Tra cứu) (`02_Function.sql`)
* **`fn_TinhPhuThuCheckInSom`**: Tự động tính phụ thu nếu khách nhận phòng trước 13:00.
* **`fn_TinhPhuThuCheckOutTre`**: Tự động tính phụ thu nếu khách trả phòng trễ sau 12:00.
* **`fn_TinhTienDichVuBooking`**: Cộng dồn toàn bộ tiền dịch vụ khách đã gọi.
* **`fn_TinhTongTienHoaDonDuKien`**: Tính toán tổng số tiền quyết toán cuối cùng cần thu của khách.
* **`fn_TinhTienHoanTraHuyPhong`**: Tính số tiền hoàn trả cọc sau khi trừ phí hủy.

### 👁️ 3.4. View (Khung nhìn dữ liệu) (`03_View.sql`)
* **`v_ArrivalCheckInBookings`**: Danh sách các đơn đặt phòng hôm nay sắp đến nhận phòng.
* **`v_ReceivableBookings`**: Danh sách các phòng đang ở cần thu tiền / công nợ chưa quyết toán.
* **`v_HousekeeperTasks`**: Theo dõi xem phòng nào đã dọn sạch để phân phòng cho khách.
* **`v_MaintenancePendingRooms`**: Xem phòng nào đang hỏng để tránh xếp khách vào.

### ⚡ 3.5. Trigger (Bộ kích hoạt tự động ngầm) (`05_Trigger.sql`)
* **`trg_BookingRoom_DongBoCheckIn`**: Đổi ngay trạng thái phòng vật lý sang `OccupancyStatus = 'Occupied'`.
* **`trg_BookingRoom_DongBoCheckOut`**: Đổi phòng sang `Vacant` & `Dirty`, đồng thời **tự động sinh ra 1 nhiệm vụ dọn phòng (`RoomCleaningTask`) ở trạng thái 'Pending'** cho bộ phận buồng phòng.
* **`trg_BookingRoomService_CapNhatTienDichVu`**: Tự động cộng dồn tiền dịch vụ vào hóa đơn khi gọi thêm đồ.
* **`trg_Payment_DongBoTrangThaiHoaDon`**: Tự động chuyển `InvoiceStatus = 'Paid'` khi khách trả đủ tiền.

### 🚀 3.6. Index (Chỉ mục tăng tốc truy vấn) (`06_Index.sql`)
* **`IX_Invoice_Unpaid`**: Tối ưu cực nhanh màn hình Thu ngân lọc các hóa đơn chưa thanh toán hết (`InvoiceStatus <> 'Paid'`).
* **`IX_Payment_InvoiceId`**: Tính nhanh tổng tiền khách đã trả để hiển thị số nợ còn lại (`RemainingDebt`).

---

## 4. VAI TRÒ: HOUSEKEEPER (Nhân viên Buồng phòng)
> **Mục tiêu:** Làm vệ sinh buồng phòng sau khi khách trả phòng, cập nhật trạng thái phòng sạch để sẵn sàng đón khách mới, và báo cáo sự cố hư hại trang thiết bị.

### 🔐 4.1. Security & Phân quyền RBAC (`07_Security_Roles.sql`)
* **Database Role:** `role_Housekeeper` (gán cho User `user_housekeeper`).
* **Quyền được cấp (GRANT):**
  * `SELECT, UPDATE` trên `Room` (xem phòng và đổi trạng thái dọn dẹp).
  * `SELECT, INSERT, UPDATE` trên `RoomCleaningTask` (nhận việc và báo hoàn tất).
  * `SELECT, INSERT, UPDATE` trên `DamageReport`, `DamageReport_DamageType` (báo cáo hỏng hóc).
  * `SELECT` trên `DamageType`, `RoomService` (xem danh mục lỗi hỏng và tiện nghi).
  * `SELECT` trên View: `v_HousekeeperTasks`, `v_DamageReports`.
* **Quyền bị cấm (DENY):**
  * Chặn tuyệt đối thông tin tiền bạc: `Invoice`, `Payment`.
  * Chặn hồ sơ khách hàng và nhân sự: `Customer`, `Account`, `Employee`.
  * Chặn can thiệp đơn đặt phòng: `Booking`, `Booking_Room`.

### ⚙️ 4.2. Stored Procedure (Thủ tục thực thi) (`04_Procedure.sql`)
* **`sp_CapNhatTienDoDonPhong`**: Nhân viên buồng bấm "Bắt đầu dọn" (`InProgress`) và "Đã dọn xong" (`Completed`) trên giao diện di động.

### 📐 4.3. Function (Hàm tính toán & Tra cứu) (`02_Function.sql`)
* Tự động sinh mã và tính toán được xử lý bởi CSDL và ứng dụng Backend.

### 👁️ 4.4. View (Khung nhìn dữ liệu) (`03_View.sql`)
* **`v_HousekeeperTasks`**: Danh sách các phòng được phân công dọn dẹp hàng ngày cho nhân viên buồng.
* **`v_DamageReports`**: Danh sách các sự cố hư hại thiết bị đã được ghi nhận.

### ⚡ 4.5. Trigger (Bộ kích hoạt tự động ngầm) (`05_Trigger.sql`)
* **`trg_RoomCleaningTask_HoanTatDonPhong`**: Khi nhân viên buồng chuyển nhiệm vụ sang `Completed`, trigger **tự động đổi ngay `Room.HousekeepingStatus = 'Clean'`** để phòng sẵn sàng đón khách mới mà không cần lễ tân bấm máy thủ công.
* **`trg_DamageReport_CapNhatTrangThaiPhong`**: Khi nhân viên buồng vừa bấm lưu biên bản sự cố, trigger **tự động đổi ngay trạng thái phòng sang `RoomStatus = 'Maintenance'` (Bảo trì)** để khóa phòng trên hệ thống, ngăn không cho lễ tân bán phòng này.

### 🚀 4.6. Index (Chỉ mục tăng tốc truy vấn) (`06_Index.sql`)
* **`IX_RoomCleaningTask_Active`**: Index lọc riêng trên các trạng thái `('Pending', 'InProgress')` giúp màn hình điện thoại của nhân viên buồng tải ngay danh sách phòng cần làm mà không bị chậm do lịch sử dọn dẹp cũ tích tụ.

---

## 5. VAI TRÒ: MANAGER (Quản lý khách sạn / Giám đốc)
> **Mục tiêu:** Quản trị toàn diện hệ thống, phân quyền nhân sự, điều chỉnh giá, giám sát tỷ lệ lấp đầy phòng và kiểm toán báo cáo doanh thu tài chính.

### 🔐 5.1. Security & Phân quyền RBAC (`07_Security_Roles.sql`)
* **Database Role:** `role_Manager` (gán cho User `user_manager`).
* **Quyền được cấp (GRANT):**
  * Toàn quyền tối cao trên toàn bộ CSDL: `GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO role_Manager`.
  * Toàn quyền thực thi mã nguồn: `GRANT EXECUTE ON SCHEMA::dbo TO role_Manager`.
* **Quyền bị cấm (DENY):** Không có bất kỳ lệnh cấm nào.

### ⚙️ 5.2. Stored Procedure (Thủ tục thực thi) (`04_Procedure.sql`)
* Toàn quyền thực thi tất cả các thủ tục của Lễ tân và Buồng phòng.
* Độc quyền sử dụng các thủ tục quản trị hệ thống:
  * **`sp_ThemTaiKhoan`**: Tạo tài khoản mới, cấp quyền phân vai (`Role`).
  * **`sp_ThemNhanVien`**: Tiếp nhận hồ sơ nhân viên mới, ngày vào làm.
  * **`sp_ThemPhong`**: Mở rộng thêm phòng vật lý mới khi khách sạn xây thêm tầng.

### 📐 5.3. Function (Hàm tính toán & Tra cứu) (`02_Function.sql`)
* Sử dụng toàn bộ 27 Functions của hệ thống để tính toán doanh thu, tỷ lệ tiền cọc, phụ thu sớm/trễ và sinh mã cho tất cả các bảng.

### 👁️ 5.4. View (Khung nhìn dữ liệu) (`03_View.sql`)
* **`v_RoomOccupancyRate`**: Đo lường tỷ lệ lấp đầy phòng (`OccupancyRatePercentage`), số phòng đang ở, phòng trống, phòng bảo trì trên Dashboard thời gian thực.
* **`v_InvoiceRevenueReport`**: Báo cáo doanh thu hóa đơn chi tiết (tiền phòng, dịch vụ, phụ thu, tổng thu và tình trạng nợ).
* **`v_PaymentReceiptReport`**: Báo cáo dòng tiền thu qua từng hình thức (Tiền mặt, Thẻ, Chuyển khoản, Momo, VNPay) kèm tên nhân viên trực tiếp thu tiền.
* **`v_RefundRequests`**: Danh sách các yêu cầu hủy phòng để Quản lý kiểm tra và duyệt hoàn cọc (`RefundStatus`).

### ⚡ 5.5. Trigger (Bộ kích hoạt tự động ngầm) (`05_Trigger.sql`)
* Toàn bộ 11 Triggers đều bảo vệ nghiệp vụ của Quản lý. Đặc biệt:
  * **`trg_Employee_KhoaTaiKhoanNghiViec`**: Khi Quản lý cập nhật trạng thái nhân viên sang nghỉ việc (`EmployeeStatus = 'Resigned'`), trigger **tự động khóa tài khoản đăng nhập (`AccountStatus = 'Locked'`)** ngay lập tức để bảo vệ an toàn dữ liệu khách sạn.

### 🚀 5.6. Index (Chỉ mục tăng tốc truy vấn) (`06_Index.sql`)
* Quản lý hưởng lợi từ toàn bộ 5 Indexes: Giúp Dashboard tài chính và báo cáo doanh thu xuất dữ liệu tức thì trong vài mili-giây ngay cả khi dữ liệu lên đến hàng trăm nghìn giao dịch.

---