-- ============================================================================
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)
-- SCRIPT 01: TẠO CƠ SỞ DỮ LIỆU & BẢNG (CHUẨN HÓA 3NF)
-- HỆ QUẢN TRỊ CSDL: MICROSOFT SQL SERVER 2019 / 2022
-- ============================================================================
USE master;


GO
IF EXISTS (SELECT 1
           FROM   sys.databases
           WHERE  name = 'QuanLyKhachSan')
    BEGIN
        ALTER DATABASE QuanLyKhachSan
            SET SINGLE_USER 
            WITH ROLLBACK IMMEDIATE;
        DROP DATABASE QuanLyKhachSan;
    END


GO
CREATE DATABASE QuanLyKhachSan COLLATE Vietnamese_CI_AS;


GO
USE QuanLyKhachSan;


GO
-- ============================================================================
-- PHẦN 1: NHÓM TÀI KHOẢN, NHÂN VIÊN & KHÁCH HÀNG
-- ============================================================================
-- BẢNG 1: ACCOUNT (Tài khoản đăng nhập hệ thống)
CREATE TABLE Account (
    AccountId     VARCHAR (10)  NOT NULL,
    Email         VARCHAR (100) NOT NULL,
    Role          VARCHAR (20)  NOT NULL,
    UserName      NVARCHAR (50) NOT NULL,
    Password      VARCHAR (255) NOT NULL,
    AccountStatus VARCHAR (20)  CONSTRAINT DF_Account_Status DEFAULT 'Active' NOT NULL,
    CONSTRAINT PK_Account PRIMARY KEY (AccountId),
    CONSTRAINT UQ_Account_UserName UNIQUE (UserName),
    CONSTRAINT UQ_Account_Email UNIQUE (Email),
    CONSTRAINT CK_Account_Role CHECK (Role IN ('Customer', 'Receptionist', 'Housekeeper', 'Manager')),
    CONSTRAINT CK_Account_Status CHECK (AccountStatus IN ('Active', 'Locked'))
);


GO
-- BẢNG 2: EMPLOYEE (Hồ sơ thông tin nhân viên)
CREATE TABLE Employee (
    EmployeeId      VARCHAR (10)   NOT NULL,
    AccountId       VARCHAR (10)   NULL,
    FullName        NVARCHAR (100) NOT NULL,
    Phone           VARCHAR (15)   NOT NULL,
    Email           VARCHAR (100)  NOT NULL,
    HireDate        DATE           CONSTRAINT DF_Employee_HireDate DEFAULT CAST (GETDATE() AS DATE) NOT NULL,
    ResignationDate DATE           NULL,
    EmployeeStatus  VARCHAR (20)   CONSTRAINT DF_Employee_Status DEFAULT 'Working' NOT NULL,
    CONSTRAINT PK_Employee PRIMARY KEY (EmployeeId),
    CONSTRAINT FK_Employee_Account FOREIGN KEY (AccountId) REFERENCES Account (AccountId),
    CONSTRAINT UQ_Employee_Phone UNIQUE (Phone),
    CONSTRAINT CK_Employee_Status CHECK (EmployeeStatus IN ('Working', 'Resigned')),
    CONSTRAINT CK_Employee_Dates CHECK (ResignationDate IS NULL
                                        OR ResignationDate >= HireDate)
);


GO
-- BẢNG 3: CUSTOMER (Hồ sơ khách hàng)
CREATE TABLE Customer (
    CustomerId  VARCHAR (10)   NOT NULL,
    FullName    NVARCHAR (100) NOT NULL,
    PhoneNumber VARCHAR (15)   NOT NULL,
    CCCD        VARCHAR (20)   NOT NULL,
    Email       VARCHAR (100)  NOT NULL,
    CONSTRAINT PK_Customer PRIMARY KEY (CustomerId),
    CONSTRAINT UQ_Customer_CCCD UNIQUE (CCCD),
    CONSTRAINT UQ_Customer_PhoneNumber UNIQUE (PhoneNumber),
    CONSTRAINT CK_Customer_CCCD CHECK (LEN(CCCD) = 12
                                       AND CCCD NOT LIKE '%[^0-9]%')
);


