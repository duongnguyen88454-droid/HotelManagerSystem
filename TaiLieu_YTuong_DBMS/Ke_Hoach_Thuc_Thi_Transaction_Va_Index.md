# KẾ HOẠCH CHI TIẾT THỰC THI HỆ THỐNG TRANSACTION & INDEX
**Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10  
**Môn học:** Hệ Quản Trị Cơ Sở Dữ Liệu (DBMS330284) — Trường ĐH Sư Phạm Kỹ Thuật TP.HCM (HCMUTE)  
**Tiêu chuẩn định dạng:** Tiếng Việt UTF-8 chuẩn, giao diện văn bản rõ ràng, dễ đọc

---

## MỤC LỤC

1. NGUYÊN TẮC THIẾT KẾ TRANSACTION & INDEX
2. DANH SÁCH 5 TRANSACTION CỐT LÕI (CHUẨN ACID)
   - Transaction 1: Tạo đơn đặt phòng mới trọn gói (tr_TaoBookingTronGoi)
   - Transaction 2: Check-in nhận phòng bàn giao chìa khóa (tr_CheckInNhanPhong)
   - Transaction 3: Check-out và thanh toán toàn bộ hóa đơn tại quầy (tr_CheckOutVaThanhToan)
   - Transaction 4: Hủy đơn đặt phòng và giải phóng phòng trống (tr_HuyDonDatPhong)
   - Transaction 5: Hoàn tất dọn dẹp và tự động lập biên bản hư hại (tr_HoanTatDonPhongVaLapBienBan)
3. DANH SÁCH 5 NON-CLUSTERED INDEX TỐI ƯU HIỆU NĂNG
   - Index 1: Tối ưu kiểm tra phòng trống và chống Double-booking (IX_BOOKING_PHONG_ThoiGian_MaPhong)
   - Index 2: Tối ưu tra cứu lịch sử đơn của khách hàng (IX_BOOKING_MaKH_TrangThai)
   - Index 3: Tối ưu tìm kiếm khách hàng tại quầy Lễ tân (IX_KHACHHANG_SoDT_CCCD)
   - Index 4: Tối ưu tải sơ đồ trạng thái phòng trên Dashboard (IX_PHONG_TrangThai_MaLoaiPhong)
   - Index 5: Tối ưu tổng hợp doanh thu tài chính theo thời gian (IX_THANHTOAN_ThoiDiemThanhToan)
4. HƯỚNG DẪN KIỂM CHỨNG EXECUTION PLAN TRONG BÁO CÁO ĐỒ ÁN
5. BẢNG TỔNG HỢP VAI TRÒ & GIÁ TRỊ THỰC TIỄN

---

## 1. NGUYÊN TẮC THIẾT KẾ TRANSACTION & INDEX

### 1.1. Nguyên tắc thiết kế Transaction (Giao dịch an toàn dữ liệu)
Mỗi Transaction trong hệ thống phải thỏa mãn trọn vẹn 4 tính chất **ACID**:
* **Atomicity (Tính nguyên tử - "Tất cả hoặc không có gì"):** Một chu trình gồm nhiều câu lệnh ghi dữ liệu (`INSERT`, `UPDATE`, `DELETE`) trên nhiều bảng khác nhau. Nếu một câu lệnh gặp lỗi (sai ràng buộc, thiếu tiền, phòng hỏng), toàn bộ các câu lệnh trước đó đều phải bị hủy bỏ hoàn toàn thông qua `ROLLBACK TRANSACTION`.
* **Consistency (Tính nhất quán):** Dữ liệu trước và sau giao dịch luôn thỏa mãn các ràng buộc toàn vẹn (`CHECK`, `FOREIGN KEY`, `UNIQUE`).
* **Isolation (Tính cô lập):** Các giao dịch thực thi độc lập, không đọc dữ liệu rác (Dirty Read) của các giao dịch chưa được xác nhận.
* **Durability (Tính bền vững):** Khi lệnh `COMMIT TRANSACTION` thành công, dữ liệu được ghi nhận vĩnh viễn vào ổ đĩa.

### 1.2. Nguyên tắc thiết kế Index (Chỉ mục tối ưu hiệu năng)
* Mọi bảng trong hệ thống đã có sẵn **Clustered Index** tự động gắn liền với Khóa chính (`PRIMARY KEY`).
* **Non-Clustered Index** được thiết kế bổ sung cho các cột thường xuyên xuất hiện trong:
  - Mệnh đề tìm kiếm `WHERE`
  - Mệnh đề kết nối `JOIN` (Khóa ngoại)
  - Mệnh đề sắp xếp `ORDER BY`
