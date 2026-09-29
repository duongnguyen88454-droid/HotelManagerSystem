-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: TẠO DATABASE, 17 BẢNG (CHUẨN 3NF), RÀNG BUỘC VÀ DỮ LIỆU MẪU
-- ============================================================================
-- ============================================================================
-- PHẦN 1: TẠO DATABASE VÀ CÁC BẢNG (DDL SCRIPT)
-- ============================================================================
IF DB_ID('QuanLyKhachSan') IS NOT NULL
    BEGIN
        ALTER DATABASE QuanLyKhachSan
            SET SINGLE_USER 
            WITH ROLLBACK IMMEDIATE;
        DROP DATABASE QuanLyKhachSan;
    END


GO
CREATE DATABASE QuanLyKhachSan;


GO
USE QuanLyKhachSan;


GO
-- 1. XÓA BẢNG NẾU ĐÃ TỒN TẠI (Thứ tự từ bảng con đến bảng cha)
IF OBJECT_ID('CHITIETBAOCAOHUHAI', 'U') IS NOT NULL
    DROP TABLE CHITIETBAOCAOHUHAI;

IF OBJECT_ID('BAOCAOHUHAI', 'U') IS NOT NULL
    DROP TABLE BAOCAOHUHAI;

IF OBJECT_ID('LOAIHUHAI', 'U') IS NOT NULL
    DROP TABLE LOAIHUHAI;

IF OBJECT_ID('NHIEMVUDOPHONG', 'U') IS NOT NULL
    DROP TABLE NHIEMVUDOPHONG;

IF OBJECT_ID('THANHTOAN', 'U') IS NOT NULL
    DROP TABLE THANHTOAN;

IF OBJECT_ID('HOADON', 'U') IS NOT NULL
    DROP TABLE HOADON;

IF OBJECT_ID('BOOKING_DICHVU', 'U') IS NOT NULL
    DROP TABLE BOOKING_DICHVU;

IF OBJECT_ID('BOOKING_PHONG', 'U') IS NOT NULL
    DROP TABLE BOOKING_PHONG;

IF OBJECT_ID('BOOKING', 'U') IS NOT NULL
    DROP TABLE BOOKING;

IF OBJECT_ID('LOAIPHONG_DICHVU', 'U') IS NOT NULL
    DROP TABLE LOAIPHONG_DICHVU;

IF OBJECT_ID('DICHVU', 'U') IS NOT NULL
    DROP TABLE DICHVU;

IF OBJECT_ID('PHONG', 'U') IS NOT NULL
    DROP TABLE PHONG;

IF OBJECT_ID('LOAIPHONG', 'U') IS NOT NULL
    DROP TABLE LOAIPHONG;

IF OBJECT_ID('NHANVIEN', 'U') IS NOT NULL
    DROP TABLE NHANVIEN;

IF OBJECT_ID('KHACHHANG', 'U') IS NOT NULL
    DROP TABLE KHACHHANG;

IF OBJECT_ID('TAIKHOAN', 'U') IS NOT NULL
    DROP TABLE TAIKHOAN;

IF OBJECT_ID('VAITRO', 'U') IS NOT NULL
    DROP TABLE VAITRO;


GO
-- 2. TẠO CÁC BẢNG VỀ NGƯỜI DÙNG & TÀI KHOẢN
-- BẢNG 1: VAITRO
CREATE TABLE VAITRO (
    MaVaiTro  VARCHAR (10)  NOT NULL,
    TenVaiTro NVARCHAR (30) NOT NULL,
    CONSTRAINT PK_VAITRO PRIMARY KEY (MaVaiTro),
    CONSTRAINT UQ_VAITRO_TenVaiTro UNIQUE (TenVaiTro)
);


GO
-- BẢNG 2: TAIKHOAN
CREATE TABLE TAIKHOAN (
    MaTaiKhoan  VARCHAR (10)  NOT NULL,
    TenDangNhap VARCHAR (50)  NOT NULL,
    MatKhau     VARCHAR (255) NOT NULL,
    MaVaiTro    VARCHAR (10)  NOT NULL,
    TrangThai   VARCHAR (20)  CONSTRAINT DF_TAIKHOAN_TrangThai DEFAULT 'Active' NOT NULL,
    CONSTRAINT PK_TAIKHOAN PRIMARY KEY (MaTaiKhoan),
    CONSTRAINT UQ_TAIKHOAN_TenDangNhap UNIQUE (TenDangNhap),
    CONSTRAINT FK_TAIKHOAN_VAITRO FOREIGN KEY (MaVaiTro) REFERENCES VAITRO (MaVaiTro),
    CONSTRAINT CK_TAIKHOAN_TrangThai CHECK (TrangThai IN ('Active', 'Locked'))
);


GO
-- BẢNG 3: KHACHHANG
CREATE TABLE KHACHHANG (
    MaKH       VARCHAR (10)   NOT NULL,
    MaTaiKhoan VARCHAR (10)   NULL,
    HoTen      NVARCHAR (100) NOT NULL,
    Email      VARCHAR (100)  NULL,
    SoDT       VARCHAR (15)   NOT NULL,
    CCCD       VARCHAR (20)   NULL,
    CONSTRAINT PK_KHACHHANG PRIMARY KEY (MaKH),
    CONSTRAINT UQ_KHACHHANG_SoDT UNIQUE (SoDT),
    CONSTRAINT FK_KHACHHANG_TAIKHOAN FOREIGN KEY (MaTaiKhoan) REFERENCES TAIKHOAN (MaTaiKhoan),
    CONSTRAINT CK_KHACHHANG_CCCD_12Digits CHECK (CCCD IS NULL OR (LEN(CCCD) = 12 AND CCCD NOT LIKE '%[^0-9]%'))
);
GO

-- Filtered Unique Indexes cho KHACHHANG (cho phép nhiều giá trị NULL nhưng khi có dữ liệu thì bắt buộc duy nhất)
CREATE UNIQUE NONCLUSTERED INDEX UQ_KHACHHANG_MaTaiKhoan_Filtered
ON KHACHHANG (MaTaiKhoan)
WHERE MaTaiKhoan IS NOT NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_KHACHHANG_Email_Filtered
ON KHACHHANG (Email)
WHERE Email IS NOT NULL;
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_KHACHHANG_CCCD_Filtered
ON KHACHHANG (CCCD)
WHERE CCCD IS NOT NULL;
GO


GO
-- BẢNG 4: NHANVIEN
CREATE TABLE NHANVIEN (
    MaNV             VARCHAR (10)   NOT NULL,
    MaTaiKhoan       VARCHAR (10)   NOT NULL,
    HoTen            NVARCHAR (100) NOT NULL,
    Email            VARCHAR (100)  NOT NULL,
    SoDienThoai      VARCHAR (15)   NOT NULL,
    NgayVaoLam       DATE           NOT NULL,
    NgayNghiLam      DATE           NULL,
    TrangThaiLamViec VARCHAR (20)   CONSTRAINT DF_NHANVIEN_TrangThai DEFAULT 'DangLam' NOT NULL,
    CONSTRAINT PK_NHANVIEN PRIMARY KEY (MaNV),
    CONSTRAINT UQ_NHANVIEN_MaTaiKhoan UNIQUE (MaTaiKhoan),
    CONSTRAINT UQ_NHANVIEN_Email UNIQUE (Email),
    CONSTRAINT UQ_NHANVIEN_SoDienThoai UNIQUE (SoDienThoai),
    CONSTRAINT FK_NHANVIEN_TAIKHOAN FOREIGN KEY (MaTaiKhoan) REFERENCES TAIKHOAN (MaTaiKhoan),
    CONSTRAINT CK_NHANVIEN_TrangThai CHECK (TrangThaiLamViec IN ('DangLam', 'NghiViec')),
    CONSTRAINT CK_NHANVIEN_NgayCongTac CHECK (NgayNghiLam IS NULL
                                              OR NgayNghiLam >= NgayVaoLam)
);


