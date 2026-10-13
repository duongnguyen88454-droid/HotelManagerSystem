# BÁO CÁO TOÀN DIỆN VỀ NỢ KỸ THUẬT (TECHNICAL DEBT REPORT)
**Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System)  
**Thời điểm rà soát:** Tháng 10/2026  
**Phạm vi:** Cơ sở dữ liệu SQL Server, Mã nguồn Backend Java (Servlet/DAO/Service), Giao diện JSP, Quy trình kiểm thử và Bảo mật.

---

## 1. NỢ KỸ THUẬT MỨC ĐỘ ĐỎ (CRITICAL - NGUY HIỂM CAO)

### 1.1. Bất đồng bộ mô hình CSDL cũ và mới (Legacy Schema Mismatch)
* **Hiện trạng:**
  Dự án đã chuẩn hóa CSDL sang mô hình 3NF với tên bảng và trường chuẩn hóa Tiếng Anh (`Room`, `RoomType`, `Booking`, `Booking_Room`, `Invoice`, `Payment`, `Customer`, `RoomCleaningTask`).  
  Tuy nhiên, một số module phát triển từ Phase 2 & Phase 3 vẫn đang viết câu lệnh SQL trỏ vào **các bảng Tiếng Việt cũ đã không còn tồn tại**:
  * **Module Thu Ngân (Cashier):**
    * [`ActiveBookingDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/cashier/dao/ActiveBookingDAO.java): Truy vấn bảng `KHACHHANG`, `BOOKING_PHONG`, `HOADON`, `THANHTOAN`.
    * [`InvoiceDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/cashier/dao/InvoiceDAO.java): Truy vấn `HOADON`, `KHACHHANG`, `BOOKING_PHONG`, `BOOKING_DICHVU`, `DICHVU`.
    * [`PaymentDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/cashier/dao/PaymentDAO.java): Truy vấn `THANHTOAN`.
  * **Module Buồng phòng (Housekeeper):**
    * [`HousekeeperTaskDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/housekeeper/dao/HousekeeperTaskDAO.java): Truy vấn `NHIEMVUDOPHONG`, `PHONG`, `LOAIPHONG`.
    * [`DamageReportDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/housekeeper/dao/DamageReportDAO.java): Truy vấn `NHIEMVUDOPHONG`, `PHONG`.
  * **Module Quản lý (Manager):**
    * [`MaintenanceDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/manager/dao/MaintenanceDAO.java): `UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = ?`.
  * **Module Dịch vụ phòng (Hotel Service):**
    * [`RoomServiceOrderDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/hotelservice/dao/RoomServiceOrderDAO.java): Truy vấn `BOOKING_PHONG`, `BOOKING_DICHVU`, `DICHVU`.
* **Hậu quả:** Bất kỳ thao tác nào gọi đến các chức năng này của Thu Ngân, Buồng Phòng hay Quản Lý sẽ lập tức văng ngoại lệ SQL Server: `Invalid object name '...'`.

---

### 1.2. Nợ kỹ thuật Song ngữ trạng thái (Bilingual Status Desynchronization)
* **Hiện trạng:**
  CSDL hiện tại quy định các trạng thái đặt phòng chuẩn 100% Tiếng Anh:
  * `Booking_Room.BookingStatus`: `'Confirmed'`, `'CheckedIn'`, `'CheckedOut'`, `'Cancelled'`.
  * `Invoice.InvoiceStatus`: `'Unpaid'`, `'PartiallyPaid'`, `'Paid'`, `'Cancelled'`.
  * `Room.RoomStatus`: `'Available'`, `'Maintenance'`, `'OutOfService'`.
  * `Room.OccupancyStatus`: `'Vacant'`, `'Occupied'`.
  * `Room.HousekeepingStatus`: `'Clean'`, `'Dirty'`, `'Inspected'`.
  Tuy nhiên, trong code Java và JSP vẫn còn tàn dư kiểm tra chuỗi Tiếng Việt:
  * [`BookingService.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/booking/service/BookingService.java#L154): So sánh `!"DaXacNhan".equalsIgnoreCase(trangThai)` và `!"DaCheckIn"`.
  * [`BookingService.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/booking/service/BookingService.java#L213): So sánh `!"DaXacNhan".equalsIgnoreCase(booking.getTrangThaiBooking())` khiến khách hàng không thể hủy đơn đặt trước `Confirmed`.
  * [`BookingDetailDTO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/booking/dto/BookingDetailDTO.java#L58): Dùng `DaXacNhan` để bật cờ `coTheHuy`.
* **Hậu quả:** Logic nghiệp vụ bị sai lệch âm thầm, nút bấm không hoạt động hoặc quăng lỗi không mong muốn cho người dùng cuối.

---

## 2. NỢ KỸ THUẬT MỨC ĐỘ VÀNG (MEDIUM - CẦN CẢI TIẾN SỚM)

### 2.1. Vòng đời đơn giữ chỗ (Booking Hold Expiration Lifecycle)
* **Hiện trạng:**
  Theo phương án 3 (Thanh toán cọc trong 10 phút), các đơn chưa cọc quá 10 phút được xem là hết hạn.
  * Function `fn_KiemTraPhongTrongTrongKhoang` và Trigger 1 đã lọc bỏ các đơn này để nhả phòng cho khách mới.
  * Tuy nhiên, hệ thống **chưa có tác vụ ngầm (Background Job / Scheduled Task) hoặc hàm dọn dẹp chủ động** để đổi các đơn này sang trạng thái `Cancelled`.
* **Hậu quả:** Các đơn hết hạn vẫn nằm trong CSDL với trạng thái `Confirmed` ("đơn ma"), gây khó hiểu khi xem danh sách đơn hoặc thống kê báo cáo.
* **Giải pháp:** Tích hợp logic tự động cập nhật `Cancelled` trong `BookingDAO` khi chốt đơn mới, hoặc bổ sung một định kỳ quét (Scheduled Executor) trong ứng dụng web.

---

### 2.2. Thông tin kết nối CSDL và Tài khoản bị Hardcode
* **Hiện trạng:**
  * [`DBContext.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/common/config/DBContext.java): Thông tin `SERVER_NAME = "localhost"`, `PORT_NUMBER = "1433"`, `USER_NAME = "sa"`, `PASSWORD = "1234"` được ghi cứng trong mã nguồn Java, không dùng Connection Pool (`HikariCP` / `Tomcat JDBC Pool`) hay biến môi trường.
  * [`BookingDAO.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/main/java/com/mycompany/hotelmanagersystem/booking/dao/BookingDAO.java#L166): Tài khoản người tạo được fallback cứng là `"ACC002"` nếu thiếu thông tin session.
* **Hậu quả:** Khó khăn khi triển khai đa môi trường (Development / Staging / Production), tiềm ẩn rủi ro bảo mật nếu lộ mã nguồn.

---

### 2.3. Bất đồng bộ môi trường triển khai CSDL (Database Instance Confusion)
* **Hiện trạng:**
  Trên máy phát triển tồn tại nhiều cơ chế kết nối SQL Server (Shared Memory / Default Instance qua `localhost` vs TCP/IP qua `127.0.0.1:1433`).
  Khi chạy script bằng lệnh CLI nếu không chỉ định rõ `-S 127.0.0.1,1433`, script sẽ chạy nhầm vào instance mặc định khác, khiến CSDL thực tế của ứng dụng Web không nhận được cập nhật.
* **Giải pháp:** Đồng bộ tài liệu và script triển khai luôn dùng cổng rõ ràng `127.0.0.1,1433`.

---

## 3. NỢ KỸ THUẬT MỨC ĐỘ XANH (LOW / ARCHITECTURE DEBT)

### 3.1. Nợ kiểm thử tự động (Testing Debt)
* **Hiện trạng:**
  Toàn bộ dự án hiện chỉ có duy nhất 1 lớp kiểm thử là [`ArchitectureRulesTest.java`](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/backend/src/test/java/com/mycompany/hotelmanagersystem/architecture/ArchitectureRulesTest.java) (kiểm tra kiến trúc ArchUnit).
  Hoàn toàn **chưa có Unit Test hoặc Integration Test tự động** cho `BookingService`, `RoomService`, `CustomerService`, các luồng tính tiền hóa đơn hay thanh toán cọc.
* **Hậu quả:** Mọi thay đổi logic đều phải kiểm thử thủ công trên trình duyệt, tốn thời gian và dễ sót lỗi biên.

---

### 3.2. Mã nguồn Giao diện (JSP) lạm dụng Inline CSS
* **Hiện trạng:**
  Các trang JSP (điển hình như `booking_form.jsp`, `booking_detail.jsp`, `booking_history.jsp`) chứa hàng trăm thẻ HTML với thuộc tính `style="..."` viết trực tiếp trong mã.
* **Hậu quả:**
  Kích thước trang nặng, khó bảo trì giao diện nhất quán, không tái sử dụng được thiết kế và khó áp dụng Responsive trên các thiết bị di động.

---

## 4. KẾ HOẠCH HÀNH ĐỘNG KHẮC PHỤC THEO THỨ TỰ ƯU TIÊN

| Hạng mục | Mức độ ưu tiên | Giải pháp cụ thể |
| :--- | :---: | :--- |
| **1. Cập nhật Trigger & Function CSDL** | **Cấp bách (Đã hoàn tất)** | Chạy Trigger 1 có lọc 10 phút trên `127.0.0.1:1433`. Đã kiểm chứng thành công. |
| **2. Bỏ Song ngữ, chuẩn hóa 100% CSDL** | **Cấp bách (Đang trình duyệt)** | Chuyển toàn bộ các chuỗi kiểm tra trạng thái trong `BookingService`, `BookingDetailDTO`, `CustomerBookingHistoryDTO`, `booking_detail.jsp`, `booking_history.jsp` sang `Confirmed`, `CheckedIn`, `CheckedOut`, `Cancelled`. |
| **3. Tự động hủy đơn hết hạn** | **Cấp bách (Đang trình duyệt)** | Tích hợp câu lệnh dọn dẹp `cleanupExpiredPendingBookings` trong `BookingDAO` khi khách tạo đơn mới. |
| **4. Chuẩn hóa DAO của Cashier & Housekeeper** | **Cao (Phase tiếp theo)** | Refactor các câu lệnh SQL trong `ActiveBookingDAO`, `InvoiceDAO`, `PaymentDAO`, `HousekeeperTaskDAO` sang các bảng 3NF Tiếng Anh (`Invoice`, `Payment`, `Booking_Room`, `RoomCleaningTask`). |
| **5. Bổ sung Unit Test tự động** | **Trung bình** | Viết test case JUnit 5 cho `BookingService` và các DAO lõi. |