* Áp dụng kỹ thuật **Covering Index (`INCLUDE`)**: Đưa thêm các cột cần `SELECT` vào lá của Index để SQL Server lấy dữ liệu trực tiếp từ Index mà không cần tốn chi phí tra cứu ngược về bảng gốc (Key Lookup).

---

## 2. DANH SÁCH 5 TRANSACTION CỐT LÕI (CHUẨN ACID)

---

### Transaction 1: Tạo đơn đặt phòng mới trọn gói (`tr_TaoBookingTronGoi`)

* **Nghiệp vụ thực tế:** Khách hàng đặt phòng trực tuyến hoặc Lễ tân nhận đặt phòng tại quầy.
* **Các bảng bị tác động đồng thời:** `BOOKING`, `BOOKING_PHONG`, `HOADON`.
* **Rủi ro nếu không có Transaction:**
  - Nếu tạo được bản ghi `BOOKING` nhưng khi chèn vào `BOOKING_PHONG` bị lỗi (phòng bị trùng lịch, phòng đang bẩn), hệ thống sẽ tồn tại một đơn đặt phòng "rác" không có phòng nào.
  - Ngược lại, nếu chèn được phòng nhưng hệ thống bị lỗi tạo hóa đơn `HOADON` thì sau này không thể thu tiền khách.
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_Transaction_TaoBookingTronGoi
    @MaKH VARCHAR(10),
    @MaPhong VARCHAR(10),
    @NgayNhan DATE,
    @NgayTra DATE,
    @PhuongPhapBooking VARCHAR(10) = 'Online', -- 'Online' hoặc 'Offline'
    @MaBookingMoi VARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Bắt đầu khối kiểm soát lỗi
    BEGIN TRY
        -- 1. Kiểm tra tính hợp lệ cơ bản
        IF @NgayNhan >= @NgayTra OR @NgayNhan < CAST(GETDATE() AS DATE)
            THROW 50001, N'Ngày nhận phòng hoặc ngày trả phòng không hợp lệ!', 1;

        IF NOT EXISTS (SELECT 1 FROM KHACHHANG WHERE MaKH = @MaKH)
            THROW 50002, N'Mã khách hàng đại diện không tồn tại!', 1;

        -- 2. Kiểm tra tính khả dụng của phòng bằng hàm fn_KiemTraPhongTrongTrongKhoang
        IF dbo.fn_KiemTraPhongTrongTrongKhoang(@MaPhong, @NgayNhan, @NgayTra, NULL) = 0
            THROW 50003, N'Phòng đã chọn không khả dụng (đang dọn dẹp, hư hại hoặc trùng lịch)!', 1;

        -- 3. Lấy giá niêm yết và tính số đêm
        DECLARE @DonGia DECIMAL(12,2);
        SELECT @DonGia = lp.GiaPhong
        FROM PHONG p
        INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
        WHERE p.MaPhong = @MaPhong;

        DECLARE @SoDem INT = DATEDIFF(DAY, @NgayNhan, @NgayTra);
        IF @SoDem <= 0 SET @SoDem = 1;
        DECLARE @ChiPhiDuKien DECIMAL(12,2) = @DonGia * @SoDem;

        -- Sinh mã Booking mới
        SET @MaBookingMoi = 'BK_' + SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 7);

        -- BẮT ĐẦU TRANSACTION
        BEGIN TRANSACTION;

        -- Bước A: Tạo đơn đặt phòng
        INSERT INTO BOOKING (MaBooking, MaKH, NgayDat, ChiPhiDuKien, TrangThai, MaNV, PhuongPhapBooking)
        VALUES (@MaBookingMoi, @MaKH, GETDATE(), @ChiPhiDuKien, 'DaXacNhan', NULL, @PhuongPhapBooking);

        -- Bước B: Gán phòng vào đơn (dùng @DonGia đã lấy từ LOAIPHONG)
        INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien, NgayCheckInThucTe, NgayCheckOutThucTe)
        VALUES (@MaBookingMoi, @MaPhong, @DonGia, @NgayNhan, @NgayTra, NULL, NULL);

        -- Bước C: Tạo hóa đơn tổng duy nhất (Nếu Trigger 5 chưa tạo thì thủ tục đảm bảo tính toàn vẹn)
        IF NOT EXISTS (SELECT 1 FROM HOADON WHERE MaBooking = @MaBookingMoi)
        BEGIN
            INSERT INTO HOADON (MaHoaDon, MaBooking, NgayLap, TongTienCuoiCung, MaNV, TrangThai)
            VALUES ('HD_' + SUBSTRING(@MaBookingMoi, 4, 7), @MaBookingMoi, GETDATE(), NULL, 'NV001', 'ChuaThanhToan');
        END

        -- MỌI THAO TÁC THÀNH CÔNG -> XÁC NHẬN LƯU VĨNH VIỄN
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- NẾU CÓ BẤT KỲ LỖI NÀO -> HỦY BỎ TOÀN BỘ
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO
```

---

### Transaction 2: Check-in nhận phòng bàn giao chìa khóa (`tr_CheckInNhanPhong`)

* **Nghiệp vụ thực tế:** Khi khách hàng đến khách sạn làm thủ tục nhận phòng thực tế tại quầy lễ tân.
* **Các bảng bị tác động đồng thời:** `BOOKING`, `BOOKING_PHONG`, `PHONG`.
* **Rủi ro nếu không có Transaction:** Đơn booking đã chuyển sang trạng thái `DaCheckIn` nhưng căn phòng vật lý vẫn ở màu xanh `Available` do lỗi hệ thống, khiến lễ tân khác nhìn vào tưởng phòng còn trống và xếp cho khách khác vào ở (Double Check-in).
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_Transaction_CheckInNhanPhong
    @MaBooking VARCHAR(10),
    @MaNV VARCHAR(10),
    @MaPhong VARCHAR(10) = NULL -- NULL = Check-in tất cả các phòng; Hoặc chỉ định phòng cụ thể
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Kiểm tra đơn đặt phòng
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE MaBooking = @MaBooking AND TrangThai IN ('DaXacNhan', 'DaCheckIn'))
            THROW 50011, N'Đơn đặt phòng không tồn tại hoặc không ở trạng thái hợp lệ để Check-in!', 1;

        -- 2. Kiểm tra nhân viên thực hiện
        IF NOT EXISTS (SELECT 1 FROM NHANVIEN WHERE MaNV = @MaNV AND TrangThaiLamViec = 'DangLam')
            THROW 50012, N'Mã nhân viên lễ tân không hợp lệ hoặc đã nghỉ việc!', 1;

        -- 3. Nếu chỉ định phòng cụ thể, kiểm tra phòng đó có thuộc đơn không
        IF @MaPhong IS NOT NULL AND NOT EXISTS (
            SELECT 1 FROM BOOKING_PHONG WHERE MaBooking = @MaBooking AND MaPhong = @MaPhong AND NgayCheckInThucTe IS NULL
        )
            THROW 50013, N'Phòng chỉ định không thuộc đơn đặt phòng này hoặc đã Check-in trước đó!', 1;

        -- BẮT ĐẦU TRANSACTION
        BEGIN TRANSACTION;

        -- Bước A: Cập nhật giờ nhận phòng thực tế cho phòng chỉ định hoặc tất cả các phòng chưa check-in
        UPDATE BOOKING_PHONG
        SET NgayCheckInThucTe = GETDATE()
        WHERE MaBooking = @MaBooking 
          AND (@MaPhong IS NULL OR MaPhong = @MaPhong)
          AND NgayCheckInThucTe IS NULL;

        -- Bước B: Chuyển trạng thái căn phòng vật lý sang 'Occupied' (Đang có khách)
        UPDATE p
        SET p.TrangThai = 'Occupied'
        FROM PHONG p
        INNER JOIN BOOKING_PHONG bp ON p.MaPhong = bp.MaPhong
        WHERE bp.MaBooking = @MaBooking
          AND (@MaPhong IS NULL OR bp.MaPhong = @MaPhong);

        -- Bước C: Cập nhật trạng thái đơn Booking sang 'DaCheckIn' và ghi nhận nhân viên làm thủ tục
        UPDATE BOOKING
        SET TrangThai = 'DaCheckIn', MaNV = @MaNV
        WHERE MaBooking = @MaBooking;

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO
```

