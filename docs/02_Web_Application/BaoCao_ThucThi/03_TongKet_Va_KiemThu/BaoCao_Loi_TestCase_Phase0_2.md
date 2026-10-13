# BAO CAO LOI - TEST CASES PHASE 0 -> PHASE 2
**Du an:** Hotel Management System - Nhom 10
**Ngay kiem thu:** 2026-09-30
**Tong test case chay:** 20
**Ket qua ban dau:** 13 PASS / 7 FAIL

---

## TOM TAT KET QUA

| ID   | Phase  | Ten Test Case                                                 | Ket qua | Nguyen nhan                          |
|------|--------|---------------------------------------------------------------|---------|--------------------------------------|
| TC01 | Phase0 | Server Tomcat dang chay                                       | PASS    | -                                    |
| TC02 | Phase0 | Trang dang nhap load duoc                                     | PASS    | -                                    |
| TC03 | Phase0 | Trang dang ky load duoc                                       | PASS    | -                                    |
| TC04 | Phase0 | Portal redirect dung khi chua dang nhap                        | PASS    | -                                    |
| TC05 | Phase1 | Dang ky tai khoan moi thanh cong                              | PASS    | -                                    |
| TC06 | Phase1 | Dang ky ten dang nhap trung (phai bi tu choi)                 | PASS    | -                                    |
| TC07 | Phase1 | Dang nhap sai mat khau (phai bi tu choi)                      | PASS    | -                                    |
| TC08 | Phase1 | Dang nhap dung tai khoan va mat khau                          | PASS    | -                                    |
| TC09 | Phase1 | Chuyen huong bao ve login khi chua dang nhap                  | PASS    | -                                    |
| TC10 | Phase2 | Tim phong trong theo ngay hop le                              | PASS    | -                                    |
| TC11 | Phase2 | Tim phong voi checkOut <= checkIn (phai bao loi)              | PASS    | Khong co thong bao loi ro rang (BUG-02) |
| TC12 | Phase2 | Xem chi tiet phong tra ve thong tin day du                    | FAIL    | BUG-01 (script login sai field)      |
| TC13 | Phase2 | Tao booking 1 phong thanh cong voi thong tin khach day du     | FAIL    | BUG-01 (khong lay duoc phong)        |
| TC14 | Phase2 | Tao booking voi CCCD sai dinh dang (phai bi tu choi)         | FAIL    | BUG-01 (khong lay duoc phong)        |
| TC15 | Phase2 | Xem lich su dat phong sau khi tao                             | PASS    | -                                    |
| TC16 | Phase2 | Xem chi tiet booking vua tao                                  | FAIL    | BUG-01 (khong co booking ID)         |
| TC17 | Phase2 | Them phong vao gio hang                                       | FAIL    | BUG-01 (khong lay duoc phong)        |
| TC18 | Phase2 | Xem gio hang hien thi du lieu                                 | PASS    | -                                    |
| TC19 | Phase2 | Race Condition: 2 phien dat cung phong cung luc               | FAIL    | BUG-01 (khong lay duoc phong)        |
| TC20 | Phase2 | Huy dat phong - TrangThai phai thanh DaHuy                   | FAIL    | BUG-03 (sai ten parameter POST)      |

---

## CHI TIET TUNG LOI

---

### BUG-01: Script test dung sai ten field de login -> Session khong duoc tao -> TC12-TC19 fail

**Muc do:** CRITICAL (lam fail 6 test cases: TC12, TC13, TC14, TC16, TC17, TC19)

**Mo ta:**
Script test `run_20_testcases.ps1` gui `POST /login` voi body `{ username=...; password=... }`.
Tuy nhien, `LoginServlet.java` doc field `loginIdentifier` (email) chu KHONG PHAI `username`.
Ket qua: login luon that bai, session `CURRENT_USER` khong duoc tao.
`AuthFilter` phat hien khong co session -> redirect ve `/login`.
Trang `/customer/search-rooms` tra ve HTML trang login (status 200 nhung noi dung la trang login).
Regex trong script khong tim thay `maPhong=` trong HTML login -> `$AVAILABLE_ROOM = null` -> TC12-TC19 deu fail.

**Bang chung:** File `search_page.html` (da luu tu debug) chua `<title>Dang Nhap He Thong</title>` thay vi danh sach phong.

**Nguyen nhan goc:** Khong dong bo giua ten field HTML (`loginIdentifier`) va ten field trong script test (`username`).
Form dang ky chi co: `hoTen`, `email`, `password`, `confirmPassword` -- KHONG co `username` hay `soDienThoai`.