GO
-- ============================================================================
-- PHẦN 2: NHÓM DANH MỤC PHÒNG & TIỆN NGHI
-- ============================================================================
-- BẢNG 4: ROOMTYPE (Hạng phòng)
CREATE TABLE RoomType (
    RoomTypeId      VARCHAR (10)    NOT NULL,
    RoomTypeName    NVARCHAR (50)   NOT NULL,
    BasePrice       DECIMAL (12, 2) NOT NULL,
    Capacity        INT             NOT NULL,
    EarlyCheckInFee DECIMAL (12, 2) CONSTRAINT DF_RoomType_EarlyCheckInFee DEFAULT 0 NOT NULL,
    LateCheckOutFee DECIMAL (12, 2) CONSTRAINT DF_RoomType_LateCheckOutFee DEFAULT 0 NOT NULL,
    DepositPercent  DECIMAL (5, 2)  CONSTRAINT DF_RoomType_DepositPercent DEFAULT 0 NOT NULL,
    IsActive        BIT             CONSTRAINT DF_RoomType_IsActive DEFAULT 1 NOT NULL,
    CONSTRAINT PK_RoomType PRIMARY KEY (RoomTypeId),
    CONSTRAINT UQ_RoomType_Name UNIQUE (RoomTypeName),
    CONSTRAINT CK_RoomType_BasePrice CHECK (BasePrice >= 0),
    CONSTRAINT CK_RoomType_Capacity CHECK (Capacity > 0),
    CONSTRAINT CK_RoomType_EarlyCheckInFee CHECK (EarlyCheckInFee >= 0),
    CONSTRAINT CK_RoomType_LateCheckOutFee CHECK (LateCheckOutFee >= 0),
    CONSTRAINT CK_RoomType_DepositPercent CHECK (DepositPercent >= 0
                                                 AND DepositPercent <= 100)
);


GO
-- BẢNG 5: BEDTYPE (Loại giường)
CREATE TABLE BedType (
    BedTypeId   VARCHAR (10)  NOT NULL,
    BedTypeName NVARCHAR (50) NOT NULL,
    IsActive    BIT           CONSTRAINT DF_BedType_IsActive DEFAULT 1 NOT NULL,
    CONSTRAINT PK_BedType PRIMARY KEY (BedTypeId),
    CONSTRAINT UQ_BedType_Name UNIQUE (BedTypeName)
);


GO
-- BẢNG 6: ROOMTYPE_BEDTYPE (Liên kết Hạng phòng - Loại giường)
CREATE TABLE RoomType_BedType (
    RoomTypeId VARCHAR (10) NOT NULL,
    BedTypeId  VARCHAR (10) NOT NULL,
    Quantity   INT          NOT NULL CONSTRAINT DF_RTBT_Quantity DEFAULT 1,
    CONSTRAINT PK_RoomType_BedType PRIMARY KEY (RoomTypeId, BedTypeId),
    CONSTRAINT FK_RTBT_RoomType FOREIGN KEY (RoomTypeId) REFERENCES RoomType (RoomTypeId) ON DELETE CASCADE,
    CONSTRAINT FK_RTBT_BedType FOREIGN KEY (BedTypeId) REFERENCES BedType (BedTypeId)
);


GO
-- BẢNG 7: ROOMSERVICE (Tiện nghi trong phòng)
CREATE TABLE RoomService (
    RoomServiceId   VARCHAR (10)   NOT NULL,
    RoomServiceName NVARCHAR (100) NOT NULL,
    IsActive        BIT            CONSTRAINT DF_RoomService_IsActive DEFAULT 1 NOT NULL,
    CONSTRAINT PK_RoomService PRIMARY KEY (RoomServiceId),
    CONSTRAINT UQ_RoomService_Name UNIQUE (RoomServiceName)
);


GO
-- BẢNG 8: ROOMTYPE_ROOMSERVICE (Liên kết Hạng phòng - Tiện nghi phòng)
CREATE TABLE RoomType_RoomService (
    RoomTypeId    VARCHAR (10) NOT NULL,
    RoomServiceId VARCHAR (10) NOT NULL,
    CONSTRAINT PK_RoomType_RoomService PRIMARY KEY (RoomTypeId, RoomServiceId),
    CONSTRAINT FK_RTRS_RoomType FOREIGN KEY (RoomTypeId) REFERENCES RoomType (RoomTypeId) ON DELETE CASCADE,
    CONSTRAINT FK_RTRS_RoomService FOREIGN KEY (RoomServiceId) REFERENCES RoomService (RoomServiceId)
);


GO
-- BẢNG 9: ROOM (Phòng vật lý)
CREATE TABLE Room (
    RoomId             VARCHAR (10)  NOT NULL,
    RoomTypeId         VARCHAR (10)  NOT NULL,
    RoomName           NVARCHAR (50) NOT NULL,
    RoomStatus         VARCHAR (20)  CONSTRAINT DF_Room_Status DEFAULT 'Available' NOT NULL,
    HousekeepingStatus VARCHAR (20)  CONSTRAINT DF_Room_Housekeeping DEFAULT 'Clean' NOT NULL,
    OccupancyStatus    VARCHAR (20)  CONSTRAINT DF_Room_Occupancy DEFAULT 'Vacant' NOT NULL,
    CONSTRAINT PK_Room PRIMARY KEY (RoomId),
    CONSTRAINT UQ_Room_Name UNIQUE (RoomName),
    CONSTRAINT FK_Room_RoomType FOREIGN KEY (RoomTypeId) REFERENCES RoomType (RoomTypeId),
    CONSTRAINT CK_Room_Status CHECK (RoomStatus IN ('Available', 'Maintenance', 'OutOfService')),
    CONSTRAINT CK_Room_Housekeeping CHECK (HousekeepingStatus IN ('Dirty', 'Cleaning', 'Clean')),
    CONSTRAINT CK_Room_Occupancy CHECK (OccupancyStatus IN ('Vacant', 'Occupied'))
);


