-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
-- SCRIPT 04: HỆ THỐNG STORED PROCEDURE (THỦ TỤC NGHIỆP VỤ - CHUẨN 3NF)
-- HỆ QUẢN TRỊ CSDL: MICROSOFT SQL SERVER 2019 / 2022
-- ============================================================================
USE QuanLyKhachSan;


GO
-- ============================================================================
-- PROCEDURE 1: ĐẶT PHÒNG (CHO CẢ WEBSITE VÀ LỄ TÂN TẠI QUẦY)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DatPhong
@CustomerId VARCHAR (10), @CreateBy VARCHAR (10), -- AccountId của khách hàng hoặc nhân viên tạo đơn
@RoomId VARCHAR (10), @ExpectedCheckInDate DATE, @ExpectedCheckOutDate DATE, @Deposit DECIMAL (12, 2)=NULL, -- NULL nếu là khách vãng lai nhận phòng ngay
@NewBookingId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra tính hợp lệ của ngày lưu trú
        IF @ExpectedCheckInDate >= @ExpectedCheckOutDate
           OR @ExpectedCheckInDate < CAST (GETDATE() AS DATE)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Ngày nhận và ngày trả phòng dự kiến không hợp lệ!', 16, 1);
                RETURN -1;
            END
        -- 2. Kiểm tra khách hàng và tài khoản tồn tại
        IF NOT EXISTS (SELECT 1
                       FROM   Customer
                       WHERE  CustomerId = @CustomerId)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Không tìm thấy hồ sơ khách hàng đại diện!', 16, 1);
                RETURN -2;
            END
        IF NOT EXISTS (SELECT 1
                       FROM   Account
                       WHERE  AccountId = @CreateBy)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Tài khoản người tạo đơn không tồn tại!', 16, 1);
                RETURN -3;
            END
        -- 3. Kiểm tra phòng có trống và sẵn sàng không
        IF dbo.fn_KiemTraPhongTrongTrongKhoang(@RoomId, @ExpectedCheckInDate, @ExpectedCheckOutDate, NULL) = 0
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Phòng đã chọn hiện không khả dụng trong khoảng thời gian này!', 16, 1);
                RETURN -4;
            END
        -- 4. Lấy đơn giá niêm yết của phòng theo Hạng phòng
        DECLARE @BasePrice AS DECIMAL (12, 2);
        SELECT @BasePrice = rt.BasePrice
        FROM   Room AS r
               INNER JOIN
               RoomType AS rt
               ON r.RoomTypeId = rt.RoomTypeId
        WHERE  r.RoomId = @RoomId;
        -- 5. Sinh mã Booking mới
        SET @NewBookingId = dbo.fn_SinhMaBooking();
        -- 6. Giao dịch chèn dữ liệu (Trigger sẽ tự sinh Invoice và tính tiền phòng)
        BEGIN TRANSACTION;
        INSERT  INTO Booking (
            BookingId,
            CustomerId,
            CreateBy,
            CreateDate
        )
        VALUES               (@NewBookingId, @CustomerId, @CreateBy, GETDATE());
        INSERT  INTO Booking_Room (
            BookingId,
            RoomId,
            BookingStatus,
            ExpectedCheckInDate,
            ExpectedCheckOutDate,
            ActualCheckInDate,
            ActualCheckOutDate,
            Deposit,
            Price
        )
        VALUES                    (@NewBookingId, @RoomId, 'Confirmed', @ExpectedCheckInDate, @ExpectedCheckOutDate, NULL, NULL, @Deposit, @BasePrice);
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
-- ============================================================================
-- PROCEDURE 2: THỦ TỤC CHECK-IN NHẬN PHÒNG TẠI QUẦY LỄ TÂN
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_CheckInNhanPhong
@BookingId VARCHAR (10), @RoomId VARCHAR (10)=NULL -- NULL = Check-in toàn bộ phòng trong đơn; Truyền mã = Check-in riêng phòng đó
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1
                       FROM   Booking
                       WHERE  BookingId = @BookingId)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Đơn đặt phòng không tồn tại trên hệ thống!', 16, 1);
                RETURN -1;
            END
        -- Nếu chỉ định phòng cụ thể, kiểm tra phòng có thuộc đơn và đang Confirmed không
        IF @RoomId IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   Booking_Room
                           WHERE  BookingId = @BookingId
                                  AND RoomId = @RoomId
                                  AND BookingStatus = 'Confirmed')
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Phòng chỉ định không thuộc đơn đặt này hoặc đã được Check-in trước đó!', 16, 1);
                RETURN -2;
            END
        BEGIN TRANSACTION;
        -- Cập nhật ActualCheckInDate (Trigger sẽ tự đổi Room sang Occupied và tính phụ thu nhận sớm nếu trước 13:00)
        UPDATE Booking_Room
        SET    ActualCheckInDate = GETDATE(),
               BookingStatus     = 'CheckedIn'
        WHERE  BookingId = @BookingId
               AND (@RoomId IS NULL
                    OR RoomId = @RoomId)
               AND ActualCheckInDate IS NULL;
        IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Không tìm thấy phòng hợp lệ để làm thủ tục Check-in!', 16, 1);
                ROLLBACK;
                RETURN -3;
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
-- ============================================================================
-- PROCEDURE 3: GỌI THÊM DỊCH VỤ PHÁT SINH CHO PHÒNG
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GoiThemDichVu
@BookingId VARCHAR (10), @RoomId VARCHAR (10), @ServiceId VARCHAR (10), @Quantity INT=1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Quantity <= 0
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Số lượng dịch vụ gọi thêm phải lớn hơn 0!', 16, 1);
                RETURN -1;
            END
        -- 1. Chỉ cho phép gọi dịch vụ khi phòng đang lưu trú (CheckedIn)
        IF NOT EXISTS (SELECT 1
                       FROM   Booking_Room
                       WHERE  BookingId = @BookingId
                              AND RoomId = @RoomId
                              AND BookingStatus = 'CheckedIn')
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Chỉ có thể gọi thêm dịch vụ khi khách đang lưu trú tại phòng!', 16, 1);
                RETURN -2;
            END
        -- 2. Kiểm tra dịch vụ và lấy đơn giá niêm yết hiện tại
        DECLARE @UnitPrice AS DECIMAL (12, 2);
        SELECT @UnitPrice = BasePrice
        FROM   Service
        WHERE  ServiceId = @ServiceId;
        IF @UnitPrice IS NULL
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Dịch vụ không tồn tại trên hệ thống!', 16, 1);
                RETURN -3;
            END
        BEGIN TRANSACTION;
        -- 3. Nếu đã gọi dịch vụ này trước đó thì cộng dồn số lượng, ngược lại chèn mới
        IF EXISTS (SELECT 1
                   FROM   Booking_Room_Service
                   WHERE  BookingId = @BookingId
                          AND RoomId = @RoomId
                          AND ServiceId = @ServiceId)
            BEGIN
                UPDATE Booking_Room_Service
                SET    Quantity = Quantity + @Quantity
                WHERE  BookingId = @BookingId
                       AND RoomId = @RoomId
                       AND ServiceId = @ServiceId;
            END
        ELSE
            BEGIN
                INSERT  INTO Booking_Room_Service (
                    BookingId,
                    RoomId,
                    ServiceId,
                    UnitPrice,
                    Quantity
                )
                VALUES                            (@BookingId, @RoomId, @ServiceId, @UnitPrice, @Quantity);
            END
        -- Trigger trg_BookingRoomService_CapNhatTienDichVu sẽ tự động cộng tiền vào Hóa đơn
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
-- ============================================================================
-- PROCEDURE 4: THỦ TỤC CHECK-OUT TRẢ PHÒNG TẠI QUẦY LỄ TÂN
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_CheckOutTraPhong
@BookingId VARCHAR (10), @RoomId VARCHAR (10)=NULL -- NULL = Check-out toàn bộ phòng; Hoặc truyền mã để trả từng phòng
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1
                       FROM   Booking
                       WHERE  BookingId = @BookingId)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Đơn đặt phòng không tồn tại trên hệ thống!', 16, 1);
                RETURN -1;
            END
        -- Kiểm tra phòng đang ở trạng thái CheckedIn
        IF @RoomId IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM   Booking_Room
                           WHERE  BookingId = @BookingId
                                  AND RoomId = @RoomId
                                  AND BookingStatus = 'CheckedIn')
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Phòng chỉ định không ở trạng thái lưu trú để làm thủ tục trả phòng!', 16, 1);
                RETURN -2;
            END
        BEGIN TRANSACTION;
        -- Cập nhật ActualCheckOutDate (Trigger sẽ tự đổi phòng sang Dirty, sinh việc dọn phòng, và tính phụ thu trễ nếu sau 12:00)
        UPDATE Booking_Room
        SET    ActualCheckOutDate = GETDATE(),
               BookingStatus      = 'CheckedOut'
        WHERE  BookingId = @BookingId
               AND (@RoomId IS NULL
                    OR RoomId = @RoomId)
               AND ActualCheckInDate IS NOT NULL
               AND ActualCheckOutDate IS NULL;
        IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Không tìm thấy phòng hợp lệ cần làm thủ tục Check-out!', 16, 1);
                ROLLBACK;
                RETURN -3;
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
-- ============================================================================
-- PROCEDURE 5: GHI NHẬN THANH TOÁN TIỀN (TIỀN CỌC / QUYẾT TOÁN HÓA ĐƠN)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_GhiNhanThanhToan
@InvoiceId VARCHAR (10), @ProcessBy VARCHAR (10)=NULL, -- NULL nếu khách tự thanh toán online
@TotalAmount DECIMAL (12, 2), @PaymentMethod VARCHAR (20)='Cash', @Note NVARCHAR (300)=NULL, @NewPaymentId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @TotalAmount <= 0
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Số tiền thanh toán phải lớn hơn 0!', 16, 1);
                RETURN -1;
            END
        IF NOT EXISTS (SELECT 1
                       FROM   Invoice
                       WHERE  InvoiceId = @InvoiceId)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Hóa đơn thanh toán không tồn tại trên hệ thống!', 16, 1);
                RETURN -2;
            END
        IF EXISTS (SELECT 1
                   FROM   Invoice
                   WHERE  InvoiceId = @InvoiceId
                          AND InvoiceStatus = 'Paid')
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Hóa đơn này đã được thanh toán đủ, không thể thu thêm!', 16, 1);
                RETURN -3;
            END
        SET @NewPaymentId = dbo.fn_SinhMaPayment();
        BEGIN TRANSACTION;
        INSERT  INTO Payment (
            PaymentId,
            ProcessBy,
            InvoiceId,
            PaymentDate,
            PaymentMethod,
            TotalAmount,
            Note
        )
        VALUES               (@NewPaymentId, @ProcessBy, @InvoiceId, GETDATE(), @PaymentMethod, @TotalAmount, @Note);
        -- Trigger trg_Payment_DongBoTrangThaiHoaDon sẽ tự động đối soát tổng tiền và cập nhật InvoiceStatus
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
-- ============================================================================
-- PROCEDURE 6: THỦ TỤC HỦY PHÒNG ĐÃ ĐẶT
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_HuyPhong
@BookingId VARCHAR (10), @RoomId VARCHAR (10), @CancelledBy VARCHAR (10), @CancellationFee DECIMAL (12, 2)=0, @Reason NVARCHAR (300)=NULL, @NewCancellationId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Kiểm tra phòng có thuộc đơn và ở trạng thái Confirmed không
        DECLARE @Deposit AS DECIMAL (12, 2);
        SELECT @Deposit = Deposit
        FROM   Booking_Room
        WHERE  BookingId = @BookingId
               AND RoomId = @RoomId
               AND BookingStatus = 'Confirmed';
        IF @Deposit IS NULL
           AND NOT EXISTS (SELECT 1
                           FROM   Booking_Room
                           WHERE  BookingId = @BookingId
                                  AND RoomId = @RoomId
                                  AND BookingStatus = 'Confirmed')
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Phòng không ở trạng thái hợp lệ để thực hiện hủy phòng!', 16, 1);
                RETURN -1;
            END
        SET @NewCancellationId = dbo.fn_SinhMaCancellation();
        BEGIN TRANSACTION;
        -- 2. Ghi nhận vào lịch sử hủy phòng (Trigger 8 sẽ chặn nếu đã check-in, đổi trạng thái và trả phòng Vacant)
        INSERT  INTO CancellationHistory (
            CancellationId,
            BookingId,
            RoomId,
            CancelledBy,
            DepositAtCancellation,
            CancellationDate,
            CancellationFee,
            RefundStatus,
            Reason
        )
        VALUES                           (@NewCancellationId, @BookingId, @RoomId, @CancelledBy, ISNULL(@Deposit, 0), GETDATE(), @CancellationFee, 'Pending', @Reason);
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
-- ============================================================================
-- PROCEDURE 7: QUY TRÌNH BUỒNG PHÒNG TIẾP NHẬN & HOÀN TẤT DỌN DẸP
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_CapNhatTienDoDonPhong
@RoomCleaningTaskId VARCHAR (10), @ReceivedBy VARCHAR (10), -- AccountId của nhân viên dọn phòng
@Action VARCHAR (20), -- 'AcceptTask' (Nhận việc) hoặc 'CompleteTask' (Hoàn tất)
@Result NVARCHAR (255)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @RoomId AS VARCHAR (10);
        DECLARE @CurrentStatus AS VARCHAR (20);
        DECLARE @CurrentReceiver AS VARCHAR (10);
        SELECT @RoomId = RoomId,
               @CurrentStatus = RoomCleaningTaskStatus,
               @CurrentReceiver = ReceivedBy
        FROM   RoomCleaningTask
        WHERE  RoomCleaningTaskId = @RoomCleaningTaskId;
        IF @RoomId IS NULL
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Nhiệm vụ dọn phòng không tồn tại trên hệ thống!', 16, 1);
                RETURN -1;
            END
        BEGIN TRANSACTION;
        IF @Action = 'AcceptTask'
            BEGIN
                -- 1. Kiểm tra nhân viên có đang dọn dở phòng nào khác không
                IF EXISTS (SELECT 1
                           FROM   RoomCleaningTask
                           WHERE  ReceivedBy = @ReceivedBy
                                  AND RoomCleaningTaskStatus = 'InProgress')
                    BEGIN
                        RAISERROR (N'Lỗi nghiệp vụ: Bạn đang có phòng đang dọn dở! Vui lòng hoàn tất trước khi nhận phòng mới.', 16, 1);
                        ROLLBACK;
                        RETURN -2;
                    END
                -- 2. Khóa hàng cập nhật nguyên tử chống 2 nhân viên cùng nhận 1 phòng
                UPDATE RoomCleaningTask WITH (UPDLOCK, ROWLOCK)
                SET    ReceivedBy             = @ReceivedBy,
                       StartTime              = GETDATE(),
                       RoomCleaningTaskStatus = 'InProgress'
                WHERE  RoomCleaningTaskId = @RoomCleaningTaskId
                       AND RoomCleaningTaskStatus = 'Pending';
                IF @@ROWCOUNT = 0
                    BEGIN
                        RAISERROR (N'Lỗi nghiệp vụ: Phòng này đã được tiếp nhận bởi nhân viên khác hoặc không ở trạng thái chờ dọn!', 16, 1);
                        ROLLBACK;
                        RETURN -3;
                    END
                -- Đổi trạng thái buồng phòng sang Cleaning
                UPDATE Room
                SET    HousekeepingStatus = 'Cleaning'
                WHERE  RoomId = @RoomId;
            END
        ELSE
            IF @Action = 'CompleteTask'
                BEGIN
                    IF @CurrentStatus <> 'InProgress'
                        BEGIN
                            RAISERROR (N'Lỗi nghiệp vụ: Chỉ có thể hoàn tất phòng đang trong tiến trình dọn dẹp!', 16, 1);
                            ROLLBACK;
                            RETURN -4;
                        END
                    IF @CurrentReceiver <> @ReceivedBy
                        BEGIN
                            RAISERROR (N'Lỗi nghiệp vụ: Bạn không thể hoàn tất nhiệm vụ do nhân viên khác đang phụ trách!', 16, 1);
                            ROLLBACK;
                            RETURN -5;
                        END
                    -- Hoàn thành nhiệm vụ (Trigger 9 sẽ tự động đưa Room.HousekeepingStatus về 'Clean')
                    UPDATE RoomCleaningTask
                    SET    EndTime                = GETDATE(),
                           RoomCleaningTaskStatus = 'Completed',
                           Result                 = ISNULL(@Result, N'Hoàn tất dọn dẹp sạch sẽ')
                    WHERE  RoomCleaningTaskId = @RoomCleaningTaskId;
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
-- ============================================================================
-- PROCEDURE 8: GHI NHẬN BIÊN BẢN BÁO CÁO HƯ HỎNG THIẾT BỊ TRONG PHÒNG
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_BaoCaoSuCoHuHai
@RoomId VARCHAR (10), @CreateBy VARCHAR (10), @DamageTypeId VARCHAR (10), @Note NVARCHAR (300)=NULL, @NewDamageReportId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1
                       FROM   Room
                       WHERE  RoomId = @RoomId)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Phòng báo cáo sự cố không tồn tại!', 16, 1);
                RETURN -1;
            END
        IF NOT EXISTS (SELECT 1
                       FROM   DamageType
                       WHERE  DamageTypeId = @DamageTypeId)
            BEGIN
                RAISERROR (N'Lỗi nghiệp vụ: Loại hư hỏng thiết bị không hợp lệ!', 16, 1);
                RETURN -2;
            END
        SET @NewDamageReportId = dbo.fn_SinhMaDamageReport();
        BEGIN TRANSACTION;
        -- 1. Tạo biên bản báo cáo (Trạng thái Confirmed kích hoạt Trigger 10 đưa Room sang Maintenance)
        INSERT  INTO DamageReport (
            DamageReportId,
            RoomId,
            CreateBy,
            DetectedAt,
            ConfirmedAt,
            DamageReportStatus
        )
        VALUES                    (@NewDamageReportId, @RoomId, @CreateBy, GETDATE(), GETDATE(), 'Confirmed');
        -- 2. Ghi chi tiết loại hư hại
        INSERT  INTO DamageReport_DamageType (
            DamageReportId,
            DamageTypeId,
            Note
        )
        VALUES                               (@NewDamageReportId, @DamageTypeId, @Note);
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
-- ============================================================================
-- PROCEDURE 9: BÁO CÁO TỔNG KẾT KINH DOANH CHỐT CA THEO NGÀY (NIGHT AUDIT)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_BaoCaoDoanhThuTheoNgay
@ReportDate DATE=NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ReportDate IS NULL
        SET @ReportDate = CAST (GETDATE() AS DATE);
    SELECT @ReportDate AS ReportDate,
           -- Hoạt động đặt phòng & lưu trú trong ngày
           (SELECT COUNT(*)
            FROM   Booking
            WHERE  CAST (CreateDate AS DATE) = @ReportDate) AS TotalNewBookings,
           (SELECT COUNT(*)
            FROM   Booking_Room
            WHERE  CAST (ActualCheckInDate AS DATE) = @ReportDate) AS TotalRoomsCheckedIn,
           (SELECT COUNT(*)
            FROM   Booking_Room
            WHERE  CAST (ActualCheckOutDate AS DATE) = @ReportDate) AS TotalRoomsCheckedOut,
           -- Thống kê dòng tiền thực thu trong ngày
           ISNULL(SUM(p.TotalAmount), 0) AS TotalRevenue,
           ISNULL(SUM(CASE WHEN p.PaymentMethod = 'Cash' THEN p.TotalAmount END), 0) AS RevenueCash,
           ISNULL(SUM(CASE WHEN p.PaymentMethod = 'CreditCard' THEN p.TotalAmount END), 0) AS RevenueCreditCard,
           ISNULL(SUM(CASE WHEN p.PaymentMethod = 'BankTransfer' THEN p.TotalAmount END), 0) AS RevenueBankTransfer,
           ISNULL(SUM(CASE WHEN p.PaymentMethod = 'Momo' THEN p.TotalAmount END), 0) AS RevenueMomo,
           ISNULL(SUM(CASE WHEN p.PaymentMethod = 'VNPay' THEN p.TotalAmount END), 0) AS RevenueVNPay
    FROM   Payment AS p
    WHERE  CAST (p.PaymentDate AS DATE) = @ReportDate;
