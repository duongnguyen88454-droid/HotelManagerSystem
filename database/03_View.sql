USE QuanLyKhachSan;


GO
-- ============================================================================
-- View 1: Danh sách phòng trống khả dụng (Màn hình Booking Online & Quầy Lễ tân)
-- ============================================================================
CREATE OR ALTER VIEW v_DanhSachPhongKhaDung
AS
SELECT r.RoomId AS MaPhong,
       r.RoomName AS SoPhong,
       rt.RoomTypeId AS MaLoaiPhong,
       rt.RoomTypeName AS TenLoaiPhong,
       rt.BasePrice AS GiaPhong,
       rt.Capacity AS SoNguoiToiDa,
       r.RoomName AS MoTaPhong
FROM   Room AS r
       INNER JOIN
       RoomType AS rt
       ON r.RoomTypeId = rt.RoomTypeId
WHERE  r.RoomStatus = 'Available'
       AND r.HousekeepingStatus = 'Clean'
       AND r.OccupancyStatus = 'Vacant'
       AND rt.IsActive = 1;


GO
-- ============================================================================
-- View 2: Danh sách phòng cần dọn dẹp hàng ngày (Màn hình phân công Housekeeper)
-- ============================================================================
CREATE OR ALTER VIEW v_DanhSachPhongCanDonDep
AS
SELECT rct.RoomCleaningTaskId AS MaNhiemVu,
       r.RoomId AS MaPhong,
       r.RoomName AS SoPhong,
       rt.RoomTypeName AS TenLoaiPhong,
       r.HousekeepingStatus AS TrangThaiPhong,
       rct.RoomCleaningTaskStatus AS TrangThaiNhiemVu,
       emp.EmployeeId AS MaNhanVienDon,
       ISNULL(emp.FullName, acc.UserName) AS TenNhanVienDon,
       rct.StartTime AS ThoiGianNhan,
       rct.StartTime AS ThoiGianBatDau
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
       ON acc.AccountId = emp.AccountId
WHERE  rct.RoomCleaningTaskStatus IN ('Pending', 'InProgress');


GO
-- ============================================================================
-- View 3: Danh sách phòng hư hại chờ bảo trì (Màn hình điều phối Quản lý)
-- ============================================================================
CREATE OR ALTER VIEW v_DanhSachPhongHuHaiCanBaoTri
AS
SELECT dr.DamageReportId AS MaBaoCao,
       r.RoomId AS MaPhong,
       r.RoomName AS SoPhong,
       rt.RoomTypeName AS TenLoaiPhong,
       dr.DetectedAt AS NgayPhatHien,
       dt.DamageName AS TenLoaiHuHai,
       drdt.Note AS MoTaChiTiet,
       dr.DamageReportStatus AS TrangThaiBaoCao,
       ISNULL(emp.FullName, acc.UserName) AS NhanVienPhatHien
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
-- View 4: Theo dõi công nợ và quyết toán hóa đơn (Màn hình Thu ngân / Lễ tân)
-- ============================================================================
CREATE OR ALTER VIEW v_CongNoHoaDonKhachHang
AS
SELECT   inv.InvoiceId AS MaHoaDon,
         b.BookingId AS MaBooking,
         c.FullName AS NguoiDaiDienBooking,
         c.PhoneNumber AS SoDT,
         inv.CreateDate AS NgayLap,
         inv.FinalTotalAmount AS TongTienPhaiTra,
         ISNULL(SUM(p.TotalAmount), 0) AS DaThanhToan,
         (inv.FinalTotalAmount - ISNULL(SUM(p.TotalAmount), 0)) AS ConThieu,
         inv.InvoiceStatus AS TrangThaiHoaDon
FROM     Invoice AS inv
         INNER JOIN
         Booking AS b
         ON inv.BookingId = b.BookingId
         INNER JOIN
         Customer AS c
         ON b.CustomerId = c.CustomerId
         LEFT OUTER JOIN
         Payment AS p
         ON inv.InvoiceId = p.InvoiceId
GROUP BY inv.InvoiceId, b.BookingId, c.FullName, c.PhoneNumber, inv.CreateDate, inv.FinalTotalAmount, inv.InvoiceStatus;


GO
-- ============================================================================
-- View 5: Báo cáo tài chính doanh thu tổng hợp theo tháng (Quản lý & Giám đốc)
-- ============================================================================
CREATE OR ALTER VIEW v_BaoCaoDoanhThuTheoThang
AS
SELECT   YEAR(p.PaymentDate) AS Nam,
         MONTH(p.PaymentDate) AS Thang,
         COUNT(DISTINCT p.PaymentId) AS SoLuotGiaoDich,
         COUNT(DISTINCT inv.InvoiceId) AS SoHoaDonDaThanhToan,
         SUM(p.TotalAmount) AS TongDoanhThuThucThu
FROM     Payment AS p
         INNER JOIN
         Invoice AS inv
         ON p.InvoiceId = inv.InvoiceId
GROUP BY YEAR(p.PaymentDate), MONTH(p.PaymentDate);


GO
-- ============================================================================
-- View 6: Thống kê dịch vụ gia tăng được ưa chuộng (Bộ phận Kinh doanh)
-- ============================================================================
CREATE OR ALTER VIEW v_ThongKeDichVuBanChay
AS
SELECT   s.ServiceId AS MaDichVu,
         s.ServiceName AS TenDichVu,
         s.BasePrice AS DonGiaHienTai,
         ISNULL(SUM(brs.Quantity), 0) AS TongSoLuongSuDung,
         ISNULL(SUM(brs.UnitPrice * brs.Quantity), 0) AS TongDoanhThuDichVu
FROM     Service AS s
         LEFT OUTER JOIN
         Booking_Room_Service AS brs
         ON s.ServiceId = brs.ServiceId
GROUP BY s.ServiceId, s.ServiceName, s.BasePrice;


GO
-- ============================================================================
-- View 7: Báo cáo tỷ lệ công suất phòng (Dashboard Quản lý)
-- ============================================================================
CREATE OR ALTER VIEW v_TyLeLapDayPhong
AS
SELECT COUNT(*) AS TongSoPhong,
       COUNT(CASE WHEN OccupancyStatus = 'Occupied' THEN 1 END) AS SoPhongDangCoKhach,
       COUNT(CASE WHEN RoomStatus = 'Available'
                       AND OccupancyStatus = 'Vacant'
                       AND HousekeepingStatus = 'Clean' THEN 1 END) AS SoPhongTrong,
       COUNT(CASE WHEN HousekeepingStatus IN ('Dirty', 'Cleaning') THEN 1 END) AS SoPhongDangDon,
       COUNT(CASE WHEN RoomStatus IN ('Maintenance', 'OutOfService') THEN 1 END) AS SoPhongHuHai,
       ROUND((COUNT(CASE WHEN OccupancyStatus = 'Occupied' THEN 1 END) * 100.0) / NULLIF (COUNT(*), 0), 2) AS TyLeLapDayPhanTram
FROM   Room;