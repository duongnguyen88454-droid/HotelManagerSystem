USE QuanLyKhachSan;


GO
SET ANSI_NULLS ON;


GO
SET QUOTED_IDENTIFIER ON;


GO
CREATE OR ALTER FUNCTION dbo.fn_TinhTienPhongBooking
(@BookingId VARCHAR (10))
RETURNS DECIMAL (12, 2)
AS
BEGIN
    DECLARE @TongTien AS DECIMAL (12, 2) = 0;
    SELECT @TongTien = ISNULL(SUM(CASE WHEN DATEDIFF(DAY, ExpectedCheckInDate, ExpectedCheckOutDate) <= 0 THEN 1 ELSE DATEDIFF(DAY, ExpectedCheckInDate, ExpectedCheckOutDate) END * Price), 0)
    FROM   Booking_Room
    WHERE  BookingId = @BookingId
           AND BookingStatus <> 'Cancelled';
    RETURN @TongTien;
END


GO
CREATE OR ALTER FUNCTION dbo.fn_TinhTienDichVuBooking
(@BookingId VARCHAR (10))
RETURNS DECIMAL (12, 2)
AS
BEGIN
    DECLARE @TongDichVu AS DECIMAL (12, 2) = 0;
    SELECT @TongDichVu = ISNULL(SUM(UnitPrice * Quantity), 0)
    FROM   Booking_Room_Service
    WHERE  BookingId = @BookingId;
    RETURN @TongDichVu;
END


GO
CREATE OR ALTER FUNCTION dbo.fn_TinhPhuThuCheckInSom
(@BookingId VARCHAR (10))
RETURNS DECIMAL (12, 2)
AS
BEGIN
    DECLARE @TongPhiEarly AS DECIMAL (12, 2) = 0;
    SELECT @TongPhiEarly = ISNULL(SUM(rt.EarlyCheckInFee), 0)
    FROM   Booking_Room AS br
           INNER JOIN
           Room AS r
           ON br.RoomId = r.RoomId
           INNER JOIN
           RoomType AS rt
           ON r.RoomTypeId = rt.RoomTypeId
    WHERE  br.BookingId = @BookingId
           AND br.BookingStatus <> 'Cancelled'
           AND br.ActualCheckInDate IS NOT NULL
           AND (CAST (br.ActualCheckInDate AS DATE) < br.ExpectedCheckInDate
                OR (CAST (br.ActualCheckInDate AS DATE) = br.ExpectedCheckInDate
                    AND CAST (br.ActualCheckInDate AS TIME) < '13:00:00'));
    RETURN @TongPhiEarly;
END


GO
CREATE OR ALTER FUNCTION dbo.fn_TinhPhuThuCheckOutTre
(@BookingId VARCHAR (10))
RETURNS DECIMAL (12, 2)
AS
BEGIN
    DECLARE @TongPhiLate AS DECIMAL (12, 2) = 0;
    SELECT @TongPhiLate = ISNULL(SUM(rt.LateCheckOutFee), 0)
    FROM   Booking_Room AS br
           INNER JOIN
           Room AS r
           ON br.RoomId = r.RoomId
           INNER JOIN
           RoomType AS rt
           ON r.RoomTypeId = rt.RoomTypeId
    WHERE  br.BookingId = @BookingId
           AND br.BookingStatus <> 'Cancelled'
           AND br.ActualCheckOutDate IS NOT NULL
           AND (CAST (br.ActualCheckOutDate AS DATE) > br.ExpectedCheckOutDate
                OR (CAST (br.ActualCheckOutDate AS DATE) = br.ExpectedCheckOutDate
                    AND CAST (br.ActualCheckOutDate AS TIME) > '12:00:00'));
    RETURN @TongPhiLate;
END


GO
CREATE OR ALTER FUNCTION dbo.fn_TinhTongTienHoaDonDuKien
(@BookingId VARCHAR (10))
RETURNS DECIMAL (12, 2)
AS
BEGIN
    RETURN dbo.fn_TinhTienPhongBooking(@BookingId) + dbo.fn_TinhTienDichVuBooking(@BookingId) + dbo.fn_TinhPhuThuCheckInSom(@BookingId) + dbo.fn_TinhPhuThuCheckOutTre(@BookingId);
END


GO
CREATE OR ALTER FUNCTION dbo.fn_TinhTienHoanTraHuyPhong
(@CancellationId VARCHAR (10))
RETURNS DECIMAL (12, 2)
AS
BEGIN
    DECLARE @RefundAmount AS DECIMAL (12, 2) = 0;
    SELECT @RefundAmount = CASE WHEN (DepositAtCancellation - CancellationFee) > 0 THEN (DepositAtCancellation - CancellationFee) ELSE 0 END
    FROM   CancellationHistory
    WHERE  CancellationId = @CancellationId;
    RETURN ISNULL(@RefundAmount, 0);
END


