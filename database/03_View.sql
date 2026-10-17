USE QuanLyKhachSan;


GO
-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
-- SCRIPT 03: HỆ THỐNG VIEW CHUẨN HÓA TIẾNG ANH (100% ENGLISH PASCALCASE)
-- ============================================================================
-- Dọn dẹp các view cũ tiếng Việt (nếu có)
DROP VIEW IF EXISTS v_DanhSachPhongHuHaiCanBaoTri;

DROP VIEW IF EXISTS v_TyLeLapDayPhong;

DROP VIEW IF EXISTS v_ThongTinChiTietPhong;

DROP VIEW IF EXISTS v_DanhSachDonCanThuTien;

DROP VIEW IF EXISTS v_DanhSachNhiemVuDonPhong;

DROP VIEW IF EXISTS v_DanhSachDonCheckInTiepNhan;

DROP VIEW IF EXISTS v_DanhSachYeuCauHoanTien;


GO
-- ============================================================================
-- VIEW 1: MAINTENANCE PENDING ROOMS (DAMAGED ROOMS NEEDING REPAIR)
-- Phục vụ: MaintenanceDAO.java (Màn hình điều phối bảo trì của Quản lý)
-- ============================================================================
CREATE OR ALTER VIEW v_MaintenancePendingRooms
AS
SELECT dr.DamageReportId AS ReportId,
       r.RoomId,
       r.RoomName,
       rt.RoomTypeName,
       dr.DetectedAt,
       dt.DamageName AS DamageTypeName,
       drdt.Note AS DamageDescription,
       dr.DamageReportStatus AS ReportStatus,
       ISNULL(emp.FullName, acc.UserName) AS ReportedBy
FROM   DamageReport AS dr
       INNER JOIN
       Room AS r
       ON dr.RoomId = r.RoomId
       INNER JOIN
       RoomType AS rt
       ON r.RoomTypeId = rt.RoomTypeId
       INNER JOIN
       DamageReport_DamageType AS drdt
       ON dr.DamageReportId = drdt.DamageReportId
       INNER JOIN
       DamageType AS dt
       ON drdt.DamageTypeId = dt.DamageTypeId
       LEFT OUTER JOIN
       Account AS acc
       ON dr.CreateBy = acc.AccountId
       LEFT OUTER JOIN
       Employee AS emp
       ON acc.AccountId = emp.AccountId
WHERE  dr.DamageReportStatus IN ('Pending', 'Confirmed');


GO
-- ============================================================================
-- VIEW 2: ROOM OCCUPANCY RATE REPORT (PMS OCCUPANCY METRICS)
-- Phục vụ: ManagerDashboardDAO.java (Dashboard Quản lý)
-- ============================================================================
CREATE OR ALTER VIEW v_RoomOccupancyRate
AS
SELECT COUNT(*) AS TotalRooms,
       COUNT(CASE WHEN OccupancyStatus = 'Occupied' THEN 1 END) AS OccupiedRooms,
       COUNT(CASE WHEN RoomStatus = 'Available'
                       AND OccupancyStatus = 'Vacant'
                       AND HousekeepingStatus = 'Clean' THEN 1 END) AS AvailableRooms,
       COUNT(CASE WHEN HousekeepingStatus IN ('Dirty', 'Cleaning') THEN 1 END) AS CleaningRooms,
       COUNT(CASE WHEN RoomStatus IN ('Maintenance', 'OutOfService') THEN 1 END) AS MaintenanceRooms,
       ROUND((COUNT(CASE WHEN OccupancyStatus = 'Occupied' THEN 1 END) * 100.0) / NULLIF (COUNT(*), 0), 2) AS OccupancyRatePercentage
FROM   Room;


