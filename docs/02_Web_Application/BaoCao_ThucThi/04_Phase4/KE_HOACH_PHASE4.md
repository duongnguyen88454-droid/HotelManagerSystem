# KE HOACH TRIEN KHAI GIAI DOAN 4 (PHASE 4)
# Phan He Thu Ngan - Quyet Toan & Tra Phong
# (Cashier Portal: Check-Out, Invoice & Payment - Role VT03)

---

> **Muc dich tai lieu nay:**
> - Dinh nghia ro rang **nhung gi Phase 4 phai dat duoc** de tranh di lech muc tieu.
> - Chia nho tung phan thanh **task cu the co the tick check** de AI va nhom de theo doi tien do.
> - Lam can cu **review code sau moi task** theo dung quy tac Propose - Review - Approve.

**Trang thai:** Dang trien khai | **Bat dau:** 03/10/2026

---

## TONG QUAN LUONG NGHIEP VU PHASE 4

```
Phase 3 (DAU VAO)               Phase 4 (XU LY)                  Ket qua Cuoi
BOOKING.DaCheckIn        ──►    CHECK-OUT           ──►    BOOKING.DaCheckOut
BOOKING_PHONG            ──►    TINH TIEN PHONG     ──►    HOADON.TongTienCuoiCung
BOOKING_DICHVU           ──►    + TIEN DICH VU      ──►    THANHTOAN (da dot)
PHONG.Occupied           ──►    TRIGGER DON PHONG   ──►    PHONG.Dirty + NHIEMVUDOPHONG
```

**Nhan vat chinh trong Phase 4:** Nhan vien Thu Ngan (VT03)

| Bang | Vai tro trong Phase 4 |
|:---|:---|
| `BOOKING` | Cap nhat TrangThai -> DaCheckOut |
| `BOOKING_PHONG` | Ghi NgayCheckOutThucTe, tinh so dem thuc te |
| `BOOKING_DICHVU` | Tong hop dich vu phat sinh de lap hoa don |
| `HOADON` | Tao moi, luu TongTienCuoiCung, trang thai ChuaThanhToan -> DaThanhToanDu |
| `THANHTOAN` | Ghi nhan tung dot thanh toan (TienMat / TheNganHang / ChuyenKhoan) |
| `PHONG` | Trigger doi Occupied -> Dirty sau check-out |
| `NHIEMVUDOPHONG` | Tu dong tao task don phong cho Housekeeping |

---

## PHAN 1 - DATABASE LAYER (Tang CSDL)

> **Muc tieu:** Hoan thien toan bo Stored Procedures va Triggers phuc vu Phase 4.
> **File anh huong:** `database/04_Procedure.sql`, `database/05_Trigger.sql`

### Sprint 4.1-A - Stored Procedures

#### Task DB-01: `sp_CheckOut`
- [x] Input: @MaBooking VARCHAR(10), @MaNV VARCHAR(10), @MaPhong VARCHAR(10) = NULL
- [x] Logic: Validate trang thai DaCheckIn -> Ghi NgayCheckOutThucTe = GETDATE() -> Chi chuyen BOOKING.TrangThai = 'DaCheckOut' khi tat ca phong da check-out
- [x] Boc trong BEGIN TRANSACTION ... COMMIT / ROLLBACK (Da deploy & test thanh cong tren SQL Server)

#### Task DB-02: `sp_TaoHoaDon`
- [x] Input: @MaBooking VARCHAR(10), @MaNV VARCHAR(10), @MaHoaDonMoi VARCHAR(20) OUTPUT
- [x] Tinh TongTien = fn_TinhTongTienThucTePhaiTra(@MaBooking) (Phuong an B: ho tro tinh tam tinh khi con phong chua tra va chot tong khi da tra het)
- [x] INSERT/UPDATE vao HOADON voi TrangThai dong bo theo THANHTOAN, tra @MaHoaDonMoi OUTPUT
- [x] Constraint: 1 Booking chi co 1 hoa don (UQ_HOADON_MaBooking) - Da deploy & test thanh cong tren SQL Server

