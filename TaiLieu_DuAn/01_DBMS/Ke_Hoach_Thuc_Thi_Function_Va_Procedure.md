# KẾ HOẠCH CHI TIẾT THỰC THI HỆ THỐNG FUNCTION & STORED PROCEDURE
**Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10  
**Môn học:** Hệ Quản Trị Cơ Sở Dữ Liệu (DBMS330284) — Trường ĐH Sư Phạm Kỹ Thuật TP.HCM (HCMUTE)  
**Tiêu chuẩn định dạng:** Tiếng Việt UTF-8 chuẩn, giao diện văn bản rõ ràng, dễ đọc

---

## MỤC LỤC

1. NGUYÊN TẮC THIẾT KẾ FUNCTION & STORED PROCEDURE
2. DANH SÁCH Ý TƯỞNG CÁC FUNCTION (HÀM TÍNH TOÁN & TRA CỨU)
   - Function 1: Tính tiền phòng của đơn đặt phòng (fn_TinhTienPhongBooking)
   - Function 2: Tính tiền dịch vụ phát sinh của đơn đặt phòng (fn_TinhTienDichVuBooking)
   - Function 3: Tính tổng tiền thực tế phải thanh toán (fn_TinhTongTienThucTePhaiTra)
   - Function 4: Kiểm tra nhanh phòng có trống trong khoảng thời gian không (fn_KiemTraPhongTrongTrongKhoang)
   - Function 5: Tra cứu danh sách phòng trống theo ngày và loại phòng (fn_TraCuuPhongTrongTheoYeuCau)
   - Function 6: Xem lịch sử đặt phòng của một khách hàng (fn_LichSuDatPhongKhachHang)
   - Function 7: Thống kê doanh thu trong một khoảng thời gian tùy chọn (fn_DoanhThuTheoKhoangThoiGian)
3. DANH SÁCH Ý TƯỞNG CÁC STORED PROCEDURE (THỦ TỤC NGHIỆP VỤ)
   - Procedure 1: Đặt phòng trực tuyến cho khách hàng (sp_TaoDonDatPhongOnline)
   - Procedure 2: Thủ tục Check-in nhận phòng tại quầy (sp_CheckInNhanPhong)
   - Procedure 3: Gọi thêm dịch vụ gia tăng vào phòng (sp_GoiThemDichVu)
   - Procedure 4: Quyết toán hóa đơn và Check-out trả phòng (sp_QuyetToanVaCheckOut)
   - Procedure 5: Ghi nhận thanh toán và đặt cọc (sp_GhiNhanThanhToan)
   - Procedure 6: Quy trình buồng phòng nhận và hoàn thành dọn phòng (sp_CapNhatTienDoDonPhong)
   - Procedure 7: Báo cáo tổng kết kinh doanh chốt ca theo ngày (sp_BaoCaoTongHopKinhDoanhTheoNgay)
   - Procedure 8: Báo cáo tổng kết kinh doanh tháng (sp_BaoCaoTongHopKinhDoanhThang)
4. BẢNG TỔNG HỢP VAI TRÒ & ĐỐI TƯỢNG SỬ DỤNG

---

## 1. NGUYÊN TẮC THIẾT KẾ FUNCTION & STORED PROCEDURE

1. **Phân định rạch ròi giữa Function (Hàm) và Stored Procedure (Thủ tục):**
   * **Function (Hàm):** 
     - Chỉ dùng để **tính toán giá trị** (Scalar Function) hoặc **tra cứu dữ liệu** trả về bảng (Table-Valued Function).
     - Tuyệt đối không thay đổi trạng thái dữ liệu (không chứa `INSERT`, `UPDATE`, `DELETE`).
     - Được gọi trực tiếp bên trong các câu lệnh `SELECT`, `WHERE`, `JOIN` của Backend Java Servlet hoặc lồng bên trong Stored Procedure.
   * **Stored Procedure (Thủ tục):** 
     - Dùng để **thực thi các chu trình nghiệp vụ hoàn chỉnh** làm thay đổi dữ liệu (tạo booking, check-in, check-out, thanh toán tiền).
     - Bắt buộc tích hợp xử lý lỗi với khối `BEGIN TRY ... BEGIN CATCH`.
     - Sử dụng tham số đầu ra (`OUTPUT`) và giá trị trả về (`RETURN`) để Backend Java Servlet dễ dàng nhận biết kết quả thành công hay thất bại.
2. **Tuân thủ đúng nghiệp vụ đã thống nhất:**
   * Quản lý theo **Người đại diện đặt phòng (Chủ đơn)**, không đếm đầu người.
   * Thực hiện theo **Phương án A (1 Booking — 1 Hóa đơn duy nhất)**.
   * Chặn hoàn toàn việc đặt hoặc check-in phòng đang `Dirty`, `Cleaning` hoặc `Damaged`.

---

## 2. DANH SÁCH Ý TƯỞNG CÁC FUNCTION (HÀM)

---

### Function 1: Tính tiền phòng của đơn đặt phòng (`fn_TinhTienPhongBooking`)
* **Loại hàm:** Scalar Function (Trả về giá trị số thực `DECIMAL(18,2)`).
* **Mục đích nghiệp vụ:** Tính tổng tiền phòng của toàn bộ các phòng trong 1 booking dựa trên số đêm lưu trú thực tế hoặc dự kiến nhân với đơn giá mỗi đêm (`DonGiaPhong`).
* **Đặc tả logic (Tách rời các bước xử lý):**
  - **Bước 1 (Xác định ngày trả phòng):** Nếu khách đã check-out thì lấy ngày check-out thực tế; nếu khách chưa check-out thì lấy ngày trả phòng dự kiến.
  - **Bước 2 (Tính số đêm lưu trú):** `DATEDIFF(DAY, NgayNhan, NgayTra)`. Nếu nhận và trả trong cùng một ngày thì tính tối thiểu là 1 đêm.
  - **Bước 3 (Tính tiền từng phòng và cộng dồn):** Tổng tiền phòng = `SUM(DonGiaPhong * SoDem)`.
  - **Bước 4 (Xử lý giá trị rỗng):** Nếu booking không có phòng hoặc kết quả trả về `NULL` thì quy về 0.
