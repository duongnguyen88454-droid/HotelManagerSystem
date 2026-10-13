# BỘ TEST CASE KHẮC NGHIỆT — BACKEND PHASE 6 (MANAGER PORTAL - VT04)

> **Đối tượng kiểm thử:** `ManagerPortalServlet`, `ManagerRevenueReportServlet`, `ManagerServiceAnalyticsServlet`, `ManagerDamageResolutionServlet` cùng các Service/DAO và đối tượng CSDL tương ứng.
> **Tinh thần:** Không kiểm tra "đường hạnh phúc". Mỗi case nhắm vào một giả định ngầm mà người viết code có thể đã đặt ra sai.

---

## 0. QUY TẮC THỰC THI (BẮT BUỘC ĐỌC TRƯỚC)

1. **Chạy trên bản sao dữ liệu.** Trước khi bắt đầu: `BACKUP DATABASE QuanLyKhachSan TO DISK = '...'`. Nhiều case ghi/sửa dữ liệu.
2. **Mỗi case phải có một trong ba kết luận:** `PASS` / `FAIL` / `BLOCKED` (không chạy được, nêu lý do).
3. **FAIL phải ghi đủ:** kết quả thực tế, câu SQL hoặc request chứng minh, file và dòng nghi ngờ.
4. **CẤM sửa test case để biến FAIL thành PASS.** CẤM sửa code khi chưa có duyệt của User (theo `GEMINI.md`). Gặp FAIL thì lập đề xuất Before/After rồi dừng chờ duyệt.
5. **Đọc ràng buộc thực tế trước khi dựng dữ liệu:** chạy `sp_help 'THANHTOAN'`, `sp_help 'BAOCAOHUHAI'`, `sp_help 'PHONG'`, `sp_help 'HOADON'` và ghi lại các `CHECK` (giá trị hợp lệ của `PhuongThucThanhToan`, `TrangThai`...). Nếu giá trị trong test không hợp lệ với CHECK thật, ghi `BLOCKED` kèm giá trị thật.
6. **Ghi lại trạng thái trước/sau** của các bảng `PHONG`, `BAOCAOHUHAI`, `THANHTOAN` bằng `SELECT` cho từng case ghi dữ liệu.

**Tài khoản:** Quản lý `VT04`, Buồng phòng `nhung.lth@hotel.com` (`VT03`), mật khẩu `1234`. Cần thêm 1 tài khoản `VT01` và 1 tài khoản `VT02`.
**Base URL:** `http://localhost:8080/HotelManagerSystem` (Tomcat 9.0.121, KHÔNG dùng Tomcat 10).

### Dữ liệu mồi dùng chung (chạy một lần)

```sql
-- Snapshot trạng thái phòng để so sánh sau mỗi case
SELECT MaPhong, SoPhong, TrangThai INTO #SnapPhong FROM PHONG;
-- Xem phân bố trạng thái hiện có (phát hiện trạng thái ngoài 4 nhóm của view)
SELECT TrangThai, COUNT(*) AS SoLuong FROM PHONG GROUP BY TrangThai;
```

---

## NHÓM A — PHÂN QUYỀN & BIÊN GIỚI TRUY CẬP

### A1. Vai trò khác truy cập từng route của Manager
- **Cách thực hiện:** Lần lượt đăng nhập `VT01`, `VT02`, `VT03`; gửi `GET` tới `/manager/dashboard`, `/manager/revenue`, `/manager/services`, `/manager/damages`. Sau đó gửi `POST /manager/damages` với `action=resolve` bằng `curl` mang cookie `JSESSIONID` của `VT03`.
- **Kết quả mong muốn:** Tất cả trả `403`, nội dung `error_403.jsp`. **Riêng POST của VT03 tuyệt đối không được làm đổi trạng thái phòng.** Kiểm chứng bằng `SELECT` `PHONG` và `BAOCAOHUHAI` trước/sau.
- **Bẫy:** Chỉ kiểm tra GET mà quên POST; POST là đường ghi dữ liệu.

### A2. Né bộ lọc bằng biến thể đường dẫn
- **Cách thực hiện:** Với phiên `VT03`, thử lần lượt: `/manager/../manager/damages`, `//manager/dashboard`, `/manager;jsessionid=x/dashboard`, `/MANAGER/dashboard`, `/manager/dashboard/`, `/manager/%2e%2e/manager/dashboard`, `/manager` (không dấu `/` cuối).
- **Kết quả mong muốn:** Không biến thể nào cho `VT03` xem được dữ liệu Manager. Chấp nhận `403` hoặc `404`, **không chấp nhận `200`**.
- **Bẫy:** `AuthFilter` dùng `path.startsWith("/manager/")` so khớp chuỗi thô. Đường dẫn `/manager` không có dấu `/` cuối có thể lọt khỏi nhánh kiểm tra rồi rơi vào `isAuthorized = false`. Cần xác nhận hành vi thực tế.

### A3. Phiên hết hạn giữa chừng khi đang nghiệm thu
- **Cách thực hiện:** Mở `/manager/damages` bằng `VT04`. Xóa cookie `JSESSIONID` (hoặc `session.invalidate()`). Bấm nút Nghiệm thu (hoặc `curl POST` với cookie cũ).
- **Kết quả mong muốn:** Chuyển hướng `302` về `/login?redirect=...`. Không có `UPDATE` nào được thực thi. Không lỗi 500.

