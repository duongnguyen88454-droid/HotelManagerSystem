USE QuanLyKhachSan;
GO

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

PRINT N'------------------------------------------------------------------------';
PRINT N'1. VÔ HIỆU HÓA TẤT CẢ TRIGGER ĐỂ NẠP DỮ LIỆU SEEDING AN TOÀN...';
PRINT N'------------------------------------------------------------------------';
DISABLE TRIGGER ALL ON Booking;
DISABLE TRIGGER ALL ON Booking_Room;
DISABLE TRIGGER ALL ON Booking_Room_Service;
DISABLE TRIGGER ALL ON Invoice;
DISABLE TRIGGER ALL ON Payment;
DISABLE TRIGGER ALL ON RoomCleaningTask;
DISABLE TRIGGER ALL ON DamageReport;
DISABLE TRIGGER ALL ON CancellationHistory;
DISABLE TRIGGER ALL ON Employee;
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'2. XÓA SẠCH DỮ LIỆU CŨ THEO THỨ TỰ KHÓA NGOẠI (CHILD -> PARENT)...';
PRINT N'------------------------------------------------------------------------';
DELETE FROM DamageReport_DamageType;
DELETE FROM DamageReport;
DELETE FROM DamageType;
DELETE FROM RoomCleaningTask;
DELETE FROM Payment;
DELETE FROM Invoice;
DELETE FROM CancellationHistory;
DELETE FROM Booking_Room_Service;
DELETE FROM Booking_Room;
DELETE FROM Booking;
DELETE FROM RoomType_RoomService;
DELETE FROM RoomService;
DELETE FROM Service;
DELETE FROM Room;
DELETE FROM RoomType_BedType;
DELETE FROM RoomType;
DELETE FROM BedType;
DELETE FROM Employee;
DELETE FROM Customer;
DELETE FROM Account;
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'3. CHÈN 7 TÀI KHOẢN (ACCOUNT) VỚI MẬT KHẨU SHA-256 CHUẨN (123456)...';
PRINT N'------------------------------------------------------------------------';
-- Mật khẩu hash: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
INSERT INTO Account (AccountId, Email, Role, UserName, Password, AccountStatus) VALUES
('ACC001', 'admin@hotel.com',        'Manager',      N'admin',        '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active'),
('ACC002', 'letan1@hotel.com',       'Receptionist', N'letan1',       '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active'),
('ACC003', 'letan2@hotel.com',       'Receptionist', N'letan2',       '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active'),
('ACC004', 'buongphong1@hotel.com',  'Housekeeper',  N'buongphong1',  '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active'),
('ACC005', 'buongphong2@hotel.com',  'Housekeeper',  N'buongphong2',  '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active'),
('ACC006', 'customer1@gmail.com',    'Customer',     N'khachhang1',   '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active'),
('ACC007', 'customer2@gmail.com',    'Customer',     N'khachhang2',   '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Active');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'4. CHÈN 5 HỒ SƠ NHÂN VIÊN (EMPLOYEE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Employee (EmployeeId, AccountId, FullName, Phone, Email, HireDate, ResignationDate, EmployeeStatus) VALUES
('EMP001', 'ACC001', N'Nguyễn Quản Lý',   '0901111001', 'admin@hotel.com',       '2024-01-01', NULL, 'Working'),
('EMP002', 'ACC002', N'Lê Lễ Tân',        '0901111002', 'letan1@hotel.com',      '2024-02-15', NULL, 'Working'),
('EMP003', 'ACC003', N'Trần Thu Ngân',    '0901111003', 'letan2@hotel.com',      '2024-03-01', NULL, 'Working'),
('EMP004', 'ACC004', N'Phạm Buồng Phòng', '0901111004', 'buongphong1@hotel.com', '2024-04-10', NULL, 'Working'),
('EMP005', 'ACC005', N'Hoàng Dọn Dẹp',    '0901111005', 'buongphong2@hotel.com', '2024-05-20', NULL, 'Working');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'5. CHÈN 10 KHÁCH HÀNG (CUSTOMER) - CCCD ĐÚNG 12 CHỮ SỐ...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Customer (CustomerId, FullName, PhoneNumber, CCCD, Email) VALUES
('CUS001', N'Đặng Văn Khách',   '0912000001', '001202000001', 'customer1@gmail.com'),
('CUS002', N'Vũ Thị Lan',       '0912000002', '001202000002', 'customer2@gmail.com'),
('CUS003', N'Phạm Quang Minh',  '0912000003', '001202000003', 'minh.pq@gmail.com'),
('CUS004', N'Nguyễn Thị Mai',   '0912000004', '001202000004', 'mai.nt@gmail.com'),
('CUS005', N'Trương Tấn Phát',  '0912000005', '001202000005', 'phat.tt@gmail.com'),
('CUS006', N'Bùi Hoàng Nam',    '0912000006', '001202000006', 'nam.bh@gmail.com'),
('CUS007', N'Lê Mỹ Duyên',      '0912000007', '001202000007', 'duyen.lm@gmail.com'),
('CUS008', N'Đỗ Anh Tuấn',      '0912000008', '001202000008', 'tuan.da@gmail.com'),
('CUS009', N'Hồ Bích Ngọc',     '0912000009', '001202000009', 'ngoc.hb@gmail.com'),
('CUS010', N'Võ Trọng Nghĩa',   '0912000010', '001202000010', 'nghia.vt@gmail.com');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'6. CHÈN 10 LOẠI GIƯỜNG (BEDTYPE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO BedType (BedTypeId, BedTypeName, IsActive) VALUES
('BT001', N'Giường Đơn Tiêu Chuẩn (Single 1.2m)', 1),
('BT002', N'Giường Đôi Tiêu Chuẩn (Double 1.6m)', 1),
('BT003', N'Giường Đôi Lớn (Queen 1.8m)',        1),
('BT004', N'Giường Đôi Cực Đại (King 2.0m)',      1),
('BT005', N'Giường Siêu Rộng (Super King 2.2m)',  1),
('BT006', N'Giường Tầng Trẻ Em (Bunk Bed)',       1),
('BT007', N'Giường Phụ Gấp (Extra Bed)',          1),
('BT008', N'Giường Đôi Ghép (Hollywood Twin)',    1),
('BT009', N'Giường Tròn Cao Cấp (Round Bed)',     1),
('BT010', N'Giường Sofa Đa Năng (Sofa Bed)',      1);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'7. CHÈN 10 HẠNG PHÒNG (ROOMTYPE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO RoomType (RoomTypeId, RoomTypeName, BasePrice, Capacity, EarlyCheckInFee, LateCheckOutFee, DepositPercent, IsActive) VALUES
('RT001', N'Standard Single Room',    500000.00,  1, 150000.00, 150000.00, 30.00, 1),
('RT002', N'Standard Double Room',    700000.00,  2, 200000.00, 200000.00, 30.00, 1),
('RT003', N'Superior Twin Room',      850000.00,  2, 250000.00, 250000.00, 30.00, 1),
('RT004', N'Superior King Room',      950000.00,  2, 250000.00, 250000.00, 30.00, 1),
('RT005', N'Deluxe Ocean View Room',  1200000.00, 2, 350000.00, 350000.00, 40.00, 1),
('RT006', N'Deluxe Mountain View',    1100000.00, 2, 300000.00, 300000.00, 40.00, 1),
('RT007', N'Junior Suite Room',       1600000.00, 3, 450000.00, 450000.00, 40.00, 1),
('RT008', N'Executive Suite Room',    2200000.00, 4, 600000.00, 600000.00, 50.00, 1),
('RT009', N'Family Connecting Suite', 2800000.00, 5, 700000.00, 700000.00, 50.00, 1),
('RT010', N'Presidential Suite Room', 5000000.00, 6, 1200000.00, 1200000.00, 50.00, 1);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'8. CHÈN LIÊN KẾT ROOMTYPE - BEDTYPE...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO RoomType_BedType (RoomTypeId, BedTypeId, Quantity) VALUES
('RT001', 'BT001', 1),
('RT002', 'BT002', 1),
('RT003', 'BT001', 2),
('RT004', 'BT004', 1),
('RT005', 'BT004', 1),
('RT006', 'BT003', 1),
('RT007', 'BT004', 1),
('RT007', 'BT010', 1),
('RT008', 'BT005', 1),
('RT008', 'BT007', 1),
('RT009', 'BT003', 1),
('RT009', 'BT001', 2),
('RT010', 'BT005', 1),
('RT010', 'BT009', 1);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'9. CHÈN 10 TIỆN NGHI PHÒNG (ROOMSERVICE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO RoomService (RoomServiceId, RoomServiceName, IsActive) VALUES
('RS001', N'Wifi Tốc Độ Cao',              1),
('RS002', N'Smart TV 55 inch',             1),
('RS003', N'Điều Hòa 2 Chiều',             1),
('RS004', N'Tủ Lạnh Minibar',              1),
('RS005', N'Két Sắt An Toàn',              1),
('RS006', N'Máy Sấy Tóc Chuyên Dụng',       1),
('RS007', N'Ấm Đun Nước Siêu Tốc',         1),
('RS008', N'Bàn Ủi & Cầu Là Hơi Nước',     1),
('RS009', N'Ban Công Ngắm Cảnh Thoáng Mát', 1),
('RS010', N'Bồn Tắm Nằm Jacuzzi Cao Cấp',   1);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'10. CHÈN LIÊN KẾT ROOMTYPE - ROOMSERVICE...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO RoomType_RoomService (RoomTypeId, RoomServiceId) VALUES
('RT001', 'RS001'), ('RT001', 'RS003'), ('RT001', 'RS006'),
('RT002', 'RS001'), ('RT002', 'RS002'), ('RT002', 'RS003'), ('RT002', 'RS004'),
('RT003', 'RS001'), ('RT003', 'RS002'), ('RT003', 'RS003'), ('RT003', 'RS007'),
('RT004', 'RS001'), ('RT004', 'RS002'), ('RT004', 'RS003'), ('RT004', 'RS004'), ('RT004', 'RS005'),
('RT005', 'RS001'), ('RT005', 'RS002'), ('RT005', 'RS003'), ('RT005', 'RS004'), ('RT005', 'RS005'), ('RT005', 'RS009'),
('RT006', 'RS001'), ('RT006', 'RS002'), ('RT006', 'RS003'), ('RT006', 'RS004'), ('RT006', 'RS009'),
('RT007', 'RS001'), ('RT007', 'RS002'), ('RT007', 'RS003'), ('RT007', 'RS004'), ('RT007', 'RS005'), ('RT007', 'RS008'), ('RT007', 'RS010'),
('RT008', 'RS001'), ('RT008', 'RS002'), ('RT008', 'RS003'), ('RT008', 'RS004'), ('RT008', 'RS005'), ('RT008', 'RS008'), ('RT008', 'RS010'),
('RT009', 'RS001'), ('RT009', 'RS002'), ('RT009', 'RS003'), ('RT009', 'RS004'), ('RT009', 'RS005'), ('RT009', 'RS007'), ('RT009', 'RS009'),
('RT010', 'RS001'), ('RT010', 'RS002'), ('RT010', 'RS003'), ('RT010', 'RS004'), ('RT010', 'RS005'), ('RT010', 'RS006'), ('RT010', 'RS007'), ('RT010', 'RS008'), ('RT010', 'RS009'), ('RT010', 'RS010');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'11. CHÈN 15 PHÒNG VẬT LÝ (ROOM) - MÃ RM001 ĐẾN RM015...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Room (RoomId, RoomTypeId, RoomName, RoomStatus, HousekeepingStatus, OccupancyStatus) VALUES
('RM001', 'RT001', N'P101', 'Available',   'Clean',    'Vacant'),
('RM002', 'RT002', N'P102', 'Available',   'Clean',    'Vacant'),
('RM003', 'RT002', N'P103', 'Available',   'Clean',    'Vacant'),
('RM004', 'RT003', N'P104', 'Available',   'Clean',    'Vacant'),
('RM005', 'RT004', N'P105', 'Available',   'Clean',    'Vacant'),
('RM006', 'RT005', N'P201', 'Available',   'Clean',    'Vacant'),
('RM007', 'RT005', N'P202', 'Available',   'Clean',    'Occupied'),
('RM008', 'RT006', N'P203', 'Available',   'Clean',    'Occupied'),
('RM009', 'RT007', N'P204', 'Available',   'Clean',    'Vacant'),
('RM010', 'RT007', N'P205', 'Available',   'Dirty',    'Vacant'),
('RM011', 'RT008', N'P301', 'Available',   'Clean',    'Vacant'),
('RM012', 'RT008', N'P302', 'Available',   'Cleaning', 'Vacant'),
('RM013', 'RT009', N'P303', 'Available',   'Clean',    'Vacant'),
('RM014', 'RT009', N'P304', 'Maintenance', 'Dirty',    'Vacant'),
('RM015', 'RT010', N'P305', 'Available',   'Clean',    'Vacant');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'12. CHÈN 10 DỊCH VỤ THU PHÍ (SERVICE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Service (ServiceId, ServiceName, BasePrice, IsActive) VALUES
('SRV001', N'Giặt Ủi Quần Áo Tiêu Chuẩn',           50000.00,  1),
('SRV002', N'Buffet Sáng Quốc Tế',                 150000.00, 1),
('SRV003', N'Nước Suối Khoáng Lavie (Chai 500ml)',  20000.00,  1),
('SRV004', N'Nước Ngọt Coca Cola (Lon 330ml)',      25000.00,  1),
('SRV005', N'Bia Heineken Silver (Lon 330ml)',      35000.00,  1),
('SRV006', N'Thuê Xe Máy Tay Ga (Theo Ngày)',       180000.00, 1),
('SRV007', N'Đưa Đón Sân Bay 1 Chiều',             300000.00, 1),
('SRV008', N'Massage Body Thư Giãn (60 phút)',      400000.00, 1),
('SRV009', N'Bữa Ăn Đêm Tại Phòng (Room Dining)',   120000.00, 1),
('SRV010', N'Đĩa Trái Cây Tươi Chào Mừng',          80000.00,  1);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'13. CHÈN 10 NHÓM LOẠI HƯ HẠI (DAMAGETYPE) - CHUẨN CATEGORY...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO DamageType (DamageTypeId, DamageName) VALUES
('DT001', N'Hư hại thiết bị điện & điện tử'),
('DT002', N'Hư hại đồ gỗ & nội thất'),
('DT003', N'Hư hại thiết bị vệ sinh & phòng tắm'),
('DT004', N'Hư hại đồ vải & dệt may'),
('DT005', N'Hư hại hệ thống khóa & an ninh'),
('DT006', N'Hư hại hệ thống điều hòa & thông gió'),
('DT007', N'Hư hại cửa sổ, cửa đi & vách kính'),
('DT008', N'Hư hại đồ thủy tinh & sành sứ'),
('DT009', N'Hư hại tường, trần & sàn nhà'),
('DT010', N'Hư hại tiện ích ban công & ngoài trời');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'14. CHÈN 10 ĐƠN ĐẶT PHÒNG (BOOKING)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Booking (BookingId, CustomerId, CreateBy, CreateDate) VALUES
('BK001', 'CUS001', 'ACC002', '2026-10-01 08:30:00'),
('BK002', 'CUS002', 'ACC002', '2026-10-02 09:15:00'),
('BK003', 'CUS003', 'ACC003', '2026-10-04 14:00:00'),
('BK004', 'CUS004', 'ACC002', '2026-10-06 10:20:00'),
('BK005', 'CUS005', 'ACC003', '2026-10-08 16:45:00'),
('BK006', 'CUS006', 'ACC006', '2026-10-10 11:10:00'),
('BK007', 'CUS007', 'ACC002', '2026-10-14 13:00:00'),
('BK008', 'CUS008', 'ACC003', '2026-10-15 15:30:00'),
('BK009', 'CUS009', 'ACC007', '2026-10-16 18:20:00'),
('BK010', 'CUS010', 'ACC002', '2026-10-08 09:00:00');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'15. CHÈN CHI TIẾT PHÒNG ĐẶT (BOOKING_ROOM)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Booking_Room (BookingId, RoomId, BookingStatus, ExpectedCheckInDate, ExpectedCheckOutDate, ActualCheckInDate, ActualCheckOutDate, Deposit, Price) VALUES
('BK001', 'RM001', 'CheckedOut', '2026-10-01', '2026-10-03', '2026-10-01 13:30:00', '2026-10-03 11:30:00', 300000.00,  500000.00),
('BK002', 'RM002', 'CheckedOut', '2026-10-02', '2026-10-05', '2026-10-02 14:00:00', '2026-10-05 12:00:00', 420000.00,  700000.00),
('BK003', 'RM003', 'CheckedOut', '2026-10-05', '2026-10-07', '2026-10-05 14:15:00', '2026-10-07 11:45:00', 420000.00,  700000.00),
('BK004', 'RM004', 'CheckedOut', '2026-10-07', '2026-10-09', '2026-10-07 13:50:00', '2026-10-09 11:20:00', 510000.00,  850000.00),
('BK005', 'RM005', 'CheckedOut', '2026-10-09', '2026-10-11', '2026-10-09 14:00:00', '2026-10-11 12:10:00', 570000.00,  950000.00),
('BK006', 'RM006', 'CheckedOut', '2026-10-11', '2026-10-14', '2026-10-11 14:30:00', '2026-10-14 11:50:00', 960000.00, 1200000.00),
('BK007', 'RM007', 'CheckedIn',  '2026-10-15', '2026-10-19', '2026-10-15 14:00:00', NULL,                  960000.00, 1200000.00),
('BK008', 'RM008', 'CheckedIn',  '2026-10-16', '2026-10-20', '2026-10-16 13:40:00', NULL,                  880000.00, 1100000.00),
('BK009', 'RM009', 'Confirmed',  '2026-10-22', '2026-10-25', NULL,                  NULL,                 1280000.00, 1600000.00),
('BK010', 'RM011', 'Cancelled',  '2026-10-10', '2026-10-13', NULL,                  NULL,                 2200000.00, 2200000.00);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'16. CHÈN DỊCH VỤ PHÁT SINH THEO PHÒNG (BOOKING_ROOM_SERVICE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Booking_Room_Service (BookingId, RoomId, ServiceId, UnitPrice, Quantity) VALUES
('BK001', 'RM001', 'SRV003',  20000.00, 2),
('BK001', 'RM001', 'SRV002', 150000.00, 2),
('BK002', 'RM002', 'SRV004',  25000.00, 4),
('BK002', 'RM002', 'SRV001',  50000.00, 2),
('BK003', 'RM003', 'SRV005',  35000.00, 3),
('BK004', 'RM004', 'SRV006', 180000.00, 1),
('BK005', 'RM005', 'SRV007', 300000.00, 1),
('BK006', 'RM006', 'SRV008', 400000.00, 2),
('BK007', 'RM007', 'SRV009', 120000.00, 1),
('BK008', 'RM008', 'SRV010',  80000.00, 1);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'17. CHÈN 10 HỒ SƠ HỦY PHÒNG / HOÀN TIỀN (CANCELLATIONHISTORY)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO CancellationHistory (CancellationId, BookingId, RoomId, CancelledBy, DepositAtCancellation, CancellationDate, CancellationFee, RefundStatus, Reason) VALUES
('CAN001', 'BK010', 'RM011', 'ACC002', 2200000.00, '2026-10-09 10:00:00', 200000.00, 'Completed', N'Khách bận công tác đột xuất, đã duyệt hoàn 2.000.000đ'),
('CAN002', 'BK010', 'RM011', 'ACC002', 1000000.00, '2026-10-10 11:20:00', 100000.00, 'Completed', N'Hủy trước 24h, hoàn trả cọc qua chuyển khoản'),
('CAN003', 'BK010', 'RM011', 'ACC003', 1500000.00, '2026-10-11 14:00:00', 300000.00, 'Pending',   N'Khách yêu cầu hủy phòng do thời tiết bão, chờ quản lý duyệt'),
('CAN004', 'BK010', 'RM011', 'ACC003',  800000.00, '2026-10-12 16:30:00', 200000.00, 'Pending',   N'Chờ xác minh sao kê ngân hàng hoàn cọc'),
('CAN005', 'BK010', 'RM011', 'ACC001', 1200000.00, '2026-10-13 09:10:00', 1200000.00,'Rejected',  N'Hủy sát giờ nhận phòng quá thời hạn quy định, không duyệt hoàn tiền'),
('CAN006', 'BK010', 'RM011', 'ACC002',  900000.00, '2026-10-13 15:40:00', 100000.00, 'Completed', N'Đã hoàn tiền cọc thành công vào tài khoản Vietcombank'),
('CAN007', 'BK010', 'RM011', 'ACC002', 1100000.00, '2026-10-14 17:00:00', 200000.00, 'Pending',   N'Khách đổi lịch trình sang tháng sau, đang thẩm định'),
('CAN008', 'BK010', 'RM011', 'ACC003',  750000.00, '2026-10-15 08:30:00',  75000.00, 'Completed', N'Trừ 10% phí hủy theo chính sách khách sạn'),
('CAN009', 'BK010', 'RM011', 'ACC001', 2000000.00, '2026-10-15 13:15:00', 2000000.00,'Rejected',  N'Khách no-show không đến nhận phòng, từ chối hoàn tiền'),
('CAN010', 'BK010', 'RM011', 'ACC002', 1300000.00, '2026-10-16 10:45:00', 150000.00, 'Pending',   N'Yêu cầu hoàn cọc mới tiếp nhận sáng nay');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'18. CHÈN 10 HÓA ĐƠN THANH TOÁN (INVOICE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Invoice (InvoiceId, BookingId, CreateDate, TotalRoomCharge, TotalServiceCharge, EarlyCheckInFee, LateCheckOutFee, InvoiceStatus, FinalTotalAmount) VALUES
('INV001', 'BK001', '2026-10-03 11:30:00', 1000000.00, 340000.00,      0.00,      0.00, 'Paid',   1340000.00),
('INV002', 'BK002', '2026-10-05 12:00:00', 2100000.00, 200000.00,      0.00,      0.00, 'Paid',   2300000.00),
('INV003', 'BK003', '2026-10-07 11:45:00', 1400000.00, 105000.00,      0.00,      0.00, 'Paid',   1505000.00),
('INV004', 'BK004', '2026-10-09 11:20:00', 1700000.00, 180000.00,      0.00,      0.00, 'Paid',   1880000.00),
('INV005', 'BK005', '2026-10-11 12:10:00', 1900000.00, 300000.00,      0.00,      0.00, 'Paid',   2200000.00),
('INV006', 'BK006', '2026-10-14 11:50:00', 3600000.00, 800000.00,      0.00,      0.00, 'Paid',   4400000.00),
('INV007', 'BK007', '2026-10-15 14:00:00', 4800000.00, 120000.00,      0.00,      0.00, 'Unpaid', 4920000.00),
('INV008', 'BK008', '2026-10-16 13:40:00', 4400000.00,  80000.00,      0.00,      0.00, 'Unpaid', 4480000.00),
('INV009', 'BK009', '2026-10-16 18:20:00', 4800000.00,      0.00,      0.00,      0.00, 'Unpaid', 4800000.00),
('INV010', 'BK010', '2026-10-10 11:20:00',      0.00,      0.00,      0.00,      0.00, 'Paid',         0.00);
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'19. CHÈN 10 GIAO DỊCH THANH TOÁN (PAYMENT)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO Payment (PaymentId, ProcessBy, InvoiceId, PaymentDate, PaymentMethod, TotalAmount, Note) VALUES
('PAY001', 'ACC002', 'INV001', '2026-10-01 08:35:00', 'BankTransfer',  300000.00, N'Thanh toán tiền đặt cọc nhận phòng'),
('PAY002', 'ACC002', 'INV001', '2026-10-03 11:35:00', 'Cash',         1040000.00, N'Thanh toán số tiền còn lại khi check-out'),
('PAY003', 'ACC002', 'INV002', '2026-10-02 09:20:00', 'CreditCard',    420000.00, N'Đặt cọc quẹt thẻ Visa'),
('PAY004', 'ACC003', 'INV002', '2026-10-05 12:05:00', 'BankTransfer', 1880000.00, N'Chuyển khoản thanh toán toàn bộ chi phí'),
('PAY005', 'ACC003', 'INV003', '2026-10-07 11:50:00', 'Cash',         1505000.00, N'Thanh toán tiền mặt tại quầy lễ tân'),
('PAY006', 'ACC002', 'INV004', '2026-10-09 11:25:00', 'CreditCard',   1880000.00, N'Thanh toán bằng thẻ Master Card'),
('PAY007', 'ACC003', 'INV005', '2026-10-11 12:15:00', 'BankTransfer', 2200000.00, N'Chuyển khoản quét mã QR ngân hàng'),
('PAY008', 'ACC002', 'INV006', '2026-10-14 11:55:00', 'BankTransfer', 4400000.00, N'Khách VIP thanh toán chuyển khoản'),
('PAY009', 'ACC002', 'INV007', '2026-10-15 14:05:00', 'CreditCard',    960000.00, N'Đặt cọc phòng lưu trú đang ở'),
('PAY010', 'ACC003', 'INV008', '2026-10-16 13:45:00', 'Cash',          880000.00, N'Đặt cọc tiền mặt khi làm thủ tục check-in');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'20. CHÈN 10 NHIỆM VỤ DỌN PHÒNG (ROOMCLEANINGTASK)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO RoomCleaningTask (RoomCleaningTaskId, RoomId, ReceivedBy, StartTime, EndTime, RoomCleaningTaskStatus, Result) VALUES
('TSK001', 'RM001', 'ACC004', '2026-10-03 11:35:00', '2026-10-03 12:15:00', 'Completed',  N'Đã dọn dẹp sạch sẽ, thay toàn bộ vỏ chăn ga và bổ sung nước khoáng'),
('TSK002', 'RM002', 'ACC005', '2026-10-05 12:05:00', '2026-10-05 12:50:00', 'Completed',  N'Đã hút bụi, khử khuẩn phòng và kiểm tra thiết bị hoạt động tốt'),
('TSK003', 'RM003', 'ACC004', '2026-10-07 11:50:00', '2026-10-07 12:30:00', 'Completed',  N'Hoàn tất vệ sinh toilet và bổ sung đồ dùng 1 lần (amenities)'),
('TSK004', 'RM004', 'ACC005', '2026-10-09 11:25:00', '2026-10-09 12:05:00', 'Completed',  N'Đã lau dọn ban công và thay khăn tắm sạch'),
('TSK005', 'RM005', 'ACC004', '2026-10-11 12:15:00', '2026-10-11 13:00:00', 'Completed',  N'Đã vệ sinh sạch sẽ, phòng sẵn sàng đón khách mới'),
('TSK006', 'RM006', 'ACC005', '2026-10-14 12:00:00', '2026-10-14 12:55:00', 'Completed',  N'Dọn phòng Suite, lau kính cửa sổ và kiểm tra két sắt an toàn'),
('TSK007', 'RM010', 'ACC004', '2026-10-18 07:30:00', NULL,                  'InProgress', N'Đang hút bụi thảm và thay bộ ga giường mới'),
('TSK008', 'RM012', 'ACC005', '2026-10-18 07:45:00', NULL,                  'InProgress', N'Đang tổng vệ sinh bồn tắm jacuzzi và lau sàn gỗ'),
('TSK009', 'RM014', NULL,     NULL,                  NULL,                  'Pending',    N'Phòng bảo trì xong cần dọn dẹp kỹ trước khi đưa vào khai thác'),
('TSK010', 'RM015', NULL,     NULL,                  NULL,                  'Pending',    N'Lên kế hoạch dọn định kỳ phòng Tổng thống đón đoàn ngoại giao');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'21. CHÈN 10 BIÊN BẢN BÁO CÁO HƯ HẠI (DAMAGEREPORT)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO DamageReport (DamageReportId, RoomId, CreateBy, DetectedAt, ConfirmedAt, DamageReportStatus) VALUES
('DMR001', 'RM001', 'ACC004', '2026-10-03 11:40:00', '2026-10-03 12:00:00', 'Resolved'),
('DMR002', 'RM002', 'ACC005', '2026-10-05 12:10:00', '2026-10-05 12:30:00', 'Resolved'),
('DMR003', 'RM004', 'ACC004', '2026-10-09 11:30:00', '2026-10-09 13:00:00', 'Resolved'),
('DMR004', 'RM006', 'ACC005', '2026-10-14 12:15:00', '2026-10-14 14:00:00', 'Resolved'),
('DMR005', 'RM010', 'ACC004', '2026-10-17 08:30:00', '2026-10-17 09:30:00', 'Confirmed'),
('DMR006', 'RM012', 'ACC005', '2026-10-17 14:20:00', '2026-10-17 15:00:00', 'Confirmed'),
('DMR007', 'RM014', 'ACC004', '2026-10-17 16:50:00', '2026-10-17 17:30:00', 'Confirmed'),
('DMR008', 'RM007', 'ACC005', '2026-10-18 07:15:00', NULL,                  'Pending'),
('DMR009', 'RM008', 'ACC004', '2026-10-18 07:40:00', NULL,                  'Pending'),
('DMR010', 'RM015', 'ACC005', '2026-10-18 08:00:00', NULL,                  'Pending');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'22. CHÈN LIÊN KẾT BIÊN BẢN VÀ LOẠI HƯ HẠI (DAMAGEREPORT_DAMAGETYPE)...';
PRINT N'------------------------------------------------------------------------';
INSERT INTO DamageReport_DamageType (DamageReportId, DamageTypeId, Note) VALUES
('DMR001', 'DT001', N'Ấm đun nước siêu tốc bị cháy phần đế cắm điện, đã đổi mới'),
('DMR002', 'DT008', N'Khách làm vỡ 2 ly thủy tinh uống rượu vang trong minibar'),
('DMR003', 'DT003', N'Đầu vòi sen tắm bị rỉ nước ở ren nối, kỹ thuật đã siết lại'),
('DMR004', 'DT004', N'Rèm cửa sổ ban công bị tuột móc treo, đã móc lại chắc chắn'),
('DMR005', 'DT005', N'Ổ khóa thẻ từ cửa phòng nhận tín hiệu chập chờn, kỹ thuật đang thay pin và bo mạch'),
('DMR006', 'DT006', N'Điều hòa phòng phả ra hơi ấm, kỹ thuật đang nạp thêm gas lạnh R410A'),
('DMR007', 'DT002', N'Chân bàn làm việc bị lỏng ốc vít gây lung lay, đang gia cố lại khung sắt'),
('DMR008', 'DT007', N'Cánh cửa lùa ban công bị kẹt ray trượt, cần thợ bôi mỡ bảo dưỡng'),
('DMR009', 'DT009', N'Vết trầy xước dài 10cm trên sàn gỗ gần chân giường, chờ nghiệm thu khắc phục'),
('DMR010', 'DT010', N'Tay vịn lan can ban công bằng nhôm kính bị lỏng bu-lông cố định, chờ kỹ thuật xử lý');
GO

PRINT N'------------------------------------------------------------------------';
PRINT N'23. BẬT LẠI TẤT CẢ TRIGGER VÀ HOÀN TẤT...';
PRINT N'------------------------------------------------------------------------';
ENABLE TRIGGER ALL ON Booking;
ENABLE TRIGGER ALL ON Booking_Room;
ENABLE TRIGGER ALL ON Booking_Room_Service;
ENABLE TRIGGER ALL ON Invoice;
ENABLE TRIGGER ALL ON Payment;
ENABLE TRIGGER ALL ON RoomCleaningTask;
ENABLE TRIGGER ALL ON DamageReport;
ENABLE TRIGGER ALL ON CancellationHistory;
ENABLE TRIGGER ALL ON Employee;
GO

PRINT N'========================================================================';
PRINT N'NẠP TOÀN BỘ CSDL MỚI THÀNH CÔNG RỰC RỠ!';
PRINT N'========================================================================';
GO