GO
-- BẢNG 10: SERVICE (Dịch vụ bổ sung: ăn uống, giặt là, spa...)
CREATE TABLE Service (
    ServiceId   VARCHAR (10)    NOT NULL,
    ServiceName NVARCHAR (100)  NOT NULL,
    BasePrice   DECIMAL (12, 2) NOT NULL,
    IsActive    BIT             CONSTRAINT DF_Service_IsActive DEFAULT 1 NOT NULL,
    CONSTRAINT PK_Service PRIMARY KEY (ServiceId),
    CONSTRAINT UQ_Service_Name UNIQUE (ServiceName),
    CONSTRAINT CK_Service_BasePrice CHECK (BasePrice >= 0)
);


GO
-- ============================================================================
-- PHẦN 3: NHÓM ĐẶT PHÒNG, DỊCH VỤ PHÒNG & HỦY PHÒNG
-- ============================================================================
-- BẢNG 11: BOOKING (Đơn đặt phòng)
CREATE TABLE Booking (
    BookingId  VARCHAR (10) NOT NULL,
    CustomerId VARCHAR (10) NOT NULL,
    CreateBy   VARCHAR (10) NOT NULL,
    CreateDate DATETIME     CONSTRAINT DF_Booking_CreateDate DEFAULT GETDATE() NOT NULL,
    CONSTRAINT PK_Booking PRIMARY KEY (BookingId),
    CONSTRAINT FK_Booking_Customer FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId),
    CONSTRAINT FK_Booking_Account FOREIGN KEY (CreateBy) REFERENCES Account (AccountId)
);


GO
-- BẢNG 12: BOOKING_ROOM (Chi tiết từng phòng trong đơn)
CREATE TABLE Booking_Room (
    BookingId            VARCHAR (10)    NOT NULL,
    RoomId               VARCHAR (10)    NOT NULL,
    BookingStatus        VARCHAR (20)    CONSTRAINT DF_BookingRoom_Status DEFAULT 'Confirmed' NOT NULL,
    ExpectedCheckInDate  DATE            NOT NULL,
    ExpectedCheckOutDate DATE            NOT NULL,
    ActualCheckInDate    DATETIME        NULL,
    ActualCheckOutDate   DATETIME        NULL,
    Deposit              DECIMAL (12, 2) NULL, -- Cho phép NULL nếu khách vãng lai nhận ngay
    Price                DECIMAL (12, 2) NOT NULL, -- Đơn giá 1 đêm lúc chốt đặt
    CONSTRAINT PK_Booking_Room PRIMARY KEY (BookingId, RoomId),
    CONSTRAINT FK_BR_Booking FOREIGN KEY (BookingId) REFERENCES Booking (BookingId),
    CONSTRAINT FK_BR_Room FOREIGN KEY (RoomId) REFERENCES Room (RoomId),
    CONSTRAINT CK_BR_BookingStatus CHECK (BookingStatus IN ('Confirmed', 'CheckedIn', 'CheckedOut', 'Cancelled')),
    CONSTRAINT CK_BR_ExpectedDates CHECK (ExpectedCheckOutDate > ExpectedCheckInDate),
    CONSTRAINT CK_BR_Deposit CHECK (Deposit IS NULL
                                    OR Deposit >= 0),
    CONSTRAINT CK_BR_Price CHECK (Price >= 0),
    CONSTRAINT CK_BR_ActualDates CHECK ((ActualCheckInDate IS NULL)
                                        OR (ActualCheckOutDate IS NULL)
                                        OR (ActualCheckOutDate >= ActualCheckInDate))
);


GO
-- BẢNG 13: BOOKING_ROOM_SERVICE (Dịch vụ gọi thêm theo phòng)
CREATE TABLE Booking_Room_Service (
    BookingId VARCHAR (10)    NOT NULL,
    RoomId    VARCHAR (10)    NOT NULL,
    ServiceId VARCHAR (10)    NOT NULL,
    UnitPrice DECIMAL (12, 2) NOT NULL, -- Snapshot giá tại thời điểm gọi
    Quantity  INT             CONSTRAINT DF_BRS_Quantity DEFAULT 1 NOT NULL,
    CONSTRAINT PK_Booking_Room_Service PRIMARY KEY (BookingId, RoomId, ServiceId),
    CONSTRAINT FK_BRS_Booking_Room FOREIGN KEY (BookingId, RoomId) REFERENCES Booking_Room (BookingId, RoomId),
    CONSTRAINT FK_BRS_Service FOREIGN KEY (ServiceId) REFERENCES Service (ServiceId),
    CONSTRAINT CK_BRS_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_BRS_Quantity CHECK (Quantity > 0)
);