### A4. Hạ quyền khi đang đăng nhập
- **Cách thực hiện:** `VT04` đang mở phiên. Trong DB đổi `MaVaiTro` của tài khoản đó sang `VT01`. Thao tác tiếp trên phiên cũ.
- **Kết quả mong muốn:** Ghi nhận hành vi thực tế. Nếu phiên vẫn dùng quyền cũ thì ghi rõ vào báo cáo như một **rủi ro bảo mật đã biết** (vai trò được cache trong session), không tự ý coi là PASS.

---

## NHÓM B — F6.1 DASHBOARD / `v_TyLeLapDayPhong`

### B1. Bảng PHONG rỗng
- **Cách thực hiện:** Trong transaction: `BEGIN TRAN; DELETE FROM PHONG;` (nếu dính FK thì dùng bản sao DB hoặc `BLOCKED`). Gọi `/manager/dashboard`, sau đó `ROLLBACK`.
- **Kết quả mong muốn:** Không lỗi chia cho 0; tất cả chỉ số bằng 0; tỷ lệ `0` chứ không phải `null` gây `NullPointerException` ở JSP.
- **Bẫy:** View dùng `NULLIF`, DAO có fallback; kiểm tra JSP có render đúng `0%` không.

### B2. Trạng thái phòng nằm ngoài 4 nhóm
- **Cách thực hiện:** Đặt 1 phòng sang trạng thái khác (ví dụ `Maintenance`/`Reserved` nếu CHECK cho phép, nếu không thì ghi `BLOCKED`). So sánh `TongSoPhong` với tổng 4 nhóm.
- **Kết quả mong muốn:** Hoặc tổng 4 nhóm luôn bằng `TongSoPhong`, hoặc có cơ chế/cảnh báo cho phần "khác". Nếu `Tổng ≠ Occupied + Available + Dọn + Hỏng` mà UI không giải thích thì **FAIL** (số liệu lệch, người quản lý không biết phòng "biến mất" đi đâu).

### B3. Làm tròn tỷ lệ lấp đầy
- **Cách thực hiện:** Dựng tình huống 1/3, 2/3, 1/7 phòng `Occupied` (trên bản sao). Đọc `TyLeLapDayPhanTram`.
- **Kết quả mong muốn:** `33.33`, `66.67`, `14.29`. Tổng các phần trăm hiển thị trên thanh phân đoạn (nếu có) không vượt `100%` do làm tròn.
- **Bẫy:** `100.0 * COUNT / COUNT` đã là thập phân; cẩn thận nếu ai đó đổi sang chia số nguyên.

### B4. Số liệu dashboard lệch ngay sau thao tác ở phase khác
- **Cách thực hiện:** Ghi số liệu dashboard. Thực hiện lần lượt: check-in một phòng; check-out; buồng phòng nhận dọn; buồng phòng báo hư hại. Sau **mỗi** bước, tải lại dashboard.
- **Kết quả mong muốn:** Mỗi bước chỉ chuyển đúng một phòng giữa các nhóm, `TongSoPhong` không đổi. Chuỗi: `Available→Occupied→Dirty→Cleaning→Damaged`.
- **Bẫy:** Phát hiện phòng bị đếm hai lần hoặc không đếm trong khoảnh khắc chuyển trạng thái.

### B5. Phòng `Occupied` nhưng không có booking đang hiệu lực (dữ liệu bẩn)
- **Cách thực hiện:** `UPDATE PHONG SET TrangThai='Occupied'` cho một phòng không có booking `DaCheckIn`. Xem dashboard.
- **Kết quả mong muốn:** Ghi nhận view đếm theo `PHONG.TrangThai` thuần túy nên vẫn tính phòng này là có khách. Đây là hành vi "tin cột trạng thái"; ghi vào báo cáo như rủi ro nhất quán dữ liệu, kèm đề xuất truy vấn đối soát với `BOOKING_PHONG`.

---

## NHÓM C — F6.2 BÁO CÁO DOANH THU

### C1. Tra cứu khoảng ngày chỉ một ngày (fromDate = toDate)
- **Cách thực hiện:** Tạo (hoặc tìm) một khoản thanh toán lúc `15:00` hôm nay. Gọi `/manager/revenue?fromDate=<hôm nay>&toDate=<hôm nay>`. So sánh `rangeRevenue` với `SELECT SUM(SoTien) FROM THANHTOAN WHERE CAST(ThoiDiemThanhToan AS DATE)=CAST(GETDATE() AS DATE)`.
- **Kết quả mong muốn:** Hai số **bằng nhau**.
- **Bẫy (nghi ngờ cao FAIL):** `fn_DoanhThuTheoKhoangThoiGian` nhận `DATETIME` và dùng `BETWEEN`. DAO truyền `java.sql.Date` nên `toDate` là `00:00:00`; mọi khoản thu trong ngày `toDate` sau 00:00 bị loại. Xác minh bằng: `SELECT dbo.fn_DoanhThuTheoKhoangThoiGian('2026-10-05','2026-10-05')`.

### C2. Khoản thu sát mốc nửa đêm
- **Cách thực hiện:** Chèn thanh toán tại `2026-10-04 23:59:59.997`, `2026-10-05 00:00:00.000`, `2026-10-05 23:59:59.997`. Với mỗi ngày gọi cả báo cáo chốt ca (`?date=`) lẫn khoảng ngày.
- **Kết quả mong muốn:** Mỗi khoản thu thuộc đúng **một** ngày duy nhất, không bị tính trùng ở hai ngày liền kề, không bị mất. Tổng 2 ngày liền kề = tổng khoảng ngày trải qua cả 2 ngày.
- **Bẫy:** `DATETIME` làm tròn đến `.003`/`.007` ms; `23:59:59.999` bị làm tròn sang ngày hôm sau.

