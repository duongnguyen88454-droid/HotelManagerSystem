# HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
# KỊCH BẢN THUYẾT TRÌNH BẢO VỆ ĐỒ ÁN CƠ SỞ DỮ LIỆU (PHÂN CÔNG 4 THÀNH VIÊN)

> **Mục tiêu:** Thuyết trình trực diện, gắn liền logic nghiệp vụ từ Giao diện (UI) $\rightarrow$ Mã nguồn Backend $\rightarrow$ Thủ tục lưu trữ (Stored Procedure) $\rightarrow$ Bộ máy CSDL (Index, Function, View, Trigger).
> **Phạm vi bảo đảm:** Phủ kín **100%** toàn bộ các đối tượng CSDL cốt lõi trong hệ thống (5 Index, 7 Function nghiệp vụ, 10 Stored Procedure, 11 Trigger, 11 View). Không nói các function sinh mã tự tăng.

---

## 1. MA TRẬN ĐỐI SOÁT 100% CSDL GIỮA 4 THÀNH VIÊN

| Loại đối tượng | Tổng số | Thành viên 1 (Đặt phòng & Cọc) | Thành viên 2 (Lễ tân Check-in) | Thành viên 3 (Dịch vụ & Check-out) | Thành viên 4 (Buồng phòng & Báo cáo) | Tỷ lệ phủ |
| :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| **Index** | **5** | `IX_Booking_CustomerId_CreateDate` | `IX_BookingRoom_ConflictCheck` | `IX_Payment_InvoiceId` | `IX_RoomCleaningTask_Active`<br>`IX_Invoice_Unpaid` | **100%** |
| **Procedure** | **10** | `sp_XacNhanThanhToanCoc` | `sp_CheckInNhanPhong`<br>`sp_ThemPhong` | `sp_GoiThemDichVu`<br>`sp_GhiNhanThanhToan`<br>`sp_CheckOutTraPhong` | `sp_CapNhatTienDoDonPhong`<br>`sp_HuyPhong`<br>`sp_ThemNhanVien`<br>`sp_ThemTaiKhoan` | **100%** |
| **View** | **11** | `v_RoomDetails`<br>`v_CustomerBookingHistory` | `v_ArrivalCheckInBookings`<br>`v_DamageReports`<br>`v_MaintenancePendingRooms` | `v_ReceivableBookings`<br>`v_PaymentReceiptReport`<br>`v_InvoiceRevenueReport` | `v_HousekeeperTasks`<br>`v_RefundRequests`<br>`v_RoomOccupancyRate` | **100%** |
| **Trigger** | **11** | `trg_Booking_TuDongTaoHoaDon`<br>`trg_BookingRoom_CapNhatHoaDon`<br>`trg_Payment_DongBoTrangThaiHoaDon` | `trg_BookingRoom_KiemTraXungDot`<br>`trg_BookingRoom_DongBoCheckIn`<br>`trg_DamageReport_CapNhatTrangThaiPhong` | `trg_BookingRoomService_CapNhatTienDichVu`<br>`trg_BookingRoom_DongBoCheckOut` | `trg_RoomCleaningTask_HoanTatDonPhong`<br>`trg_Cancellation_DongBoHuyPhong`<br>`trg_Employee_KhoaTaiKhoanNghiViec` | **100%** |
| **Function (Nghiệp vụ)** | **7** | `fn_KiemTraPhongTrongTrongKhoang`<br>`fn_TinhTienPhongBooking` | `fn_TinhPhuThuCheckInSom` | `fn_TinhTienDichVuBooking`<br>`fn_TinhTongTienHoaDonDuKien` | `fn_TinhPhuThuCheckOutTre`<br>`fn_TinhTienHoanTraHuyPhong` | **100%** |
| **TỔNG ĐỐI TƯỢNG** | **44** | **9 đối tượng** | **10 đối tượng** | **11 đối tượng** | **14 đối tượng** | **44 / 44** |

---

## 2. CHI TIẾT DANH MỤC CỤ THỂ CỦA TỪNG THÀNH VIÊN

---

