-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
-- SCRIPT 07: BẢO MẬT & PHÂN QUYỀN TRÊN HỆ THỐNG CSDL (RBAC SECURITY)
-- HỆ QUẢN TRỊ CSDL: MICROSOFT SQL SERVER 2019 / 2022
-- ============================================================================
USE QuanLyKhachSan;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================================
-- BƯỚC 1: DỌN DẸP NẾU ĐÃ TỒN TẠI (ĐẢM BẢO CHẠY ĐƯỢC NHIỀU LẦN - IDEMPOTENT)
-- ============================================================================
-- 1. Xóa Users trong Database QuanLyKhachSan
DROP USER IF EXISTS user_manager;
DROP USER IF EXISTS user_receptionist;
DROP USER IF EXISTS user_housekeeper;
DROP USER IF EXISTS user_customer;
GO

-- 2. Xóa Roles trong Database
DROP ROLE IF EXISTS role_Manager;
DROP ROLE IF EXISTS role_Receptionist;
DROP ROLE IF EXISTS role_Housekeeper;
DROP ROLE IF EXISTS role_Customer;
GO

-- 3. Xóa Logins ở cấp Server (CSDL master)
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_manager') 
    DROP LOGIN login_manager;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_receptionist') 
    DROP LOGIN login_receptionist;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_housekeeper') 
    DROP LOGIN login_housekeeper;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_customer') 
    DROP LOGIN login_customer;
GO

-- ============================================================================
-- BƯỚC 2: TẠO 4 SERVER LOGINS Ở CẤP MÁY CHỦ (SERVER LEVEL)
-- ============================================================================
-- 1. Login Quản trị viên / Giám đốc
CREATE LOGIN login_manager 
    WITH PASSWORD = N'Manager@123456', 
    DEFAULT_DATABASE = QuanLyKhachSan, 
    CHECK_POLICY = OFF;

-- 2. Login Nhân viên Lễ tân / Thu ngân
CREATE LOGIN login_receptionist 
    WITH PASSWORD = N'Reception@123456', 
    DEFAULT_DATABASE = QuanLyKhachSan, 
    CHECK_POLICY = OFF;

-- 3. Login Nhân viên Buồng phòng
CREATE LOGIN login_housekeeper 
    WITH PASSWORD = N'Housekeeper@123456', 
    DEFAULT_DATABASE = QuanLyKhachSan, 
    CHECK_POLICY = OFF;

-- 4. Login Khách hàng đăng nhập cổng Portal / Web
CREATE LOGIN login_customer 
    WITH PASSWORD = N'Customer@123456', 
    DEFAULT_DATABASE = QuanLyKhachSan, 
    CHECK_POLICY = OFF;
GO

-- ============================================================================
-- BƯỚC 3: TẠO 4 DATABASE USERS ÁNH XẠ TỪ CÁC LOGIN VÀO CSDL QUANLYKHACHSAN
-- ============================================================================
CREATE USER user_manager FOR LOGIN login_manager;
CREATE USER user_receptionist FOR LOGIN login_receptionist;
CREATE USER user_housekeeper FOR LOGIN login_housekeeper;
CREATE USER user_customer FOR LOGIN login_customer;
GO

-- ============================================================================
-- BƯỚC 4: TẠO 4 DATABASE ROLES VÀ GÁN USER VÀO TƯƠNG ỨNG
-- ============================================================================
CREATE ROLE role_Manager;
CREATE ROLE role_Receptionist;
CREATE ROLE role_Housekeeper;
CREATE ROLE role_Customer;
GO

ALTER ROLE role_Manager ADD MEMBER user_manager;
ALTER ROLE role_Receptionist ADD MEMBER user_receptionist;
ALTER ROLE role_Housekeeper ADD MEMBER user_housekeeper;
ALTER ROLE role_Customer ADD MEMBER user_customer;
GO

-- ============================================================================
-- BƯỚC 5: THIẾT LẬP CHÍNH SÁCH BẢO MẬT & PHÂN QUYỀN (GRANT / DENY)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 5.1. ROLE: role_Manager (Quản lý toàn quyền nghiệp vụ khách sạn)
-- ----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO role_Manager;
GRANT EXECUTE ON SCHEMA::dbo TO role_Manager;
GO

