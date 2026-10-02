USE QuanLyKhachSan;
GO

-- 1. SỬA DỊCH VỤ (DICHVU)
UPDATE DICHVU SET TenDichVu = N'Ăn sáng Buffet', MoTa = N'Buffet sáng món Á - Âu từ 6:00 đến 9:30' WHERE MaDichVu = 'DV01';
UPDATE DICHVU SET TenDichVu = N'Giặt ủi quần áo', MoTa = N'Giặt sấy ủi lấy trong ngày (tính theo kg)' WHERE MaDichVu = 'DV02';
UPDATE DICHVU SET TenDichVu = N'Đưa đón sân bay', MoTa = N'Xe sedan 4 chỗ đời mới đưa/đón Tân Sơn Nhất' WHERE MaDichVu = 'DV03';
UPDATE DICHVU SET TenDichVu = N'Massage & Spa Body', MoTa = N'Gói trị liệu toàn thân tinh dầu thảo mộc 60 phút' WHERE MaDichVu = 'DV04';
UPDATE DICHVU SET TenDichVu = N'Nước uống Mini Bar', MoTa = N'Lon nước ngọt/nước ép trái cây các loại' WHERE MaDichVu = 'DV05';
UPDATE DICHVU SET TenDichVu = N'Thuê xe máy tự lái', MoTa = N'Xe tay ga Honda Air Blade theo ngày (24h)' WHERE MaDichVu = 'DV06';

-- 2. SỬA LOẠI PHÒNG (LOAIPHONG)
UPDATE LOAIPHONG SET LoaiGiuong = N'1 Giường đơn' WHERE MaLoaiPhong = 'LP01';
UPDATE LOAIPHONG SET LoaiGiuong = N'1 Giường đôi' WHERE MaLoaiPhong = 'LP02';
UPDATE LOAIPHONG SET LoaiGiuong = N'1 Giường King' WHERE MaLoaiPhong = 'LP03';
UPDATE LOAIPHONG SET LoaiGiuong = N'2 Giường đôi' WHERE MaLoaiPhong = 'LP04';
UPDATE LOAIPHONG SET LoaiGiuong = N'2 Giường King VIP' WHERE MaLoaiPhong = 'LP05';

-- 3. SỬA PHÒNG (PHONG)
UPDATE PHONG SET MoTa = N'Phòng tầng 1, hướng vườn, thoáng mát.' WHERE MaPhong = 'P101';
UPDATE PHONG SET MoTa = N'Khách vừa check-out lúc 11:30, cần dọn dẹp.' WHERE MaPhong = 'P102';
UPDATE PHONG SET MoTa = N'Phòng tầng 1, gần sảnh lễ tân.' WHERE MaPhong = 'P103';
UPDATE PHONG SET MoTa = N'Khách KH001 đang lưu trú.' WHERE MaPhong = 'P201';
UPDATE PHONG SET MoTa = N'Phòng Deluxe King tầng 2, giữ phòng theo lịch đặt.' WHERE MaPhong = 'P202';
UPDATE PHONG SET MoTa = N'Phòng tầng 2, ban công nhìn ra hồ bơi.' WHERE MaPhong = 'P203';
UPDATE PHONG SET MoTa = N'Nhân viên buồng phòng đang tiến hành vệ sinh.' WHERE MaPhong = 'P301';
UPDATE PHONG SET MoTa = N'Khách gia đình đang ở.' WHERE MaPhong = 'P302';
UPDATE PHONG SET MoTa = N'Phòng gia đình đầy đủ tiện nghi bếp nhỏ.' WHERE MaPhong = 'P303';
UPDATE PHONG SET MoTa = N'Gương phòng tắm bị nứt vỡ, đang chờ kỹ thuật thay thế.' WHERE MaPhong = 'P401';
UPDATE PHONG SET MoTa = N'Phòng tổng thống VIP, nội thất phong cách Pháp.' WHERE MaPhong = 'P402';
UPDATE PHONG SET MoTa = N'Phòng tầng cao ngắm cảnh thành phố ban đêm.' WHERE MaPhong = 'P403';

