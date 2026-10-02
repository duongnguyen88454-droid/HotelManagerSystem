-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: HỆ THỐNG TRIGGER (TỰ ĐỘNG HÓA VÀ RÀNG BUỘC TOÀN VẸN DỮ LIỆU)
-- ============================================================================

USE QuanLyKhachSan;
GO

-- ----------------------------------------------------------------------------
-- Trigger 1: Chống đặt trùng phòng và chặn đặt phòng bẩn / đang dọn / hư hại
-- Bảng: BOOKING_PHONG | Sự kiện: AFTER INSERT, UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_Check_XungDotDatPhong
ON BOOKING_PHONG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ kiểm tra khi thêm mới dòng đặt phòng hoặc khi thay đổi phòng / ngày lưu trú dự kiến
    IF NOT EXISTS (SELECT 1 FROM deleted) 
       OR UPDATE(MaPhong) 
       OR UPDATE(NgayNhanDuKien) 
       OR UPDATE(NgayTraDuKien)
    BEGIN
        -- 1. Chặn đặt các phòng đang bị hư hại (Damaged)
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN PHONG p ON i.MaPhong = p.MaPhong
            WHERE p.TrangThai = 'Damaged'
        )
        BEGIN
            RAISERROR(N'Lỗi nghiệp vụ: Phòng đang bị hư hỏng (Damaged), không thể nhận đặt phòng!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Kiểm tra giao thoa thời gian giữa booking mới và booking cũ của cùng 1 phòng
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN BOOKING b_new ON i.MaBooking = b_new.MaBooking
            INNER JOIN BOOKING_PHONG bp_old ON i.MaPhong = bp_old.MaPhong AND i.MaBooking <> bp_old.MaBooking
            INNER JOIN BOOKING b_old ON bp_old.MaBooking = b_old.MaBooking
            WHERE b_new.TrangThai IN ('ChoXacNhan', 'DaXacNhan', 'DaCheckIn')
              AND b_old.TrangThai IN ('ChoXacNhan', 'DaXacNhan', 'DaCheckIn')
              AND NOT (i.NgayTraDuKien <= bp_old.NgayNhanDuKien OR i.NgayNhanDuKien >= bp_old.NgayTraDuKien)
        )
        BEGIN
            RAISERROR(N'Lỗi nghiệp vụ: Phòng này đã có khách đặt trong khoảng thời gian yêu cầu!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 2: Chặn hủy đơn đặt phòng sau khi khách đã Check-in
-- Bảng: BOOKING | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_ChanHuyBookingSaiChinhSach
ON BOOKING
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThai)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN deleted d ON i.MaBooking = d.MaBooking
            INNER JOIN BOOKING_PHONG bp ON i.MaBooking = bp.MaBooking
            WHERE i.TrangThai = 'DaHuy'
              AND (d.TrangThai = 'DaCheckIn' OR bp.NgayCheckInThucTe IS NOT NULL)
        )
        BEGIN
            RAISERROR(N'Lỗi nghiệp vụ: Không thể hủy đơn đặt phòng khi khách đã Check-in lưu trú!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 3: Tự động đổi trạng thái phòng sang Occupied khi làm thủ tục Check-in
-- Bảng: BOOKING_PHONG | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_DongBoTrangThaiPhongCheckIn
ON BOOKING_PHONG
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(NgayCheckInThucTe)
    BEGIN
        UPDATE p
        SET p.TrangThai = 'Occupied'
        FROM PHONG p
        INNER JOIN inserted i ON p.MaPhong = i.MaPhong
        INNER JOIN deleted d ON i.MaBooking = d.MaBooking AND i.MaPhong = d.MaPhong
        WHERE d.NgayCheckInThucTe IS NULL AND i.NgayCheckInThucTe IS NOT NULL AND i.NgayCheckOutThucTe IS NULL;
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 4: Tự động đổi phòng sang Dirty và tạo việc dọn dẹp khi Check-out
-- Bảng: BOOKING_PHONG | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_TuDongDonPhongSauCheckOut
ON BOOKING_PHONG
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(NgayCheckOutThucTe)
    BEGIN
        -- 1. Đổi trạng thái phòng sang 'Dirty' khi chuyển từ chưa check-out sang đã check-out
        UPDATE p
        SET p.TrangThai = 'Dirty'
        FROM PHONG p
        INNER JOIN inserted i ON p.MaPhong = i.MaPhong
        INNER JOIN deleted d ON i.MaBooking = d.MaBooking AND i.MaPhong = d.MaPhong
        WHERE d.NgayCheckOutThucTe IS NULL AND i.NgayCheckOutThucTe IS NOT NULL;

        -- 2. Tự động tạo nhiệm vụ dọn phòng nếu chưa có nhiệm vụ nào đang chờ xử lý
        INSERT INTO NHIEMVUDOPHONG (MaNhiemVu, MaPhong, MaNV, ThoiGianNhan, TrangThai)
        SELECT 
            'NV' + SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8),
            i.MaPhong,
            NULL,
            GETDATE(),
            'ChoXuLy'
        FROM inserted i
        INNER JOIN deleted d ON i.MaBooking = d.MaBooking AND i.MaPhong = d.MaPhong
        WHERE d.NgayCheckOutThucTe IS NULL AND i.NgayCheckOutThucTe IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM NHIEMVUDOPHONG 
              WHERE MaPhong = i.MaPhong AND TrangThai IN ('ChoXuLy', 'DangDon')
          );
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 5: Tự động sinh Hóa đơn tổng duy nhất khi tạo Booking (Phương án A)
-- Bảng: BOOKING | Sự kiện: AFTER INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_TuDongTaoHoaDonKhiDatPhong
ON BOOKING
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO HOADON (MaHoaDon, MaBooking, NgayLap, TongTienCuoiCung, MaNV, TrangThai)
    SELECT 
        'HD' + SUBSTRING(i.MaBooking, 3, 8),
        i.MaBooking,
        GETDATE(),
        NULL,
        ISNULL(i.MaNV, 'NV001'),
        'ChuaThanhToan'
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM HOADON WHERE MaBooking = i.MaBooking);
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 6: Tự động đối soát tiền nạp và cập nhật trạng thái thanh toán hóa đơn
-- Bảng: THANHTOAN | Sự kiện: AFTER INSERT, UPDATE, DELETE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_CapNhatTrangThaiHoaDon
ON THANHTOAN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HoaDonList TABLE (MaHoaDon VARCHAR(10));
    INSERT INTO @HoaDonList SELECT DISTINCT MaHoaDon FROM inserted
    UNION SELECT DISTINCT MaHoaDon FROM deleted;

    UPDATE hd
    SET hd.TrangThai = 
        CASE 
            WHEN ISNULL(DaThu.TongThu, 0) >= ISNULL(hd.TongTienCuoiCung, b.ChiPhiDuKien) AND ISNULL(DaThu.TongThu, 0) > 0
                THEN 'DaThanhToanDu'
            WHEN ISNULL(DaThu.TongThu, 0) > 0
                THEN 'MotPhan'
            ELSE 'ChuaThanhToan'
        END
    FROM HOADON hd
    INNER JOIN BOOKING b ON hd.MaBooking = b.MaBooking
    INNER JOIN @HoaDonList hl ON hd.MaHoaDon = hl.MaHoaDon
    OUTER APPLY (
        SELECT SUM(SoTien) AS TongThu
        FROM THANHTOAN
        WHERE MaHoaDon = hd.MaHoaDon
    ) DaThu;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 7: Tự động khóa tài khoản khi nhân viên nghỉ việc