GO
-- BẢNG 14: CANCELLATIONHISTORY (Lịch sử hủy phòng)
CREATE TABLE CancellationHistory (
    CancellationId        VARCHAR (10)    NOT NULL,
    BookingId             VARCHAR (10)    NOT NULL,
    RoomId                VARCHAR (10)    NOT NULL,
    CancelledBy           VARCHAR (10)    NOT NULL,
    DepositAtCancellation DECIMAL (12, 2) NOT NULL,
    CancellationDate      DATETIME        CONSTRAINT DF_Cancel_Date DEFAULT GETDATE() NOT NULL,
    CancellationFee       DECIMAL (12, 2) CONSTRAINT DF_Cancel_Fee DEFAULT 0 NOT NULL,
    RefundStatus          VARCHAR (20)    CONSTRAINT DF_Cancel_RefundStatus DEFAULT 'Pending' NOT NULL,
    Reason                NVARCHAR (300)  NULL,
    CONSTRAINT PK_CancellationHistory PRIMARY KEY (CancellationId),
    CONSTRAINT FK_Cancel_Booking_Room FOREIGN KEY (BookingId, RoomId) REFERENCES Booking_Room (BookingId, RoomId),
    CONSTRAINT FK_Cancel_Account FOREIGN KEY (CancelledBy) REFERENCES Account (AccountId),
    CONSTRAINT CK_Cancel_Deposit CHECK (DepositAtCancellation >= 0),
    CONSTRAINT CK_Cancel_Fee CHECK (CancellationFee >= 0),
    CONSTRAINT CK_Cancel_RefundStatus CHECK (RefundStatus IN ('Pending', 'Completed', 'Rejected'))
);


GO
-- ============================================================================
-- PHẦN 4: NHÓM HÓA ĐƠN & THANH TOÁN
-- ============================================================================
-- BẢNG 15: INVOICE (Hóa đơn thanh toán)
CREATE TABLE Invoice (
    InvoiceId          VARCHAR (10)    NOT NULL,
    BookingId          VARCHAR (10)    NOT NULL,
    CreateDate         DATETIME        CONSTRAINT DF_Invoice_CreateDate DEFAULT GETDATE() NOT NULL,
    TotalRoomCharge    DECIMAL (12, 2) CONSTRAINT DF_Invoice_RoomCharge DEFAULT 0 NOT NULL,
    TotalServiceCharge DECIMAL (12, 2) CONSTRAINT DF_Invoice_ServiceCharge DEFAULT 0 NOT NULL,
    EarlyCheckInFee    DECIMAL (12, 2) CONSTRAINT DF_Invoice_EarlyFee DEFAULT 0 NOT NULL,
    LateCheckOutFee    DECIMAL (12, 2) CONSTRAINT DF_Invoice_LateFee DEFAULT 0 NOT NULL,
    InvoiceStatus      VARCHAR (20)    CONSTRAINT DF_Invoice_Status DEFAULT 'Unpaid' NOT NULL,
    FinalTotalAmount   DECIMAL (12, 2) CONSTRAINT DF_Invoice_FinalTotal DEFAULT 0 NOT NULL,
    CONSTRAINT PK_Invoice PRIMARY KEY (InvoiceId),
    CONSTRAINT UQ_Invoice_Booking UNIQUE (BookingId),
    CONSTRAINT FK_Invoice_Booking FOREIGN KEY (BookingId) REFERENCES Booking (BookingId),
    CONSTRAINT CK_Invoice_RoomCharge CHECK (TotalRoomCharge >= 0),
    CONSTRAINT CK_Invoice_ServiceCharge CHECK (TotalServiceCharge >= 0),
    CONSTRAINT CK_Invoice_EarlyFee CHECK (EarlyCheckInFee >= 0),
    CONSTRAINT CK_Invoice_LateFee CHECK (LateCheckOutFee >= 0),
    CONSTRAINT CK_Invoice_FinalTotal CHECK (FinalTotalAmount >= 0),
    CONSTRAINT CK_Invoice_Status CHECK (InvoiceStatus IN ('Unpaid', 'Paid', 'PartiallyPaid'))
);


GO
-- BẢNG 16: PAYMENT (Lịch sử các lần thanh toán)
CREATE TABLE Payment (
    PaymentId     VARCHAR (10)    NOT NULL,
    ProcessBy     VARCHAR (10)    NULL, -- NULL nếu khách tự thanh toán online
    InvoiceId     VARCHAR (10)    NOT NULL,
    PaymentDate   DATETIME        CONSTRAINT DF_Payment_Date DEFAULT GETDATE() NOT NULL,
    PaymentMethod VARCHAR (20)    CONSTRAINT DF_Payment_Method DEFAULT 'Cash' NOT NULL,
    TotalAmount   DECIMAL (12, 2) NOT NULL,
    Note          NVARCHAR (300)  NULL,
    CONSTRAINT PK_Payment PRIMARY KEY (PaymentId),
    CONSTRAINT FK_Payment_Account FOREIGN KEY (ProcessBy) REFERENCES Account (AccountId),
    CONSTRAINT FK_Payment_Invoice FOREIGN KEY (InvoiceId) REFERENCES Invoice (InvoiceId),
    CONSTRAINT CK_Payment_Amount CHECK (TotalAmount > 0),
    CONSTRAINT CK_Payment_Method CHECK (PaymentMethod IN ('Cash', 'CreditCard', 'BankTransfer', 'Momo', 'VNPay'))
);