GO
-- 3. TẠO CÁC BẢNG PHÒNG & DỊCH VỤ
-- BẢNG 5: LOAIPHONG
CREATE TABLE LOAIPHONG (
    MaLoaiPhong  VARCHAR (10)    NOT NULL,
    TenLoaiPhong NVARCHAR (50)   NOT NULL,
    DienTich     DECIMAL (6, 2)  NOT NULL,
    LoaiGiuong   NVARCHAR (50)   NULL,
    SoNguoiToiDa INT             NOT NULL,
    GiaPhong     DECIMAL (12, 2) NOT NULL,
    TrangThai    VARCHAR (20)    CONSTRAINT DF_LOAIPHONG_TrangThai DEFAULT 'ApDung' NOT NULL,
    CONSTRAINT PK_LOAIPHONG PRIMARY KEY (MaLoaiPhong),
    CONSTRAINT UQ_LOAIPHONG_TenLoaiPhong UNIQUE (TenLoaiPhong),
    CONSTRAINT CK_LOAIPHONG_DienTich CHECK (DienTich > 0),
    CONSTRAINT CK_LOAIPHONG_SoNguoiToiDa CHECK (SoNguoiToiDa > 0),
    CONSTRAINT CK_LOAIPHONG_GiaPhong CHECK (GiaPhong >= 0),
    CONSTRAINT CK_LOAIPHONG_TrangThai CHECK (TrangThai IN ('ApDung', 'NgungApDung'))
);


GO
-- BẢNG 6: PHONG
CREATE TABLE PHONG (
    MaPhong     VARCHAR (10)   NOT NULL,
    SoPhong     VARCHAR (10)   NOT NULL,
    MaLoaiPhong VARCHAR (10)   NOT NULL,
    TrangThai   VARCHAR (20)   CONSTRAINT DF_PHONG_TrangThai DEFAULT 'Available' NOT NULL,
    MoTa        NVARCHAR (300) NULL,
    CONSTRAINT PK_PHONG PRIMARY KEY (MaPhong),
    CONSTRAINT UQ_PHONG_SoPhong UNIQUE (SoPhong),
    CONSTRAINT FK_PHONG_LOAIPHONG FOREIGN KEY (MaLoaiPhong) REFERENCES LOAIPHONG (MaLoaiPhong),
    CONSTRAINT CK_PHONG_TrangThai CHECK (TrangThai IN ('Available', 'Booked', 'Occupied', 'Dirty', 'Cleaning', 'Damaged'))
);


GO
-- BẢNG 7: DICHVU
CREATE TABLE DICHVU (
    MaDichVu  VARCHAR (10)    NOT NULL,
    TenDichVu NVARCHAR (100)  NOT NULL,
    MoTa      NVARCHAR (300)  NULL,
    DonGia    DECIMAL (12, 2) NOT NULL,
    TrangThai VARCHAR (20)    CONSTRAINT DF_DICHVU_TrangThai DEFAULT 'ApDung' NOT NULL,
    CONSTRAINT PK_DICHVU PRIMARY KEY (MaDichVu),
    CONSTRAINT UQ_DICHVU_TenDichVu UNIQUE (TenDichVu),
    CONSTRAINT CK_DICHVU_DonGia CHECK (DonGia >= 0),
    CONSTRAINT CK_DICHVU_TrangThai CHECK (TrangThai IN ('ApDung', 'NgungApDung'))
);


GO
-- BẢNG 8: LOAIPHONG_DICHVU (Bảng kết hợp N-N: tiện ích kèm theo loại phòng)
CREATE TABLE LOAIPHONG_DICHVU (
    MaLoaiPhong VARCHAR (10) NOT NULL,
    MaDichVu    VARCHAR (10) NOT NULL,
    CONSTRAINT PK_LOAIPHONG_DICHVU PRIMARY KEY (MaLoaiPhong, MaDichVu),
    CONSTRAINT FK_LPDV_LOAIPHONG FOREIGN KEY (MaLoaiPhong) REFERENCES LOAIPHONG (MaLoaiPhong),
    CONSTRAINT FK_LPDV_DICHVU FOREIGN KEY (MaDichVu) REFERENCES DICHVU (MaDichVu)
);


GO
-- 4. TẠO CÁC BẢNG ĐẶT PHÒNG, HÓA ĐƠN & THANH TOÁN
-- BẢNG 9: BOOKING
CREATE TABLE BOOKING (
    MaBooking         VARCHAR (10)    NOT NULL,
    MaKH              VARCHAR (10)    NOT NULL,
    MaNV              VARCHAR (10)    NULL,
    NgayDat           DATETIME        CONSTRAINT DF_BOOKING_NgayDat DEFAULT GETDATE() NOT NULL,
    TrangThai         VARCHAR (20)    CONSTRAINT DF_BOOKING_TrangThai DEFAULT 'DaXacNhan' NOT NULL,
    ChiPhiDuKien      DECIMAL (12, 2) CONSTRAINT DF_BOOKING_ChiPhiDuKien DEFAULT 0 NOT NULL,
    PhuongPhapBooking VARCHAR (10)    NOT NULL,
    ThoiDiemHuy       DATETIME        NULL,
    PhiHuy            DECIMAL (12, 2) CONSTRAINT DF_BOOKING_PhiHuy DEFAULT 0 NULL,
    CONSTRAINT PK_BOOKING PRIMARY KEY (MaBooking),
    CONSTRAINT FK_BOOKING_KHACHHANG FOREIGN KEY (MaKH) REFERENCES KHACHHANG (MaKH),
    CONSTRAINT FK_BOOKING_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN (MaNV),
    CONSTRAINT CK_BOOKING_TrangThai CHECK (TrangThai IN ('DaXacNhan', 'DaCheckIn', 'DaCheckOut', 'DaHuy')),
    CONSTRAINT CK_BOOKING_PhuongPhap CHECK (PhuongPhapBooking IN ('Online', 'Offline')),
    CONSTRAINT CK_BOOKING_ChiPhiDuKien CHECK (ChiPhiDuKien >= 0),
    CONSTRAINT CK_BOOKING_PhiHuy CHECK (PhiHuy IS NULL
                                        OR PhiHuy >= 0)
);


GO
-- BẢNG 10: BOOKING_PHONG
CREATE TABLE BOOKING_PHONG (
    MaBooking          VARCHAR (10)    NOT NULL,
    MaPhong            VARCHAR (10)    NOT NULL,
    DonGiaPhong        DECIMAL (12, 2) NOT NULL,
    NgayNhanDuKien     DATE            NOT NULL,
    NgayTraDuKien      DATE            NOT NULL,
    NgayCheckInThucTe  DATETIME        NULL,
    NgayCheckOutThucTe DATETIME        NULL,
    CONSTRAINT PK_BOOKING_PHONG PRIMARY KEY (MaBooking, MaPhong),
    CONSTRAINT FK_BP_BOOKING FOREIGN KEY (MaBooking) REFERENCES BOOKING (MaBooking),
    CONSTRAINT FK_BP_PHONG FOREIGN KEY (MaPhong) REFERENCES PHONG (MaPhong),
    CONSTRAINT CK_BOOKING_PHONG_DonGia CHECK (DonGiaPhong >= 0),
    CONSTRAINT CK_BOOKING_PHONG_NgayLuuTru CHECK (NgayTraDuKien > NgayNhanDuKien),
    CONSTRAINT CK_BOOKING_PHONG_ThoiGianThucTe CHECK ((NgayCheckInThucTe IS NULL)
                                                      OR (NgayCheckOutThucTe IS NULL)
                                                      OR (NgayCheckOutThucTe >= NgayCheckInThucTe))
);