-- ----------------------------------------------------------------------------
-- 5.2. ROLE: role_Receptionist (Nhân viên Lễ tân & Thu ngân tại quầy)
-- ----------------------------------------------------------------------------
-- Quyền đọc thông tin danh mục, đơn đặt và phiếu thu
GRANT SELECT, INSERT, UPDATE ON Room TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON RoomType TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON BedType TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON RoomType_BedType TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Service TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON RoomService TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON RoomType_RoomService TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Booking TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Booking_Room TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Booking_Room_Service TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Customer TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Invoice TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON Payment TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON CancellationHistory TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON RoomCleaningTask TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON DamageReport TO role_Receptionist;
GRANT SELECT, INSERT, UPDATE ON DamageReport_DamageType TO role_Receptionist;
GRANT SELECT ON DamageType TO role_Receptionist;

-- Quyền xem các View nghiệp vụ tiếp đón và thu tiền
GRANT SELECT ON v_RoomDetails TO role_Receptionist;
GRANT SELECT ON v_ArrivalCheckInBookings TO role_Receptionist;
GRANT SELECT ON v_ReceivableBookings TO role_Receptionist;
GRANT SELECT ON v_HousekeeperTasks TO role_Receptionist;
GRANT SELECT ON v_MaintenancePendingRooms TO role_Receptionist;
GRANT SELECT ON v_DamageReports TO role_Receptionist;
GRANT SELECT ON v_CustomerBookingHistory TO role_Receptionist;

-- Quyền thực thi các thủ tục Check-in/Check-out/Thu tiền/Dịch vụ/Hủy phòng
GRANT EXECUTE ON dbo.sp_CheckInNhanPhong TO role_Receptionist;
GRANT EXECUTE ON dbo.sp_CheckOutTraPhong TO role_Receptionist;
GRANT EXECUTE ON dbo.sp_GoiThemDichVu TO role_Receptionist;
GRANT EXECUTE ON dbo.sp_GhiNhanThanhToan TO role_Receptionist;
GRANT EXECUTE ON dbo.sp_XacNhanThanhToanCoc TO role_Receptionist;
GRANT EXECUTE ON dbo.sp_HuyPhong TO role_Receptionist;
GRANT EXECUTE ON dbo.fn_KiemTraPhongTrongTrongKhoang TO role_Receptionist;
GRANT EXECUTE ON dbo.fn_SinhMaBooking TO role_Receptionist;
GRANT EXECUTE ON dbo.fn_SinhMaCustomer TO role_Receptionist;
GRANT EXECUTE ON dbo.fn_SinhMaPayment TO role_Receptionist;

-- CHÍNH SÁCH DENY: Chặn xem báo cáo tài chính tổng hợp & chặn sửa giá, nhân sự
DENY SELECT ON v_InvoiceRevenueReport TO role_Receptionist;
DENY SELECT ON v_PaymentReceiptReport TO role_Receptionist;
DENY INSERT, UPDATE, DELETE ON RoomType TO role_Receptionist;
DENY INSERT, UPDATE, DELETE ON Service TO role_Receptionist;
DENY SELECT, INSERT, UPDATE, DELETE ON Employee TO role_Receptionist;
DENY SELECT, INSERT, UPDATE, DELETE ON Account TO role_Receptionist;
GO

-- ----------------------------------------------------------------------------
-- 5.3. ROLE: role_Housekeeper (Nhân viên Buồng phòng)
-- ----------------------------------------------------------------------------
-- Quyền xem và cập nhật nhiệm vụ dọn phòng, thiết bị hư hại
GRANT SELECT, UPDATE ON Room TO role_Housekeeper;
GRANT SELECT, INSERT, UPDATE ON RoomCleaningTask TO role_Housekeeper;
GRANT SELECT ON DamageType TO role_Housekeeper;
GRANT SELECT ON RoomService TO role_Housekeeper;
GRANT SELECT, INSERT, UPDATE ON DamageReport TO role_Housekeeper;
GRANT SELECT, INSERT, UPDATE ON DamageReport_DamageType TO role_Housekeeper;
GRANT SELECT ON v_HousekeeperTasks TO role_Housekeeper;
GRANT SELECT ON v_DamageReports TO role_Housekeeper;

-- Quyền thực thi thủ tục cập nhật tiến độ dọn dẹp
GRANT EXECUTE ON dbo.sp_CapNhatTienDoDonPhong TO role_Housekeeper;