GO
-- ============================================================================
-- PHẦN 5: NHÓM BUỒNG PHÒNG & BÁO CÁO HƯ HỎNG
-- ============================================================================
-- BẢNG 17: ROOMCLEANINGTASK (Nhiệm vụ dọn phòng)
CREATE TABLE RoomCleaningTask (
    RoomCleaningTaskId     VARCHAR (10)   NOT NULL,
    RoomId                 VARCHAR (10)   NOT NULL,
    ReceivedBy             VARCHAR (10)   NULL, -- NULL khi mới tạo tự động (Pending) sau Check-out
    StartTime              DATETIME       NULL,
    EndTime                DATETIME       NULL,
    RoomCleaningTaskStatus VARCHAR (20)   CONSTRAINT DF_RCT_Status DEFAULT 'Pending' NOT NULL,
    Result                 NVARCHAR (255) NULL,
    CONSTRAINT PK_RoomCleaningTask PRIMARY KEY (RoomCleaningTaskId),
    CONSTRAINT FK_RCT_Room FOREIGN KEY (RoomId) REFERENCES Room (RoomId),
    CONSTRAINT FK_RCT_Account FOREIGN KEY (ReceivedBy) REFERENCES Account (AccountId),
    CONSTRAINT CK_RCT_Status CHECK (RoomCleaningTaskStatus IN ('Pending', 'InProgress', 'Completed')),
    CONSTRAINT CK_RCT_Times CHECK (StartTime IS NULL
                                   OR EndTime IS NULL
                                   OR EndTime >= StartTime)
);


GO
-- BẢNG 18: DAMAGETYPE (Danh mục loại hư hỏng thiết bị)
CREATE TABLE DamageType (
    DamageTypeId VARCHAR (10)   NOT NULL,
    DamageName   NVARCHAR (100) NOT NULL,
    CONSTRAINT PK_DamageType PRIMARY KEY (DamageTypeId),
    CONSTRAINT UQ_DamageType_Name UNIQUE (DamageName)
);


GO
-- BẢNG 19: DAMAGEREPORT (Biên bản báo cáo hư hỏng phòng)
CREATE TABLE DamageReport (
    DamageReportId     VARCHAR (10) NOT NULL,
    RoomId             VARCHAR (10) NOT NULL,
    CreateBy           VARCHAR (10) NOT NULL,
    DetectedAt         DATETIME     CONSTRAINT DF_DR_DetectedAt DEFAULT GETDATE() NOT NULL,
    ConfirmedAt        DATETIME     NULL,
    DamageReportStatus VARCHAR (20) CONSTRAINT DF_DR_Status DEFAULT 'Pending' NOT NULL,
    CONSTRAINT PK_DamageReport PRIMARY KEY (DamageReportId),
    CONSTRAINT FK_DR_Room FOREIGN KEY (RoomId) REFERENCES Room (RoomId),
    CONSTRAINT FK_DR_Account FOREIGN KEY (CreateBy) REFERENCES Account (AccountId),
    CONSTRAINT CK_DR_Status CHECK (DamageReportStatus IN ('Pending', 'Confirmed', 'Resolved')),
    CONSTRAINT CK_DR_Dates CHECK (ConfirmedAt IS NULL
                                  OR ConfirmedAt >= DetectedAt)
);


GO
-- BẢNG 20: DAMAGEREPORT_DAMAGETYPE (Chi tiết các hư hỏng trong biên bản)
CREATE TABLE DamageReport_DamageType (
    DamageReportId VARCHAR (10)   NOT NULL,
    DamageTypeId   VARCHAR (10)   NOT NULL,
    Note           NVARCHAR (300) NULL,
    CONSTRAINT PK_DamageReport_DamageType PRIMARY KEY (DamageReportId, DamageTypeId),
    CONSTRAINT FK_DRDT_DamageReport FOREIGN KEY (DamageReportId) REFERENCES DamageReport (DamageReportId) ON DELETE CASCADE,
    CONSTRAINT FK_DRDT_DamageType FOREIGN KEY (DamageTypeId) REFERENCES DamageType (DamageTypeId)
);

USE QuanLyKhachSan;


GO
SET NOCOUNT ON;

PRINT N'========================================================================';

PRINT N'BƯỚC 1: VÔ HIỆU HÓA RÀNG BUỘC & TRIGGER ĐỂ XỬ LÝ AN TOÀN...';

PRINT N'========================================================================';

-- Tắt kiểm tra khóa ngoại và trigger trên toàn bộ các bảng
EXECUTE sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";