### 👤 THÀNH VIÊN 1: LUỒNG TÌM KIẾM, ĐẶT PHÒNG & ĐẶT CỌC (9 đối tượng)
* **1 Index:**
  1. `IX_Booking_CustomerId_CreateDate`: Tối ưu tra cứu lịch sử đơn đặt phòng của khách hàng theo mã khách hàng và ngày giảm dần.
* **2 Function (Nghiệp vụ):**
  1. `fn_KiemTraPhongTrongTrongKhoang`: Kiểm tra phòng có khả dụng, không bảo trì và không bị giao thoa lịch.
  2. `fn_TinhTienPhongBooking`: Tính tổng tiền phòng dựa theo số ngày đêm lưu trú thực tế.
* **1 Procedure:**
  1. `sp_XacNhanThanhToanCoc`: Ghi nhận giao dịch thanh toán tiền cọc của khách vào bảng `Payment`.
* **3 Trigger:**
  1. `trg_Booking_TuDongTaoHoaDon`: Tự động tạo một hóa đơn rỗng trạng thái `Unpaid` ngay khi có đơn `Booking` mới.
  2. `trg_BookingRoom_CapNhatHoaDon`: Tự động tính tiền phòng cập nhật vào cột `TotalRoomCharge` của hóa đơn.
  3. `trg_Payment_DongBoTrangThaiHoaDon`: Tự động đổi trạng thái hóa đơn sang `'PartiallyPaid'` khi nhận được tiền cọc.
* **2 View:**
  1. `v_RoomDetails`: Chi tiết phòng, giá niêm yết, tiện nghi và loại giường chuẩn 3NF.
  2. `v_CustomerBookingHistory`: Danh sách lịch sử các đơn đặt phòng của khách hàng.

---

### 👤 THÀNH VIÊN 2: LUỒNG LỄ TÂN CHECK-IN & BẢO TRÌ PHÒNG (10 đối tượng)
* **1 Index:**
  1. `IX_BookingRoom_ConflictCheck`: Index phức hợp 4 cột kiểm tra giao thoa lịch đặt, chống quét toàn bảng.
* **1 Function (Nghiệp vụ):**
  1. `fn_TinhPhuThuCheckInSom`: Tự động tính tiền phụ thu nhận phòng sớm trước 13h00 theo loại phòng.
* **2 Procedure:**
  1. `sp_CheckInNhanPhong`: Ghi nhận giờ nhận phòng thực tế và đổi trạng thái phòng sang `CheckedIn`.
  2. `sp_ThemPhong`: Tạo mới phòng vật lý và kết nối hạng phòng an toàn.
* **3 Trigger:**
  1. `trg_BookingRoom_KiemTraXungDot`: Chặn xếp vào phòng đang bảo trì và chống Overbooking khi trùng lịch.
  2. `trg_BookingRoom_DongBoCheckIn`: Tự động đổi trạng thái phòng sang `'Occupied'` (Có người ở) khi check-in.
  3. `trg_DamageReport_CapNhatTrangThaiPhong`: Tự động đổi phòng sang `'Maintenance'` khi phát hiện hư hại.
* **3 View:**
  1. `v_ArrivalCheckInBookings`: Màn hình danh sách khách dự kiến đến tại quầy lễ tân.
  2. `v_DamageReports`: Danh sách sự cố hư hại thiết bị (xây dựng phục vụ bộ phận Buồng phòng theo dõi hỏng hóc).
  3. `v_MaintenancePendingRooms`: Danh sách phòng hỏng chờ sửa chữa (xây dựng cho Quản lý điều phối & nghiệm thu bảo trì; gián tiếp khóa phòng trên Timeline của Lễ tân).

---

### 👤 THÀNH VIÊN 3: LUỒNG PHỤC VỤ DỊCH VỤ & CHECK-OUT QUYẾT TOÁN (11 đối tượng)
* **1 Index:**
  1. `IX_Payment_InvoiceId`: Covering Index với `INCLUDE(TotalAmount, PaymentDate)` giúp tính tổng tiền thanh toán tức thì.