**Vi tri loi:** `run_20_testcases.ps1` -- cac dong POST toi `/login` va `/register`
**File anh huong:** Script test (KHONG phai code ung dung)

---

**Code TRUOC khi fix** (script test):

```powershell
# TC08 - Dang nhap
$body = @{ username = $TEST_USER; password = $TEST_PASS }

# TC05 - Dang ky
$body = @{
    username    = $TEST_USER      # SAI: khong ton tai trong form
    password    = $TEST_PASS
    hoTen       = "Test User TC05"
    email       = $TEST_EMAIL
    soDienThoai = $TEST_PHONE     # SAI: khong ton tai trong form register
}

# Login o cac TC khac dung $TEST_USER thay vi email
$lb = @{ username = $TEST_USER; password = $TEST_PASS }
```

**Code SAU khi fix** (script test):

```powershell
# TC08 - Dang nhap: dung loginIdentifier (email) theo LoginServlet.java
$body = @{ loginIdentifier = $TEST_EMAIL; password = $TEST_PASS }

# TC05 - Dang ky: chi co hoTen, email, password, confirmPassword
$body = @{
    hoTen           = "Test User TC05"
    email           = $TEST_EMAIL
    password        = $TEST_PASS
    confirmPassword = $TEST_PASS   # BẮT BUỘC theo form register
}

# Login o cac TC khac: dung loginIdentifier va email
$lb = @{ loginIdentifier = $TEST_EMAIL; password = $TEST_PASS }
```

---

### BUG-02: CustomerSearchRoomServlet khong validate checkOut > checkIn -- khong hien thi thong bao loi ro rang

**Muc do:** MEDIUM (TC11 PASS nhung ve UX la loi nghiem trong)

**Mo ta:**
Khi nguoi dung nhap ngay tra phong truoc ngay nhan phong, `CustomerSearchRoomServlet` khong kiem tra logic ngay, chi don gian chay query SQL.
SQL khong tra ve phong nao, nhung nguoi dung thay thong bao "Khong tim thay phong trong" thay vi loi ro rang "Ngay tra phong phai sau ngay nhan phong".

**Vi tri loi:** `CustomerSearchRoomServlet.java` -- phuong thuc `doGet()`

---

**Code TRUOC khi fix:**

```java
// CustomerSearchRoomServlet.java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    String checkIn  = request.getParameter("checkIn");
    String checkOut = request.getParameter("checkOut");
    // ... set defaults ...

    // THIEU: khong validate checkOut > checkIn
    try {
        List<AvailableRoomDTO> roomList = roomService.searchRooms(checkIn, checkOut, guests, roomType);
        request.setAttribute("roomList", roomList);
    } catch (IllegalArgumentException ex) {
        request.setAttribute("errorMessage", ex.getMessage());
    }
    // ...
}
```

**Code SAU khi fix:**

```java
// CustomerSearchRoomServlet.java
@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    String checkIn  = request.getParameter("checkIn");
    String checkOut = request.getParameter("checkOut");
    // ... set defaults ...

    // THEM: Validate ngay hop le truoc khi query
    try {
        LocalDate dateIn  = LocalDate.parse(checkIn.trim());
        LocalDate dateOut = LocalDate.parse(checkOut.trim());
        if (!dateOut.isAfter(dateIn)) {
            request.setAttribute("errorMessage",
                "Ngay tra phong phai sau ngay nhan phong it nhat 1 ngay!");
            request.setAttribute("roomList", new java.util.ArrayList<>());
        } else {
            List<AvailableRoomDTO> roomList = roomService.searchRooms(checkIn, checkOut, guests, roomType);
            request.setAttribute("roomList", roomList);
        }
    } catch (IllegalArgumentException ex) {
        request.setAttribute("errorMessage", ex.getMessage());
    } catch (java.time.format.DateTimeParseException ex) {
        request.setAttribute("errorMessage", "Dinh dang ngay khong hop le, vui long chon lai!");
    }
    // ...
}
```

---

### BUG-03: Script test gui `maBooking` thay vi `bookingId` khi POST huy booking

**Muc do:** MEDIUM (TC20 FAIL)

**Mo ta:**
`CustomerHistoryServlet.doPost()` doc parameter ten `bookingId` (dong 55).
Script test gui `maBooking` -> `bookingId = null` -> dieu kien cancel khong thoa man -> khong huy gi ca.

**Vi tri loi:** `run_20_testcases.ps1` -- TC20
**File anh huong:** Script test (KHONG phai code ung dung)

---

