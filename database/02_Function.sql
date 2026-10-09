-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
-- SCRIPT 02: HỆ THỐNG FUNCTION (TÍNH TOÁN, TRA CỨU & SINH MÃ TỰ ĐỘNG - CHUẨN 3NF)
-- HỆ QUẢN TRỊ CSDL: MICROSOFT SQL SERVER 2019 / 2022
-- ============================================================================

USE QuanLyKhachSan;
GO

-- ============================================================================
-- PHẦN 1: CÁC FUNCTION TÍNH TOÁN & KIỂM TRA NGHIỆP VỤ (SCALAR FUNCTIONS)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function 1: Tính tổng tiền phòng của đơn đặt phòng (chỉ tính phòng chưa hủy)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhTienPhongBooking
(
    @BookingId VARCHAR(10)
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(12, 2) = 0;

    SELECT @TongTien = ISNULL(SUM(
        CASE 
            WHEN DATEDIFF(DAY, ExpectedCheckInDate, ExpectedCheckOutDate) <= 0 THEN 1 
            ELSE DATEDIFF(DAY, ExpectedCheckInDate, ExpectedCheckOutDate) 
        END * Price
    ), 0)
    FROM Booking_Room
    WHERE BookingId = @BookingId
      AND BookingStatus <> 'Cancelled';

    RETURN @TongTien;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 2: Tính tổng tiền dịch vụ phát sinh của đơn đặt phòng
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhTienDichVuBooking
(
    @BookingId VARCHAR(10)
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @TongDichVu DECIMAL(12, 2) = 0;

    SELECT @TongDichVu = ISNULL(SUM(UnitPrice * Quantity), 0)
    FROM Booking_Room_Service
    WHERE BookingId = @BookingId;

    RETURN @TongDichVu;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 3: Tính phụ thu nhận phòng sớm theo quy tắc khách sạn
-- Quy tắc: Check-in chuẩn 14h. Miễn phí từ 13h - 14h. Nhận trước 13h tính EarlyCheckInFee.
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhPhuThuCheckInSom
(
    @BookingId VARCHAR(10)
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @TongPhiEarly DECIMAL(12, 2) = 0;

    SELECT @TongPhiEarly = ISNULL(SUM(rt.EarlyCheckInFee), 0)
    FROM Booking_Room br
    JOIN Room r ON br.RoomId = r.RoomId
    JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId
    WHERE br.BookingId = @BookingId
      AND br.BookingStatus <> 'Cancelled'
      AND br.ActualCheckInDate IS NOT NULL
      AND (
          CAST(br.ActualCheckInDate AS DATE) < br.ExpectedCheckInDate
          OR (
              CAST(br.ActualCheckInDate AS DATE) = br.ExpectedCheckInDate 
              AND CAST(br.ActualCheckInDate AS TIME) < '13:00:00'
          )
      );

    RETURN @TongPhiEarly;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 4: Tính phụ thu trả phòng trễ theo quy tắc khách sạn
-- Quy tắc: Check-out chuẩn 12h. Miễn phí đến 12h (kể cả 11h-12h). Trả sau 12h tính LateCheckOutFee.
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhPhuThuCheckOutTre
(
    @BookingId VARCHAR(10)
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @TongPhiLate DECIMAL(12, 2) = 0;

    SELECT @TongPhiLate = ISNULL(SUM(rt.LateCheckOutFee), 0)
    FROM Booking_Room br
    JOIN Room r ON br.RoomId = r.RoomId
    JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId
    WHERE br.BookingId = @BookingId
      AND br.BookingStatus <> 'Cancelled'
      AND br.ActualCheckOutDate IS NOT NULL
      AND (
          CAST(br.ActualCheckOutDate AS DATE) > br.ExpectedCheckOutDate
          OR (
              CAST(br.ActualCheckOutDate AS DATE) = br.ExpectedCheckOutDate 
              AND CAST(br.ActualCheckOutDate AS TIME) > '12:00:00'
          )
      );

    RETURN @TongPhiLate;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 5: Tính tổng tiền thực tế của đơn đặt phòng (Phòng + Dịch vụ + Phụ thu)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhTongTienHoaDonDuKien
(
    @BookingId VARCHAR(10)
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    RETURN dbo.fn_TinhTienPhongBooking(@BookingId) 
         + dbo.fn_TinhTienDichVuBooking(@BookingId)
         + dbo.fn_TinhPhuThuCheckInSom(@BookingId)
         + dbo.fn_TinhPhuThuCheckOutTre(@BookingId);
END;
GO

-- ----------------------------------------------------------------------------
-- Function 6: Tính số tiền hoàn trả cọc khi hủy phòng (Thuộc tính suy diễn chuẩn 3NF)
-- Công thức: DepositAtCancellation - CancellationFee (Tối thiểu 0)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TinhTienHoanTraHuyPhong
(
    @CancellationId VARCHAR(10)
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @RefundAmount DECIMAL(12, 2) = 0;

    SELECT @RefundAmount = 
        CASE 
            WHEN (DepositAtCancellation - CancellationFee) > 0 
                THEN (DepositAtCancellation - CancellationFee)
            ELSE 0 
        END
    FROM CancellationHistory
    WHERE CancellationId = @CancellationId;

    RETURN ISNULL(@RefundAmount, 0);
END;
GO

-- ----------------------------------------------------------------------------
-- Function 7: Kiểm tra phòng có trống và khả dụng trong khoảng thời gian không
-- Trả về: 1 (Trống / Sẵn sàng phục vụ), 0 (Không khả dụng hoặc đã bị trùng lịch)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_KiemTraPhongTrongTrongKhoang
(
    @RoomId VARCHAR(10),
    @ExpectedCheckIn DATE,
    @ExpectedCheckOut DATE,
    @IgnoreBookingId VARCHAR(10) = NULL
)
RETURNS BIT
AS
BEGIN
    -- 1. Nếu phòng đang bảo trì hoặc ngừng hoạt động -> Không khả dụng
    IF EXISTS (
        SELECT 1
        FROM Room
        WHERE RoomId = @RoomId
          AND RoomStatus IN ('Maintenance', 'OutOfService')
    )
        RETURN 0;

    -- 2. Kiểm tra xung đột lịch đặt với các booking đang có hiệu lực (Confirmed, CheckedIn)
    IF EXISTS (
        SELECT 1
        FROM Booking_Room br
        WHERE br.RoomId = @RoomId
          AND (@IgnoreBookingId IS NULL OR br.BookingId <> @IgnoreBookingId)
          AND br.BookingStatus IN ('Confirmed', 'CheckedIn')
          AND NOT (
              br.ExpectedCheckOutDate <= @ExpectedCheckIn
              OR br.ExpectedCheckInDate >= @ExpectedCheckOut
          )
    )
        RETURN 0;

    RETURN 1;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 8: Thống kê tổng doanh thu thực tế đã thu trong khoảng thời gian
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_DoanhThuTheoKhoangThoiGian
(
    @FromDate DATETIME,
    @ToDate DATETIME
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @TongThu DECIMAL(12, 2) = 0;

    SELECT @TongThu = ISNULL(SUM(TotalAmount), 0)
    FROM Payment
    WHERE PaymentDate BETWEEN @FromDate AND @ToDate;

    RETURN @TongThu;
END;
GO

-- ============================================================================
-- PHẦN 2: CÁC FUNCTION TRA CỨU BẢNG (INLINE TABLE-VALUED FUNCTIONS)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Function 9: Tra cứu phòng trống theo khoảng thời gian, số người và hạng phòng
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_TraCuuPhongTrongTheoYeuCau
(
    @CheckInDate DATE,
    @CheckOutDate DATE,
    @Capacity INT = NULL,
    @RoomTypeId VARCHAR(10) = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        r.RoomId,
        r.RoomName,
        rt.RoomTypeId,
        rt.RoomTypeName,
        rt.BasePrice,
        rt.Capacity,
        rt.EarlyCheckInFee,
        rt.LateCheckOutFee,
        rt.DepositPercent
    FROM Room r
    JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId
    WHERE rt.IsActive = 1
      AND r.RoomStatus = 'Available'
      AND (@RoomTypeId IS NULL OR rt.RoomTypeId = @RoomTypeId)
      AND (@Capacity IS NULL OR rt.Capacity >= @Capacity)
      AND dbo.fn_KiemTraPhongTrongTrongKhoang(r.RoomId, @CheckInDate, @CheckOutDate, NULL) = 1
);
GO

-- ----------------------------------------------------------------------------
-- Function 10: Xem lịch sử đặt phòng của một khách hàng
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_LichSuDatPhongKhachHang
(
    @CustomerId VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        b.BookingId,
        b.CreateDate,
        inv.InvoiceId,
        inv.TotalRoomCharge,
        inv.TotalServiceCharge,
        inv.EarlyCheckInFee,
        inv.LateCheckOutFee,
        inv.FinalTotalAmount,
        inv.InvoiceStatus
    FROM Booking b
    LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId
    WHERE b.CustomerId = @CustomerId
);
GO

-- ----------------------------------------------------------------------------
-- Function 11: Lấy chi tiết danh sách các phòng trong một đơn đặt phòng
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_ChiTietPhongTrongBooking
(
    @BookingId VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        br.BookingId,
        br.RoomId,
        r.RoomName,
        rt.RoomTypeName,
        br.BookingStatus,
        br.ExpectedCheckInDate,
        br.ExpectedCheckOutDate,
        br.ActualCheckInDate,
        br.ActualCheckOutDate,
        br.Deposit,
        br.Price
    FROM Booking_Room br
    JOIN Room r ON br.RoomId = r.RoomId
    JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId
    WHERE br.BookingId = @BookingId
);
GO

-- ----------------------------------------------------------------------------
-- Function 12: Lấy chi tiết danh sách tất cả dịch vụ đã gọi trong một đơn đặt phòng
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_ChiTietDichVuTrongBooking
(
    @BookingId VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        brs.BookingId,
        brs.RoomId,
        r.RoomName,
        s.ServiceId,
        s.ServiceName,
        brs.UnitPrice,
        brs.Quantity,
        CAST(brs.UnitPrice * brs.Quantity AS DECIMAL(12, 2)) AS TotalAmount
    FROM Booking_Room_Service brs
    JOIN Room r ON brs.RoomId = r.RoomId
    JOIN Service s ON brs.ServiceId = s.ServiceId
    WHERE brs.BookingId = @BookingId
);
GO

-- ============================================================================
-- PHẦN 3: CÁC FUNCTION TỰ ĐỘNG SINH KHÓA CHÍNH (AUTO-PK FUNCTIONS)
-- Hỗ trợ Backend truy vấn trực tiếp từ CSDL, triệt tiêu xung đột ID
-- ============================================================================

-- Function 13: Sinh mã Account (ACC001, ACC002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaAccount()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(AccountId, PATINDEX('%[0-9]%', AccountId), 10) AS INT)), 0)
    FROM Account WITH (NOLOCK);
    RETURN 'ACC' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 14: Sinh mã Employee (EMP001, EMP002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaEmployee()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(EmployeeId, PATINDEX('%[0-9]%', EmployeeId), 10) AS INT)), 0)
    FROM Employee WITH (NOLOCK);
    RETURN 'EMP' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 15: Sinh mã Customer (CUS001, CUS002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaCustomer()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(CustomerId, PATINDEX('%[0-9]%', CustomerId), 10) AS INT)), 0)
    FROM Customer WITH (NOLOCK);
    RETURN 'CUS' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 16: Sinh mã RoomType (RT001, RT002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoomType()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(RoomTypeId, PATINDEX('%[0-9]%', RoomTypeId), 10) AS INT)), 0)
    FROM RoomType WITH (NOLOCK);
    RETURN 'RT' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 17: Sinh mã BedType (BT001, BT002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaBedType()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(BedTypeId, PATINDEX('%[0-9]%', BedTypeId), 10) AS INT)), 0)
    FROM BedType WITH (NOLOCK);
    RETURN 'BT' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 18: Sinh mã RoomService tiện nghi (RS001, RS002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoomService()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(RoomServiceId, PATINDEX('%[0-9]%', RoomServiceId), 10) AS INT)), 0)
    FROM RoomService WITH (NOLOCK);
    RETURN 'RS' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 19: Sinh mã Room vật lý (RM001, RM002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoom()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(RoomId, PATINDEX('%[0-9]%', RoomId), 10) AS INT)), 0)
    FROM Room WITH (NOLOCK);
    RETURN 'RM' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 20: Sinh mã Service phát sinh (SRV001, SRV002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaService()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(ServiceId, PATINDEX('%[0-9]%', ServiceId), 10) AS INT)), 0)
    FROM Service WITH (NOLOCK);
    RETURN 'SRV' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 21: Sinh mã Booking (BK001, BK002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaBooking()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(BookingId, PATINDEX('%[0-9]%', BookingId), 10) AS INT)), 0)
    FROM Booking WITH (NOLOCK);
    RETURN 'BK' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 22: Sinh mã CancellationHistory (CAN001, CAN002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaCancellation()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(CancellationId, PATINDEX('%[0-9]%', CancellationId), 10) AS INT)), 0)
    FROM CancellationHistory WITH (NOLOCK);
    RETURN 'CAN' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 23: Sinh mã Invoice (INV001, INV002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaInvoice()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(InvoiceId, PATINDEX('%[0-9]%', InvoiceId), 10) AS INT)), 0)
    FROM Invoice WITH (NOLOCK);
    RETURN 'INV' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 24: Sinh mã Payment (PAY001, PAY002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaPayment()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(PaymentId, PATINDEX('%[0-9]%', PaymentId), 10) AS INT)), 0)
    FROM Payment WITH (NOLOCK);
    RETURN 'PAY' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 25: Sinh mã RoomCleaningTask (TSK001, TSK002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaRoomCleaningTask()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(RoomCleaningTaskId, PATINDEX('%[0-9]%', RoomCleaningTaskId), 10) AS INT)), 0)
    FROM RoomCleaningTask WITH (NOLOCK);
    RETURN 'TSK' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 26: Sinh mã DamageType (DT001, DT002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaDamageType()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(DamageTypeId, PATINDEX('%[0-9]%', DamageTypeId), 10) AS INT)), 0)
    FROM DamageType WITH (NOLOCK);
    RETURN 'DT' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO

-- Function 27: Sinh mã DamageReport (DMR001, DMR002...)
CREATE OR ALTER FUNCTION dbo.fn_SinhMaDamageReport()
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @MaxID INT;
    SELECT @MaxID = ISNULL(MAX(TRY_CAST(SUBSTRING(DamageReportId, PATINDEX('%[0-9]%', DamageReportId), 10) AS INT)), 0)
    FROM DamageReport WITH (NOLOCK);
    RETURN 'DMR' + RIGHT('000' + CAST(@MaxID + 1 AS VARCHAR(10)), 3);
END;
GO