### C3. Khoảng ngày ngược (fromDate > toDate)
- **Cách thực hiện:** `?fromDate=2026-10-10&toDate=2026-10-01`.
- **Kết quả mong muốn:** Không 500. Cần thông báo rõ "khoảng ngày không hợp lệ". Ghi nhận thực tế: servlet hiện bỏ qua im lặng và không set `rangeRevenue`, người dùng nhìn thấy trang như chưa lọc. Nếu không có thông báo thì ghi **FAIL mức UX**.

### C4. Giá trị ngày vô lý
- **Cách thực hiện:** Lần lượt: `date=2026-02-30`, `date=abc`, `date=`, `date=0001-01-01`, `date=9999-12-31`, `fromDate=1700-01-01&toDate=2026-10-05`, `date=2026-13-01`, `date=%00`, `date=2026-10-05%20OR%201=1`.
- **Kết quả mong muốn:** Không 500, không lộ stack trace. Ngày sai định dạng rơi về hôm nay. Riêng `fromDate=1700-01-01`: `DATETIME` của SQL Server chỉ từ năm `1753` nên có thể ném lỗi tràn; xác nhận kết quả là thông báo có nghĩa chứ **không phải số `0` im lặng**.
- **Bẫy:** DAO bắt `Exception` rồi trả `BigDecimal.ZERO`; người dùng tin rằng "doanh thu = 0" trong khi thực ra truy vấn đã lỗi.

### C5. Phương thức thanh toán lạ
- **Cách thực hiện:** Nếu CHECK cho phép, chèn thanh toán có `PhuongThucThanhToan` ngoài `TienMat/ChuyenKhoan/TheNganHang` (hoặc khác hoa/thường, có khoảng trắng đuôi, ví dụ `'TienMat '`). Chạy `sp_BaoCaoTongHopKinhDoanhTheoNgay`.
- **Kết quả mong muốn:** `ThuTienMat + ThuChuyenKhoan + ThuTheNganHang = TongTienThucThu`. Nếu lệch thì **FAIL**: dòng tiền "mất tích" khỏi bảng cơ cấu.
- **Bẫy:** SQL Server so sánh chuỗi mặc định không phân biệt hoa thường và bỏ qua khoảng trắng đuôi; hãy kiểm chứng thay vì giả định.

### C6. Hoàn tiền / số tiền âm
- **Cách thực hiện:** Nếu CHECK cho phép `SoTien < 0` (hoàn cọc), chèn khoản hoàn tiền; nếu không, ghi `BLOCKED`. Xem chốt ca ngày và doanh thu tháng.
- **Kết quả mong muốn:** Doanh thu thực thu = thu − hoàn, hoặc có quy ước rõ ràng. Không để `View` tháng và `SP` ngày cho hai số khác nhau cho cùng một ngày.

### C7. Đối soát chéo ba nguồn doanh thu
- **Cách thực hiện:** Chọn một tháng có dữ liệu. Tính 3 số: (a) cộng các ngày bằng `sp_BaoCaoTongHopKinhDoanhTheoNgay`; (b) `v_BaoCaoDoanhThuTheoThang`; (c) `sp_BaoCaoTongHopKinhDoanhThang`; (d) `fn_DoanhThuTheoKhoangThoiGian(đầu tháng, cuối tháng)`.
- **Kết quả mong muốn:** Cả bốn **bằng nhau tuyệt đối**.
- **Bẫy:** View tháng dùng `INNER JOIN HOADON`, nên khoản thanh toán không gắn hóa đơn (ví dụ tiền cọc) sẽ có trong (a)(c)(d) nhưng **không có** trong (b). Nếu lệch, truy `SELECT * FROM THANHTOAN WHERE MaHoaDon IS NULL`.

### C8. Chuyển giao tháng và năm
- **Cách thực hiện:** Có thanh toán ngày `2025-12-31 23:59:00` và `2026-01-01 00:01:00`. Xem `v_BaoCaoDoanhThuTheoThang` và `sp_BaoCaoTongHopKinhDoanhThang(12,2025)`, `(1,2026)`.
- **Kết quả mong muốn:** Mỗi khoản vào đúng tháng/năm; danh sách tháng sắp xếp `Nam DESC, Thang DESC` (`2026-01` đứng trước `2025-12`).

### C9. Tháng không có giao dịch
- **Cách thực hiện:** Gọi `sp_BaoCaoTongHopKinhDoanhThang` cho tháng chưa có dữ liệu (ví dụ `(2,1999)`) và xem danh sách tháng khi bảng `THANHTOAN` rỗng (trên bản sao).
- **Kết quả mong muốn:** Trả về một dòng toàn số 0, danh sách rỗng được JSP xử lý (hiện "chưa có dữ liệu"), không lỗi.

### C10. Chốt ca ngày: đơn hủy và đơn tạo-hủy trong ngày
- **Cách thực hiện:** Tạo một booking rồi hủy ngay trong cùng ngày. Chạy chốt ca.
- **Kết quả mong muốn:** Ghi nhận `SoDonDatMoi` có tính đơn đã hủy hay không; cần có quy ước rõ. Nếu đơn đã hủy bị tính vào "đơn đặt mới" thì ghi nhận như điểm cần làm rõ với nghiệp vụ.

