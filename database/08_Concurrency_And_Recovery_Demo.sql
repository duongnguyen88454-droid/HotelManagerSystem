-- ============================================================================
-- DỰ ÁN HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGER SYSTEM)
-- SCRIPT MINH CHỨNG: 
-- 1. XỬ LÝ TRANH CHẤP TRUY CẬP ĐỒNG THỜI (CONCURRENCY CONTROL / DOUBLE BOOKING)
-- 2. KHÔI PHỤC SAU SỰ CỐ DỮ LIỆU (DISASTER RECOVERY / BACKUP & RESTORE)
-- ============================================================================
USE QuanLyKhachSan;


GO
/*
================================================================================
PHẦN 1: MINH CHỨNG XỬ LÝ TRANH CHẤP ĐỒNG THỜI (CONCURRENCY CONTROL)
================================================================================
Mục tiêu: 
- Chứng minh hệ thống không bao giờ bị Overbooking (đặt đè phòng) khi 2 khách hàng
  cùng bấm đặt chung 1 phòng trong cùng một khoảng thời gian.
- Cơ chế bảo vệ: 
  + Cấp CSDL: Exclusive Lock (X-Lock) và Trigger AFTER INSERT [trg_BookingRoom_KiemTraXungDot]
  + Cấp Ứng dụng: JDBC Transaction (ACID) rollback toàn bộ khi bắt SQLException.

HƯỚNG DẪN THỰC HIỆN TRÊN SSMS (Mở 2 Tab truy vấn khác nhau):
--------------------------------------------------------------------------------
*/
-- =============================================================================
-- [TAB 1 - KHÁCH HÀNG A]: Bấm đặt phòng P101 từ ngày 2026-11-01 đến 2026-11-05
-- =============================================================================
/*
USE QuanLyKhachSan;
BEGIN TRANSACTION;

-- Bước 1: Tạo đơn đặt phòng của Khách A
INSERT INTO Booking (BookingId, CustomerId, CreateBy, CreateDate) 
VALUES ('BK_TEST_A', 'KH001', 'ACC002', GETDATE());

-- Bước 2: Đặt phòng P101 (SQL Server sẽ tạo Exclusive Lock trên bảng Booking_Room)
INSERT INTO Booking_Room (BookingId, RoomId, BookingStatus, ExpectedCheckInDate, ExpectedCheckOutDate, Price, Deposit)
VALUES ('BK_TEST_A', 'P101', 'Confirmed', '2026-11-01', '2026-11-05', 500000, 100000);

PRINT N'>>> TAB 1 (Khách A): Đang giữ kết nối và chưa COMMIT...';
-- (LƯU Ý: Giữ nguyên Tab 1 không chạy lệnh COMMIT để mô phỏng tranh chấp đồng thời)
*/
-- =============================================================================
-- [TAB 2 - KHÁCH HÀNG B]: Cùng thời điểm đó, cố tình đặt đè phòng P101 (2026-11-02 -> 2026-11-04)
-- =============================================================================
/*
USE QuanLyKhachSan;
BEGIN TRANSACTION;

-- Bước 1: Tạo đơn của Khách B
INSERT INTO Booking (BookingId, CustomerId, CreateBy, CreateDate) 
VALUES ('BK_TEST_B', 'KH002', 'ACC002', GETDATE());

-- Bước 2: Cố tình đặt đè vào phòng P101
INSERT INTO Booking_Room (BookingId, RoomId, BookingStatus, ExpectedCheckInDate, ExpectedCheckOutDate, Price, Deposit)
VALUES ('BK_TEST_B', 'P101', 'Confirmed', '2026-11-02', '2026-11-04', 500000, 100000);

PRINT N'>>> TAB 2 (Khách B): Sẽ bị rơi vào trạng thái BLOCKED (Chờ Tab 1 nhả khóa)!';
*/
-- =============================================================================
-- [KẾT QUẢ KHI TAB 1 CHẠY COMMIT]:
-- =============================================================================
/*
Quay lại TAB 1 và chạy:
    COMMIT TRANSACTION;

Ngay lập tức, TAB 2 sẽ bị Trigger chặn đứng và báo lỗi:
    Msg 50000, Level 16, State 1, Procedure trg_BookingRoom_KiemTraXungDot:
    Lỗi nghiệp vụ: Phòng này đã có khách đặt trong khoảng thời gian yêu cầu!
    Msg 3609, Level 16, State 1: The transaction ended in the trigger. The batch has been aborted.

Toàn bộ dữ liệu của Khách B bị ROLLBACK hoàn toàn. Phòng P101 an toàn 100%!
*/
-- LỆNH DỌN DẸP DỮ LIỆU TEST (Chạy sau khi demo xong):
/*
DELETE FROM Booking_Room WHERE BookingId IN ('BK_TEST_A', 'BK_TEST_B');
DELETE FROM Booking WHERE BookingId IN ('BK_TEST_A', 'BK_TEST_B');
*/
/*
================================================================================
PHẦN 2: MINH CHỨNG KHÔI PHỤC SAU SỰ CỐ (DISASTER RECOVERY)
================================================================================
Mục tiêu:
- Chứng minh khả năng phục hồi nguyên vẹn cơ sở dữ liệu khi gặp sự cố nghiêm trọng
  (xóa nhầm dữ liệu, hỏng bảng, ransomware hoặc sự cố phần cứng).
*/
-- BƯỚC 1: Kiểm tra số lượng bản ghi hiện có
SELECT COUNT(*) AS TongSoBookingTruocSuCo
FROM   Booking;