END


GO
-- ============================================================================
-- PROCEDURE 10: BÁO CÁO TỔNG HỢP KINH DOANH THÁNG (BAN QUẢN LÝ / GIÁM ĐỐC)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_BaoCaoDoanhThuTheoThang
@Month INT, @Year INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @Month AS ReportMonth,
           @Year AS ReportYear,
           COUNT(DISTINCT b.BookingId) AS TotalBookings,
           COUNT(DISTINCT CASE WHEN br.BookingStatus = 'CheckedOut' THEN b.BookingId END) AS CompletedBookings,
           COUNT(DISTINCT CASE WHEN br.BookingStatus = 'Cancelled' THEN b.BookingId END) AS CancelledBookings,
           (SELECT ISNULL(SUM(p.TotalAmount), 0)
            FROM   Payment AS p
            WHERE  MONTH(p.PaymentDate) = @Month
                   AND YEAR(p.PaymentDate) = @Year) AS TotalRevenue
    FROM   Booking AS b
           LEFT OUTER JOIN
           Booking_Room AS br
           ON b.BookingId = br.BookingId
    WHERE  MONTH(b.CreateDate) = @Month
           AND YEAR(b.CreateDate) = @Year;
END


GO
-- ============================================================================
-- PROCEDURE 11: TẠO HỒ SƠ KHÁCH HÀNG MỚI (ÁP DỤNG fn_SinhMaCustomer)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ThemKhachHang
@FullName NVARCHAR (100), @PhoneNumber VARCHAR (15), @CCCD VARCHAR (20), @Email VARCHAR (100), @NewCustomerId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1
                   FROM   Customer
                   WHERE  CCCD = @CCCD)
            THROW 50051, N'Số CCCD này đã tồn tại trên hệ thống!', 1;
        IF EXISTS (SELECT 1
                   FROM   Customer
                   WHERE  PhoneNumber = @PhoneNumber)
            THROW 50052, N'Số điện thoại này đã tồn tại trên hệ thống!', 1;
        SET @NewCustomerId = dbo.fn_SinhMaCustomer();
        INSERT  INTO Customer (
            CustomerId,
            FullName,
            PhoneNumber,
            CCCD,
            Email
        )
        VALUES                (@NewCustomerId, @FullName, @PhoneNumber, @CCCD, @Email);
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -1;
    END CATCH