**Code TRUOC khi fix** (script test):

```powershell
# TC20
$body = @{ action = "cancel"; maBooking = $CREATED_BOOKING_ID }   # SAI: maBooking
```

**Code SAU khi fix** (script test):

```powershell
# TC20 -- dung ten parameter theo CustomerHistoryServlet.java dong 55
$body = @{ action = "cancel"; bookingId = $CREATED_BOOKING_ID }   # DUNG: bookingId
$cancelled = ($r.Content -match "cancelSuccess|DaHuy|huy thanh cong")
```

---

### BUG-04 (Tiem an): BookingDAO.cancelBooking() chi huy theo MaKH, khong ho tro MaTaiKhoan

**Muc do:** HIGH (anh huong user moi dang ky qua web khi MaDinhDanh null)

**Mo ta:**
`BookingDAO.cancelBooking(maBooking, maKH)` chi loc theo `MaKH`.
`CustomerHistoryServlet` truyen `maKH = currentUser.getMaDinhDanh()`.
Voi tai khoan moi tao qua web chua co MaDinhDanh (KH profile), `getMaDinhDanh()` = null
-> WHERE MaKH = null khong khop dong nao -> executeUpdate() = 0 -> return false -> huy that bai.

**Vi tri loi:** `BookingDAO.java` dong 245-259 (phuong thuc `cancelBooking`)

---

**Code TRUOC khi fix:**

```java
// BookingDAO.java
public boolean cancelBooking(String maBooking, String maKH) {
    String sql = "UPDATE BOOKING "
            + "SET TrangThai = 'DaHuy', ThoiDiemHuy = GETDATE() "
            + "WHERE MaBooking = ? AND MaKH = ? AND TrangThai = 'DaXacNhan'";
    // Chi loc theo MaKH -- neu MaKH null thi KHONG HUY DUOC
    try (Connection conn = DBContext.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, maBooking);
        ps.setString(2, maKH);
        return ps.executeUpdate() > 0;
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        return false;
    }
}
```

**Code SAU khi fix:**

```java
// BookingDAO.java -- ho tro ca MaKH va MaTaiKhoan
public boolean cancelBooking(String maBooking, String maKH, String maTaiKhoan) {
    String sql = "UPDATE BOOKING "
            + "SET TrangThai = 'DaHuy', ThoiDiemHuy = GETDATE() "
            + "WHERE MaBooking = ? "
            + "  AND TrangThai = 'DaXacNhan' "
            + "  AND (MaKH = ? OR (? IS NOT NULL AND MaTaiKhoan = ?))";
    // OR fallback: neu MaKH null/khong khop, thu MaTaiKhoan
    try (Connection conn = DBContext.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, maBooking);
        ps.setString(2, maKH);
        ps.setString(3, maTaiKhoan);
        ps.setString(4, maTaiKhoan);
        return ps.executeUpdate() > 0;
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
        return false;
    }
}
```

**Cac file can cap nhat them:**
- `BookingService.java`: sua signature `cancelBooking(maBooking, maKH)` -> `cancelBooking(maBooking, maKH, maTaiKhoan)`
- `CustomerHistoryServlet.java`: truyen them `maTaiKhoan` vao loi goi BookingService

---

## TONG KET

| Bug    | Muc do   | File can sua                                          | Loai thay doi           | Trang thai |
|--------|----------|-------------------------------------------------------|-------------------------|------------|
| BUG-01 | CRITICAL | run_20_testcases.ps1 (script test)                    | Fix ten field POST login | CHO DUYET  |
| BUG-02 | MEDIUM   | CustomerSearchRoomServlet.java                         | Them validate ngay      | CHO DUYET  |
| BUG-03 | MEDIUM   | run_20_testcases.ps1 (script test)                    | Fix ten param cancel     | CHO DUYET  |
| BUG-04 | HIGH     | BookingDAO.java + BookingService.java + CustomerHistoryServlet.java | Ho tro cancel qua MaTaiKhoan | CHO DUYET |

> BUG-01 la nguyen nhan day chuyen lam fail TC12->TC19.
> Sau khi fix BUG-01, can chay lai toan bo de xac nhan so luong PASS thuc te.

## KE HOACH SAU KHI DUOC DUYET

1. Fix BUG-01 + BUG-03 (script test) -> Chay lai 20 test cases
2. Fix BUG-02 (CustomerSearchRoomServlet.java) -> Chay lai TC11
3. Fix BUG-04 (BookingDAO + cascade) -> Chay lai TC20
4. Muc tieu cuoi: 20/20 PASS
