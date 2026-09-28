-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: HỆ THỐNG VIEW (MÀN HÌNH HIỂN THỊ & BÁO CÁO QUẢN TRỊ)
-- ============================================================================

USE QuanLyKhachSan;
GO

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
