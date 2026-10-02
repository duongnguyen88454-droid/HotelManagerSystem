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
- [ ] Input: @MaBooking VARCHAR(10), @MaNV VARCHAR(10)
- [ ] Logic: Validate trang thai DaCheckIn -> Update BOOKING.TrangThai = 'DaCheckOut' -> Ghi NgayCheckOutThucTe = GETDATE()
- [ ] Boc trong BEGIN TRANSACTION ... COMMIT / ROLLBACK

#### Task DB-02: `sp_TaoHoaDon`
- [ ] Input: @MaBooking VARCHAR(10), @MaNV VARCHAR(10), @MaHoaDonMoi VARCHAR(20) OUTPUT
- [ ] Tinh TienPhong = DonGiaPhong * SoDemThucTe tu BOOKING_PHONG
- [ ] Tinh TienDichVu = SUM(DonGia * SoLuong) tu BOOKING_DICHVU
- [ ] Kiem tra tra phong muon sau 12:00 PM -> phu thu 50% don gia 1 dem
- [ ] TongTienCuoiCung = TienPhong + TienDichVu + PhuThu
- [ ] INSERT vao HOADON voi TrangThai = 'ChuaThanhToan', tra @MaHoaDonMoi OUTPUT
- [ ] Constraint: 1 Booking chi co 1 hoa don (UQ_HOADON_MaBooking da co)

#### Task DB-03: `sp_GhiNhanThanhToan`
- [ ] Input: @MaHoaDon, @MaNV, @SoTien DECIMAL(12,2), @PhuongThuc VARCHAR(20)
- [ ] INSERT vao THANHTOAN -> Tinh tong da tra -> Tu cap nhat HOADON.TrangThai
- [ ] Tong da tra >= Tong tien -> 'DaThanhToanDu' | Tong da tra < Tong tien -> 'MotPhan'
- [ ] Boc trong Transaction

---

### Sprint 4.1-B - Triggers

#### Task TRG-01: `trg_DonPhongSauCheckOut`
- [ ] Bang: BOOKING_PHONG, su kien: AFTER UPDATE
- [ ] Dieu kien: Khi NgayCheckOutThucTe thay doi tu NULL -> co gia tri
- [ ] Hanh dong: Update PHONG.TrangThai = 'Dirty' + INSERT NHIEMVUDOPHONG (TrangThai = 'ChoXuLy')

#### Task TRG-02: Kiem tra trigger CheckIn tu Phase 3 khong xung dot
- [ ] Xac nhan trg_DongBoTrangThaiPhongCheckIn hoat dong dung
- [ ] Kiem thu: CheckIn -> Occupied; CheckOut -> Dirty; Don xong -> Available

---

**Tieu chi hoan thanh Phan 1:**
- [ ] Ca 3 SP chay thanh cong khi test bang sqlcmd
- [ ] Trigger trg_DonPhongSauCheckOut tu kich hoat khi update NgayCheckOutThucTe
- [ ] `mvn test "-Dcheckstyle.skip=true"` -> 7/7 ArchUnit Tests Passed

---

## PHAN 2 - DATA ACCESS LAYER (Tang DAO)

> **Muc tieu:** Xay dung cac lop DAO moi trong package `cashier.dao`.
> **File anh huong:** Tao moi trong `src/main/java/.../cashier/dao/`

#### Task DAO-01: `CheckOutDAO.java`
- [ ] `executeCheckOut(String maBooking, String maNV)` -> goi sp_CheckOut, tra ve boolean

#### Task DAO-02: `InvoiceDAO.java`
- [ ] `createInvoice(String maBooking, String maNV)` -> goi sp_TaoHoaDon, tra ve String maHoaDon
- [ ] `getInvoiceDetail(String maHoaDon)` -> JOIN HOADON + BOOKING + KHACHHANG + NHANVIEN
- [ ] `getServiceBreakdown(String maBooking)` -> danh sach BOOKING_DICHVU chi tiet
- [ ] `findInvoiceByBooking(String maBooking)` -> kiem tra da co hoa don chua

#### Task DAO-03: `PaymentDAO.java`
- [ ] `recordPayment(maHoaDon, maNV, soTien, phuongThuc)` -> goi sp_GhiNhanThanhToan
- [ ] `getPaymentHistory(String maHoaDon)` -> danh sach dot da thanh toan
- [ ] `getTotalPaid(String maHoaDon)` -> tong da thanh toan

#### Task DAO-04: `ActiveBookingDAO.java`
- [ ] `findCheckedInBookings(String keyword)` -> tim booking DaCheckIn theo ten/CCCD/SDT/MaBooking
- [ ] `getBookingCheckOutDetail(String maBooking)` -> day du thong tin de lap hoa don

---

**Tieu chi hoan thanh Phan 2:**
- [ ] Tat ca DAO nam trong package cashier.dao (khong de trong booking.dao)
- [ ] Khong co DAO nao goi truc tiep sang DAO khac package
- [ ] `mvn compile` -> BUILD SUCCESS

---

## PHAN 3 - SERVICE LAYER (Tang Service)

> **Muc tieu:** Lop Service dieu phoi nghiep vu giua cac DAO.
> **File anh huong:** Tao moi trong `src/main/java/.../cashier/service/`

#### Task SVC-01: `CheckOutService.java`
- [ ] `processCheckOut(String maBooking, String maNV)`:
  - Goi CheckOutDAO.executeCheckOut()
  - Goi InvoiceDAO.createInvoice() ngay sau check-out thanh cong
  - Tra ve String maHoaDon cho Controller dieu huong