#### Task DB-03: `sp_GhiNhanThanhToan`
- [x] Input: @MaHoaDon, @MaNV, @SoTien DECIMAL(18,2), @PhuongThuc VARCHAR(20), @MaThanhToanMoi OUTPUT
- [x] Cho phep thanh toan tung phan trong luc luu tru (DaCheckIn)
- [x] RANG BUOC PHUONG AN B: Chan tat toan du 100% khi booking con phong chua Check-out
- [x] INSERT vao THANHTOAN -> Trigger trg_CapNhatTrangThaiHoaDon tu cap nhat HOADON.TrangThai -> Boc trong Transaction (Da deploy & test thanh cong tren SQL Server)

---

### Sprint 4.1-B - Triggers

#### Task TRG-01: `trg_DonPhongSauCheckOut`
- [x] Bang: BOOKING_PHONG, su kien: AFTER UPDATE (trg_TuDongDonPhongSauCheckOut)
- [x] Dieu kien: Khi NgayCheckOutThucTe thay doi tu NULL -> co gia tri
- [x] Hanh dong: Update PHONG.TrangThai = 'Dirty' + INSERT NHIEMVUDOPHONG (TrangThai = 'ChoXuLy') (Da test kich hoat tu dong)

#### Task TRG-02: Kiem tra trigger CheckIn tu Phase 3 khong xung dot
- [x] Xac nhan trg_DongBoTrangThaiPhongCheckIn hoat dong dung
- [x] Kiem thu: CheckIn -> Occupied; CheckOut -> Dirty; Don xong -> Available

---

**Tieu chi hoan thanh Phan 1:**
- [x] Ca 3 SP (sp_CheckOut, sp_TaoHoaDon, sp_GhiNhanThanhToan) chay thanh cong khi test bang sqlcmd
- [x] Trigger trg_TuDongDonPhongSauCheckOut tu kich hoat khi update NgayCheckOutThucTe
- [x] `mvn test "-Dcheckstyle.skip=true"` -> 7/7 ArchUnit Tests Passed

---

## PHAN 2 - DATA ACCESS LAYER (Tang DAO)

> **Muc tieu:** Xay dung cac lop DAO moi trong package `cashier.dao`.
> **File anh huong:** Tao moi trong `src/main/java/.../cashier/dao/`

#### Task DAO-01: `CheckOutDAO.java`
- [x] `executeCheckOutAll(String maBooking, String maNV)` -> goi sp_CheckOut, tra ve boolean
- [x] `executeCheckOutRoom(String maBooking, String maPhong, String maNV)` -> tra phong rieng le

#### Task DAO-02: `InvoiceDAO.java`
- [x] `createOrUpdateInvoice(String maBooking, String maNV)` -> goi sp_TaoHoaDon, tra ve String maHoaDon
- [x] `getInvoiceHeader(String maHoaDon)` -> JOIN HOADON + BOOKING + KHACHHANG + NHANVIEN
- [x] `getInvoiceRooms(String maBooking)` -> danh sach phong va tinh so dem thuc te
- [x] `getInvoiceServices(String maBooking)` -> danh sach BOOKING_DICHVU chi tiet
- [x] `findInvoiceIdByBooking(String maBooking)` -> tim hoa don theo ma booking

#### Task DAO-03: `PaymentDAO.java`
- [x] `recordPayment(maHoaDon, maNV, soTien, phuongThuc)` -> goi sp_GhiNhanThanhToan
- [x] `getPaymentHistory(String maHoaDon)` -> danh sach dot da thanh toan
- [x] `getTotalPaid(String maHoaDon)` -> tong da thanh toan

#### Task DAO-04: `ActiveBookingDAO.java`
- [x] `findCheckedInBookings(String keyword)` -> tim booking DaCheckIn theo ten/CCCD/SDT/MaBooking (STRING_AGG + COUNT + SUM SoPhongChuaTra)
- [x] `hasUncheckedOutRooms(String maBooking)` -> kiem tra con phong nao chua Check-out khong

---