* **2 Function (Nghiệp vụ):**
  1. `fn_TinhTienDichVuBooking`: Tính tổng tiền dịch vụ theo `UnitPrice * Quantity`.
  2. `fn_TinhTongTienHoaDonDuKien`: Tổng hợp toàn bộ chi phí: Tiền phòng + Dịch vụ + Phụ thu nhận sớm + Phụ thu trả trễ.
* **3 Procedure:**
  1. `sp_GoiThemDichVu`: Thêm dịch vụ phòng phát sinh trong kỳ lưu trú.
  2. `sp_GhiNhanThanhToan`: Ghi nhận khoản thanh toán dứt điểm hóa đơn của thu ngân.
  3. `sp_CheckOutTraPhong`: Xác nhận trả phòng và ghi nhận giờ check-out thực tế.
* **2 Trigger:**
  1. `trg_BookingRoomService_CapNhatTienDichVu`: Tự động cộng dồn tiền dịch vụ mới vào `TotalServiceCharge` trên hóa đơn.
  2. `trg_BookingRoom_DongBoCheckOut`: Tự động đổi phòng sang `'Vacant/Dirty'` và tự động sinh bản ghi `RoomCleaningTask`.
* **3 View:**
  1. `v_ReceivableBookings`: Màn hình công nợ hiển thị số tiền nợ còn lại `RemainingDebt` để thu tiền.
  2. `v_PaymentReceiptReport`: Báo cáo phiếu thu tiền mặt/chuyển khoản của ca thu ngân.
  3. `v_InvoiceRevenueReport`: Báo cáo chi tiết cơ cấu doanh thu theo từng hóa đơn.

---

### 👤 THÀNH VIÊN 4: LUỒNG VẬN HÀNH BUỒNG PHÒNG, HỦY PHÒNG & QUẢN TRỊ (14 đối tượng)
* **2 Index (Filtered Index):**
  1. `IX_RoomCleaningTask_Active`: Chỉ mục có điều kiện `WHERE RoomCleaningTaskStatus IN ('Pending', 'InProgress')` tối ưu danh sách dọn phòng.
  2. `IX_Invoice_Unpaid`: Chỉ mục có điều kiện `WHERE InvoiceStatus <> 'Paid'` lọc các đơn chưa thanh toán xong.
* **2 Function (Nghiệp vụ):**
  1. `fn_TinhPhuThuCheckOutTre`: Tự động tính tiền phạt trả phòng muộn sau 12h00 trưa theo loại phòng.
  2. `fn_TinhTienHoanTraHuyPhong`: Tính số tiền hoàn lại khi hủy: `Tiền cọc - Phí phạt hủy`.
* **4 Procedure:**
  1. `sp_CapNhatTienDoDonPhong`: Cập nhật trạng thái nhiệm vụ dọn phòng sang `Completed`.
  2. `sp_HuyPhong`: Xử lý hủy đơn đặt phòng và ghi vào lịch sử hủy.
  3. `sp_ThemNhanVien`: Quản trị viên thêm nhân viên mới.
  4. `sp_ThemTaiKhoan`: Cấp tài khoản đăng nhập hệ thống.
* **3 Trigger:**
  1. `trg_RoomCleaningTask_HoanTatDonPhong`: Tự động đổi trạng thái phòng sang `'Clean'` khi dọn xong.
  2. `trg_Cancellation_DongBoHuyPhong`: Tự động giải phóng phòng về `'Vacant'` khi có lệnh hủy.
  3. `trg_Employee_KhoaTaiKhoanNghiViec`: Tự động khóa tài khoản khi nhân viên nghỉ việc (`IsActive = 0`).
* **3 View:**
  1. `v_HousekeeperTasks`: Màn hình danh sách công việc của nhân viên buồng phòng.
  2. `v_RefundRequests`: Màn hình quản lý phê duyệt hoàn trả tiền cọc cho khách.
  3. `v_RoomOccupancyRate`: Báo cáo tỷ lệ lấp đầy phòng (%) dành cho Ban Giám đốc.

---

## 3. KỊCH BẢN THUYẾT TRÌNH CHI TIẾT TỪNG THÀNH VIÊN (END-TO-END SCRIPT)

---