EXECUTE sp_MSforeachtable "ALTER TABLE ? DISABLE TRIGGER ALL";


GO
PRINT N'BƯỚC 2: XÓA SẠCH DỮ LIỆU CŨ TRONG TẤT CẢ CÁC BẢNG...';

DELETE Payment;

DELETE CancellationHistory;

DELETE Invoice;

DELETE Booking_Room_Service;

DELETE Booking_Room;

DELETE Booking;

DELETE Customer;

DELETE RoomCleaningTask;

DELETE DamageReport_DamageType;

DELETE DamageReport;

DELETE DamageType;

DELETE Room;

DELETE RoomType_RoomService;

DELETE RoomService;

DELETE RoomType_BedType;

DELETE BedType;

DELETE RoomType;

DELETE Service;

DELETE Employee;

DELETE Account;


GO
PRINT N'BƯỚC 3: NẠP DỮ LIỆU MẪU (SEED DATA) CHUẨN HÓA 3NF...';

-- 1. BẢNG ACCOUNT (Tài khoản hệ thống - Password mã hóa BCrypt tương ứng với "123456")
INSERT  INTO Account (
    AccountId,
    Email,
    Role,
    UserName,
    Password,
    AccountStatus
)
VALUES               ('ACC001', 'manager@hotel.com', 'Manager', 'manager', '$2a$12$e8yvWvVlP5k5VjCqVfQhNu4Y0w1rFkUeJg8yF4p5hK2bL7qX9w6yC', 'Active'),
                     ('ACC002', 'letan1@hotel.com', 'Receptionist', 'letan1', '$2a$12$e8yvWvVlP5k5VjCqVfQhNu4Y0w1rFkUeJg8yF4p5hK2bL7qX9w6yC', 'Active'),
                     ('ACC003', 'letan2@hotel.com', 'Receptionist', 'letan2', '$2a$12$e8yvWvVlP5k5VjCqVfQhNu4Y0w1rFkUeJg8yF4p5hK2bL7qX9w6yC', 'Active'),
                     ('ACC004', 'buongphong@hotel.com', 'Housekeeper', 'buongphong', '$2a$12$e8yvWvVlP5k5VjCqVfQhNu4Y0w1rFkUeJg8yF4p5hK2bL7qX9w6yC', 'Active'),
                     ('ACC005', 'khachhang@gmail.com', 'Customer', 'khachhang', '$2a$12$e8yvWvVlP5k5VjCqVfQhNu4Y0w1rFkUeJg8yF4p5hK2bL7qX9w6yC', 'Active');


GO
-- 2. BẢNG EMPLOYEE (Hồ sơ nhân viên)
INSERT  INTO Employee (
    EmployeeId,
    AccountId,
    FullName,
    Phone,
    Email,
    HireDate,
    ResignationDate,
    EmployeeStatus
)
VALUES                ('EMP001', 'ACC001', N'Trần Quản Lý', '0901112233', 'manager@hotel.com', '2024-01-01', NULL, 'Working'),
                      ('EMP002', 'ACC002', N'Lê Lễ Tân', '0902223344', 'letan1@hotel.com', '2024-03-15', NULL, 'Working'),
                      ('EMP003', 'ACC004', N'Phạm Buồng Phòng', '0903334455', 'buongphong@hotel.com', '2024-05-01', NULL, 'Working');


GO
-- 3. BẢNG CUSTOMER (Hồ sơ khách hàng chuẩn 5 cột, CCCD đủ 12 chữ số)
INSERT  INTO Customer (
    CustomerId,
    FullName,
    PhoneNumber,
    CCCD,
    Email
)
VALUES                ('CUS001', N'Nguyễn Văn An', '0912345678', '079201001234', 'khachhang@gmail.com'),
                      ('CUS002', N'Hoàng Thanh Bình', '0918765432', '079202005678', 'khachhang2@gmail.com'),
                      ('CUS003', N'Đỗ Thị Cẩm Tú', '0987654321', '079303009876', 'tu.dothi@gmail.com');


GO
-- 4. BẢNG ROOMTYPE (Hạng phòng)
INSERT  INTO RoomType (
    RoomTypeId,
    RoomTypeName,
    BasePrice,
    Capacity,
    EarlyCheckInFee,
    LateCheckOutFee,
    DepositPercent,
    IsActive
)
VALUES                ('RT01', N'Standard Room', 450000.00, 2, 50000.00, 50000.00, 30.00, 1),
                      ('RT02', N'Superior Room', 650000.00, 2, 70000.00, 70000.00, 30.00, 1),
                      ('RT03', N'Deluxe Room', 950000.00, 3, 100000.00, 100000.00, 40.00, 1),
                      ('RT04', N'Suite Luxury', 1500000.00, 4, 150000.00, 150000.00, 50.00, 1);


GO
-- 5. BẢNG BEDTYPE (Loại giường)
INSERT  INTO BedType (
    BedTypeId,
    BedTypeName,
    IsActive
)
VALUES               ('BT01', 'Single Bed', 1),
                     ('BT02', 'Double Bed', 1),
                     ('BT03', 'King Bed', 1);


