-- ============================================================================
-- ĐỒ ÁN MÔN HỌC: HỆ QUẢN TRỊ CƠ SỞ DỮ LIỆU (DBMS330284) - HCMUTE
-- HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) - NHÓM 10
-- TẬP LỆNH: HỆ THỐNG FUNCTION (HÀM TÍNH TOÁN & TRA CỨU)
-- ============================================================================

USE QuanLyKhachSan;
GO

-- ----------------------------------------------------------------------------
-- Function 1: Tính tổng tiền phòng của đơn đặt phòng
-- Loại hàm: Scalar Function
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_TinhTienPhongBooking (@MaBooking VARCHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTienPhong DECIMAL(18,2) = 0;

    -- Bước 1: Tách riêng việc xác định ngày kết thúc lưu trú
    ;WITH BangXacDinhNgay AS (
        SELECT 
            bp.DonGiaPhong,
            bp.NgayNhanDuKien,
            -- Ưu tiên ngày check-out thực tế, nếu chưa check-out thì dùng ngày trả dự kiến
            ISNULL(CAST(bp.NgayCheckOutThucTe AS DATE), bp.NgayTraDuKien) AS NgayKetThuc
        FROM BOOKING_PHONG bp
        WHERE bp.MaBooking = @MaBooking
    ),
    -- Bước 2: Tách riêng việc tính số đêm lưu trú (tối thiểu là 1 đêm nếu ở cùng ngày)
    BangTinhSoDem AS (
        SELECT 
            DonGiaPhong,
            CASE 
                WHEN DATEDIFF(DAY, NgayNhanDuKien, NgayKetThuc) <= 0 THEN 1
                ELSE DATEDIFF(DAY, NgayNhanDuKien, NgayKetThuc)
            END AS SoDem
        FROM BangXacDinhNgay
    )
    -- Bước 3: Tính tổng tiền phòng = Đơn giá mỗi đêm * Số đêm
    SELECT @TongTienPhong = SUM(DonGiaPhong * SoDem)
    FROM BangTinhSoDem;

    -- Bước 4: Tách riêng xử lý NULL, nếu không có bản ghi nào thì trả về 0
    IF @TongTienPhong IS NULL
        SET @TongTienPhong = 0;

    RETURN @TongTienPhong;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 2: Tính tổng tiền dịch vụ phát sinh của đơn đặt phòng
-- Loại hàm: Scalar Function
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_TinhTienDichVuBooking (@MaBooking VARCHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTienDichVu DECIMAL(18,2) = 0;

    SELECT @TongTienDichVu = ISNULL(SUM(bdv.DonGia * bdv.SoLuong), 0)
    FROM BOOKING_DICHVU bdv
    WHERE bdv.MaBooking = @MaBooking;

    RETURN @TongTienDichVu;
END;
GO

-- ----------------------------------------------------------------------------
-- Function 3: Tính tổng tiền thực tế phải thanh toán (Phòng + Dịch vụ)
-- Loại hàm: Scalar Function
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_TinhTongTienThucTePhaiTra (@MaBooking VARCHAR(10))
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN dbo.fn_TinhTienPhongBooking(@MaBooking) + dbo.fn_TinhTienDichVuBooking(@MaBooking);
END;
GO

-- ----------------------------------------------------------------------------
-- Function 4: Kiểm tra nhanh phòng có trống trong khoảng thời gian không
-- Loại hàm: Scalar Function (Trả về 1 = Khả dụng, 0 = Không khả dụng)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_KiemTraPhongTrongTrongKhoang (
    @MaPhong VARCHAR(10),
    @NgayNhan DATE,
    @NgayTra DATE,
    @MaBookingBoQua VARCHAR(10) = NULL
)
RETURNS BIT
AS
BEGIN
    -- 1. Nếu phòng đang bẩn, đang dọn hoặc bị hư hỏng thì không thể sử dụng
    IF EXISTS (SELECT 1 FROM PHONG WHERE MaPhong = @MaPhong AND TrangThai IN ('Dirty', 'Cleaning', 'Damaged'))
        RETURN 0;

    -- 2. Kiểm tra có bị trùng lịch với booking khác đang có hiệu lực hay không
    IF EXISTS (
        SELECT 1
        FROM BOOKING_PHONG bp
        INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking
        WHERE bp.MaPhong = @MaPhong
          -- Bỏ qua chính mã booking đang được sửa đổi (nếu có) để tránh tự trùng với chính mình
          AND (@MaBookingBoQua IS NULL OR bp.MaBooking <> @MaBookingBoQua)
          AND b.TrangThai IN ('DaXacNhan', 'DaCheckIn')
          AND NOT (bp.NgayTraDuKien <= @NgayNhan OR bp.NgayNhanDuKien >= @NgayTra)
    )
        RETURN 0;

    RETURN 1; -- Phòng trống hoàn toàn và sẵn sàng phục vụ
END;
GO

-- ----------------------------------------------------------------------------
-- Function 5: Tra cứu danh sách phòng trống theo ngày, số người và loại phòng
-- Loại hàm: Inline Table-Valued Function (Phục vụ Search Bar trên Web ReactJS)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_TraCuuPhongTrongTheoYeuCau (
    @NgayNhan DATE,
    @NgayTra DATE,
    @SoNguoi INT = NULL,
    @MaLoaiPhong VARCHAR(10) = NULL
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.MaPhong,
        p.SoPhong,
        lp.MaLoaiPhong,
        lp.TenLoaiPhong,
        lp.DienTich,
        lp.LoaiGiuong,
        lp.SoNguoiToiDa,
        lp.GiaPhong,
        p.MoTa
    FROM PHONG p
    INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong
    WHERE (@MaLoaiPhong IS NULL OR p.MaLoaiPhong = @MaLoaiPhong)
      AND (@SoNguoi IS NULL OR lp.SoNguoiToiDa >= @SoNguoi)
      AND p.TrangThai NOT IN ('Dirty', 'Cleaning', 'Damaged')
      AND lp.TrangThai = 'ApDung'
      AND dbo.fn_KiemTraPhongTrongTrongKhoang(p.MaPhong, @NgayNhan, @NgayTra, NULL) = 1
);
GO

-- ----------------------------------------------------------------------------
-- Function 6: Xem lịch sử đặt phòng của một khách hàng
-- Loại hàm: Inline Table-Valued Function (Phục vụ trang cá nhân Khách hàng)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_LichSuDatPhongKhachHang (@MaKH VARCHAR(10))
RETURNS TABLE
AS
RETURN (
    SELECT 
        b.MaBooking,
        b.NgayDat,
        b.ChiPhiDuKien,
        b.TrangThai AS TrangThaiBooking,
        hd.MaHoaDon,
        hd.TongTienCuoiCung,
        hd.TrangThai AS TrangThaiHoaDon
    FROM BOOKING b
    LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking
    WHERE b.MaKH = @MaKH
);
GO

-- ----------------------------------------------------------------------------
-- Function 7: Thống kê doanh thu theo khoảng thời gian tùy chọn
-- Loại hàm: Scalar Function (Phục vụ báo cáo tùy biến cho Quản lý)
-- ----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_DoanhThuTheoKhoangThoiGian (
    @TuNgay DATETIME,
    @DenNgay DATETIME
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongThu DECIMAL(18,2) = 0;

    SELECT @TongThu = ISNULL(SUM(SoTien), 0)
    FROM THANHTOAN
    WHERE ThoiDiemThanhToan BETWEEN @TuNgay AND @DenNgay;

    RETURN @TongThu;
END;
GO