-- Bảng: NHANVIEN | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_KhoaTaiKhoanKhiNghiViec
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThaiLamViec) OR UPDATE(NgayNghiLam)
    BEGIN
        UPDATE tk
        SET tk.TrangThai = 'Locked'
        FROM TAIKHOAN tk
        INNER JOIN inserted i ON tk.MaTaiKhoan = i.MaTaiKhoan
        WHERE i.TrangThaiLamViec = 'NghiViec' 
           OR (i.NgayNghiLam IS NOT NULL AND i.NgayNghiLam <= CAST(GETDATE() AS DATE));
    END
END;
GO

-- ============================================================================
-- PHẦN BỔ SUNG: HỆ THỐNG TRIGGER TỰ ĐỘNG SINH KHÓA CHÍNH (PRIMARY KEY AUTO-PK)
-- Triệt tiêu hoàn toàn lỗi Self-Deadlock giao dịch và tối ưu hóa xử lý đồng thời
-- ============================================================================

-- Đảm bảo các bảng có ràng buộc DEFAULT '' để client có thể INSERT mà không cần truyền mã
IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('BOOKING_DICHVU') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('BOOKING_DICHVU'), 'MaBookingDichVu', 'ColumnId'))
    ALTER TABLE BOOKING_DICHVU ADD CONSTRAINT DF_BDV_MaBookingDichVu DEFAULT '' FOR MaBookingDichVu;

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('BOOKING') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('BOOKING'), 'MaBooking', 'ColumnId'))
    ALTER TABLE BOOKING ADD CONSTRAINT DF_BOOKING_MaBooking DEFAULT '' FOR MaBooking;

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('KHACHHANG') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('KHACHHANG'), 'MaKH', 'ColumnId'))
    ALTER TABLE KHACHHANG ADD CONSTRAINT DF_KH_MaKH DEFAULT '' FOR MaKH;

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('TAIKHOAN') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('TAIKHOAN'), 'MaTaiKhoan', 'ColumnId'))
    ALTER TABLE TAIKHOAN ADD CONSTRAINT DF_TK_MaTaiKhoan DEFAULT '' FOR MaTaiKhoan;

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('THANHTOAN') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('THANHTOAN'), 'MaThanhToan', 'ColumnId'))
    ALTER TABLE THANHTOAN ADD CONSTRAINT DF_TT_MaThanhToan DEFAULT '' FOR MaThanhToan;

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('HOADON') AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('HOADON'), 'MaHoaDon', 'ColumnId'))
    ALTER TABLE HOADON ADD CONSTRAINT DF_HD_MaHoaDon DEFAULT '' FOR MaHoaDon;