GO
-- 6. BẢNG ROOMTYPE_BEDTYPE (Liên kết Hạng phòng - Giường)
INSERT  INTO RoomType_BedType (
    RoomTypeId,
    BedTypeId,
    Quantity
)
VALUES                        ('RT01', 'BT01', 1),
                              ('RT01', 'BT02', 1),
                              ('RT02', 'BT02', 1),
                              ('RT03', 'BT03', 1),
                              ('RT04', 'BT03', 2);


GO
-- 7. BẢNG ROOMSERVICE (Tiện nghi phòng)
INSERT  INTO RoomService (
    RoomServiceId,
    RoomServiceName,
    IsActive
)
VALUES                   ('RS01', N'Wifi Tốc Độ Cao', 1),
                         ('RS02', N'Điều Hòa 2 Chiều', 1),
                         ('RS03', N'Tivi Thông Minh 55 Inch', 1),
                         ('RS04', N'Bồn Tắm Nằm', 1),
                         ('RS05', N'Tủ Lạnh Mini & Minibar', 1),
                         ('RS06', N'Ban Công Hướng Biển', 1);


GO
-- 8. BẢNG ROOMTYPE_ROOMSERVICE (Liên kết Hạng phòng - Tiện nghi)
INSERT  INTO RoomType_RoomService (
    RoomTypeId,
    RoomServiceId
)
VALUES                            ('RT01', 'RS01'),
                                  ('RT01', 'RS02'),
                                  ('RT01', 'RS03'),
                                  ('RT02', 'RS01'),
                                  ('RT02', 'RS02'),
                                  ('RT02', 'RS03'),
                                  ('RT02', 'RS05'),
                                  ('RT03', 'RS01'),
                                  ('RT03', 'RS02'),
                                  ('RT03', 'RS03'),
                                  ('RT03', 'RS04'),
                                  ('RT03', 'RS05'),
                                  ('RT04', 'RS01'),
                                  ('RT04', 'RS02'),
                                  ('RT04', 'RS03'),
                                  ('RT04', 'RS04'),
                                  ('RT04', 'RS05'),
                                  ('RT04', 'RS06');


GO
-- 9. BẢNG ROOM (Phòng vật lý)
INSERT  INTO Room (
    RoomId,
    RoomTypeId,
    RoomName,
    RoomStatus,
    HousekeepingStatus,
    OccupancyStatus
)
VALUES            ('P101', 'RT01', N'Phòng 101', 'Available', 'Clean', 'Vacant'),
                  ('P102', 'RT01', N'Phòng 102', 'Available', 'Clean', 'Vacant'),
                  ('P103', 'RT02', N'Phòng 103', 'Available', 'Dirty', 'Vacant'),
                  ('P201', 'RT02', N'Phòng 201', 'Available', 'Clean', 'Occupied'),
                  ('P202', 'RT03', N'Phòng 202', 'Available', 'Cleaning', 'Vacant'),
                  ('P203', 'RT03', N'Phòng 203', 'Available', 'Clean', 'Vacant'),
                  ('P301', 'RT03', N'Phòng 301', 'Maintenance', 'Clean', 'Vacant'),
                  ('P302', 'RT04', N'Phòng 302', 'Available', 'Clean', 'Vacant'),
                  ('P303', 'RT04', N'Phòng 303', 'Available', 'Clean', 'Vacant');


GO
-- 10. BẢNG SERVICE (Dịch vụ gia tăng)
INSERT  INTO Service (
    ServiceId,
    ServiceName,
    BasePrice,
    IsActive
)
VALUES               ('SRV001', N'Buffet Sáng Cao Cấp', 120000.00, 1),
                     ('SRV002', N'Giặt Là Lấy Ngay', 50000.00, 1),
                     ('SRV003', N'Đưa Đón Sân Bay Chu Đáo', 250000.00, 1),
                     ('SRV004', N'Gói Massage & Spa Thư Giãn', 350000.00, 1),
                     ('SRV005', N'Nước Khoáng Đóng Chai', 15000.00, 1),
                     ('SRV006', N'Nước Ngọt Lon Tiện Lợi', 20000.00, 1);


GO
-- 11. BẢNG BOOKING (Đơn đặt phòng)
INSERT  INTO Booking (
    BookingId,
    CustomerId,
    CreateBy,
    CreateDate
)
VALUES               ('BK001', 'CUS001', 'ACC005', '2026-10-01 08:30:00'),
                     ('BK002', 'CUS002', 'ACC002', '2026-10-08 09:15:00'),
                     ('BK003', 'CUS003', 'ACC002', '2026-10-09 10:00:00');