* **Đoạn mã T-SQL đề xuất (Đã tách rời các khối để dễ đọc):**

```sql
CREATE OR ALTER FUNCTION fn_TinhTienPhongBooking (@MaBooking VARCHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTienPhong DECIMAL(18,2) = 0;

    -- Bước 1: Tách riêng việc xác định ngày kết thúc lưu trú
    ;WITH BangXacDinhNgay AS (
        SELECT 
            bp.DonGiaPhong,
            bp.NgayNhanDuKien,
            -- Ưu tiên ngày check-out thực tế, nếu chưa check-out thì dùng ngày trả dự kiến
            ISNULL(CAST(bp.NgayCheckOutThucTe AS DATE), bp.NgayTraDuKien) AS NgayKetThuc
        FROM BOOKING_PHONG bp
        WHERE bp.MaBooking = @MaBooking
    ),
    -- Bước 2: Tách riêng việc tính số đêm lưu trú (tối thiểu là 1 đêm nếu ở cùng ngày)
    BangTinhSoDem AS (
        SELECT 
            DonGiaPhong,
            CASE 
                WHEN DATEDIFF(DAY, NgayNhanDuKien, NgayKetThuc) <= 0 THEN 1
                ELSE DATEDIFF(DAY, NgayNhanDuKien, NgayKetThuc)
            END AS SoDem
        FROM BangXacDinhNgay
    )
    -- Bước 3: Tính tổng tiền phòng = Đơn giá mỗi đêm * Số đêm
    SELECT @TongTienPhong = SUM(DonGiaPhong * SoDem)
    FROM BangTinhSoDem;

    -- Bước 4: Tách riêng xử lý NULL, nếu không có bản ghi nào thì trả về 0
    IF @TongTienPhong IS NULL
        SET @TongTienPhong = 0;

    RETURN @TongTienPhong;
END;
GO
```

---