-- 4. SỬA KHÁCH HÀNG (KHACHHANG)
UPDATE KHACHHANG SET HoTen = N'Nguyễn Văn An' WHERE MaKH = 'KH001';
UPDATE KHACHHANG SET HoTen = N'Trần Thị Bích Mai' WHERE MaKH = 'KH002';
UPDATE KHACHHANG SET HoTen = N'Lê Quốc Hùng' WHERE MaKH = 'KH003';
UPDATE KHACHHANG SET HoTen = N'Phạm Thanh Thảo' WHERE MaKH = 'KH004';
UPDATE KHACHHANG SET HoTen = N'Hoàng Minh Tuấn' WHERE MaKH = 'KH005';

-- 5. SỬA NHÂN VIÊN (NHANVIEN)
UPDATE NHANVIEN SET HoTen = N'Nguyễn Thị Hương' WHERE MaNV = 'NV001';
UPDATE NHANVIEN SET HoTen = N'Trần Văn Khoa' WHERE MaNV = 'NV002';
UPDATE NHANVIEN SET HoTen = N'Lê Thị Hồng Nhung' WHERE MaNV = 'NV003';
UPDATE NHANVIEN SET HoTen = N'Phan Thanh Bình' WHERE MaNV = 'NV004';
UPDATE NHANVIEN SET HoTen = N'Đỗ Quang Vinh' WHERE MaNV = 'NV005';

-- 6. SỬA TÀI KHOẢN (TAIKHOAN)
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Nguyễn Thị Hương' WHERE MaTaiKhoan = 'TK_E01';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Trần Văn Khoa' WHERE MaTaiKhoan = 'TK_E02';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Lê Thị Hồng Nhung' WHERE MaTaiKhoan = 'TK_E03';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Phan Thanh Bình' WHERE MaTaiKhoan = 'TK_E04';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Đỗ Quang Vinh' WHERE MaTaiKhoan = 'TK_E05';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Nguyễn Văn An' WHERE MaTaiKhoan = 'TK_G01';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Trần Thị Bích Mai' WHERE MaTaiKhoan = 'TK_G02';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Lê Quốc Hùng' WHERE MaTaiKhoan = 'TK_G03';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Phạm Thanh Thảo' WHERE MaTaiKhoan = 'TK_G04';
UPDATE TAIKHOAN SET HoTenTaiKhoan = N'Hoàng Minh Tuấn' WHERE MaTaiKhoan = 'TK_G05';

-- 7. SỬA LOẠI HƯ HẠI (LOAIHUHAI)
UPDATE LOAIHUHAI SET TenLoaiHuHai = N'Vỡ kính / Gương / Thủy tinh', MoTa = N'Bể gương soi, mặt kính bàn trà, ly tách thủy tinh.' WHERE MaLoaiHuHai = 'LHH01';
UPDATE LOAIHUHAI SET TenLoaiHuHai = N'Hỏng máy lạnh / Điều hòa', MoTa = N'Điều hòa không lạnh, chảy nước hoặc kêu to bất thường.' WHERE MaLoaiHuHai = 'LHH02';
UPDATE LOAIHUHAI SET TenLoaiHuHai = N'Rách ga / Nệm / Rèm cửa', MoTa = N'Cháy thủng do tàn thuốc, rách vải nội thất.' WHERE MaLoaiHuHai = 'LHH03';
UPDATE LOAIHUHAI SET TenLoaiHuHai = N'Hỏng khóa cửa / Thẻ từ', MoTa = N'Khóa thông minh không nhận thẻ từ, tay nắm bị kẹt.' WHERE MaLoaiHuHai = 'LHH04';
UPDATE LOAIHUHAI SET TenLoaiHuHai = N'Nghẹt bồn cầu / Rò rỉ nước', MoTa = N'Tắc nghẽn đường ống dẫn thoát nước vệ sinh.' WHERE MaLoaiHuHai = 'LHH05';

-- 8. SỬA BÁO CÁO HƯ HẠI (BAOCAOHUHAI & CHITIETBAOCAOHUHAI)
UPDATE BAOCAOHUHAI SET MoTa = N'Phát hiện trong lúc dọn phòng sau khi khách rời đi.' WHERE MaBaoCao = 'BC001';
UPDATE CHITIETBAOCAOHUHAI SET MoTaChiTiet = N'Gương treo tường bồn rửa mặt bị nứt đường chéo dài 40cm góc dưới bên trái.' WHERE MaBaoCao = 'BC001' AND MaLoaiHuHai = 'LHH01';
GO