GO
-- BẢNG 11: BOOKING_DICHVU
CREATE TABLE BOOKING_DICHVU (
    MaBookingDichVu VARCHAR (10)    NOT NULL,
    MaBooking       VARCHAR (10)    NOT NULL,
    MaPhong         VARCHAR (10)    NULL,
    MaDichVu        VARCHAR (10)    NOT NULL,
    DonGia          DECIMAL (12, 2) NOT NULL,
    SoLuong         INT             CONSTRAINT DF_BDV_SoLuong DEFAULT 1 NOT NULL,
    ThoiDiemThem    DATETIME        CONSTRAINT DF_BDV_ThoiDiem DEFAULT GETDATE() NOT NULL,
    NguoiThem       VARCHAR (20)    NOT NULL,
    MaNV            VARCHAR (10)    NULL,
    CONSTRAINT PK_BOOKING_DICHVU PRIMARY KEY (MaBookingDichVu),
    CONSTRAINT FK_BDV_BOOKING_PHONG FOREIGN KEY (MaBooking, MaPhong) REFERENCES BOOKING_PHONG (MaBooking, MaPhong),
    CONSTRAINT FK_BDV_BOOKING FOREIGN KEY (MaBooking) REFERENCES BOOKING (MaBooking),
    CONSTRAINT FK_BDV_DICHVU FOREIGN KEY (MaDichVu) REFERENCES DICHVU (MaDichVu),
    CONSTRAINT FK_BDV_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN (MaNV),
    CONSTRAINT CK_BDV_DonGia CHECK (DonGia >= 0),
    CONSTRAINT CK_BDV_SoLuong CHECK (SoLuong > 0),
    CONSTRAINT CK_BDV_NguoiThem CHECK (NguoiThem IN ('KhachHang', 'NhanVien'))
);


GO
-- BẢNG 12: HOADON (Mỗi Booking chỉ có duy nhất 1 Hóa đơn tổng - Phương án A)
CREATE TABLE HOADON (
    MaHoaDon         VARCHAR (10)    NOT NULL,
    MaBooking        VARCHAR (10)    NOT NULL,
    NgayLap          DATETIME        CONSTRAINT DF_HOADON_NgayLap DEFAULT GETDATE() NOT NULL,
    TongTienCuoiCung DECIMAL (12, 2) NULL,
    MaNV             VARCHAR (10)    NOT NULL,
    TrangThai        VARCHAR (20)    CONSTRAINT DF_HOADON_TrangThai DEFAULT 'ChuaThanhToan' NOT NULL,
    CONSTRAINT PK_HOADON PRIMARY KEY (MaHoaDon),
    CONSTRAINT UQ_HOADON_MaBooking UNIQUE (MaBooking),
    CONSTRAINT FK_HOADON_BOOKING FOREIGN KEY (MaBooking) REFERENCES BOOKING (MaBooking),
    CONSTRAINT FK_HOADON_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN (MaNV),
    CONSTRAINT CK_HOADON_TongTien CHECK (TongTienCuoiCung IS NULL
                                         OR TongTienCuoiCung >= 0),
    CONSTRAINT CK_HOADON_TrangThai CHECK (TrangThai IN ('ChuaThanhToan', 'MotPhan', 'DaThanhToanDu'))
);


GO
-- BẢNG 13: THANHTOAN (1 Hóa đơn có thể thanh toán nhiều đợt)
CREATE TABLE THANHTOAN (
    MaThanhToan         VARCHAR (10)    NOT NULL,
    MaHoaDon            VARCHAR (10)    NOT NULL,
    MaNV                VARCHAR (10)    NOT NULL,
    SoTien              DECIMAL (12, 2) NOT NULL,
    PhuongThucThanhToan VARCHAR (20)    NOT NULL,
    ThoiDiemThanhToan   DATETIME        CONSTRAINT DF_THANHTOAN_ThoiDiem DEFAULT GETDATE() NOT NULL,
    CONSTRAINT PK_THANHTOAN PRIMARY KEY (MaThanhToan),
    CONSTRAINT FK_THANHTOAN_HOADON FOREIGN KEY (MaHoaDon) REFERENCES HOADON (MaHoaDon),
    CONSTRAINT FK_THANHTOAN_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN (MaNV),
    CONSTRAINT CK_THANHTOAN_SoTien CHECK (SoTien > 0),
    CONSTRAINT CK_THANHTOAN_PhuongThuc CHECK (PhuongThucThanhToan IN ('TienMat', 'TheNganHang', 'ChuyenKhoan'))
);


GO
-- 5. TẠO CÁC BẢNG DỌN PHÒNG & XỬ LÝ HƯ HẠI
-- BẢNG 14: NHIEMVUDOPHONG
CREATE TABLE NHIEMVUDOPHONG (
    MaNhiemVu       VARCHAR (10) NOT NULL,
    MaPhong         VARCHAR (10) NOT NULL,
    MaNV            VARCHAR (10) NULL,
    ThoiGianNhan    DATETIME     NULL,
    ThoiGianBatDau  DATETIME     NULL,
    ThoiGianKetThuc DATETIME     NULL,
    TrangThai       VARCHAR (20) CONSTRAINT DF_NVDP_TrangThai DEFAULT 'ChoXuLy' NOT NULL,
    KetQua          VARCHAR (20) NULL,
    CONSTRAINT PK_NHIEMVUDOPHONG PRIMARY KEY (MaNhiemVu),
    CONSTRAINT FK_NVDP_PHONG FOREIGN KEY (MaPhong) REFERENCES PHONG (MaPhong),
    CONSTRAINT FK_NVDP_NHANVIEN FOREIGN KEY (MaNV) REFERENCES NHANVIEN (MaNV),
    CONSTRAINT CK_NVDP_TrangThai CHECK (TrangThai IN ('ChoXuLy', 'DangDon', 'HoanThanh')),
    CONSTRAINT CK_NVDP_KetQua CHECK (KetQua IS NULL
                                     OR KetQua IN ('KhongThietHai', 'CoThietHai'))
);


GO
-- BẢNG 15: LOAIHUHAI
CREATE TABLE LOAIHUHAI (
    MaLoaiHuHai  VARCHAR (10)   NOT NULL,
    TenLoaiHuHai NVARCHAR (100) NOT NULL,
    MoTa         NVARCHAR (300) NULL,
    CONSTRAINT PK_LOAIHUHAI PRIMARY KEY (MaLoaiHuHai),
    CONSTRAINT UQ_LOAIHUHAI_TenLoaiHuHai UNIQUE (TenLoaiHuHai)
);