GO

-- ----------------------------------------------------------------------------
-- Trigger 8: Tự động sinh khóa chính MaBookingDichVu (BDV...)
-- Bảng: BOOKING_DICHVU | Sự kiện: INSTEAD OF INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_AutoPK_BOOKING_DICHVU
ON BOOKING_DICHVU
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(MaBookingDichVu, PATINDEX('%[0-9]%', MaBookingDichVu), 10) AS INT)), 0)
    FROM BOOKING_DICHVU WITH (NOLOCK);

    INSERT INTO BOOKING_DICHVU (
        MaBookingDichVu, MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem, MaNV
    )
    SELECT
        CASE 
            WHEN ISNULL(i.MaBookingDichVu, '') = '' 
                THEN 'BDV' + RIGHT('000' + CAST(@MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 3)
            ELSE i.MaBookingDichVu
        END,
        i.MaBooking,
        i.MaPhong,
        i.MaDichVu,
        i.DonGia,
        ISNULL(i.SoLuong, 1),
        ISNULL(i.ThoiDiemThem, GETDATE()),
        i.NguoiThem,
        i.MaNV
    FROM inserted i;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 9: Tự động sinh khóa chính MaBooking (BK...)
-- Bảng: BOOKING | Sự kiện: INSTEAD OF INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_AutoPK_BOOKING
ON BOOKING
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(MaBooking, PATINDEX('%[0-9]%', MaBooking), 10) AS INT)), 0)
    FROM BOOKING WITH (NOLOCK);

    INSERT INTO BOOKING (
        MaBooking, MaKH, MaTaiKhoan, MaNV, NgayDat, TrangThai, ChiPhiDuKien, PhuongPhapBooking, ThoiDiemHuy, PhiHuy
    )
    SELECT
        CASE 
            WHEN ISNULL(i.MaBooking, '') = '' 
                THEN 'BK' + RIGHT('000' + CAST(@MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 3)
            ELSE i.MaBooking
        END,
        i.MaKH,
        i.MaTaiKhoan,
        i.MaNV,
        ISNULL(i.NgayDat, GETDATE()),
        ISNULL(i.TrangThai, 'ChoXacNhan'),
        i.ChiPhiDuKien,
        ISNULL(i.PhuongPhapBooking, 'Online'),
        i.ThoiDiemHuy,
        i.PhiHuy
    FROM inserted i;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 10: Tự động sinh khóa chính MaKH (KH...)
-- Bảng: KHACHHANG | Sự kiện: INSTEAD OF INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_AutoPK_KHACHHANG
ON KHACHHANG
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(MaKH, PATINDEX('%[0-9]%', MaKH), 10) AS INT)), 0)
    FROM KHACHHANG WITH (NOLOCK);

    INSERT INTO KHACHHANG (
        MaKH, HoTen, Email, SoDT, CCCD
    )
    SELECT
        CASE
            WHEN ISNULL(i.MaKH, '') = ''
                THEN 'KH' + RIGHT('000' + CAST(@MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 3)
            ELSE i.MaKH
        END,
        i.HoTen,
        i.Email,
        i.SoDT,
        i.CCCD
    FROM inserted i;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 11: Tự động sinh khóa chính MaTaiKhoan (TK...)
-- Bảng: TAIKHOAN | Sự kiện: INSTEAD OF INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_AutoPK_TAIKHOAN
ON TAIKHOAN
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(MaTaiKhoan, PATINDEX('%[0-9]%', MaTaiKhoan), 10) AS INT)), 0)
    FROM TAIKHOAN WITH (NOLOCK);

    INSERT INTO TAIKHOAN (
        MaTaiKhoan, MatKhau, MaVaiTro, TrangThai, HoTenTaiKhoan, Email
    )
    SELECT
        CASE 
            WHEN ISNULL(i.MaTaiKhoan, '') = '' 
                THEN 'TK' + RIGHT('000' + CAST(@MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 3)
            ELSE i.MaTaiKhoan
        END,
        i.MatKhau,
        i.MaVaiTro,
        ISNULL(i.TrangThai, 'Active'),
        i.HoTenTaiKhoan,
        i.Email
    FROM inserted i;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 12: Tự động sinh khóa chính MaThanhToan (TT...)
-- Bảng: THANHTOAN | Sự kiện: INSTEAD OF INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_AutoPK_THANHTOAN
ON THANHTOAN
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(MaThanhToan, PATINDEX('%[0-9]%', MaThanhToan), 10) AS INT)), 0)
    FROM THANHTOAN WITH (NOLOCK);

    INSERT INTO THANHTOAN (
        MaThanhToan, MaHoaDon, MaNV, SoTien, PhuongThucThanhToan, ThoiDiemThanhToan
    )
    SELECT
        CASE 
            WHEN ISNULL(i.MaThanhToan, '') = '' 
                THEN 'TT' + RIGHT('000' + CAST(@MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 3)
            ELSE i.MaThanhToan
        END,
        i.MaHoaDon,
        i.MaNV,
        i.SoTien,
        ISNULL(i.PhuongThucThanhToan, 'TienMat'),
        ISNULL(i.ThoiDiemThanhToan, GETDATE())
    FROM inserted i;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 13: Tự động sinh khóa chính MaHoaDon (HD...)
-- Bảng: HOADON | Sự kiện: INSTEAD OF INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_AutoPK_HOADON
ON HOADON
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(MaHoaDon, PATINDEX('%[0-9]%', MaHoaDon), 10) AS INT)), 0)
    FROM HOADON WITH (NOLOCK);

    INSERT INTO HOADON (
        MaHoaDon, MaBooking, NgayLap, TongTienCuoiCung, MaNV, TrangThai
    )
    SELECT
        CASE 
            WHEN ISNULL(i.MaHoaDon, '') = '' 
                THEN 'HD' + RIGHT('000' + CAST(@MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS VARCHAR(10)), 3)
            ELSE i.MaHoaDon
        END,
        i.MaBooking,
        ISNULL(i.NgayLap, GETDATE()),
        i.TongTienCuoiCung,
        ISNULL(i.MaNV, 'NV001'),
        ISNULL(i.TrangThai, 'ChuaThanhToan')
    FROM inserted i;
END;
GO
