$sqlCmd = "SELECT p.MaPhong, p.SoPhong, lp.TenLoaiPhong, lp.GiaPhong, p.TrangThai FROM PHONG p INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong ORDER BY p.SoPhong;"
sqlcmd -S localhost,1433 -U sa -P 1234 -d QuanLyKhachSan -Q $sqlCmd -s "," -W