GO
-- ============================================================================
-- VIEW 3: DETAILED ROOM INFORMATION WITH 3NF BED TYPES & AMENITIES
-- Phục vụ: RoomDAO.java (searchAvailableRooms, getRoomDetailById, getAllRoomsForTimeline)
-- ============================================================================
CREATE OR ALTER VIEW v_RoomDetails
AS
SELECT r.RoomId,
       r.RoomName,
       r.RoomStatus,
       r.OccupancyStatus,
       r.HousekeepingStatus,
       rt.RoomTypeId,
       rt.RoomTypeName,
       rt.Capacity,
       rt.BasePrice,
       rt.DepositPercent,
       rt.IsActive AS RoomTypeIsActive,
       r.RoomName AS RoomDescription,
       ISNULL((SELECT STRING_AGG(rs.RoomServiceName, ', ')
               FROM   RoomType_RoomService AS rtrs
                      INNER JOIN
                      RoomService AS rs
                      ON rtrs.RoomServiceId = rs.RoomServiceId
               WHERE  rtrs.RoomTypeId = rt.RoomTypeId
                      AND rs.IsActive = 1), N'Đầy đủ tiện nghi cơ bản') AS AmenitiesDescription,
       ISNULL((SELECT STRING_AGG(CONCAT(rtbt.Quantity, ' ', bt.BedTypeName), ', ')
               FROM   RoomType_BedType AS rtbt
                      INNER JOIN
                      BedType AS bt
                      ON rtbt.BedTypeId = bt.BedTypeId
               WHERE  rtbt.RoomTypeId = rt.RoomTypeId
                      AND bt.IsActive = 1), N'Tiêu chuẩn') AS BedTypesDescription
FROM   Room AS r
       INNER JOIN
       RoomType AS rt
       ON r.RoomTypeId = rt.RoomTypeId;


GO
-- ============================================================================
-- VIEW 4: ACTIVE RECEIVABLE BOOKINGS (CASHIER RECEIVABLES & DEBT)
-- Phục vụ: ActiveBookingDAO.java (Dashboard Thu Ngân / Check-out)
-- ============================================================================
CREATE OR ALTER VIEW v_ReceivableBookings
AS
SELECT   b.BookingId,
         c.FullName AS CustomerName,
         c.PhoneNumber,
         c.CCCD,
         ISNULL(inv.FinalTotalAmount, 0) AS EstimatedTotal,
         ISNULL((SELECT TOP 1 br_st.BookingStatus
                 FROM   Booking_Room AS br_st
                 WHERE  br_st.BookingId = b.BookingId), 'CheckedIn') AS BookingStatus,
         COUNT(br.RoomId) AS TotalRooms,
         STRING_AGG(br.RoomId, ', ') AS RoomList,
         SUM(CASE WHEN br.ActualCheckOutDate IS NULL THEN 1 ELSE 0 END) AS PendingCheckOutRooms,
         inv.InvoiceId,
         ISNULL(inv.InvoiceStatus, 'Unpaid') AS InvoiceStatus,
         ISNULL(inv.FinalTotalAmount, 0) AS TotalAmount,
         ISNULL(tt.DaTra, 0) AS PaidAmount,
         (ISNULL(inv.FinalTotalAmount, 0) - ISNULL(tt.DaTra, 0)) AS RemainingDebt
FROM     Booking AS b
         INNER JOIN
         Customer AS c
         ON b.CustomerId = c.CustomerId
         INNER JOIN
         Booking_Room AS br
         ON b.BookingId = br.BookingId
         LEFT OUTER JOIN
         Invoice AS inv
         ON b.BookingId = inv.BookingId
         OUTER APPLY (SELECT SUM(TotalAmount) AS DaTra
                      FROM   Payment
                      WHERE  InvoiceId = inv.InvoiceId) AS tt
WHERE    EXISTS (SELECT 1
                 FROM   Booking_Room AS br2
                 WHERE  br2.BookingId = b.BookingId
                        AND br2.BookingStatus IN ('CheckedIn', 'CheckedOut'))
         AND ISNULL(inv.InvoiceStatus, 'Unpaid') <> 'Paid'
GROUP BY b.BookingId, c.FullName, c.PhoneNumber, c.CCCD, inv.FinalTotalAmount, inv.InvoiceId, inv.InvoiceStatus, tt.DaTra;