**Tieu chi hoan thanh Phan 2:**
- [x] Tat ca DAO nam trong package cashier.dao (khong de trong booking.dao)
- [x] Khong co DAO nao goi truc tiep sang DAO khac package
- [x] `mvn checkstyle:check` -> 0 Checkstyle violations
- [x] `mvn test` -> 7/7 ArchUnit Tests Passed, BUILD SUCCESS

---

## PHAN 3 - SERVICE LAYER (Tang Service)

> **Muc tieu:** Lop Service dieu phoi nghiep vu giua cac DAO.
> **File anh huong:** Tao moi trong `src/main/java/.../cashier/service/`

#### Task SVC-01: `CheckOutService.java`
- [x] `processCheckOutAll(String maBooking, String maNV)`:
  - Goi CheckOutDAO.executeCheckOutAll()
  - Goi InvoiceDAO.createOrUpdateInvoice() ngay sau check-out thanh cong
  - Tra ve CheckOutResultDTO kem String maHoaDon cho Controller dieu huong
- [x] `processCheckOutRoom(String maBooking, String maPhong, String maNV)`:
  - Goi CheckOutDAO.executeCheckOutRoom()
  - Cap nhat hoa don tam tinh va bao tinh trang con phong chua tra

#### Task SVC-02: `InvoiceService.java`
- [x] `getFullInvoiceForDisplay(String maHoaDon)` -> tong hop InvoiceDetailDTO day du cho view (Header, Phong, Dich vu, Da tra, Con thieu)
- [x] `getInvoiceByBooking(String maBooking, String maNV)` -> tim hoac tao hoa don theo ma booking
- [x] `isFullyPaid(String maHoaDon)` -> kiem tra hoa don da thanh toan du chua

#### Task SVC-03: `PaymentService.java`
- [x] `processPayment(maHoaDon, maNV, soTien, phuongThuc)`:
  - Validate soTien > 0
  - Goi PaymentDAO.recordPayment()
  - Tra ve PaymentResultDTO kem ma giao dich va trang thai hoa don moi sau thanh toan
- [x] `getPaymentHistory(String maHoaDon)` -> danh sach lich su thanh toan
- [x] `calculateRemainingAmount(String maHoaDon)` -> tinh so tien con thieu

#### Bo sung: `ActiveBookingService.java`
- [x] `findCheckedInBookings(String keyword)` -> ho tro tim kiem don luu tru cho dashboard Thu Ngan
- [x] `hasUncheckedOutRooms(String maBooking)` -> kiem tra con phong nao chua Check-out khong

---

**Tieu chi hoan thanh Phan 3:**
- [x] Khong co Service nao import DAO tu package khac ngoai cashier.dao
- [x] Khong co Service nao dung java.sql.* hoac javax.servlet.* (Tuan thu tuyet doi QT 3.2)
- [x] `mvn checkstyle:check` -> 0 Checkstyle violations
- [x] `mvn test` -> 7/7 ArchUnit Tests Passed, BUILD SUCCESS

---

## PHAN 4 - CONTROLLER + VIEW LAYER (Tang Controller & JSP)

> **Muc tieu:** Xay dung giao dien Thu Ngan hoan chinh voi 3 man hinh chinh.
> **File anh huong:** Tao moi trong cashier/controller/ va webapp/views/cashier/

### Sprint 4.4-A - HTTP Servlets

#### Task CTL-01: `CashierDashboardServlet.java` - Dashboard Thu Ngan
- [x] Route: GET /cashier/dashboard
- [x] Hien thi danh sach booking can thu tien (ChuaThanhToan, MotPhan), ho tro tim kiem nhanh
- [x] Forward toi views/cashier/cashier_dashboard.jsp

#### Task CTL-02: `CashierBookingDetailServlet.java` & `CashierCheckOutServlet.java`
- [x] GET /cashier/booking-detail?maBooking=BK_XXXX -> Hien thi chi tiet tung phong, dich vu kem theo
- [x] POST /cashier/checkout -> Thuc hien check-out tung phong hoac toan bo phong duoc chon
- [x] Forward toi views/cashier/booking_detail.jsp va redirect sang /cashier/payment