GO
-- 12. BẢNG BOOKING_ROOM (Chi tiết phòng trong đơn)
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
VALUES                    ('BK001', 'P101', 'CheckedOut', '2026-10-01', '2026-10-03', '2026-10-01 14:00:00', '2026-10-03 11:30:00', 270000.00, 450000.00),
                          ('BK002', 'P201', 'CheckedIn', '2026-10-08', '2026-10-10', '2026-10-08 13:30:00', NULL, 390000.00, 650000.00),
                          ('BK003', 'P302', 'Confirmed', '2026-10-15', '2026-10-18', NULL, NULL, 900000.00, 1500000.00);


GO
-- 13. BẢNG BOOKING_ROOM_SERVICE (Dịch vụ gọi theo phòng)
INSERT  INTO Booking_Room_Service (
    BookingId,
    RoomId,
    ServiceId,
    UnitPrice,
    Quantity
)
VALUES                            ('BK001', 'P101', 'SRV001', 120000.00, 2), -- 240,000
                                  ('BK001', 'P101', 'SRV005', 15000.00, 4), -- 60,000
                                  ('BK002', 'P201', 'SRV001', 120000.00, 1), -- 120,000
                                  ('BK002', 'P201', 'SRV003', 250000.00, 1); -- 250,000


GO
-- 14. BẢNG INVOICE (Hóa đơn thanh toán)
INSERT  INTO Invoice (
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
VALUES               ('INV001', 'BK001', '2026-10-01 08:35:00', 900000.00, 300000.00, 0.00, 0.00, 'Paid', 1200000.00),
                     ('INV002', 'BK002', '2026-10-08 09:20:00', 1300000.00, 370000.00, 0.00, 0.00, 'PartiallyPaid', 1670000.00),
                     ('INV003', 'BK003', '2026-10-09 10:05:00', 4500000.00, 0.00, 0.00, 0.00, 'Unpaid', 4500000.00);


GO
-- 15. BẢNG PAYMENT (Lịch sử thanh toán)
INSERT  INTO Payment (
    PaymentId,
    ProcessBy,
    InvoiceId,
    PaymentDate,
    PaymentMethod,
    TotalAmount,
    Note
)
VALUES               ('PAY001', 'ACC002', 'INV001', '2026-10-03 11:35:00', 'Cash', 1200000.00, N'Khách thanh toán toàn bộ tiền mặt khi check-out'),
                     ('PAY002', 'ACC002', 'INV002', '2026-10-08 09:25:00', 'BankTransfer', 390000.00, N'Khách chuyển khoản tiền đặt cọc giữ phòng');


GO
-- 16. BẢNG ROOMCLEANINGTASK (Nhiệm vụ dọn phòng)
INSERT  INTO RoomCleaningTask (
    RoomCleaningTaskId,
    RoomId,
    ReceivedBy,
    StartTime,
    EndTime,
    RoomCleaningTaskStatus,
    Result
)
VALUES                        ('TSK001', 'P103', NULL, NULL, NULL, 'Pending', N'Khách vừa trả phòng, cần thay chăn ga gối đệm'),
                              ('TSK002', 'P202', 'ACC004', '2026-10-09 08:00:00', NULL, 'InProgress', N'Đang hút bụi và lau dọn sàn nhà'),
                              ('TSK003', 'P101', 'ACC004', '2026-10-03 12:00:00', '2026-10-03 12:45:00', 'Completed', N'Đã dọn sạch sẽ, khử khuẩn và bổ sung minibar');


GO
-- 17. BẢNG DAMAGETYPE (Loại hư hại - Duy nhất 1 loại)
INSERT  INTO DamageType (
    DamageTypeId,
    DamageName
)
VALUES                  ('DMT001', N'Hỏng Hóc Thiết Bị / Cần Bảo Trì');


GO
-- 18. BẢNG DAMAGEREPORT (Biên bản báo cáo hư hỏng)
INSERT  INTO DamageReport (
    DamageReportId,
    RoomId,
    CreateBy,
    DetectedAt,
    ConfirmedAt,
    DamageReportStatus
)
VALUES                    ('DMR001', 'P301', 'ACC004', '2026-10-08 15:00:00', '2026-10-08 16:30:00', 'Confirmed');


GO
-- 19. BẢNG DAMAGEREPORT_DAMAGETYPE (Chi tiết hư hỏng)
INSERT  INTO DamageReport_DamageType (
    DamageReportId,
    DamageTypeId,
    Note
)
VALUES                               ('DMR001', 'DMT001', N'Vỡ kính cửa sổ ban công do gió mạnh, đã gọi kỹ thuật bảo trì');


GO
PRINT N'BƯỚC 4: BẬT LẠI TOÀN BỘ RÀNG BUỘC KHÓA NGOẠI & TRIGGER...';

EXECUTE sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";

EXECUTE sp_MSforeachtable "ALTER TABLE ? ENABLE TRIGGER ALL";


GO
PRINT N'========================================================================';

PRINT N'>>> ĐÃ XÓA SẠCH VÀ NẠP MỚI THÀNH CÔNG 100% DỮ LIỆU SEED DATA 3NF!';

PRINT N'========================================================================';