GO
CREATE OR ALTER FUNCTION dbo.fn_KiemTraPhongTrongTrongKhoang
(@RoomId VARCHAR (10), @ExpectedCheckIn DATE, @ExpectedCheckOut DATE, @IgnoreBookingId VARCHAR (10)=NULL)
RETURNS BIT
AS
BEGIN
    -- 1. Nếu phòng đang bảo trì hoặc ngừng hoạt động -> Không khả dụng
    IF EXISTS (SELECT 1
               FROM   Room
               WHERE  RoomId = @RoomId
                      AND RoomStatus IN ('Maintenance', 'OutOfService'))
        RETURN 0;
    -- 2. Kiểm tra xung đột lịch đặt với các booking đang có hiệu lực (Confirmed, CheckedIn)
    IF EXISTS (SELECT 1
               FROM   Booking_Room AS br
               WHERE  br.RoomId = @RoomId
                      AND (@IgnoreBookingId IS NULL
                           OR br.BookingId <> @IgnoreBookingId)
                      AND br.BookingStatus IN ('Confirmed', 'CheckedIn')
                      AND NOT (br.ExpectedCheckOutDate <= @ExpectedCheckIn
                               OR br.ExpectedCheckInDate >= @ExpectedCheckOut))
        RETURN 0;
    RETURN 1;
END


GO
-- Function 13: Sinh mã Account (ACC001, ACC002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaAccount
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(AccountId, PATINDEX('%[0-9]%', AccountId), 10) AS INT)), 0)
    FROM   Account WITH (NOLOCK);
    RETURN 'ACC' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 14: Sinh mã Employee (EMP001, EMP002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaEmployee
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(EmployeeId, PATINDEX('%[0-9]%', EmployeeId), 10) AS INT)), 0)
    FROM   Employee WITH (NOLOCK);
    RETURN 'EMP' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 15: Sinh mã Customer (CUS001, CUS002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaCustomer
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(CustomerId, PATINDEX('%[0-9]%', CustomerId), 10) AS INT)), 0)
    FROM   Customer WITH (NOLOCK);
    RETURN 'CUS' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 16: Sinh mã RoomType (RT001, RT002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoomType
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(RoomTypeId, PATINDEX('%[0-9]%', RoomTypeId), 10) AS INT)), 0)
    FROM   RoomType WITH (NOLOCK);
    RETURN 'RT' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 17: Sinh mã BedType (BT001, BT002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaBedType
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(BedTypeId, PATINDEX('%[0-9]%', BedTypeId), 10) AS INT)), 0)
    FROM   BedType WITH (NOLOCK);
    RETURN 'BT' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 18: Sinh mã RoomService tiện nghi (RS001, RS002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoomService
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(RoomServiceId, PATINDEX('%[0-9]%', RoomServiceId), 10) AS INT)), 0)
    FROM   RoomService WITH (NOLOCK);
    RETURN 'RS' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 19: Sinh mã Room vật lý (RM001, RM002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoom
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(RoomId, PATINDEX('%[0-9]%', RoomId), 10) AS INT)), 0)
    FROM   Room WITH (NOLOCK);
    RETURN 'RM' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 20: Sinh mã Service phát sinh (SRV001, SRV002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaService
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(ServiceId, PATINDEX('%[0-9]%', ServiceId), 10) AS INT)), 0)
    FROM   Service WITH (NOLOCK);
    RETURN 'SRV' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 21: Sinh mã Booking (BK001, BK002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaBooking
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(BookingId, PATINDEX('%[0-9]%', BookingId), 10) AS INT)), 0)
    FROM   Booking WITH (NOLOCK);
    RETURN 'BK' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 22: Sinh mã CancellationHistory (CAN001, CAN002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaCancellation
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(CancellationId, PATINDEX('%[0-9]%', CancellationId), 10) AS INT)), 0)
    FROM   CancellationHistory WITH (NOLOCK);
    RETURN 'CAN' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 23: Sinh mã Invoice (INV001, INV002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaInvoice
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(InvoiceId, PATINDEX('%[0-9]%', InvoiceId), 10) AS INT)), 0)
    FROM   Invoice WITH (NOLOCK);
    RETURN 'INV' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
-- Function 24: Sinh mã Payment (PAY001, PAY002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaPayment
( )
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(PaymentId, PATINDEX('%[0-9]%', PaymentId), 10) AS INT)), 0)
    FROM   Payment WITH (NOLOCK);
    RETURN 'PAY' + RIGHT('000' + CAST (@MaxID + 1 AS VARCHAR (10)), 3);
END


GO
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoomCleaningTask
(@Offset INT=1)
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @MaxID AS INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST (SUBSTRING(RoomCleaningTaskId, PATINDEX('%[0-9]%', RoomCleaningTaskId), 10) AS INT)), 0)
    FROM   RoomCleaningTask WITH (NOLOCK);
    RETURN 'TSK' + RIGHT('000' + CAST (@MaxID + ISNULL(@Offset, 1) AS VARCHAR (10)), 3);
END