#### Task CTL-03: `CashierPaymentServlet.java` & `CashierInvoiceServlet.java`
- [x] GET /cashier/payment?maHoaDon=HD_XXXX -> Hien thi 3 khoi tai chinh (Tong, Da tra, Con thieu), khong dung icon
- [x] POST /cashier/payment -> Ghi nhan dot thanh toan theo ca, ho tro thanh toan mot phan / toan bo
- [x] GET /cashier/invoice?maHoaDon=HD_XXXX -> Hien thi ban in hoa don quyet toan, nhat ky thu tien cac ca, nut in

---

### Sprint 4.4-B - Giao Dien JSP

#### Task UI-01: `cashier_dashboard.jsp` - Dashboard tong quan
- [x] Thanh tim kiem nhanh theo Ten, CCCD, SDT, Ma Booking
- [x] Bang danh sach booking can thu tien (ChuaThanhToan, MotPhan)
- [x] Nut [Chi Tiet & Tra Phong] dieu huong sang booking_detail.jsp
- [x] Khong su dung icon/emoji theo dung yeu cau cua User

#### Task UI-02: `booking_detail.jsp` - Chi tiet don & chon phong tra
- [x] Panel thong tin khach hang & Doi soat tai chinh
- [x] Bang danh sach phong voi co che checkbox rieng tung phong (ho tro multi-room khac ca)
- [x] Bang ke dich vu phat sinh theo phong
- [x] Form GET chuyen sang /cashier/payment (Chi Check-out dong thoi khi xac nhan thu tien theo Phuong an 2)

#### Task UI-03: `payment_form.jsp` - Man hinh thanh toan
- [x] 3 khoi thong ke tai chinh bat buoc: Tong tien booking, Da thanh toan, Con lai can thu
- [x] Form thanh toan: So tien (mac dinh con thieu, co nut chon nhanh), phuong thuc thanh toan
- [x] Bang lich su thanh toan cac ca lam viec
- [x] Phuong an 2: Gop Tra phong & Thu tien dong thoi, co nut Huy bo an toan
- [x] Tuyet doi khong dung icon/emoji

#### Task UI-04: `invoice_detail.jsp` - Ban in hoa don quyet toan
- [x] Tieu de khach san, thong tin booking, khach hang
- [x] Bang ke chi tiet tien phong & bang ke dich vu
- [x] Nhat ky giao dich thanh toan doi soat theo tung ca thu ngan
- [x] Tong ket tai chinh & khu vuc chu ky
- [x] Nut [In Hoa Don] (window.print()) va Print CSS an giao dien dieu huong

---

**Tieu chi hoan thanh Phan 4:**
- [x] Bon man hinh hoan thanh, khong loi 500
- [x] Luong 4 buoc chuan UX: Dashboard -> Chi tiet & Chon phong -> Thanh toan -> Hoa don
- [x] Tuyet doi khong dung icon tren giao dien
- [x] `mvn checkstyle:check` -> 0 violations
- [x] `mvn test` -> 7/7 ArchUnit Passed

---

## PHAN 5 - MODEL/DTO & KIEM THU

### Sprint 4.5-A - Data Transfer Objects

#### Task DTO-01: `InvoiceDetailDTO.java` & `InvoiceRoomItemDTO.java`
- [x] Fields: maHoaDon, maBooking, tenKhachHang, cccd, soDT, maKH, tenNVLap, ngayLap
- [x] Fields tai chinh: tongTienCuoiCung, daThanhToan, conThieu, trangThaiHoaDon
- [x] Collections: List<InvoiceRoomItemDTO> rooms, List<InvoiceServiceItemDTO> services

#### Task DTO-02: `InvoiceServiceItemDTO.java` & `ActiveBookingItemDTO.java`
- [x] Fields: maBookingDichVu, maPhong, tenDichVu, soLuong, donGia, thanhTien, thoiDiemThem
- [x] ActiveBookingItemDTO: maBooking, tenKhach, cccd, soDT, soPhongChuaTra, tongTien, soTienConNo

#### Task DTO-03: `PaymentRecordDTO.java`, `PaymentResultDTO.java`, `CheckOutResultDTO.java`
- [x] Fields: maThanhToan, maHoaDon, maNV, tenNV, soTien, phuongThucThanhToan, thoiDiemThanhToan

