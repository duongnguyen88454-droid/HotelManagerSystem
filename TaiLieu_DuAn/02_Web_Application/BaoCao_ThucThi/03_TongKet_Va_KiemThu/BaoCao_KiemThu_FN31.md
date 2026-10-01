# BÁO CÁO KẾT QUẢ KIỂM THỬ ĐỘC LẬP: CHỨC NĂNG FN-3.1
## PHÂN HỆ LỄ TÂN (RECEPTIONIST PORTAL) — TẢI DỮ LIỆU PHÒNG THỰC TẾ & KPI BUỒNG PHÒNG
*(Verification Report: Real-Time Room Matrix & Housekeeping KPI Engine)*

> **Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10  
> **Môn học:** Lập Trình Web (JSP/Servlet) & Hệ Quản Trị CSDL — HCMUTE  
> **Chức năng kiểm thử:** FN-3.1 (Tải phòng thực tế theo tầng & Tính toán chỉ số KPI buồng phòng)  
> **Thời điểm kiểm thử:** 01/10/2026  
> **Người thực hiện:** AI Pair Programmer & Lập Trình Viên  
> **Trạng thái:** **20/20 TEST CASES PASS (100%)** — KHÔNG CÓ LỖI PHÁT SINH

---

## 1. MỤC TIÊU & PHẠM VI BỘ KIỂM THỬ (TEST SCOPE)

Bộ kiểm thử 20 Test Cases (TC-3.1.01 $\to$ TC-3.1.20) được thiết kế chuyên biệt nhằm thẩm định toàn diện tính đúng đắn của chức năng **FN-3.1**, tập trung vào 4 khía cạnh kỹ thuật cốt lõi:
1. **Truy vấn Dữ liệu CSDL SQL Server:** Tính toàn vẹn của câu truy vấn DAO, phép kết (JOIN) giữa `PHONG` và `LOAIPHONG`, thứ tự sắp xếp phòng và thuật toán trích xuất tầng.
2. **Công thức & Logic Thống kê KPI:** Tính toán chính xác tổng số phòng, phân loại 6 trạng thái buồng phòng (`Available`, `Occupied`, `Dirty`, `Cleaning`, `Damaged`, `Booked`), tỷ lệ lấp đầy phòng (`Occupancy Rate`) và kiểm thử an toàn phép chia cho 0 (`Zero Division`).
3. **Quy đổi Text Badge & CSS Class:** Tính năng sinh Text Badge thuần văn bản (`[Đã dọn]`, `[Bẩn]`, `[Đang dọn]`, `[Bảo trì]`, `[Đang có khách]`, `[Đã giữ chỗ]`) và class màu nền CSS tương ứng trong `RoomTimelineDTO`.
4. **Quy chuẩn Giao diện Doanh nghiệp:** Quét mã nguồn file giao diện [room_map.jsp](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/src/main/webapp/views/receptionist/room_map.jsp) nhằm bảo đảm **tuyệt đối không dùng Icon Font và không chứa ký tự Emoji**.

---

## 2. BẢNG TỔNG HỢP KẾT QUẢ 20 TEST CASES