---

### Transaction 3: Check-out và thanh toán toàn bộ hóa đơn tại quầy (`tr_CheckOutVaThanhToan`)

* **Nghiệp vụ thực tế:** Hệ thống không thu cọc trước. Khi khách trả phòng, Lễ tân tính tổng hóa đơn cuối cùng (tiền phòng + tiền dịch vụ), khách thanh toán toàn bộ chi phí tại quầy, hệ thống đổi trạng thái phòng và tự động bàn giao cho buồng phòng dọn dẹp.
* **Các bảng bị tác động đồng thời:** `HOADON`, `THANHTOAN`, `BOOKING_PHONG`, `BOOKING`, `PHONG`, `NHIEMVUDOPHONG`.
* **Rủi ro nếu không có Transaction:** Thu được tiền của khách nhưng phần mềm bị lỗi không cập nhật được giờ trả phòng, hoặc khách đã trả phòng nhưng hệ thống quên tạo phiếu dọn phòng khiến phòng bị bỏ quên không ai dọn.
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_Transaction_CheckOutVaThanhToan
    @MaBooking VARCHAR(10),
    @MaNV VARCHAR(10),
    @PhuongThucThanhToan VARCHAR(20) = 'TienMat',
    @TongTienCuoiCung DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM BOOKING WHERE MaBooking = @MaBooking AND TrangThai = 'DaCheckIn')
            THROW 50021, N'Đơn đặt phòng không ở trạng thái lưu trú để làm thủ tục Check-out!', 1;

        -- BẮT ĐẦU TRANSACTION
        BEGIN TRANSACTION;

        -- Bước A: Sử dụng hàm tính tổng tiền thực tế (Tiền phòng + Tiền dịch vụ phát sinh)
        SET @TongTienCuoiCung = dbo.fn_TinhTongTienThucTePhaiTra(@MaBooking);

        -- Bước B: Lấy mã hóa đơn liên kết
        DECLARE @MaHoaDon VARCHAR(10);
        SELECT @MaHoaDon = MaHoaDon FROM HOADON WHERE MaBooking = @MaBooking;

        -- Bước C: Cập nhật hóa đơn tổng cuối cùng và chuyển sang trạng thái đã thanh toán đủ
        UPDATE HOADON
        SET TongTienCuoiCung = @TongTienCuoiCung,
            MaNV = @MaNV,
            TrangThai = 'DaThanhToanDu'
        WHERE MaHoaDon = @MaHoaDon;

        -- Bước D: Ghi nhận phiếu thu thanh toán toàn bộ chi phí tại quầy
        IF @TongTienCuoiCung > 0
        BEGIN
            DECLARE @MaThanhToanMoi VARCHAR(20) = 'TT_' + SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 7);
            INSERT INTO THANHTOAN (MaThanhToan, MaHoaDon, MaNV, SoTien, PhuongThucThanhToan, ThoiDiemThanhToan)
            VALUES (@MaThanhToanMoi, @MaHoaDon, @MaNV, @TongTienCuoiCung, @PhuongThucThanhToan, GETDATE());
        END

        -- Bước E: Cập nhật giờ trả phòng thực tế
        UPDATE BOOKING_PHONG
        SET NgayCheckOutThucTe = GETDATE()
        WHERE MaBooking = @MaBooking AND NgayCheckOutThucTe IS NULL;

        -- Bước F: Chuyển trạng thái Booking sang 'DaCheckOut'
        UPDATE BOOKING
        SET TrangThai = 'DaCheckOut', MaNV = @MaNV
        WHERE MaBooking = @MaBooking;

        -- Bước G: Chuyển phòng sang 'Dirty' (Phòng bẩn)
        UPDATE p
        SET p.TrangThai = 'Dirty'
        FROM PHONG p
        INNER JOIN BOOKING_PHONG bp ON p.MaPhong = bp.MaPhong
        WHERE bp.MaBooking = @MaBooking;

        -- Bước H: Tự động phân công nhiệm vụ dọn dẹp vào NHIEMVUDOPHONG
        INSERT INTO NHIEMVUDOPHONG (MaNhiemVu, MaPhong, MaNV, ThoiGianNhan, TrangThai)
        SELECT 
            'NV' + SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8),
            bp.MaPhong,
            NULL,
            GETDATE(),
            'ChoXuLy'
        FROM BOOKING_PHONG bp
        WHERE bp.MaBooking = @MaBooking
          AND NOT EXISTS (
              SELECT 1 FROM NHIEMVUDOPHONG WHERE MaPhong = bp.MaPhong AND TrangThai IN ('ChoXuLy', 'DangDon')
          );

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO
```

---

### Transaction 4: Hủy đơn đặt phòng và giải phóng phòng trống (`tr_HuyDonDatPhong`)

* **Nghiệp vụ thực tế:** Khách hàng hoặc Lễ tân hủy đơn đặt phòng đã đặt trước đó (do hệ thống không thu cọc nên không phát sinh quy trình hoàn trả tiền cọc).
* **Các bảng bị tác động đồng thời:** `BOOKING`, `HOADON`.
* **Chính sách hủy:**
  - Nếu đã Check-in rồi thì tuyệt đối cấm hủy (được chặn bởi Trigger 2).
  - Chỉ hủy được các đơn đang ở trạng thái Chờ nhận phòng (`DaXacNhan`).
  - Khi đơn bị hủy, toàn bộ các phòng trong đơn đó lập tức được giải phóng để đón khách hàng khác.
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_Transaction_HuyDonDatPhong
    @MaBooking VARCHAR(10),
    @LyDoHuy NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Kiểm tra trạng thái đơn
        DECLARE @TrangThaiHienTai VARCHAR(20);
        SELECT @TrangThaiHienTai = TrangThai
        FROM BOOKING WHERE MaBooking = @MaBooking;

        IF @TrangThaiHienTai IS NULL
            THROW 50031, N'Không tìm thấy đơn đặt phòng yêu cầu hủy!', 1;

        IF @TrangThaiHienTai <> 'DaXacNhan'
            THROW 50032, N'Chỉ có thể hủy đơn đặt phòng đang ở trạng thái Chờ nhận phòng (DaXacNhan)! Khách đã Check-in không thể hủy đơn.', 1;

        -- BẮT ĐẦU TRANSACTION
        BEGIN TRANSACTION;

        -- Bước A: Cập nhật trạng thái đơn Booking sang 'DaHuy', ghi nhận thời điểm và lý do hủy
        UPDATE BOOKING
        SET TrangThai = 'DaHuy',
            ThoiDiemHuy = GETDATE(),
            PhiHuy = 0
        WHERE MaBooking = @MaBooking;
        -- Lý do hủy: @LyDoHuy có thể được lưu vào bảng log riêng nếu cần mở rộng.

        -- Bước B: Đưa hóa đơn về trạng thái 'ChuaThanhToan' và xóa công nợ vì khách không ở
        -- (Giữ TrangThai trong CHECK constraint: ChuaThanhToan/MotPhan/DaThanhToanDu)
        UPDATE HOADON
        SET TrangThai = 'ChuaThanhToan',
            TongTienCuoiCung = 0
        WHERE MaBooking = @MaBooking;

        -- Bước C: Xác nhận Transaction thành công
        -- (Ngay khi Booking sang 'DaHuy', Function fn_KiemTraPhongTrongTrongKhoang sẽ tự động giải phóng phòng để đón khách khác)
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO
```