GO
-- BẢNG 16: BAOCAOHUHAI (Đã chuẩn hóa 3NF - loại bỏ MaPhong dư thừa)
CREATE TABLE BAOCAOHUHAI (
    MaBaoCao        VARCHAR (10)   NOT NULL,
    MaNhiemVu       VARCHAR (10)   NOT NULL,
    NgayPhatHien    DATETIME       CONSTRAINT DF_BCHH_NgayPhatHien DEFAULT GETDATE() NOT NULL,
    MoTa            NVARCHAR (500) NULL,
    TrangThai       VARCHAR (20)   CONSTRAINT DF_BCHH_TrangThai DEFAULT 'ChoXuLy' NOT NULL,
    ThoiDiemXacNhan DATETIME       NULL,
    CONSTRAINT PK_BAOCAOHUHAI PRIMARY KEY (MaBaoCao),
    CONSTRAINT FK_BCHH_NHIEMVUDOPHONG FOREIGN KEY (MaNhiemVu) REFERENCES NHIEMVUDOPHONG (MaNhiemVu),
    CONSTRAINT CK_BCHH_TrangThai CHECK (TrangThai IN ('ChoXuLy', 'DaKhacPhuc'))
);


GO
-- BẢNG 17: CHITIETBAOCAOHUHAI
CREATE TABLE CHITIETBAOCAOHUHAI (
    MaBaoCao    VARCHAR (10)   NOT NULL,
    MaLoaiHuHai VARCHAR (10)   NOT NULL,
    MoTaChiTiet NVARCHAR (500) NULL,
    CONSTRAINT PK_CHITIETBAOCAOHUHAI PRIMARY KEY (MaBaoCao, MaLoaiHuHai),
    CONSTRAINT FK_CTBCHH_BAOCAOHUHAI FOREIGN KEY (MaBaoCao) REFERENCES BAOCAOHUHAI (MaBaoCao),
    CONSTRAINT FK_CTBCHH_LOAIHUHAI FOREIGN KEY (MaLoaiHuHai) REFERENCES LOAIHUHAI (MaLoaiHuHai)
);


GO
-- ============================================================================
-- PHẦN 2: NẠP DỮ LIỆU MẪU (DATA SEEDING SCRIPT)
-- ============================================================================
-- 1. NẠP VAITRO
INSERT  INTO VAITRO (
    MaVaiTro,
    TenVaiTro
)
VALUES             ('VT01', N'Guest'),
('VT02', N'Receptionist'),
('VT03', N'HouseKeeper'),
('VT04', N'Manager');


GO
-- 2. NẠP TAIKHOAN (10 Tài khoản: 5 Khách hàng + 2 Lễ tân + 2 Buồng phòng + 1 Quản lý)
-- Mật khẩu tạm thời để dạng thô '1234' phục vụ kiểm thử thủ công
INSERT  INTO TAIKHOAN (
    MaTaiKhoan,
    TenDangNhap,
    MatKhau,
    MaVaiTro,
    TrangThai
)
VALUES               ('TK_G01', 'an.nguyen@gmail.com', '1234', 'VT01', 'Active'),
('TK_G02', 'mai.tran@gmail.com', '1234', 'VT01', 'Active'),
('TK_G03', 'hung.le@gmail.com', '1234', 'VT01', 'Active'),
('TK_G04', 'thao.pham@gmail.com', '1234', 'VT01', 'Active'),
('TK_G05', 'tuan.hoang@gmail.com', '1234', 'VT01', 'Active'),
('TK_E01', 'huong.reception', '1234', 'VT02', 'Active'),
('TK_E02', 'khoa.reception', '1234', 'VT02', 'Active'),
('TK_E03', 'nhung.housekeeper', '1234', 'VT03', 'Active'),
('TK_E04', 'binh.housekeeper', '1234', 'VT03', 'Active'),
('TK_E05', 'vinh.manager', '1234', 'VT04', 'Active');


GO
-- 3. NẠP KHACHHANG
INSERT  INTO KHACHHANG (
    MaKH,
    MaTaiKhoan,
    HoTen,
    Email,
    SoDT,
    CCCD
)
VALUES                ('KH001', 'TK_G01', N'Nguyễn Văn An', 'an.nguyen@gmail.com', '0901111111', '079200012345'),
('KH002', 'TK_G02', N'Trần Thị Bích Mai', 'mai.tran@gmail.com', '0912222222', '079300023456'),
('KH003', 'TK_G03', N'Lê Quốc Hùng', 'hung.le@gmail.com', '0923333333', '079400034567'),
('KH004', 'TK_G04', N'Phạm Thanh Thảo', 'thao.pham@gmail.com', '0934444444', '079500045678'),
('KH005', 'TK_G05', N'Hoàng Minh Tuấn', 'tuan.hoang@gmail.com', '0945000001', '079600056789');


GO
-- 4. NẠP NHANVIEN
INSERT  INTO NHANVIEN (
    MaNV,
    MaTaiKhoan,
    HoTen,
    Email,
    SoDienThoai,
    NgayVaoLam,
    NgayNghiLam,
    TrangThaiLamViec
)
VALUES               ('NV001', 'TK_E01', N'Nguyễn Thị Hương', 'huong.nv@hotel.com', '0951111111', '2025-01-10', NULL, 'DangLam'),
('NV002', 'TK_E02', N'Trần Văn Khoa', 'khoa.tv@hotel.com', '0962222222', '2025-02-15', NULL, 'DangLam'),
('NV003', 'TK_E03', N'Lê Thị Hồng Nhung', 'nhung.lth@hotel.com', '0973333333', '2025-03-20', NULL, 'DangLam'),
('NV004', 'TK_E04', N'Phan Thanh Bình', 'binh.pt@hotel.com', '0984444444', '2025-04-05', NULL, 'DangLam'),
('NV005', 'TK_E05', N'Đỗ Quang Vinh', 'vinh.dq@hotel.com', '0995555555', '2025-05-01', NULL, 'DangLam');


GO
-- 5. NẠP LOAIPHONG
INSERT  INTO LOAIPHONG (
    MaLoaiPhong,
    TenLoaiPhong,
    DienTich,
    LoaiGiuong,
    SoNguoiToiDa,
    GiaPhong,
    TrangThai
)
VALUES                ('LP01', N'Standard Single', 22.50, N'1 Giường đơn', 1, 450000.00, 'ApDung'),
('LP02', N'Standard Double', 30.00, N'1 Giường đôi', 2, 650000.00, 'ApDung'),
('LP03', N'Deluxe King', 42.00, N'1 Giường King', 2, 1100000.00, 'ApDung'),
('LP04', N'Family Suite', 65.00, N'2 Giường đôi', 4, 1850000.00, 'ApDung'),
('LP05', N'Presidential', 120.00, N'2 Giường King VIP', 4, 4500000.00, 'ApDung');


GO
-- 6. NẠP PHONG (12 phòng, phân bổ đầy đủ 6 trạng thái)
INSERT  INTO PHONG (
    MaPhong,
    SoPhong,
    MaLoaiPhong,
    TrangThai,
    MoTa
)
VALUES            ('P101', '101', 'LP01', 'Available', N'Phòng tầng 1, hướng vườn, thoáng mát.'),
('P102', '102', 'LP01', 'Dirty', N'Khách vừa check-out lúc 11:30, cần dọn dẹp.'),
('P103', '103', 'LP02', 'Available', N'Phòng tầng 1, gần sảnh lễ tân.'),
('P201', '201', 'LP02', 'Occupied', N'Khách KH001 đang lưu trú.'),
('P202', '202', 'LP03', 'Booked', N'Đã nhận cọc, giữ phòng cho khách ngày mai.'),
('P203', '203', 'LP03', 'Available', N'Phòng tầng 2, ban công nhìn ra hồ bơi.'),
('P301', '301', 'LP04', 'Cleaning', N'Nhân viên Nhung đang tiến hành vệ sinh.'),
('P302', '302', 'LP04', 'Occupied', N'Khách gia đình KH002 đang ở.'),
('P303', '303', 'LP04', 'Available', N'Phòng gia đình đầy đủ tiện nghi bếp nhỏ.'),
('P401', '401', 'LP05', 'Damaged', N'Gương phòng tắm bị nứt vỡ, đang chờ kỹ thuật thay thế.'),
('P402', '402', 'LP05', 'Available', N'Phòng tổng thống VIP, nội thất dát vàng phong cách Pháp.'),
('P403', '403', 'LP03', 'Available', N'Phòng tầng cao ngắm cảnh thành phố ban đêm.');