GO
-- ============================================================================
-- VIEW 5: HOUSEKEEPER ROOM CLEANING TASKS
-- Phục vụ: HousekeeperTaskDAO.java (Màn hình Buồng Phòng Housekeeper)
-- ============================================================================
CREATE OR ALTER VIEW v_HousekeeperTasks
AS
SELECT rct.RoomCleaningTaskId AS TaskId,
       r.RoomId,
       r.RoomName,
       rt.RoomTypeName,
       r.HousekeepingStatus AS RoomStatus,
       rct.RoomCleaningTaskStatus AS TaskStatus,
       ISNULL(rct.ReceivedBy, '') AS StaffId,
       ISNULL(emp.FullName, acc.UserName) AS StaffName,
       rct.StartTime AS AssignedTime,
       rct.StartTime,
       rct.EndTime,
       rct.Result
FROM   RoomCleaningTask AS rct
       INNER JOIN
       Room AS r
       ON rct.RoomId = r.RoomId
       INNER JOIN
       RoomType AS rt
       ON r.RoomTypeId = rt.RoomTypeId
       LEFT OUTER JOIN
       Account AS acc
       ON rct.ReceivedBy = acc.AccountId
       LEFT OUTER JOIN
       Employee AS emp
       ON acc.AccountId = emp.AccountId;


GO
-- ============================================================================
-- VIEW 6: FRONT DESK ARRIVAL BOOKINGS AWAITING CHECK-IN
-- Phục vụ: BookingCheckInQueryDAO.java (Màn hình Quầy Lễ Tân Check-in)
-- ============================================================================
CREATE OR ALTER VIEW v_ArrivalCheckInBookings
AS
SELECT   b.BookingId,
         c.FullName AS CustomerName,
         c.PhoneNumber,
         c.CCCD,
         MIN(br.ExpectedCheckInDate) AS ExpectedCheckInDate,
         MAX(br.ExpectedCheckOutDate) AS ExpectedCheckOutDate,
         COUNT(br.RoomId) AS TotalRooms,
         COUNT(CASE WHEN br.ActualCheckInDate IS NOT NULL THEN 1 END) AS ReceivedRooms
FROM     Booking AS b
         INNER JOIN
         Customer AS c
         ON b.CustomerId = c.CustomerId
         INNER JOIN
         Booking_Room AS br
         ON b.BookingId = br.BookingId
WHERE    br.BookingStatus IN ('Confirmed', 'CheckedIn')
GROUP BY b.BookingId, c.FullName, c.PhoneNumber, c.CCCD;


GO
-- ============================================================================
-- VIEW 7: CANCELLATION AND REFUND REQUESTS
-- Phục vụ: ManagerRefundDAO.java (Màn hình Phê duyệt hoàn cọc)
-- ============================================================================
CREATE OR ALTER VIEW v_RefundRequests
AS
SELECT ch.CancellationId,
       ch.BookingId,
       ch.RoomId,
       r.RoomName,
       ISNULL(acc.UserName, ch.CancelledBy) AS CancelledBy,
       ch.DepositAtCancellation,
       ch.CancellationDate,
       ch.CancellationFee,
       ch.RefundStatus,
       ch.Reason,
       dbo.fn_TinhTienHoanTraHuyPhong(ch.CancellationId) AS RefundAmount
FROM   CancellationHistory AS ch
       INNER JOIN
       Room AS r
       ON ch.RoomId = r.RoomId
       LEFT OUTER JOIN
       Account AS acc
       ON ch.CancelledBy = acc.AccountId;
GO

-- ============================================================================
-- VIEW 8: CUSTOMER BOOKING HISTORY
-- Phục vụ: BookingQueryDAO.java (Màn hình Lịch sử Đặt phòng của Khách hàng)
-- ============================================================================
CREATE OR ALTER VIEW v_CustomerBookingHistory
AS
SELECT b.BookingId,
       b.CustomerId,
       b.CreateBy AS AccountId,
       CAST(COUNT(br.RoomId) AS VARCHAR) + N' phòng' AS RoomSummary,
       N'' AS RoomTypeName,
       b.CreateDate,
       MIN(br.ExpectedCheckInDate) AS ExpectedCheckInDate,
       MAX(br.ExpectedCheckOutDate) AS ExpectedCheckOutDate,
       ISNULL(inv.FinalTotalAmount, 0) AS EstimatedTotal,
       ISNULL(MIN(br.BookingStatus), 'Confirmed') AS BookingStatus,
       inv.InvoiceId,
       inv.InvoiceStatus
