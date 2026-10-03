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
@MaKH VARCHAR (10), @MaPhong VARCHAR (10), @NgayNhan DATE, @NgayTra DATE, @MaBookingMoi VARCHAR (20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra ngày hợp lệ
        IF @NgayNhan >= @NgayTra
           OR @NgayNhan < CAST (GETDATE() AS DATE)
            BEGIN
                RAISERROR (N'Ngày nhận và trả phòng không hợp lệ!', 16, 1);
                RETURN -1;
            END
        -- 2. Kiểm tra khách hàng tồn tại
        IF NOT EXISTS (SELECT 1
                       FROM   KHACHHANG
                       WHERE  MaKH = @MaKH)
            BEGIN
                RAISERROR (N'Không tìm thấy thông tin khách hàng đại diện!', 16, 1);
                RETURN -2;
            END
        -- 3. Kiểm tra phòng có trống không bằng hàm fn_KiemTraPhongTrongTrongKhoang
        IF dbo.fn_KiemTraPhongTrongTrongKhoang(@MaPhong, @NgayNhan, @NgayTra, NULL) = 0
            BEGIN
                RAISERROR (N'Phòng đã chọn hiện không khả dụng trong khoảng thời gian này!', 16, 1);
                RETURN -3;
            END
        -- 4. Lấy giá niêm yết của phòng
        DECLARE @GiaPhong AS DECIMAL (18, 2);
        SELECT @GiaPhong = lp.GiaPhong
        FROM   PHONG AS p
               INNER JOIN
               LOAIPHONG AS lp
               ON p.MaLoaiPhong = lp.MaLoaiPhong
        WHERE  p.MaPhong = @MaPhong;
        DECLARE @SoDem AS INT = DATEDIFF(DAY, @NgayNhan, @NgayTra);
        IF @SoDem <= 0
            SET @SoDem = 1;
        DECLARE @ChiPhiDuKien AS DECIMAL (18, 2) = @GiaPhong * @SoDem;
        -- 5. Sinh mã Booking mới (tiền tố BK_ + 7 ký tự UUID = 10 ký tự)
        SET @MaBookingMoi = 'BK_' + SUBSTRING(CONVERT (VARCHAR (36), NEWID()), 1, 7);
        -- 6. Chèn vào bảng BOOKING và BOOKING_PHONG trong Transaction
        BEGIN TRANSACTION;
        INSERT  INTO BOOKING (
            MaBooking,
            MaKH,
            NgayDat,
            ChiPhiDuKien,
            TrangThai,
            MaNV
        )
        VALUES               (@MaBookingMoi, @MaKH, GETDATE(), @ChiPhiDuKien, 'DaXacNhan', NULL);
        INSERT  INTO BOOKING_PHONG (
            MaBooking,
            MaPhong,
            DonGiaPhong,
            NgayNhanDuKien,
            NgayTraDuKien,
            NgayCheckInThucTe,
            NgayCheckOutThucTe
        )
        VALUES                     (@MaBookingMoi, @MaPhong, @GiaPhong, @NgayNhan, @NgayTra, NULL, NULL);
        COMMIT TRANSACTION;
        RETURN 0; -- Thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 2: Thủ tục Check-in nhận phòng tại quầy
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_CheckInNhanPhong
@MaBooking VARCHAR (10), @MaNV VARCHAR (10), @MaPhong VARCHAR (10)=NULL -- NULL = Check-in tất cả các phòng; Hoặc truyền mã để Check-in riêng từng phòng
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Kiểm tra đơn đặt phòng
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING
                       WHERE  MaBooking = @MaBooking
                              AND TrangThai IN ('DaXacNhan', 'DaCheckIn'))
            BEGIN
                RAISERROR (N'Đơn đặt phòng không tồn tại hoặc không ở trạng thái hợp lệ để Check-in!', 16, 1);
                RETURN -1;
            END
        -- Nếu chỉ định phòng cụ thể, kiểm tra phòng đó có thuộc đơn không và chưa check-in
        IF @MaPhong IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   BOOKING_PHONG
                           WHERE  MaBooking = @MaBooking
                                  AND MaPhong = @MaPhong
                                  AND NgayCheckInThucTe IS NULL)
            BEGIN
                RAISERROR (N'Phòng chỉ định không thuộc đơn đặt phòng này hoặc đã Check-in trước đó!', 16, 1);
                RETURN -2;
            END
        BEGIN TRANSACTION;
        -- Cập nhật giờ check-in thực tế (cho phòng chỉ định hoặc toàn bộ phòng chưa check-in trong đơn)
        UPDATE BOOKING_PHONG
        SET    NgayCheckInThucTe = GETDATE()
        WHERE  MaBooking = @MaBooking
               AND (@MaPhong IS NULL
                    OR MaPhong = @MaPhong)
               AND NgayCheckInThucTe IS NULL;
        IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR (N'Phòng chỉ định không thuộc đơn đặt phòng này hoặc đã Check-in trước đó!', 16, 1);
            END
        -- Cập nhật trạng thái đơn đặt phòng sang 'DaCheckIn' và ghi nhận nhân viên làm thủ tục
        UPDATE BOOKING
        SET    TrangThai = 'DaCheckIn',
               MaNV      = @MaNV
        WHERE  MaBooking = @MaBooking;
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 3: Gọi thêm dịch vụ gia tăng vào phòng
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GoiThemDichVu
@MaBooking VARCHAR (10), @MaPhong VARCHAR (10)=NULL, -- NULL nếu là dịch vụ dùng chung cho cả đoàn, có mã nếu gọi riêng cho phòng
@MaDichVu VARCHAR (10), @SoLuong INT, @NguoiThem VARCHAR (20)='KhachHang', @MaNV VARCHAR (10)=NULL, @MaBookingDichVuMoi VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @SoLuong <= 0
            BEGIN
                RAISERROR (N'Số lượng dịch vụ phải lớn hơn 0!', 16, 1);
                RETURN -1;
            END
        -- Chỉ cho phép gọi dịch vụ khi đang ở trạng thái DaCheckIn
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING
                       WHERE  MaBooking = @MaBooking
                              AND TrangThai = 'DaCheckIn')
            BEGIN
                RAISERROR (N'Chỉ có thể gọi thêm dịch vụ khi khách đang lưu trú tại khách sạn!', 16, 1);
                RETURN -2;
            END
        -- Kiểm tra dịch vụ có tồn tại và đang kinh doanh không
        DECLARE @DonGia AS DECIMAL (18, 2);
        SELECT @DonGia = DonGia
        FROM   DICHVU
        WHERE  MaDichVu = @MaDichVu
               AND TrangThai = 'ApDung';
        IF @DonGia IS NULL
            BEGIN
                RAISERROR (N'Dịch vụ không tồn tại hoặc đang tạm ngưng cung cấp (NgungApDung)!', 16, 1);
                RETURN -3;
            END
        -- Nếu có chỉ định phòng, kiểm tra phòng đó có thực sự thuộc đơn booking này không (Chuẩn 3NF)
        IF @MaPhong IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   BOOKING_PHONG
                           WHERE  MaBooking = @MaBooking
                                  AND MaPhong = @MaPhong)
            BEGIN
                RAISERROR (N'Phòng được chỉ định không thuộc đơn đặt phòng này!', 16, 1);
                RETURN -4;
            END
        SET @MaBookingDichVuMoi = 'BDV_' + SUBSTRING(CONVERT (VARCHAR (36), NEWID()), 1, 6);
        INSERT  INTO BOOKING_DICHVU (
            MaBookingDichVu,
            MaBooking,
            MaPhong,
            MaDichVu,
            DonGia,
            SoLuong,
            ThoiDiemThem,
            NguoiThem,
            MaNV
        )
        VALUES                      (@MaBookingDichVuMoi, @MaBooking, @MaPhong, @MaDichVu, @DonGia, @SoLuong, GETDATE(), @NguoiThem, @MaNV);
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 4: Quyết toán hóa đơn và Check-out trả phòng
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_QuyetToanVaCheckOut
@MaBooking VARCHAR (10), @MaNV VARCHAR (10), @TongTienCuoiCung DECIMAL (18, 2) OUTPUT, @DaThanhToan DECIMAL (18, 2) OUTPUT, @ConThieu DECIMAL (18, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING
                       WHERE  MaBooking = @MaBooking
                              AND TrangThai = 'DaCheckIn')
            BEGIN
                RAISERROR (N'Đơn đặt phòng không ở trạng thái lưu trú để làm thủ tục trả phòng!', 16, 1);
                RETURN -1;
            END
        BEGIN TRANSACTION;
        -- 1. Tính tổng tiền thực tế cuối cùng bằng hàm fn_TinhTongTienThucTePhaiTra
        SET @TongTienCuoiCung = dbo.fn_TinhTongTienThucTePhaiTra(@MaBooking);
        -- 2. Cập nhật hóa đơn
        UPDATE HOADON
        SET    TongTienCuoiCung = @TongTienCuoiCung,
               MaNV             = @MaNV
        WHERE  MaBooking = @MaBooking;
        -- 3. Tính tiền đã trả và tiền còn thiếu
        SELECT @DaThanhToan = ISNULL(SUM(tt.SoTien), 0)
        FROM   THANHTOAN AS tt
               INNER JOIN
               HOADON AS hd
               ON tt.MaHoaDon = hd.MaHoaDon
        WHERE  hd.MaBooking = @MaBooking;
        SET @ConThieu = @TongTienCuoiCung - @DaThanhToan;
        -- 4. Cập nhật giờ check-out thực tế
        UPDATE BOOKING_PHONG
        SET    NgayCheckOutThucTe = GETDATE()
        WHERE  MaBooking = @MaBooking
               AND NgayCheckOutThucTe IS NULL;
        -- 5. Cập nhật trạng thái đơn đặt phòng
        UPDATE BOOKING
        SET    TrangThai = 'DaCheckOut',
               MaNV      = @MaNV
        WHERE  MaBooking = @MaBooking;
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure: sp_CheckOut - Thủ tục Check-out trả phòng độc lập (Phase 4)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_CheckOut
@MaBooking VARCHAR (10), @MaNV VARCHAR (10), @MaPhong VARCHAR (10)=NULL -- NULL = Check-out tất cả các phòng; Hoặc truyền mã để Check-out riêng từng phòng
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra đơn booking có tồn tại không
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING
                       WHERE  MaBooking = @MaBooking)
            BEGIN
                RAISERROR (N'Đơn đặt phòng không tồn tại trên hệ thống!', 16, 1);
                RETURN -1;
            END
        -- Nếu đơn đã hủy
        IF EXISTS (SELECT 1
                   FROM   BOOKING
                   WHERE  MaBooking = @MaBooking
                          AND TrangThai = 'DaHuy')
            BEGIN
                RAISERROR (N'Không thể Check-out đơn đặt phòng đã bị hủy!', 16, 1);
                RETURN -1;
            END
        -- 2. Nếu chỉ định phòng cụ thể
        IF @MaPhong IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1
                               FROM   BOOKING_PHONG
                               WHERE  MaBooking = @MaBooking
                                      AND MaPhong = @MaPhong)
                    BEGIN
                        RAISERROR (N'Phòng chỉ định không thuộc đơn đặt phòng này!', 16, 1);
                        RETURN -2;
                    END
                -- Nếu phòng này đã Check-out trước đó rồi thì coi như thành công (idempotent)
                IF EXISTS (SELECT 1
                           FROM   BOOKING_PHONG
                           WHERE  MaBooking = @MaBooking
                                  AND MaPhong = @MaPhong
                                  AND NgayCheckOutThucTe IS NOT NULL)
                    BEGIN
                        RETURN 0;
                    END
            END
        ELSE
            BEGIN
                -- Nếu toàn bộ phòng trong đơn đã Check-out trước đó rồi thì coi như thành công
                IF NOT EXISTS (SELECT 1
                               FROM   BOOKING_PHONG
                               WHERE  MaBooking = @MaBooking
                                      AND NgayCheckOutThucTe IS NULL)
                    BEGIN
                        RETURN 0;
                    END
            END
        BEGIN TRANSACTION;
        -- 3. Cập nhật giờ Check-out thực tế cho phòng chỉ định (hoặc toàn bộ phòng chưa trả)
        -- (Sự kiện UPDATE này sẽ kích hoạt trigger trg_TuDongDonPhongSauCheckOut để chuyển phòng sang Dirty và tạo việc dọn dẹp)
        UPDATE BOOKING_PHONG
        SET    NgayCheckOutThucTe = GETDATE()
        WHERE  MaBooking = @MaBooking
               AND (@MaPhong IS NULL
                    OR MaPhong = @MaPhong)
               AND NgayCheckInThucTe IS NOT NULL
               AND NgayCheckOutThucTe IS NULL;
        IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR (N'Không tìm thấy phòng hợp lệ cần Check-out trong đơn đặt phòng này!', 16, 1);
                ROLLBACK;
                RETURN -3;
            END
        -- 4. CHỈ KHI TẤT CẢ CÁC PHÒNG TRONG ĐƠN ĐÃ CHECK-OUT HẾT MỚI ĐỔI TRẠNG THÁI BOOKING SANG 'DaCheckOut'
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING_PHONG
                       WHERE  MaBooking = @MaBooking
                              AND NgayCheckOutThucTe IS NULL)
            BEGIN
                UPDATE BOOKING
                SET    TrangThai = 'DaCheckOut',
                       MaNV      = @MaNV
                WHERE  MaBooking = @MaBooking;
            END
        ELSE
            BEGIN
                -- Nếu vẫn còn phòng chưa trả, đơn BOOKING vẫn giữ nguyên 'DaCheckIn', chỉ cập nhật nhân viên phụ trách gần nhất
                UPDATE BOOKING
                SET    MaNV = @MaNV
                WHERE  MaBooking = @MaBooking;
            END
        COMMIT TRANSACTION;
        RETURN 0; -- Thành công
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure: sp_TaoHoaDon - Thủ tục Lập / Cập nhật Hóa đơn quyết toán (Phase 4 - Phương án B)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_TaoHoaDon
@MaBooking VARCHAR (10), @MaNV VARCHAR (10), @MaHoaDonMoi VARCHAR (20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra đơn đặt phòng có tồn tại không
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING
                       WHERE  MaBooking = @MaBooking)
            BEGIN
                RAISERROR (N'Đơn đặt phòng không tồn tại trên hệ thống!', 16, 1);
                RETURN -1;
            END
        -- 2. Kiểm tra trạng thái đơn: không lập hóa đơn cho đơn đã bị hủy
        IF EXISTS (SELECT 1
                   FROM   BOOKING
                   WHERE  MaBooking = @MaBooking
                          AND TrangThai = 'DaHuy')
            BEGIN
                RAISERROR (N'Không thể lập hóa đơn cho đơn đặt phòng đã bị hủy!', 16, 1);
                RETURN -2;
            END
        -- 3. Chỉ cho phép lập/cập nhật hóa đơn khi đơn đã xác nhận, đang lưu trú hoặc đã trả phòng
        IF NOT EXISTS (SELECT 1
                       FROM   BOOKING
                       WHERE  MaBooking = @MaBooking
                              AND TrangThai IN ('DaXacNhan', 'DaCheckIn', 'DaCheckOut'))
            BEGIN
                RAISERROR (N'Đơn đặt phòng không ở trạng thái hợp lệ để lập/cập nhật hóa đơn!', 16, 1);
                RETURN -3;
            END
        BEGIN TRANSACTION;
        -- 4. Tính toán tổng tiền thực tế phải trả tính đến thời điểm hiện tại (Phòng + Dịch vụ)
        -- Với các phòng đã Check-out: tính theo số đêm thực tế (NgayCheckOutThucTe)
        -- Với các phòng chưa Check-out: tạm tính theo ngày trả dự kiến (NgayTraDuKien)
        DECLARE @TongTien AS DECIMAL (18, 2) = ISNULL(dbo.fn_TinhTongTienThucTePhaiTra(@MaBooking), 0);
        -- 5. Kiểm tra hóa đơn đã tồn tại cho đơn đặt phòng này chưa (1 Booking - 1 Hóa đơn)
        SELECT @MaHoaDonMoi = MaHoaDon
        FROM   HOADON
        WHERE  MaBooking = @MaBooking;
        IF @MaHoaDonMoi IS NOT NULL
            BEGIN
                -- Tính tổng tiền khách đã thanh toán trước đó (nếu có)
                DECLARE @DaThu AS DECIMAL (18, 2) = 0;
                SELECT @DaThu = ISNULL(SUM(SoTien), 0)
                FROM   THANHTOAN
                WHERE  MaHoaDon = @MaHoaDonMoi;
                -- Cập nhật tổng tiền cuối cùng và đồng bộ lại trạng thái hóa đơn
                UPDATE HOADON
                SET    TongTienCuoiCung = @TongTien,
                       MaNV             = @MaNV,
                       NgayLap          = GETDATE(),
                       TrangThai        = CASE WHEN @DaThu >= @TongTien
                                                    AND @DaThu > 0 THEN 'DaThanhToanDu' WHEN @DaThu > 0 THEN 'MotPhan' ELSE 'ChuaThanhToan' END
                WHERE  MaHoaDon = @MaHoaDonMoi;
            END
        ELSE
            BEGIN
                -- Tạo mã hóa đơn tương ứng với đơn đặt phòng
                SET @MaHoaDonMoi = 'HD' + SUBSTRING(@MaBooking, 3, 8);
                -- Nếu mã bị trùng trên hệ thống, sinh mã ngẫu nhiên 10 ký tự
                IF EXISTS (SELECT 1
                           FROM   HOADON
                           WHERE  MaHoaDon = @MaHoaDonMoi)
                    SET @MaHoaDonMoi = 'HD_' + SUBSTRING(CONVERT (VARCHAR (36), NEWID()), 1, 7);
                INSERT  INTO HOADON (
                    MaHoaDon,
                    MaBooking,
                    NgayLap,
                    TongTienCuoiCung,
                    MaNV,
                    TrangThai
                )
                VALUES              (@MaHoaDonMoi, @MaBooking, GETDATE(), @TongTien, @MaNV, 'ChuaThanhToan');
            END
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 5: Ghi nhận thanh toán và đặt cọc (Phase 4 - Phương án B)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_GhiNhanThanhToan
@MaHoaDon VARCHAR (10), @MaNV VARCHAR (10), @SoTien DECIMAL (18, 2), @PhuongThucThanhToan VARCHAR (20)='TienMat', @MaThanhToanMoi VARCHAR (20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra số tiền hợp lệ
        IF @SoTien <= 0
            BEGIN
                RAISERROR (N'Số tiền thanh toán phải lớn hơn 0!', 16, 1);
                RETURN -1;
            END
        -- 2. Kiểm tra hóa đơn có tồn tại không và lấy thông tin liên quan
        DECLARE @MaBooking AS VARCHAR (10);
        DECLARE @TongTien AS DECIMAL (18, 2);
        DECLARE @TrangThaiHD AS VARCHAR (20);
        SELECT @MaBooking = hd.MaBooking,
               @TongTien = hd.TongTienCuoiCung,
               @TrangThaiHD = hd.TrangThai
        FROM   HOADON AS hd
        WHERE  hd.MaHoaDon = @MaHoaDon;
        IF @MaBooking IS NULL
            BEGIN
                RAISERROR (N'Hóa đơn không tồn tại trên hệ thống!', 16, 1);
                RETURN -2;
            END
        -- 3. Kiểm tra đơn đặt phòng không bị hủy
        IF EXISTS (SELECT 1
                   FROM   BOOKING
                   WHERE  MaBooking = @MaBooking
                          AND TrangThai = 'DaHuy')
            BEGIN
                RAISERROR (N'Không thể ghi nhận thanh toán cho đơn đặt phòng đã bị hủy!', 16, 1);
                RETURN -2;
            END
        -- 4. Kiểm tra hóa đơn đã thanh toán đủ chưa
        IF @TrangThaiHD = 'DaThanhToanDu'
            BEGIN
                RAISERROR (N'Hóa đơn này đã được thanh toán đủ, không thể thu thêm tiền!', 16, 1);
                RETURN -3;
            END
        -- 5. Tính tổng số tiền đã thanh toán trước đó
        DECLARE @DaThanhToan AS DECIMAL (18, 2) = 0;
        SELECT @DaThanhToan = ISNULL(SUM(SoTien), 0)
        FROM   THANHTOAN
        WHERE  MaHoaDon = @MaHoaDon;
        DECLARE @TongSauThanhToan AS DECIMAL (18, 2) = @DaThanhToan + @SoTien;
        -- 6. Nếu hóa đơn đã có tổng tiền xác định, kiểm tra không thu vượt quá số tiền còn thiếu
        IF @TongTien IS NOT NULL
           AND @TongTien > 0
            BEGIN
                IF @TongSauThanhToan > @TongTien
                    BEGIN
                        DECLARE @ConThieu AS DECIMAL (18, 2) = @TongTien - @DaThanhToan;
                        DECLARE @Msg AS NVARCHAR (500) = N'Số tiền thanh toán (' + CAST (@SoTien AS NVARCHAR (30)) + N') vượt quá số tiền còn thiếu (' + CAST (@ConThieu AS NVARCHAR (30)) + N')!';
                        RAISERROR (@Msg, 16, 1);
                        RETURN -4;
                    END
            END
        -- 7. RÀNG BUỘC PHƯƠNG ÁN B:
        -- Nếu đợt thanh toán này sẽ tất toán đủ 100% hóa đơn (@TongSauThanhToan >= @TongTien),
        -- nhưng đơn đặt phòng vẫn còn phòng chưa hoàn tất Check-out -> CHẶN LẠI!
        IF @TongTien IS NOT NULL
           AND @TongSauThanhToan >= @TongTien
            BEGIN
                IF EXISTS (SELECT 1
                           FROM   BOOKING_PHONG
                           WHERE  MaBooking = @MaBooking
                                  AND NgayCheckOutThucTe IS NULL)
                    BEGIN
                        RAISERROR (N'Không thể tất toán đủ hóa đơn khi đơn đặt phòng vẫn còn phòng chưa thực hiện Check-out! Vui lòng chỉ thanh toán tạm tính từng phần hoặc hoàn tất Check-out tất cả các phòng trước khi thanh toán hết.', 16, 1);
                        RETURN -5;
                    END
            END
        BEGIN TRANSACTION;
        -- 8. Ghi nhận giao dịch thanh toán vào bảng THANHTOAN
        SET @MaThanhToanMoi = 'TT_' + SUBSTRING(CONVERT (VARCHAR (36), NEWID()), 1, 7);
        INSERT  INTO THANHTOAN (
            MaThanhToan,
            MaHoaDon,
            MaNV,
            SoTien,
            PhuongThucThanhToan,
            ThoiDiemThanhToan
        )
        VALUES                 (@MaThanhToanMoi, @MaHoaDon, @MaNV, @SoTien, @PhuongThucThanhToan, GETDATE());
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsgCatch AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsgCatch, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 6: Quy trình buồng phòng nhận và hoàn thành dọn dẹp
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_CapNhatTienDoDonPhong
@MaNhiemVu VARCHAR (10), @MaNV VARCHAR (10), @HanhDong VARCHAR (20), -- 'NhanViec' hoặc 'HoanThanh'
@KetQua VARCHAR (20)='KhongThietHai'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @MaPhong AS VARCHAR (10);
        DECLARE @TrangThaiNhiemVu AS VARCHAR (20);
        SELECT @MaPhong = MaPhong,
               @TrangThaiNhiemVu = TrangThai
        FROM   NHIEMVUDOPHONG
        WHERE  MaNhiemVu = @MaNhiemVu;
        IF @MaPhong IS NULL
            BEGIN
                RAISERROR (N'Nhiệm vụ dọn phòng không tồn tại!', 16, 1);
                RETURN -1;
            END
        BEGIN TRANSACTION;
        IF @HanhDong = 'NhanViec'
            BEGIN
                IF @TrangThaiNhiemVu <> 'ChoXuLy'
                    BEGIN
                        RAISERROR (N'Nhiệm vụ này đã được nhận dọn dẹp hoặc đã hoàn thành trước đó!', 16, 1);
                        ROLLBACK;
                        RETURN -2;
                    END
                UPDATE NHIEMVUDOPHONG
                SET    MaNV           = @MaNV,
                       ThoiGianBatDau = GETDATE(),
                       TrangThai      = 'DangDon'
                WHERE  MaNhiemVu = @MaNhiemVu;
                UPDATE PHONG
                SET    TrangThai = 'Cleaning'
                WHERE  MaPhong = @MaPhong;
            END
        ELSE
            IF @HanhDong = 'HoanThanh'
                BEGIN
                    IF @TrangThaiNhiemVu <> 'DangDon'
                        BEGIN
                            RAISERROR (N'Chỉ có thể hoàn thành nhiệm vụ đang trong quá trình dọn dẹp (DangDon)!', 16, 1);
                            ROLLBACK;
                            RETURN -3;
                        END
                    UPDATE NHIEMVUDOPHONG
                    SET    ThoiGianKetThuc = GETDATE(),
                           TrangThai       = 'HoanThanh',
                           KetQua          = @KetQua
                    WHERE  MaNhiemVu = @MaNhiemVu;
                    IF @KetQua = 'KhongThietHai'
                        UPDATE PHONG
                        SET    TrangThai = 'Available'
                        WHERE  MaPhong = @MaPhong;
                    ELSE
                        UPDATE PHONG
                        SET    TrangThai = 'Damaged'
                        WHERE  MaPhong = @MaPhong;
                END
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -99;
    END CATCH
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 7: Báo cáo tổng kết kinh doanh chốt ca theo ngày (Night Audit)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_BaoCaoTongHopKinhDoanhTheoNgay
@NgayBaoCao DATE=NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu không truyền ngày thì mặc định lấy ngày hôm nay
    IF @NgayBaoCao IS NULL
        SET @NgayBaoCao = CAST (GETDATE() AS DATE);
    SELECT @NgayBaoCao AS NgayBaoCao,
           -- Thống kê hoạt động buồng phòng trong ngày
           (SELECT COUNT(*)
            FROM   BOOKING
            WHERE  CAST (NgayDat AS DATE) = @NgayBaoCao) AS SoDonDatMoi,
           (SELECT COUNT(*)
            FROM   BOOKING_PHONG
            WHERE  CAST (NgayCheckInThucTe AS DATE) = @NgayBaoCao) AS SoPhongCheckIn,
           (SELECT COUNT(*)
            FROM   BOOKING_PHONG
            WHERE  CAST (NgayCheckOutThucTe AS DATE) = @NgayBaoCao) AS SoPhongCheckOut,
           -- Thống kê doanh thu thực thu trong ngày (từ bảng THANHTOAN)
           ISNULL(SUM(tt.SoTien), 0) AS TongTienThucThu,
           ISNULL(SUM(CASE WHEN tt.PhuongThucThanhToan = 'TienMat' THEN tt.SoTien END), 0) AS ThuTienMat,
           ISNULL(SUM(CASE WHEN tt.PhuongThucThanhToan = 'ChuyenKhoan' THEN tt.SoTien END), 0) AS ThuChuyenKhoan,
           ISNULL(SUM(CASE WHEN tt.PhuongThucThanhToan = 'TheNganHang' THEN tt.SoTien END), 0) AS ThuTheNganHang
    FROM   THANHTOAN AS tt
    WHERE  CAST (tt.ThoiDiemThanhToan AS DATE) = @NgayBaoCao;
END


GO
-- ----------------------------------------------------------------------------
-- Procedure 8: Báo cáo tổng kết kinh doanh tháng cho Quản lý / Giám đốc
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_BaoCaoTongHopKinhDoanhThang
@Thang INT, @Nam INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Thang AS ThangBaoCao,
           @Nam AS NamBaoCao,
           COUNT(DISTINCT b.MaBooking) AS TongSoDonBooking,
           COUNT(DISTINCT CASE WHEN b.TrangThai = 'DaCheckOut' THEN b.MaBooking END) AS SoDonHoanThanh,
           COUNT(DISTINCT CASE WHEN b.TrangThai = 'DaHuy' THEN b.MaBooking END) AS SoDonDaHuy,
           (SELECT ISNULL(SUM(SoTien), 0)
            FROM   THANHTOAN
            WHERE  MONTH(ThoiDiemThanhToan) = @Thang
                   AND YEAR(ThoiDiemThanhToan) = @Nam) AS TongTienThucThu
    FROM   BOOKING AS b
    WHERE  MONTH(b.NgayDat) = @Thang
           AND YEAR(b.NgayDat) = @Nam;
END