### 👤 THÀNH VIÊN 1: LUỒNG TÌM KIẾM, ĐẶT PHÒNG & THANH TOÁN CỌC (9 đối tượng)

> **Lời mở đầu:** *"Kính thưa quý thầy cô, em là [Họ Tên], em xin đại diện nhóm trình bày phân hệ Khách hàng: từ thao tác tìm kiếm phòng, kiểm tra khả dụng, tính toán giá cọc đến khi hoàn tất đặt cọc trực tuyến."*

1. **Hiển thị thông tin phòng (View - `v_RoomDetails`):**
   * **Bối cảnh:** Khi khách hàng truy cập trang chủ và thực hiện tra cứu danh sách phòng.
   * **Cách nói:** *"Tại giao diện đặt phòng, Backend gọi qua View `v_RoomDetails`. View này giúp kết hợp dữ liệu từ bảng `Room`, `RoomType` và sử dụng hàm `STRING_AGG` để gộp toàn bộ danh mục tiện ích phòng và loại giường thành các chuỗi mô tả hoàn chỉnh. Điều này giúp loại bỏ hoàn toàn các câu lệnh JOIN phức tạp ở tầng ứng dụng Java và tuân thủ chặt chẽ chuẩn thiết kế 3NF."*

2. **Kiểm tra phòng trống & Tính tiền lưu trú (Function - `fn_KiemTraPhongTrongTrongKhoang` & `fn_TinhTienPhongBooking`):**
   * **Bối cảnh:** Khi khách chọn ngày nhận phòng, ngày trả phòng và bấm xem giá.
   * **Cách nói:** *"Trước khi cho phép đặt, Backend gọi hàm `fn_KiemTraPhongTrongTrongKhoang` truyền vào ngày Check-in và Check-out để kiểm tra phòng có bị rơi vào trạng thái bảo trì hoặc bị giao thoa lịch với bất kỳ đơn nào trước đó hay không. Đồng thời, hàm `fn_TinhTienPhongBooking` tự động tính tổng tiền phòng bằng cách lấy số ngày đêm thực tế nhân với đơn giá niêm yết của hạng phòng đó."*

3. **Tự động sinh hóa đơn & Cập nhật tiền phòng (Trigger - `trg_Booking_TuDongTaoHoaDon` & `trg_BookingRoom_CapNhatHoaDon`):**
   * **Bối cảnh:** Khi khách bấm xác nhận đặt giữ phòng.
   * **Cách nói:** *"Ngay khi bản ghi đơn đặt được chèn vào bảng `Booking`, Trigger `trg_Booking_TuDongTaoHoaDon` tự động tạo một hóa đơn `Invoice` tương ứng với trạng thái ban đầu là `'Unpaid'`. Tiếp theo, khi chi tiết phòng được thêm vào bảng `Booking_Room`, Trigger `trg_BookingRoom_CapNhatHoaDon` lập tức tự động cập nhật số tiền phòng vào cột `TotalRoomCharge` của hóa đơn."*

4. **Xác nhận thanh toán tiền cọc (Procedure - `sp_XacNhanThanhToanCoc` & Trigger - `trg_Payment_DongBoTrangThaiHoaDon`):**
   * **Bối cảnh:** Khi khách quét mã chuyển khoản hoặc thanh toán tiền cọc thành công trên UI.
   * **Cách nói:** *"Khi cổng thanh toán phản hồi thành công, Backend gọi Stored Procedure `sp_XacNhanThanhToanCoc` để ghi nhận phiếu thu cọc vào bảng `Payment`. Ngay khi lệnh INSERT vào bảng Payment hoàn tất, Trigger `trg_Payment_DongBoTrangThaiHoaDon` tự động kích hoạt: tính lại tổng số tiền khách đã thanh toán qua `OUTER APPLY` và so sánh với tổng tiền hóa đơn để tự động đổi trạng thái `InvoiceStatus` sang `'PartiallyPaid'` (Đã cọc) mà không cần can thiệp bằng code Java."*

