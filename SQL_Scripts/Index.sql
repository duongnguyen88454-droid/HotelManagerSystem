-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: HỆ THỐNG NON-CLUSTERED INDEX (TỐI ƯU HIỆU NĂNG TRUY VẤN)
-- ============================================================================

USE QuanLyKhachSan;
GO

-- ----------------------------------------------------------------------------
-- Index 1: Tối ưu tra cứu kiểm tra phòng trống & Chống Double-booking
-- Bảng: BOOKING_PHONG
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_BOOKING_PHONG_ThoiGian_MaPhong
ON BOOKING_PHONG (MaPhong, NgayNhanDuKien, NgayTraDuKien);
GO

-- ----------------------------------------------------------------------------
-- Index 2: Tối ưu tra cứu lịch sử đơn đặt phòng của khách hàng
-- Bảng: BOOKING
-- Kỹ thuật Covering Index: INCLUDE (NgayDat, ChiPhiDuKien)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_BOOKING_MaKH_TrangThai
ON BOOKING (MaKH, TrangThai)
INCLUDE (NgayDat, ChiPhiDuKien);
GO

-- ----------------------------------------------------------------------------
-- Index 3: Tối ưu tìm kiếm khách hàng tại quầy Lễ tân theo SĐT / CCCD
-- Bảng: KHACHHANG
-- Kỹ thuật Covering Index: INCLUDE (HoTen, Email)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_KHACHHANG_SoDT_CCCD
ON KHACHHANG (SoDT, CCCD)
INCLUDE (HoTen, Email);
GO

-- ----------------------------------------------------------------------------
-- Index 4: Tối ưu tải sơ đồ trạng thái phòng trên Dashboard Quản lý / Lễ tân
-- Bảng: PHONG
-- Kỹ thuật Covering Index: INCLUDE (SoPhong)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_PHONG_TrangThai_MaLoaiPhong
ON PHONG (TrangThai, MaLoaiPhong)
INCLUDE (SoPhong);
GO

-- ----------------------------------------------------------------------------
-- Index 5: Tối ưu tổng hợp doanh thu tài chính theo thời gian
-- Bảng: THANHTOAN
-- Kỹ thuật Covering Index: INCLUDE (SoTien, PhuongThucThanhToan, MaHoaDon)
-- ----------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_THANHTOAN_ThoiDiemThanhToan
ON THANHTOAN (ThoiDiemThanhToan)
INCLUDE (SoTien, PhuongThucThanhToan, MaHoaDon);
GO