SELECT COUNT(*) AS TongSoBookingRoomTruocSuCo
FROM   Booking_Room;


GO
-- BƯỚC 2: Tạo một bản sao lưu toàn vẹn (Full Database Backup)
BACKUP DATABASE QuanLyKhachSan
  TO DISK = 'd:\Learn\College\Lap trinh web\HotelManagerSystem\database\backup_QuanLyKhachSan_Demo.bak'
  WITH FORMAT, INIT, NAME = N'QuanLyKhachSan-Full Backup Demo';

PRINT N'>>> Đã tạo bản sao lưu an toàn tại database\backup_QuanLyKhachSan_Demo.bak';


GO
-- BƯỚC 3: GIẢ LẬP SỰ CỐ THẢM HỌA (Xóa toàn bộ đơn đặt phòng)
DELETE Booking_Room_Service;

DELETE Booking_Room;

DELETE Invoice;

DELETE Booking;

PRINT N'>>> [CẢNH BÁO SỰ CỐ]: Toàn bộ dữ liệu đặt phòng đã bị xóa!';

SELECT COUNT(*) AS SoLuongSauSuCo
FROM   Booking; -- Trả về 0


GO
-- BƯỚC 4: THỰC HIỆN KHÔI PHỤC DỮ LIỆU (DISASTER RECOVERY)
USE master;

ALTER DATABASE QuanLyKhachSan
  SET SINGLE_USER 
  WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE QuanLyKhachSan FROM DISK = 'd:\Learn\College\Lap trinh web\HotelManagerSystem\database\backup_QuanLyKhachSan_Demo.bak'
  WITH REPLACE, RECOVERY;

ALTER DATABASE QuanLyKhachSan
  SET MULTI_USER;

PRINT N'>>> [THÀNH CÔNG]: Đã khôi phục hoàn toàn cơ sở dữ liệu về trạng thái trước sự cố!';


GO
-- BƯỚC 5: KIỂM TRA DỮ LIỆU SAU PHỤC HỒI
USE QuanLyKhachSan;

SELECT COUNT(*) AS TongSoBookingSauPhucHoi
FROM   Booking;

SELECT COUNT(*) AS TongSoBookingRoomSauPhucHoi
FROM   Booking_Room;