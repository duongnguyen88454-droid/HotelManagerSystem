USE QuanLyKhachSan;


GO
CREATE OR ALTER TRIGGER trg_BookingRoom_KiemTraXungDot
       ON Booking_Room
       AFTER INSERT, UPDATE
       AS BEGIN
                 SET NOCOUNT ON;
                 IF NOT EXISTS (SELECT 1
                                FROM   deleted)
                    OR UPDATE (RoomId)
                    OR UPDATE (ExpectedCheckInDate)
                    OR UPDATE (ExpectedCheckOutDate)
                        BEGIN
                               -- 1. Chặn đặt các phòng đang bảo trì hoặc ngưng hoạt động
                               IF EXISTS (SELECT 1
                                          FROM   inserted AS i
                                                 INNER JOIN
                                                 Room AS r
                                                 ON i.RoomId = r.RoomId
                                          WHERE  r.RoomStatus IN ('Maintenance', 'OutOfService'))
                                      BEGIN
                                             RAISERROR (N'Lỗi nghiệp vụ: Phòng đang bảo trì hoặc ngừng hoạt động (Maintenance / OutOfService), không thể nhận đặt phòng!', 16, 1);
                                             ROLLBACK;
                                             RETURN;
                                      END
                               -- 2. Chống Overbooking: Kiểm tra giao thoa thời gian với các đơn đặt đang có hiệu lực
                               IF EXISTS (SELECT 1
                                          FROM   inserted AS i
                                                 INNER JOIN
                                                 Booking_Room AS br_old
                                                 ON i.RoomId = br_old.RoomId
                                                    AND NOT (i.BookingId = br_old.BookingId
                                                             AND i.RoomId = br_old.RoomId)
                                          WHERE  i.BookingStatus IN ('Confirmed', 'CheckedIn')
                                                 AND br_old.BookingStatus IN ('Confirmed', 'CheckedIn')
                                                 AND NOT (i.ExpectedCheckOutDate <= br_old.ExpectedCheckInDate
                                                          OR i.ExpectedCheckInDate >= br_old.ExpectedCheckOutDate))
                                      BEGIN
                                             RAISERROR (N'Lỗi nghiệp vụ: Phòng này đã có khách đặt trong khoảng thời gian yêu cầu!', 16, 1);
                                             ROLLBACK;
                                             RETURN;
                                      END
                        END
          END


GO
-- ============================================================================
-- TRIGGER 2: ĐỒNG BỘ TRẠNG THÁI PHÒNG KHI KHÁCH LÀM THỦ TỤC CHECK-IN
-- BẢNG: Booking_Room | SỰ KIỆN: AFTER UPDATE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_BookingRoom_DongBoCheckIn
       ON Booking_Room
       AFTER UPDATE
       AS BEGIN
                 SET NOCOUNT ON;
                 IF UPDATE (ActualCheckInDate)
                        BEGIN
                               -- Đổi OccupancyStatus của phòng sang 'Occupied'
                               UPDATE r
                               SET    r.OccupancyStatus = 'Occupied'
                               FROM   Room AS r
                                      INNER JOIN
                                      inserted AS i
                                      ON r.RoomId = i.RoomId
                                      INNER JOIN
                                      deleted AS d
                                      ON i.BookingId = d.BookingId
                                         AND i.RoomId = d.RoomId
                               WHERE  d.ActualCheckInDate IS NULL
                                      AND i.ActualCheckInDate IS NOT NULL
                                      AND i.ActualCheckOutDate IS NULL;
                        END
          END