5. **Tra cứu lịch sử đơn đặt (View - `v_CustomerBookingHistory` & Index - `IX_Booking_CustomerId_CreateDate`):**
   * **Bối cảnh:** Khi khách đăng nhập vào tài khoản cá nhân để xem lại các đơn đã đặt.
   * **Cách nói:** *"Màn hình lịch sử đặt phòng của khách truy vấn qua View `v_CustomerBookingHistory`. Nhóm em đã tối ưu truy vấn này bằng Non-clustered Index `IX_Booking_CustomerId_CreateDate` trên bảng `Booking(CustomerId, CreateDate DESC)`. Nhờ Index này, SQL Server duyệt trực tiếp theo cây B-Tree theo mã khách hàng và trả về kết quả đã sắp xếp sẵn theo ngày mới nhất mà không tốn chi phí chạy thuật toán Sort."*

---

### 👤 THÀNH VIÊN 2: LUỒNG LỄ TÂN TIẾP ĐÓN, CHECK-IN & BẢO TRÌ PHÒNG (10 đối tượng)

> **Lời mở đầu:** *"Kính thưa thầy cô, em là [Họ Tên], em xin tiếp nối với phân hệ Nghiệp vụ Lễ tân tại quầy: tiếp nhận khách đến, kiểm soát xung đột lịch và quản lý phòng bảo trì."*

1. **Màn hình tiếp nhận khách đến (View - `v_ArrivalCheckInBookings`):**
   * **Bối cảnh:** Đầu mỗi ca làm việc, lễ tân mở màn hình quầy tiếp tân.
   * **Cách nói:** *"Lễ tân quản lý danh sách khách đến hôm nay qua View `v_ArrivalCheckInBookings`. View này tự động tổng hợp các đơn đặt phòng có trạng thái `Confirmed` hoặc `CheckedIn`, hiển thị thông tin khách hàng, số phòng cần giao và số phòng đã nhận giúp nhân viên thao tác nhanh chóng."*

2. **Quản lý sự cố phòng hư hại & bảo trì (View - `v_DamageReports` & `v_MaintenancePendingRooms`):**
   * **Bối cảnh:** Phối hợp giữa các bộ phận để kiểm soát phòng an toàn trước khi đón khách.
   * **Cách nói:** *"Để kiểm soát chất lượng buồng phòng, CSDL xây dựng 2 View chuyên trách: `v_DamageReports` phục vụ bộ phận Buồng phòng theo dõi các biên bản sự cố, và `v_MaintenancePendingRooms` phục vụ Quản lý điều phối thợ sửa chữa và nghiệm thu. Về phía Lễ tân, dù giao diện quầy không trực tiếp mở 2 bảng danh sách này, nhưng dữ liệu từ đây sẽ gián tiếp bảo vệ Lễ tân: khi phòng có sự cố chưa nghiệm thu, hệ thống sẽ tự động bôi xám với trạng thái 'Hư hại / Bảo trì' ngay trên Lưới Timeline và Sơ đồ phòng của Lễ tân, giúp Lễ tân tuyệt đối không bao giờ xếp nhầm phòng hỏng cho khách."*

3. **Chặn phòng bảo trì & Chống Overbooking (Trigger - `trg_BookingRoom_KiemTraXungDot` & Index - `IX_BookingRoom_ConflictCheck`):**
   * **Bối cảnh:** Khi xếp phòng hoặc cập nhật lịch lưu trú.
   * **Cách nói:** *"Nếu nhân viên vô tình xếp khách vào phòng đang bảo trì, hoặc xếp đè lịch với một khách khác, Trigger `trg_BookingRoom_KiemTraXungDot` sẽ lập tức ROLLBACK và tung thông báo lỗi ngăn chặn. Nhóm em tối ưu truy vấn kiểm tra giao thoa ngày bằng Index phức hợp 4 cột `IX_BookingRoom_ConflictCheck` trên `Booking_Room(RoomId, BookingStatus, ExpectedCheckInDate, ExpectedCheckOutDate)`, biến thao tác quét toàn bảng thành Index Seek dưới 5ms."*