GO
-- 7. NẠP DICHVU
INSERT  INTO DICHVU (
    MaDichVu,
    TenDichVu,
    MoTa,
    DonGia,
    TrangThai
)
VALUES             ('DV01', N'Ăn sáng Buffet', N'Buffet sáng món Á - Âu từ 6:00 đến 9:30', 150000.00, 'ApDung'),
('DV02', N'Giặt ủi quần áo', N'Giặt sấy ủi lấy trong ngày (tính theo kg)', 60000.00, 'ApDung'),
('DV03', N'Đưa đón sân bay', N'Xe sedan 4 chỗ đời mới đưa/đón Tân Sơn Nhất', 350000.00, 'ApDung'),
('DV04', N'Massage & Spa Body', N'Gói trị liệu toàn thân tinh dầu thảo mộc 60 phút', 450000.00, 'ApDung'),
('DV05', N'Nước uống Mini Bar', N'Lon nước ngọt/nước ép trái cây các loại', 30000.00, 'ApDung'),
('DV06', N'Thuê xe máy tự lái', N'Xe tay ga Honda Air Blade theo ngày (24h)', 180000.00, 'ApDung');


GO
-- 8. NẠP LOAIPHONG_DICHVU (Tiện ích đi kèm miễn phí theo loại phòng)
INSERT  INTO LOAIPHONG_DICHVU (
    MaLoaiPhong,
    MaDichVu
)
VALUES                       ('LP03', 'DV01'), -- Deluxe tặng Buffet sáng
('LP04', 'DV01'), -- Family Suite tặng Buffet sáng
('LP05', 'DV01'), -- Presidential tặng Buffet sáng
('LP05', 'DV03'), -- Presidential miễn phí xe đưa đón sân bay
('LP05', 'DV04'); -- Presidential tặng 1 suất Spa


GO
-- 9. NẠP BOOKING (6 đơn đặt phòng đại diện đủ 4 trạng thái)
INSERT  INTO BOOKING (
    MaBooking,
    MaKH,
    MaNV,
    NgayDat,
    TrangThai,
    ChiPhiDuKien,
    PhuongPhapBooking,
    ThoiDiemHuy,
    PhiHuy
)
VALUES              -- BK001: Đang ở (DaCheckIn)
('BK001', 'KH001', NULL, '2026-09-25 08:30:00', 'DaCheckIn', 1300000.00, 'Online', NULL, NULL),
-- BK002: Đang ở (DaCheckIn)
('BK002', 'KH002', 'NV001', '2026-09-26 14:00:00', 'DaCheckIn', 3700000.00, 'Offline', NULL, NULL),
-- BK003: Đã đặt trước, chưa check-in (DaXacNhan)
('BK003', 'KH003', NULL, '2026-09-27 10:15:00', 'DaXacNhan', 2200000.00, 'Online', NULL, NULL),
-- BK004: Đã hoàn tất trả phòng và thanh toán xong (DaCheckOut)
('BK004', 'KH004', 'NV002', '2026-09-20 09:00:00', 'DaCheckOut', 900000.00, 'Offline', NULL, NULL),
-- BK005: Khách hủy đặt phòng (DaHuy)
('BK005', 'KH005', NULL, '2026-09-22 11:00:00', 'DaHuy', 1100000.00, 'Online', '2026-09-23 09:00:00', 100000.00),
-- BK006: Lịch sử hoàn tất trả phòng tuần trước (DaCheckOut)
('BK006', 'KH001', 'NV001', '2026-09-15 13:00:00', 'DaCheckOut', 1100000.00, 'Offline', NULL, NULL);


GO
-- 10. NẠP BOOKING_PHONG
INSERT  INTO BOOKING_PHONG (
    MaBooking,
    MaPhong,
    DonGiaPhong,
    NgayNhanDuKien,
    NgayTraDuKien,
    NgayCheckInThucTe,
    NgayCheckOutThucTe
)
VALUES                    ('BK001', 'P201', 650000.00, '2026-09-26', '2026-09-28', '2026-09-26 14:15:00', NULL),
('BK002', 'P302', 1850000.00, '2026-09-27', '2026-09-29', '2026-09-27 13:45:00', NULL),
('BK003', 'P202', 1100000.00, '2026-09-29', '2026-10-01', NULL, NULL),
('BK004', 'P101', 450000.00, '2026-09-21', '2026-09-23', '2026-09-21 14:00:00', '2026-09-23 11:30:00'),
('BK005', 'P203', 1100000.00, '2026-09-25', '2026-09-26', NULL, NULL),
('BK006', 'P403', 1100000.00, '2026-09-16', '2026-09-17', '2026-09-16 14:00:00', '2026-09-17 11:00:00');


GO
-- 11. NẠP BOOKING_DICHVU (Dịch vụ gọi thêm trong đợt ở)
INSERT  INTO BOOKING_DICHVU (
    MaBookingDichVu,
    MaBooking,
    MaPhong,
    MaDichVu,
    DonGia,
    SoLuong,
    ThoiDiemThem,
    NguoiThem,
    MaNV
)
VALUES                     ('BDV01', 'BK001', 'P201', 'DV02', 60000.00, 2, '2026-09-26 16:00:00', 'NhanVien', 'NV001'), -- Giặt ủi 2kg cho phòng P201
('BDV02', 'BK001', 'P201', 'DV05', 30000.00, 4, '2026-09-27 09:30:00', 'KhachHang', NULL), -- 4 lon nước ngọt phòng P201
('BDV03', 'BK002', 'P302', 'DV04', 450000.00, 2, '2026-09-27 15:00:00', 'KhachHang', NULL), -- 2 vé Spa phòng P302
('BDV04', 'BK004', 'P101', 'DV01', 150000.00, 2, '2026-09-22 07:30:00', 'NhanVien', 'NV002'); -- 2 suất Buffet phòng P101


GO
-- 12. NẠP HOADON (Mỗi Booking đúng 1 Hóa đơn)
INSERT  INTO HOADON (
    MaHoaDon,
    MaBooking,
    NgayLap,
    TongTienCuoiCung,
    MaNV,
    TrangThai
)
VALUES             -- HD001 cho BK001: Đang ở, chưa tính xong tổng cuối
('HD001', 'BK001', '2026-09-26 14:15:00', NULL, 'NV001', 'ChuaThanhToan'),
-- HD002 cho BK002: Đang ở, khách đã cọc trước 1 phần
('HD002', 'BK002', '2026-09-27 13:45:00', NULL, 'NV001', 'MotPhan'),
-- HD003 cho BK003: Đã cọc đủ tiền phòng trước
('HD003', 'BK003', '2026-09-27 10:30:00', 2200000.00, 'NV002', 'DaThanhToanDu'),
-- HD004 cho BK004: Đã chốt hóa đơn và thanh toán hết lúc check-out
('HD004', 'BK004', '2026-09-23 11:30:00', 1200000.00, 'NV002', 'DaThanhToanDu'),
-- HD006 cho BK006: Lịch sử tuần trước đã thanh toán đủ
('HD006', 'BK006', '2026-09-17 11:00:00', 1100000.00, 'NV001', 'DaThanhToanDu');


