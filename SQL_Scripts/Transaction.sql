-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: HỆ THỐNG TRANSACTION (GIAO DỊCH TOÀN VẸN CHUẨN ACID)
-- ============================================================================

USE QuanLyKhachSan;
GO

-- ----------------------------------------------------------------------------
-- Transaction 1: Tạo đơn đặt phòng mới trọn gói (Booking + Phòng + Hóa đơn)
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Transaction 2: Check-in nhận phòng bàn giao chìa khóa
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Transaction 3: Check-out và thanh toán toàn bộ hóa đơn tại quầy
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- Transaction 4: Hủy đơn đặt phòng và giải phóng phòng trống
-- ----------------------------------------------------------------------------
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

        -- Bước B: Đưa hóa đơn về trạng thái 'ChuaThanhToan' và xóa công nợ vì khách không ở
        UPDATE HOADON
        SET TrangThai = 'ChuaThanhToan',
            TongTienCuoiCung = 0
        WHERE MaBooking = @MaBooking;

        -- Bước C: Xác nhận Transaction thành công
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

-- ----------------------------------------------------------------------------
-- Transaction 5: Hoàn tất dọn dẹp và tự động lập biên bản hư hại
-- ----------------------------------------------------------------------------
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