---

### Transaction 5: Hoàn tất dọn dẹp và tự động lập biên bản hư hại (`tr_HoanTatDonPhongVaLapBienBan`)

* **Nghiệp vụ thực tế:** Housekeeper dọn phòng xong. Nếu phòng sạch sẽ thì mở phòng cho khách mới; nếu phát hiện hư hại đồ đạc (vỡ gương, hỏng máy lạnh) thì chuyển phòng sang `Damaged` và tự động lập biên bản báo cáo cho Quản lý.
* **Các bảng bị tác động đồng thời:** `NHIEMVUDOPHONG`, `PHONG`, `BAOCAOHUHAI`, `CHITIETBAOCAOHUHAI`.
* **Rủi ro nếu không có Transaction:** Phòng bị chuyển sang trạng thái hỏng `Damaged` nhưng biên bản hư hại bị lỗi không tạo được $\to$ Quản lý không biết phòng bị hỏng cái gì, ai làm hỏng, dẫn đến việc phòng bị bỏ hoang không được bảo trì.
* **Đặc tả mã T-SQL đề xuất:**

```sql
CREATE OR ALTER PROCEDURE sp_Transaction_HoanTatDonPhongVaLapBienBan
    @MaNhiemVu VARCHAR(20),
    @MaNV VARCHAR(10),
    @KetQua VARCHAR(20), -- 'KhongThietHai' hoặc 'CoThietHai'
    @MaLoaiHuHai VARCHAR(10) = NULL,
    @MoTaChiTiet NVARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @MaPhong VARCHAR(10);
        SELECT @MaPhong = MaPhong FROM NHIEMVUDOPHONG WHERE MaNhiemVu = @MaNhiemVu;

        IF @MaPhong IS NULL
            THROW 50041, N'Mã nhiệm vụ dọn phòng không tồn tại trên hệ thống!', 1;

        -- BẮT ĐẦU TRANSACTION
        BEGIN TRANSACTION;

        -- Bước A: Hoàn thành nhiệm vụ dọn phòng
        UPDATE NHIEMVUDOPHONG
        SET ThoiGianKetThuc = GETDATE(),
            TrangThai = 'HoanThanh',
            KetQua = @KetQua,
            MaNV = @MaNV
        WHERE MaNhiemVu = @MaNhiemVu;

        -- Bước B: Phân nhánh theo kết quả kiểm tra
        IF @KetQua = 'KhongThietHai'
        BEGIN
            -- Phòng sạch sẽ -> Sẵn sàng đón khách mới
            UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = @MaPhong;
        END
        ELSE IF @KetQua = 'CoThietHai'
        BEGIN
            -- Phòng bị hư hỏng -> Khóa phòng
            UPDATE PHONG SET TrangThai = 'Damaged' WHERE MaPhong = @MaPhong;

            -- Tự động lập biên bản báo cáo hư hại trong BAOCAOHUHAI
            DECLARE @MaBaoCao VARCHAR(10) = 'BC_' + SUBSTRING(CONVERT(VARCHAR(36), NEWID()), 1, 7);

            INSERT INTO BAOCAOHUHAI (MaBaoCao, MaNhiemVu, NgayPhatHien, MoTa, TrangThai, ThoiDiemXacNhan)
            VALUES (@MaBaoCao, @MaNhiemVu, GETDATE(), N'Biên bản lập tự động sau ca dọn phòng của nhân viên ' + @MaNV, 'ChoXuLy', NULL);

            -- Ghi nhận chi tiết món đồ hư hại vào CHITIETBAOCAOHUHAI
            IF @MaLoaiHuHai IS NOT NULL
            BEGIN
                INSERT INTO CHITIETBAOCAOHUHAI (MaBaoCao, MaLoaiHuHai, MoTaChiTiet)
                VALUES (@MaBaoCao, @MaLoaiHuHai, ISNULL(@MoTaChiTiet, N'Phát hiện đồ vật bị hư hỏng cần bảo trì thay thế.'));
            END
        END

        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO
```