GO
-- 13. NẠP THANHTOAN (Lịch sử từng lần thu tiền của hóa đơn)
INSERT  INTO THANHTOAN (
    MaThanhToan,
    MaHoaDon,
    MaNV,
    SoTien,
    PhuongThucThanhToan,
    ThoiDiemThanhToan
)
VALUES                -- Khách BK002 cọc trước 2 triệu chuyển khoản
('TT001', 'HD002', 'NV001', 2000000.00, 'ChuyenKhoan', '2026-09-27 14:00:00'),
-- Khách BK003 thanh toán đủ 2.2 triệu qua thẻ ngân hàng
('TT002', 'HD003', 'NV002', 2200000.00, 'TheNganHang', '2026-09-27 10:35:00'),
-- Khách BK004 thanh toán tiền mặt 1.2 triệu khi check-out
('TT003', 'HD004', 'NV002', 1200000.00, 'TienMat', '2026-09-23 11:35:00'),
-- Khách BK006 thanh toán chuyển khoản 1.1 triệu
('TT004', 'HD006', 'NV001', 1100000.00, 'ChuyenKhoan', '2026-09-17 11:05:00');


GO
-- 14. NẠP NHIEMVUDOPHONG (Phân công buồng phòng)
INSERT  INTO NHIEMVUDOPHONG (
    MaNhiemVu,
    MaPhong,
    MaNV,
    ThoiGianNhan,
    ThoiGianBatDau,
    ThoiGianKetThuc,
    TrangThai,
    KetQua
)
VALUES                     -- P102: Khách vừa trả phòng lúc 11:30, đã phân công nhân viên Bình nhưng chưa dọn (ChoXuLy)
('NVDP01', 'P102', 'NV004', '2026-09-27 11:30:00', NULL, NULL, 'ChoXuLy', NULL),
-- P301: Nhân viên Nhung đang tiến hành dọn dẹp
('NVDP02', 'P301', 'NV003', '2026-09-27 08:30:00', '2026-09-27 08:45:00', NULL, 'DangDon', NULL),
-- P101: Đã dọn xong sạch sẽ không hư hại
('NVDP03', 'P101', 'NV003', '2026-09-23 11:45:00', '2026-09-23 12:00:00', '2026-09-23 13:00:00', 'HoanThanh', 'KhongThietHai'),
-- P401: Dọn xong nhưng phát hiện gương phòng tắm bị vỡ
('NVDP04', 'P401', 'NV004', '2026-09-20 09:00:00', '2026-09-20 09:15:00', '2026-09-20 10:15:00', 'HoanThanh', 'CoThietHai');


GO
-- 15. NẠP LOAIHUHAI (Danh mục loại hư hỏng)
INSERT  INTO LOAIHUHAI (
    MaLoaiHuHai,
    TenLoaiHuHai,
    MoTa
)
VALUES                ('LHH01', N'Vỡ kính / Gương / Thủy tinh', N'Bể gương soi, mặt kính bàn trà, ly tách thủy tinh.'),
('LHH02', N'Hỏng máy lạnh / Điều hòa', N'Điều hòa không lạnh, chảy nước hoặc kêu to bất thường.'),
('LHH03', N'Rách ga / Nệm / Rèm cửa', N'Cháy thủng do tàn thuốc, rách vải nội thất.'),
('LHH04', N'Hỏng khóa cửa / Thẻ từ', N'Khóa thông minh không nhận thẻ từ, tay nắm bị kẹt.'),
('LHH05', N'Nghẹt bồn cầu / Rò rỉ nước', N'Tắc nghẽn đường ống dẫn thoát nước vệ sinh.');


GO
-- 16. NẠP BAOCAOHUHAI & CHITIETBAOCAOHUHAI (Biên bản cho ca dọn phòng NVDP04)
INSERT  INTO BAOCAOHUHAI (
    MaBaoCao,
    MaNhiemVu,
    NgayPhatHien,
    MoTa,
    TrangThai,
    ThoiDiemXacNhan
)
VALUES                  ('BC001', 'NVDP04', '2026-09-20 10:20:00', N'Phát hiện trong lúc dọn phòng sau khi khách rời đi.', 'ChoXuLy', NULL);


GO
INSERT  INTO CHITIETBAOCAOHUHAI (
    MaBaoCao,
    MaLoaiHuHai,
    MoTaChiTiet
)
VALUES                         ('BC001', 'LHH01', N'Gương treo tường bồn rửa mặt bị nứt đường chéo dài 40cm góc dưới bên trái.');


GO
-- ============================================================================
-- PHẦN 3: KIỂM TRA SỐ LƯỢNG BẢN GHI SAU KHI NẠP
-- ============================================================================
SELECT 'VAITRO' AS [Bảng],
       COUNT(*) AS [Số bản ghi]
FROM   VAITRO
UNION ALL
SELECT 'TAIKHOAN',
       COUNT(*)
FROM   TAIKHOAN
UNION ALL
SELECT 'KHACHHANG',
       COUNT(*)
FROM   KHACHHANG
UNION ALL
SELECT 'NHANVIEN',
       COUNT(*)
FROM   NHANVIEN
UNION ALL
SELECT 'LOAIPHONG',
       COUNT(*)
FROM   LOAIPHONG
UNION ALL
SELECT 'PHONG',
       COUNT(*)
FROM   PHONG
UNION ALL
SELECT 'DICHVU',
       COUNT(*)
FROM   DICHVU
UNION ALL
SELECT 'LOAIPHONG_DICHVU',
       COUNT(*)
FROM   LOAIPHONG_DICHVU
UNION ALL
SELECT 'BOOKING',
       COUNT(*)
FROM   BOOKING
UNION ALL
SELECT 'BOOKING_PHONG',
       COUNT(*)
FROM   BOOKING_PHONG
UNION ALL
SELECT 'BOOKING_DICHVU',
       COUNT(*)
FROM   BOOKING_DICHVU
UNION ALL
SELECT 'HOADON',
       COUNT(*)
FROM   HOADON
UNION ALL
SELECT 'THANHTOAN',
       COUNT(*)
FROM   THANHTOAN
UNION ALL
SELECT 'NHIEMVUDOPHONG',
       COUNT(*)
FROM   NHIEMVUDOPHONG
UNION ALL
SELECT 'LOAIHUHAI',
       COUNT(*)
FROM   LOAIHUHAI
UNION ALL
SELECT 'BAOCAOHUHAI',
       COUNT(*)
FROM   BAOCAOHUHAI
UNION ALL
SELECT 'CHITIETBAOCAOHUHAI',
       COUNT(*)
FROM   CHITIETBAOCAOHUHAI;
GO