---

### Sprint 4.5-B - Kiem Thu Thu Cong

#### Task TST-01: `Run10TestCasesSprint41.java`
- [ ] TC01: CheckOut thanh cong -> BOOKING.TrangThai = 'DaCheckOut'
- [ ] TC02: CheckOut booking khong ton tai -> Exception voi message ro rang
- [ ] TC03: CheckOut booking dang DaXacNhan (chua CheckIn) -> Bi tu choi
- [ ] TC04: Sau CheckOut -> PHONG.TrangThai = 'Dirty' (trigger tu kich hoat)
- [ ] TC05: Sau CheckOut -> Bang NHIEMVUDOPHONG co ban ghi moi TrangThai = 'ChoXuLy'
- [ ] TC06: Tao hoa don -> TongTienCuoiCung = TienPhong + TienDichVu chinh xac
- [ ] TC07: Tao hoa don lan 2 cho cung 1 booking -> Bi tu choi (unique constraint)
- [ ] TC08: Thanh toan 1 dot (mot phan) -> HOADON.TrangThai = 'MotPhan'
- [ ] TC09: Thanh toan du tong tien -> HOADON.TrangThai = 'DaThanhToanDu'
- [ ] TC10: Thanh toan vuot qua so tien con lai -> Bi tu choi voi thong bao loi phu hop

---

**Tieu chi hoan thanh Phan 5:**
- [ ] 10/10 Test Case deu pass khong loi
- [ ] Tat ca DTO dat trong package cashier.dto
- [ ] `mvn war:exploded` -> BUILD SUCCESS

---

## TONG KET TIEU CHI CHAP NHAN (DEFINITION OF DONE) TOAN PHASE 4

| Tieu Chi | Kiem Tra Bang |
|:---|:---|
| 3 SP (sp_CheckOut, sp_TaoHoaDon, sp_GhiNhanThanhToan) hoat dong chinh xac | sqlcmd test truc tiep |
| Trigger trg_DonPhongSauCheckOut tu doi phong -> Dirty va tao NHIEMVUDOPHONG | Kiem tra bang sau CheckOut |
| Luong hoan chinh: Tim booking -> CheckOut -> Xem HD -> Thanh Toan -> Done | Test manual trinh duyet |
| Thanh toan da dot dung, tu dong cap nhat trang thai HD | TC08 + TC09 |
| Kien truc 3 tang khong bi vi pham | mvn test -> 7/7 ArchUnit Passed |
| 10 Test Cases thu cong deu PASS | File TST-01 |
| 3 man hinh load dung, khong loi 500 | Kiem tra trinh duyet |
| mvn war:exploded -> BUILD SUCCESS | Maven output |

---

## THU TU THUC HIEN DUOC KHUYEN NGHI

```
[Phan 1] DB: SP (DB-01, DB-02, DB-03) -> Trigger (TRG-01, TRG-02) -> Verify sqlcmd
         |
[Phan 5-A] DTO: InvoiceDTO, ServiceItemDTO, PaymentDTO
         |
[Phan 2] DAO: ActiveBookingDAO -> CheckOutDAO -> InvoiceDAO -> PaymentDAO
         |
[Phan 3] Service: CheckOutService -> InvoiceService -> PaymentService
         |  (mvn compile phai SUCCESS o day)
[Phan 4-A] Controller: CTL-01 -> CTL-02 -> CTL-03
         |
[Phan 4-B] JSP View: UI-01 -> UI-02 -> UI-03
         |
[Phan 5-B] Test: TST-01 (10 test cases)
```

**Quy tac bat buoc:**
- Tuan thu protocol Propose -> Review -> Approve truoc moi task code thuc thi (GEMINI.md).
- Moi Task hoan thanh -> danh dau [x] vao checkbox tuong ung de theo doi tien do.
- AI doc file nay dau moi phien lam viec de nam trang thai hien tai.

---
Tai lieu duoc lap ngay 03/10/2026 - Chuyen tiep tu Phase 3 sang Phase 4
Luu tru tai: docs/02_Web_Application/BaoCao_ThucThi/04_Phase4/KE_HOACH_PHASE4.md