### Function 2: Tính tiền dịch vụ phát sinh (`fn_TinhTienDichVuBooking`)
* **Loại hàm:** Scalar Function (Trả về giá trị `DECIMAL(18,2)`).
* **Mục đích nghiệp vụ:** Tính tổng chi phí tất cả các dịch vụ gia tăng (Buffet sáng, giặt ủi, nước ngọt mini-bar, vé spa...) mà khách đã gọi thêm trong suốt kỳ nghỉ.
* **Đặc tả logic:** `SUM(DonGia * SoLuong)` từ bảng `BOOKING_DICHVU` theo `@MaBooking`. Nếu khách không dùng dịch vụ nào thì trả về 0.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE OR ALTER FUNCTION fn_TinhTienDichVuBooking (@MaBooking VARCHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTienDichVu DECIMAL(18,2) = 0;

    SELECT @TongTienDichVu = ISNULL(SUM(bdv.DonGia * bdv.SoLuong), 0)
    FROM BOOKING_DICHVU bdv
    WHERE bdv.MaBooking = @MaBooking;

    RETURN @TongTienDichVu;
END;
GO
```

---

### Function 3: Tính tổng tiền thực tế phải thanh toán (`fn_TinhTongTienThucTePhaiTra`)
* **Loại hàm:** Scalar Function (Trả về `DECIMAL(18,2)`).
* **Mục đích nghiệp vụ:** Kết hợp cả 2 hàm trên để tính ra con số thanh toán cuối cùng của đơn đặt phòng: `Tiền phòng + Tiền dịch vụ`. Dùng để chốt số liệu khi Lễ tân in hóa đơn quyết toán.
* **Đặc tả logic:** Gọi lồng `fn_TinhTienPhongBooking(@MaBooking) + fn_TinhTienDichVuBooking(@MaBooking)`.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE OR ALTER FUNCTION fn_TinhTongTienThucTePhaiTra (@MaBooking VARCHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN dbo.fn_TinhTienPhongBooking(@MaBooking) + dbo.fn_TinhTienDichVuBooking(@MaBooking);
END;
GO
```

---

### Function 4: Kiểm tra phòng trống trong khoảng thời gian (`fn_KiemTraPhongTrongTrongKhoang`)
* **Loại hàm:** Scalar Function (Trả về `BIT`: 1 = Khả dụng, 0 = Không khả dụng).
* **Mục đích nghiệp vụ:** Cho phép Backend kiểm tra tức thời xem phòng X có đón được khách từ ngày A đến ngày B hay không (phòng phải không bị trùng lịch và trạng thái hiện tại không được là Dirty, Cleaning hay Damaged).
* **Tham số đầu vào:**
  - `@MaPhong VARCHAR(10)`: Mã phòng cần kiểm tra.
  - `@NgayNhan DATE`: Ngày bắt đầu nhận phòng.
  - `@NgayTra DATE`: Ngày dự kiến trả phòng.
  - `@MaBookingBoQua VARCHAR(10) = NULL`: Mã booking cần bỏ qua khi đối soát lịch (Mặc định là NULL).
* **Giải thích chi tiết ý nghĩa của tham số `@MaBookingBoQua`:**
  - **Mục đích cốt lõi:** Tránh lỗi **"tự va chạm với chính mình" (Self-Collision)** khi khách hàng hoặc lễ tân thực hiện đổi lịch hoặc gia hạn ngày ở cho một đơn đã đặt trước đó.
  - **Trường hợp 1 (Đặt phòng mới - INSERT):** Truyền `@MaBookingBoQua = NULL`. Hàm sẽ đối soát với tất cả các đơn đặt phòng đang có hiệu lực trong toàn khách sạn.
  - **Trường hợp 2 (Đổi ngày / Gia hạn thêm ngày ở - UPDATE):** Ví dụ đơn `BK001` đang đặt phòng `P101` từ ngày 01/10 đến 05/10. Nay khách muốn ở thêm đến 07/10. Nếu kiểm tra bình thường, hệ thống sẽ thấy phòng `P101` từ 01/10 đến 05/10 đã có người đặt rồi (chính là `BK001`) và báo trùng lịch sai. Bằng cách truyền `@MaBookingBoQua = 'BK001'`, hàm sẽ bỏ qua chính đơn `BK001`, chỉ kiểm tra xem khoảng thời gian gia hạn mới (05/10 - 07/10) có bị vị khách nào khác đặt chen vào hay không.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE OR ALTER FUNCTION fn_KiemTraPhongTrongTrongKhoang (
    @MaPhong VARCHAR(10),
    @NgayNhan DATE,
    @NgayTra DATE,
    @MaBookingBoQua VARCHAR(10) = NULL
)
RETURNS BIT
AS
BEGIN
    -- 1. Nếu phòng đang bẩn, đang dọn hoặc bị hư hỏng thì không thể sử dụng
    IF EXISTS (SELECT 1 FROM PHONG WHERE MaPhong = @MaPhong AND TrangThai IN ('Dirty', 'Cleaning', 'Damaged'))
        RETURN 0;

    -- 2. Kiểm tra có bị trùng lịch với booking khác đang có hiệu lực hay không
    IF EXISTS (
        SELECT 1
        FROM BOOKING_PHONG bp
        INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking
        WHERE bp.MaPhong = @MaPhong
          -- Bỏ qua chính mã booking đang được sửa đổi (nếu có) để tránh tự trùng với chính mình
          AND (@MaBookingBoQua IS NULL OR bp.MaBooking <> @MaBookingBoQua)
          AND b.TrangThai IN ('DaXacNhan', 'DaCheckIn')
          AND NOT (bp.NgayTraDuKien <= @NgayNhan OR bp.NgayNhanDuKien >= @NgayTra)
    )
        RETURN 0;

    RETURN 1; -- Phòng trống hoàn toàn và sẵn sàng phục vụ
END;
GO
```

---

### Function 5: Tra cứu phòng trống theo yêu cầu (`fn_TraCuuPhongTrongTheoYeuCau`)
* **Loại hàm:** Inline Table-Valued Function (Trả về bảng danh sách phòng).
* **Mục đích nghiệp vụ:** Phục vụ trực tiếp thanh tìm kiếm (**Search Bar**) trên giao diện Web ReactJS: Khách hàng chọn ngày nhận, ngày trả, có thể lọc theo loại phòng và **sức chứa số lượng người**. Hàm trả về danh sách các phòng thực sự sẵn sàng đón khách.
* **Tham số đầu vào:**
  - `@NgayNhan DATE`: Ngày nhận phòng dự kiến.
  - `@NgayTra DATE`: Ngày trả phòng dự kiến.
  - `@SoNguoi INT = NULL`: Số lượng người lưu trú cần tìm (Mặc định NULL = không lọc theo sức chứa).
  - `@MaLoaiPhong VARCHAR(10) = NULL`: Mã hạng phòng cần tìm (Mặc định NULL = tìm tất cả các hạng phòng).
* **Giải thích logic lọc theo sức chứa (`lp.SoNguoiToiDa >= @SoNguoi`):**
  - Sử dụng toán tử lớn hơn hoặc bằng (`>=`): Nếu khách đi nhóm 2 người, hàm sẽ hiển thị các phòng có sức chứa từ 2 người trở lên (phòng 2 người, 3 người, 4 người đều đủ chỗ ở). Những phòng đơn chỉ chứa tối đa 1 người sẽ tự động bị loại bỏ.
  - Nếu khách không nhập số người (`@SoNguoi IS NULL`): Điều kiện tự động bỏ qua, hiển thị tất cả các phòng thỏa mãn ngày ở.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE OR ALTER FUNCTION fn_TraCuuPhongTrongTheoYeuCau (
    @NgayNhan DATE,
    @NgayTra DATE,
    @SoNguoi INT = NULL,
    @MaLoaiPhong VARCHAR(10) = NULL
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.MaPhong,
        p.SoPhong,
        lp.MaLoaiPhong,
        lp.TenLoaiPhong,
        lp.DienTich,
        lp.LoaiGiuong,
        lp.SoNguoiToiDa,
        lp.GiaPhong,
        p.MoTa
    FROM PHONG p
    INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
    WHERE (@MaLoaiPhong IS NULL OR p.MaLoaiPhong = @MaLoaiPhong)
      AND (@SoNguoi IS NULL OR lp.SoNguoiToiDa >= @SoNguoi)
      AND p.TrangThai NOT IN ('Dirty', 'Cleaning', 'Damaged')
      AND lp.TrangThai = 'ApDung'
      AND dbo.fn_KiemTraPhongTrongTrongKhoang(p.MaPhong, @NgayNhan, @NgayTra, NULL) = 1
);
GO
```

---

### Function 6: Xem lịch sử đặt phòng của khách hàng (`fn_LichSuDatPhongKhachHang`)
* **Loại hàm:** Inline Table-Valued Function.
* **Mục đích nghiệp vụ:** Hiển thị trang cá nhân "Lịch sử đặt phòng" của khách hàng đại diện: Bao gồm mã đơn, ngày đặt, trạng thái đơn, tổng tiền dự kiến và mã hóa đơn liên kết.
* **Tham số:** `@MaKH VARCHAR(10)`.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE OR ALTER FUNCTION fn_LichSuDatPhongKhachHang (@MaKH VARCHAR(10))
RETURNS TABLE
AS
RETURN (
    SELECT 
        b.MaBooking,
        b.NgayDat,
        b.ChiPhiDuKien,
        b.TrangThai AS TrangThaiBooking,
        hd.MaHoaDon,
        hd.TongTienCuoiCung,
        hd.TrangThai AS TrangThaiHoaDon
    FROM BOOKING b
    LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking
    WHERE b.MaKH = @MaKH
);
GO
```

---

### Function 7: Thống kê doanh thu theo khoảng thời gian tùy chọn (`fn_DoanhThuTheoKhoangThoiGian`)
* **Loại hàm:** Scalar Function (Trả về `DECIMAL(18,2)`).
* **Mục đích nghiệp vụ:** Phục vụ báo cáo tùy biến cho Quản lý (Ví dụ: xem doanh thu tuần lễ tết, dịp lễ 30/4 - 1/5...).
* **Tham số:** `@TuNgay DATETIME, @DenNgay DATETIME`.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE OR ALTER FUNCTION fn_DoanhThuTheoKhoangThoiGian (
    @TuNgay DATETIME,
    @DenNgay DATETIME
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongThu DECIMAL(18,2) = 0;

    SELECT @TongThu = ISNULL(SUM(SoTien), 0)
    FROM THANHTOAN
    WHERE ThoiDiemThanhToan BETWEEN @TuNgay AND @DenNgay;

    RETURN @TongThu;
END;
GO
```

---

---

## 3. DANH SÁCH Ý TƯỞNG CÁC STORED PROCEDURE (THỦ TỤC NGHIỆP VỤ)

---

### Procedure 1: Đặt phòng trực tuyến (`sp_TaoDonDatPhongOnline`)
* **Mục đích:** Quy trình tạo mới một đơn đặt phòng từ Web:
  1. Kiểm tra khách hàng có tồn tại không.
  2. Kiểm tra tính khả dụng của phòng định đặt.
  3. Tạo mới bản ghi trong `BOOKING` và `BOOKING_PHONG`.
  4. Trigger `trg_TuDongTaoHoaDonKhiDatPhong` sẽ tự động sinh hóa đơn tổng tương ứng theo Phương án A.
* **Tham số:** 
  - `@MaKH VARCHAR(10)`
  - `@MaPhong VARCHAR(10)`
  - `@NgayNhan DATE`
  - `@NgayTra DATE`
  - `@PhuongPhapBooking VARCHAR(10)` ('Online' hoặc 'Offline', mặc định 'Online')
  - `@MaBookingMoi VARCHAR(20) OUTPUT`
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_TaoDonDatPhongOnline
    @MaKH VARCHAR(10),
    @MaPhong VARCHAR(10),
    @NgayNhan DATE,
    @NgayTra DATE,
    @PhuongPhapBooking VARCHAR(10) = 'Online', -- 'Online' hoặc 'Offline'
    @MaBookingMoi VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra ngày hợp lệ
        IF @NgayNhan >= @NgayTra OR @NgayNhan < CAST(GETDATE() AS DATE)
        BEGIN
            RAISERROR(N'Ngày nhận và trả phòng không hợp lệ!', 16, 1);
            RETURN -1;
        END

        -- 2. Kiểm tra khách hàng tồn tại
        IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
        BEGIN
            RAISERROR(N'Không tìm thấy thông tin khách hàng đại diện!', 16, 1);
            RETURN -2;
        END

        -- 3. Kiểm tra phòng có trống không bằng hàm fn_KiemTraPhongTrongTrongKhoang
        IF dbo.fn_KiemTraPhongTrongTrongKhoang(@MaPhong, @NgayNhan, @NgayTra, NULL) = 0
        BEGIN
            RAISERROR(N'Phòng đã chọn hiện không khả dụng trong khoảng thời gian này!', 16, 1);
            RETURN -3;
        END

        -- 4. Lấy giá niêm yết của phòng
        DECLARE @GiaPhong DECIMAL(18,2);
        SELECT @GiaPhong = lp.GiaPhong
        FROM PHONG p
        INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
        WHERE p.MaPhong = @MaPhong;

        DECLARE @SoDem INT = DATEDIFF(DAY, @NgayNhan, @NgayTra);
        IF @SoDem <= 0 SET @SoDem = 1;
        DECLARE @ChiPhiDuKien DECIMAL(18,2) = @GiaPhong * @SoDem;

        -- 5. Sinh mã Booking mới (tiền tố BK_ + 7 ký tự UUID = 10 ký tự)
        SET @MaBookingMoi = 'BK_' + SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 7);

        -- 6. Chèn vào bảng BOOKING và BOOKING_PHONG trong Transaction
        BEGIN TRANSACTION;

        INSERT INTO BOOKING (MaBooking, MaKH, NgayDat, ChiPhiDuKien, TrangThai, MaNV, PhuongPhapBooking)
        VALUES (@MaBookingMoi, @MaKH, GETDATE(), @ChiPhiDuKien, 'DaXacNhan', NULL, @PhuongPhapBooking);

        INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien, NgayCheckInThucTe, NgayCheckOutThucTe)
        VALUES (@MaBookingMoi, @MaPhong, @GiaPhong, @NgayNhan, @NgayTra, NULL, NULL);

        COMMIT TRANSACTION;
        RETURN 0; -- Thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO
```

---

### Procedure 2: Thủ tục Check-in nhận phòng tại quầy (`sp_CheckInNhanPhong`)
* **Mục đích:** Khi khách hàng đến khách sạn, Lễ tân thực hiện thủ tục nhận phòng:
  - Cập nhật `NgayCheckInThucTe = GETDATE()` cho các phòng trong `BOOKING_PHONG`.
  - Đổi trạng thái `BOOKING.TrangThai = 'DaCheckIn'`.
  - Trigger `trg_DongBoTrangThaiPhongCheckIn` sẽ tự động chuyển phòng sang `'Occupied'`.
* **Tham số:** `@MaBooking VARCHAR(10), @MaNV VARCHAR(10)`.
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_CheckInNhanPhong
    @MaBooking VARCHAR(10),
    @MaNV VARCHAR(10),
    @MaPhong VARCHAR(10) = NULL -- NULL = Check-in tất cả các phòng; Hoặc truyền mã để Check-in riêng từng phòng
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Kiểm tra đơn đặt phòng
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE MaBooking = @MaBooking AND TrangThai IN ('DaXacNhan', 'DaCheckIn'))
        BEGIN
            RAISERROR(N'Đơn đặt phòng không tồn tại hoặc không ở trạng thái hợp lệ để Check-in!', 16, 1);
            RETURN -1;
        END

        -- Nếu chỉ định phòng cụ thể, kiểm tra phòng đó có thuộc đơn không và chưa check-in
        IF @MaPhong IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM BOOKING_PHONG WHERE MaBooking = @MaBooking AND MaPhong = @MaPhong AND NgayCheckInThucTe IS NULL
        )
        BEGIN
            RAISERROR(N'Phòng chỉ định không thuộc đơn đặt phòng này hoặc đã Check-in trước đó!', 16, 1);
            RETURN -2;
        END

        BEGIN TRANSACTION;

        -- Cập nhật giờ check-in thực tế (cho phòng chỉ định hoặc toàn bộ phòng chưa check-in trong đơn)
        UPDATE BOOKING_PHONG
        SET NgayCheckInThucTe = GETDATE()
        WHERE MaBooking = @MaBooking 
          AND (@MaPhong IS NULL OR MaPhong = @MaPhong)
          AND NgayCheckInThucTe IS NULL;

        -- Cập nhật trạng thái đơn đặt phòng sang 'DaCheckIn' và ghi nhận nhân viên làm thủ tục
        UPDATE BOOKING
        SET TrangThai = 'DaCheckIn', MaNV = @MaNV
        WHERE MaBooking = @MaBooking;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO
```