4. **Tự động khóa phòng khi phát hiện hư hại (Trigger - `trg_DamageReport_CapNhatTrangThaiPhong`):**
   * **Bối cảnh:** Khi bộ phận kỹ thuật hoặc buồng phòng lập biên bản hư hại.
   * **Cách nói:** *"Khi một sự cố hư hỏng phòng được ghi nhận vào bảng `DamageReport`, Trigger `trg_DamageReport_CapNhatTrangThaiPhong` tự động đổi trạng thái phòng trong bảng `Room` thành `'Maintenance'`, giúp phòng đó tự động biến mất khỏi danh sách phòng trống trên toàn hệ thống."*

5. **Phụ thu nhận phòng sớm & Check-in (Function - `fn_TinhPhuThuCheckInSom`, Procedure - `sp_CheckInNhanPhong` & Trigger - `trg_BookingRoom_DongBoCheckIn`):**
   * **Bối cảnh:** Khách đến nhận phòng thực tế tại quầy lễ tân.
   * **Cách nói:** *"Khách sạn quy định giờ Check-in chuẩn là 14h00. Nếu khách đến trước 13h00, hàm `fn_TinhPhuThuCheckInSom` tự động trích xuất phí `EarlyCheckInFee` của loại phòng đó để tính phụ thu. Khi lễ tân bấm 'Xác nhận Check-in', Backend gọi `sp_CheckInNhanPhong` cập nhật ngày giờ thực tế. Trigger `trg_BookingRoom_DongBoCheckIn` lập tức tự động đổi trạng thái phòng sang `'Occupied'` (Có người ở)."*

6. **Mở rộng danh mục phòng khách sạn (Procedure - `sp_ThemPhong`):**
   * **Bối cảnh:** Khi khách sạn đưa thêm phòng mới vào hoạt động.
   * **Cách nói:** *"Quản trị viên sử dụng Procedure `sp_ThemPhong` để thiết lập phòng vật lý mới kèm loại phòng, số tầng và trạng thái sẵn sàng đón khách ban đầu một cách an toàn và nhất quán dữ liệu."*

---

### 👤 THÀNH VIÊN 3: LUỒNG PHỤC VỤ DỊCH VỤ & CHECK-OUT QUYẾT TOÁN (11 đối tượng)

> **Lời mở đầu:** *"Em là [Họ Tên], em xin trình bày phân hệ Phục vụ phòng trong kỳ lưu trú và quy trình Quyết toán hóa đơn - Trả phòng tại quầy Thu ngân."*

1. **Gọi thêm dịch vụ phát sinh (Procedure - `sp_GoiThemDichVu` & Trigger - `trg_BookingRoomService_CapNhatTienDichVu`):**
   * **Bối cảnh:** Trong thời gian lưu trú, khách gọi đồ ăn uống hoặc dịch vụ giặt là.
   * **Cách nói:** *"Khi khách yêu cầu dịch vụ, nhân viên ghi nhận trên hệ thống qua Procedure `sp_GoiThemDichVu`. Ngay khi chèn dữ liệu vào bảng `Booking_Room_Service`, Trigger `trg_BookingRoomService_CapNhatTienDichVu` tự động kích hoạt: tính tiền dịch vụ mới và cộng dồn trực tiếp vào cột `TotalServiceCharge` cũng như `FinalTotalAmount` trên hóa đơn của khách."*

2. **Tính toán chi phí dịch vụ & Tổng hóa đơn (Function - `fn_TinhTienDichVuBooking` & `fn_TinhTongTienHoaDonDuKien`):**
   * **Bối cảnh:** Khách yêu cầu in phiếu tạm tính trước khi rời phòng.
   * **Cách nói:** *"Hệ thống sử dụng hàm `fn_TinhTienDichVuBooking` để tính tổng chi phí dịch vụ theo đơn giá lịch sử nhân số lượng. Đồng thời, hàm `fn_TinhTongTienHoaDonDuKien` tự động gom toàn bộ các cấu phần chi phí: Tiền phòng + Dịch vụ + Phụ thu nhận sớm + Phụ thu trả trễ để cho ra tổng số tiền thực tế của toàn bộ kỳ nghỉ."*