### C11. Đa luồng: thanh toán chèn vào đúng lúc chốt ca
- **Cách thực hiện:** Phiên SQL 1: `BEGIN TRAN; INSERT INTO THANHTOAN ...;` (chưa commit). Phiên 2: gọi `/manager/revenue`. Quan sát (treo hay trả về). Sau đó `COMMIT`, tải lại.
- **Kết quả mong muốn:** Báo cáo không treo vô hạn (có timeout hợp lý), không đọc dữ liệu chưa commit. Sau `COMMIT`, số liệu cập nhật. Nếu trang treo quá 30 giây thì ghi nhận rủi ro khóa đọc.

---

## NHÓM D — F6.3 PHÂN TÍCH DỊCH VỤ / `v_ThongKeDichVuBanChay`

### D1. Dịch vụ của booking đã hủy bị tính vào doanh thu
- **Cách thực hiện:** Tạo booking, gọi thêm dịch vụ (`sp_GoiThemDichVu`) ví dụ 5 lon nước, sau đó hủy booking (`TrangThai='DaHuy'`). Xem `/manager/services`.
- **Kết quả mong muốn:** Doanh thu dịch vụ **không** gồm khoản của booking đã hủy. Nếu view vẫn cộng (view không lọc trạng thái booking) thì **FAIL**: số liệu "bán chạy" bị thổi phồng bởi dịch vụ chưa từng được thanh toán.

### D2. Dịch vụ chưa từng bán
- **Cách thực hiện:** Thêm một dịch vụ mới vào `DICHVU`, không ai gọi.
- **Kết quả mong muốn:** Xuất hiện ở cuối danh sách với số lượng `0`, doanh thu `0`, không `null`. Không lọt vào vị trí "Top".

### D3. Đổi giá dịch vụ sau khi đã bán
- **Cách thực hiện:** Bán 10 đơn vị ở giá 20.000. Đổi `DICHVU.DonGia` thành 50.000. Bán thêm 10 đơn vị.
- **Kết quả mong muốn:** `TongDoanhThuDichVu = 10×20.000 + 10×50.000 = 700.000` (dùng `BOOKING_DICHVU.DonGia` lịch sử), không phải `20×50.000`. Cột `DonGiaHienTai` hiển thị 50.000.

### D4. Đồng hạng và thứ tự ổn định
- **Cách thực hiện:** Hai dịch vụ cùng doanh thu và cùng số lượng.
- **Kết quả mong muốn:** Thứ tự ổn định giữa các lần tải (cần tiêu chí phụ như `TenDichVu`). Nếu thứ tự nhảy ngẫu nhiên giữa các lần F5 thì ghi nhận.

### D5. Tên dịch vụ chứa ký tự đặc biệt
- **Cách thực hiện:** Đổi tên một dịch vụ thành `<script>alert(1)</script> & "Spa" 'VIP' Ñ Đ ế`.
- **Kết quả mong muốn:** JSP hiển thị nguyên văn, **không thực thi script**, không vỡ bố cục, tiếng Việt đúng. Bắt buộc dùng `<c:out>` hoặc `fn:escapeXml`. *(Chỉ áp dụng khi `service_analytics.jsp` đã được tạo.)*

### D6. Số lượng lớn gây tràn
- **Cách thực hiện:** Dịch vụ `DonGia = 9999999999999999.99`-mức cận biên của `DECIMAL(18,2)` với `SoLuong = 1000` (nếu CHECK cho phép).
- **Kết quả mong muốn:** Ghi nhận hành vi tràn số (`Arithmetic overflow`) và cách DAO xử lý; không được nuốt lỗi rồi trả danh sách rỗng.

---

## NHÓM E — F6.4 NGHIỆM THU BẢO TRÌ (nhóm nguy hiểm nhất, vì GHI dữ liệu)

> Chuẩn bị: lập ít nhất 3 biên bản hư hại thật bằng giao diện Buồng phòng (Phase 5) cho 3 phòng khác nhau, trong đó **một biên bản có 3 mục chi tiết**.

### E1. Một biên bản nhiều mục chi tiết hiển thị thế nào
- **Cách thực hiện:** Mở `/manager/damages`. Đếm số dòng thuộc biên bản có 3 mục.
- **Kết quả mong muốn:** Người dùng phải hiểu đó là **một** biên bản. Nếu hiển thị 3 dòng độc lập, mỗi dòng một nút Nghiệm thu thì rất dễ nhầm. Ghi nhận cách hiển thị; sau khi bấm Nghiệm thu ở **một** dòng, cả 3 dòng cùng biến mất (vì cùng `MaBaoCao`). Xác minh bằng `SELECT`.

### E2. Giả mạo mã phòng — mở khóa nhầm phòng đang có khách (**nghi ngờ FAIL nghiêm trọng**)
- **Cách thực hiện:** Lấy một phòng đang `Occupied` (có khách ở). Dùng `curl` gửi `POST /manager/damages` với `action=resolve`, `maBaoCao=<mã biên bản hợp lệ chờ xử lý>`, `maPhong=<mã phòng đang Occupied>`, kèm cookie `VT04`.
- **Kết quả mong muốn:** Hệ thống **từ chối** (báo cáo và phòng không khớp, hoặc phòng không ở trạng thái `Damaged`). Phòng `Occupied` giữ nguyên `Occupied`.
- **Bẫy:** `MaintenanceDAO.resolveDamagedRoom` thực thi hai câu `UPDATE` rời rạc, không kiểm tra `MaPhong` có thuộc `MaBaoCao` và không kiểm tra `PHONG.TrangThai = 'Damaged'`. Nếu mã giả được chấp nhận thì phòng đang có khách bị đặt thành `Available` và có thể bị bán cho khách thứ hai (overbooking). Kiểm chứng bằng `SELECT TrangThai FROM PHONG WHERE MaPhong=...` sau request.