#### Task SVC-02: `InvoiceService.java`
- [ ] `getFullInvoiceForDisplay(String maHoaDon)` -> tong hop InvoiceDTO day du cho view
- [ ] `calculateRemainingAmount(String maHoaDon)` -> TongTien - TongDaTra
- [ ] `isFullyPaid(String maHoaDon)` -> kiem tra hoa don da thanh toan du chua

#### Task SVC-03: `PaymentService.java`
- [ ] `processPayment(maHoaDon, maNV, soTien, phuongThuc)`:
  - Validate soTien > 0 va khong vuot qua so con lai
  - Goi PaymentDAO.recordPayment()
  - Tra ve trang thai hoa don moi sau thanh toan

---

**Tieu chi hoan thanh Phan 3:**
- [ ] Khong co Service nao import DAO tu package khac ngoai cashier.dao
- [ ] `mvn test` -> 7/7 ArchUnit Tests Passed

---

## PHAN 4 - CONTROLLER + VIEW LAYER (Tang Controller & JSP)

> **Muc tieu:** Xay dung giao dien Thu Ngan hoan chinh voi 3 man hinh chinh.
> **File anh huong:** Tao moi trong cashier/controller/ va webapp/views/cashier/

### Sprint 4.4-A - HTTP Servlets

#### Task CTL-01: `CashierPortalServlet.java` - Dashboard Thu Ngan
- [ ] Route: GET /cashier/dashboard
- [ ] Hien thi danh sach booking DaCheckIn, ho tro tim kiem nhanh
- [ ] Forward toi views/cashier/cashier_dashboard.jsp

#### Task CTL-02: `CashierCheckOutServlet.java`
- [ ] GET /cashier/checkout?maBooking=BK_XXXX -> Hien thi chi tiet + preview hoa don
- [ ] POST /cashier/checkout -> Thuc hien check-out + tao hoa don, redirect sang trang thanh toan
- [ ] Forward toi views/cashier/checkout_invoice.jsp

#### Task CTL-03: `CashierPaymentServlet.java`
- [ ] GET /cashier/payment?maHoaDon=HD_XXXX -> Hien thi hoa don + lich su + form thanh toan
- [ ] POST /cashier/payment -> Ghi nhan 1 dot thanh toan, redirect refresh lai trang
- [ ] Forward toi views/cashier/payment.jsp

---

### Sprint 4.4-B - Giao Dien JSP

#### Task UI-01: `cashier_dashboard.jsp` - Dashboard tong quan
- [ ] 4 KPI Cards: Khach cho check-out hom nay | HD da thanh toan | Doanh thu hom nay | HD chua thanh toan
- [ ] Bang danh sach booking DaCheckIn: Ma Booking | Ten Khach | Phong | Ngay CheckIn | Ngay Tra DK | Trang Thai HD | Hanh Dong
- [ ] Nut [Xem HD & Tra Phong] dieu huong sang checkout_invoice.jsp
- [ ] O tim kiem nhanh

#### Task UI-02: `checkout_invoice.jsp` - Hoa don & xac nhan tra phong
- [ ] Panel thong tin khach: Ho ten, CCCD, SDT, Email
- [ ] Panel chi tiet phong: So phong | Loai phong | Ngay nhan TT | Ngay tra TT | So dem | Don gia/dem | Thanh tien
- [ ] Panel dich vu phat sinh: Ten dich vu | So luong | Don gia | Thanh tien | Thoi diem goi
- [ ] Panel tong ket: Tien phong + Tien dich vu + Phu thu (neu tra muon) = Tong tien (in dam, noi bat)
- [ ] Nut [Xac Nhan Tra Phong & Lap Hoa Don] -> POST den Servlet
- [ ] Canh bao mau do neu tra phong muon sau 12:00 PM

#### Task UI-03: `payment.jsp` - Man hinh thanh toan
- [ ] Panel hoa don (chi doc): Ma HD | Tong tien | Da thanh toan | Con lai + Progress bar
- [ ] Form thanh toan: Input so tien + Radio group (Tien mat / The Ngan Hang / Chuyen Khoan) + Nut xac nhan
- [ ] Bang lich su cac dot thanh toan: Thoi diem | So tien | Phuong thuc | Thu ngan
- [ ] Khi DaThanhToanDu -> Banner xanh la "Da Thanh Toan Du" + disabled form

---

**Tieu chi hoan thanh Phan 4:**
- [ ] Ba man hinh load duoc khong loi 500
- [ ] Luong day du: Tim booking -> Xem HD -> Xac nhan CheckOut -> Thanh Toan -> Hoan tat
- [ ] Sau CheckOut: Phong tu dong chuyen Dirty, task NHIEMVUDOPHONG duoc tao
- [ ] `mvn test` -> 7/7 ArchUnit Passed

---

## PHAN 5 - MODEL/DTO & KIEM THU

### Sprint 4.5-A - Data Transfer Objects

#### Task DTO-01: `InvoiceDTO.java`
- [ ] Fields: maHoaDon, maBooking, tenKhachHang, cccd, soDT, soPhong, loaiPhong
- [ ] Fields tai chinh: soNgayThucTe, donGiaPhong, tienPhong, tienDichVu, phuThu, tongTienCuoiCung
- [ ] Fields trang thai: trangThaiHoaDon, tongDaThanhToan, conLai
- [ ] Collections: List<ServiceItemDTO> danhSachDichVu, List<PaymentDTO> lichSuThanhToan

#### Task DTO-02: `ServiceItemDTO.java`
- [ ] Fields: tenDichVu, soPhong, soLuong, donGia, thanhTien, thoiDiemGoi, nguoiGoi

#### Task DTO-03: `PaymentDTO.java`
- [ ] Fields: maThanhToan, soTien, phuongThuc, thoiDiem, tenThuNgan

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