END


GO
-- ============================================================================
-- PROCEDURE 12: TẠO TÀI KHOẢN ĐĂNG NHẬP MỚI (ÁP DỤNG fn_SinhMaAccount)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ThemTaiKhoan
@Email VARCHAR (100), @Role VARCHAR (20), @UserName VARCHAR (50), @Password VARCHAR (255), @NewAccountId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1
                   FROM   Account
                   WHERE  UserName = @UserName)
            THROW 50053, N'Tên đăng nhập đã được sử dụng!', 1;
        IF EXISTS (SELECT 1
                   FROM   Account
                   WHERE  Email = @Email)
            THROW 50054, N'Email tài khoản đã được sử dụng!', 1;
        SET @NewAccountId = dbo.fn_SinhMaAccount();
        INSERT  INTO Account (
            AccountId,
            Email,
            Role,
            UserName,
            Password,
            AccountStatus
        )
        VALUES               (@NewAccountId, @Email, @Role, @UserName, @Password, 'Active');
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -1;
    END CATCH
END


GO
-- ============================================================================
-- PROCEDURE 13: TẠO HỒ SƠ NHÂN VIÊN MỚI (ÁP DỤNG fn_SinhMaEmployee)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ThemNhanVien
@AccountId VARCHAR (10)=NULL, @FullName NVARCHAR (100), @Phone VARCHAR (15), @Email VARCHAR (100), @HireDate DATE=NULL, @NewEmployeeId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1
                   FROM   Employee
                   WHERE  Phone = @Phone)
            THROW 50055, N'Số điện thoại nhân viên đã tồn tại trên hệ thống!', 1;
        SET @NewEmployeeId = dbo.fn_SinhMaEmployee();
        INSERT  INTO Employee (
            EmployeeId,
            AccountId,
            FullName,
            Phone,
            Email,
            HireDate,
            EmployeeStatus
        )
        VALUES                (@NewEmployeeId, @AccountId, @FullName, @Phone, @Email, ISNULL(@HireDate, CAST (GETDATE() AS DATE)), 'Working');
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -1;
    END CATCH