FROM Booking b
LEFT JOIN Booking_Room br ON b.BookingId = br.BookingId
LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId
GROUP BY b.BookingId, b.CustomerId, b.CreateBy, b.CreateDate, inv.FinalTotalAmount, inv.InvoiceId, inv.InvoiceStatus;
GO

-- ============================================================================
-- VIEW 9: INVOICE REVENUE REPORT
-- Phục vụ: RevenueReportDAO.java (Báo cáo Doanh thu Hóa đơn cho Quản lý)
-- ============================================================================
CREATE OR ALTER VIEW v_InvoiceRevenueReport
AS
SELECT inv.InvoiceId,
       inv.BookingId,
       c.FullName AS CustomerName,
       ISNULL((SELECT STRING_AGG(r2.RoomName, ', ') FROM Booking_Room br2 
               INNER JOIN Room r2 ON br2.RoomId = r2.RoomId WHERE br2.BookingId = inv.BookingId), N'Chưa xếp') AS RoomNames,
       inv.CreateDate,
       ISNULL((SELECT SUM(br3.Deposit) FROM Booking_Room br3 WHERE br3.BookingId = inv.BookingId), 0) AS DepositAmount,
       inv.TotalRoomCharge,
       inv.TotalServiceCharge,
       (inv.EarlyCheckInFee + inv.LateCheckOutFee) AS Surcharge,
       inv.FinalTotalAmount,
       ISNULL((SELECT SUM(p.TotalAmount) FROM Payment p WHERE p.InvoiceId = inv.InvoiceId), 0) AS PaidAmount,
       inv.InvoiceStatus
FROM Invoice inv
INNER JOIN Booking b ON inv.BookingId = b.BookingId
INNER JOIN Customer c ON b.CustomerId = c.CustomerId;
GO

-- ============================================================================
-- VIEW 10: PAYMENT RECEIPT REPORT
-- Phục vụ: RevenueReportDAO.java (Báo cáo Phiếu thu Tiền mặt & Chuyển khoản)
-- ============================================================================
CREATE OR ALTER VIEW v_PaymentReceiptReport
AS
SELECT p.PaymentId,
       p.InvoiceId,
       inv.BookingId,
       c.FullName AS CustomerName,
       p.PaymentDate,
       p.PaymentMethod,
       ISNULL(emp.FullName, ISNULL(acc.UserName, N'Khách online')) AS StaffName,
       emp.EmployeeId,
       p.TotalAmount,
       p.Note
FROM Payment p
INNER JOIN Invoice inv ON p.InvoiceId = inv.InvoiceId
INNER JOIN Booking b ON inv.BookingId = b.BookingId
INNER JOIN Customer c ON b.CustomerId = c.CustomerId
LEFT JOIN Account acc ON p.ProcessBy = acc.AccountId
LEFT JOIN Employee emp ON acc.AccountId = emp.AccountId;
GO

-- ============================================================================
-- VIEW 11: DAMAGE REPORTS (ALL INCIDENTS FOR HOUSEKEEPING & MAINTENANCE)
-- Phục vụ: DamageReportDAO.java (Lịch sử sự cố hư hại Buồng Phòng & Nghiệm thu)
-- ============================================================================
CREATE OR ALTER VIEW v_DamageReports
AS
SELECT dr.DamageReportId,
       dr.RoomId,
       r.RoomName,
       rt.RoomTypeName,
       dr.DetectedAt,
       dt.DamageName AS DamageTypeName,
       drdt.Note AS DamageDescription,
       dr.DamageReportStatus AS ReportStatus,
       dr.CreateBy
FROM   DamageReport AS dr
       INNER JOIN
       Room AS r
       ON dr.RoomId = r.RoomId
       INNER JOIN
       RoomType AS rt
       ON r.RoomTypeId = rt.RoomTypeId
       LEFT JOIN
       DamageReport_DamageType AS drdt
       ON dr.DamageReportId = drdt.DamageReportId
       LEFT JOIN
       DamageType AS dt
       ON drdt.DamageTypeId = dt.DamageTypeId;
GO