-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
-- SCRIPT 06: HỆ THỐNG 5 CHỈ MỤC THEN CHỐT (TOP 5 ESSENTIAL INDEXES)
-- ÁP DỤNG ĐÚNG 1 INDEX DUY NHẤT CHO MỖI BẢNG TRỌNG ĐIỂM
-- HỆ QUẢN TRỊ CSDL: MICROSOFT SQL SERVER 2019 / 2022
-- ============================================================================
USE QuanLyKhachSan;


GO
SET ANSI_NULLS ON;


GO
SET QUOTED_IDENTIFIER ON;


GO
-- 1. DỌN DẸP CÁC INDEX PHỤ THỪA
DROP INDEX IF EXISTS IX_BookingRoom_ArrivalRevenue
    ON Booking_Room;

DROP INDEX IF EXISTS IX_Payment_PaymentDate
    ON Payment;

DROP INDEX IF EXISTS IX_Booking_CreateDate
    ON Booking;

DROP INDEX IF EXISTS IX_Invoice_CreateDate
    ON Invoice;


GO
-- ============================================================================
-- INDEX 1 (BẢNG BOOKING_ROOM): KIỂM TRA PHÒNG TRỐNG & CHẶN XUNG ĐỘT LỊCH ĐẶT
-- ============================================================================
DROP INDEX IF EXISTS IX_BookingRoom_ConflictCheck
    ON Booking_Room;


GO
CREATE NONCLUSTERED INDEX IX_BookingRoom_ConflictCheck
    ON Booking_Room(RoomId, BookingStatus, ExpectedCheckInDate, ExpectedCheckOutDate);


GO
-- ============================================================================
-- INDEX 2 (BẢNG PAYMENT): TÍNH TỔNG TIỀN THANH TOÁN CỦA HÓA ĐƠN
-- ============================================================================
DROP INDEX IF EXISTS IX_Payment_InvoiceId
    ON Payment;


GO
CREATE NONCLUSTERED INDEX IX_Payment_InvoiceId
    ON Payment(InvoiceId)
    INCLUDE(TotalAmount, PaymentDate);


GO
-- ============================================================================
-- INDEX 3 (BẢNG BOOKING): XEM LỊCH SỬ ĐẶT PHÒNG CỦA KHÁCH HÀNG
-- ============================================================================
DROP INDEX IF EXISTS IX_Booking_CustomerId_CreateDate
    ON Booking;


GO
CREATE NONCLUSTERED INDEX IX_Booking_CustomerId_CreateDate
    ON Booking(CustomerId, CreateDate DESC);


GO
-- ============================================================================
-- INDEX 4 (BẢNG INVOICE): LỌC DANH SÁCH CÔNG NỢ & ĐƠN CHƯA QUYẾT TOÁN
-- ============================================================================
DROP INDEX IF EXISTS IX_Invoice_Unpaid
    ON Invoice;


GO
CREATE NONCLUSTERED INDEX IX_Invoice_Unpaid
    ON Invoice(InvoiceStatus, BookingId) WHERE InvoiceStatus <> 'Paid';


GO
-- ============================================================================
-- INDEX 5 (BẢNG ROOMCLEANINGTASK): DANH SÁCH NHIỆM VỤ DỌN PHÒNG ĐANG HOẠT ĐỘNG
-- ============================================================================
DROP INDEX IF EXISTS IX_RoomCleaningTask_Active
    ON RoomCleaningTask;


GO
CREATE NONCLUSTERED INDEX IX_RoomCleaningTask_Active
    ON RoomCleaningTask(RoomCleaningTaskStatus, ReceivedBy)
    INCLUDE(RoomId, StartTime, EndTime) WHERE RoomCleaningTaskStatus IN ('Pending', 'InProgress');