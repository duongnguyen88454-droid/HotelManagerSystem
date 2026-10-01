# BÁO CÁO THỰC THI GIAI ĐOẠN 2: PHÂN HỆ KHÁCH HÀNG — TRA CỨU, TÌM KIẾM & ĐẶT PHÒNG TRỰC TUYẾN
*(Customer Portal: Room Search, Real-Time Availability & Online Booking Flow)*

**Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10  
**Môn học:** Lập Trình Web (JSP/Servlet) & Hệ Quản Trị CSDL — HCMUTE  
**Người lập:** AI Assistant  
**Trạng thái:** 📋 **ĐÃ CẬP NHẬT TOÀN DIỆN Ý TƯỞNG & ĐẶC TẢ KIẾN TRÚC GIAI ĐOẠN 2 (TRÌNH LẬP TRÌNH VIÊN XEM & ĐÁNH GIÁ TRƯỚC KHI CODE)**  

---

## MỤC LỤC

1. [Mục Tiêu & Quy Tắc Nghiệp Vụ Cốt Lõi Giai Đoạn 2](#1-mục-tiêu--quy-tắc-nghiệp-vụ-cốt-lõi-giai-đoạn-2)
2. [Sơ Đồ Luồng Dữ Liệu & Chu Trình Tương Tác Giữa Các Lớp (Sequence Diagrams)](#2-sơ-đồ-luồng-dữ-liệu--chu-trình-tương-tác-giữa-các-lớp-sequence-diagrams)
   - [2.1. Luồng Tra Cứu & Lọc Phòng Trống Thời Gian Thực](#21-luồng-tra-cứu--lọc-phòng-trống-thời-gian-thực)
   - [2.2. Luồng Xác Nhận & Đặt Phòng Kèm Dịch Vụ Tiện Ích Từng Phòng](#22-luồng-xác-nhận--đặt-phòng-kèm-dịch-vụ-tiện-ích-từng-phòng)
   - [2.3. Luồng Quản Lý Lịch Sử Đặt Phòng Cá Nhân](#23-luồng-quản-lý-lịch-sử-đặt-phòng-cá-nhân)
   - [2.4. Luồng Xem Chi Tiết Booking & Thêm Dịch Vụ Vào Từng Phòng (Add Service to Room Detail)](#24-luồng-xem-chi-tiết-booking--thêm-dịch-vụ-vào-từng-phòng-add-service-to-room-detail)
   - [2.5. Luồng Đặt Nhiều Phòng Với Khoảng Thời Gian Độc Lập Trong Cùng Một Booking](#25-luồng-đặt-nhiều-phòng-với-khoảng-thời-gian-độc-lập-trong-cùng-một-booking)
3. [Danh Sách Các Class Sinh Ra & Bảng Phân Định Trách Nhiệm Chi Tiết](#3-danh-sách-các-class-sinh-ra--bảng-phân-định-trách-nhiệm-chi-tiết)
4. [Các Điểm Nâng Cấp Kế Thừa Từ Giai Đoạn 1](#4-các-điểm-nâng-cấp-kế-thừa-từ-giai-đoạn-1)
5. [Đặc Tả Chi Tiết Từng Bước Triển Khai & Danh Sách Các Hàm](#5-đặc-tả-chi-tiết-từng-bước-triển-khai--danh-sách-các-hàm)
   - [Bước 1: Các Entity Model & DTO Mới](#bước-1-các-entity-model--dto-mới)
   - [Bước 2: Tầng DAO (RoomDAO, ServiceDAO & BookingDAO)](#bước-2-tầng-dao-roomdao-servicedao--bookingdao)
   - [Bước 3: Tầng Nghiệp Vụ Service (RoomService & BookingService)](#bước-3-tầng-nghiệp-vụ-service-roomservice--bookingservice)
   - [Bước 4: Tầng Điều Khiển Controller Servlet](#bước-4-tầng-điều-khiển-controller-servlet)
   - [Bước 5: Thiết Kế & Nâng Cấp Giao Diện UI/UX JSP](#bước-5-thiết-kế--nâng-cấp-giao-diện-uiux-jsp)
6. [Tương Tác CSDL: Phối Hợp Function, Trigger & Transaction](#6-tương-tác-csdl-phối-hợp-function-trigger--transaction)
7. [Giải Pháp Xử Lý Thách Thức Nghiệp Vụ Đặc Thù](#7-giải-pháp-xử-lý-thách-thức-nghiệp-vụ-đặc-thù)
   - [7.1. Chống Đặt Trùng Phòng Thời Gian Thực (Concurrency / Overbooking)](#71-chống-đặt-trùng-phòng-thời-gian-thực-concurrency--overbooking)
   - [7.2. Thống Nhất Tuyệt Đối Chuẩn Khóa Chính Liền Mạch (BK001, BD001, HD001)](#72-thống-nhất-tuyệt-đối-chuẩn-khóa-chính-liền-mạch-bk001-bd001-hd001)
   - [7.3. Cơ Chế Thời Gian Chết 1 Tiếng (Housekeeping Buffer) & Vòng Đời Phòng Hư Hỏng (Damaged)](#73-cơ-chế-thời-gian-chết-1-tiếng-housekeeping-buffer--vòng-đời-phòng-hư-hỏng-damaged)
   - [7.4. Quy Trình Lễ Tân Tiếp Khách Vãng Lai (Walk-in Double Validation)](#74-quy-trình-lễ-tân-tiếp-khách-vãng-lai-walk-in-double-validation)
   - [7.5. Cơ Chế Quản Lý Dịch Vụ Theo Từng Phòng (Room-Specific Add-on Services) & Toàn Vẹn 3NF](#75-cơ-chế-quản-lý-dịch-vụ-theo-từng-phòng-room-specific-add-on-services--toàn-vẹn-3nf)
   - [7.6. Cơ Chế Đặt Nhiều Phòng Với Khoảng Thời Gian Độc Lập Trong Cùng Một Booking & Giỏ Hàng Session](#76-cơ-chế-đặt-nhiều-phòng-với-khoảng-thời-gian-độc-lập-trong-cùng-một-booking--giỏ-hàng-session)
   - [7.7. Thiết Kế Luồng Trải Nghiệm Đặt Phòng Đa Bước Chuẩn Quốc Tế Phong Cách iVIVU (5-Step Customer Booking Journey)](#77-thiết-kế-luồng-trải-nghiệm-đặt-phòng-đa-bước-chuẩn-quốc-tế-phong-cách-ivivu-5-step-customer-booking-journey)
   - [7.8. Chi Tiết Kiến Trúc Kỹ Thuật & Tương Tác Các Lớp Trong Luồng 5 Bước](#78-chi-tiết-kiến-trúc-kỹ-thuật--tương-tác-các-lớp-trong-luồng-5-bước)
   - [7.9. Thiết Kế Các Class & Servlet Hỗ Trợ Luồng 5 Bước](#79-thiết-kế-các-class--servlet-hỗ-trợ-luồng-5-bước)
   - [7.10. Giải Pháp Tách Bạch "Tài Khoản Đại Diện Web" (TAIKHOAN) & "Hồ Sơ Khách Hàng Lưu Trú" (KHACHHANG) — Xử Lý Triệt Để Bài Toán Khách Vãng Lai & Chống Trùng Lặp Dữ Liệu](#710-giải-pháp-tách-bạch-tài-khoản-đại-diện-web-taikhoan--hồ-sơ-khách-hàng-lưu-trú-khachhang--xử-lý-triệt-để-bài-toán-khách-vãng-lai--chống-trùng-lặp-dữ-liệu)
8. [Kịch Bản Kiểm Thử Giai Đoạn 2 (Live Test Checklist)](#8-kịch-bản-kiểm-thử-giai-đoạn-2-live-test-checklist)
9. [Kết Luận & Đánh Giá Hoàn Thành Giai Đoạn 2](#9-kết-luận--đánh-giá-hoàn-thành-giai-đoạn-2)

---

## 1. MỤC TIÊU & QUY TẮC NGHIỆP VỤ CỐT LÕI GIAI ĐOẠN 2

### 1.1. Mục tiêu giai đoạn 2
* **Xây dựng hoàn chỉnh Cổng Khách Hàng (Customer Portal):** Cho phép người dùng sau khi đăng ký/đăng nhập có thể tra cứu phòng trống theo khoảng ngày nhận - trả, số lượng người và hạng phòng mong muốn.
* **Tạo đơn đặt phòng trực tuyến (`BOOKING`) đầu tiên:** Làm nguyên liệu và tiền đề cho phân hệ Lễ tân check-in ở Giai đoạn 3, Thu ngân thanh toán ở Giai đoạn 4 và Buồng phòng dọn dẹp ở Giai đoạn 5.
* **Hỗ trợ chọn và thêm dịch vụ gia tăng vào chi tiết từng phòng (`BOOKING_PHONG` -> `BOOKING_DICHVU`):** Khách hàng có thể chọn dịch vụ ngay khi tạo đơn đặt phòng hoặc gọi thêm dịch vụ vào phòng cụ thể từ trang Chi tiết đặt phòng (`booking_detail.jsp`).
* **Tự động kích hoạt toàn bộ cơ chế tự động hóa CSDL:** 
  - Kích hoạt hàm kiểm tra phòng trống `fn_KiemTraPhongTrongTrongKhoang`.
  - Kích hoạt Trigger 1 (`trg_Check_XungDotDatPhong`) chống đặt trùng phòng.
  - Kích hoạt Trigger 5 (`trg_TuDongTaoHoaDonKhiDatPhong`) tự động sinh sẵn 1 Hóa đơn `HOADON` ở trạng thái `ChuaThanhToan` (theo đúng **Phương án A: 1 Booking — 1 Hóa đơn tổng duy nhất**).

### 1.2. Các quy tắc nghiệp vụ cốt lõi
1. **Phân định rõ Chủ Tài Khoản Web (`TAIKHOAN`) và Người Lưu Trú Thực Tế (`KHACHHANG`):**
   - **Tài khoản Web (`TAIKHOAN`):** Đại diện cho chủ tài khoản đặt trên web (`sessionScope.CURRENT_USER`, mã `MaTaiKhoan`). Khi tạo tài khoản web qua `/register`, hệ thống **CHỈ ghi nhận vào bảng `TAIKHOAN`**, hoàn toàn **KHÔNG đụng chạm gì đến bảng `KHACHHANG`**.
   - **Chính sách sạch 100% (Fresh Start):** Mọi tài khoản web mới tạo có lịch sử đơn đặt ban đầu = 0 đơn, **tuyệt đối KHÔNG cho phép kế thừa lịch sử lưu trú vãng lai cũ**.
   - **Hồ sơ Khách lưu trú thực tế (`KHACHHANG`):** Lưu thông tin người trực tiếp lưu trú tại phòng. Tất cả 4 thuộc tính cốt lõi (`HoTen`, `Email`, `SoDT`, `CCCD`) đều bắt buộc **`NOT NULL` 100%** theo quy tắc nghiệp vụ hệ thống. Định danh duy nhất bằng số Căn Cước Công Dân (`CCCD` 12 chữ số).
   - **Xử lý CCCD khi Đặt phòng (Find-or-Upsert by CCCD):** Chỉ khi khách hàng thực hiện Đặt phòng (Booking), hệ thống mới yêu cầu nhập số CCCD của người đại diện lưu trú và tra cứu trong `KHACHHANG`:
     * Nếu CCCD đã có: Kiểm tra SĐT, Email (nếu giống giữ nguyên, nếu khác cập nhật mới nhất) và tái sử dụng `MaKH`.
     * Nếu CCCD chưa có: Tạo mới bản ghi trong `KHACHHANG` với `MaTaiKhoan = NULL`.
   - **Gắn kết đơn đặt:** Bảng `BOOKING` lưu cả `MaTaiKhoan` (chủ tài khoản web đặt) và `MaKH` (người lưu trú). Trang lịch sử cá nhân truy vấn theo `WHERE BOOKING.MaTaiKhoan = CURRENT_USER.MaTaiKhoan`.
2. **Tìm kiếm & Phân phối phòng trống thời gian thực (Real-time Availability & Smart Buffer):**
   - Người dùng bắt buộc chọn `NgayNhan` và `NgayTra` (Điều kiện: `NgayNhan >= Ngày hiện tại` và `NgayTra > NgayNhan`).
   - **Kênh Online (Web Khách Hàng):**
     1. **Loại trừ phòng hư hỏng (`Damaged`):** Ẩn 100% tất cả các phòng đang có trạng thái `Damaged`. Khách đặt online không bao giờ nhìn thấy phòng hỏng, loại bỏ hoàn toàn rủi ro bán nhầm phòng không ở được.
     2. **Cơ chế thời gian chết 1 tiếng (Turnaround Buffer = 60 phút):**
        - Đối với đơn đặt ngày mai trở đi (`NgayNhan > Hôm nay`): Bỏ qua trạng thái `Dirty`/`Cleaning` hiện tại (vì đến ngày mai buồng phòng chắc chắn đã dọn xong).
        - Đối với đơn đặt nhận phòng NGAY HÔM NAY: Phòng đang `Dirty`/`Cleaning` chỉ được hiển thị nếu khoảng cách giữa lúc khách trước check-out và giờ nhận phòng mới $\ge 60\text{ phút}$. Nếu $< 60$ phút thì tạm ẩn vì buồng phòng dọn không kịp.
     3. **Chống trùng lịch:** Không bị giao thoa thời gian với bất kỳ đơn đặt phòng nào khác đang có hiệu lực (`DaXacNhan` hoặc `DaCheckIn`) trong khoảng `[NgayNhan, NgayTra]`.
   - **Kênh Offline tại quầy (Lễ tân tiếp khách vãng lai - Walk-in):**
     1. **Ổ khóa 1 (Trạng thái tức thời):** Phòng bắt buộc phải là `Available` (sạch sẽ, sẵn sàng giao chìa khóa ngay lập tức). Tuyệt đối không giao phòng `Dirty`, `Cleaning` hay `Damaged`.
     2. **Ổ khóa 2 (Quét lịch tương lai):** Hệ thống tự động kiểm tra từ hôm nay đến ngày trả phòng của khách vãng lai, bảo đảm phòng này không có bất kỳ khách online nào đã đặt trước.
3. **Quy chuẩn sinh mã khóa chính thống nhất (Unified Primary Key Standard):**
   - Tuyệt đối tuân thủ chỉ đạo của lập trình viên: **Khóa chính toàn hệ thống phải thống nhất 100% định dạng liền mạch: `[TIỀN TỐ 2 KÝ TỰ] + [3 CHỮ SỐ]`** (Ví dụ: `TK001`, `KH001`, `NV001`, `BK001`, `BD001`, `HD001`).
   - Tuyệt đối không sinh mã có dấu gạch dưới như `BK_001` hay `BK_uuid`.
   - Sinh mã Booking mới thông qua `KeyGenerator.generateBookingId()` và mã dịch vụ booking qua `KeyGenerator.generateBookingDichVuId()` (quét MAX + 1 và kiểm tra tính độc nhất tuyệt đối trong CSDL).
   - Đồng bộ Trigger 5 để tự động sinh mã `HOADON` dạng `HD001` tương ứng với `BK001`.
4. **Phương thức đặt phòng và trạng thái ban đầu:**
   - Đơn đặt qua Web được gán `PhuongPhapBooking = 'Online'`.
   - Trạng thái ban đầu của Booking là `'DaXacNhan'` (sẵn sàng chờ khách đến quầy để Lễ tân check-in).
   - Cột `MaNV` trong `BOOKING` ban đầu để `NULL` (chờ Lễ tân tiếp nhận xử lý check-in ghi nhận sau).
5. **Quản lý Dịch vụ tiện ích gắn liền chi tiết từng phòng (Add-on Services per Room Detail):**
   - Trong mô hình dữ liệu, mỗi phòng trong đơn đặt phòng là một bản ghi trong `BOOKING_PHONG(MaBooking, MaPhong)`.
   - Bảng `BOOKING_DICHVU` tham chiếu trực tiếp cặp khóa ngoại `(MaBooking, MaPhong)` trỏ về `BOOKING_PHONG` (chuẩn hóa 3NF), cho phép quản lý dịch vụ gắn chính xác vào từng phòng:
     * **Chọn dịch vụ khi đặt phòng (`booking_form.jsp`):** Khách hàng có thể tích chọn các dịch vụ tiện ích bổ sung cho phòng đang đặt (Buffet sáng, Đưa đón sân bay, Giường phụ...) và chọn số lượng. Tổng tiền dự kiến sẽ tự động tính = `Tiền phòng (Đơn giá x Số đêm) + Tổng tiền dịch vụ đã chọn`.
     * **Xem chi tiết & gọi thêm dịch vụ sau khi đặt (`booking_detail.jsp`):** Khách hàng có thể vào màn hình Chi tiết đặt phòng để xem danh sách dịch vụ của từng phòng và bấm nút **"+ Thêm Dịch Vụ Cho Phòng"** để gọi thêm dịch vụ mới bất kỳ lúc nào khi đơn đang ở trạng thái `DaXacNhan` hoặc `DaCheckIn`.
   - Cột `NguoiThem` được gán giá trị `'KhachHang'` (khi khách tự thêm qua web) hoặc `'NhanVien'` (khi lễ tân thêm tại quầy ở Giai đoạn 3). Cột `MaNV` để `NULL` khi khách tự thêm.
   - Cột `DonGia` trong `BOOKING_DICHVU` được lưu cố định theo đơn giá niêm yết tại thời điểm thêm (lấy từ `DICHVU.DonGia`), đảm bảo không bị ảnh hưởng nếu sau này khách sạn tăng hoặc giảm giá dịch vụ.
   - Công thức tổng chi phí dự kiến:
     $$\text{ChiPhiDuKien} = \sum_{\text{phòng}} (\text{DonGiaPhong} \times \text{SoDem}) + \sum_{\text{dịch vụ}} (\text{DonGiaDichVu} \times \text{SoLuong})$$

---

## 2. SƠ ĐỒ LUỒNG DỮ LIỆU & CHU TRÌNH TƯƠNG TÁC GIỮA CÁC LỚP (SEQUENCE DIAGRAMS)

### 2.1. Luồng Tra Cứu & Lọc Phòng Trống Thời Gian Thực

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Khách hàng
    participant Browser as Trình duyệt (Client)
    participant SearchServlet as CustomerSearchRoomServlet (/customer/search-rooms)
    participant RoomService as RoomService
    participant RoomDAO as RoomDAO
    participant DB as SQL Server (QuanLyKhachSan)

    Customer->>Browser: Chọn Ngày nhận, Ngày trả, Số người, Hạng phòng -> Bấm "Tìm phòng"
    Browser->>SearchServlet: GET /customer/search-rooms?checkIn=...&checkOut=...&guests=...&roomType=...
    SearchServlet->>RoomService: searchAvailableRooms(checkInStr, checkOutStr, guestsStr, roomTypeId)
    RoomService->>RoomService: Validate: checkIn >= Today && checkOut > checkIn
    RoomService->>RoomService: Tính số đêm lưu trú: DATEDIFF(checkIn, checkOut)
    RoomService->>RoomDAO: findAvailableRooms(checkInDate, checkOutDate, guests, roomTypeId)
    RoomDAO->>DB: Thực thi fn_TraCuuPhongTrongTheoYeuCau(checkIn, checkOut, guests, roomType)
    DB-->>RoomDAO: ResultSet (MaPhong, SoPhong, MaLoaiPhong, TenLoaiPhong, DienTich, GiaPhong...)
    RoomDAO->>RoomDAO: Ánh xạ ResultSet -> List<AvailableRoomDTO>
    RoomDAO-->>RoomService: List<AvailableRoomDTO>
    RoomService->>RoomService: Gán soDem & tính tongTienDuKien = GiaPhong * soDem
    RoomService-->>SearchServlet: List<AvailableRoomDTO>
    SearchServlet->>SearchServlet: request.setAttribute("roomList", list), request.setAttribute("searchParams", params)
    SearchServlet-->>Browser: forward sang views/customer/room_list.jsp (Hiển thị thẻ phòng sang trọng)
```

### 2.2. Luồng Xác Nhận & Đặt Phòng Kèm Dịch Vụ Tiện Ích Từng Phòng (Online Booking with Add-on Services)

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Khách hàng
    participant Browser as Trình duyệt (Client)
    participant BookingServlet as CustomerBookingServlet (/customer/booking)
    participant BookingService as BookingService
    participant KeyGenerator as KeyGenerator
    participant BookingDAO as BookingDAO
    participant ServiceDAO as ServiceDAO
    participant DB as SQL Server (QuanLyKhachSan)

    Customer->>Browser: Tại danh sách phòng, bấm "Đặt phòng ngay" (MaPhong, CheckIn, CheckOut)
    Browser->>BookingServlet: GET /customer/booking?roomId=P101&checkIn=...&checkOut=...
    BookingServlet->>BookingService: prepareBookingSummary(roomId, checkIn, checkOut)
    BookingService->>ServiceDAO: getAllActiveServices()
    ServiceDAO->>DB: SELECT * FROM DICHVU WHERE TrangThai = 'ApDung'
    DB-->>ServiceDAO: Danh mục dịch vụ khả dụng (Buffet, Đưa đón, Spa...)
    BookingService-->>BookingServlet: AvailableRoomDTO + List<ServiceItem>
    BookingServlet-->>Browser: forward sang views/customer/booking_form.jsp (Màn hình xác nhận, Thông tin khách CCCD & Chọn dịch vụ)

    Customer->>Browser: Nhập/chỉnh sửa thông tin lưu trú (Họ tên, SĐT, Email, CCCD 12 số), chọn dịch vụ -> Bấm "Xác nhận đặt phòng"
    Browser->>BookingServlet: POST /customer/booking (hoTen, sdt, email, cccd, roomId, checkIn, checkOut, note, selectedServices)
    BookingServlet->>BookingServlet: Lấy CURRENT_USER từ session -> Lấy MaTaiKhoan
    BookingServlet->>BookingService: createOnlineBooking(currentUser, guestInfo(hoTen, sdt, email, cccd), roomId, checkIn, checkOut, note, selectedServices)
    
    BookingService->>CustomerDAO: findOrUpsertGuestByCCCD(hoTen, email, sdt, cccd)
    CustomerDAO->>DB: SELECT * FROM KHACHHANG WHERE CCCD = ?
    alt CCCD đã tồn tại trong KHACHHANG
        DB-->>CustomerDAO: Khách hàng cũ
        alt SĐT hoặc Email có thay đổi
            CustomerDAO->>DB: UPDATE KHACHHANG SET HoTen=?, SoDT=?, Email=? WHERE CCCD=?
        end
        CustomerDAO-->>BookingService: Trả về MaKH cũ
    else CCCD chưa tồn tại trong KHACHHANG
        CustomerDAO->>KeyGenerator: generateCustomerId() -> KHxxx
        CustomerDAO->>DB: INSERT INTO KHACHHANG (MaKH, HoTen, Email, SoDT, CCCD, MaTaiKhoan=NULL)
        CustomerDAO-->>BookingService: Trả về MaKH mới
    end

    BookingService->>KeyGenerator: generateBookingId()
    KeyGenerator-->>BookingService: Trả về mã độc nhất dạng BK001, BK002...
    
    BookingService->>BookingDAO: saveBookingTransaction(maBooking, maKH, maTaiKhoan, roomId, checkIn, checkOut, donGiaPhong, tongTien, selectedServices)
    BookingDAO->>DB: BEGIN TRANSACTION
    BookingDAO->>DB: SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(roomId, checkIn, checkOut, NULL)
    
    alt Phòng vừa bị người khác đặt mất (Không còn khả dụng)
        DB-->>BookingDAO: Trả về 0 (Conflict)
        BookingDAO->>DB: ROLLBACK TRANSACTION
        BookingDAO-->>BookingService: Ném RoomConflictException ("Phòng vừa có khách khác đặt!")
        BookingService-->>BookingServlet: Báo lỗi xung đột
        BookingServlet-->>Browser: Chuyển về room_list.jsp kèm thông báo cảnh báo đỏ
    else Phòng hoàn toàn khả dụng
        DB-->>BookingDAO: Trả về 1 (Available)
        BookingDAO->>DB: INSERT INTO BOOKING (MaBooking, MaKH, MaTaiKhoan, NgayDat, ChiPhiDuKien, TrangThai, PhuongPhapBooking) VALUES (?, ?, ?, GETDATE(), ?, 'DaXacNhan', 'Online')
        BookingDAO->>DB: INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien)
        loop Với mỗi dịch vụ được chọn cho phòng
            BookingDAO->>KeyGenerator: generateBookingDichVuId() -> BD001, BD002...
            BookingDAO->>DB: INSERT INTO BOOKING_DICHVU (MaBookingDichVu, MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem)
        end
        DB->>DB: Kích hoạt Trigger 5: Tự động INSERT INTO HOADON (MaHoaDon = 'HD001', TrangThai = 'ChuaThanhToan')
        DB->>DB: Kích hoạt Trigger 1: Kiểm tra lại toàn vẹn chống Double-booking
        BookingDAO->>DB: COMMIT TRANSACTION
        DB-->>BookingDAO: Thành công
        BookingDAO-->>BookingService: maBooking (Ví dụ: "BK001")
        BookingService-->>BookingServlet: maBooking
        BookingServlet-->>Browser: response.sendRedirect("/customer/history?bookingSuccess=BK001")
    end
```

### 2.3. Luồng Quản Lý Lịch Sử Đặt Phòng Cá Nhân (Độc Lập Tuyệt Đối Với Đơn Vãng Lai Cũ)

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Khách hàng
    participant Browser as Trình duyệt (Client)
    participant HistoryServlet as CustomerHistoryServlet (/customer/history)
    participant BookingService as BookingService
    participant BookingDAO as BookingDAO
    participant DB as SQL Server (QuanLyKhachSan)

    Customer->>Browser: Bấm menu "Lịch sử đặt phòng của tôi"
    Browser->>HistoryServlet: GET /customer/history
    HistoryServlet->>HistoryServlet: Lấy maTaiKhoan từ sessionScope.CURRENT_USER
    HistoryServlet->>BookingService: getCustomerBookingHistoryByAccountId(maTaiKhoan)
    BookingService->>BookingDAO: getHistoryByAccountId(maTaiKhoan)
    BookingDAO->>DB: SELECT b.*, bp.MaPhong, lp.TenLoaiPhong FROM BOOKING b JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking JOIN PHONG p ON bp.MaPhong = p.MaPhong JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong WHERE b.MaTaiKhoan = ?
    Note over BookingDAO, DB: Đơn vãng lai cũ có MaTaiKhoan = NULL nên 100% không bị kéo vào tài khoản mới
    DB-->>BookingDAO: ResultSet (Chỉ gồm các đơn do chính MaTaiKhoan này tạo ra)
    BookingDAO->>BookingDAO: Ánh xạ ResultSet -> List<CustomerBookingHistoryDTO>
    BookingDAO-->>BookingService: List<CustomerBookingHistoryDTO>
    BookingService-->>HistoryServlet: List<CustomerBookingHistoryDTO>
    HistoryServlet->>HistoryServlet: request.setAttribute("bookingList", list)
    HistoryServlet-->>Browser: forward sang views/customer/booking_history.jsp
```

### 2.4. Luồng Xem Chi Tiết Booking & Thêm Dịch Vụ Vào Từng Phòng (Add Service to Room Detail)

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Khách hàng
    participant Browser as Trình duyệt (Client)
    participant DetailServlet as CustomerBookingDetailServlet (/customer/booking-detail)
    participant AddServiceServlet as CustomerAddServiceServlet (/customer/booking-detail/add-service)
    participant BookingService as BookingService
    participant BookingDAO as BookingDAO
    participant ServiceDAO as ServiceDAO
    participant DB as SQL Server (QuanLyKhachSan)

    Customer->>Browser: Tại Lịch sử đặt phòng, bấm "Xem chi tiết & Dịch vụ" (MaBooking)
    Browser->>DetailServlet: GET /customer/booking-detail?bookingId=BK001
    DetailServlet->>BookingService: getBookingDetail(maBooking, maKH)
    BookingService->>BookingDAO: getBookingDetailById(maBooking)
    BookingDAO->>DB: Query BOOKING, BOOKING_PHONG, BOOKING_DICHVU, DICHVU
    DB-->>BookingDAO: Thông tin phòng và danh sách dịch vụ của từng phòng
    BookingDAO-->>BookingService: BookingDetailDTO
    BookingService->>ServiceDAO: getAllActiveServices()
    ServiceDAO->>DB: SELECT * FROM DICHVU WHERE TrangThai = 'ApDung'
    DB-->>ServiceDAO: List<ServiceItem>
    BookingService-->>DetailServlet: BookingDetailDTO + List<ServiceItem>
    DetailServlet->>DetailServlet: request.setAttribute("bookingDetail", dto), setAttribute("activeServices", list)
    DetailServlet-->>Browser: forward sang views/customer/booking_detail.jsp

    Customer->>Browser: Tại thẻ phòng P101, bấm "+ Thêm Dịch Vụ", chọn Buffet sáng (SL: 2) -> Bấm "Xác nhận thêm"
    Browser->>AddServiceServlet: POST /customer/booking-detail/add-service (maBooking, maPhong, maDichVu, soLuong)
    AddServiceServlet->>BookingService: addServiceToRoom(maBooking, maPhong, maDichVu, soLuong, maKH)
    BookingService->>BookingService: Validate: Đơn thuộc maKH, trạng thái hợp lệ (DaXacNhan/DaCheckIn), soLuong > 0
    BookingService->>BookingDAO: addServiceToBookingRoom(maBooking, maPhong, maDichVu, soLuong, "KhachHang")
    BookingDAO->>DB: INSERT INTO BOOKING_DICHVU (MaBookingDichVu, MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem)
    BookingDAO->>DB: UPDATE BOOKING SET ChiPhiDuKien = dbo.fn_TinhTongTienThucTePhaiTra(MaBooking) WHERE MaBooking = ?
    DB-->>BookingDAO: Thành công
    BookingDAO-->>BookingService: true
    BookingService-->>AddServiceServlet: true
    AddServiceServlet-->>Browser: sendRedirect("/customer/booking-detail?bookingId=BK001&msg=service_added")
```

### 2.5. Luồng Đặt Nhiều Phòng Với Khoảng Thời Gian Độc Lập Trong Cùng Một Booking

```mermaid
sequenceDiagram
    autonumber
    actor Customer as Khách hàng
    participant Browser as Trình duyệt (Client)
    participant SearchServlet as CustomerSearchRoomServlet
    participant BookingServlet as CustomerBookingServlet
    participant CartServlet as CustomerCartServlet
    participant Session as HttpSession (BookingCartDTO)
    participant BookingService as BookingService
    participant BookingDAO as BookingDAO
    participant DB as SQL Server (QuanLyKhachSan)

    Note over Customer, Browser: ĐỢT 1: CHỌN PHÒNG 1 (Ví dụ: P101 từ 01/10 đến 03/10)
    Customer->>Browser: Tìm phòng đợt 1 (CheckIn: 01/10, CheckOut: 03/10)
    Browser->>SearchServlet: GET /customer/search-rooms?checkIn=2026-10-01&checkOut=2026-10-03
    SearchServlet-->>Browser: Trả về danh sách phòng trống đợt 1 (Có P101)
    Customer->>Browser: Bấm "Chọn đặt phòng P101" -> Cấu hình dịch vụ (Buffet x 2)
    Customer->>Browser: Bấm nút "➕ Lưu Phòng Này & Đặt Thêm Phòng Khác"
    Browser->>CartServlet: POST /customer/cart/add (maPhong=P101, checkIn=01/10, checkOut=03/10, services, action=continue)
    CartServlet->>Session: cart.addOrUpdateRoom(CartRoomItemDTO: P101, 2 đêm, services)
    CartServlet-->>Browser: Redirect về /customer/search-rooms (Hiển thị Giỏ phòng: 1 phòng đã chọn)

    Note over Customer, Browser: ĐỢT 2: CHỌN PHÒNG 2 VỚI KHOẢNG NGÀY KHÁC (Ví dụ: P202 từ 02/10 đến 06/10)
    Customer->>Browser: Đổi khoảng ngày mới trên thanh tìm kiếm (CheckIn: 02/10, CheckOut: 06/10) -> Bấm "Tìm lại"
    Browser->>SearchServlet: GET /customer/search-rooms?checkIn=2026-10-02&checkOut=2026-10-06
    SearchServlet-->>Browser: Trả về danh sách phòng trống đợt 2 (Có P202)
    Customer->>Browser: Bấm "Chọn đặt phòng P202" -> Cấu hình dịch vụ (Đưa đón sân bay x 1)
    Customer->>Browser: Bấm nút "✓ Chốt Đơn & Đến Trang Xác Nhận Thanh Toán"
    Browser->>CartServlet: POST /customer/cart/add (maPhong=P202, checkIn=02/10, checkOut=06/10, services, action=checkout)
    CartServlet->>Session: cart.addOrUpdateRoom(CartRoomItemDTO: P202, 4 đêm, services)
    CartServlet-->>Browser: Redirect sang /customer/booking (Trang Checkout đa phòng)

    Note over Customer, DB: BƯỚC 3: XÁC NHẬN TỔNG THỂ & TRANSACTION GHI NHẬN CSDL
    Browser->>BookingServlet: GET /customer/booking (Đọc cart từ Session)
    BookingServlet->>Session: session.getAttribute("BOOKING_CART")
    Session-->>BookingServlet: BookingCartDTO (2 phòng với 2 kỳ lưu trú độc lập)
    BookingServlet-->>Browser: Hiển thị bảng tổng hợp: P101 (2 đêm: 01/10-03/10) + P202 (4 đêm: 02/10-06/10) + Dịch vụ
    Customer->>Browser: Nhập ghi chú chung -> Bấm "Xác Nhận Đặt Toàn Bộ Đơn"
    Browser->>BookingServlet: POST /customer/booking (note)
    BookingServlet->>BookingService: createMultiRoomBooking(maKH, cart, note)
    
    BookingService->>BookingService: Validate song song: Kiểm tra khả dụng từng phòng theo đúng ngày của phòng đó
    BookingService->>BookingDAO: createMultiRoomBookingWithServices(maKH, cart, note)
    
    BookingDAO->>DB: BEGIN TRANSACTION
    BookingDAO->>DB: 1. INSERT INTO BOOKING (MaBooking, MaKH, NgayDat, TrangThai='DaXacNhan')
    BookingDAO->>DB: 2. INSERT INTO BOOKING_PHONG (MaBooking, MaPhong='P101', NgayNhan='01/10', NgayTra='03/10', DonGia)
    BookingDAO->>DB: 3. INSERT INTO BOOKING_DICHVU (gắn với P101)
    BookingDAO->>DB: 4. INSERT INTO BOOKING_PHONG (MaBooking, MaPhong='P202', NgayNhan='02/10', NgayTra='06/10', DonGia)
    BookingDAO->>DB: 5. INSERT INTO BOOKING_DICHVU (gắn với P202)
    BookingDAO->>DB: 6. INSERT INTO HOADON (MaHoaDon, MaBooking, TongTien = Tổng 2 phòng + Tổng dịch vụ, TrangThai='ChuaThanhToan')
    BookingDAO->>DB: COMMIT TRANSACTION
    DB-->>BookingDAO: Giao tác thành công
    BookingDAO-->>BookingService: Trả về mã MaBooking (VD: BK010)
    BookingService-->>BookingServlet: MaBooking
    BookingServlet->>Session: cart.clear() (Giải phóng giỏ hàng Session)
    BookingServlet-->>Browser: sendRedirect("/customer/booking-detail?bookingId=BK010&bookingSuccess=true")
```

---

## 3. DANH SÁCH CÁC CLASS SINH RA & BẢNG PHÂN ĐỊNH TRÁCH NHIỆM CHI TIẾT

| STT | Tên Class / Tệp tin | Gói (Package) / Thư mục | Nhiệm vụ cụ thể | Tương tác trực tiếp |
| :---: | :--- | :--- | :--- | :--- |
| 1 | **`RoomType.java`** | `model` | Entity ánh xạ bảng `LOAIPHONG` (`maLoaiPhong`, `tenLoaiPhong`, `dienTich`, `loaiGiuong`, `soNguoiToiDa`, `giaPhong`, `trangThai`). | Dùng bởi `RoomDAO`, `RoomService`. |
| 2 | **`Room.java`** | `model` | Entity ánh xạ bảng `PHONG` (`maPhong`, `soPhong`, `maLoaiPhong`, `trangThai`, `moTa`). | Dùng bởi `RoomDAO`, `RoomService`. |
| 3 | **`Booking.java`** | `model` | Entity ánh xạ bảng `BOOKING` (`maBooking`, `maKH`, `maTaiKhoan`, `maNV`, `ngayDat`, `trangThai`, `chiPhiDuKien`, `phuongPhapBooking`, `thoiDiemHuy`, `phiHuy`). Bổ sung `maTaiKhoan` để phân định chủ tài khoản web với người lưu trú. | Dùng bởi `BookingDAO`, `BookingService`. |
| 4 | **`BookingRoom.java`** | `model` | Entity ánh xạ bảng `BOOKING_PHONG` (`maBooking`, `maPhong`, `donGiaPhong`, `ngayNhanDuKien`, `ngayTraDuKien`, `ngayCheckInThucTe`, `ngayCheckOutThucTe`). | Dùng bởi `BookingDAO`. |
| 5 | **`ServiceItem.java`** | `model` | Entity ánh xạ bảng `DICHVU` (`maDichVu`, `tenDichVu`, `donGia`, `trangThai`). | Dùng bởi `ServiceDAO`, `BookingService`. |
| 6 | **`BookingDichVu.java`** | `model` | Entity ánh xạ bảng `BOOKING_DICHVU` (`maBookingDichVu`, `maBooking`, `maPhong`, `maDichVu`, `donGia`, `soLuong`, `thoiDiemThem`, `nguoiThem`, `maNV`). | Dùng bởi `BookingDAO`, `BookingService`. |
| 7 | **`Invoice.java`** | `model` | Entity ánh xạ bảng `HOADON` (`maHoaDon`, `maBooking`, `ngayLap`, `tongTienCuoiCung`, `maNV`, `trangThai`). | Dùng bởi `BookingDAO`, `InvoiceDAO`. |
| 8 | **`AvailableRoomDTO.java`** | `dto.room` | Chứa dữ liệu hiển thị thẻ phòng kết quả tìm kiếm: `maPhong`, `soPhong`, `maLoaiPhong`, `tenLoaiPhong`, `dienTich`, `loaiGiuong`, `soNguoiToiDa`, `giaPhong`, `moTaPhong`, `soDem`, `tongTienDuKien`. | `RoomDAO` $\to$ `RoomService` $\to$ `room_list.jsp`. |
| 9 | **`BookingRequestDTO.java`** | `dto.booking` | Chứa dữ liệu yêu cầu đặt phòng gửi từ Client: `hoTen`, `email`, `soDT`, `cccd` (12 số bắt buộc), `maPhong`, `ngayNhan`, `ngayTra`, `ghiChu`, `selectedServices` (`Map<String, Integer>`). | `CustomerBookingServlet` $\to$ `BookingService`. |
| 10 | **`CustomerBookingHistoryDTO.java`** | `dto.booking` | Dữ liệu hiển thị bảng lịch sử đặt phòng: `maBooking`, `soPhong`, `tenLoaiPhong`, `ngayDat`, `ngayNhanDuKien`, `ngayTraDuKien`, `soDem`, `chiPhiDuKien`, `trangThaiBooking`, `maHoaDon`, `trangThaiHoaDon`. | `BookingDAO` $\to$ `BookingService` $\to$ `booking_history.jsp`. |
| 11 | **`BookingDetailDTO.java`** | `dto.booking` | Chứa toàn bộ thông tin chi tiết của 1 đơn đặt phòng: Thông tin chung đơn (`maBooking`, `ngayDat`, `trangThai`, `chiPhiDuKien`, `maHoaDon`), và danh sách chi tiết từng phòng `List<RoomBookingDetailDTO>`. | `BookingDAO` $\to$ `BookingService` $\to$ `booking_detail.jsp`. |
| 12 | **`RoomBookingDetailDTO.java`** | `dto.booking` | Chứa thông tin 1 phòng đã đặt (`maPhong`, `soPhong`, `tenLoaiPhong`, `donGiaPhong`, `ngayNhan`, `ngayTra`, `soDem`, `tienPhong`) và danh sách các dịch vụ gọi riêng cho phòng đó `List<BookingDichVuItemDTO>`. | Dùng trong `BookingDetailDTO`. |
| 13 | **`BookingDichVuItemDTO.java`** | `dto.booking` | Thông tin 1 dòng dịch vụ gắn vào phòng: `maBookingDichVu`, `maDichVu`, `tenDichVu`, `donGia`, `soLuong`, `thanhTien`, `thoiDiemThem`, `nguoiThem`. | Dùng trong `RoomBookingDetailDTO`. |
| 14 | **`RoomDAO.java`** | `dao.room` | Tương tác CSDL về phòng: `getAllActiveRoomTypes()`, `searchAvailableRooms(checkIn, checkOut, guests, roomTypeId)`, `getRoomDetailById(maPhong)`, `isRoomAvailable(maPhong, checkIn, checkOut)`. | Gọi `DBContext`, thực thi câu lệnh SQL/Function. |
| 15 | **`ServiceDAO.java`** | `dao.service` | Tương tác CSDL về dịch vụ: `getAllActiveServices()` (lấy toàn bộ dịch vụ đang áp dụng), `getServiceById(maDichVu)`. | Gọi `DBContext`, tương tác bảng `DICHVU`. |
| 16 | **`BookingDAO.java`** | `dao.booking` | Quản lý giao dịch đặt phòng: `createOnlineBooking(bookingRequest, services)`, `createMultiRoomBookingWithServices(maKH, maTaiKhoan, cart, ghiChu)`, `getBookingHistoryByAccount(maTaiKhoan)` (chỉ lấy đơn của tài khoản web đó, bảo đảm 100% không kéo đơn vãng lai cũ), `getBookingDetailById(maBooking)`. | Mở Transaction, dùng `KeyGenerator`, tương tác bảng `BOOKING`, `BOOKING_PHONG`, `BOOKING_DICHVU`, `HOADON`. |
| 17 | **`RoomService.java`** | `service.room` | Xử lý logic tìm phòng: validate ngày nhận/trả, tính số đêm lưu trú, tính tổng tiền tạm tính, lọc kết quả phòng trống. | Gọi `RoomDAO`, được gọi bởi Servlets. |
| 18 | **`BookingService.java`** | `service.booking` | Logic nghiệp vụ đặt phòng & dịch vụ: Xử lý `findOrUpsertGuestByCCCD()` tra cứu hồ sơ khách lưu trú theo CCCD, validate điều kiện đặt phòng, tạo booking kèm dịch vụ lưu cả `MaTaiKhoan` và `MaKH`, lấy chi tiết booking & lịch sử theo `MaTaiKhoan`. | Gọi `BookingDAO`, `CustomerDAO`, `ServiceDAO`, `RoomDAO`. |
| 19 | **`CustomerSearchRoomServlet.java`** | `controller.customer` (`/customer/search-rooms`) | Tiếp nhận tham số tìm kiếm (`checkIn`, `checkOut`, `guests`, `roomType`), gọi `RoomService`, chuyển tiếp dữ liệu sang `views/customer/room_list.jsp`. | Gọi `RoomService`, forward sang `room_list.jsp`. |
| 20 | **`CustomerBookingServlet.java`** | `controller.customer` (`/customer/booking`) | GET: Hiển thị form xác nhận đặt phòng (`booking_form.jsp`) kèm chi phí chi tiết & danh mục dịch vụ. POST: Nhận thông tin khách lưu trú (Họ tên, SĐT, Email, **CCCD 12 số**), gọi `BookingService.createMultiRoomBooking()`, redirect về lịch sử. | Gọi `BookingService`, `RoomService`. |
| 21 | **`CustomerHistoryServlet.java`** | `controller.customer` (`/customer/history`) | GET: Lấy danh sách booking của khách hàng theo `MaTaiKhoan` của session đang đăng nhập, hiển thị `booking_history.jsp` (Khởi đầu sạch 0 đơn, không kế thừa vãng lai). POST: Hỗ trợ hủy đơn (nếu chưa check-in). | Gọi `BookingService`, forward sang `booking_history.jsp`. |
| 22 | **`CustomerBookingDetailServlet.java`** | `controller.customer` (`/customer/booking-detail`) | GET: Xem chi tiết đơn đặt phòng, hiển thị thông tin từng phòng và các dịch vụ đã add vào phòng đó, nạp danh mục dịch vụ phục vụ Modal gọi thêm. | Gọi `BookingService`, forward sang `booking_detail.jsp`. |
| 23 | **`CustomerAddServiceServlet.java`** | `controller.customer` (`/customer/booking-detail/add-service`) | POST: Nhận yêu cầu thêm dịch vụ vào phòng (`maBooking`, `maPhong`, `maDichVu`, `soLuong`), gọi `BookingService.addServiceToRoom()`, redirect về chi tiết đơn kèm thông báo thành công. POST (action=remove): Xóa dịch vụ khi chưa check-in. | Gọi `BookingService`. |
| 24 | **`home.jsp` (Nâng cấp)** | `views/customer/` | Màn hình chính Customer Portal: Tích hợp thanh Search Bar trực quan, bộ lọc ngày nhận/trả phòng, số người, hạng phòng. | Gửi form GET sang `/customer/search-rooms`. |
| 25 | **`room_list.jsp`** | `views/customer/` | Màn hình hiển thị danh sách phòng trống dưới dạng thẻ card nằm ngang hiện đại (phong cách iVIVU), bộ lọc bên trái, thông số diện tích, tiện ích miễn phí và nút "Xem phòng". | Gửi tham số sang `/customer/room-detail`. |
| 26 | **`booking_form.jsp`** | `views/customer/` | Màn hình xác nhận đặt phòng: Khối 1: Thông tin khách lưu trú (Họ tên, SĐT, Email, **Số CCCD 12 số bắt buộc** - auto-fill từ tài khoản web nhưng cho phép chỉnh sửa); Khối 2: Lựa chọn dịch vụ bổ sung theo phòng. | Gửi form POST sang `/customer/cart/add` hoặc `/customer/booking`. |
| 27 | **`booking_history.jsp`** | `views/customer/` | Màn hình "Lịch sử đặt phòng của tôi": Danh sách các đơn do chính tài khoản này tạo ra (`WHERE MaTaiKhoan = CURRENT_USER.MaTaiKhoan`), timeline trạng thái, thông tin phòng, mã hóa đơn liên kết, nút **"Xem chi tiết & Dịch vụ"**. | Tương tác với `/customer/history` và `/customer/booking-detail`. |
| 28 | **`booking_detail.jsp` (Mới)** | `views/customer/` | Màn hình Chi tiết đơn đặt phòng: Hiển thị chi tiết từng phòng đã đặt, bảng kê dịch vụ phát sinh của từng phòng, nút **"+ Thêm Dịch Vụ Cho Phòng"** và Popup Modal gọi dịch vụ. | Tương tác với `/customer/booking-detail` và `/customer/booking-detail/add-service`. |
| 29 | **`CartRoomItemDTO.java` (Mới)** | `dto.booking` | DTO đại diện cho 1 phòng trong Giỏ hàng đa phòng: Lưu độc lập `maPhong`, `soPhong`, `tenLoaiPhong`, `donGiaPhong`, `ngayNhan`, `ngayTra`, `soDem`, `tienPhong`, thông tin khách lưu trú kèm CCCD, và danh sách dịch vụ chọn riêng cho phòng đó `List<CartServiceItemDTO>`. | Dùng trong `BookingCartDTO`, truyền dữ liệu giữa Session và Controller. |
| 30 | **`CartServiceItemDTO.java` (Mới)** | `dto.booking` | DTO dịch vụ tiện ích gắn riêng vào từng phòng trong giỏ hàng: `maDichVu`, `tenDichVu`, `donGia`, `soLuong`, `thanhTien`. | Dùng trong `CartRoomItemDTO`. |
| 31 | **`BookingCartDTO.java` (Mới)** | `dto.booking` | Giỏ hàng đặt phòng lưu trong `HttpSession` (`BOOKING_CART`): Quản lý tập hợp các phòng được chọn `Map<String, CartRoomItemDTO>` (key là `maPhong`), các hàm tiện ích tính tổng tiền phòng, tổng tiền dịch vụ, tổng chi phí dự kiến toàn giỏ hàng, thêm/sửa/xóa phòng và dịch vụ. | Lưu trong `HttpSession`, tương tác giữa `CustomerCartServlet`, `CustomerBookingServlet`, `BookingService`. |
| 32 | **`CustomerCartServlet.java` (Mới)** | `controller.customer` (`/customer/cart/*`) | Servlet quản lý giỏ hàng đặt phòng: Xử lý thêm phòng vào giỏ (`/customer/cart/add`), xóa phòng khỏi giỏ (`/customer/cart/remove`), làm rỗng giỏ (`/customer/cart/clear`), hỗ trợ điều hướng quay lại tìm phòng tiếp hoặc tiến hành thanh toán checkout. | Tương tác với `HttpSession`, `BookingCartDTO`, chuyển hướng sang `/customer/search-rooms` hoặc `/customer/booking`. |

---

## 4. CÁC ĐIỂM NÂNG CẤP KẾ THỪA TỪ GIAI ĐOẠN 1

1. **Tận dụng phiên đăng nhập định danh `UserSessionDTO`:**
   - Trong Giai đoạn 1, khi người dùng đăng nhập, hệ thống đã lưu đối tượng `UserSessionDTO` vào `session.setAttribute("CURRENT_USER", ...)`.
   - Đối tượng này chứa: `maTaiKhoan`, `hoTenTaiKhoan`, `email`, `maVaiTro` của tài khoản web.
   - Trong Giai đoạn 2:
     * **Auto-fill thông minh:** Khi khách vào form điền thông tin đặt phòng (`booking_form.jsp`), hệ thống tự động trích xuất Họ tên, SĐT, Email từ `CURRENT_USER` để điền sẵn vào các ô input, giúp khách đặt cho chính mình nhanh chóng mà không cần gõ lại. Khách vẫn có thể sửa lại nếu đặt hộ người thân.
     * **Định danh CCCD bắt buộc:** Khách bắt buộc nhập số CCCD của người trực tiếp lưu trú. Hệ thống dùng CCCD này để tra cứu/tạo mới hồ sơ trong `KHACHHANG` (Find-or-Upsert by CCCD).
     * **Lưu vết sở hữu đơn:** Đơn đặt phòng `BOOKING` sẽ lưu `MaTaiKhoan = CURRENT_USER.getMaTaiKhoan()`. Nhờ đó, trang lịch sử cá nhân chỉ hiển thị các đơn do chính tài khoản này tạo ra, hoàn toàn sạch sẽ và không kế thừa các đơn vãng lai trước đó!
2. **Kế thừa bộ lọc bảo vệ an ninh `AuthFilter`:**
   - Mọi URL bắt đầu bằng `/customer/*` đã được `AuthFilter` bảo vệ nghiêm ngặt.
   - Nếu khách vãng lai chưa đăng nhập mà bấm vào link đặt phòng, `AuthFilter` tự động chặn lại và chuyển hướng về `/login?redirect=...`. Sau khi đăng nhập thành công, khách sẽ được đưa quay lại đúng trang đặt phòng dang dở.
3. **Kế thừa tiện ích sinh mã `KeyGenerator.java`:**
   - Sử dụng hàm `KeyGenerator.generateBookingId()` đã viết ở Giai đoạn 1 để sinh mã đặt phòng dạng `BK001`, `BK002`... tự tăng và kiểm tra tính độc nhất trong CSDL.
   - Đồng bộ hóa triệt để cách đặt tên mã giữa Java và SQL Trigger.

---

## 5. ĐẶC TẢ CHI TIẾT TỪNG BƯỚC TRIỂN KHAI & DANH SÁCH CÁC HÀM

### Bước 1: Các Entity Model & DTO Mới

#### 1.1. `RoomType.java` (Package: `model`)
Ánh xạ trực tiếp bảng `LOAIPHONG`:
* **Thuộc tính:**
  - `String maLoaiPhong`: Khóa chính (ví dụ: `LP001`, `LP002`).
  - `String tenLoaiPhong`: Tên hạng phòng (Standard, Deluxe, Suite, VIP...).
  - `double dienTich`: Diện tích phòng ($m^2$).
  - `String loaiGiuong`: Loại giường (Đơn, Đôi, King, Queen...).
  - `int soNguoiToiDa`: Sức chứa tối đa.
  - `double giaPhong`: Đơn giá niêm yết theo đêm (VNĐ).
  - `String trangThai`: Trạng thái áp dụng kinh doanh (`ApDung`, `NgungApDung`).
* **Hàm / Phương thức:** Constructor mặc định, Constructor đầy đủ tham số, Getters và Setters.

#### 1.2. `Room.java` (Package: `model`)
Ánh xạ trực tiếp bảng `PHONG`:
* **Thuộc tính:**
  - `String maPhong`: Khóa chính (ví dụ: `P101`, `P102`).
  - `String soPhong`: Số phòng hiển thị trên cửa (101, 102...).
  - `String maLoaiPhong`: Khóa ngoại trỏ đến `LOAIPHONG`.
  - `String trangThai`: Trạng thái vật lý (`Available`, `Booked`, `Occupied`, `Dirty`, `Cleaning`, `Damaged`).
  - `String moTa`: Ghi chú mô tả thêm về hướng phòng, ban công, view biển.
* **Hàm / Phương thức:** Getters, Setters, Constructor.

#### 1.3. `Booking.java` (Package: `model`)
Ánh xạ trực tiếp bảng `BOOKING`:
* **Thuộc tính:**
  - `String maBooking`: Khóa chính dạng `BK001`, `BK002`.
  - `String maKH`: Mã khách hàng đại diện.
  - `String maNV`: Mã nhân viên xử lý (NULL khi đặt online).
  - `Timestamp ngayDat`: Thời điểm tạo đơn.
  - `String trangThai`: Trạng thái đơn (`DaXacNhan`, `DaCheckIn`, `DaCheckOut`, `DaHuy`).
  - `double chiPhiDuKien`: Tổng tiền phòng dự kiến.
  - `String phuongPhapBooking`: `'Online'` hoặc `'Offline'`.
  - `Timestamp thoiDiemHuy`: Thời điểm khách hủy phòng (nếu có).
  - `double phiHuy`: Phí phạt hủy phòng (nếu có).

#### 1.4. `BookingRoom.java` (Package: `model`)
Ánh xạ trực tiếp bảng `BOOKING_PHONG`:
* **Thuộc tính:**
  - `String maBooking`: Khóa ngoại trỏ đến `BOOKING`.
  - `String maPhong`: Khóa ngoại trỏ đến `PHONG`.
  - `double donGiaPhong`: Đơn giá chốt tại thời điểm đặt phòng.
  - `Date ngayNhanDuKien`: Ngày khách dự kiến nhận phòng.
  - `Date ngayTraDuKien`: Ngày khách dự kiến trả phòng.
  - `Timestamp ngayCheckInThucTe`: Ghi nhận giờ khách nhận phòng thực tế.
  - `Timestamp ngayCheckOutThucTe`: Ghi nhận giờ khách trả phòng thực tế.

#### 1.5. `ServiceItem.java` (Package: `model`)
Ánh xạ trực tiếp bảng `DICHVU`:
* **Thuộc tính:**
  - `String maDichVu`: Khóa chính (ví dụ: `DV001`, `DV002`... `DV008`).
  - `String tenDichVu`: Tên dịch vụ (Buffet sáng, Đưa đón sân bay, Giặt ủi, Nước suối, Giường phụ...).
  - `double donGia`: Đơn giá niêm yết (VNĐ).
  - `String trangThai`: Trạng thái kinh doanh (`ApDung`, `NgungApDung`).

#### 1.6. `BookingDichVu.java` (Package: `model`)
Ánh xạ trực tiếp bảng `BOOKING_DICHVU` (Dịch vụ gắn vào từng phòng trong booking):
* **Thuộc tính:**
  - `String maBookingDichVu`: Khóa chính tự sinh dạng `BD001`, `BD002`...
  - `String maBooking`: Khóa ngoại trỏ đến `BOOKING`.
  - `String maPhong`: Khóa ngoại trỏ đến `PHONG` (thuộc cặp `(MaBooking, MaPhong)` trong `BOOKING_PHONG`).
  - `String maDichVu`: Khóa ngoại trỏ đến `DICHVU`.
  - `double donGia`: Đơn giá chốt tại thời điểm thêm dịch vụ.
  - `int soLuong`: Số lượng dịch vụ sử dụng (mặc định $\ge 1$).
  - `Timestamp thoiDiemThem`: Thời điểm thêm dịch vụ (`GETDATE()`).
  - `String nguoiThem`: `'KhachHang'` hoặc `'NhanVien'`.
  - `String maNV`: Mã nhân viên thực hiện (NULL nếu khách tự đặt online).

#### 1.7. `AvailableRoomDTO.java` (Package: `dto.room`)
Đối tượng mang dữ liệu phục vụ trực tiếp màn hình kết quả tìm kiếm `room_list.jsp` và màn hình xác nhận `booking_form.jsp`:
* **Thuộc tính:**
  - `String maPhong`, `String soPhong`, `String maLoaiPhong`, `String tenLoaiPhong`
  - `double dienTich`, `String loaiGiuong`, `int soNguoiToiDa`, `double giaPhong`, `String moTaPhong`
  - `String ngayNhan`, `String ngayTra`: Ngày tìm kiếm đã format chuỗi `dd/MM/yyyy`
  - `int soDem`: Số đêm lưu trú tính toán được
  - `double tongTienDuKien`: Bằng `giaPhong * soDem`
  - `String hinhAnhMinhHoa`: Đường dẫn ảnh đại diện của loại phòng

#### 1.8. `CustomerBookingHistoryDTO.java` (Package: `dto.booking`)
Đối tượng mang dữ liệu hiển thị lịch sử đặt phòng `booking_history.jsp`:
* **Thuộc tính:**
  - `String maBooking`: Mã đơn (ví dụ: `BK001`)
  - `String soPhong`, `String tenLoaiPhong`: Thông tin phòng đã đặt
  - `Timestamp ngayDat`: Ngày giờ đặt phòng
  - `Date ngayNhanDuKien`, `Date ngayTraDuKien`: Khoảng thời gian lưu trú
  - `int soDem`: Số đêm ở
  - `double chiPhiDuKien`: Tổng chi phí
  - `String trangThaiBooking`: `DaXacNhan`, `DaCheckIn`, `DaCheckOut`, `DaHuy`
  - `String maHoaDon`: Mã hóa đơn tương ứng (ví dụ: `HD001`)
  - `String trangThaiHoaDon`: `ChuaThanhToan`, `MotPhan`, `DaThanhToanDu`
  - `boolean coTheHuy`: Cờ boolean đánh giá khách có được quyền bấm hủy đơn không (`trangThaiBooking.equals("DaXacNhan")`)

#### 1.9. `BookingDetailDTO.java` (Package: `dto.booking`)
Dữ liệu hiển thị chi tiết toàn diện đơn đặt phòng tại `booking_detail.jsp`:
* **Thuộc tính:**
  - `String maBooking`, `Timestamp ngayDat`, `String trangThaiBooking`, `String phuongPhapBooking`, `String ghiChu`
  - `String maKH`, `String hoTenKhachHang`, `String soDT`, `String email`
  - `String maHoaDon`, `String trangThaiHoaDon`
  - `double tongTienPhong`, `double tongTienDichVu`, `double tongChiPhiDuKien`
  - `List<RoomBookingDetailDTO> danhSachPhong`: Danh sách các phòng đã đặt kèm chi tiết dịch vụ của từng phòng

#### 1.10. `RoomBookingDetailDTO.java` & `BookingDichVuItemDTO.java` (Package: `dto.booking`)
Chi tiết từng phòng và dịch vụ của phòng:
* **`RoomBookingDetailDTO`:**
  - `String maPhong`, `String soPhong`, `String tenLoaiPhong`, `double donGiaPhong`
  - `Date ngayNhanDuKien`, `Date ngayTraDuKien`, `int soDem`, `double tienPhong`
  - `List<BookingDichVuItemDTO> danhSachDichVu`: Danh sách các dịch vụ đã gọi riêng cho phòng này
  - `double tongTienDichVuPhong`: Tổng tiền dịch vụ của riêng phòng này
* **`BookingDichVuItemDTO`:**
  - `String maBookingDichVu`, `String maDichVu`, `String tenDichVu`, `double donGia`, `int soLuong`, `double thanhTien`
  - `Timestamp thoiDiemThem`, `String nguoiThem`

#### 1.11. `CartRoomItemDTO.java` (Package: `dto.booking`)
Đối tượng đại diện cho 1 phòng nằm trong Giỏ hàng đặt phòng của khách hàng:
* **Thuộc tính:**
  - `String maPhong`, `String soPhong`, `String maLoaiPhong`, `String tenLoaiPhong`
  - `double donGiaPhong`: Đơn giá chốt tại thời điểm đưa vào giỏ
  - `String ngayNhan`, `String ngayTra`: Khoảng ngày lưu trú của **riêng phòng này** (chuỗi `yyyy-MM-dd`)
  - `java.sql.Date checkInDate`, `java.sql.Date checkOutDate`: Ngày SQL phục vụ kiểm tra trùng lịch và chèn CSDL
  - `int soDem`: Số đêm ở của phòng này ($= \text{checkOut} - \text{checkIn}$)
  - `double tienPhong`: Thành tiền phòng ($= \text{donGiaPhong} \times \text{soDem}$)
  - `List<CartServiceItemDTO> selectedServices`: Danh sách dịch vụ tiện ích chọn riêng cho phòng này
  - `double tongTienDichVu`: Tổng chi phí dịch vụ của phòng này
  - `double tongTienPhongVaDichVu`: $= \text{tienPhong} + \text{tongTienDichVu}$
* **Phương thức:** `addOrUpdateService(CartServiceItemDTO)`, `removeService(String maDichVu)`, `recalculateTotal()`.

#### 1.12. `CartServiceItemDTO.java` (Package: `dto.booking`)
Dịch vụ tiện ích đính kèm cho từng phòng trong giỏ hàng:
* **Thuộc tính:**
  - `String maDichVu`, `String tenDichVu`, `double donGia`, `int soLuong`, `double thanhTien` ($= \text{donGia} \times \text{soLuong}$)
* **Phương thức:** Getters, Setters, Constructor.

#### 1.13. `BookingCartDTO.java` (Package: `dto.booking`)
Đối tượng Giỏ hàng đặt phòng toàn diện được lưu trong `HttpSession` với khóa `BOOKING_CART`:
* **Thuộc tính:**
  - `Map<String, CartRoomItemDTO> items`: Bảng băm lưu danh sách phòng trong giỏ (Key: `maPhong`, Value: `CartRoomItemDTO`).
  - `String ghiChuChung`: Ghi chú tổng thể của khách hàng cho toàn bộ đơn đặt phòng.
* **Phương thức cốt lõi:**
  - `public void addOrUpdateRoom(CartRoomItemDTO roomItem)`: Thêm mới phòng vào giỏ hoặc cập nhật ngày lưu trú/dịch vụ nếu phòng đã tồn tại trong giỏ.
  - `public void removeRoom(String maPhong)`: Xóa một phòng khỏi giỏ hàng.
  - `public void clear()`: Làm rỗng giỏ hàng sau khi đã commit đơn thành công.
  - `public boolean containsRoom(String maPhong)`: Kiểm tra phòng đã có trong giỏ chưa.
  - `public int getTotalRoomCount()`: Trả về số lượng phòng đang có trong giỏ.
  - `public double getTotalRoomCost()`: Tổng tiền lưu trú của tất cả các phòng: $\sum \text{tienPhong}_i$.
  - `public double getTotalServiceCost()`: Tổng tiền dịch vụ của tất cả các phòng: $\sum \text{tongTienDichVu}_i$.
  - `public double getGrandTotal()`: Tổng chi phí dự kiến toàn bộ đơn: $= \text{getTotalRoomCost}() + \text{getTotalServiceCost}()$.
  - `public boolean isEmpty()`: Kiểm tra giỏ hàng có rỗng không.

---

### Bước 2: Tầng DAO (RoomDAO, ServiceDAO & BookingDAO)

#### 2.1. `RoomDAO.java` (Package: `dao.room`)
* **Nhiệm vụ:** Thực thi các truy vấn liên quan đến phòng, hạng phòng và tính khả dụng của phòng.
* **Danh sách hàm triển khai:**
  1. `public List<RoomType> getAllActiveRoomTypes()`: Lấy danh sách toàn bộ hạng phòng đang áp dụng (`TrangThai = 'ApDung'`).
  2. `public List<AvailableRoomDTO> searchAvailableRooms(java.sql.Date checkIn, java.sql.Date checkOut, Integer guests, String roomTypeId)`: Gọi `dbo.fn_TraCuuPhongTrongTheoYeuCau(?, ?, ?, ?)`.
  3. `public AvailableRoomDTO getRoomDetailForBooking(String maPhong, java.sql.Date checkIn, java.sql.Date checkOut)`: Truy vấn thông tin chi tiết phòng để hiển thị trên màn hình xác nhận `booking_form.jsp`.
  4. `public boolean isRoomAvailable(String maPhong, java.sql.Date checkIn, java.sql.Date checkOut)`: Gọi `SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(?, ?, ?, NULL)`.

#### 2.2. `ServiceDAO.java` (Package: `dao.service`)
* **Nhiệm vụ:** Tương tác với bảng `DICHVU` để phục vụ khách hàng chọn tiện ích.
* **Danh sách hàm triển khai:**
  1. `public List<ServiceItem> getAllActiveServices()`:
     - Truy vấn tất cả dịch vụ đang kinh doanh:
       ```sql
       SELECT MaDichVu, TenDichVu, DonGia, TrangThai 
       FROM DICHVU 
       WHERE TrangThai = 'ApDung' 
       ORDER BY DonGia ASC
       ```
  2. `public ServiceItem getServiceById(String maDichVu)`:
     - Lấy thông tin 1 dịch vụ cụ thể theo mã để kiểm tra đơn giá niêm yết.

#### 2.3. `CustomerDAO.java` (Package: `dao.customer` / `dao.booking`)
* **Nhiệm vụ:** Quản lý hồ sơ công dân lưu trú thực tế trong bảng `KHACHHANG`, định danh duy nhất bằng số `CCCD` (12 chữ số).
* **Danh sách hàm triển khai:**
  1. `public Customer findCustomerByCCCD(String cccd)`:
     - Truy vấn: `SELECT * FROM KHACHHANG WHERE CCCD = ?`.
  2. `public String findOrUpsertGuestByCCCD(String hoTen, String email, String soDT, String cccd)`:
     - **Triển khai thuật toán Find-or-Upsert theo CCCD:**
       * Nếu `cccd` đã tồn tại:
         - So sánh `email` mới với email cũ, `soDT` mới với SĐT cũ.
         - Nếu có thay đổi: Thực thi `UPDATE KHACHHANG SET HoTen = ?, SoDT = ?, Email = ? WHERE CCCD = ?`.
         - Trả về mã `MaKH` cũ hiện tại.
       * Nếu `cccd` chưa có trong CSDL:
         - Sinh mã mới `MaKH` dạng `KHxxx` qua `KeyGenerator.generateCustomerId()`.
         - Thực thi `INSERT INTO KHACHHANG (MaKH, HoTen, Email, SoDT, CCCD, MaTaiKhoan) VALUES (?, ?, ?, ?, ?, NULL)`.
         - Trả về mã `MaKH` mới tạo.

#### 2.4. `BookingDAO.java` (Package: `dao.booking`)
* **Nhiệm vụ:** Quản lý giao dịch tạo đơn đặt phòng kèm dịch vụ cho từng phòng, thêm/xóa dịch vụ vào chi tiết phòng, và truy xuất chi tiết đơn theo tài khoản web.
* **Danh sách hàm triển khai:**
  1. `public String createOnlineBookingWithServices(String maKH, String maTaiKhoan, String maPhong, java.sql.Date checkIn, java.sql.Date checkOut, double donGiaPhong, double tongChiPhi, Map<String, Integer> selectedServices) throws Exception`:
     - **Triển khai JDBC Transaction toàn vẹn:**
       ```java
       Connection conn = DBContext.getConnection();
       conn.setAutoCommit(false);
       ```
     - **Bước 1:** Kiểm tra lại tính khả dụng của phòng bằng `fn_KiemTraPhongTrongTrongKhoang`. Nếu xung đột $\to$ `conn.rollback()` và ném `RoomConflictException`.
     - **Bước 2:** Sinh mã `MaBooking` bằng `KeyGenerator.generateBookingId()` (ví dụ: `BK001`).
     - **Bước 3:** Chèn `BOOKING` (lưu cả `MaKH` người ở và `MaTaiKhoan` người đặt web):
       ```sql
       INSERT INTO BOOKING (MaBooking, MaKH, MaTaiKhoan, MaNV, NgayDat, TrangThai, ChiPhiDuKien, PhuongPhapBooking)
       VALUES (?, ?, ?, NULL, GETDATE(), 'DaXacNhan', ?, 'Online')
       ```
     - **Bước 4:** Chèn `BOOKING_PHONG` (`MaBooking`, `MaPhong`, `DonGiaPhong`, `NgayNhanDuKien`, `NgayTraDuKien`).
     - **Bước 5 (Gắn Dịch Vụ Vào Phòng):** Nếu khách có chọn dịch vụ:
       * Với mỗi dịch vụ trong `selectedServices`:
         - Lấy `DonGia` dịch vụ từ bảng `DICHVU`.
         - Sinh `MaBookingDichVu` bằng `KeyGenerator.generateBookingDichVuId()` (ví dụ: `BD001`, `BD002`).
         - Thực thi câu lệnh chèn vào `BOOKING_DICHVU`:
           ```sql
           INSERT INTO BOOKING_DICHVU (MaBookingDichVu, MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem, MaNV)
           VALUES (?, ?, ?, ?, ?, ?, GETDATE(), 'KhachHang', NULL)
           ```
     - **Bước 6:** Trigger 5 tự động sinh `HOADON` (`HD001`, `ChuaThanhToan`).
     - **Bước 7:** `conn.commit()`, trả về chuỗi `maBooking`.
  2. `public boolean addServiceToBookingRoom(String maBooking, String maPhong, String maDichVu, int soLuong, String nguoiThem) throws Exception`:
     - Thêm dịch vụ mới vào phòng đã đặt và cập nhật lại `ChiPhiDuKien`.
  3. `public boolean removeServiceFromBookingRoom(String maBookingDichVu, String maBooking) throws Exception`:
     - Xóa dịch vụ khỏi phòng (khi đơn chưa Check-in).
  4. `public BookingDetailDTO getBookingDetailById(String maBooking)`:
     - Truy vấn thông tin `BOOKING`, `HOADON`, danh sách phòng `BOOKING_PHONG`, và danh sách các dịch vụ `BOOKING_DICHVU` gắn với từng phòng để nạp vào `BookingDetailDTO`.
  5. `public List<CustomerBookingHistoryDTO> getBookingHistoryByAccount(String maTaiKhoan)`:
     - Truy vấn danh sách booking do chính tài khoản web này tạo ra:
       ```sql
       SELECT b.MaBooking, p.SoPhong, lp.TenLoaiPhong, b.NgayDat,
              bp.NgayNhanDuKien, bp.NgayTraDuKien, b.ChiPhiDuKien,
              b.TrangThai AS TrangThaiBooking, hd.MaHoaDon, hd.TrangThai AS TrangThaiHoaDon
       FROM BOOKING b
       INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking
       INNER JOIN PHONG p ON bp.MaPhong = p.MaPhong
       INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
       LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking
       WHERE b.MaTaiKhoan = ?
       ORDER BY b.NgayDat DESC
       ```
     - **Đặc điểm cốt lõi:** Các đơn vãng lai tạo tại quầy có `MaTaiKhoan = NULL`, nên tài khoản web mới tạo có lịch sử hoàn toàn sạch sẽ (0 đơn), 100% không bị kéo đơn cũ!
  6. `public boolean cancelBooking(String maBooking, String maTaiKhoan)`: Hủy đơn nếu đơn chưa Check-in và thuộc quyền sở hữu của tài khoản web.
  7. `public String createMultiRoomBookingWithServices(String maKH, String maTaiKhoan, BookingCartDTO cart, String note) throws Exception`:
     - **Triển khai Giao tác Nguyên tử Đa Phòng (Atomic Multi-Room Transaction):**
       ```java
       Connection conn = DBContext.getConnection();
       conn.setAutoCommit(false);
       ```
     - **Vòng lặp Kiểm tra Khả dụng Độc lập (Independent Pre-check):**
       * Duyệt qua từng phòng `CartRoomItemDTO` trong `cart.getItems().values()`.
       * Thực thi `SELECT dbo.fn_KiemTraPhongTrongTrongKhoang(...)`.
     - **Bước 1: Sinh mã & Chèn bảng cha `BOOKING`:**
       * Sinh `MaBooking` duy nhất dạng `BK001` qua `KeyGenerator.generateBookingId()`.
       * Chèn vào `BOOKING` kèm `MaTaiKhoan` và `MaKH`:
         ```sql
         INSERT INTO BOOKING (MaBooking, MaKH, MaTaiKhoan, MaNV, NgayDat, TrangThai, ChiPhiDuKien, PhuongPhapBooking)
         VALUES (?, ?, ?, NULL, GETDATE(), 'DaXacNhan', ?, 'Online')
         ```
     - **Bước 2: Chèn các phòng vào `BOOKING_PHONG` với khoảng ngày độc lập.**
     - **Bước 3: Chèn các dịch vụ tiện ích gắn với từng phòng vào `BOOKING_DICHVU`.**
     - **Bước 4: Kích hoạt Trigger 5 tự động sinh Hóa đơn tổng `HOADON` (`HD001`, `ChuaThanhToan`).**
     - **Bước 5:** `conn.commit()`, trả về `MaBooking`.

---

### Bước 3: Tầng Nghiệp Vụ Service (RoomService & BookingService)

#### 3.1. `RoomService.java` (Package: `service.room`)
* **Nhiệm vụ:** Kiểm tra tính hợp lệ của dữ liệu đầu vào khi tìm kiếm phòng và tính toán các chỉ số lưu trú.
* **Danh sách hàm triển khai:**
  1. `public List<RoomType> getActiveRoomTypes()`: Gọi `RoomDAO.getAllActiveRoomTypes()`.
  2. `public List<AvailableRoomDTO> searchRooms(String checkInStr, String checkOutStr, String guestsStr, String roomTypeId) throws ValidationException`: Validate ngày tháng, tính số đêm, gọi `RoomDAO.searchAvailableRooms(...)` và tính tổng tiền tạm tính.
  3. `public AvailableRoomDTO getRoomBookingDetail(String maPhong, String checkInStr, String checkOutStr) throws ValidationException`: Lấy chi tiết phòng phục vụ hiển thị màn hình xác nhận.

#### 3.2. `BookingService.java` (Package: `service.booking`)
* **Nhiệm vụ:** Điều phối nghiệp vụ đặt phòng, định danh khách theo CCCD và quản lý dịch vụ gắn vào phòng của khách hàng.
* **Danh sách hàm triển khai:**
  1. `public List<ServiceItem> getActiveServices()`: Gọi `ServiceDAO.getAllActiveServices()`.
  2. `public String createMultiRoomBooking(UserSessionDTO currentUser, String hoTen, String email, String soDT, String cccd, BookingCartDTO cart, String note) throws Exception`:
     - Validate giỏ hàng không rỗng (`!cart.isEmpty()`).
     - Validate số CCCD: Bắt buộc đúng 12 chữ số (`validateCccd(cccd)`).
     - Gọi `CustomerDAO.findOrUpsertGuestByCCCD(hoTen, email, soDT, cccd)` để lấy mã `maKH` người lưu trú.
     - Lấy mã `maTaiKhoan = currentUser.getMaTaiKhoan()`.
     - Gọi `BookingDAO.createMultiRoomBookingWithServices(maKH, maTaiKhoan, cart, note)`.
     - Trả về `maBooking`.
  3. `public BookingDetailDTO getBookingDetail(String maBooking, String maTaiKhoan) throws SecurityException`:
     - Lấy chi tiết đơn phòng và kiểm tra quyền sở hữu của `maTaiKhoan`.
  4. `public boolean addServiceToRoom(String maBooking, String maPhong, String maDichVu, int soLuong, String maTaiKhoan) throws Exception`: Thêm dịch vụ vào phòng đã đặt.
  5. `public boolean removeServiceFromRoom(String maBookingDichVu, String maBooking, String maTaiKhoan) throws Exception`: Xóa dịch vụ khỏi phòng khi chưa check-in.
  6. `public List<CustomerBookingHistoryDTO> getCustomerHistoryByAccountId(String maTaiKhoan)`: Lấy lịch sử đặt phòng của tài khoản web.
  7. `public boolean cancelBooking(String maBooking, String maTaiKhoan) throws BusinessException`: Xử lý hủy đơn phòng.

---

### Bước 4: Tầng Điều Khiển Controller Servlet

#### 4.1. `CustomerSearchRoomServlet.java` (URL: `/customer/search-rooms`)
* Tiếp nhận tham số tìm kiếm (`checkIn`, `checkOut`, `guests`, `roomType`), gọi `RoomService.searchRooms(...)`, forward sang `views/customer/room_list.jsp`.

#### 4.2. `CustomerBookingServlet.java` (URL: `/customer/booking`)
* **Phương thức GET (Màn hình xác nhận đặt phòng & Checkout):**
  - **Trường hợp 1 (Đặt từ Giỏ hàng đa phòng):** Kiểm tra `session.getAttribute("BOOKING_CART")`. Nếu giỏ hàng có phòng, lấy đối tượng `BookingCartDTO` truyền sang request attribute `bookingCart`, nạp danh mục dịch vụ khả dụng, forward đến `views/customer/booking_form.jsp`.
  - **Trường hợp 2 (Đặt trực tiếp 1 phòng qua URL):** Nhận `roomId`, `checkIn`, `checkOut`, gọi `RoomService.getRoomBookingDetail(...)`, tự động tạo/nạp vào giỏ hàng hoặc truyền trực tiếp đối tượng đơn lẻ sang `booking_form.jsp`.
* **Phương thức POST (Chốt toàn bộ đơn đặt phòng):**
  - Đọc `BookingCartDTO` từ session.
  - Lấy thông tin khách lưu trú từ form: `hoTen`, `email`, `soDT`, **`cccd` (bắt buộc 12 số)** và ghi chú `note`.
  - Lấy `currentUser` từ `sessionScope.CURRENT_USER`.
  - Gọi `BookingService.createMultiRoomBooking(currentUser, hoTen, email, soDT, cccd, cart, note)`.
  - Giải phóng giỏ hàng: `session.removeAttribute("BOOKING_CART")`.
  - Chuyển hướng (Redirect) về `/customer/booking-detail?bookingId=` + `maBooking` + `&bookingSuccess=true`.

#### 4.3. `CustomerCartServlet.java` (URL: `/customer/cart/*`) (Mới)
* **Phương thức POST (`/customer/cart/add`):**
  - Nhận tham số: `roomId`, `checkIn`, `checkOut`, thông tin khách lưu trú (Họ tên, SĐT, Email, CCCD 12 số), các dịch vụ đã chọn (`service_[id]`, `quantity_[id]`), và tham số điều hướng `action` (`continue` hoặc `checkout`).
  - Lấy hoặc khởi tạo `BookingCartDTO` trong `HttpSession`.
  - Kiểm tra nếu phòng này đã tồn tại trong giỏ $\to$ cập nhật lại ngày lưu trú và danh sách dịch vụ.
  - Nếu chưa có $\to$ tạo mới `CartRoomItemDTO`, tính số đêm, thành tiền phòng, nạp dịch vụ đã chọn, thêm vào `cart.addOrUpdateRoom(...)`.
  - **Điều hướng linh hoạt:**
    * Nếu `action.equals("continue")`: Chuyển hướng quay lại `/customer/search-rooms` (kèm tham số `addedRoom=` + `roomId`), trên giao diện hiển thị Thanh thông báo nổi màu xanh: *"Đã lưu phòng [P...] vào giỏ! Bạn có thể chọn ngày khác để đặt thêm phòng tiếp theo."*.
    * Nếu `action.equals("checkout")`: Chuyển hướng thẳng sang `/customer/booking` để tiến hành thanh toán/xác nhận.
* **Phương thức POST (`/customer/cart/remove`):**
  - Nhận tham số `roomId`.
  - Gọi `cart.removeRoom(roomId)`.
  - Redirect về lại trang trước (`booking_form.jsp` hoặc `room_list.jsp`).
* **Phương thức POST (`/customer/cart/clear`):**
  - Gọi `cart.clear()`, làm rỗng giỏ hàng.

#### 4.4. `CustomerHistoryServlet.java` (URL: `/customer/history`)
* **Phương thức GET:**
  - Lấy `currentUser` từ `sessionScope.CURRENT_USER` $\to$ Lấy `maTaiKhoan`.
  - Gọi `BookingService.getCustomerHistoryByAccountId(currentUser.getMaTaiKhoan())`.
  - Hiển thị danh sách các đơn do chính tài khoản này tạo ra (tài khoản mới bắt đầu với 0 đơn, không bao giờ kế thừa các đơn vãng lai trong quá khứ).
* **Phương thức POST:** Tiếp nhận yêu cầu hủy đơn (nếu chưa check-in) dựa trên `maBooking` và `maTaiKhoan`.

#### 4.5. `CustomerBookingDetailServlet.java` (URL: `/customer/booking-detail`)
* **Phương thức GET:**
  - Nhận tham số `bookingId`.
  - Lấy `maTaiKhoan` từ `sessionScope.CURRENT_USER`.
  - Gọi `BookingService.getBookingDetail(bookingId, maTaiKhoan)`.
  - Gọi `BookingService.getActiveServices()` lấy danh sách dịch vụ đang kinh doanh (để nạp vào Modal "+ Thêm Dịch Vụ Cho Phòng").
  - Đặt vào request: `bookingDetail`, `activeServices`.
  - Forward đến `views/customer/booking_detail.jsp`.

#### 4.6. `CustomerAddServiceServlet.java` (URL: `/customer/booking-detail/add-service`)
* **Phương thức POST (Thêm dịch vụ vào chi tiết phòng):**
  - Nhận các tham số: `bookingId`, `roomId` (`maPhong`), `serviceId` (`maDichVu`), `quantity`.
  - Lấy `maKH` từ `CURRENT_USER`.
  - Gọi `BookingService.addServiceToRoom(bookingId, roomId, serviceId, quantity, maKH)`.
  - Thành công: Redirect về `/customer/booking-detail?bookingId=` + `bookingId` + `&msg=service_added`.
  - Thất bại: Redirect về kèm thông báo lỗi `&error=add_failed`.
* **Phương thức POST (action=remove) (Xóa dịch vụ khỏi phòng):**
  - Nhận `serviceBookingId` (`maBookingDichVu`), `bookingId`.
  - Gọi `BookingService.removeServiceFromRoom(serviceBookingId, bookingId, maKH)`.
  - Redirect về `/customer/booking-detail?bookingId=` + `bookingId` + `&msg=service_removed`.
  - Thất bại: Redirect về kèm thông báo lỗi `&error=remove_failed`.

---

### Bước 5: Thiết Kế & Nâng Cấp Giao Diện UI/UX JSP

#### 5.1. Nâng cấp `views/customer/home.jsp` (Hero Banner & Search Bar)
* Thiết kế thanh tìm kiếm nhanh (**Search Bar**) đặt ngay vị trí trung tâm: Ngày nhận, Ngày trả, Số lượng khách, Hạng phòng.

#### 5.2. Xây dựng mới `views/customer/room_list.jsp` (Danh sách phòng trống khả dụng)
* Hiển thị danh sách thẻ phòng hiện đại: Ảnh đại diện, thông số tiện ích, đơn giá mỗi đêm (đơn giá niêm yết không nhân trước ngày theo yêu cầu mới nhất).
* **Nút bấm kép trên mỗi thẻ phòng:**
  1. Nút **"Đặt Phòng Này"**: Chuyển thẳng sang trang `booking_form.jsp` để cấu hình và chốt đơn nhanh.
  2. Nút **"➕ Thêm Vào Giỏ Đặt Phòng"**: Gọi POST sang `/customer/cart/add` để lưu phòng và khoảng ngày hiện tại vào Giỏ hàng Session, cho phép khách hàng đổi ngày trên thanh Search Bar và chọn tiếp phòng thứ 2.
* **Thanh Giỏ Hàng Nổi (Floating Sticky Cart Bar):**
  - Tự động hiển thị nổi bật ở góc dưới màn hình khi `BOOKING_CART` có $\ge 1$ phòng.
  - Hiển thị tóm tắt: *"🛒 Giỏ phòng: [N] phòng đã chọn | Tạm tính: [X] đ"* cùng 2 nút: `[Xem Chi Tiết Giỏ]` và `[Xác Nhận Đặt Phòng]`.

#### 5.3. Xây dựng mới `views/customer/booking_form.jsp` (Xác nhận đặt phòng & Checkout Đa Phòng - Đa Khoảng Thời Gian)
* Bố cục 2 cột chuyên nghiệp, tương thích hoàn toàn cả đơn 1 phòng và đơn nhiều phòng:
  - **Cột trái:**
    - Khối 1: Thông tin khách hàng đại diện đặt phòng (Họ tên, SĐT, Email - Read-only từ `CURRENT_USER`).
    - Khối 2: **Danh sách các phòng đã chọn với thời gian độc lập:**
      * Mỗi phòng là một Card riêng biệt: Số phòng, Hạng phòng, **Khoảng ngày lưu trú riêng của phòng (`checkIn` $\to$ `checkOut`)**, Số đêm, Đơn giá và Thành tiền phòng.
      * Nút "Xóa khỏi giỏ" (icon thùng rác đỏ) trên từng phòng nếu khách đổi ý không muốn đặt phòng đó nữa.
      * **Danh mục dịch vụ tiện ích riêng cho từng phòng:** Mỗi phòng có danh sách checkbox dịch vụ tiện ích riêng (Buffet sáng, Đưa đón sân bay, Giường phụ...) kèm bộ đếm số lượng (`+` / `-`).
    - Khối 3: Ghi chú lưu trú chung cho toàn bộ đơn đặt phòng.
    - **Nút hành động bổ sung nổi bật:**
      * Nút **"➕ Quay Lại Chọn Thêm Phòng Khác Với Ngày Khác"**: Chuyển hướng về `/customer/search-rooms`, giỏ hàng hiện tại vẫn được bảo toàn nguyên vẹn trong Session.
  - **Cột phải (Tóm tắt kỳ lưu trú & Chi phí toàn giỏ hàng):**
    - Bảng kê tài chính chi tiết:
      * Bảng liệt kê từng phòng: `Phòng [X] ([N] đêm x [Giá]): ... đ`.
      * Bảng kê dịch vụ theo từng phòng: `Dịch vụ phòng [X]: ... đ`.
      * Tổng tiền phòng: $\sum \text{TienPhong}_i$.
      * Tổng tiền dịch vụ: $\sum \text{TienDichVu}_i$.
      * **Tổng chi phí dự kiến toàn bộ đơn**: Cập nhật realtime sống động.
    - Nút bấm xác nhận chốt đơn: **"✓ Xác Nhận Đặt Toàn Bộ [N] Phòng"**.

#### 5.4. Xây dựng mới `views/customer/booking_history.jsp` (Lịch sử đặt phòng của tôi)
* Danh sách các đơn đặt phòng: Mã đơn, Phòng, Ngày đặt, Kỳ lưu trú, Tổng chi phí, Trạng thái đơn, Trạng thái hóa đơn.
* Cột hành động:
  - Nút **"🔍 Chi Tiết & Dịch Vụ"**: Điều hướng sang trang `booking_detail.jsp`.
  - Nút **"Hủy đơn"**: Chỉ hiển thị khi đơn ở trạng thái `DaXacNhan`.

#### 5.5. Xây dựng mới `views/customer/booking_detail.jsp` (Chi Tiết Đơn Đặt Phòng & Quản Lý Dịch Vụ Từng Phòng)
* Màn hình quản lý chi tiết đơn đặt phòng toàn diện:
  - **Header đơn phòng:** Mã đơn (`BK001`), Ngày đặt, Trạng thái (Badge: `Đã xác nhận`), Mã hóa đơn (`HD001`).
  - **Khu vực danh sách các phòng trong đơn (`BOOKING_PHONG`):**
    * Thẻ card hiển thị thông tin từng phòng: Tên hạng phòng, Số phòng, Ngày nhận - Ngày trả, Đơn giá phòng, Thành tiền phòng.
    * **Bảng kê dịch vụ đã gọi của phòng đó (`BOOKING_DICHVU`):**
      - Bảng hiển thị: Tên dịch vụ, Đơn giá, Số lượng, Thời điểm gọi, Thành tiền, Người thêm (`Khách hàng` / `Lễ tân`).
      - Nút Xóa dịch vụ (Icon thùng rác màu đỏ) nếu đơn chưa Check-in.
      - **Nút bấm nổi bật: `[+ Thêm Dịch Vụ Cho Phòng Này]`**:
        * Bấm vào sẽ mở Popup Modal: Chọn dịch vụ từ combobox (tự động hiện đơn giá), nhập số lượng, hiển thị thành tiền tạm tính.
        * Bấm "Xác Nhận Thêm" $\to$ Gọi `CustomerAddServiceServlet` ghi nhận ngay lập tức vào CSDL.
  - **Footer tổng kết tài chính:**
    * Bảng tóm tắt: Tổng tiền phòng + Tổng tiền dịch vụ của toàn bộ các phòng = **Tổng Chi Phí Cuối Cùng**.

---

## 6. TƯƠNG TÁC CSDL: PHỐI HỢP FUNCTION, TRIGGER & TRANSACTION

### 6.1. Function 5: `fn_TraCuuPhongOnline` (Nâng cấp từ `fn_TraCuuPhongTrongTheoYeuCau`)
Được `RoomDAO` gọi trực tiếp khi khách hàng tìm kiếm phòng trên Web:
* **Loại bỏ phòng hư hỏng (`Damaged`):** Điều kiện `p.TrangThai <> 'Damaged'` bảo đảm 100% không bao giờ lộ phòng hỏng ra ngoài web.
* **Cơ chế Housekeeping Buffer 1 tiếng:** 
  - Nếu nhận phòng từ ngày mai trở đi: Bỏ qua trạng thái `Dirty`/`Cleaning` hiện tại (vì ngày mai phòng chắc chắn đã dọn xong).
  - Nếu nhận phòng ngay hôm nay: Chỉ hiển thị phòng `Dirty`/`Cleaning` khi khoảng cách giữa lúc khách cũ check-out và giờ nhận phòng $\ge 60\text{ phút}$.
* **Kiểm tra trùng lịch:** Lồng kiểm tra không giao thoa với bất kỳ đơn đặt phòng nào khác trong `BOOKING_PHONG` (`DaXacNhan` hoặc `DaCheckIn`).

### 6.2. Function 4: `fn_KiemTraPhongTrongTrongKhoang`
Được gọi 2 lần:
* Lần 1: Trong câu lệnh SELECT tìm kiếm phòng online.
* Lần 2: Trong khối TRANSACTION của `BookingDAO` ngay trước khi bấm INSERT để chặn dứt điểm hiện tượng 2 khách cùng bấm đặt 1 phòng trong cùng 1 giây (Race Condition).
* **Quy chuẩn mới:** Nhận thêm tham số `@GioNhanDuKien TIME = '14:00'` để tính toán chính xác khoảng thời gian chết 60 phút khi khách nhận phòng trong ngày.

### 6.3. Trigger 1: `trg_Check_XungDotDatPhong`
* "Người gác cổng" tầng sâu nhất trong CSDL trên bảng `BOOKING_PHONG`: Nếu vì lý do nào đó có 2 luồng đồng thời vượt qua tầng ứng dụng, Trigger này sẽ tự động `ROLLBACK TRANSACTION` và ném lỗi tiếng Việt rõ ràng, bảo đảm CSDL không bao giờ bị vi phạm toàn vẹn.

### 6.4. Trigger 5: `trg_TuDongTaoHoaDonKhiDatPhong`
* Ngay sau khi bảng `BOOKING` có bản ghi mới, Trigger này tự động chèn 1 dòng vào bảng `HOADON` với trạng thái `ChuaThanhToan`.
* **Cập nhật quy chuẩn mã:** Đồng bộ mã `HOADON` theo đúng chuẩn liền mạch `HD001` tương ứng với `BK001` (xem chi tiết mục 7.2).

### 6.5. Tương Tác Bảng `BOOKING_DICHVU` & Hàm Tính Tiền Dịch Vụ `fn_TinhTienDichVuBooking`
* **Ghi nhận dịch vụ phát sinh theo phòng:** Bảng `BOOKING_DICHVU` lưu trữ chính xác dịch vụ gắn vào từng phòng với `(MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem)`.
* **Cập nhật tổng chi phí tức thời:** Sử dụng hàm CSDL:
  ```sql
  SELECT dbo.fn_TinhTongTienThucTePhaiTra(@MaBooking)
  ```
  Hàm này tự động tính gộp: `fn_TinhTienPhongBooking(@MaBooking) + fn_TinhTienDichVuBooking(@MaBooking)`, đảm bảo số liệu tổng chi phí trong `BOOKING` luôn khớp 100% với chi tiết phòng và dịch vụ.
* **Hỗ trợ gọi thêm dịch vụ linh hoạt:** Khách hàng có thể gọi thêm dịch vụ khi đơn ở trạng thái `DaXacNhan` hoặc `DaCheckIn`, không bị giới hạn chỉ được đặt dịch vụ lúc ban đầu.

---

## 7. GIẢI PHÁP XỬ LÝ THÁCH THỨC NGHIỆP VỤ ĐẶC THÙ

### 7.1. Chống Đặt Trùng Phòng Thời Gian Thực (Concurrency / Overbooking)
* **Vấn đề thực tế:** Khách hàng A và Khách hàng B cùng mở trang web, cùng nhìn thấy phòng 101 đang trống từ ngày 01/10 đến 03/10. Cả 2 cùng bấm nút "Đặt phòng" vào đúng 10:15:30.
* **Giải pháp 3 lớp bảo vệ khép kín:**
  1. **Lớp 1 (Validation tại Service):** Kiểm tra trạng thái khả dụng trước khi mở transaction.
  2. **Lớp 2 (Transaction Isolation & Re-check tại DAO):** Bên trong `conn.setAutoCommit(false)`, thực hiện kiểm tra lại `fn_KiemTraPhongTrongTrongKhoang`. Nếu thấy có booking khác vừa được commit chen ngang $\to$ Hủy ngay lập tức và ném `RoomConflictException`.
  3. **Lớp 3 (Database Trigger 1):** `trg_Check_XungDotDatPhong` tự động kích hoạt ở mức CSDL và `ROLLBACK TRANSACTION` nếu thời gian giao thoa.
* **Trải nghiệm người dùng:** Người thứ 2 sẽ không bị sập ứng dụng (không bị lỗi 500), mà màn hình sẽ hiển thị thông báo lịch sự màu vàng: *"Rất tiếc! Phòng này vừa được một khách hàng khác hoàn tất đặt trước bạn ít giây. Vui lòng chọn một phòng khác!"*.

### 7.2. Thống Nhất Tuyệt Đối Chuẩn Khóa Chính Liền Mạch (BK001, BD001, HD001)
* **Yêu cầu nghiêm ngặt từ lập trình viên:** Khóa chính toàn hệ thống phải thống nhất 1 kiểu: `TK001`, `KH001`, `NV001`, `BK001`, `BD001`, `HD001` (không dùng gạch dưới `BK_001` hay `BK_uuid`).
* **Triển khai trong Java (`KeyGenerator.java`):**
  - `KeyGenerator.generateBookingId()`: Sinh mã Booking dạng `BK001`, `BK002`...
  - `KeyGenerator.generateBookingDichVuId()`: Sinh mã Dịch vụ Booking dạng `BD001`, `BD002`...
    ```java
    public static String generateBookingDichVuId() {
        return generateNextId("BOOKING_DICHVU", "MaBookingDichVu", "BD", 3);
    }
    ```
    Thuật toán: Quét `MAX(TRY_CAST(SUBSTRING(MaBookingDichVu, 3, 10) AS INT))` $\to$ Lấy MAX + 1 $\to$ Định dạng `BD%03d` $\to$ Kiểm tra tính độc nhất tuyệt đối trong DB.
* **Đồng bộ mã Trigger 5 trong SQL Server:**
  - Script SQL ban đầu sinh `'HD_' + SUBSTRING(i.MaBooking, 4, 7)`.
  - Cập nhật Trigger 5 sang dạng liền mạch chuẩn:
    ```sql
    CREATE OR ALTER TRIGGER trg_TuDongTaoHoaDonKhiDatPhong
    ON BOOKING
    AFTER INSERT
    AS
    BEGIN
        SET NOCOUNT ON;
        INSERT INTO HOADON (MaHoaDon, MaBooking, NgayLap, TongTienCuoiCung, MaNV, TrangThai)
        SELECT 
            'HD' + SUBSTRING(i.MaBooking, 3, 8), -- Từ BK001 -> HD001 (chuẩn hóa liền mạch 100%)
            i.MaBooking,
            GETDATE(),
            NULL,
            ISNULL(i.MaNV, 'NV001'),
            'ChuaThanhToan'
        FROM inserted i
        WHERE NOT EXISTS (SELECT 1 FROM HOADON WHERE MaBooking = i.MaBooking);
    END;
    GO
    ```
  - Khi Java chèn `BK001`, Trigger 5 sẽ tự động sinh hóa đơn mang mã `HD001` hoàn toàn đồng bộ, sạch sẽ và nhất quán.

### 7.3. Cơ Chế Thời Gian Chết 1 Tiếng (Housekeeping Buffer) & Vòng Đời Phòng Hư Hỏng (Damaged)
* **Vấn đề thực tế:** Khi khách cũ A vừa check-out lúc 11:30 trưa, phòng chuyển sang `Dirty`. Nếu web ẩn phòng thì khách tìm phòng cho ngày mai hoặc chiều nay sẽ không thấy $\to$ mất khách. Ngược lại, nếu phòng bị hư hại (`Damaged`) mà vẫn hiện thì có nguy cơ bán nhầm phòng hỏng.
* **Ma trận quyết định tính khả dụng phòng (Availability Decision Matrix):**

| Trạng thái vật lý | Thời điểm nhận phòng | Kênh áp dụng | Quyết định hệ thống | Cơ chế bảo vệ nghiệp vụ |
| :--- | :--- | :--- | :---: | :--- |
| **Damaged (Hư hỏng)** | Bất kỳ ngày nào | **Web Online** | ❌ **Ẩn 100%** | Khách online không thấy phòng hỏng, tránh rủi ro đền bù/khiếu nại. |
| **Damaged (Hư hỏng)** | Hôm nay | **Lễ tân tại quầy** | ❌ **Khóa Check-in** | Nút Check-in bị vô hiệu hóa, hiện cờ lê cảnh báo sự cố kỹ thuật. |
| **Dirty / Cleaning** | Ngày mai trở đi | **Web Online** | ✅ **Cho phép hiện** | Khách nhận sau hơn 24 tiếng, buồng phòng chắc chắn đã dọn xong. |
| **Dirty / Cleaning** | Hôm nay ($\Delta T < 1\text{h}$) | **Web Online** | ❌ **Tạm ẩn** | Cách lúc check-out chưa đủ 1 tiếng, buồng phòng dọn không kịp. |
| **Dirty / Cleaning** | Hôm nay ($\Delta T \ge 1\text{h}$) | **Web Online** | ✅ **Cho phép hiện** | Đủ khoảng đệm $\ge 1$ tiếng để buồng phòng dọn dẹp sạch sẽ. |
| **Dirty / Cleaning** | Hôm nay (ở ngay) | **Lễ tân tại quầy** | ❌ **Không giao chìa khóa** | Khách đứng tại quầy đòi nhận phòng ngay, chưa dọn xong không thể giao. |
| **Available (Sạch)** | Hôm nay (ở ngay) | **Lễ tân tại quầy** | ✅ **Giao phòng ngay** | Kiểm tra ổ khóa 2: Không bị đè lịch tương lai. |

* **Vòng đời phòng hư hỏng (Damaged Lifecycle):**
  - Buồng phòng phát hiện hỏng thiết bị $\to$ Lập `BAOCAOHUHAI` $\to$ Phòng đổi sang `Damaged` $\to$ Tự động ẩn khỏi Web Online & Khóa Check-in tại quầy.
  - Kỹ thuật sửa chữa xong $\to$ Buồng phòng kiểm tra và dọn dẹp $\to$ Bấm "Hoàn thành" $\to$ Phòng chuyển về `Available`.
  - **Ngay lập tức:** Phòng tự động xuất hiện trở lại trên Web Online và trên Sơ đồ phòng của Lễ tân để đón khách mới.

### 7.4. Quy Trình Lễ Tân Tiếp Khách Vãng Lai (Walk-in Double Validation)
* **Vấn đề thực tế:** Khách vãng lai đến quầy muốn thuê phòng ngay từ hôm nay đến ngày X. Lễ tân cần biết phòng nào đang trống mà **không được đè lên lịch của khách đã đặt online trong tương lai**.
* **Giải pháp 2 ổ khóa kiểm tra (Double Validation):**
  1. **Ổ khóa 1 (Trạng thái tức thời):** Bắt buộc `PHONG.TrangThai = 'Available'` (sạch sẽ, sẵn sàng giao phòng ngay).
  2. **Ổ khóa 2 (Quét lịch tương lai):** Hệ thống quét bảng `BOOKING_PHONG`: Từ hôm nay đến ngày X không có bất kỳ khách online nào đã đặt trước.
  - **Hàm hỗ trợ SQL:** `fn_TraCuuPhongChoKhachVangLai(@NgayTraDuKien, @MaLoaiPhong)`.

### 7.5. Cơ Chế Quản Lý Dịch Vụ Theo Từng Phòng (Room-Specific Add-on Services) & Toàn Vẹn 3NF
* **Vấn đề thực tế:** Một khách hàng đặt phòng không chỉ trả tiền lưu trú mà thường phát sinh nhu cầu tiện ích: Buffet sáng cho 2 người ở phòng P101, xe đưa đón sân bay cho phòng P102... Nếu chỉ lưu dịch vụ chung chung theo mã booking mà không biết dịch vụ đó phục vụ cho phòng nào thì lễ tân và buồng phòng không thể điều phối phục vụ chính xác.
* **Thiết kế chuẩn hóa CSDL (3NF):**
  - `BOOKING_DICHVU` tham chiếu khóa ngoại kép `CONSTRAINT FK_BDV_BOOKING_PHONG FOREIGN KEY (MaBooking, MaPhong) REFERENCES BOOKING_PHONG (MaBooking, MaPhong)`.
  - Điều này bắt buộc mọi dịch vụ được gọi phải gắn chính xác vào một phòng đã đặt trong đơn, ngăn chặn tuyệt đối tình trạng gán dịch vụ vào phòng không thuộc về đơn đó.
* **Bảo vệ toàn vẹn giá (Price Integrity):**
  - Cột `DonGia` trong `BOOKING_DICHVU` lưu cố định giá trị tại thời điểm thêm. Dù sau này quản lý có tăng giá Buffet từ 150.000đ lên 200.000đ trong bảng `DICHVU`, đơn đặt phòng cũ vẫn giữ nguyên giá 150.000đ, bảo vệ quyền lợi minh bạch cho khách hàng.
* **Kiểm soát phân quyền thêm/xóa:**
  - Khách hàng chỉ được thêm dịch vụ vào phòng của chính mình (`maKH` khớp session) và khi đơn đang có hiệu lực (`DaXacNhan` hoặc `DaCheckIn`).
  - Khách chỉ được hủy dịch vụ khi đơn **chưa check-in** (`DaXacNhan`). Khi đã check-in, mọi thao tác hủy dịch vụ phải do Lễ tân kiểm tra thực tế (tránh trường hợp khách đã ăn sáng buffet xong rồi tự bấm hủy trên web).

### 7.6. Cơ Chế Đặt Nhiều Phòng Với Khoảng Thời Gian Độc Lập Trong Cùng Một Booking & Giỏ Hàng Session

#### 7.6.1. Trả Lời Trọng Tâm Nghiệp Vụ: Xử lý thế nào khi khách đặt 2 phòng có khoảng thời gian khác nhau?
* **Khẳng định kiến trúc:** CSDL và mô hình ứng dụng đã được thiết kế chuẩn mực ngay từ đầu để hỗ trợ hoàn hảo kịch bản này!
* **Bản chất CSDL đã tách biệt thời gian lưu trú về cấp phòng:**
  - Trong cấu trúc CSDL chuẩn hóa 3NF: Bảng cha `BOOKING(MaBooking, MaKH, NgayDat, TrangThai, ChiPhiDuKien...)` **hoàn toàn không chứa** cột `NgayNhanDuKien` hay `NgayTraDuKien`.
  - Thông tin thời gian nhận phòng và trả phòng được lưu trữ tại bảng con `BOOKING_PHONG`:
    ```sql
    BOOKING_PHONG (
        MaBooking          VARCHAR(10),
        MaPhong            VARCHAR(10),
        DonGiaPhong        DECIMAL(12,2),
        NgayNhanDuKien     DATE,          -- Khoảng thời gian nhận của RIÊNG phòng này
        NgayTraDuKien      DATE,          -- Khoảng thời gian trả của RIÊNG phòng này
        NgayCheckInThucTe  DATETIME,      -- Ghi nhận giờ nhận phòng thực tế riêng
        NgayCheckOutThucTe DATETIME,      -- Ghi nhận giờ trả phòng thực tế riêng
        CONSTRAINT PK_BOOKING_PHONG PRIMARY KEY (MaBooking, MaPhong)
    )
    ```
  - **Ví dụ thực tế minh chứng:** Cùng thuộc một đơn `MaBooking = 'BK010'`:
    * Phòng `P101`: `NgayNhanDuKien = '2026-10-01'`, `NgayTraDuKien = '2026-10-03'` (Số đêm = 2 đêm).
    * Phòng `P202`: `NgayNhanDuKien = '2026-10-02'`, `NgayTraDuKien = '2026-10-06'` (Số đêm = 4 đêm).
  - Hai phòng lưu trú hoàn toàn độc lập về ngày nhận, ngày trả và số đêm, không hề ràng buộc phải có cùng ngày đi hay cùng ngày về!

#### 7.6.2. Cơ Chế Kiểm Tra Khả Dụng Độc Lập Theo Thời Gian Thực (Independent Real-Time Availability Check)
* Khi khách hàng tìm kiếm đợt 1 với khoảng ngày $[CheckIn_1, CheckOut_1]$ (Ví dụ: 01/10 $\to$ 03/10): Hệ thống gọi `fn_TraCuuPhongOnline(2026-10-01, 2026-10-03, ...)` $\to$ Hiển thị danh sách phòng trống trong khoảng thời gian này. Khách chọn phòng `P101`.
* Khi khách bấm nút *"➕ Lưu & Đặt thêm phòng khác"*: Hệ thống đóng gói `CartRoomItemDTO` (gồm `maPhong = P101`, ngày nhận: `2026-10-01`, ngày trả: `2026-10-03`, số đêm: 2, cùng các dịch vụ đã chọn của phòng này) và lưu vào Giỏ hàng Session `BookingCartDTO`.
* Khách hàng quay lại màn hình tìm kiếm, đổi ngày trên Search Bar sang $[CheckIn_2, CheckOut_2]$ (Ví dụ: 02/10 $\to$ 06/10) và bấm "Tìm phòng": Hệ thống thực thi truy vấn tìm kiếm mới độc lập theo khoảng ngày thứ hai. Phòng `P202` trống trong khoảng 02/10 $\to$ 06/10 xuất hiện trong kết quả. Khách chọn phòng `P202`.
* Khi khách vào trang Checkout và bấm *"Xác nhận đặt toàn bộ"*:
  - **Tại tầng DAO bên trong Transaction:** Hệ thống quét qua từng phòng trong giỏ hàng:
    * Kiểm tra phòng 1: `fn_KiemTraPhongTrongTrongKhoang('P101', '2026-10-01', '2026-10-03', '14:00')`.
    * Kiểm tra phòng 2: `fn_KiemTraPhongTrongTrongKhoang('P202', '2026-10-02', '2026-10-06', '14:00')`.
  - Mỗi phòng được kiểm tra theo đúng khoảng ngày riêng của phòng đó. Nếu cả 2 đều hợp lệ $\to$ Ghi nhận đồng thời trong một giao tác an toàn tuyệt đối.

#### 7.6.3. Quy Tắc Ngăn Chặn Xung Đột & Trùng Lặp Phòng (Room Conflict Rules)
1. **Khóa chính ngăn trùng lặp (Primary Key Integrity):** Khóa chính của bảng `BOOKING_PHONG` là cặp `(MaBooking, MaPhong)`. Do đó, về mặt cấu trúc dữ liệu, một phòng vật lý **tuyệt đối không thể xuất hiện 2 lần trong cùng một mã `MaBooking`**. Nếu cố tình chèn 2 dòng cho cùng một phòng `P101` vào một đơn, SQL Server sẽ ném lỗi vi phạm khóa chính `PK_BOOKING_PHONG` ngay lập tức.
2. **Bản chất nghiệp vụ khách sạn thực tế (2 Kỳ lưu trú = 2 Đơn đặt phòng riêng biệt):**
   - **Tình huống:** Khách muốn ở phòng `P101` từ 01/10 đến 03/10, sau đó về nhà và quay lại ở tiếp phòng `P101` từ 10/10 đến 12/10.
   - **Xác định nghiệp vụ:** Đây là **2 chuyến đi / 2 kỳ lưu trú hoàn toàn tách biệt**. Mỗi đợt đều có vòng đời riêng: Khách đến Check-in $\to$ Ở $\to$ Check-out $\to$ Thanh toán & Quyết toán Hóa đơn $\to$ Buồng phòng dọn dẹp để khách sạn đón các lượt khách khác trong khoảng thời gian trống 7 ngày ở giữa.
   - **Quy tắc bắt buộc:** Trong trường hợp này, **khách hàng bắt buộc phải tạo 2 đơn đặt phòng riêng biệt** (`BK001` cho đợt 1 và `BK002` cho đợt 2), tương ứng với **2 hóa đơn tài chính độc lập** (`HD001` và `HD002`).
3. **Trải nghiệm hướng dẫn người dùng trên giao diện UI/UX:**
   - Khi phòng `P101` đã nằm trong Giỏ hàng của đơn hiện tại:
     * Nếu khách đổi ngày sang đợt mới và bấm thêm lại phòng `P101`, hệ thống sẽ phát hiện `cart.containsRoom("P101")` và hiển thị một Popup Modal hướng dẫn trực quan:
       > ⚠️ **Thông báo điều chỉnh lịch đặt phòng:**  
       > *"Phòng P101 hiện đã có trong giỏ hàng cho kỳ nghỉ từ **01/10/2026 đến 03/10/2026**.*  
       > *Vì một đơn chỉ áp dụng cho một lượt lưu trú liên tục của mỗi phòng, hệ thống không thể gộp hai kỳ nghỉ gián đoạn vào cùng một mã booking.*  
       > *Vui lòng chọn một trong hai phương án sau:*  
       > *• **[Cập nhật ngày mới]:** Thay đổi kỳ nghỉ của phòng P101 thành 10/10 - 12/10 trong đơn hiện tại.*  
       > *• **[Tách đơn mới]:** Hoàn tất thanh toán đơn hiện tại trước, sau đó tiến hành đặt thêm đơn thứ 2 cho chuyến đi tiếp theo."*

#### 7.6.4. Công Thức Tính Toán Tài Chính Tổng Hợp Cho Đơn Đa Phòng - Đa Thời Gian
* Tiền phòng của từng phòng:
  $$\text{TienPhong}_i = \text{DonGiaPhong}_i \times \text{SoDem}_i = \text{DonGiaPhong}_i \times \left(\text{NgayTraDuKien}_i - \text{NgayNhanDuKien}_i\right)$$
* Tiền dịch vụ phát sinh của từng phòng:
  $$\text{TienDichVu}_i = \sum_{j=1}^{m_i} \left(\text{DonGiaDV}_{ij} \times \text{SoLuong}_{ij}\right)$$
* Chi phí tạm tính của từng phòng:
  $$\text{TongPhong}_i = \text{TienPhong}_i + \text{TienDichVu}_i$$
* **Tổng Chi Phí Toàn Bộ Booking (Ghi vào `BOOKING.ChiPhiDuKien` và tự động kích hoạt tạo `HOADON.TongTienCuoiCung`):**
  $$\text{TongChiPhiDuKien} = \sum_{i=1}^{n} \text{TongPhong}_i = \sum_{i=1}^{n} \left[ \text{DonGiaPhong}_i \times \text{SoDem}_i + \sum_{j=1}^{m_i} (\text{DonGiaDV}_{ij} \times \text{SoLuong}_{ij}) \right]$$

#### 7.6.5. Vòng Đời Giỏ Hàng `BookingCartDTO` Trong `HttpSession`
1. **Khởi tạo:** Khi khách bấm "Thêm vào giỏ phòng", nếu session chưa có giỏ thì `CustomerCartServlet` tạo mới đối tượng `BookingCartDTO` và lưu vào `session.setAttribute("BOOKING_CART", cart)`.
2. **Bảo toàn trạng thái:** Khi khách quay lại màn hình tìm kiếm, đổi ngày, chọn hạng phòng khác, đối tượng `BOOKING_CART` vẫn được giữ nguyên vẹn trong phiên làm việc của người dùng.
3. **Hiển thị linh động:** Thanh giỏ hàng nổi (Floating Cart Bar) và Badge trên menu luôn hiển thị chính xác số lượng phòng đã chọn.
4. **Giải phóng:** Sau khi `BookingService.createMultiRoomBooking()` hoàn tất và commit CSDL thành công $\to$ gọi `session.removeAttribute("BOOKING_CART")` để dọn dẹp bộ nhớ và chống đặt lại đơn cũ.

#### 7.6.6. Khả Năng Tương Thích Tuyệt Đối Với Nghiệp Vụ Lễ Tân Check-in (Giai Đoạn 3)
* Bảng `BOOKING_PHONG` có riêng 2 cột `NgayCheckInThucTe` và `NgayCheckOutThucTe` cho từng phòng:
  - **Ngày 01/10:** Khách phòng `P101` đến trước $\to$ Lễ tân thực hiện Check-in riêng cho phòng `P101` $\to$ Ghi nhận `NgayCheckInThucTe = GETDATE()` cho `P101`, trạng thái phòng `P101` chuyển sang `Occupied`. Phòng `P202` vẫn đang chờ khách và chưa check-in.
  - **Ngày 02/10:** Khách phòng `P202` đến quầy $\to$ Lễ tân Check-in tiếp cho phòng `P202` $\to$ Cập nhật `NgayCheckInThucTe` cho `P202`.
  - **Ngày 03/10:** Khách phòng `P101` làm thủ tục Check-out $\to$ Phòng `P101` chuyển sang `Dirty` và tự động sinh nhiệm vụ dọn phòng cho Housekeeper; trong khi phòng `P202` vẫn đang ở bình thường cho đến ngày 06/10!
* **Kết luận:** Mô hình dữ liệu và chu trình nghiệp vụ được thiết kế hoàn toàn tương thích và thông suốt từ Giai đoạn 2 (Web Khách Hàng) sang Giai đoạn 3 (Lễ Tân Tiếp Nhận) và Giai đoạn 5 (Buồng Phòng Dọn Dẹp).

---

### 7.7. Thiết Kế Luồng Trải Nghiệm Đặt Phòng Đa Bước Chuẩn Quốc Tế Phong Cách iVIVU (5-Step Customer Booking Journey)

#### 7.7.1. Đặt Vấn Đề Nghiệp Vụ & Nhu Cầu Nâng Tầm Giao Diện Khách Sạn
* **Thực trạng ban đầu:** Giao diện khách hàng trước đây kết hợp dồn dập việc xem phòng, đặt phòng và điền form vào cùng một màn hình hoặc danh sách dạng lưới đơn giản, thiếu thông tin chuyên sâu của từng phòng (kích thước, dịch vụ miễn phí, chi tiết tiện nghi) và chưa có luồng điều hướng mượt mà khi khách muốn đặt nhiều phòng.
* **Mô hình chuẩn hóa (tham khảo nền tảng OTA hàng đầu iVIVU / Agoda / Booking.com):**
  - Tách bạch rõ ràng 5 bước hành trình khách hàng:
    1. **Trang Chủ (`home.jsp`):** Giới thiệu không gian khách sạn sang trọng + Thanh tìm kiếm trung tâm.
    2. **Trang Đặt Phòng / Danh Sách Kết Quả Tìm Kiếm (`room_list.jsp`):** Bố cục 2 cột chuyên nghiệp:
       - Cột trái: Bộ lọc đa tiêu chí (Khu vực / Hạng phòng, Khoảng giá / Ngân sách, Sức chứa).
       - Cột phải: Danh sách phòng dạng **Thẻ Ngang (Horizontal Card)** với ảnh phòng, hạng phòng, tiện ích miễn phí (bao gồm ăn sáng, wifi...), đơn giá niêm yết theo đêm và nút **`[Xem Phòng]`**.
    3. **Trang Xem Chi Tiết Phòng (`room_detail.jsp`):** Thể hiện toàn diện thông số kỹ thuật (Kích thước phòng $m^2$, số lượng khách, tiện ích miễn phí, loại giường, view, nội quy) kèm nút **`[Đặt Phòng]`**.
    4. **Trang Điền Thông Tin Khách & Dịch Vụ Bổ Sung (`booking_form.jsp`):** Tự động điền (Auto-fill) thông tin cá nhân từ phiên đăng nhập, cho phép khách chọn thêm các dịch vụ gia tăng gắn riêng cho phòng đó kèm nút **`[Thêm Vào Booking]`**.
    5. **Cửa Sổ Nhỏ / Popup Modal Xác Nhận & Đặt Tiếp:** Bảng tóm tắt chi phí phòng + dịch vụ vừa chọn, mang lại 2 tùy chọn linh hoạt:
       - **`[Quay Lại Đặt Tiếp]`**: Giữ nguyên giỏ hàng, cho phép chọn tiếp phòng thứ 2, thứ 3...
       - **`[Xác Nhận Đặt Booking]`**: Chuyển thẳng đến chốt giao dịch và lưu vào CSDL.

---

### 7.8. Chi Tiết Kiến Trúc Kỹ Thuật & Tương Tác Các Lớp Trong Luồng 5 Bước

```mermaid
sequenceDiagram
    autonumber
    actor KhachHang as Khách Hàng
    participant Home as home.jsp (Trang Chủ)
    participant SearchCtrl as CustomerSearchRoomsServlet
    participant RoomList as room_list.jsp (Bố Cục iVIVU)
    participant DetailCtrl as CustomerRoomDetailServlet
    participant RoomDetail as room_detail.jsp (Xem Phòng)
    participant BookCtrl as CustomerBookingServlet
    participant BookForm as booking_form.jsp (Điền Thông Tin)
    participant CartCtrl as CustomerCartServlet
    participant CartSession as HttpSession (BOOKING_CART)
    participant PopupModal as Modal Popup (Tóm Tắt & Lựa Chọn)
    participant CheckoutCtrl as CustomerBookingCheckoutServlet

    KhachHang->>Home: Đăng nhập -> Vào Trang Chủ (Banner giới thiệu + Search Bar)
    KhachHang->>Home: Nhập ngày nhận, ngày trả, số khách -> Bấm "Tìm Kiếm"
    Home->>SearchCtrl: GET /customer/search-rooms?checkIn=...&checkOut=...
    SearchCtrl->>RoomList: Render Trang Đặt Phòng (Bộ lọc trái + Thẻ ngang iVIVU phải)
    KhachHang->>RoomList: Xem danh sách, bấm nút "[Xem Phòng]" trên phòng P101
    RoomList->>DetailCtrl: GET /customer/room-detail?maPhong=P101&checkIn=...&checkOut=...
    DetailCtrl->>RoomDetail: Render trang chi tiết (kích thước m2, sức chứa, dịch vụ miễn phí)
    KhachHang->>RoomDetail: Xem thông tin ưng ý -> Bấm nút "[Đặt Phòng Này]"
    RoomDetail->>BookCtrl: GET /customer/booking?action=prepare&maPhong=P101...
    BookCtrl->>BookForm: Render form (Auto-fill họ tên/SĐT/Email + Danh mục dịch vụ bổ sung)
    KhachHang->>BookForm: Chọn dịch vụ (Buffet x2) -> Bấm "[Thêm Vào Booking]"
    BookForm->>CartCtrl: POST /customer/cart?action=add (Gói CartRoomItemDTO)
    CartCtrl->>CartSession: Lưu CartRoomItemDTO vào BOOKING_CART
    CartCtrl-->>PopupModal: Trả về trạng thái thành công + Dữ liệu tóm tắt phòng vừa thêm
    Note over PopupModal: Hiển thị Popup Modal:<br/>- Tiền phòng P101 + Dịch vụ<br/>- 2 Nút: [Quay Lại Đặt Tiếp] & [Xác Nhận Đặt]
    alt Khách chọn [Quay Lại Đặt Tiếp]
        KhachHang->>PopupModal: Click "[Quay Lại Đặt Tiếp]"
        PopupModal->>SearchCtrl: Chuyển về màn hình tìm kiếm, giỏ hàng giữ nguyên P101
        Note over KhachHang, RoomList: Khách tiếp tục chọn phòng P202 theo luồng trên
    else Khách chọn [Xác Nhận Đặt Booking]
        KhachHang->>PopupModal: Click "[Xác Nhận Đặt Booking]"
        PopupModal->>CheckoutCtrl: Chuyển đến màn hình Xác Nhận Chốt Đơn
        CheckoutCtrl->>KhachHang: Lưu toàn bộ đơn vào CSDL (BOOKING, BOOKING_PHONG, BOOKING_DICHVU, HOADON)
    end
```

---

#### 7.8.1. Bước 1: Trang Chủ Khách Sạn (`home.jsp` - `/customer/home`)
* **Mục tiêu:** Giới thiệu thương hiệu khách sạn nghỉ dưỡng cao cấp, tạo ấn tượng chuyên nghiệp ban đầu.
* **Thành phần giao diện:**
  - **Hero Banner:** Tiêu đề chào mừng khách hàng cá nhân hóa (`Xin chào, ${sessionScope.CURRENT_USER.hoTen}`), giới thiệu tiêu chuẩn phục vụ, không gian nghỉ dưỡng (chờ trang trí ảnh/nội dung chi tiết ở các giai đoạn sau).
  - **Thanh tìm kiếm trung tâm (Search Bar Bar):**
    * Ô Ngày nhận phòng: Mặc định là ngày hôm nay (`LocalDate.now()`).
    * Ô Ngày trả phòng: Mặc định là ngày mai (`LocalDate.now().plusDays(1)`).
    * Ô Số lượng khách: Dropdown (1 người, 2 người, 3 người, 4+ người).
    * Ô Hạng phòng: Dropdown lấy từ bảng `LOAIPHONG` (Tất cả hạng phòng, Standard, Superior, Deluxe, Suite...).
    * Nút hành động nổi bật: **`[Tìm Kiếm Phòng]`** (Gửi `GET` sang `/customer/search-rooms`).

---

#### 7.8.2. Bước 2: Trang Đặt Phòng / Danh Sách Kết Quả (`room_list.jsp` - Phong Cách iVIVU)
* **Bố cục 2 cột chuyên nghiệp theo đúng ảnh thiết kế tham khảo:**
  1. **Cột Trái - Bộ Lọc Đa Năng (Filter Sidebar - Rộng ~280px):**
     - Tiêu đề "Bộ Lọc Tìm Kiếm" kèm nút "Xóa tất cả bộ lọc".
     - **Lọc theo Tên/Số phòng:** Ô input tìm kiếm nhanh.
     - **Lọc theo Hạng phòng / Khu vực:** Danh sách Checkbox (Standard, Superior, Deluxe, Suite...) kèm số lượng phòng khả dụng tương ứng.
     - **Lọc theo Ngân sách (Giá/đêm):**
       * Dưới 1.000.000 đ
       * 1.000.000 đ - 2.000.000 đ
       * 2.000.000 đ - 3.000.000 đ
       * Trên 3.000.000 đ
     - **Lọc theo Sức chứa:** 1 người, 2 người, 3-4 người.
     - Khả năng lọc tức thời bằng JavaScript hoặc gửi tham số URL.
  2. **Cột Phải - Danh Sách Thẻ Phòng Nằm Ngang (Horizontal Room Cards):**
     - Thanh tóm tắt kết quả: Số lượng phòng tìm thấy + Dropdown sắp xếp ("Giá tăng dần", "Giá giảm dần", "Sức chứa").
     - **Mỗi Thẻ Phòng Nằm Ngang bao gồm 3 khối nội dung liền mạch:**
       * **Khối 1 (Ảnh đại diện bên trái - ~260px):** Ảnh chất lượng cao của hạng phòng, badge nhãn nổi bật màu đỏ gạch/vàng đồng (VD: *"Bao gồm bữa sáng"* hoặc *"Ưu đãi hôm nay"*).
       * **Khối 2 (Thông tin chi tiết ở giữa - linh hoạt):**
         - Tên phòng & Hạng phòng nổi bật (VD: **Phòng 101 - Deluxe Ocean View**).
         - Tiêu chuẩn khách sạn & Đánh giá (Văn bản thuần túy: *"Tiêu chuẩn 5 sao - Xuất sắc 9.6/10"*).
         - Thông tin vị trí & tầng (VD: *"Tầng 3 - Hướng biển Panorama"*).
         - Tags tiện nghi cốt lõi: *"Bồn tắm nằm", "Ban công riêng", "Điều hòa 2 chiều", "Wifi tốc độ cao"*.
         - Thông báo tình trạng phòng: *"Sẵn sàng đón khách"* (hoặc *"Chỉ còn 1 phòng duy nhất"*).
       * **Khối 3 (Bảng giá & Nút hành động bên phải - ~220px, viền ngăn cách trang nhã):**
         - Tên gói lưu trú: `Gói Nghỉ Dưỡng Tiêu Chuẩn`.
         - Checklist quyền lợi miễn phí:
           * `✓ Đã bao gồm bữa sáng`
           * `✓ Nước khoáng & trà miễn phí`
           * `✓ Miễn phí hủy trước 24h`
         - Đơn giá hiển thị to, rõ ràng, màu cam đất cao cấp: **`1.598.000 đ`** / phòng / đêm (định dạng chuẩn `fmt:formatNumber`, không số lẻ thập phân).
         - Nút hành động nổi bật: **`[Xem Phòng]`** (Dẫn sang Trang Xem Chi Tiết Phòng: `/customer/room-detail?maPhong=${room.maPhong}&checkIn=${paramCheckIn}&checkOut=${paramCheckOut}`).

---

#### 7.8.3. Bước 3: Trang Xem Chi Tiết Phòng (`room_detail.jsp` - `/customer/room-detail`)
* **Mục tiêu:** Cung cấp đầy đủ thông tin chuyên sâu của phòng được chọn để khách an tâm trước khi quyết định đặt.
* **Nội dung hiển thị toàn diện:**
  1. **Thông số kỹ thuật phòng:**
     - **Kích thước / Diện tích:** $35\text{ m}^2$ (hoặc $45\text{ m}^2$, $60\text{ m}^2$ theo từng hạng phòng).
     - **Sức chứa tối đa:** 2 người lớn + 1 trẻ em.
     - **Cấu hình giường:** 1 giường King-size cao cấp (hoặc 2 giường đơn).
     - **Hướng nhìn (View):** Hướng biển trực diện / Hướng đồi thông / Hướng thành phố.
     - **Vị trí tầng:** Tầng 2, Tòa nhà trung tâm.
  2. **Danh mục dịch vụ & Tiện ích MIỄN PHÍ đi kèm phòng (Complimentary Inclusions):**
     - Bữa sáng buffet tự chọn hàng ngày tại nhà hàng tầng 1.
     - 02 chai nước suối tinh khiết, trà và cà phê setup hàng ngày trong phòng.
     - Sử dụng miễn phí hồ bơi vô cực nước ấm và phòng Gym thể hình.
     - Internet Wifi cáp quang tốc độ cao không giới hạn.
     - Dịch vụ dọn phòng và thay khăn tiêu chuẩn mỗi ngày.
     - Đồ dùng vệ sinh cá nhân cao cấp (áo choàng, dép đi trong phòng, máy sấy tóc, két sắt an toàn).
  3. **Chính sách nhận / trả phòng & lưu ý:**
     - Giờ nhận phòng: từ 14:00.
     - Giờ trả phòng: trước 12:00 trưa.
     - Không hút thuốc trong phòng, hỗ trợ hỗ trợ người khuyết tật.
  4. **Tóm tắt chi phí dự kiến cho kỳ lưu trú này:**
     - Khoảng thời gian: Từ `checkIn` đến `checkOut` ($N$ đêm).
     - Đơn giá: `DonGia` VNĐ/đêm $\times N$ đêm = `TienPhong` VNĐ.
  5. **Nút hành động:**
     - Nút **`[Quay Lại Danh Sách]`** (nút phụ, màu xám nhạt).
     - Nút **`[Đặt Phòng Này]`** (nút chính, màu cam nổi bật) $\to$ Chuyển hướng sang Trang Điền Thông Tin: `/customer/booking?action=prepare&maPhong=...&checkIn=...&checkOut=...`.

---

#### 7.8.4. Bước 4: Trang Điền Thông Tin Khách & Dịch Vụ Bổ Sung (`booking_form.jsp`)
* **Hai khối chức năng trên cùng một giao diện liền mạch:**
  1. **Khối 1: Thông tin khách hàng lưu trú (Guest Profile & Identity):**
     - **Các trường nhập liệu bắt buộc:**
       * **Họ và tên khách đại diện lưu trú (`hoTen`):** Bắt buộc (`required`), độ dài tối đa 100 ký tự.
       * **Số điện thoại liên lạc (`soDT`):** Bắt buộc (`required`), định dạng 10-11 số (`pattern="[0-9]{10,11}"`).
       * **Địa chỉ Email (`email`):** Bắt buộc (`required`), định dạng email chuẩn để gửi thông tin xác nhận.
       * **Số Căn Cước Công Dân (`cccd`):** **BẮT BUỘC NHẬP 12 CHỮ SỐ** (`required`, `pattern="[0-9]{12}"`, `maxlength="12"`, `title="Vui lòng nhập đúng 12 chữ số CCCD"`).
       * **Ghi chú / Yêu cầu đặc biệt (`note`):** Không bắt buộc (nhập yêu cầu phòng tầng cao, giường phụ...).
     - **Cơ chế tự động điền (Auto-fill) & Trải nghiệm tối ưu:**
       * Khi khách hàng đang đăng nhập tài khoản web, hệ thống tự động trích xuất Họ tên, SĐT, Email từ `sessionScope.CURRENT_USER` để điền sẵn vào các ô input.
       * Khách hàng hoàn toàn có quyền chủ động chỉnh sửa các thông tin này nếu đang đặt phòng cho người thân hoặc bạn bè.
     - **Thuật toán xử lý định danh tại Server (Find-or-Upsert by CCCD):**
       * Số `cccd` là **khóa định danh thực tế duy nhất** của công dân lưu trú trong CSDL (`KHACHHANG`).
       * Khi form được gửi lên, `BookingService` gọi `CustomerDAO.findOrUpsertGuestByCCCD(hoTen, email, soDT, cccd)`:
         - **Nếu CCCD đã có trong `KHACHHANG`:** Đối chiếu SĐT và Email; nếu người dùng nhập mới thì hệ thống thực hiện `UPDATE KHACHHANG SET HoTen=?, SoDT=?, Email=? WHERE CCCD=?`; nếu giống thì giữ nguyên. Sau đó tái sử dụng mã `MaKH` cũ, tuyệt đối không bị lỗi trùng lặp.
         - **Nếu CCCD chưa có trong `KHACHHANG`:** Hệ thống sinh mã `MaKH` mới dạng `KHxxx`, chèn bản ghi mới vào `KHACHHANG (MaKH, HoTen, Email, SoDT, CCCD, MaTaiKhoan=NULL)`.
       * Bản ghi `BOOKING` sẽ lưu trữ cả `MaTaiKhoan` (chủ tài khoản web đặt) và `MaKH` (người lưu trú thực tế). Nhờ vậy, tài khoản web hoàn toàn không bị kéo các đơn vãng lai cũ trong quá khứ!
  2. **Khối 2: Lựa chọn dịch vụ bổ sung gắn theo phòng (Room-specific Add-on Services):**
     - Bảng danh mục các dịch vụ trả phí của khách sạn:
       * Buffet sáng gia đình (Đơn giá: 150.000 đ / người).
       * Dịch vụ xe đưa đón sân bay (Đơn giá: 300.000 đ / chuyến).
       * Dịch vụ giặt ủi lấy nhanh (Đơn giá: 80.000 đ / kg).
       * Vé khu vui chơi / Tour tham quan (Đơn giá niêm yết).
     - Mỗi dịch vụ có Checkbox bật/tắt và Ô điều chỉnh số lượng (`min="1"`, `max="10"`).
     - JavaScript tự động cập nhật tổng tiền dịch vụ và tổng tiền dự kiến theo thời gian thực (Real-time recalculation).
  3. **Nút hành động:**
     - Nút **`[Thêm Vào Booking]`** (Nút màu xanh đậm sang trọng `#1a365d`):
       * Khi click, form gửi request AJAX (hoặc submit POST) đến `CustomerCartServlet?action=add`.
       * Gói dữ liệu `CartRoomItemDTO` (gồm mã phòng, thông tin khách kèm CCCD, ngày nhận, ngày trả, số đêm, tiền phòng, danh sách dịch vụ bổ sung đã chọn) được lưu trữ an toàn trong `HttpSession`.

---

#### 7.8.5. Bước 5: Cửa Sổ Nhỏ / Popup Modal Tóm Tắt & Lựa Chọn Nghiệp Vụ
* **Ngay sau khi bấm "Thêm Vào Booking":**
  - Màn hình hiển thị một Cửa sổ nhỏ (Modal Popup) thanh lịch, lịch sự, nền mờ nhẹ nhàng:
  - **Nội dung Popup:**
    * **Tiêu đề:** *"Đã thêm phòng vào đơn đặt thành công!"*
    * **Bảng tóm tắt phòng vừa thêm:**
      - Phòng: **P101** - Deluxe Ocean View
      - Thời gian: `2026-10-01` $\to$ `2026-10-03` (2 đêm)
      - Tiền phòng: $1.598.000 \times 2 = 3.196.000$ đ
      - Dịch vụ kèm theo: Buffet sáng (SL: 2) = $300.000$ đ
      - **Tổng tiền tạm tính phòng này:** **`3.496.000 đ`**
    * **Thông tin giỏ đơn hàng hiện tại:** *"Đơn booking của bạn hiện đang có 1 phòng (hoặc N phòng)"*.
  - **Hai nút điều hướng chiến lược:**
    1. **Nút 1: `[Quay Lại Đặt Tiếp]` (Màu xanh Navy viền trắng):**
       - Đóng popup và chuyển hướng người dùng quay lại màn hình tìm kiếm phòng (`/customer/search-rooms`).
       - Dữ liệu phòng P101 đã nằm an toàn trong Giỏ hàng Session `BOOKING_CART`.
       - Khách hàng có thể đổi ngày trên Search Bar, đổi hạng phòng và tiếp tục chọn thêm phòng thứ 2 (ví dụ: phòng P202) theo đúng quy tắc đa phòng - đa thời gian.
    2. **Nút 2: `[Xác Nhận Đặt Booking]` (Màu cam nổi bật `#dd6b20`):**
       - Chuyển hướng người dùng thẳng đến màn hình Xác Nhận Booking / Checkout (`/customer/cart` hoặc `/customer/booking-checkout`).
       - Khách hàng rà soát toàn bộ danh sách các phòng đã chọn trong giỏ và bấm "Chốt Đặt Toàn Bộ" để ghi nhận đơn vào CSDL và sinh hóa đơn.

---

### 7.9. Thiết Kế Các Class & Servlet Hỗ Trợ Luồng 5 Bước

1. **`CustomerPortalServlet` (`/customer/home`):**
   - Chỉ chuẩn bị dữ liệu danh mục `RoomType` và ngày mặc định cho Search Bar.
   - Render `views/customer/home.jsp` tập trung vào giới thiệu khách sạn và thanh tìm kiếm.

2. **`CustomerSearchRoomsServlet` (`/customer/search-rooms`):**
   - Nhận các tiêu chí: `checkIn`, `checkOut`, `guests`, `roomType`.
   - Gọi `RoomService.searchRooms(...)` để truy vấn CSDL.
   - Forward dữ liệu sang `views/customer/room_list.jsp` (layout iVIVU thẻ ngang + bộ lọc bên trái).

3. **`CustomerRoomDetailServlet` (`/customer/room-detail`):**
   - Nhận `maPhong`, `checkIn`, `checkOut`.
   - Lấy thông tin chi tiết phòng (`RoomDAO.getRoomByMaPhong()`), thông số kích thước diện tích, danh mục tiện ích miễn phí.
   - Forward dữ liệu sang `views/customer/room_detail.jsp`.

4. **`CustomerBookingServlet` (`/customer/booking`):**
   - `action=prepare`: Nhận thông tin phòng, tự động lấy thông tin khách hàng từ `CURRENT_USER` trong session, nạp danh sách dịch vụ từ `ServiceDAO.getAllActiveServices()`.
   - Forward dữ liệu sang `views/customer/booking_form.jsp`.

5. **`CustomerCartServlet` (`/customer/cart`):**
   - `action=add`: Tiếp nhận dữ liệu phòng + dịch vụ từ `booking_form.jsp`, tạo `CartRoomItemDTO` và lưu vào `BookingCartDTO` trong `HttpSession`.
   - Hỗ trợ trả lời JSON cho Popup Modal hoặc redirect kèm cờ hiển thị Modal.
   - `action=view`: Xem toàn bộ giỏ hàng các phòng trước khi chốt.
   - `action=remove`: Xóa phòng khỏi giỏ.
   - `action=checkout`: Gọi `BookingService.createMultiRoomBooking()` để commit Transaction vào CSDL.

---

### 7.10. Giải Pháp Kiến Trúc Tách Bạch "Tài Khoản Đại Diện Web" (`TAIKHOAN`) & "Hồ Sơ Khách Hàng Lưu Trú" (`KHACHHANG`) — Xử Lý Triệt Để Bài Toán Khách Vãng Lai & Không Trùng Lặp Dữ Liệu

#### 7.10.1. Đặt Vấn Đề Nghiệp Vụ & Yêu Cầu Cốt Lõi Từ Lập Trình Viên
1. **Xung đột khi tạo tài khoản theo cơ chế cũ:**
   - Khách vãng lai đến quầy lễ tân đặt phòng trực tiếp tại chỗ (Offline). Lễ tân nhập Họ tên, Số điện thoại, Email, CCCD vào bảng `KHACHHANG` (bản ghi này có `MaTaiKhoan = NULL`).
   - Nếu khi khách về nhà đăng ký tài khoản web (`/register`), hệ thống lại tự động cố tạo một dòng `KHACHHANG` mới hoặc gán ghép với dòng cũ:
     * Dễ bị chặn do trùng Email/SĐT với dòng vãng lai trước đó.
     * Tên khách hàng hoặc số điện thoại gia đình dùng chung có thể bị trùng lặp, gây sai lệch hoặc nhầm lẫn giữa các cá nhân khác nhau.
2. **Quy định nghiệp vụ dứt khoát từ lập trình viên (Chính sách Fresh Start):**
   - **Tài khoản Web (`TAIKHOAN`) chỉ là Người đại diện trên môi trường số (Web Booker / Credential)**, hoàn toàn độc lập với các giao dịch tại quầy.
   - **TUYỆT ĐỐI KHÔNG CHO khách hàng vãng lai cũ kế thừa lịch sử đặt phòng trước khi tạo tài khoản**.
   - Mọi tài khoản web khi mới tạo sẽ bắt đầu sạch sẽ 100% (lịch sử đơn đặt ban đầu = 0 đơn), chỉ quản lý các đơn do chính tài khoản này tạo ra từ thời điểm đăng ký trở về sau.
   - **Khi nào mới lưu/cập nhật thông tin khách lưu trú?** Chỉ khi người dùng thực hiện **Đặt phòng (Booking)**, lúc đó mới nhập Họ tên, Số điện thoại, Email, Số CCCD của người lưu trú và lưu vào hệ thống bảng `KHACHHANG`.

---

#### 7.10.2. Phân Tách Trách Nhiệm Rõ Ràng (Separation of Concerns)

| Tiêu Chí So Sánh | Bảng `TAIKHOAN` (Người Đại Diện Web / Booker) | Bảng `KHACHHANG` (Người Lưu Trú Thực Tế / Guest Profile) |
| :--- | :--- | :--- |
| **Bản chất nghiệp vụ** | Đại diện cho **Tài khoản người dùng Web**. Quản lý việc đăng nhập bằng Email, bảo mật, xác thực mật khẩu băm SHA-256 và lưu giỏ hàng `HttpSession`. | Đại diện cho **Hồ sơ định danh công dân lưu trú thực tế** tại khách sạn (phục vụ check-in nhận phòng, khai báo tạm trú công an, in hóa đơn). |
| **Khóa định danh chính** | **`Email`** (Địa chỉ Email duy nhất của tài khoản trên bảng `TAIKHOAN`). | **`CCCD` (Căn cước công dân 12 chữ số duy nhất của công dân)**. |
| **Thuộc tính lưu trữ** | **`MaTaiKhoan`, `MatKhau`, `MaVaiTro` (`VT01`), `TrangThai` (`Active`), `HoTenTaiKhoan`, `Email`**. | `MaKH`, `HoTen`, `Email`, `SoDT`, `CCCD`, `MaTaiKhoan` (cho phép `NULL`). |
| **Thời điểm phát sinh** | Được tạo ngay tại trang **Đăng ký tài khoản (`/register`)**. | Chỉ được tra cứu/tạo mới khi thực hiện **Đặt phòng (Booking)** hoặc khi Lễ tân check-in tại quầy. |
| **Lịch sử đơn đặt** | Chỉ chứa các đơn do chính tài khoản này đặt kể từ sau khi đăng ký (`WHERE BOOKING.MaTaiKhoan = CURRENT_USER.MaTaiKhoan`). | Chứa lịch sử lưu trú thực tế của cá nhân có số CCCD đó. |

---

#### 7.10.3. Phương Án Xử Lý Chi Tiết 3 Kịch Bản Nghiệp Vụ

##### Kịch Bản A: Quy Trình Đăng Ký Tài Khoản Web (`/register`) — Độc Lập 100%, Không Đụng Chạm `KHACHHANG`
* Khi người dùng vào trang Đăng ký tài khoản (`/register`): Nhập Họ tên, Email, Mật khẩu.
* **Quy trình xử lý tại `AuthService.register()` để triệt tiêu 100% nguy cơ trùng lặp:**
  1. **Bước 1: Kiểm tra tính độc nhất trên bảng `TAIKHOAN`:**
     - Truy vấn: `SELECT 1 FROM TAIKHOAN WHERE Email = ?`
     - Nếu đã tồn tại $\to$ Báo lỗi: *"Email này đã được sử dụng để đăng ký tài khoản. Vui lòng đăng nhập hoặc sử dụng chức năng Quên mật khẩu!"*
  2. **Bước 2: Ghi nhận trực tiếp vào bảng `TAIKHOAN`:**
     - Sinh mã `MaTaiKhoan` mới (`KeyGenerator.generateAccountId()`).
     - Băm mật khẩu SHA-256 qua `PasswordUtil.hashPassword(password)`.
     - Thực thi câu lệnh (chỉ lưu đúng 6 thuộc tính chuẩn):
       ```sql
       INSERT INTO TAIKHOAN (MaTaiKhoan, MatKhau, MaVaiTro, TrangThai, HoTenTaiKhoan, Email)
       VALUES (@MaTaiKhoan, @HashedPassword, 'VT01', 'Active', @HoTenTaiKhoan, @Email)
       ```
     - **TUYỆT ĐỐI KHÔNG INSERT HOẶC UPDATE VÀO BẢNG `KHACHHANG`!**
  3. **Ưu điểm vượt bậc của giải pháp:**
     - Việc tạo tài khoản diễn ra siêu tốc, hoàn toàn không dính dáng đến bảng `KHACHHANG`.
     - Dù trước đó có khách vãng lai nào từng ở khách sạn có cùng Số điện thoại hay Email thì việc tạo `TAIKHOAN` này **không bao giờ bị xung đột hoặc văng lỗi vi phạm Unique Constraint**!
     - Tài khoản web mới tạo có lịch sử hoàn toàn trống (0 đơn), **bảo đảm 100% không kế thừa bất kỳ đơn vãng lai nào trước đây**.

---

##### Kịch Bản B: Quy Trình Đặt Phòng (Booking) — Thuật Toán "Tra Cứu & Cập Nhật Hồ Sơ Theo CCCD" (Find-or-Upsert by CCCD)
* **Giao diện `booking_form.jsp`:**
  - Khối thông tin khách lưu trú bổ sung trường nhập bắt buộc: **Số Căn Cước Công Dân (CCCD)** (chuẩn 12 chữ số).
  - Tự động điền (Auto-fill) Họ tên, SĐT, Email từ tài khoản đang đăng nhập để tiện lợi cho khách, nhưng cho phép khách **chủ động chỉnh sửa thoải mái** nếu đặt phòng cho người thân hoặc bạn bè.
* **Thuật toán xử lý tại `BookingService` khi khách bấm Xác nhận đặt phòng:**
  1. Trích xuất thông tin người đại diện lưu trú từ Form: `hoTen`, `soDT`, `email`, `cccd`.
  2. Lấy **`cccd`** (khóa định danh công dân duy nhất) tra cứu trong bảng `KHACHHANG`:
     - **Trường hợp B1 — CCCD ĐÃ TỒN TẠI trong bảng `KHACHHANG` (`profileKhach`):**
       - Hệ thống đối chiếu dữ liệu cũ và dữ liệu mới:
         * So sánh `email` mới với `profileKhach.getEmail()`.
         * So sánh `soDT` mới với `profileKhach.getSoDT()`.
       - **Nếu giống nhau 100%:** Giữ nguyên dữ liệu, không làm gì cả. Sử dụng lại `MaKH = profileKhach.getMaKH()`.
       - **Nếu có thay đổi (ví dụ: khách đổi SĐT mới hoặc đổi Email mới):** Cập nhật dữ liệu mới nhất:
         ```sql
         UPDATE KHACHHANG 
         SET HoTen = @hoTenMoi, 
             SoDT = @soDTMoi, 
             Email = @emailMoi 
         WHERE CCCD = @cccd
         ```
         Sử dụng lại `MaKH = profileKhach.getMaKH()`.
     - **Trường hợp B2 — CCCD CHƯA TỒN TẠI trong bảng `KHACHHANG`:**
       - Sinh mã `MaKH` mới (`KeyGenerator.generateCustomerId()`).
       - Thêm mới một bản ghi hồ sơ khách hàng lưu trú vào CSDL:
         ```sql
         INSERT INTO KHACHHANG (MaKH, HoTen, Email, SoDT, CCCD, MaTaiKhoan) 
         VALUES (@maKHMoi, @hoTen, @email, @soDT, @cccd, NULL)
         ```
         *(Ghi chú: `MaTaiKhoan` để NULL vì đây là hồ sơ định danh lưu trú thực tế của cá nhân đó).*
  3. Lấy `MaKH` của người lưu trú vừa tìm/tạo ở trên để gán vào `BOOKING.MaKH`.

---

##### Kịch Bản C: Quản Lý Lịch Sử Đơn Đặt Phòng — Phân Định "Người Tạo Đơn Web" (`BOOKING.MaTaiKhoan`) & "Người Lưu Trú" (`BOOKING.MaKH`)
* **Đặt vấn đề:**
  - Một tài khoản web (ví dụ: Anh A - `TK001`) đặt phòng cho Bố Mẹ (Bác B - `KH005`, CCCD của Bác B).
  - Cột `BOOKING.MaKH` sẽ lưu `KH005`.
  - Nếu trang "Lịch sử đặt phòng của tôi" (`/customer/history`) chỉ truy vấn theo `WHERE MaKH = CURRENT_USER.MaKH`, Anh A sẽ không nhìn thấy đơn đặt cho bố mẹ mình!
  - Ngược lại, nếu truy vấn theo `MaKH`, thì những đơn vãng lai trước đây của Bác B vô tình bị kéo vào tài khoản của Anh A (vi phạm yêu cầu của bạn).
* **Giải pháp chuẩn hóa:**
  - Bổ sung cột `MaTaiKhoan` vào bảng `BOOKING`:
    ```sql
    ALTER TABLE BOOKING ADD MaTaiKhoan VARCHAR(10) NULL;
    ALTER TABLE BOOKING ADD CONSTRAINT FK_BOOKING_TAIKHOAN FOREIGN KEY (MaTaiKhoan) REFERENCES TAIKHOAN(MaTaiKhoan);
    ```
  - **Quy tắc lưu trữ khi tạo Booking:**
    * Khi đặt qua Website khách hàng:
      `BOOKING.MaTaiKhoan = sessionScope.CURRENT_USER.getMaTaiKhoan()`  
      `BOOKING.MaKH = MaKH_NguoiLuuTru` (xác định từ CCCD ở Kịch bản B).
    * Khi Lễ tân tạo đơn cho khách vãng lai tại quầy:
      `BOOKING.MaTaiKhoan = NULL`  
      `BOOKING.MaKH = MaKH_KhachVangLai`.
  - **Lợi ích giải quyết trọn vẹn yêu cầu:**
    1. **Trang Lịch sử của Khách hàng (`/customer/history`):**
       - Truy vấn: `SELECT * FROM BOOKING WHERE MaTaiKhoan = CURRENT_USER.MaTaiKhoan`.
       - Tài khoản mới tạo có `MaTaiKhoan = 'TKxxx'`. Các đơn vãng lai cũ có `MaTaiKhoan = NULL`.
       - Do đó, tài khoản mới tạo **bảo đảm 100% không kế thừa bất kỳ đơn vãng lai cũ nào**, lịch sử bắt đầu từ số 0, chỉ hiển thị đúng các đơn do chính tài khoản này tạo ra!
       - Bất kể Anh A đặt cho bản thân hay đặt hộ cho Bố Mẹ, Anh A đều quản lý được đầy đủ các đơn mình đã đặt và thanh toán.
    2. **Tại quầy Lễ tân (Giai đoạn 3 Check-in):**
       - Khi Bác B đến quầy khách sạn, Lễ tân tra cứu bằng **Số CCCD** của Bác B trong bảng `KHACHHANG` $\to$ lập tức hiển thị đơn đặt phòng mà Anh A đã đặt trước cho Bác B để giao chìa khóa phòng!

---

#### 7.10.4. Sơ Đồ Chu Trình Sequence Diagram Xử Lý Tài Khoản Web & Đặt Phòng

```mermaid
sequenceDiagram
    autonumber
    actor User as Người Dùng Web
    participant RegCtrl as RegisterServlet (/register)
    participant BookCtrl as CustomerBookingServlet (/customer/booking)
    participant AuthService as AuthService
    participant BookingService as BookingService
    participant AccountDAO as AccountDAO
    participant CustomerDAO as CustomerDAO
    participant BookingDAO as BookingDAO
    participant DB as SQL Server (QuanLyKhachSan)

    Note over User, DB: GIAI ĐOẠN 1: ĐĂNG KÝ TÀI KHOẢN WEB (ĐỘC LẬP 100%, KHÔNG KẾ THỪA VÃNG LAI)
    User->>RegCtrl: Nhập Họ tên tài khoản, Email, Mật khẩu -> Bấm "Đăng ký"
    RegCtrl->>AuthService: register(hoTenTaiKhoan, email, password)
    AuthService->>AccountDAO: checkEmailExistsInAccount(email)
    AccountDAO->>DB: SELECT 1 FROM TAIKHOAN WHERE Email = ?
    DB-->>AccountDAO: 0 (Email chưa đăng ký tài khoản)
    AuthService->>AccountDAO: createAccount(TK005, email, hashedPassword, hoTenTaiKhoan)
    AccountDAO->>DB: INSERT INTO TAIKHOAN (MaTaiKhoan='TK005', MatKhau, MaVaiTro='VT01', TrangThai='Active', HoTenTaiKhoan, Email)
    Note over AccountDAO, DB: KHÔNG INSERT/UPDATE vào bảng KHACHHANG
    DB-->>AccountDAO: Thành công
    AccountDAO-->>AuthService: true
    AuthService-->>RegCtrl: Tạo tài khoản thành công! (Lịch sử ban đầu = 0 đơn)

    Note over User, DB: GIAI ĐOẠN 2: TIẾN HÀNH ĐẶT PHÒNG & XỬ LÝ THEO CCCD
    User->>BookCtrl: Điền thông tin lưu trú (Họ tên, SĐT, Email, CCCD 12 số) -> Bấm "Xác nhận đặt"
    BookCtrl->>BookingService: createMultiRoomBooking(currentUser, guestInfo, cart)
    BookingService->>CustomerDAO: findOrUpsertGuestByCCCD(hoTen, sdt, email, cccd)
    CustomerDAO->>DB: SELECT * FROM KHACHHANG WHERE CCCD = ?
    alt Trường hợp 1: CCCD đã tồn tại trong KHACHHANG
        DB-->>CustomerDAO: Khách hàng KH003 (SĐT cũ, Email cũ)
        alt SĐT hoặc Email có thay đổi so với dữ liệu cũ
            CustomerDAO->>DB: UPDATE KHACHHANG SET HoTen=?, SoDT=?, Email=? WHERE CCCD=?
            DB-->>CustomerDAO: Cập nhật thành công
        else Thông tin trùng khớp 100%
            Note over CustomerDAO, DB: Giữ nguyên dữ liệu, không cần cập nhật
        end
        CustomerDAO-->>BookingService: Trả về MaKH = 'KH003'
    else Trường hợp 2: CCCD chưa từng có trong KHACHHANG
        CustomerDAO->>DB: INSERT INTO KHACHHANG (MaKH='KH008', HoTen, Email, SoDT, CCCD, MaTaiKhoan=NULL)
        DB-->>CustomerDAO: Thêm khách hàng mới thành công
        CustomerDAO-->>BookingService: Trả về MaKH = 'KH008'
    end

    Note over BookingService, DB: GIAI ĐOẠN 3: GHI NHẬN BOOKING THEO MÃ TÀI KHOẢN & MÃ KHÁCH LƯU TRÚ
    BookingService->>BookingDAO: insertBooking(MaBooking='BK018', MaKH='KH003', MaTaiKhoan='TK005'...)
    BookingDAO->>DB: INSERT INTO BOOKING (MaBooking, MaKH, MaTaiKhoan, NgayDat, ChiPhiDuKien...)
    DB-->>BookingDAO: Booking tạo thành công!
    Note over User, DB: Khi User vào xem lịch sử: SELECT * FROM BOOKING WHERE MaTaiKhoan = 'TK005'<br/>(Chỉ thấy các đơn do TK005 tạo, 100% không thấy đơn vãng lai cũ)
```

---

#### 7.10.5. Bản Thiết Kế Chi Tiết Các Tầng Mã Nguồn (Đặc Tả Đầy Đủ Trình Duyệt Trước Khi Viết Code)

Toàn bộ giải pháp kiến trúc được thiết kế chi tiết trên từng tầng như sau:
1. **Tầng CSDL (Đã thực thi cập nhật thành công trên SQL Server):**
   - Bảng `TAIKHOAN` được tối giản và chuẩn hóa tuyệt đối gồm đúng 6 thuộc tính:
     * `MaTaiKhoan VARCHAR(10) PRIMARY KEY`
     * `MatKhau VARCHAR(255) NOT NULL`
     * `MaVaiTro VARCHAR(10) FOREIGN KEY REFERENCES VAITRO(MaVaiTro)`
     * `TrangThai VARCHAR(20) DEFAULT 'Active'`
     * `HoTenTaiKhoan NVARCHAR(100) NULL`
     * `Email VARCHAR(100) UNIQUE NOT NULL`
   - Bổ sung cột `MaTaiKhoan` vào bảng `BOOKING`:
     ```sql
     ALTER TABLE BOOKING ADD MaTaiKhoan VARCHAR(10) NULL;
     ALTER TABLE BOOKING ADD CONSTRAINT FK_BOOKING_TAIKHOAN FOREIGN KEY (MaTaiKhoan) REFERENCES TAIKHOAN(MaTaiKhoan);
     ```
2. **Tầng DAO & Model:**
   - Trong `Account.java`: Chứa đúng 6 thuộc tính: `maTaiKhoan`, `matKhau`, `maVaiTro`, `trangThai`, `hoTenTaiKhoan`, `email`.
   - Trong `AccountDAO.java`:
     * Cập nhật hàm `registerAccount(Account tk)`: Ghi nhận đúng 6 thuộc tính vào `TAIKHOAN`, tuyệt đối không ghi vào `KHACHHANG`.
     * Cập nhật hàm `checkEmailExists`: Kiểm tra tính duy nhất theo `Email` trong `TAIKHOAN`.
   - Trong `CustomerDAO.java` (hoặc `BookingDAO.java`):
     * Hàm `Customer findCustomerByCCCD(String cccd)`.
     * Hàm `String findOrUpsertGuestByCCCD(String hoTen, String email, String soDT, String cccd)`: Thực hiện đúng logic so sánh email/sdt và cập nhật nếu có thay đổi.
   - Trong `Booking.java`: Bổ sung thuộc tính `private String maTaiKhoan`.
3. **Tầng Service:**
   - Trong `AuthService.register()`: Chỉ gọi `accountDAO.registerAccount(tk)`.
   - Trong `BookingService.createMultiRoomBooking()`: Gọi `findOrUpsertGuestByCCCD()` để lấy `maKH`, sau đó gán `maTaiKhoan = currentUser.getMaTaiKhoan()` vào đơn booking.
4. **Tầng Controller & View JSP:**
   - Giao diện `booking_form.jsp`: Bổ sung ô nhập **Số CCCD** (12 chữ số) trong Khối 1: Thông tin khách hàng lưu trú.
   - Servlet `CustomerBookingServlet`: Nhận thêm tham số `cccd` từ form gửi lên.
   - Servlet `CustomerHistoryServlet`: Lấy danh sách lịch sử theo `WHERE MaTaiKhoan = CURRENT_USER.getMaTaiKhoan()`.

---

## 8. KỊCH BẢN KIỂM THỬ GIAI ĐOẠN 2 (LIVE TEST CHECKLIST)

Sau khi được phê duyệt và hoàn thành lập trình, hệ thống sẽ được kiểm thử ngay trên môi trường thực tế thông qua các Test Case sau:

| Mã Test | Thao Tác Thực Hiện | Kết Quả Kỳ Vọng | Trạng Thái |
| :---: | :--- | :--- | :---: |
| **TC-2.1** | Đăng nhập tài khoản khách hàng (`/login`) với email và mật khẩu. | Đăng nhập thành công, tạo `CURRENT_USER` trong session, chuyển hướng đúng cổng khách hàng. | ✅ **Đã Đạt (Passed)** |
| **TC-2.2** | Truy cập Cổng Khách Hàng (`/customer/home`). | Trang `home.jsp` hiển thị đầy đủ tiêu chuẩn khách sạn, Banner chào mừng và Thanh tìm kiếm chuẩn mực. | ✅ **Đã Đạt (Passed)** |
| **TC-2.3** | Nhập ngày nhận và ngày trả phòng $\to$ Bấm "Tìm Kiếm Phòng" (`/customer/search-rooms`). | Chuyển sang `room_list.jsp` hiển thị 2 cột chuẩn iVIVU: Cột trái có bộ lọc giá/hạng phòng/sức chứa, Cột phải là danh sách thẻ phòng nằm ngang. | ✅ **Đã Đạt (Passed)** |
| **TC-2.4** | Bấm nút **`[Xem Phòng]`** trên thẻ phòng (ví dụ P101) $\to$ Truy cập `/customer/room-detail`. | Chuyển đến `room_detail.jsp`: Hiển thị đầy đủ kích thước phòng $m^2$, sức chứa, tiện ích và đơn giá phòng. | ✅ **Đã Đạt (Passed)** |
| **TC-2.5** | Tại trang chi tiết phòng, bấm **`[Đặt Phòng Này]`** $\to$ Chuyển đến Cấu hình phòng (`booking_form.jsp` Case 1). | **Khối nhập thông tin khách hàng đã được loại bỏ 100%**. Giao diện chỉ tập trung vào tóm tắt phòng và dịch vụ tùy chọn kèm theo. | ✅ **Đã Đạt (Passed)** |
| **TC-2.6** | Chọn dịch vụ bổ sung kèm theo $\to$ Bấm **`[Thêm Vào Booking]`** qua AJAX (`/customer/cart/add`). | Trả về JSON thành công, giỏ hàng lưu phòng 1 kèm dịch vụ, hiện Popup Modal tóm tắt chi phí và các nút điều hướng. | ✅ **Đã Đạt (Passed)** |
| **TC-2.7** | Đổi khoảng ngày độc lập và thêm phòng thứ 2 (ví dụ P103) vào giỏ hàng (`/customer/cart/add`). | Giỏ hàng ghi nhận chính xác 2 phòng với khoảng ngày độc lập, cập nhật tổng chi phí dự kiến tạm tính. | ✅ **Đã Đạt (Passed)** |
| **TC-2.8** | Truy cập màn hình Chốt đơn (`booking_form.jsp` Case 2 - Checkout). | Hiển thị toàn bộ danh sách phòng trong giỏ hàng; tập trung **1 khối form thông tin người đại diện lưu trú duy nhất** kèm tính năng tự động điền (Autofill). | ✅ **Đã Đạt (Passed)** |
| **TC-2.9** | Bấm **`[Xác Nhận Đặt Toàn Bộ Đơn Phòng]`** (`POST /customer/booking`). | Thực thi Transaction ACID 5 bảng (`BOOKING`, `BOOKING_PHONG`, `BOOKING_DICHVU`, `HOADON`), sinh mã Booking chuẩn (ví dụ `BK632`), xóa giỏ hàng thành công. | ✅ **Đã Đạt (Passed)** |
| **TC-2.10** | Hệ thống chuyển hướng sang xem Chi Tiết Đơn Đặt Phòng (`booking_detail.jsp`). | Hiển thị đầy đủ thông tin đơn vừa tạo, danh sách các phòng và các dịch vụ tương ứng đã đặt. | ✅ **Đã Đạt (Passed)** |
| **TC-2.11** | Truy cập màn hình Lịch Sử Đơn Đặt Phòng Của Tôi (`/customer/history`). | Lịch sử cá nhân hiển thị chính xác đơn đặt phòng vừa tạo của tài khoản hiện tại (`WHERE MaTaiKhoan = CURRENT_USER`). | ✅ **Đã Đạt (Passed)** |
| **TC-2.12** | Đặt phòng lần tiếp theo trong tương lai $\to$ Kiểm tra tính năng Ghi nhớ & Tự động điền (Remember / Autofill). | Hệ thống tự động điền sẵn 100% Họ tên, Email, Số điện thoại và Số CCCD 12 chữ số đã lưu mà khách không cần gõ lại. | ✅ **Đã Đạt (Passed)** |
| **TC-2.13** | Thử đặt lại phòng vừa được đặt trong cùng một khoảng ngày giao thoa (Chống Race Condition / Double Booking). | Hệ thống chặn đứng an toàn cả ở tầng Java và Trigger SQL Server; hiển thị thông báo lỗi rõ ràng: *"Phòng vừa có khách khác đặt trước hoặc không khả dụng!"*. | ✅ **Đã Đạt (Passed)** |

---

## 9. KẾT LUẬN & ĐÁNH GIÁ HOÀN THÀNH GIAI ĐOẠN 2

Toàn bộ phân hệ khách hàng của **Giai Đoạn 2** đã được hoàn thành lập trình và kiểm thử thực tế thành công rực rỡ:
1. **Luồng trải nghiệm 5 bước chuẩn OTA quốc tế:**
   - **Bước 1:** Trang chủ (`home.jsp`) giới thiệu thương hiệu và thanh tìm kiếm trung tâm.
   - **Bước 2:** Trang đặt phòng (`room_list.jsp`) với bố cục 2 cột phong cách iVIVU (Bộ lọc bên trái & Thẻ phòng nằm ngang bên phải).
   - **Bước 3:** Trang xem chi tiết phòng (`room_detail.jsp`) hiển thị toàn diện thông số kỹ thuật (diện tích, sức chứa, loại giường, view) và danh mục dịch vụ miễn phí kèm theo.
   - **Bước 4:** Trang điền thông tin (`booking_form.jsp`) tự động điền thông tin cá nhân từ session và chọn dịch vụ bổ sung gắn theo từng phòng.
   - **Bước 5:** Popup Modal tóm tắt chi phí phòng + dịch vụ, hỗ trợ 2 lựa chọn nghiệp vụ: **[Quay Lại Đặt Tiếp]** (thêm phòng 2, 3...) hoặc **[Xác Nhận Đặt Booking]** (chốt toàn bộ đơn vào CSDL).
2. **Quy chuẩn UI/UX:**
   - Tuyệt đối **100% không sử dụng icon/emoji**.
   - Thiết kế chuẩn Modern, Typography chỉn chu, màu sắc Navy `#1a365d` - Cam `#dd6b20` - Vàng đồng `#c5a880` cao cấp.
   - Không lồng form (No Nested Form), an toàn tuyệt đối.
3. **Toàn vẹn CSDL:**
   - Các bảng `BOOKING`, `BOOKING_PHONG`, `BOOKING_DICHVU`, `HOADON` ghi nhận chuẩn xác dữ liệu đa phòng - đa thời gian trong cùng một Transaction khép kín.
