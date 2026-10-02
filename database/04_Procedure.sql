-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: HỆ THỐNG STORED PROCEDURE (THỦ TỤC NGHIỆP VỤ)
-- ============================================================================

USE QuanLyKhachSan;
GO

-- ----------------------------------------------------------------------------
-- Procedure 1: Đặt phòng trực tuyến cho khách hàng
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Procedure 2: Thủ tục Check-in nhận phòng tại quầy
-- ----------------------------------------------------------------------------
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

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR(N'Phòng chỉ định không thuộc đơn đặt phòng này hoặc đã Check-in trước đó!', 16, 1);
        END

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

-- ----------------------------------------------------------------------------
-- Procedure 3: Gọi thêm dịch vụ gia tăng vào phòng
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Procedure 4: Quyết toán hóa đơn và Check-out trả phòng
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Procedure 5: Ghi nhận thanh toán và đặt cọc
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Procedure 6: Quy trình buồng phòng nhận và hoàn thành dọn dẹp
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Procedure 7: Báo cáo tổng kết kinh doanh chốt ca theo ngày (Night Audit)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Procedure 8: Báo cáo tổng kết kinh doanh tháng cho Quản lý / Giám đốc
-- ----------------------------------------------------------------------------
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