3. **Màn hình công nợ quyết toán (View - `v_ReceivableBookings`):**
   * **Bối cảnh:** Khách đến quầy làm thủ tục trả phòng.
   * **Cách nói:** *"Thu ngân mở màn hình quyết toán nạp dữ liệu từ View `v_ReceivableBookings`. View này đối soát tức thì giữa tổng tiền hóa đơn với số tiền cọc đã thu trước đó, tính sẵn số tiền còn nợ `RemainingDebt = TotalAmount - PaidAmount` để thu ngân thông báo chính xác cho khách."*

4. **Ghi nhận thanh toán dứt điểm (Procedure - `sp_GhiNhanThanhToan` & Index - `IX_Payment_InvoiceId`):**
   * **Bối cảnh:** Khách thanh toán nốt khoản tiền còn thiếu bằng tiền mặt hoặc quẹt thẻ.
   * **Cách nói:** *"Thu ngân thu tiền và gọi `sp_GhiNhanThanhToan`. Quá trình kiểm tra và tổng hợp các lần thanh toán của hóa đơn được tăng tốc bởi Covering Index `IX_Payment_InvoiceId` có mệnh đề `INCLUDE(TotalAmount, PaymentDate)`. Nhờ đó SQL Server chỉ cần đọc dữ liệu ngay trên cây chỉ mục mà không tốn công truy xuất ngược vào bảng vật lý Payment (loại bỏ Key Lookup)."*

5. **Thủ tục Check-out & Tự động giao việc dọn phòng (Procedure - `sp_CheckOutTraPhong` & Trigger - `trg_BookingRoom_DongBoCheckOut`):**
   * **Bối cảnh:** Hoàn tất thanh toán, thu hồi thẻ phòng.
   * **Cách nói:** *"Thu ngân bấm Check-out trên UI, Backend gọi `sp_CheckOutTraPhong` ghi nhận giờ trả phòng. Ngay lập tức, Trigger `trg_BookingRoom_DongBoCheckOut` đổi trạng thái phòng sang `'Vacant'` và `'Dirty'`, đồng thời tự động sinh một bản ghi nhiệm vụ dọn phòng mới trong bảng `RoomCleaningTask` cho bộ phận buồng phòng."*

6. **Báo cáo doanh thu & Phiếu thu ca làm việc (View - `v_PaymentReceiptReport` & `v_InvoiceRevenueReport`):**
   * **Bối cảnh:** Cuối ca làm việc của thu ngân.
   * **Cách nói:** *"Thu ngân sử dụng View `v_PaymentReceiptReport` để in bảng kê các phiếu thu tiền mặt/chuyển khoản trong ca và View `v_InvoiceRevenueReport` để đối chiếu doanh thu tổng hợp trước khi bàn giao quỹ."*

---

### 👤 THÀNH VIÊN 4: LUỒNG VẬN HÀNH BUỒNG PHÒNG, HỦY PHÒNG & BÁO CÁO QUẢN TRỊ (14 đối tượng)

> **Lời mở đầu:** *"Em là [Họ Tên], em xin trình bày phân hệ Vận hành Buồng phòng (Housekeeping), Quy trình xử lý hủy phòng & Báo cáo tỷ lệ lấp đầy dành cho Ban Giám đốc."*

1. **Tiếp nhận dọn phòng (View - `v_HousekeeperTasks` & Index - `IX_RoomCleaningTask_Active`):**
   * **Bối cảnh:** Nhân viên buồng phòng nhận ca dọn dẹp các phòng khách vừa trả.
   * **Cách nói:** *"Nhân viên buồng phòng xem danh sách phòng bẩn trên giao diện qua View `v_HousekeeperTasks`. Màn hình này được tối ưu bằng **Filtered Index** `IX_RoomCleaningTask_Active` với điều kiện lọc `WHERE RoomCleaningTaskStatus IN ('Pending', 'InProgress')`. Bằng cách chỉ đánh chỉ mục cho các nhiệm vụ đang xử lý, hệ thống tiết kiệm được bộ nhớ đệm RAM và giúp nhân viên load màn hình cực kỳ mượt mà."*