---

## 3. DANH SÁCH 5 NON-CLUSTERED INDEX TỐI ƯU HIỆU NĂNG

---

### Index 1: Tối ưu tra cứu kiểm tra phòng trống & Double-booking (`IX_BOOKING_PHONG_ThoiGian_MaPhong`)

* **Bảng:** `BOOKING_PHONG`
* **Các cột chỉ mục:** `(MaPhong, NgayNhanDuKien, NgayTraDuKien)`
* **Mục đích nghiệp vụ:**
  - Đây là câu truy vấn xuất hiện nhiều nhất trong toàn bộ hệ thống: Được gọi liên tục bởi **Trigger 1** (`trg_Check_XungDotDatPhong`), **Function 4** (`fn_KiemTraPhongTrongTrongKhoang`) và thanh tìm kiếm trên Web.
  - Khi hệ thống có hàng vạn bản ghi đặt phòng, nếu không có Index, SQL Server phải quét tuần tự từng dòng trong `BOOKING_PHONG` (*Clustered Index Scan*), gây chậm trễ nghiêm trọng.
  - Sau khi có Index này, SQL Server chỉ cần tìm trực tiếp trên cây nhị phân B-Tree (*Index Seek*), thời gian thực thi giảm xuống mili-giây.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE NONCLUSTERED INDEX IX_BOOKING_PHONG_ThoiGian_MaPhong