-- ============================================================================
-- PHẦN 4: HỆ THỐNG 7 TRIGGER TỰ ĐỘNG HÓA VÀ RÀNG BUỘC TOÀN VẸN DỮ LIỆU
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Trigger 1: Chống đặt trùng phòng và chặn đặt phòng bẩn / đang dọn / hư hại
-- Bảng: BOOKING_PHONG | Sự kiện: AFTER INSERT, UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_Check_XungDotDatPhong
ON BOOKING_PHONG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ kiểm tra khi thêm mới dòng đặt phòng hoặc khi thay đổi phòng / ngày lưu trú dự kiến
    IF NOT EXISTS (SELECT 1 FROM deleted) 
       OR UPDATE(MaPhong) 
       OR UPDATE(NgayNhanDuKien) 
       OR UPDATE(NgayTraDuKien)
    BEGIN
        -- 1. Chặn đặt các phòng đang bẩn (Dirty), đang dọn (Cleaning) hoặc đang hư hại (Damaged)
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN PHONG p ON i.MaPhong = p.MaPhong
            WHERE p.TrangThai IN ('Dirty', 'Cleaning', 'Damaged')
        )
        BEGIN
            RAISERROR(N'Lỗi nghiệp vụ: Phòng đang trong quá trình dọn dẹp (Dirty/Cleaning) hoặc bị hư hỏng (Damaged), không thể nhận đặt phòng!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- 2. Kiểm tra giao thoa thời gian giữa booking mới và booking cũ của cùng 1 phòng
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN BOOKING b_new ON i.MaBooking = b_new.MaBooking
            INNER JOIN BOOKING_PHONG bp_old ON i.MaPhong = bp_old.MaPhong AND i.MaBooking <> bp_old.MaBooking
            INNER JOIN BOOKING b_old ON bp_old.MaBooking = b_old.MaBooking
            WHERE b_new.TrangThai IN ('DaXacNhan', 'DaCheckIn')
              AND b_old.TrangThai IN ('DaXacNhan', 'DaCheckIn')
              AND NOT (i.NgayTraDuKien <= bp_old.NgayNhanDuKien OR i.NgayNhanDuKien >= bp_old.NgayTraDuKien)
        )
        BEGIN
            RAISERROR(N'Lỗi nghiệp vụ: Phòng này đã có khách đặt trong khoảng thời gian yêu cầu!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 2: Chặn hủy đơn đặt phòng sau khi khách đã Check-in
-- Bảng: BOOKING | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_ChanHuyBookingSaiChinhSach
ON BOOKING
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThai)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN deleted d ON i.MaBooking = d.MaBooking
            INNER JOIN BOOKING_PHONG bp ON i.MaBooking = bp.MaBooking
            WHERE i.TrangThai = 'DaHuy'
              AND (d.TrangThai = 'DaCheckIn' OR bp.NgayCheckInThucTe IS NOT NULL)
        )
        BEGIN
            RAISERROR(N'Lỗi nghiệp vụ: Không thể hủy đơn đặt phòng khi khách đã Check-in lưu trú!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 3: Tự động đổi trạng thái phòng sang Occupied khi làm thủ tục Check-in
-- Bảng: BOOKING_PHONG | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_DongBoTrangThaiPhongCheckIn
ON BOOKING_PHONG
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(NgayCheckInThucTe)
    BEGIN
        UPDATE p
        SET p.TrangThai = 'Occupied'
        FROM PHONG p
        INNER JOIN inserted i ON p.MaPhong = i.MaPhong
        INNER JOIN deleted d ON i.MaBooking = d.MaBooking AND i.MaPhong = d.MaPhong
        WHERE d.NgayCheckInThucTe IS NULL AND i.NgayCheckInThucTe IS NOT NULL AND i.NgayCheckOutThucTe IS NULL;
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 4: Tự động đổi phòng sang Dirty và tạo việc dọn dẹp khi Check-out
-- Bảng: BOOKING_PHONG | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_TuDongDonPhongSauCheckOut
ON BOOKING_PHONG
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(NgayCheckOutThucTe)
    BEGIN
        -- 1. Đổi trạng thái phòng sang 'Dirty' khi chuyển từ chưa check-out sang đã check-out
        UPDATE p
        SET p.TrangThai = 'Dirty'
        FROM PHONG p
        INNER JOIN inserted i ON p.MaPhong = i.MaPhong
        INNER JOIN deleted d ON i.MaBooking = d.MaBooking AND i.MaPhong = d.MaPhong
        WHERE d.NgayCheckOutThucTe IS NULL AND i.NgayCheckOutThucTe IS NOT NULL;

        -- 2. Tự động tạo nhiệm vụ dọn phòng nếu chưa có nhiệm vụ nào đang chờ xử lý
        INSERT INTO NHIEMVUDOPHONG (MaNhiemVu, MaPhong, MaNV, ThoiGianNhan, TrangThai)
        SELECT 
            'NV' + SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8),
            i.MaPhong,
            NULL,
            GETDATE(),
            'ChoXuLy'
        FROM inserted i
        INNER JOIN deleted d ON i.MaBooking = d.MaBooking AND i.MaPhong = d.MaPhong
        WHERE d.NgayCheckOutThucTe IS NULL AND i.NgayCheckOutThucTe IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM NHIEMVUDOPHONG 
              WHERE MaPhong = i.MaPhong AND TrangThai IN ('ChoXuLy', 'DangDon')
          );
    END
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 5: Tự động sinh Hóa đơn tổng duy nhất khi tạo Booking (Phương án A)
-- Bảng: BOOKING | Sự kiện: AFTER INSERT
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_TuDongTaoHoaDonKhiDatPhong
ON BOOKING
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO HOADON (MaHoaDon, MaBooking, NgayLap, TongTienCuoiCung, MaNV, TrangThai)
    SELECT 
        'HD_' + SUBSTRING(i.MaBooking, 4, 7),
        i.MaBooking,
        GETDATE(),
        NULL,
        ISNULL(i.MaNV, 'NV001'),
        'ChuaThanhToan'
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM HOADON WHERE MaBooking = i.MaBooking);
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 6: Tự động đối soát tiền nạp và cập nhật trạng thái thanh toán hóa đơn
-- Bảng: THANHTOAN | Sự kiện: AFTER INSERT, UPDATE, DELETE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_CapNhatTrangThaiHoaDon
ON THANHTOAN
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HoaDonList TABLE (MaHoaDon VARCHAR(10));
    INSERT INTO @HoaDonList SELECT DISTINCT MaHoaDon FROM inserted
    UNION SELECT DISTINCT MaHoaDon FROM deleted;

    UPDATE hd
    SET hd.TrangThai = 
        CASE 
            WHEN ISNULL(DaThu.TongThu, 0) >= ISNULL(hd.TongTienCuoiCung, b.ChiPhiDuKien) AND ISNULL(DaThu.TongThu, 0) > 0
                THEN 'DaThanhToanDu'
            WHEN ISNULL(DaThu.TongThu, 0) > 0
                THEN 'MotPhan'
            ELSE 'ChuaThanhToan'
        END
    FROM HOADON hd
    INNER JOIN BOOKING b ON hd.MaBooking = b.MaBooking
    INNER JOIN @HoaDonList hl ON hd.MaHoaDon = hl.MaHoaDon
    OUTER APPLY (
        SELECT SUM(SoTien) AS TongThu
        FROM THANHTOAN
        WHERE MaHoaDon = hd.MaHoaDon
    ) DaThu;
END;
GO

-- ----------------------------------------------------------------------------
-- Trigger 7: Tự động khóa tài khoản khi nhân viên nghỉ việc
-- Bảng: NHANVIEN | Sự kiện: AFTER UPDATE
-- ----------------------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_KhoaTaiKhoanKhiNghiViec
ON NHANVIEN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(TrangThaiLamViec) OR UPDATE(NgayNghiLam)
    BEGIN
        UPDATE tk
        SET tk.TrangThai = 'Locked'
        FROM TAIKHOAN tk
        INNER JOIN inserted i ON tk.MaTaiKhoan = i.MaTaiKhoan
        WHERE i.TrangThaiLamViec = 'NghiViec' 
           OR (i.NgayNghiLam IS NOT NULL AND i.NgayNghiLam <= CAST(GETDATE() AS DATE));
    END