---

### Procedure 3: Khách gọi thêm dịch vụ gia tăng (`sp_GoiThemDichVu`)
* **Mục đích:** Khi khách lưu trú gọi đồ ăn, thức uống, giặt ủi hoặc vé dịch vụ:
  - Kiểm tra đơn đặt phòng có đang lưu trú (`DaCheckIn`) hay không.
  - Lấy đúng đơn giá niêm yết hiện hành của dịch vụ từ bảng `DICHVU`.
  - Chèn bản ghi vào bảng `BOOKING_DICHVU`.
* **Tham số:** 
  - `@MaBooking VARCHAR(10)`
  - `@MaDichVu VARCHAR(10)`
  - `@SoLuong INT`
  - `@NguoiThem VARCHAR(20)` ('KhachHang' hoặc 'NhanVien')
  - `@MaNV VARCHAR(10) = NULL`
  - `@MaBookingDichVuMoi VARCHAR(10) OUTPUT`
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_GoiThemDichVu
    @MaBooking VARCHAR(10),
    @MaPhong VARCHAR(10) = NULL, -- NULL nếu là dịch vụ dùng chung cho cả đoàn, có mã nếu gọi riêng cho phòng
    @MaDichVu VARCHAR(10),
    @SoLuong INT,
    @NguoiThem VARCHAR(20) = 'KhachHang',
    @MaNV VARCHAR(10) = NULL,
    @MaBookingDichVuMoi VARCHAR(10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @SoLuong <= 0
        BEGIN
            RAISERROR(N'Số lượng dịch vụ phải lớn hơn 0!', 16, 1);
            RETURN -1;
        END

        -- Chỉ cho phép gọi dịch vụ khi đang ở trạng thái DaCheckIn
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE MaBooking = @MaBooking AND TrangThai = 'DaCheckIn')
        BEGIN
            RAISERROR(N'Chỉ có thể gọi thêm dịch vụ khi khách đang lưu trú tại khách sạn!', 16, 1);
            RETURN -2;
        END

        -- Kiểm tra dịch vụ có tồn tại và đang kinh doanh không
        DECLARE @DonGia DECIMAL(18,2);
        SELECT @DonGia = DonGia FROM DICHVU WHERE MaDichVu = @MaDichVu AND TrangThai = 'ApDung';
        
        IF @DonGia IS NULL
        BEGIN
            RAISERROR(N'Dịch vụ không tồn tại hoặc đang tạm ngưng cung cấp (NgungApDung)!', 16, 1);
            RETURN -3;
        END

        -- Nếu có chỉ định phòng, kiểm tra phòng đó có thực sự thuộc đơn booking này không (Chuẩn 3NF)
        IF @MaPhong IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM BOOKING_PHONG WHERE MaBooking = @MaBooking AND MaPhong = @MaPhong
        )
        BEGIN
            RAISERROR(N'Phòng được chỉ định không thuộc đơn đặt phòng này!', 16, 1);
            RETURN -4;
        END

        SET @MaBookingDichVuMoi = 'BDV_' + SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 6);

        INSERT INTO BOOKING_DICHVU (MaBookingDichVu, MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem, MaNV)
        VALUES (@MaBookingDichVuMoi, @MaBooking, @MaPhong, @MaDichVu, @DonGia, @SoLuong, GETDATE(), @NguoiThem, @MaNV);

        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO
```

---

### Procedure 4: Quyết toán hóa đơn và Check-out trả phòng (`sp_QuyetToanVaCheckOut`)
* **Mục đích:** Quy trình trả phòng của khách:
  1. Gọi hàm `fn_TinhTongTienThucTePhaiTra` để tính tổng tiền cuối cùng (phòng + dịch vụ) và cập nhật vào `HOADON.TongTienCuoiCung`.
  2. Tính tổng tiền khách đã thanh toán trong `THANHTOAN` để tính ra số tiền còn thiếu.
  3. Cập nhật `NgayCheckOutThucTe = GETDATE()` và chuyển `BOOKING.TrangThai = 'DaCheckOut'`.
  4. Trigger `trg_TuDongDonPhongSauCheckOut` sẽ tự động chuyển phòng sang `'Dirty'` và tạo nhiệm vụ dọn dẹp trong `NHIEMVUDOPHONG`.
* **Tham số:** 
  - `@MaBooking VARCHAR(10)`
  - `@MaNV VARCHAR(10)`
  - `@TongTienCuoiCung DECIMAL(18,2) OUTPUT`
  - `@DaThanhToan DECIMAL(18,2) OUTPUT`
  - `@ConThieu DECIMAL(18,2) OUTPUT`
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_QuyetToanVaCheckOut
    @MaBooking VARCHAR(10),
    @MaNV VARCHAR(10),
    @TongTienCuoiCung DECIMAL(18,2) OUTPUT,
    @DaThanhToan DECIMAL(18,2) OUTPUT,
    @ConThieu DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE MaBooking = @MaBooking AND TrangThai = 'DaCheckIn')
        BEGIN
            RAISERROR(N'Đơn đặt phòng không ở trạng thái lưu trú để làm thủ tục trả phòng!', 16, 1);
            RETURN -1;
        END

        BEGIN TRANSACTION;

        -- 1. Tính tổng tiền thực tế cuối cùng bằng hàm fn_TinhTongTienThucTePhaiTra
        SET @TongTienCuoiCung = dbo.fn_TinhTongTienThucTePhaiTra(@MaBooking);

        -- 2. Cập nhật hóa đơn
        UPDATE HOADON
        SET TongTienCuoiCung = @TongTienCuoiCung, MaNV = @MaNV
        WHERE MaBooking = @MaBooking;

        -- 3. Tính tiền đã trả và tiền còn thiếu
        SELECT @DaThanhToan = ISNULL(SUM(tt.SoTien), 0)
        FROM THANHTOAN tt
        INNER JOIN HOADON hd ON tt.MaHoaDon = hd.MaHoaDon
        WHERE hd.MaBooking = @MaBooking;

        SET @ConThieu = @TongTienCuoiCung - @DaThanhToan;

        -- 4. Cập nhật giờ check-out thực tế
        UPDATE BOOKING_PHONG
        SET NgayCheckOutThucTe = GETDATE()
        WHERE MaBooking = @MaBooking AND NgayCheckOutThucTe IS NULL;

        -- 5. Cập nhật trạng thái đơn đặt phòng
        UPDATE BOOKING
        SET TrangThai = 'DaCheckOut', MaNV = @MaNV
        WHERE MaBooking = @MaBooking;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO
```

---

### Procedure 5: Ghi nhận thanh toán và đặt cọc (`sp_GhiNhanThanhToan`)
* **Mục đích:** Thu ngân/Lễ tân thu tiền (tiền cọc ban đầu hoặc quyết toán lúc ra về):
  - Chèn bản ghi vào bảng `THANHTOAN`.
  - Trigger `trg_CapNhatTrangThaiHoaDon` sẽ tự động kích hoạt để chuyển trạng thái hóa đơn sang `MotPhan` hoặc `DaThanhToanDu`.
* **Tham số:** 
  - `@MaHoaDon VARCHAR(10)`
  - `@MaNV VARCHAR(10)`
  - `@SoTien DECIMAL(18,2)`
  - `@PhuongThucThanhToan VARCHAR(20)` ('TienMat', 'ChuyenKhoan', 'TheNganHang')
  - `@MaThanhToanMoi VARCHAR(20) OUTPUT`
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_GhiNhanThanhToan
    @MaHoaDon VARCHAR(10),
    @MaNV VARCHAR(10),
    @SoTien DECIMAL(18,2),
    @PhuongThucThanhToan VARCHAR(20) = 'TienMat',
    @MaThanhToanMoi VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @SoTien <= 0
        BEGIN
            RAISERROR(N'Số tiền thanh toán phải lớn hơn 0!', 16, 1);
            RETURN -1;
        END

        IF NOT EXISTS (SELECT 1 FROM HOADON WHERE MaHoaDon = @MaHoaDon)
        BEGIN
            RAISERROR(N'Hóa đơn không tồn tại trên hệ thống!', 16, 1);
            RETURN -2;
        END

        SET @MaThanhToanMoi = 'TT_' + SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 7); -- 3 + 7 = 10 ký tự

        INSERT INTO THANHTOAN (MaThanhToan, MaHoaDon, MaNV, SoTien, PhuongThucThanhToan, ThoiDiemThanhToan)
        VALUES (@MaThanhToanMoi, @MaHoaDon, @MaNV, @SoTien, @PhuongThucThanhToan, GETDATE());

        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO
```

---

### Procedure 6: Quy trình buồng phòng dọn dẹp phòng (`sp_CapNhatTienDoDonPhong`)
* **Mục đích:** Nhân viên buồng phòng thao tác trên ứng dụng di động/web:
  - Hành động `NhanViec`: Chuyển `TrangThai = 'DangDon'`, phòng chuyển sang `'Cleaning'`.
  - Hành động `HoanThanh`: 
    + Nếu kết quả `KhongThietHai`: Phòng chuyển sang `'Available'` để đón khách mới.
    + Nếu kết quả `CoThietHai`: Phòng chuyển sang `'Damaged'` và ghi nhận để Quản lý điều thợ sửa.
* **Tham số:** 
  - `@MaNhiemVu VARCHAR(20)`
  - `@MaNV VARCHAR(10)`
  - `@HanhDong VARCHAR(20)` ('NhanViec' hoặc 'HoanThanh')
  - `@KetQua VARCHAR(20) = NULL` ('KhongThietHai' hoặc 'CoThietHai')
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_CapNhatTienDoDonPhong
    @MaNhiemVu VARCHAR(10),
    @MaNV VARCHAR(10),
    @HanhDong VARCHAR(20), -- 'NhanViec' hoặc 'HoanThanh'
    @KetQua VARCHAR(20) = 'KhongThietHai'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @MaPhong VARCHAR(10);
        DECLARE @TrangThaiNhiemVu VARCHAR(20);

        SELECT @MaPhong = MaPhong, @TrangThaiNhiemVu = TrangThai 
        FROM NHIEMVUDOPHONG 
        WHERE MaNhiemVu = @MaNhiemVu;

        IF @MaPhong IS NULL
        BEGIN
            RAISERROR(N'Nhiệm vụ dọn phòng không tồn tại!', 16, 1);
            RETURN -1;
        END

        BEGIN TRANSACTION;

        IF @HanhDong = 'NhanViec'
        BEGIN
            IF @TrangThaiNhiemVu <> 'ChoXuLy'
            BEGIN
                RAISERROR(N'Nhiệm vụ này đã được nhận dọn dẹp hoặc đã hoàn thành trước đó!', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN -2;
            END

            UPDATE NHIEMVUDOPHONG
            SET MaNV = @MaNV, ThoiGianBatDau = GETDATE(), TrangThai = 'DangDon'
            WHERE MaNhiemVu = @MaNhiemVu;

            UPDATE PHONG SET TrangThai = 'Cleaning' WHERE MaPhong = @MaPhong;
        END
        ELSE IF @HanhDong = 'HoanThanh'
        BEGIN
            IF @TrangThaiNhiemVu <> 'DangDon'
            BEGIN
                RAISERROR(N'Chỉ có thể hoàn thành nhiệm vụ đang trong quá trình dọn dẹp (DangDon)!', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN -3;
            END

            UPDATE NHIEMVUDOPHONG
            SET ThoiGianKetThuc = GETDATE(), TrangThai = 'HoanThanh', KetQua = @KetQua
            WHERE MaNhiemVu = @MaNhiemVu;

            IF @KetQua = 'KhongThietHai'
                UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = @MaPhong;
            ELSE
                UPDATE PHONG SET TrangThai = 'Damaged' WHERE MaPhong = @MaPhong;
        END

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END;
GO
```

---

### Procedure 7: Báo cáo tổng kết kinh doanh chốt ca theo ngày (`sp_BaoCaoTongHopKinhDoanhTheoNgay`)
* **Mục đích:** Nghiệp vụ kiểm toán đêm (**Night Audit**) hoặc chốt sổ cuối ngày của Lễ tân/Thu ngân:
  - Thống kê toàn bộ biến động trong một ngày cụ thể (hoặc ngày hôm nay): Số đơn mới đặt, số phòng check-in, số phòng check-out.
  - Thống kê chi tiết dòng tiền thực thu trong ngày, phân tách rạch ròi theo từng phương thức: **Tiền mặt (TienMat)**, **Chuyển khoản (ChuyenKhoan)**, **Thẻ ngân hàng (TheNganHang)** để Thu ngân đối soát quỹ tiền mặt và tài khoản ngân hàng.