END


GO
-- ============================================================================
-- PROCEDURE 14: TẠO PHÒNG VẬT LÝ MỚI (ÁP DỤNG fn_SinhMaRoom)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ThemPhong
@RoomTypeId VARCHAR (10), @RoomName NVARCHAR (50), @NewRoomId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1
                   FROM   Room
                   WHERE  RoomName = @RoomName)
            THROW 50056, N'Tên số phòng này đã tồn tại trong khách sạn!', 1;
        IF NOT EXISTS (SELECT 1
                       FROM   RoomType
                       WHERE  RoomTypeId = @RoomTypeId)
            THROW 50057, N'Hạng phòng chỉ định không tồn tại!', 1;
        SET @NewRoomId = dbo.fn_SinhMaRoom();
        INSERT  INTO Room (
            RoomId,
            RoomTypeId,
            RoomName,
            RoomStatus,
            HousekeepingStatus,
            OccupancyStatus
        )
        VALUES            (@NewRoomId, @RoomTypeId, @RoomName, 'Available', 'Clean', 'Vacant');
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -1;
    END CATCH
END


GO
-- ============================================================================
-- PROCEDURE 15: TẠO DỊCH VỤ PHÁT SINH MỚI (ÁP DỤNG fn_SinhMaService)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_ThemDichVu
@ServiceName NVARCHAR (100), @BasePrice DECIMAL (12, 2), @NewServiceId VARCHAR (10) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1
                   FROM   Service
                   WHERE  ServiceName = @ServiceName)
            THROW 50058, N'Tên dịch vụ này đã tồn tại trên danh mục!', 1;
        SET @NewServiceId = dbo.fn_SinhMaService();
        INSERT  INTO Service (
            ServiceId,
            ServiceName,
            BasePrice
        )
        VALUES               (@NewServiceId, @ServiceName, @BasePrice);
        RETURN 0;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg AS NVARCHAR (4000) = ERROR_MESSAGE();
        RAISERROR (@ErrMsg, 16, 1);
        RETURN -1;
    END CATCH
END