END;
GO

-- ============================================================================
-- PHẦN 5: HỆ THỐNG 7 VIEW PHỤC VỤ GIAO DIỆN & BÁO CÁO QUẢN TRỊ
-- ============================================================================

-- ----------------------------------------------------------------------------
-- View 1: Danh sách phòng trống khả dụng (Màn hình Booking Online & Quầy Lễ tân)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_DanhSachPhongKhaDung
AS
SELECT 
    p.MaPhong,
    p.SoPhong,
    lp.MaLoaiPhong,
    lp.TenLoaiPhong,
    lp.DienTich,
    lp.LoaiGiuong,
    lp.SoNguoiToiDa,
    lp.GiaPhong,
    p.MoTa AS MoTaPhong
FROM PHONG p
INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
WHERE p.TrangThai = 'Available' AND lp.TrangThai = 'ApDung';
GO

-- ----------------------------------------------------------------------------
-- View 2: Danh sách phòng cần dọn dẹp hàng ngày (Màn hình phân công Housekeeper)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_DanhSachPhongCanDonDep
AS
SELECT 
    nvdp.MaNhiemVu,
    p.MaPhong,
    p.SoPhong,
    lp.TenLoaiPhong,
    p.TrangThai AS TrangThaiPhong,
    nvdp.TrangThai AS TrangThaiNhiemVu,
    nv.MaNV AS MaNhanVienDon,
    nv.HoTen AS TenNhanVienDon,
    nvdp.ThoiGianNhan,
    nvdp.ThoiGianBatDau
FROM NHIEMVUDOPHONG nvdp
INNER JOIN PHONG p ON nvdp.MaPhong = p.MaPhong
INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
LEFT JOIN NHANVIEN nv ON nvdp.MaNV = nv.MaNV
WHERE nvdp.TrangThai IN ('ChoXuLy', 'DangDon');
GO

-- ----------------------------------------------------------------------------
-- View 3: Danh sách phòng hư hại chờ bảo trì (Màn hình điều phối Quản lý)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_DanhSachPhongHuHaiCanBaoTri
AS
SELECT 
    bc.MaBaoCao,
    p.MaPhong,
    p.SoPhong,
    lp.TenLoaiPhong,
    bc.NgayPhatHien,
    lhh.TenLoaiHuHai,
    ct.MoTaChiTiet,
    bc.TrangThai AS TrangThaiBaoCao,
    nv.HoTen AS NhanVienPhatHien
FROM BAOCAOHUHAI bc
INNER JOIN NHIEMVUDOPHONG nvdp ON bc.MaNhiemVu = nvdp.MaNhiemVu
INNER JOIN PHONG p ON nvdp.MaPhong = p.MaPhong
INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
INNER JOIN CHITIETBAOCAOHUHAI ct ON bc.MaBaoCao = ct.MaBaoCao
INNER JOIN LOAIHUHAI lhh ON ct.MaLoaiHuHai = lhh.MaLoaiHuHai
LEFT JOIN NHANVIEN nv ON nvdp.MaNV = nv.MaNV
WHERE bc.TrangThai = 'ChoXuLy';
GO

-- ----------------------------------------------------------------------------
-- View 4: Theo dõi công nợ và quyết toán hóa đơn (Màn hình Thu ngân / Lễ tân)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_CongNoHoaDonKhachHang
AS
SELECT 
    hd.MaHoaDon,
    b.MaBooking,
    kh.HoTen AS NguoiDaiDienBooking,
    kh.SoDT,
    hd.NgayLap,
    ISNULL(hd.TongTienCuoiCung, b.ChiPhiDuKien) AS TongTienPhaiTra,
    ISNULL(SUM(tt.SoTien), 0) AS DaThanhToan,
    (ISNULL(hd.TongTienCuoiCung, b.ChiPhiDuKien) - ISNULL(SUM(tt.SoTien), 0)) AS ConThieu,
    hd.TrangThai AS TrangThaiHoaDon
FROM HOADON hd
INNER JOIN BOOKING b ON hd.MaBooking = b.MaBooking
INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH
LEFT JOIN THANHTOAN tt ON hd.MaHoaDon = tt.MaHoaDon
GROUP BY hd.MaHoaDon, b.MaBooking, kh.HoTen, kh.SoDT, hd.NgayLap, hd.TongTienCuoiCung, b.ChiPhiDuKien, hd.TrangThai;
GO

-- ----------------------------------------------------------------------------
-- View 5: Báo cáo tài chính doanh thu tổng hợp theo tháng (Quản lý & Giám đốc)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_BaoCaoDoanhThuTheoThang
AS
SELECT 
    YEAR(tt.ThoiDiemThanhToan) AS Nam,
    MONTH(tt.ThoiDiemThanhToan) AS Thang,
    COUNT(DISTINCT tt.MaThanhToan) AS SoLuotGiaoDich,
    COUNT(DISTINCT hd.MaHoaDon) AS SoHoaDonDaThanhToan,
    SUM(tt.SoTien) AS TongDoanhThuThucThu
FROM THANHTOAN tt
INNER JOIN HOADON hd ON tt.MaHoaDon = hd.MaHoaDon
GROUP BY YEAR(tt.ThoiDiemThanhToan), MONTH(tt.ThoiDiemThanhToan);
GO

-- ----------------------------------------------------------------------------
-- View 6: Thống kê dịch vụ gia tăng được ưa chuộng (Bộ phận Kinh doanh)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_ThongKeDichVuBanChay
AS
SELECT 
    dv.MaDichVu,
    dv.TenDichVu,
    dv.DonGia AS DonGiaHienTai,
    ISNULL(SUM(bdv.SoLuong), 0) AS TongSoLuongSuDung,
    ISNULL(SUM(bdv.DonGia * bdv.SoLuong), 0) AS TongDoanhThuDichVu
FROM DICHVU dv
LEFT JOIN BOOKING_DICHVU bdv ON dv.MaDichVu = bdv.MaDichVu
GROUP BY dv.MaDichVu, dv.TenDichVu, dv.DonGia;
GO

-- ----------------------------------------------------------------------------
-- View 7: Báo cáo tỷ lệ công suất phòng (Dashboard Quản lý)
-- ----------------------------------------------------------------------------
CREATE OR ALTER VIEW v_TyLeLapDayPhong
AS
SELECT 
    COUNT(*) AS TongSoPhong,
    COUNT(CASE WHEN TrangThai = 'Occupied' THEN 1 END) AS SoPhongDangCoKhach,
    COUNT(CASE WHEN TrangThai = 'Available' THEN 1 END) AS SoPhongTrong,
    COUNT(CASE WHEN TrangThai IN ('Dirty', 'Cleaning') THEN 1 END) AS SoPhongDangDon,
    COUNT(CASE WHEN TrangThai = 'Damaged' THEN 1 END) AS SoPhongHuHai,
    ROUND(
        (COUNT(CASE WHEN TrangThai = 'Occupied' THEN 1 END) * 100.0) / NULLIF(COUNT(*), 0), 
        2
    ) AS TyLeLapDayPhanTram
FROM PHONG;
GO