### E3. Cặp mã không khớp (báo cáo phòng A, phòng truyền vào B)
- **Cách thực hiện:** Hai phòng `Damaged` A và B, mỗi phòng một biên bản (`BC_A`, `BC_B`). Gửi `maBaoCao=BC_A&maPhong=B`.
- **Kết quả mong muốn:** Từ chối. Nếu thực thi: `BC_A` thành `DaXuLy` nhưng phòng A vẫn `Damaged` mãi (không ai nghiệm thu được nữa vì biên bản đã đóng) còn B mở ra dù chưa sửa. **FAIL** nếu chấp nhận.

### E4. Nộp trùng (double submit / replay)
- **Cách thực hiện:** Bấm nút Nghiệm thu hai lần rất nhanh; sau đó dùng `curl` gửi lại đúng request đó lần thứ ba.
- **Kết quả mong muốn:** Lần đầu thành công; các lần sau báo "đã được nghiệm thu rồi" hoặc không có tác dụng. Không lỗi 500. Phòng chỉ chuyển trạng thái một lần.
- **Bẫy:** `executeUpdate()` ảnh hưởng 0 dòng vẫn được coi là thành công, và `flashSuccess` vẫn hiện.

### E5. Nghiệm thu một biên bản khi phòng còn biên bản chờ khác
- **Cách thực hiện:** Phòng X có hai biên bản `ChoXuLy` (BC1 và BC2, ví dụ hai lần báo cáo liên tiếp nếu hệ thống cho phép; nếu Phase 5 chặn thì `BLOCKED` và ghi nhận như điểm tốt). Nghiệm thu BC1.
- **Kết quả mong muốn:** Phòng X **không** được mở lại `Available` khi BC2 chưa xử lý xong. Nếu mở, **FAIL**: phòng vẫn hỏng nhưng bán được.

### E6. Hai quản lý nghiệm thu cùng một biên bản đồng thời
- **Cách thực hiện:** Hai terminal `curl` gửi cùng lúc 2 request giống hệt (có thể dùng `xargs -P2` hoặc hai tab PowerShell `Start-Job`).
- **Kết quả mong muốn:** Cả hai không phá hỏng dữ liệu; trạng thái cuối nhất quán (`DaXuLy`/`Available`). Không deadlock; nếu có deadlock phải được bắt và báo lỗi thân thiện.

### E7. Tranh chấp giữa Buồng phòng và Quản lý
- **Cách thực hiện:** Tại cùng thời điểm: Quản lý nghiệm thu phòng X, trong khi nhân viên buồng phòng lập biên bản hư hại mới cho phòng X (hoặc thay đổi trạng thái phòng X).
- **Kết quả mong muốn:** Không để trạng thái cuối mâu thuẫn (ví dụ phòng `Available` nhưng có biên bản `ChoXuLy` mới nhất). Ghi nhận kết quả thực tế của cả hai thứ tự thực thi.

### E8. Rollback khi bước 2 thất bại
- **Cách thực hiện:** Tạo tạm trigger `INSTEAD OF UPDATE` hoặc dùng `ALTER TABLE PHONG ADD CONSTRAINT ...` khiến `UPDATE PHONG ... 'Available'` ném lỗi, hoặc khóa dòng `PHONG` bằng một phiên khác (`BEGIN TRAN; UPDATE PHONG SET ... WHERE MaPhong='X'` không commit). Sau đó nghiệm thu từ web.
- **Kết quả mong muốn:** `BAOCAOHUHAI` **không** đổi sang `DaXuLy` (rollback toàn bộ). Người dùng thấy thông báo lỗi. Dọn dẹp trigger/constraint tạm sau khi test.
- **Bẫy:** Kiểm tra đúng việc `rollback` có thật sự hoàn tác `psReport` đã chạy trước đó trong cùng connection hay không.

### E9. Tham số rỗng, thiếu, khoảng trắng, độ dài lớn
- **Cách thực hiện:** `POST` các biến thể: thiếu `maBaoCao`; `maBaoCao=` ; `maPhong=%20%20`; `action` thiếu; `action=RESOLVE` (hoa); `action=delete`; mã dài 10.000 ký tự; mã chứa `'; DROP TABLE PHONG;--`; mã chứa Unicode `P１０１` (số full-width).
- **Kết quả mong muốn:** Không 500, không thay đổi dữ liệu, không SQL injection (câu lệnh dùng `PreparedStatement`; xác nhận `PHONG` còn nguyên). Điểm cần chú ý: khi `action` sai hoặc thiếu, hiện tại servlet im lặng redirect, ghi nhận có thông báo hay không.

### E10. Sai phương thức HTTP
- **Cách thực hiện:** `GET /manager/damages?action=resolve&maBaoCao=...&maPhong=...`; `POST /manager/revenue`; `POST /manager/dashboard`; `PUT/DELETE /manager/damages`.
- **Kết quả mong muốn:** `GET` với `action=resolve` **không** được thực thi nghiệm thu. Các phương thức lạ trả `405`. Không trường hợp nào đổi dữ liệu.

### E11. Chống CSRF
- **Cách thực hiện:** Dựng một trang HTML giả ở origin khác chứa `<form method="POST" action="http://localhost:8080/HotelManagerSystem/manager/damages">` với trường ẩn `action=resolve`, `maBaoCao`, `maPhong`. Quản lý đã đăng nhập mở trang giả đó.
- **Kết quả mong muốn:** Request bị chặn do thiếu CSRF token. Nếu nghiệm thu được thực thi, ghi **FAIL bảo mật** (hiện hệ thống chưa có token) kèm đề xuất cách khắc phục.