| STT | Mã Test Case | Tên Test Case & Mục Tiêu Nghiệm Thu | Kết Quả Kỳ Vọng (Expected) | Kết Quả Thực Tế (Actual) | Trạng Thái |
|:---:|:---:|:---|:---|:---|:---:|
| 1 | **TC-3.1.01** | **Truy vấn danh sách phòng thực tế từ CSDL**<br>Đảm bảo `RoomDAO.getAllRoomsForTimeline()` trả về dữ liệu thực tế. | Danh sách phòng khác `null` và có số lượng $> 0$. | Tìm thấy **12 phòng** hoạt động trong CSDL SQL Server. | **PASS** |
| 2 | **TC-3.1.02** | **Sắp xếp phòng tăng dần theo số phòng**<br>Thẩm định thứ tự hiển thị phòng từ tầng thấp đến tầng cao. | Số phòng các bản ghi liền kề phải tăng dần (`101` $\to$ `403`). | 100% bản ghi được sắp xếp tăng dần chính xác theo `SoPhong ASC`. | **PASS** |
| 3 | **TC-3.1.03** | **Trích xuất tầng (`SoTang`) từ số phòng**<br>Kiểm tra thuật toán bóc tách ký tự đầu số phòng để phân tầng. | `SoTang` bằng ký tự đầu tiên của `SoPhong` (`101` $\to$ T1, `401` $\to$ T4). | 100% các phòng đều phân tầng chuẩn xác (`T1`, `T2`, `T3`, `T4`). | **PASS** |
| 4 | **TC-3.1.04** | **Xử lý an toàn khi số phòng đặc biệt**<br>Kiểm tra khả năng chịu lỗi khi `SoPhong` bị `null`, rỗng hoặc ký tự chữ. | Không văng `NullPointerException` hoặc `IndexOutOfBoundsException`. | Khởi tạo an toàn, gán giá trị tầng mặc định (`SoTang = 1`). | **PASS** |
| 5 | **TC-3.1.05** | **Toàn vẹn dữ liệu JOIN `LOAIPHONG`**<br>Đảm bảo tên hạng phòng hiển thị đầy đủ, không bị rỗng. | Tất cả phòng có `tenLoaiPhong != null` và không rỗng. | 100% phòng có đầy đủ tên hạng phòng (`Standard Single`, `Deluxe King`...). | **PASS** |
| 6 | **TC-3.1.06** | **Kiểm tra đơn giá niêm yết của phòng**<br>Đảm bảo giá phòng từ bảng `LOAIPHONG` hợp lệ. | `giaPhong > 0` cho toàn bộ danh sách phòng. | 100% phòng có đơn giá hợp lệ ($450.000$ đ $\to$ $4.500.000$ đ). | **PASS** |
| 7 | **TC-3.1.07** | **Tính hợp lệ của trạng thái buồng phòng**<br>Đối soát trạng thái trả về với `CHECK constraint` của CSDL. | Trạng thái phòng thuộc tập (`Available`, `Booked`, `Occupied`, `Dirty`, `Cleaning`, `Damaged`). | Toàn bộ trạng thái khớp 100% với danh mục hợp lệ trong CSDL. | **PASS** |
| 8 | **TC-3.1.08** | **Quy đổi Text Badge cho phòng `Available`**<br>Kiểm tra nhãn hiển thị và CSS class. | Badge: `[Đã dọn]`, CSS: `badge-clean`. | `getTrangThaiBadgeText() = "[Đã dọn]"`<br>`getTrangThaiCssClass() = "badge-clean"`. | **PASS** |
| 9 | **TC-3.1.09** | **Quy đổi Text Badge cho phòng `Occupied`**<br>Kiểm tra nhãn hiển thị và CSS class. | Badge: `[Đang có khách]`, CSS: `badge-occupied`. | `getTrangThaiBadgeText() = "[Đang có khách]"`<br>`getTrangThaiCssClass() = "badge-occupied"`. | **PASS** |
| 10 | **TC-3.1.10** | **Quy đổi Text Badge cho phòng `Dirty`**<br>Kiểm tra nhãn hiển thị và CSS class. | Badge: `[Bẩn]`, CSS: `badge-dirty`. | `getTrangThaiBadgeText() = "[Bẩn]"`<br>`getTrangThaiCssClass() = "badge-dirty"`. | **PASS** |
| 11 | **TC-3.1.11** | **Quy đổi Text Badge cho phòng `Cleaning`**<br>Kiểm tra nhãn hiển thị và CSS class. | Badge: `[Đang dọn]`, CSS: `badge-cleaning`. | `getTrangThaiBadgeText() = "[Đang dọn]"`<br>`getTrangThaiCssClass() = "badge-cleaning"`. | **PASS** |
| 12 | **TC-3.1.12** | **Quy đổi Text Badge cho phòng `Damaged`**<br>Kiểm tra nhãn hiển thị và CSS class. | Badge: `[Bảo trì]`, CSS: `badge-maintenance`. | `getTrangThaiBadgeText() = "[Bảo trì]"`<br>`getTrangThaiCssClass() = "badge-maintenance"`. | **PASS** |
| 13 | **TC-3.1.13** | **Quy đổi Text Badge cho phòng `Booked`**<br>Kiểm tra nhãn hiển thị và CSS class. | Badge: `[Đã giữ chỗ]`, CSS: `badge-booked`. | `getTrangThaiBadgeText() = "[Đã giữ chỗ]"`<br>`getTrangThaiCssClass() = "badge-booked"`. | **PASS** |
| 14 | **TC-3.1.14** | **Xử lý Text Badge cho trạng thái ngoại lệ**<br>Kiểm tra cơ chế fallback khi gặp trạng thái lạ. | Badge: `[CustomStatus]`, CSS: `badge-secondary`. | Không bị crash, trả về `[CustomStatus]` và CSS `badge-secondary`. | **PASS** |
| 15 | **TC-3.1.15** | **Đồng bộ Tổng số phòng giữa KPI và Danh sách**<br>Khớp số lượng giữa câu lệnh gom nhóm và câu lệnh lấy chi tiết. | `kpi.getTongSoPhong() == rooms.size()`. | `kpi.tongSoPhong = 12` trùng khớp `rooms.size() = 12`. | **PASS** |
| 16 | **TC-3.1.16** | **Tính bảo toàn tổng phòng trong KPI**<br>Đảm bảo tổng các trạng thái thành phần bằng tổng số phòng. | `sum(Avail + Occ + Dirty + Clean + Dmg + Booked) == Tong`. | $6 + 2 + 1 + 1 + 1 + 1 = 12$ (Khớp tuyệt đối 100%). | **PASS** |
| 17 | **TC-3.1.17** | **Đối soát chéo từng số liệu KPI với đếm thực tế**<br>Đếm tay từng phòng trong danh sách và so với kết quả KPI. | Khớp từng chỉ số thành phần: $6$ Trống, $2$ Đang ở, $1$ Bẩn, $1$ Đang dọn, $1$ Hỏng, $1$ Đã giữ. | Trùng khớp 100% giữa kết quả đếm mảng và kết quả câu truy vấn SQL. | **PASS** |
| 18 | **TC-3.1.18** | **Công thức & Định dạng Tỷ lệ lấp đầy phòng**<br>Kiểm tra công thức `% Occupancy = (Occupied / Tổng) * 100`. | `% Lấp đầy = (2 / 12) * 100 = 16.7%`. | `occupancyRate = 16.666...%`, chuỗi format hiển thị: `16.7%`. | **PASS** |
| 19 | **TC-3.1.19** | **Xử lý an toàn khi tổng số phòng = 0**<br>Kiểm tra phép chia cho 0 trong công thức lấp đầy. | Không bị `NaN` hoặc `Infinity`, tỷ lệ trả về `0.0%`. | `occupancyRate = 0.0`, chuỗi format hiển thị: `0.0%`. | **PASS** |
| 20 | **TC-3.1.20** | **Tuân thủ quy chuẩn UI: 0 Icon Font, 0 Emoji**<br>Quét toàn bộ mã nguồn JSP hiển thị. | $0$ Emoji, không chứa class `fa-`, `bi-`, `glyphicon`. | Quét [room_map.jsp](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/src/main/webapp/views/receptionist/room_map.jsp): **0 Emoji, 0 FontAwesome, 0 BootstrapIcon**. | **PASS** |