ON BOOKING_PHONG (MaPhong, NgayNhanDuKien, NgayTraDuKien);
GO
```

---

### Index 2: Tối ưu tra cứu lịch sử đơn của khách hàng (`IX_BOOKING_MaKH_TrangThai`)

* **Bảng:** `BOOKING`
* **Các cột chỉ mục:** `(MaKH, TrangThai)`
* **Các cột bao gồm (Covering Index):** `INCLUDE (NgayDat, ChiPhiDuKien)`
* **Mục đích nghiệp vụ:**
  - Phục vụ màn hình trang cá nhân của khách hàng: "Lịch sử đặt phòng của tôi" (`WHERE MaKH = @MaKH AND TrangThai = ...`).
  - Kỹ thuật `INCLUDE` giúp toàn bộ dữ liệu cần hiển thị đã nằm trọn vẹn trong trang lá của Index, SQL Server không cần phải tốn thêm chi phí tra cứu ngược về bảng chính (*Key Lookup*).
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE NONCLUSTERED INDEX IX_BOOKING_MaKH_TrangThai
ON BOOKING (MaKH, TrangThai)
INCLUDE (NgayDat, ChiPhiDuKien);
GO
```

---

### Index 3: Tối ưu tìm kiếm khách hàng tại quầy Lễ tân (`IX_KHACHHANG_SoDT_CCCD`)