### E12. Phòng hư hại đã bị xóa hoặc biên bản mồ côi
- **Cách thực hiện:** Nếu FK cho phép (trên bản sao): xóa dòng `NHIEMVUDOPHONG` hoặc đổi `NhanVien` liên quan, rồi xem `/manager/damages`.
- **Kết quả mong muốn:** Trang vẫn hiển thị (nhờ `LEFT JOIN NHANVIEN`, cột người phát hiện rỗng/`null` không gây lỗi). Biên bản không có chi tiết (`CHITIETBAOCAOHUHAI` rỗng) sẽ **không xuất hiện** vì `INNER JOIN`; ghi nhận đây là điểm mù: phòng `Damaged` nhưng không thể nghiệm thu từ giao diện.

### E13. Phòng `Damaged` không có biên bản nào
- **Cách thực hiện:** `UPDATE PHONG SET TrangThai='Damaged'` cho một phòng mà không tạo biên bản.
- **Kết quả mong muốn:** Dashboard đếm phòng này là hỏng, nhưng `/manager/damages` **không** liệt kê. Phòng bị "khóa vĩnh viễn" mà Quản lý không có đường mở. Ghi nhận như lỗ hổng đối soát (đề xuất thêm công cụ mở khóa có lý do hoặc cảnh báo chênh lệch).

### E14. Nghiệm thu rồi Phase 2 có thấy phòng không (khép kín chu trình)
- **Cách thực hiện:** Nghiệm thu phòng `P103`. Đăng nhập khách hàng `VT01`, tìm phòng đúng khoảng ngày mong muốn.
- **Kết quả mong muốn:** `P103` xuất hiện lại trong `fn_TraCuuPhongTrongTheoYeuCau`. Nếu không thấy, kiểm tra nhiệm vụ dọn phòng `NHIEMVUDOPHONG` còn dở hoặc ràng buộc khác.

---

## NHÓM F — ĐỘ BỀN VỮNG & LỖI HẠ TẦNG

### F1. CSDL sập: số liệu giả "0" thay vì báo lỗi (**nghi ngờ FAIL**)
- **Cách thực hiện:** Dừng dịch vụ SQL Server (hoặc đổi sai mật khẩu `sa` trong cấu hình). Gọi lần lượt 4 route Manager.
- **Kết quả mong muốn:** Hiển thị trang lỗi/thông báo "Không kết nối được cơ sở dữ liệu". Tuyệt đối **không** hiển thị dashboard toàn số `0` và "doanh thu 0đ" như thể đó là dữ liệu thật.
- **Bẫy:** Mọi DAO bắt `Exception` rồi `printStackTrace()` và trả giá trị mặc định. Người quản lý có thể ra quyết định sai dựa trên số `0` giả. Với `resolveDamagedRoom`, lỗi kết nối trả `false` và hiện thông báo lỗi chung chung, hãy đối chiếu.

### F2. Rò rỉ kết nối (connection leak)
- **Cách thực hiện:** Dùng script gọi `/manager/dashboard` và `/manager/revenue` 500 lần liên tiếp (kể cả với tham số ngày sai). Theo dõi `SELECT COUNT(*) FROM sys.dm_exec_sessions WHERE program_name LIKE '%JDBC%'` trước/sau.
- **Kết quả mong muốn:** Số kết nối không tăng đều theo số request. Đặc biệt kiểm tra `MaintenanceDAO.resolveDamagedRoom` (phải trả `autoCommit` về `true` và đóng kết nối ở mọi nhánh, kể cả khi ném lỗi).

### F3. Tải đồng thời
- **Cách thực hiện:** 50 luồng song song gọi `/manager/dashboard` và `/manager/services` trong 60 giây (dùng `ab`, `hey` hoặc PowerShell `ForEach-Object -Parallel`).
- **Kết quả mong muốn:** Không lỗi 500, không timeout, không rò rỉ. Servlet giữ `final` service dùng chung nhiều luồng nên phải kiểm tra không có trạng thái chia sẻ gây sai lệch giữa các request.

### F4. Mã hóa tiếng Việt xuyên suốt
- **Cách thực hiện:** Tạo biên bản hư hại với mô tả `Vỡ kính cửa sổ ban công, nệm rách 30cm, "điều hòa" hỏng — Đặng Thị Ánh`. Xem ở `/manager/damages`. Nghiệm thu và đọc thông báo flash `Phòng P103 ...`.
- **Kết quả mong muốn:** Mọi ký tự hiển thị đúng ở danh sách và thông báo. Không xuất hiện `?` hoặc `Ã¡`.

### F5. Thông báo flash không bị mất hoặc lặp
- **Cách thực hiện:** Nghiệm thu thành công, rồi F5 trang `/manager/damages` hai lần; mở thêm tab thứ hai.
- **Kết quả mong muốn:** Thông báo chỉ hiện **một lần** rồi biến mất. Ghi nhận: `ManagerDamageResolutionServlet` đặt `flashSuccess`/`flashError` vào session nhưng `doGet` không xóa; trang JSP phải tự xóa sau khi hiển thị, và JSP này **chưa tồn tại** (xem F6).