* **Tham số:** `@NgayBaoCao DATE = NULL` (Mặc định nếu truyền NULL sẽ lấy ngày hiện tại `CAST(GETDATE() AS DATE)`).
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_BaoCaoTongHopKinhDoanhTheoNgay
    @NgayBaoCao DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Nếu không truyền ngày thì mặc định lấy ngày hôm nay
    IF @NgayBaoCao IS NULL
        SET @NgayBaoCao = CAST(GETDATE() AS DATE);

    SELECT 
        @NgayBaoCao AS NgayBaoCao,
        -- Thống kê hoạt động buồng phòng trong ngày
        (SELECT COUNT(*) FROM BOOKING WHERE CAST(NgayDat AS DATE) = @NgayBaoCao) AS SoDonDatMoi,
        (SELECT COUNT(*) FROM BOOKING_PHONG WHERE CAST(NgayCheckInThucTe AS DATE) = @NgayBaoCao) AS SoPhongCheckIn,
        (SELECT COUNT(*) FROM BOOKING_PHONG WHERE CAST(NgayCheckOutThucTe AS DATE) = @NgayBaoCao) AS SoPhongCheckOut,
        
        -- Thống kê doanh thu thực thu trong ngày (từ bảng THANHTOAN)
        ISNULL(SUM(tt.SoTien), 0) AS TongTienThucThu,
        ISNULL(SUM(CASE WHEN tt.PhuongThucThanhToan = 'TienMat' THEN tt.SoTien END), 0) AS ThuTienMat,
        ISNULL(SUM(CASE WHEN tt.PhuongThucThanhToan = 'ChuyenKhoan' THEN tt.SoTien END), 0) AS ThuChuyenKhoan,
        ISNULL(SUM(CASE WHEN tt.PhuongThucThanhToan = 'TheNganHang' THEN tt.SoTien END), 0) AS ThuTheNganHang
    FROM THANHTOAN tt
    WHERE CAST(tt.ThoiDiemThanhToan AS DATE) = @NgayBaoCao;
END;
GO
```

---

### Procedure 8: Báo cáo tổng kết kinh doanh tháng (`sp_BaoCaoTongHopKinhDoanhThang`)
* **Mục đích:** Xuất báo cáo tài chính tổng quan cho Giám đốc/Quản lý theo tháng và năm chỉ định.
* **Tham số:** `@Thang INT, @Nam INT`.
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_BaoCaoTongHopKinhDoanhThang
    @Thang INT,
    @Nam INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        @Thang AS ThangBaoCao,
        @Nam AS NamBaoCao,
        COUNT(DISTINCT b.MaBooking) AS TongSoDonBooking,
        COUNT(DISTINCT CASE WHEN b.TrangThai = 'DaCheckOut' THEN b.MaBooking END) AS SoDonHoanThanh,
        COUNT(DISTINCT CASE WHEN b.TrangThai = 'DaHuy' THEN b.MaBooking END) AS SoDonDaHuy,
        (SELECT ISNULL(SUM(SoTien), 0) FROM THANHTOAN WHERE MONTH(ThoiDiemThanhToan) = @Thang AND YEAR(ThoiDiemThanhToan) = @Nam) AS TongTienThucThu
    FROM BOOKING b
    WHERE MONTH(b.NgayDat) = @Thang AND YEAR(b.NgayDat) = @Nam;
END;
GO
```

---

## 4. BẢNG TỔNG HỢP VAI TRÒ & ĐỐI TƯỢNG SỬ DỤNG

| Tên Đối Tượng | Phân Loại | Người Dùng / Màn Hình Sử Dụng | Mục Đích Chính |
| :--- | :---: | :--- | :--- |
| `fn_TinhTienPhongBooking` | Scalar Function | Hệ thống Backend | Tính tiền phòng theo số đêm lưu trú. |
| `fn_TinhTienDichVuBooking` | Scalar Function | Hệ thống Backend | Tính tổng chi phí dịch vụ gia tăng phát sinh. |
| `fn_TinhTongTienThucTePhaiTra` | Scalar Function | Thu ngân / Lễ tân | Tính con số quyết toán hóa đơn (Phòng + Dịch vụ). |
| `fn_KiemTraPhongTrongTrongKhoang` | Scalar Function | Web đặt phòng & Lễ tân | Kiểm tra tính khả dụng của phòng trước khi lưu. |
| `fn_TraCuuPhongTrongTheoYeuCau` | Table Function | Giao diện Tìm kiếm phòng | Trả về danh sách phòng trống theo ngày, số người và loại phòng. |
| `fn_LichSuDatPhongKhachHang` | Table Function | Khách hàng (Portal) | Tra cứu danh sách đơn booking đã từng đặt. |
| `fn_DoanhThuTheoKhoangThoiGian` | Scalar Function | Báo cáo Quản lý | Tính tổng doanh thu thực thu theo khoảng ngày tùy chọn. |
| `sp_TaoDonDatPhongOnline` | Stored Procedure | Khách hàng Online / Lễ tân | Tạo đơn booking hợp lệ, tự động kích hoạt tạo hóa đơn. |
| `sp_CheckInNhanPhong` | Stored Procedure | Lễ tân | Check-in, đổi trạng thái phòng sang Occupied. |
| `sp_GoiThemDichVu` | Stored Procedure | Khách hàng / Lễ tân | Ghi nhận dịch vụ phát sinh khi đang lưu trú. |
| `sp_QuyetToanVaCheckOut` | Stored Procedure | Lễ tân / Thu ngân | Chốt tiền hóa đơn, đổi phòng sang Dirty để dọn dẹp. |
| `sp_GhiNhanThanhToan` | Stored Procedure | Thu ngân | Ghi nhận thanh toán cọc hoặc trả nốt. |
| `sp_CapNhatTienDoDonPhong` | Stored Procedure | Housekeeper | Cập nhật tiến độ dọn phòng và nghiệm thu phòng sạch/hỏng. |
| `sp_BaoCaoTongHopKinhDoanhTheoNgay` | Stored Procedure | Thu ngân / Quản lý | Chốt sổ kiểm toán cuối ngày: Lượt phòng & tiền theo hình thức. |
| `sp_BaoCaoTongHopKinhDoanhThang` | Stored Procedure | Ban Giám đốc / Quản lý | Xuất báo cáo tổng quan kinh doanh trong tháng. |