---

## 3. PHÂN TÍCH CHI TIẾT SỐ LIỆU ĐỐI SOÁT CSDL THỰC TẾ

### 3.1. Danh Sách 12 Phòng Thực Tế Được Phân Bổ Theo Tầng
```text
  [+] TẦNG 1:
      • Phòng 101 | Standard Single | Đơn giá:   450.000 đ | Trạng thái: Available [Đã dọn]
      • Phòng 102 | Standard Single | Đơn giá:   450.000 đ | Trạng thái: Dirty     [Bẩn]
      • Phòng 103 | Standard Double | Đơn giá:   650.000 đ | Trạng thái: Available [Đã dọn]

  [+] TẦNG 2:
      • Phòng 201 | Standard Double | Đơn giá:   650.000 đ | Trạng thái: Occupied  [Đang có khách]
      • Phòng 202 | Deluxe King     | Đơn giá: 1.100.000 đ | Trạng thái: Booked    [Đã giữ chỗ]
      • Phòng 203 | Deluxe King     | Đơn giá: 1.100.000 đ | Trạng thái: Available [Đã dọn]

  [+] TẦNG 3:
      • Phòng 301 | Family Suite    | Đơn giá: 1.850.000 đ | Trạng thái: Cleaning  [Đang dọn]
      • Phòng 302 | Family Suite    | Đơn giá: 1.850.000 đ | Trạng thái: Occupied  [Đang có khách]
      • Phòng 303 | Family Suite    | Đơn giá: 1.850.000 đ | Trạng thái: Available [Đã dọn]

  [+] TẦNG 4:
      • Phòng 401 | Presidential    | Đơn giá: 4.500.000 đ | Trạng thái: Damaged   [Bảo trì]
      • Phòng 402 | Presidential    | Đơn giá: 4.500.000 đ | Trạng thái: Available [Đã dọn]
      • Phòng 403 | Deluxe King     | Đơn giá: 1.100.000 đ | Trạng thái: Available [Đã dọn]
```

### 3.2. Bảng Thống Kê Chỉ Số KPI Buồng Phòng Khớp CSDL 100%
* **Tổng số phòng trong khách sạn:** **12** phòng.
* **Số phòng trống sạch đón khách (`Available`):** **6** phòng ($50.0\%$).
* **Số phòng đang có khách ở (`Occupied`):** **2** phòng ($16.7\%$).
* **Số phòng bẩn chờ dọn dẹp (`Dirty`):** **1** phòng ($8.3\%$).
* **Số phòng buồng phòng đang dọn (`Cleaning`):** **1** phòng ($8.3\%$).
* **Số phòng hư hỏng tạm khóa (`Damaged`):** **1** phòng ($8.3\%$).
* **Số phòng đã giữ chỗ (`Booked`):** **1** phòng ($8.3\%$).
* **Tỷ lệ lấp đầy phòng thời gian thực:** **16.7%** ($2 / 12$).

---

## 4. GHI NHẬN LỖI (DEFECT / BUG LOG)

* **Số lượng lỗi phát hiện:** **0 LỖI**.
* Toàn bộ 20 test cases được thực thi tự động qua test runner độc lập đều đạt kết quả **PASS 100%**.
* Không có lỗi biên dịch, không có lỗi ngoại lệ thời gian chạy (Runtime Exception), không có xung đột dữ liệu hay sai lệch logic.

---

## 5. KẾT LUẬN & ĐỀ XUẤT

Chức năng **FN-3.1 (Tải dữ liệu phòng thực tế & Thanh KPI Buồng phòng)** đã hoàn thành xuất sắc toàn bộ chỉ tiêu kỹ thuật và sẵn sàng nghiệm thu. Hệ thống hiện đã có nền tảng dữ liệu phòng thực tế vững chắc để chuyển sang bước tiếp theo: **FN-3.2 (Truy vấn & Render thanh Đặt phòng Booking Bars tuần)**.