### F6. Các màn hình JSP chưa tồn tại (**chắc chắn FAIL**)
- **Cách thực hiện:** Đăng nhập `VT04`, gọi `/manager/revenue`, `/manager/services`, `/manager/damages`. Đối chiếu danh sách file trong `backend/src/main/webapp/views/manager/`.
- **Kết quả mong muốn:** Cả ba route hiển thị trang. **Dự báo thực tế:** thư mục hiện chỉ có `dashboard.jsp`, nên cả ba route trả `404` do `forward` tới `revenue_report.jsp`, `service_analytics.jsp`, `damages.jsp` không tồn tại. Ghi nhận **FAIL (thiếu tầng View)** và lập đề xuất tạo JSP (hoặc xác nhận View sẽ do React đảm nhiệm).
- **Lưu ý:** `dashboard.jsp` hiện chưa chắc đã đọc thuộc tính `occupancy`; kiểm tra xem nó vẫn dùng số liệu tĩnh cũ hay không.

---

## NHÓM G — KỊCH BẢN XUYÊN SUỐT PHASE 2 → 6 (ÉO LE NHẤT)

### G1. Vòng đời trọn vẹn của một phòng dưới con mắt Manager
- **Cách thực hiện:** Với một phòng `P` đang `Available`, thực hiện liên tục và **sau mỗi bước** đối chiếu dashboard + báo cáo doanh thu:
  1. Khách đặt online, đặt cọc (Phase 2).
  2. Lễ tân check-in, gọi 3 loại dịch vụ (Phase 3).
  3. Thu ngân quyết toán đa phương thức: nửa tiền mặt, nửa thẻ; check-out (Phase 4).
  4. Buồng phòng nhận dọn, phát hiện 2 loại hư hại, lập biên bản (Phase 5).
  5. Quản lý nghiệm thu (Phase 6).
  6. Khách mới tìm thấy phòng `P` trở lại (Phase 2).
- **Kết quả mong muốn:**
  - Tổng doanh thu chốt ca ngày = cọc + thanh toán quyết toán (đúng một lần, không đếm cọc hai lần).
  - `ThuTienMat` và `ThuTheNganHang` khớp từng đồng với những gì đã nhập ở Phase 4.
  - Doanh thu dịch vụ khớp 3 loại dịch vụ đã gọi.
  - Dashboard phản ánh đúng `Available→Occupied→Dirty→Cleaning→Damaged→Available`.
  - Phòng `P` xuất hiện lại ở tìm kiếm của khách.

### G2. Check-out lúc 23:59 và nghiệm thu lúc 00:01 hôm sau
- **Cách thực hiện:** Mô phỏng thanh toán `23:59`, nghiệm thu `00:01` (có thể đổi giờ hệ thống hoặc chèn tay `ThoiDiemThanhToan`). Chạy chốt ca hai ngày.
- **Kết quả mong muốn:** Doanh thu rơi đúng ngày thanh toán; ngày hôm sau có "1 phòng được mở lại" nhưng không có doanh thu liên quan.

### G3. Hai phòng, một biên bản giả định
- **Cách thực hiện:** Hai nhân viên buồng phòng cùng lập biên bản cho hai phòng khác nhau cùng lúc; Quản lý nghiệm thu đảo thứ tự.
- **Kết quả mong muốn:** Mỗi phòng đi đúng đường của nó, không lẫn trạng thái giữa hai phòng; số liệu dashboard khớp thực tế sau mỗi lần nghiệm thu.

### G4. Dọn dẹp sau test
- **Cách thực hiện:** Khôi phục từ bản backup (`RESTORE DATABASE`) hoặc đối chiếu `#SnapPhong` rồi trả trạng thái phòng về ban đầu; xóa trigger/constraint tạm ở E8.
- **Kết quả mong muốn:** CSDL về đúng trạng thái trước kiểm thử; liệt kê các thay đổi đã khôi phục.

---

## BẢNG TỔNG HỢP KẾT QUẢ (điền khi thực thi)