* **Bảng:** `KHACHHANG`
* **Các cột chỉ mục:** `(SoDT, CCCD)`
* **Các cột bao gồm:** `INCLUDE (HoTen, Email)`
* **Mục đích nghiệp vụ:**
  - Tại quầy Lễ tân, khi khách hàng đến check-in hoặc đặt phòng, Lễ tân luôn hỏi: *"Anh/chị cho em xin Số điện thoại hoặc Số CCCD/CMND"*.
  - Index này bảo đảm việc tra cứu hồ sơ khách hàng diễn ra tức thì, giao diện không bị giật lag khi danh sách khách hàng lên tới hàng chục nghìn người.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE NONCLUSTERED INDEX IX_KHACHHANG_SoDT_CCCD
ON KHACHHANG (SoDT, CCCD)
INCLUDE (HoTen, Email);
GO
```

---

### Index 4: Tối ưu tải sơ đồ trạng thái phòng Dashboard (`IX_PHONG_TrangThai_MaLoaiPhong`)

* **Bảng:** `PHONG`
* **Các cột chỉ mục:** `(TrangThai, MaLoaiPhong)`
* **Các cột bao gồm:** `INCLUDE (SoPhong)`
* **Mục đích nghiệp vụ:**
  - Phục vụ màn hình Dashboard trực quan của Lễ tân và Quản lý: Lọc nhanh các phòng màu xanh (`Available`), phòng màu đỏ (`Occupied`), phòng màu vàng (`Dirty`).
  - Phục vụ View `v_DanhSachPhongKhaDung` và View `v_TyLeLapDayPhong`.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE NONCLUSTERED INDEX IX_PHONG_TrangThai_MaLoaiPhong
ON PHONG (TrangThai, MaLoaiPhong)
INCLUDE (SoPhong);
GO
```

---

### Index 5: Tối ưu tổng hợp doanh thu tài chính theo thời gian (`IX_THANHTOAN_ThoiDiemThanhToan`)

* **Bảng:** `THANHTOAN`
* **Các cột chỉ mục:** `(ThoiDiemThanhToan)`
* **Các cột bao gồm:** `INCLUDE (SoTien, PhuongThucThanhToan, MaHoaDon)`
* **Mục đích nghiệp vụ:**
  - Phục vụ báo cáo tài chính hàng ngày (`sp_BaoCaoTongHopKinhDoanhTheoNgay`), báo cáo hàng tháng (`sp_BaoCaoTongHopKinhDoanhThang`) và hàm `fn_DoanhThuTheoKhoangThoiGian`.
  - Phép tính tổng tiền thu `SUM(SoTien)` chỉ cần duyệt qua các giá trị đã sắp xếp sẵn theo ngày trên Index, tốc độ nhanh hơn nhiều lần so với quét bảng.
* **Đoạn mã T-SQL đề xuất:**

```sql
CREATE NONCLUSTERED INDEX IX_THANHTOAN_ThoiDiemThanhToan
ON THANHTOAN (ThoiDiemThanhToan)
INCLUDE (SoTien, PhuongThucThanhToan, MaHoaDon);
GO
```

---

## 4. HƯỚNG DẪN KIỂM CHỨNG EXECUTION PLAN TRONG BÁO CÁO ĐỒ ÁN

Để đạt điểm tối đa phần Chỉ mục trong đồ án môn học DBMS (DBMS330284 - HCMUTE), nhóm cần đưa hình ảnh so sánh **Cây thực thi truy vấn (Execution Plan)** trước và sau khi tạo Index vào báo cáo Word:

### Các bước thực hiện trên SQL Server Management Studio (SSMS):
1. **Bật chế độ Execution Plan:** Trong cửa sổ truy vấn của SSMS, bấm tổ hợp phím **`Ctrl + M`** (hoặc chọn biểu tượng *Include Actual Execution Plan* trên thanh công cụ).
2. **Chạy câu lệnh kiểm thử trước khi tạo Index:**
   ```sql
   -- Ví dụ: Tìm phòng trong khoảng ngày cụ thể
   SELECT bp.MaPhong, bp.NgayNhanDuKien, bp.NgayTraDuKien
   FROM BOOKING_PHONG bp
   WHERE bp.MaPhong = 'P101' 
     AND bp.NgayNhanDuKien >= '2026-10-01' 
     AND bp.NgayTraDuKien <= '2026-10-05';
   ```
   * *Kết quả quan sát:* SSMS hiển thị toán tử **Clustered Index Scan** hoặc **Table Scan** với chi phí `Cost` cao (quét toàn bộ bảng).
3. **Tạo Index và chạy lại câu lệnh:**
   ```sql
   CREATE NONCLUSTERED INDEX IX_BOOKING_PHONG_ThoiGian_MaPhong
   ON BOOKING_PHONG (MaPhong, NgayNhanDuKien, NgayTraDuKien);
   ```
   * *Kết quả quan sát:* Toán tử đổi thành **Index Seek (NonClustered)** với chi phí `Cost` giảm rõ rệt (SQL Server nhảy thẳng đến nhánh dữ liệu cần tìm).
4. **Chụp lại hình ảnh so sánh 2 cây Execution Plan** để chèn vào báo cáo đồ án và slide thuyết trình.

---

## 5. BẢNG TỔNG HỢP VAI TRÒ & GIÁ TRỊ THỰC TIỄN

| Tên Đối Tượng | Thể Loại | Bảng Tác Động | Giá Trị Thực Tiễn Trong Hệ Thống Khách Sạn |
| :--- | :---: | :--- | :--- |
| `sp_Transaction_TaoBookingTronGoi` | **Transaction** | `BOOKING`, `BOOKING_PHONG`, `HOADON` | Bảo đảm tính nguyên tử khi đặt phòng, không bao giờ sinh đơn rác. |
| `sp_Transaction_CheckInNhanPhong` | **Transaction** | `BOOKING`, `BOOKING_PHONG`, `PHONG` | Đồng bộ đồng thời trạng thái đơn và phòng vật lý sang Occupied. |
| `sp_Transaction_CheckOutVaThanhToan` | **Transaction** | `HOADON`, `THANHTOAN`, `PHONG`, `NHIEMVUDOPHONG` | Thu tiền toàn bộ tại quầy, trả phòng và tự động sinh việc cho buồng phòng. |
| `sp_Transaction_HuyDonDatPhong` | **Transaction** | `BOOKING`, `HOADON` | Hủy đơn đặt phòng an toàn và tự động giải phóng phòng cho khách khác. |
| `sp_Transaction_HoanTatDonPhongVaLapBienBan` | **Transaction** | `NHIEMVUDOPHONG`, `PHONG`, `BAOCAOHUHAI` | Tự động lập biên bản hỏng hóc và đóng phòng để kỹ thuật sửa chữa. |
| `IX_BOOKING_PHONG_ThoiGian_MaPhong` | **Index** | `BOOKING_PHONG` | Tối ưu hóa kiểm tra phòng trống và chặn Double-booking. |
| `IX_BOOKING_MaKH_TrangThai` | **Index** | `BOOKING` | Tối ưu hóa màn hình lịch sử đặt phòng cho khách hàng. |
| `IX_KHACHHANG_SoDT_CCCD` | **Index** | `KHACHHANG` | Tìm kiếm khách hàng theo SĐT / CCCD tức thì tại quầy lễ tân. |
| `IX_PHONG_TrangThai_MaLoaiPhong` | **Index** | `PHONG` | Tối ưu hóa sơ đồ phòng Dashboard cho Lễ tân và Quản lý. |
| `IX_THANHTOAN_ThoiDiemThanhToan` | **Index** | `THANHTOAN` | Tối ưu hóa báo cáo doanh thu tài chính theo ngày và theo tháng. |