GO
-- ============================================================================
-- TRIGGER 3: ĐỒNG BỘ TRẠNG THÁI PHÒNG VÀ TỰ ĐỘNG TẠO VIỆC DỌN DẸP KHI CHECK-OUT
-- BẢNG: Booking_Room | SỰ KIỆN: AFTER UPDATE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_BookingRoom_DongBoCheckOut
       ON Booking_Room
       AFTER UPDATE
       AS BEGIN
                 SET NOCOUNT ON;
                 IF UPDATE (ActualCheckOutDate)
                        BEGIN
                               -- 1. Đổi phòng sang Vacant và Dirty
                               UPDATE r
                               SET    r.OccupancyStatus    = 'Vacant',
                                      r.HousekeepingStatus = 'Dirty'
                               FROM   Room AS r
                                      INNER JOIN
                                      inserted AS i
                                      ON r.RoomId = i.RoomId
                                      INNER JOIN
                                      deleted AS d
                                      ON i.BookingId = d.BookingId
                                         AND i.RoomId = d.RoomId
                               WHERE  d.ActualCheckOutDate IS NULL
                                      AND i.ActualCheckOutDate IS NOT NULL;
                               -- 2. Tự động sinh nhiệm vụ dọn dẹp chuẩn hóa theo mã TSK001, TSK002...
                               INSERT INTO RoomCleaningTask (
                                      RoomCleaningTaskId,
                                      RoomId,
                                      ReceivedBy,
                                      StartTime,
                                      EndTime,
                                      RoomCleaningTaskStatus,
                                      Result
                               )
                               SELECT dbo.fn_SinhMaRoomCleaningTask(ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
                                      i.RoomId,
                                      NULL,
                                      NULL,
                                      NULL,
                                      'Pending',
                                      N'Tự động tạo sau khi khách làm thủ tục Check-out'
                               FROM   inserted AS i
                                      INNER JOIN
                                      deleted AS d
                                      ON i.BookingId = d.BookingId
                                         AND i.RoomId = d.RoomId
                               WHERE  d.ActualCheckOutDate IS NULL
                                      AND i.ActualCheckOutDate IS NOT NULL
                                      AND NOT EXISTS (SELECT 1
                                                      FROM   RoomCleaningTask AS rct
                                                      WHERE  rct.RoomId = i.RoomId
                                                             AND rct.RoomCleaningTaskStatus IN ('Pending', 'InProgress'));
                        END
          END


GO
-- ============================================================================
-- TRIGGER 4: TỰ ĐỘNG TẠO HÓA ĐƠN KHI TẠO ĐƠN ĐẶT PHÒNG (BOOKING)
-- BẢNG: Booking | SỰ KIỆN: AFTER INSERT
-- ============================================================================
CREATE OR ALTER TRIGGER trg_Booking_TuDongTaoHoaDon
       ON Booking
       AFTER INSERT
       AS BEGIN
                 SET NOCOUNT ON;
                 INSERT INTO Invoice (
                        InvoiceId,
                        BookingId,
                        CreateDate,
                        TotalRoomCharge,
                        TotalServiceCharge,
                        EarlyCheckInFee,
                        LateCheckOutFee,
                        InvoiceStatus,
                        FinalTotalAmount
                 )
                 SELECT dbo.fn_SinhMaInvoice(),
                        i.BookingId,
                        GETDATE(),
                        0,
                        0,
                        0,
                        0,
                        'Unpaid',
                        0
                 FROM   inserted AS i
                 WHERE  NOT EXISTS (SELECT 1
                                    FROM   Invoice AS inv
                                    WHERE  inv.BookingId = i.BookingId);
          END


GO
-- ============================================================================
-- TRIGGER 5: TỰ ĐỘNG TÍNH TIỀN PHÒNG, PHỤ THU CHECK-IN/OUT VÀ CẬP NHẬT HÓA ĐƠN
-- BẢNG: Booking_Room | SỰ KIỆN: AFTER INSERT, UPDATE, DELETE
-- QUY TẮC PHỤ THU ĐÃ CHỐT:
--   • Check-in: Chuẩn 14h. Miễn phí từ 13h - 14h. Nhận trước 13h -> tính EarlyCheckInFee.
--   • Check-out: Chuẩn 12h. Miễn phí đến 12h (kể cả 11h-12h). Trả sau 12h -> tính LateCheckOutFee.
-- ============================================================================
CREATE OR ALTER TRIGGER trg_BookingRoom_CapNhatHoaDon
       ON Booking_Room
       AFTER INSERT, UPDATE, DELETE
       AS BEGIN
                 SET NOCOUNT ON;
                 DECLARE @AffectedBookings TABLE (
                        BookingId VARCHAR (10) PRIMARY KEY);
                 INSERT INTO @AffectedBookings (
                        BookingId
                 )
                 SELECT DISTINCT BookingId
                 FROM   inserted
                 UNION
                 SELECT DISTINCT BookingId
                 FROM   deleted;
                 WITH ThongKeTienPhong
                 AS   (SELECT   br.BookingId,
                                -- 1. Tiền phòng lưu trú: Số đêm * Đơn giá phòng (chỉ tính phòng chưa bị hủy)
                                SUM(CASE WHEN br.BookingStatus <> 'Cancelled' THEN (CASE WHEN DATEDIFF(DAY, br.ExpectedCheckInDate, br.ExpectedCheckOutDate) <= 0 THEN 1 ELSE DATEDIFF(DAY, br.ExpectedCheckInDate, br.ExpectedCheckOutDate) END) * br.Price ELSE 0 END) AS TongTienPhong,
                                -- 2. Phụ thu nhận phòng sớm: Nhận trước 13:00 tính phí EarlyCheckInFee
                                SUM(CASE WHEN br.BookingStatus <> 'Cancelled'
                                              AND br.ActualCheckInDate IS NOT NULL
                                              AND (CAST (br.ActualCheckInDate AS DATE) < br.ExpectedCheckInDate
                                                   OR (CAST (br.ActualCheckInDate AS DATE) = br.ExpectedCheckInDate
                                                       AND CAST (br.ActualCheckInDate AS TIME) < '13:00:00')) THEN rt.EarlyCheckInFee ELSE 0 END) AS TongPhiNhanSom,
                                -- 3. Phụ thu trả phòng trễ: Trả sau 12:00 tính phí LateCheckOutFee
                                SUM(CASE WHEN br.BookingStatus <> 'Cancelled'
                                              AND br.ActualCheckOutDate IS NOT NULL
                                              AND (CAST (br.ActualCheckOutDate AS DATE) > br.ExpectedCheckOutDate
                                                   OR (CAST (br.ActualCheckOutDate AS DATE) = br.ExpectedCheckOutDate
                                                       AND CAST (br.ActualCheckOutDate AS TIME) > '12:00:00')) THEN rt.LateCheckOutFee ELSE 0 END) AS TongPhiTraTre
                       FROM     Booking_Room AS br
                                INNER JOIN
                                Room AS r
                                ON br.RoomId = r.RoomId
                                INNER JOIN
                                RoomType AS rt
                                ON r.RoomTypeId = rt.RoomTypeId
                       WHERE    br.BookingId IN (SELECT BookingId
                                                 FROM   @AffectedBookings)
                       GROUP BY br.BookingId)
                 UPDATE inv
                 SET    inv.TotalRoomCharge  = ISNULL(tk.TongTienPhong, 0),
                        inv.EarlyCheckInFee  = ISNULL(tk.TongPhiNhanSom, 0),
                        inv.LateCheckOutFee  = ISNULL(tk.TongPhiTraTre, 0),
                        inv.FinalTotalAmount = ISNULL(tk.TongTienPhong, 0) + inv.TotalServiceCharge + ISNULL(tk.TongPhiNhanSom, 0) + ISNULL(tk.TongPhiTraTre, 0)
                 FROM   Invoice AS inv
                        LEFT OUTER JOIN
                        ThongKeTienPhong AS tk
                        ON inv.BookingId = tk.BookingId
                 WHERE  inv.BookingId IN (SELECT BookingId
                                          FROM   @AffectedBookings);
                 -- Đồng bộ lại trạng thái thanh toán hóa đơn
                 UPDATE inv
                 SET    inv.InvoiceStatus = CASE WHEN ISNULL(DaThu.TongThu, 0) >= inv.FinalTotalAmount
                                                      AND inv.FinalTotalAmount > 0 THEN 'Paid' WHEN ISNULL(DaThu.TongThu, 0) > 0 THEN 'PartiallyPaid' ELSE 'Unpaid' END
                 FROM   Invoice AS inv
                        OUTER APPLY (SELECT SUM(p.TotalAmount) AS TongThu
                                     FROM   Payment AS p
                                     WHERE  p.InvoiceId = inv.InvoiceId) AS DaThu
                 WHERE  inv.BookingId IN (SELECT BookingId
                                          FROM   @AffectedBookings);
          END


GO
-- ============================================================================
-- TRIGGER 6: TỰ ĐỘNG CẬP NHẬT TIỀN DỊCH VỤ PHÁT SINH VÀO HÓA ĐƠN
-- BẢNG: Booking_Room_Service | SỰ KIỆN: AFTER INSERT, UPDATE, DELETE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_BookingRoomService_CapNhatTienDichVu
       ON Booking_Room_Service
       AFTER INSERT, UPDATE, DELETE
       AS BEGIN
                 SET NOCOUNT ON;
                 DECLARE @AffectedBookings TABLE (
                        BookingId VARCHAR (10) PRIMARY KEY);
                 INSERT INTO @AffectedBookings (
                        BookingId
                 )
                 SELECT DISTINCT BookingId
                 FROM   inserted
                 UNION
                 SELECT DISTINCT BookingId
                 FROM   deleted;
                 WITH ThongKeDichVu
                 AS   (SELECT   brs.BookingId,
                                SUM(brs.UnitPrice * brs.Quantity) AS TongTienDichVu
                       FROM     Booking_Room_Service AS brs
                       WHERE    brs.BookingId IN (SELECT BookingId
                                                  FROM   @AffectedBookings)
                       GROUP BY brs.BookingId)
                 UPDATE inv
                 SET    inv.TotalServiceCharge = ISNULL(tk.TongTienDichVu, 0),
                        inv.FinalTotalAmount   = inv.TotalRoomCharge + ISNULL(tk.TongTienDichVu, 0) + inv.EarlyCheckInFee + inv.LateCheckOutFee
                 FROM   Invoice AS inv
                        LEFT OUTER JOIN
                        ThongKeDichVu AS tk
                        ON inv.BookingId = tk.BookingId
                 WHERE  inv.BookingId IN (SELECT BookingId
                                          FROM   @AffectedBookings);
                 -- Đồng bộ lại trạng thái thanh toán
                 UPDATE inv
                 SET    inv.InvoiceStatus = CASE WHEN ISNULL(DaThu.TongThu, 0) >= inv.FinalTotalAmount
                                                      AND inv.FinalTotalAmount > 0 THEN 'Paid' WHEN ISNULL(DaThu.TongThu, 0) > 0 THEN 'PartiallyPaid' ELSE 'Unpaid' END
                 FROM   Invoice AS inv
                        OUTER APPLY (SELECT SUM(p.TotalAmount) AS TongThu
                                     FROM   Payment AS p
                                     WHERE  p.InvoiceId = inv.InvoiceId) AS DaThu
                 WHERE  inv.BookingId IN (SELECT BookingId
                                          FROM   @AffectedBookings);
          END


GO
-- ============================================================================
-- TRIGGER 7: ĐỒNG BỘ TRẠNG THÁI HÓA ĐƠN KHI THANH TOÁN (PAYMENT)
-- BẢNG: Payment | SỰ KIỆN: AFTER INSERT, UPDATE, DELETE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_Payment_DongBoTrangThaiHoaDon
       ON Payment
       AFTER INSERT, UPDATE, DELETE
       AS BEGIN
                 SET NOCOUNT ON;
                 DECLARE @AffectedInvoices TABLE (
                        InvoiceId VARCHAR (10) PRIMARY KEY);
                 INSERT INTO @AffectedInvoices (
                        InvoiceId
                 )
                 SELECT DISTINCT InvoiceId
                 FROM   inserted
                 UNION
                 SELECT DISTINCT InvoiceId
                 FROM   deleted;
                 UPDATE inv
                 SET    inv.InvoiceStatus = CASE WHEN ISNULL(DaThu.TongThu, 0) >= inv.FinalTotalAmount
                                                      AND inv.FinalTotalAmount > 0 THEN 'Paid' WHEN ISNULL(DaThu.TongThu, 0) > 0 THEN 'PartiallyPaid' ELSE 'Unpaid' END
                 FROM   Invoice AS inv
                        INNER JOIN
                        @AffectedInvoices AS ai
                        ON inv.InvoiceId = ai.InvoiceId
                        OUTER APPLY (SELECT SUM(p.TotalAmount) AS TongThu
                                     FROM   Payment AS p
                                     WHERE  p.InvoiceId = inv.InvoiceId) AS DaThu;
          END


GO
-- ============================================================================
-- TRIGGER 8: ĐỒNG BỘ HỦY PHÒNG VÀ CHẶN HỦY SAU CHECK-IN
-- BẢNG: CancellationHistory | SỰ KIỆN: AFTER INSERT
-- ============================================================================
CREATE OR ALTER TRIGGER trg_Cancellation_DongBoHuyPhong
       ON CancellationHistory
       AFTER INSERT
       AS BEGIN
                 SET NOCOUNT ON;
                 -- 1. Chặn hủy phòng nếu khách đã Check-in lưu trú
                 IF EXISTS (SELECT 1
                            FROM   inserted AS i
                                   INNER JOIN
                                   Booking_Room AS br
                                   ON i.BookingId = br.BookingId
                                      AND i.RoomId = br.RoomId
                            WHERE  br.BookingStatus = 'CheckedIn'
                                   OR br.ActualCheckInDate IS NOT NULL)
                        BEGIN
                               RAISERROR (N'Lỗi nghiệp vụ: Không thể hủy phòng khi khách đã làm thủ tục Check-in lưu trú!', 16, 1);
                               ROLLBACK;
                               RETURN;
                        END
                 -- 2. Cập nhật trạng thái phòng trong đơn thành 'Cancelled'
                 UPDATE br
                 SET    br.BookingStatus = 'Cancelled'
                 FROM   Booking_Room AS br
                        INNER JOIN
                        inserted AS i
                        ON br.BookingId = i.BookingId
                           AND br.RoomId = i.RoomId;
                 -- 3. Trả phòng về Vacant (nếu đang bị giữ)
                 UPDATE r
                 SET    r.OccupancyStatus = 'Vacant'
                 FROM   Room AS r
                        INNER JOIN
                        inserted AS i
                        ON r.RoomId = i.RoomId;
          END


GO
-- ============================================================================
-- TRIGGER 9: TỰ ĐỘNG CHUYỂN PHÒNG SANG 'CLEAN' KHI HOÀN TẤT DỌN DẸP
-- BẢNG: RoomCleaningTask | SỰ KIỆN: AFTER UPDATE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_RoomCleaningTask_HoanTatDonPhong
       ON RoomCleaningTask
       AFTER UPDATE
       AS BEGIN
                 SET NOCOUNT ON;
                 IF UPDATE (RoomCleaningTaskStatus)
                        BEGIN
                               UPDATE r
                               SET    r.HousekeepingStatus = 'Clean'
                               FROM   Room AS r
                                      INNER JOIN
                                      inserted AS i
                                      ON r.RoomId = i.RoomId
                                      INNER JOIN
                                      deleted AS d
                                      ON i.RoomCleaningTaskId = d.RoomCleaningTaskId
                               WHERE  d.RoomCleaningTaskStatus <> 'Completed'
                                      AND i.RoomCleaningTaskStatus = 'Completed';
                        END
          END


GO
-- ============================================================================
-- TRIGGER 10: TỰ ĐỘNG ĐỔI TRẠNG THÁI PHÒNG KHI PHÁT HIỆN / XỬ LÝ HƯ HỎNG
-- BẢNG: DamageReport | SỰ KIỆN: AFTER INSERT, UPDATE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_DamageReport_CapNhatTrangThaiPhong
       ON DamageReport
       AFTER INSERT, UPDATE
       AS BEGIN
                 SET NOCOUNT ON;
                 -- 1. Khi biên bản hư hỏng được xác nhận (Confirmed) -> chuyển phòng sang 'Maintenance'
                 UPDATE r
                 SET    r.RoomStatus = 'Maintenance'
                 FROM   Room AS r
                        INNER JOIN
                        inserted AS i
                        ON r.RoomId = i.RoomId
                 WHERE  i.DamageReportStatus = 'Confirmed'
                        AND r.RoomStatus <> 'Maintenance';
                 -- 2. Khi sự cố đã giải quyết (Resolved) -> nếu không còn sự cố nào khác thì chuyển về 'Available'
                 UPDATE r
                 SET    r.RoomStatus = 'Available'
                 FROM   Room AS r
                        INNER JOIN
                        inserted AS i
                        ON r.RoomId = i.RoomId
                 WHERE  i.DamageReportStatus = 'Resolved'
                        AND r.RoomStatus = 'Maintenance'
                        AND NOT EXISTS (SELECT 1
                                        FROM   DamageReport AS dr
                                        WHERE  dr.RoomId = r.RoomId
                                               AND dr.DamageReportStatus IN ('Pending', 'Confirmed'));
          END


GO
-- ============================================================================
-- TRIGGER 11: TỰ ĐỘNG KHÓA TÀI KHOẢN KHI NHÂN VIÊN NGHỈ VIỆC
-- BẢNG: Employee | SỰ KIỆN: AFTER UPDATE
-- ============================================================================
CREATE OR ALTER TRIGGER trg_Employee_KhoaTaiKhoanNghiViec
       ON Employee
       AFTER UPDATE
       AS BEGIN
                 SET NOCOUNT ON;
                 IF UPDATE (EmployeeStatus)
                    OR UPDATE (ResignationDate)
                        BEGIN
                               UPDATE acc
                               SET    acc.AccountStatus = 'Locked'
                               FROM   Account AS acc
                                      INNER JOIN
                                      inserted AS i
                                      ON acc.AccountId = i.AccountId
                               WHERE  i.AccountId IS NOT NULL
                                      AND (i.EmployeeStatus = 'Resigned'
                                           OR (i.ResignationDate IS NOT NULL
                                               AND i.ResignationDate <= CAST (GETDATE() AS DATE)));
                        END
          END