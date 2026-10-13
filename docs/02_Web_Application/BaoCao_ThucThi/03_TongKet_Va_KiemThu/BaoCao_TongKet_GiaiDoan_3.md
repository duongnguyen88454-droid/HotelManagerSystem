# BÁO CÁO TỔNG KẾT TOÀN DIỆN GIAI ĐOẠN 3: PHÂN HỆ LỄ TÂN & VẬN HÀNH QUẦY KHÁCH SẠN
*(Receptionist Portal: PMS Gantt Timeline, In-Person Booking, Check-In Flow & In-Stay Room Service)*

---

* **Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10
* **Môn học:** Lập Trình Web (JSP / Servlet) & Hệ Quản Trị CSDL — HCMUTE
* **Phân hệ thực thi:** Phân hệ Lễ Tân (Receptionist Portal - Role `VT02`)
* **Thời điểm hoàn thành:** 02/10/2026
* **Trạng thái:** ✅ **HOÀN THÀNH 100% — ĐÃ KIỂM THỬ THỰC TẾ & VƯỢT QUA TOÀN BỘ KIỂM TRA KIẾN TRÚC**

---

## MỤC LỤC

1. [Mục Tiêu & Tầm Quan Trọng Của Giai Đoạn 3](#1-mục-tiêu--tầm-quan-trọng-của-giai-đoạn-3)
2. [Các Chức Năng Cốt Lõi Đã Xây Dựng Hoàn Chỉnh](#2-các-chức-năng-cốt-lõi-đã-xây-dựng-hoàn-chỉnh)
3. [Các Ý Tưởng Đột Phá & Cải Tiến Giao Diện Trong Quá Trình Thực Hiện](#3-các-ý-tưởng-đột-phá--cải-tiến-giao-diện-trong-quá-trình-thực-hiện)
4. [Tối Ưu Hóa & Đồng Bộ CSDL: Loại Bỏ Cột Dư Thừa](#4-tối-ưu-hóa--đồng-bộ-csdl-loại-bỏ-cột-dư-thừa)
5. [Kiến Trúc Hệ Thống & Kiểm Định Chất Lượng Mã Nguồn](#5-kiến-trúc-hệ-thống--kiểm-định-chất-lượng-mã-nguồn)
6. [Kế Hoạch & Định Hướng Chuyển Giao Sang Giai Đoạn 4 (Phase 4)](#6-kế-hoạch--định-hướng-chuyển-giao-sang-giai-đoạn-4-phase-4)

---

## 1. MỤC TIÊU & TẦM QUAN TRỌNG CỦA GIAI ĐOẠN 3

Nếu Giai đoạn 2 đóng vai trò là "kênh tiếp thị trực tuyến" thu hút khách đặt phòng từ xa qua Internet, thì **Giai đoạn 3 (Phân hệ Lễ tân)** chính là **trái tim vận hành thực tế tại khách sạn**:
* **Cầu nối giữa thế giới số và vận hành thực tế:** Biến các đơn đặt phòng từ Website thành phòng lưu trú cụ thể, tiếp đón khách hàng trực tiếp tại quầy lễ tân.
* **Số hóa toàn bộ không gian phòng theo thời gian thực:** Cung cấp cho lễ tân một bức tranh toàn cảnh về công suất phòng, trạng thái từng căn phòng (Trống sạch, Đang ở, Chờ dọn dẹp, Đang vệ sinh, Bảo trì) theo tuần.
* **Xử lý linh hoạt khách vãng lai (Walk-in):** Không phụ thuộc vào tài khoản web, định danh nhanh chóng qua CCCD/Hộ chiếu và cấp phòng ngay lập tức.
* **Bảo toàn dữ liệu phát sinh:** Mọi dịch vụ phát sinh trong thời gian khách ở được lưu vết chặt chẽ chuẩn 3NF, làm cơ sở chuẩn xác cho Phân hệ Thu ngân thanh quyết toán ở Giai đoạn 4.

---

## 2. CÁC CHỨC NĂNG CỐT LÕI ĐÃ XÂY DỰNG HOÀN CHỈNH

### 2.1. Sơ Đồ Phòng PMS Gantt Timeline Tuần (`/receptionist/room-map`)
* **Trách nhiệm:** Màn hình trung tâm (Dashboard) của nhân viên Lễ tân.
* **Chi tiết tính năng:**
  * **Thanh KPI thời gian thực:** Tự động tổng hợp 6 chỉ số buồng phòng sống còn: *Tổng số phòng, Đang có khách ở, Trống sạch sẵn sàng đón, Bẩn chờ dọn, Đang dọn dẹp, Phòng hư hỏng/bảo trì*.
  * **Ma trận trực quan hóa theo tầng & 7 ngày:** Hiển thị danh sách phòng phân tầng rõ ràng (`-- TẦNG 1 --`, `-- TẦNG 2 --`...) đối chiếu với 7 cột ngày trong tuần từ Thứ 2 đến Chủ Nhật.
  * **Dải thanh đặt phòng (`booking-bar`) theo mã màu:**
    * *Màu Xanh lá (`bar-confirmed`):* Đơn đặt trước đã xác nhận, sẵn sàng check-in.
    * *Màu Đỏ (`bar-occupied`):* Khách đang lưu trú tại phòng.
    * *Màu Cam (`bar-checkout-today`):* Khách có lịch trả phòng hôm nay.
  * **Bộ lọc tức thời (Instant Filter):** Lọc nhanh theo Tầng (Tất cả, Tầng 1, Tầng 2, Tầng 3...) và theo Trạng thái buồng phòng mà không cần tải lại toàn bộ trang.
  * **Điều hướng tuần mượt mà:** Cho phép xem lịch sử tuần trước, tuần kế tiếp hoặc quay về tuần hiện tại.

### 2.2. Đặt Phòng Trực Tiếp Tại Quầy Lễ Tân (`/receptionist/booking`)
* **Trách nhiệm:** Tiếp nhận khách vãng lai (Walk-in Guests) hoặc khách đặt phòng trực tiếp tại quầy/qua điện thoại.
* **Chi tiết tính năng:**
  * **Định danh khách hàng qua CCCD:** Tự động tra cứu hồ sơ khách hàng cũ hoặc tự động tạo mới khách hàng bằng hàm `findOrUpsertGuestByCCCD`, không đòi hỏi khách phải tạo tài khoản web.
  * **Form nhập liệu doanh nghiệp bắt buộc:** Yêu cầu điền đầy đủ Họ tên, CCCD, SĐT, Email để đảm bảo chuẩn hóa dữ liệu lưu trú theo quy định lưu trú khách sạn.
  * **Tra cứu phòng trống thời gian thực:** Chọn loại phòng, hiển thị ngay danh sách các phòng khả dụng kèm giá niêm yết để lễ tân tích chọn.
  * **2 Luồng chốt đơn linh hoạt:**
    * `[Tạo Đơn Đặt Trước]`: Đặt phòng giữ chỗ trước cho khách, đơn ở trạng thái `DaXacNhan`.
    * `[Nhận Phòng Ngay]`: Dành cho khách nhận phòng tức thì, hệ thống tự động tạo đơn và chuyển hướng thẳng sang cửa sổ xác nhận Check-in.

### 2.3. Quy Trình Tra Cứu & Xác Nhận Check-In (`/receptionist/checkin`)
* **Trách nhiệm:** Đón tiếp khách, kiểm tra tính hợp lệ và bàn giao chìa khóa phòng.
* **Chi tiết tính năng:**
  * **Tra cứu đa kênh thông minh:** Tìm kiếm đơn đặt phòng thần tốc qua *Mã Booking*, *Số điện thoại* hoặc *Số CCCD/Hộ chiếu*.
  * **Kiểm tra điều kiện buồng phòng trước khi nhận:** Chỉ cho phép Check-in khi phòng ở trạng thái `Available` (`[Đã dọn]`). Cảnh báo ngay nếu phòng chưa dọn xong hoặc đang sửa chữa.
  * **Tự động hóa hoàn toàn ở tầng CSDL:** Khi bấm Check-in thành công:
    * Đơn chuyển sang `DaCheckIn`, ghi nhận `NgayCheckInThucTe = GETDATE()`, gắn mã `MaNV` của lễ tân thực hiện.
    * Database Trigger `trg_DongBoTrangThaiPhongCheckIn` tự động chuyển trạng thái phòng sang `Occupied` (`[Đang ở]`).

### 2.4. Gọi Dịch Vụ Lưu Trú Tại Phòng (`/receptionist/order-service`)
* **Trách nhiệm:** Ghi nhận các nhu cầu phát sinh của khách trong suốt kỳ nghỉ (Buffet sáng, Nước uống minibar, Giặt ủi, Spa, Thuê xe...).
* **Chi tiết tính năng:**
  * **Ràng buộc kiểm soát chặt chẽ:** Chỉ cho phép gọi dịch vụ vào các phòng đang có khách ở (`Occupied` và `DaCheckIn`).
  * **Chốt giá niêm yết bất biến:** Đơn giá dịch vụ được cố định tại thời điểm gọi (`DICHVU.DonGia`), tránh việc điều chỉnh giá dịch vụ sau này làm sai lệch hóa đơn.
  * **Lưu vết chi tiết vào `BOOKING_DICHVU`:** Ghi nhận số lượng, thành tiền, thời điểm thêm và mã nhân viên tiếp nhận.

---

## 3. CÁC Ý TƯỞNG ĐỘT PHÁ & CẢI TIẾN GIAO DIỆN TRONG QUÁ TRÌNH THỰC HIỆN

Trong quá trình xây dựng Phase 3, nhiều giải pháp kỹ thuật và thẩm mỹ doanh nghiệp đã được nghiên cứu và đưa vào thực tế:

| STT | Vấn Đề Phát Sinh / Nhu Cầu | Ý Tưởng & Giải Pháp Thực Hiện | Hiệu Quả Đạt Được |
|:---:|:---|:---|:---|
| **1** | **Chuẩn mực Enterprise UI (Không Icon/Emoji)** | Thay thế toàn bộ icon hình ảnh và emoji bằng **Text Badges** và các dải màu nền CSS chuyên biệt: `[Đã dọn]`, `[Bẩn]`, `[Đang dọn]`, `[Bảo trì]`. | Giao diện thanh lịch, nghiêm túc, đúng chuẩn hệ thống phần mềm quản lý khách sạn quốc tế (PMS). |
| **2** | **Cột thứ bị rườm rà** | Cắt bỏ phần ngày tháng `(dd/MM)`, chỉ hiển thị thuần tên thứ: `Thứ 2`, `Thứ 3`... `Chủ Nhật`. | Tiêu đề gọn gàng, tăng diện tích hiển thị và tập trung thị giác vào dải thanh timeline. |
| **3** | **Thanh Timeline bị tràn viền (Overshoot)** | Áp dụng `table-layout: fixed;` cho bảng timeline để 7 ngày luôn chia đều tỷ lệ chuẩn; đồng thời bổ sung chặn biên trần `colSpan <= 7 - startCol + 1` ở cả tầng DAO và CSS. | Xóa bỏ triệt để hiện tượng thanh đặt phòng dài vượt ra ngoài mép phải của bảng khi tên khách dài. |
| **4** | **Va chạm thị giác (Collision) giữa các đơn liền kề** | Thiết lập khoảng lùi `left: 12px` và độ rộng dải `calc(N * 100% - 24px)`, tạo ra **khoảng hở thở (gap) cố định 24px** giữa 2 khách trả và nhận cùng ngày. | Hai thanh booking liền kề trên cùng một phòng hoàn toàn tách bạch, độc lập, bo góc 8px rõ nét. |
| **5** | **Khắc phục lỗi cú pháp CSS/JSP** | Chuyển giao toàn bộ việc tính toán giới hạn độ rộng cho các class `.span-1` đến `.span-7`, loại bỏ biểu thức `calc()` lồng EL phức tạp trong thẻ HTML. | Mã nguồn sạch sẽ, tương thích 100% chuẩn W3C, không còn cảnh báo đỏ trong IDE. |

---

## 4. TỐI ƯU HÓA & ĐỒNG BỘ CSDL: LOẠI BỎ CỘT DƯ THỪA

Sau khi phân tích sâu về luồng vận hành khách sạn, nhóm đã tiến hành **tái cấu trúc (Refactoring)** lược đồ CSDL:

* **Loại bỏ cột `PhuongPhapBooking` khỏi bảng `BOOKING`:**
  * **Lý do nghiệp vụ:** Mọi logic vận hành (đặt phòng, check-in, check-out, hủy phòng) không hề phụ thuộc vào cột này. Bản thân hai cột `MaTaiKhoan` (khách web tự đặt) và `MaNV` (nhân viên lễ tân tiếp nhận) đã tự động phân định nguồn gốc của đơn mà không cần cột riêng.
  * **Lợi ích kỹ thuật:** Giúp câu lệnh SQL ngắn gọn hơn, bảng `BOOKING` thu gọn về đúng 9 cột chuẩn hóa, giảm kích thước lưu trữ và đơn giản hóa các tầng DAO/Model.
* **Đồng bộ hóa 100% trên toàn bộ hệ thống:**
  * Đã xóa Constraint `CK_BOOKING_PhuongPhap` và cột trên SQL Server thực tế.
  * Đã cập nhật lại các file kịch bản: `01_Script_QuanLyKhachSan.sql`, `04_Procedure.sql` (`sp_TaoDonDatPhongOnline`), `05_Trigger.sql` (`trg_AutoPK_BOOKING`), `07_Transaction.sql` (`sp_Transaction_TaoBookingTronGoi`).
  * Đã dọn dẹp các Entity, DTO và câu lệnh SQL trong `BookingDAO.java`, `Booking.java`, `BookingDetailDTO.java`, `booking_detail.jsp` và các bài kiểm thử tự động.

---

## 5. KIẾN TRÚC HỆ THỐNG & KIỂM ĐỊNH CHẤT LƯỢNG MÃ NGUỒN

Hệ thống tuân thủ nghiêm ngặt mô hình kiến trúc phân lớp chuẩn doanh nghiệp (**3-Tier Architecture**):

```
[Presentation Layer]   JSP Views (room_map.jsp, booking_form.jsp, checkin.jsp, order_service.jsp)
        ↓
[Controller Layer]     ReceptionistPortalServlet, ReceptionistBookingServlet, ReceptionistCheckInServlet...
        ↓
[Service Layer]        RoomMapService, BookingService, CheckInService, RoomServiceOrderService...
        ↓
[Data Access Layer]    BookingDAO, RoomDAO, CustomerDAO, BookingCheckInDAO, ServiceDAO...
        ↓
[Database Layer]       Microsoft SQL Server (Tables, Triggers, Stored Procedures, Views)
```

### Kết quả kiểm định tự động:
* **Kiểm tra quy tắc kiến trúc (ArchUnit / Maven Test):**
  * `com.mycompany.hotelmanagersystem.architecture.ArchitectureRulesTest`
  * **Kết quả: 7/7 Tests Passed (0 Failure, 0 Error)** — Không có hiện tượng Controller truy cập trực tiếp DAO, không có phụ thuộc vòng, phân chia package mạch lạc.
* **Kiểm tra đóng gói ứng dụng:**
  * `mvn war:exploded` biên dịch thành công 69 file nguồn và đồng bộ nóng lên máy chủ Tomcat.

---

## 6. KẾ HOẠCH & ĐỊNH HƯỚNG CHUYỂN GIAO SANG GIAI ĐOẠN 4 (PHASE 4)

Giai đoạn 3 đã chuẩn bị sẵn sàng toàn bộ nền tảng dữ liệu phục vụ cho **Giai đoạn 4: Phân Hệ Thu Ngân, Quyết Toán & Trả Phòng (Cashier & Check-Out)**:

1. **Thủ tục Check-out & Bàn giao phòng:**
   * Lễ tân/Thu ngân xác nhận khách trả phòng: Cập nhật `TrangThai = 'DaCheckOut'`, ghi nhận `NgayCheckOutThucTe = GETDATE()`.
   * Trigger tự động chuyển trạng thái phòng sang `Dirty` (`[Bẩn]`) để thông báo cho nhân viên buồng phòng dọn dẹp.
2. **Quyết toán Hóa đơn tổng hợp (`HOADON`):**
   * Tự động tính toán chi phí lưu trú thực tế: `Tổng tiền phòng + Tổng tiền dịch vụ phát sinh + Phụ thu (nếu trả trễ quá giờ quy định) - Giảm trừ/Khuyến mãi`.
3. **Thanh toán đa phương thức (`THANHTOAN`):**
   * Hỗ trợ thanh toán bằng Tiền mặt, Quẹt thẻ POS ngân hàng, hoặc Chuyển khoản qua mã QR tĩnh/động.
   * Cập nhật trạng thái hóa đơn sang `DaThanhToan`.
4. **Xuất hóa đơn & Báo cáo doanh thu:**
   * In hóa đơn thanh toán chi tiết cho khách hàng.
   * Thống kê doanh thu theo ngày, theo ca làm việc của từng thu ngân.

---
*Báo cáo được lập và lưu trữ chính thức tại: `docs/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_TongKet_GiaiDoan_3.md`*
