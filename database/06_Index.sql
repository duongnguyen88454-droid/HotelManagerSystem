USE QuanLyKhachSan;

GO
SET ANSI_NULLS ON;

GO
SET QUOTED_IDENTIFIER ON;

GO
DROP INDEX IF EXISTS IX_BookingRoom_ArrivalRevenue
    ON Booking_Room;

DROP INDEX IF EXISTS IX_Payment_PaymentDate
    ON Payment;

DROP INDEX IF EXISTS IX_Booking_CreateDate
    ON Booking;

DROP INDEX IF EXISTS IX_Invoice_CreateDate
    ON Invoice;

GO
DROP INDEX IF EXISTS IX_BookingRoom_ConflictCheck
    ON Booking_Room;

GO
CREATE NONCLUSTERED INDEX IX_BookingRoom_ConflictCheck
    ON Booking_Room(RoomId, BookingStatus, ExpectedCheckInDate, ExpectedCheckOutDate);

GO
DROP INDEX IF EXISTS IX_Payment_InvoiceId
    ON Payment;

GO
CREATE NONCLUSTERED INDEX IX_Payment_InvoiceId
    ON Payment(InvoiceId)
    INCLUDE(TotalAmount, PaymentDate);

GO
DROP INDEX IF EXISTS IX_Booking_CustomerId_CreateDate
    ON Booking;

GO
CREATE NONCLUSTERED INDEX IX_Booking_CustomerId_CreateDate
    ON Booking(CustomerId, CreateDate DESC);

GO
DROP INDEX IF EXISTS IX_Invoice_Unpaid
    ON Invoice;

GO
CREATE NONCLUSTERED INDEX IX_Invoice_Unpaid
    ON Invoice(InvoiceStatus, BookingId) WHERE InvoiceStatus <> 'Paid';

GO
DROP INDEX IF EXISTS IX_RoomCleaningTask_Active
    ON RoomCleaningTask;

GO
CREATE NONCLUSTERED INDEX IX_RoomCleaningTask_Active
    ON RoomCleaningTask(RoomCleaningTaskStatus, ReceivedBy)
    INCLUDE(RoomId, StartTime, EndTime) WHERE RoomCleaningTaskStatus IN ('Pending', 'InProgress');