-- CHÍNH SÁCH DENY: Cấm tuyệt đối xem thông tin tài chính, hóa đơn, khách hàng, nhân sự
DENY SELECT, INSERT, UPDATE, DELETE ON Invoice TO role_Housekeeper;
DENY SELECT, INSERT, UPDATE, DELETE ON Payment TO role_Housekeeper;
DENY SELECT, INSERT, UPDATE, DELETE ON Customer TO role_Housekeeper;
DENY SELECT, INSERT, UPDATE, DELETE ON Account TO role_Housekeeper;
DENY SELECT, INSERT, UPDATE, DELETE ON Employee TO role_Housekeeper;
DENY SELECT, INSERT, UPDATE, DELETE ON Booking TO role_Housekeeper;
DENY SELECT, INSERT, UPDATE, DELETE ON Booking_Room TO role_Housekeeper;
DENY SELECT ON v_ReceivableBookings TO role_Housekeeper;
DENY SELECT ON v_ArrivalCheckInBookings TO role_Housekeeper;
DENY SELECT ON v_InvoiceRevenueReport TO role_Housekeeper;
DENY SELECT ON v_PaymentReceiptReport TO role_Housekeeper;
GO

-- ----------------------------------------------------------------------------
-- 5.4. ROLE: role_Customer (Khách hàng Website / Ứng dụng đặt phòng)
-- ----------------------------------------------------------------------------
-- Quyền xem danh mục phòng, tiện nghi công khai và lịch sử cá nhân
GRANT SELECT ON Room TO role_Customer;
GRANT SELECT ON BedType TO role_Customer;
GRANT SELECT ON RoomType_BedType TO role_Customer;
GRANT SELECT ON RoomService TO role_Customer;
GRANT SELECT ON RoomType_RoomService TO role_Customer;
GRANT SELECT ON v_RoomDetails TO role_Customer;
GRANT SELECT ON RoomType TO role_Customer;
GRANT SELECT ON Service TO role_Customer;
GRANT SELECT ON v_CustomerBookingHistory TO role_Customer;

-- Quyền tự tạo đơn đặt phòng, thanh toán tiền cọc và yêu cầu hủy phòng
GRANT SELECT, INSERT, UPDATE ON Customer TO role_Customer;
GRANT SELECT, INSERT ON Booking TO role_Customer;
GRANT SELECT, INSERT ON Booking_Room TO role_Customer;
GRANT SELECT, INSERT ON Booking_Room_Service TO role_Customer;
GRANT SELECT, INSERT, UPDATE ON Invoice TO role_Customer;
GRANT SELECT, INSERT ON Payment TO role_Customer;
GRANT EXECUTE ON dbo.sp_XacNhanThanhToanCoc TO role_Customer;
GRANT EXECUTE ON dbo.sp_HuyPhong TO role_Customer;
GRANT EXECUTE ON dbo.fn_KiemTraPhongTrongTrongKhoang TO role_Customer;
GRANT EXECUTE ON dbo.fn_SinhMaBooking TO role_Customer;
GRANT EXECUTE ON dbo.fn_SinhMaCustomer TO role_Customer;
GRANT EXECUTE ON dbo.fn_SinhMaPayment TO role_Customer;

-- CHÍNH SÁCH DENY: Chặn hoàn toàn các bảng nghiệp vụ nội bộ của nhân viên
DENY SELECT, INSERT, UPDATE, DELETE ON Employee TO role_Customer;
DENY SELECT, INSERT, UPDATE, DELETE ON Account TO role_Customer;
DENY SELECT, INSERT, UPDATE, DELETE ON RoomCleaningTask TO role_Customer;
DENY SELECT, INSERT, UPDATE, DELETE ON DamageReport TO role_Customer;
DENY SELECT, INSERT, UPDATE, DELETE ON DamageReport_DamageType TO role_Customer;
DENY SELECT ON v_HousekeeperTasks TO role_Customer;
DENY SELECT ON v_DamageReports TO role_Customer;
DENY SELECT ON v_ArrivalCheckInBookings TO role_Customer;
DENY SELECT ON v_ReceivableBookings TO role_Customer;
DENY SELECT ON v_InvoiceRevenueReport TO role_Customer;
DENY SELECT ON v_PaymentReceiptReport TO role_Customer;
GO

-- ============================================================================
-- BƯỚC 6: MINH HỌA LỆNH REVOKE (THU HỒI QUYỀN ĐÃ CẤP TẠM THỜI)
-- ============================================================================
-- Tình huống: Người quản trị cấp quyền tạm thời cho Lễ tân xem danh sách nhân viên:
GRANT SELECT ON Employee TO role_Receptionist;
GO

-- Sau khi hết ca làm việc, Người quản trị thu hồi lại quyền hạn này bằng REVOKE:
REVOKE SELECT ON Employee FROM role_Receptionist;
GO
