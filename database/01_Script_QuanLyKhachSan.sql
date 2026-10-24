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
-- BẢNG 1: ACCOUNT (Tài khoản đăng nhập hệ thống)
CREATE TABLE Account (
    AccountId     VARCHAR (10)  NOT NULL,
    Email         VARCHAR (100) NOT NULL,
    Role          VARCHAR (20)  NOT NULL,
    UserName      NVARCHAR (50) NOT NULL,
    Password      VARCHAR (255) NOT NULL,
    AccountStatus VARCHAR (20)  CONSTRAINT DF_Account_Status DEFAULT 'Active' NOT NULL,
    CONSTRAINT PK_Account PRIMARY KEY (AccountId),
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
    CONSTRAINT CK_Customer_CCCD CHECK (LEN(CCCD) = 12
                                       AND CCCD NOT LIKE '%[^0-9]%')
);


GO
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
    Quantity   INT          CONSTRAINT DF_RTBT_Quantity DEFAULT 1 NOT NULL,
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