| Mã | Mức độ rủi ro dự báo | Kết quả | Ghi chú / Bằng chứng |
|:---|:---:|:---:|:---|
| A1 | Cao | 🟢 PASS | AuthFilter chặn 100% các role VT01, VT02, VT03 (trả HTTP 403). |
| A2 | Cao | 🟢 PASS | Không biến thể đường dẫn nào vượt qua được AuthFilter. |
| A3 | Trung bình | 🟢 PASS | Redirect 302 về /login, không có lệnh DB nào bị thực thi. |
| A4 | Thấp | 🔴 FAIL | Quyền lưu trong Session, chưa truy vấn DB kiểm tra realtime. |
| B1 | Trung bình | 🟢 PASS | NULLIF(COUNT(*), 0) và DAO fallback BigDecimal.ZERO an toàn. |
| B2 | Cao | 🟢 PASS | Tổng 4 nhóm khớp đúng tổng số phòng hiện có trong CSDL. |
| B3 | Thấp | 🔴 FAIL | SQL ROUND giữ scale 12 (16.670000000000%), chưa CAST sang DECIMAL(5,2). |
| B4 | Trung bình | 🟢 PASS | Trạng thái phòng phân định rõ, không có phòng bị đếm 2 lần. |
| B5 | Trung bình | 🟢 PASS | 100% phòng Occupied đều có booking DaCheckIn tương ứng. |
| C1 | **Rất cao** | 🔴 FAIL | **Mất sạch doanh thu:** Hàm dùng BETWEEN trên DATETIME 00:00:00. |
| C2 | Cao | 🟢 PASS | Dùng CAST(ThoiDiemThanhToan AS DATE) phân định ranh giới ngày chính xác. |
| C3 | Thấp | 🟢 PASS | Service chặn an toàn và trả BigDecimal.ZERO. |
| C4 | Cao | 🔴 FAIL | Bẫy nuốt lỗi: SQL Server ném ngoại lệ tràn ngày nhưng DAO trả về 0đ. |
| C5 | Cao | 🟢 PASS | Ràng buộc CHECK constraint CK_THANHTOAN_PhuongThuc bảo vệ toàn vẹn. |
| C6 | Trung bình | 🟢 PASS | Ràng buộc CHECK constraint CK_THANHTOAN_SoTien > 0 chặn số âm. |
| C7 | **Rất cao** | 🟢 PASS | SP ngày, View tháng, SP tháng, Function khoảng đồng bộ chính xác (6.500.000đ). |
| C8 | Trung bình | 🟢 PASS | Sắp xếp Nam DESC, Thang DESC chuẩn mực. |
| C9 | Thấp | 🟢 PASS | Trả về DTO toàn số 0 an toàn, không lỗi. |
| C10 | Thấp | 🔴 FAIL | SoDonDatMoi đếm cả đơn đã bị hủy trong ngày. |
| C11 | Trung bình | 🟢 PASS | SQL Server Read Committed ngăn chặn đọc dữ liệu chưa commit. |
| D1 | **Rất cao** | 🔴 FAIL | **Doanh thu ảo:** View không lọc b.TrangThai <> 'DaHuy'. |
| D2 | Thấp | 🟢 PASS | LEFT JOIN và ISNULL() trả số lượng 0, doanh thu 0đ đúng thiết kế. |
| D3 | Trung bình | 🟢 PASS | Tính theo bdv.DonGia lịch sử tại thời điểm đặt. |
| D4 | Thấp | 🔴 FAIL | Thiếu tie-breaker TenDichVu trong mệnh đề ORDER BY. |
| D5 | Cao | 🟢 PASS | JSTL/EL tự động escape XML, không thực thi script. |
| D6 | Thấp | 🟢 PASS | Kiểu dữ liệu DECIMAL(18,2) và BigDecimal an toàn. |
| E1 | Trung bình | 🔴 FAIL | INNER JOIN CHITIETBAOCAOHUHAI làm nhân bản số dòng hiển thị. |
| E2 | **Rất cao** | 🔴 FAIL | **Lỗ hổng bảo mật:** Cho phép mở khóa phòng đang có khách về Available. |
| E3 | **Rất cao** | 🔴 FAIL | Không kiểm tra MaPhong có thuộc MaBaoCao không. |
| E4 | Cao | 🔴 FAIL | executeUpdate() = 0 vẫn trả về true và hiện thông báo thành công. |
| E5 | Cao | 🔴 FAIL | Mở phòng khi còn sự cố khác chưa sửa xong. |
| E6 | Cao | 🟢 PASS | Transaction JDBC độc lập với autoCommit(false). |
| E7 | Cao | 🔴 FAIL | Thiếu khóa dòng UPDLOCK trên bảng PHONG. |
| E8 | Cao | 🔴 FAIL | **Nghiệm thu luôn lỗi:** Cập nhật 'DaXuLy' trong khi CHECK chỉ cho phép 'DaKhacPhuc'. |
| E9 | Cao | 🟢 PASS | Validate rỗng và dùng PreparedStatement an toàn. |
| E10 | Cao | 🟢 PASS | GET chỉ đọc, POST mới xử lý ghi dữ liệu. |
| E11 | Cao | 🔴 FAIL | Form POST nghiệm thu chưa có CSRF Token. |
| E12 | Trung bình | 🔴 FAIL | INNER JOIN làm mất biên bản chưa kịp nhập chi tiết. |
| E13 | Cao | 🔴 FAIL | Phòng bị kẹt vĩnh viễn không có đường mở lại. |
| E14 | Trung bình | 🟢 PASS | Chuyển Available thì fn_TraCuuPhongTrongTheoYeuCau tìm thấy ngay. |
| F1 | **Rất cao** | 🔴 FAIL | DAO nuốt toàn bộ Exception và trả DTO rỗng. |
| F2 | Cao | 🟢 PASS | 100% DAO dùng try-with-resources đóng Connection đúng quy cách. |
| F3 | Trung bình | 🟢 PASS | Service và DAO là Stateless, an toàn đa luồng. |
| F4 | Trung bình | 🟢 PASS | UTF-8 và NVARCHAR lưu trữ và hiển thị tiếng Việt hoàn hảo. |
| F5 | Trung bình | 🔴 FAIL | Thông báo không được xóa khỏi Session sau khi hiển thị. |
| F6 | **Chắc chắn** | 🔴 FAIL | *(Phần Frontend: Thiếu 3 trang JSP views/manager)* |
| G1 | Cao | 🟢 PASS | Chuỗi chu trình trạng thái phòng thông suốt qua các Stored Procedure. |
| G2 | Trung bình | 🟢 PASS | Doanh thu gắn với thời điểm thanh toán hóa đơn. |
| G3 | Trung bình | 🟢 PASS | Khóa chính phòng và nhiệm vụ phân lập hoàn toàn. |
| G4 | — | 🟢 PASS | Đã sao lưu bản backup đầy đủ trước khi thực thi. |

**Tổng cộng: 51 test case | PASS: 31 | FAIL: 19 | BLOCKED: 0.**
> Chi tiết nguyên nhân gốc rễ và đề xuất Before / After được lưu trữ tại file: `BAO_CAO_TEST_VA_DE_XUAT_SUA_LOI_PHASE6.md`.