2. **Hoàn tất dọn phòng (Procedure - `sp_CapNhatTienDoDonPhong` & Trigger - `trg_RoomCleaningTask_HoanTatDonPhong`):**
   * **Bối cảnh:** Khi dọn xong, kiểm tra phòng đạt chuẩn sạch.
   * **Cách nói:** *"Nhân viên bấm 'Hoàn tất', Backend gọi `sp_CapNhatTienDoDonPhong` cập nhật trạng thái nhiệm vụ là `'Completed'`. Trigger `trg_RoomCleaningTask_HoanTatDonPhong` tự động kích hoạt: đổi trạng thái dọn dẹp của phòng trong bảng `Room` từ `'Cleaning'` sang `'Clean'`, giúp phòng ngay lập tức sẵn sàng đón khách mới mà không cần lễ tân bấm thao tác bằng tay."*

3. **Phụ thu trả phòng trễ (Function - `fn_TinhPhuThuCheckOutTre`):**
   * **Bối cảnh:** Trường hợp khách trả phòng muộn.
   * **Cách nói:** *"Khách sạn quy định giờ trả phòng chuẩn là 12h00 trưa. Nếu khách trả phòng sau 12h00, hàm `fn_TinhPhuThuCheckOutTre` tự động bóc tách giờ trả thực tế, áp dụng mức phí phạt `LateCheckOutFee` tương ứng với hạng phòng đó để tính tiền phụ thu tự động."*

4. **Quy trình Hủy đơn đặt phòng & Hoàn tiền cọc (Procedure - `sp_HuyPhong`, Trigger - `trg_Cancellation_DongBoHuyPhong`, Function - `fn_TinhTienHoanTraHuyPhong` & View - `v_RefundRequests`):**
   * **Bối cảnh:** Khi khách có việc bận yêu cầu hủy đặt phòng trước ngày đến.
   * **Cách nói:** *"Khi khách hủy đơn, Backend gọi `sp_HuyPhong`. Trigger `trg_Cancellation_DongBoHuyPhong` tự động giải phóng phòng về trạng thái trống `'Vacant'` và ghi nhận vào lịch sử hủy. Quản lý sẽ mở View `v_RefundRequests` để duyệt hoàn tiền, trong đó hàm `fn_TinhTienHoanTraHuyPhong` tự động tính chính xác số tiền hoàn lại theo công thức: `Tiền cọc tại thời điểm hủy - Phí phạt hủy phòng`."*

5. **Quản trị nhân sự & Bảo mật phân quyền (Procedure - `sp_ThemNhanVien`, `sp_ThemTaiKhoan` & Trigger - `trg_Employee_KhoaTaiKhoanNghiViec`):**
   * **Bối cảnh:** Khâu quản trị nhân sự của khách sạn.
   * **Cách nói:** *"Admin thêm nhân sự và cấp tài khoản qua 2 Procedure `sp_ThemNhanVien` và `sp_ThemTaiKhoan`. Đặc biệt, để đảm bảo an ninh thông tin, khi một nhân viên nghỉ việc (`IsActive = 0`), Trigger `trg_Employee_KhoaTaiKhoanNghiViec` tự động khóa tài khoản tương ứng, ngăn chặn tuyệt đối nhân viên cũ truy cập trái phép vào dữ liệu khách sạn."*

6. **Báo cáo công suất phòng & Lọc nợ tồn đọng (View - `v_RoomOccupancyRate` & Index - `IX_Invoice_Unpaid`):**
   * **Bối cảnh:** Dành cho Tổng Giám đốc theo dõi hiệu quả kinh doanh.
   * **Cách nói:** *"Ban Giám đốc theo dõi hiệu suất vận hành qua View `v_RoomOccupancyRate` để xem tỷ lệ lấp đầy phòng (%) và cơ cấu phòng (đang ở, đang dọn, đang hỏng). Đồng thời, Filtered Index `IX_Invoice_Unpaid` (`WHERE InvoiceStatus <> 'Paid'`) giúp Ban giám đốc lọc nhanh các hóa đơn công nợ chưa thu tiền mà không cần quét toàn bộ bảng hóa đơn."*

---