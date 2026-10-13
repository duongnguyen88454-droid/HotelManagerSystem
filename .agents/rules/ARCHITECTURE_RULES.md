# QUY TẮC KIẾN TRÚC BẮT BUỘC (ARCHITECTURE_RULES)

> Áp dụng cho **mọi lập trình viên và mọi AI Agent** làm việc trong repo này.
> File này **bổ sung** cho `GEMINI.md` (đề xuất → thẩm định → duyệt rồi mới sửa code), **không thay thế**.
> Số liệu "hiện trạng" trong file này đo trên nhánh `phase3`, commit `62fb343`.

## 0. Vì sao có file này

Hai vấn đề đã xảy ra trong repo:

1. **`BookingDAO` dài 697 dòng.** Điều đáng chú ý: không method nào dài quá 50 dòng. Class phình ra vì nó ôm **30 method (10 public + 20 private) cho 4 trách nhiệm khác nhau**: ghi đặt phòng, quản lý dịch vụ trong booking, truy vấn lịch sử/chi tiết, và hóa đơn. Vì vậy quy tắc cần giới hạn cả **số dòng**, **số method** lẫn **trách nhiệm**, chứ giới hạn dòng đơn thuần chưa đủ.
2. **Controller gọi thẳng DAO** (`CustomerBookingServlet` → `CustomerDAO`, `ReceptionistPortalServlet` → `RoomDAO`), bỏ qua tầng service. Đi kèm là nghiệp vụ lọt vào controller: `CustomerBookingServlet.doPost` dài 94 dòng, độ phức tạp chu trình 31.

Quy tắc có **ba lớp bảo vệ**, vì quy tắc chỉ viết ra giấy thì sớm muộn sẽ bị bỏ qua:

| Lớp | Công cụ | Khi nào chạy | Kết quả khi vi phạm |
|---|---|---|---|
| 1 | Checkstyle (`config/checkstyle/`) | `mvn validate` (tự chạy trong `mvn package`) | **Build đỏ** |
| 2 | ArchUnit (`src/test/.../architecture/`) | `mvn test` | **Test đỏ** |
| 3 | Review + checklist ở mục 5.4 | Mỗi pull request | Không được merge |

---

## 1. Giới hạn kích thước và độ phức tạp

| Mã | Quy tắc | Mục tiêu (nên đạt) | **Ngưỡng cứng** (build đỏ) | Công cụ |
|---|---|---|---|---|
| QT 1.1 | Số dòng mỗi file `.java` | ≤ 200 | **300** | `FileLength` |
| QT 1.2 | Số dòng mỗi method | ≤ 30 | **50** | `MethodLength` |
| QT 1.3 | Độ phức tạp chu trình mỗi method | ≤ 10 | **15** | `CyclomaticComplexity` |
| QT 1.4 | Số tham số mỗi method/constructor | ≤ 4 | **6** | `ParameterNumber` |
| QT 1.5 | Số method mỗi class (dao, service, controller, filter, util) | ≤ 8 public | **12 public, 20 tổng** | `MethodCount` |

- **Miễn trừ:** `dto/` và `model/` được miễn QT 1.4 và QT 1.5 (getter/setter, constructor đầy đủ). Hai thư mục này vẫn bị QT 1.1.
- **Vì sao 300 dòng:** ngoài `BookingDAO` (697) và `BookingService` (307), mọi file Java trong repo đều ≤ 261 dòng. Ngưỡng 300 chặn được tái diễn mà không gây khó cho code hiện có.
- **QT 1.6 (cảnh báo sớm, 70% ngưỡng):** khi một file đạt **≥ 210 dòng** hoặc class đạt **≥ 9 public method**, người định thêm code **phải nêu kế hoạch tách trong PR trước khi thêm**. AI Agent phải **dừng và đề xuất** theo quy trình của `GEMINI.md`.

---

## 2. Một class một trách nhiệm

**QT 2.1 – Một DAO phụ trách một aggregate.** DAO chứa bảng gốc cùng các bảng con có vòng đời gắn chặt với nó. Bảng có vòng đời riêng (ví dụ `BookingDichVu`, `Invoice`) thì có lớp riêng. Khi một DAO vượt ~200 dòng, tách **ghi** và **đọc**: `XxxDAO` (ghi) và `XxxQueryDAO` (đọc).

**QT 2.2 – Giao dịch nhiều bảng.** Giữ transaction trong **một method public của DAO điều phối**. Các lớp phụ trợ trong cùng package là `package-private` và nhận `Connection` làm tham số. Không mở kết nối mới bên trong method được gọi giữa một transaction. **Service không bao giờ nhìn thấy `Connection`** (xem QT 3.2).

**QT 2.3 – Kế hoạch tách `BookingDAO` (đề xuất, phải qua quy trình duyệt của `GEMINI.md` trước khi làm).** Số dòng lấy từ vị trí các method hiện tại, là **ước lượng**:

| Lớp đề xuất | Trách nhiệm | Method hiện có chuyển sang | ~Dòng |
|---|---|---|---|
| `BookingDAO` (public, điều phối giao dịch) | Tạo và hủy đặt phòng | `createOnlineBookingWithServices`, `createMultiRoomBookingWithServices`, `cancelBooking`, `validateRoomAvailability`, `insertBookingHeader`, `insertBookingRoom`, `getNextBookingIdFromDB`, `rollbackTransaction`, `closeTransactionConnection` | ~230 |
| `BookingDichVuDAO` (public) | Thêm/bớt dịch vụ trong booking | `addServiceToBookingRoom`, `removeServiceFromBookingRoom`, `insertBookingServices`, `insertSingleBookingService`, `validateRoomBelongsToBooking`, `getActiveServicePrice`, `getBookingServiceCost`, `deleteBookingServiceRecord` | ~170 |
| `BookingQueryDAO` (public, chỉ đọc) | Lịch sử và chi tiết booking | `getBookingHistoryByCustomer`, `getBookingHistoryByAccountId`, `getBookingDetailById`, `executeBookingHistoryQuery`, `mapRowToBookingHistoryDTO`, `fetchBookingHeader`, `fetchBookingRooms`, `attachBookingServicesToRooms` | ~210 |
| `InvoiceWriter` (package-private, nhận `Connection`) | Hóa đơn và tổng tiền | `ensureInvoiceExists`, `updateBookingTotalCost` | ~40 |
| chuyển lên tầng khác | Tính toán thuần | `calculateNights` → `BookingDetailDTO` hoặc service | ~10 |

Lưu ý khi thực hiện: `getActiveServicePrice` trùng chức năng với `ServiceDAO` đã có, nên cân nhắc dùng lại thay vì giữ bản sao.

**QT 2.4 – Tên lớp.** Lớp mới **không được kết thúc bằng** `Manager`, `Helper`, `Misc`, `Common` (Checkstyle chặn). Tên lớp phải mô tả được bằng một cụm danh từ, không có "And"/"Và". Từ "Manager" vẫn được dùng khi là **vai trò nghiệp vụ** (ví dụ `ManagerPortalServlet`). `Util` chỉ dành cho hàm tĩnh thuần, không phụ thuộc tầng nào của ứng dụng.

**QT 2.5 – Cấm overload chỉ khác tham số tùy chọn.** Hiện `BookingService` có 6 cặp (`cancelBooking`, `createMultiRoomBooking`, `getBookingDetail`, ...) và `BookingDAO` có 2 cặp, đa số chỉ khác nhau ở `maTaiKhoan`. Dùng **một** method nhận đối tượng tham số (đã có `BookingRequestDTO`) hoặc đặt tên khác nghĩa. Overload cũ phải đánh dấu `@Deprecated` và xóa ở lần dọn dẹp kế tiếp.

---

## 3. Phân tầng và chiều phụ thuộc

Chiều gọi **duy nhất** được phép: `Controller → Service → DAO → (DB)`. Gọi ngược, hoặc nhảy cóc, đều bị cấm.

| Tầng | Được phép | **Cấm** | Công cụ chặn |
|---|---|---|---|
| **controller** (QT 3.1) | Gọi `service`; dùng `dto`, `model`, `util`; dùng `javax.servlet` | Import/gọi `dao.*`; dùng `java.sql.*`; dùng `DBContext` | ImportControl + ArchUnit |
| **service** (QT 3.2) | Gọi `dao`; dùng `dto`, `model` | Dùng `javax.servlet.*` (HttpSession...); dùng `java.sql.*` (dùng `java.time.LocalDate`, chuyển sang `java.sql.Date` ở DAO); gọi `controller` | ImportControl + ArchUnit |
| **dao** (QT 3.3) | `java.sql.*`, `DBContext`; trả về `dto`/`model` | Gọi `service`/`controller`; dùng `javax.servlet.*`; chứa tính toán nghiệp vụ | ImportControl + ArchUnit |
| **dto / model** (QT 3.4) | Chỉ chứa dữ liệu | Import `controller`/`service`/`dao`; dùng `javax.servlet.*` | ImportControl + ArchUnit |
| **filter, util** (QT 3.5) | `filter` dùng session/service; `util` độc lập | `filter` truy vấn DB trực tiếp; `util` phụ thuộc controller/service/dao/filter | ImportControl (ArchUnit chỉ kiểm thêm phần `filter`) |

**QT 3.1 – Controller mỏng.** Mỗi `doGet`/`doPost` chỉ làm ba việc: (1) đọc và kiểm tra **cú pháp** tham số, (2) gọi **một** method service, (3) đặt attribute rồi forward/redirect. Controller **không**: tính tiền hoặc ngày, quyết định quyền sở hữu dữ liệu, lặp xử lý nghiệp vụ, hay tự dựng SQL. Dấu hiệu nghiệp vụ đã lọt vào controller: method > 30 dòng hoặc độ phức tạp > 8. Khi thấy dấu hiệu này, chuyển phần đó xuống service.

**QT 3.3 – DAO chỉ làm việc với dữ liệu.** Phép kiểm tra **cần khóa hoặc cần nhất quán trong cùng transaction** (ví dụ chống đặt trùng phòng trong `validateRoomAvailability`) được phép ở DAO, nhưng phải ghi chú lý do ngay trên method. Tính toán nghiệp vụ (số đêm, tổng tiền, quyết định cho phép hay không) thuộc service.

**QT 3.6 – Giữa các feature (chỉ áp dụng sau khi chuyển sang chia theo feature).** Feature A muốn dùng dữ liệu của feature B thì gọi **service của B**, không gọi DAO của B. Không được có vòng phụ thuộc. Chiều cho phép đề xuất: mọi feature → `common`; `customer` → `room`; `auth` → `customer`; `booking` → `room`, `hotelservice`, `customer`, `auth`; `receptionist` → `room`. Tên feature **không được trùng tên tầng** (vì vậy domain dịch vụ khách sạn đặt là `hotelservice`, không đặt là `service`). Bật kiểm tra bằng cách đổi `FEATURE_BASED = true` trong `ArchitectureRulesTest` và dùng luật có sẵn trong `import-control.xml`.

---

## 4. Nợ kỹ thuật đã biết (baseline)

Các vi phạm dưới đây **được phép tồn tại tạm thời** (đang được miễn trong `checkstyle-suppressions.xml` và đóng băng trong kho ArchUnit). Tổng cộng **21 vi phạm trong 8 file**. Danh sách này **chỉ được ngắn lại, không được dài thêm** (xem QT 5.2).

| File | Vi phạm đo được | Hướng xử lý |
|---|---|---|
| `BookingDAO` | 697 dòng (QT 1.1); 30 method (QT 1.5); 2 method nhiều tham số: 9 và 7 (QT 1.4) | Tách theo QT 2.3; gom tham số vào DTO |
| `BookingService` | 307 dòng; 15 public method; `createBookingWithServices` 51 dòng và 7 tham số; `getBookingDetail` độ phức tạp 17; import `java.sql.Date` | Tách theo trách nhiệm; bỏ overload (QT 2.5); dùng `LocalDate` |
| `RoomService` | Import `java.sql.Date` | Dùng `LocalDate`, đổi kiểu ở DAO |
| `CustomerBookingServlet` | Import `CustomerDAO`; `doPost` 94 dòng, độ phức tạp 31; `doGet` độ phức tạp 17 | Tạo `CustomerService`; chuyển nghiệp vụ xuống service (QT 3.1) |
| `CustomerCartServlet` | `handleAddRoom` 92 dòng, độ phức tạp 23 | Chuyển xuống service |
| `ReceptionistPortalServlet` | Import `RoomDAO` | Gọi qua `RoomService` |
| `CustomerDAO` | `findOrUpsertGuestByCCCD` 112 dòng, độ phức tạp 26 | Tách thành các bước nhỏ; đưa quyết định nghiệp vụ lên service |
| `RoomDAO` | `searchAvailableRooms` 57 dòng | Tách phần dựng điều kiện và phần map kết quả |

**Chưa có công cụ tự động chặn** (cần review thủ công cho đến khi chuyển sang cấu trúc feature): `BookingService` gọi trực tiếp `RoomDAO` và `ServiceDAO` của domain khác (vi phạm QT 3.6).

---

## 5. Quy trình và các điều cấm

**QT 5.1 – Khi chạm ngưỡng.** Dừng thêm code vào class đó. Tách trước (hoặc trong cùng PR), rồi mới thêm tính năng. Mọi đề xuất tách đều đi theo quy trình `GEMINI.md`: nêu vấn đề, đưa Before/After, dừng chờ duyệt.

**QT 5.2 – Baseline chỉ được ngắn lại.**
1. Cấm thêm dòng mới vào `checkstyle-suppressions.xml` khi chưa được người duyệt kiến trúc đồng ý.
2. Sửa xong một nợ thì **xóa dòng miễn tương ứng trong cùng commit**.
3. Cấm thêm code mới vào class hoặc method đang nằm trong danh sách nợ; code mới đặt vào class mới.
4. Các dòng miễn dùng số dòng khai báo (`lines="..."`). Nếu bạn sửa phía trên một method nợ làm lệch số dòng, build sẽ đỏ. Hãy **refactor cho hết vi phạm**, đừng chỉ chỉnh lại số dòng.
5. Khuyến nghị thêm `CODEOWNERS` cho `/config/checkstyle/` và `/src/test/resources/archunit_store/` để mọi thay đổi ở đây bắt buộc có người duyệt kiến trúc.

**QT 5.3 – Các cách lách bị cấm.**
- Nâng ngưỡng trong `checkstyle.xml`.
- Thêm `@SuppressWarnings("checkstyle...")` (Checkstyle chặn riêng chuỗi này).
- Xóa hoặc sửa thư mục `archunit_store`, hoặc đặt `freeze.refreeze=true`.
- Nén code để giảm số dòng (nhiều lệnh một dòng, xóa dòng trống hoặc javadoc).
- Tách class "giả" chỉ để chứa phần thừa (`BookingDAO2`, `BookingDAOPart2`, `BookingDAOHelper`).
- Chuyển logic sang `util` hoặc phương thức `static` để né kiểm tra phân tầng.
- Dùng tên lớp đầy đủ hoặc reflection để né `import` (ArchUnit kiểm tra ở mức bytecode nên vẫn bắt được).

**QT 5.4 – Checklist cho người review PR.**
- [ ] `mvn -q validate` và `mvn -q test` đều xanh.
- [ ] Không có file nào vượt 210 dòng mà chưa nêu kế hoạch tách (QT 1.6).
- [ ] Controller mới/đã sửa chỉ gọi service; mỗi method controller làm đúng ba việc (QT 3.1).
- [ ] `checkstyle-suppressions.xml` và `archunit_store` không bị thêm vi phạm mới (chỉ được rút bớt).
- [ ] Lớp mới có tên mô tả đúng một trách nhiệm (QT 2.4); không thêm overload kiểu QT 2.5.

**QT 5.5 – Dành riêng cho AI Agent (Gemini, Claude, Copilot...).**
1. **Đọc file này trước khi sửa bất kỳ file `.java` nào.**
2. Trước khi báo "xong", chạy `mvn -q validate` (và `mvn -q test` sau khi đã bật ArchUnit), **dán kết quả vào báo cáo**.
3. Nếu build đỏ vì code do mình vừa viết: sửa code của mình. **Không** sửa ngưỡng, **không** thêm miễn trừ.
4. Nếu build đỏ vì nợ cũ bị lệch số dòng: đề xuất refactor theo `GEMINI.md` và dừng chờ duyệt, không tự chỉnh `checkstyle-suppressions.xml`.
5. Nếu yêu cầu của người dùng mâu thuẫn với quy tắc (ví dụ "gọi DAO trong controller cho nhanh"): nói rõ mâu thuẫn, đề xuất cách làm đúng tầng (thêm method vào service), không âm thầm vi phạm.
6. Khi được yêu cầu thêm tính năng vào class đã ≥ 210 dòng: đề xuất tạo class mới thay vì thêm vào class cũ.

---

## 6. Kích hoạt

1. Chép vào repo: `config/checkstyle/` (3 file), `src/test/java/.../architecture/ArchitectureRulesTest.java`, `src/test/resources/archunit.properties`, và file này vào `.agents/rules/`.
2. Gộp 3 phần trong `pom-additions.xml` vào `pom.xml`.
3. Chạy `mvn -q validate`. Với repo hiện tại kết quả phải **xanh** (nợ cũ đã được miễn).
4. Chạy `mvn -q test` lần đầu: ArchUnit tạo `src/test/resources/archunit_store`. **Commit thư mục này**, sau đó đổi `freeze.store.default.allowStoreCreation=false`.
5. Thêm `CODEOWNERS` như QT 5.2 mục 5. Nên thêm bước `mvn -B verify` vào CI nếu có.

**Cách đọc lỗi thường gặp:**

| Thông báo | Nghĩa là | Cách xử lý |
|---|---|---|
| `Disallowed import - ...dao...` trong controller | Controller gọi thẳng DAO | Thêm method vào service, controller gọi service |
| `Disallowed import - java.sql.Date` trong service | Service dùng kiểu JDBC | Dùng `java.time.LocalDate`, đổi kiểu ở DAO |
| `File length is N lines (max allowed is 300)` | Class quá lớn | Tách theo trách nhiệm (QT 2.1, 2.3) |
| `Total number of methods is N` | Class ôm nhiều trách nhiệm | Tách theo QT 2.1; không chỉ gộp bớt method |
| `Cyclomatic Complexity is N` / `Method ... length` | Method làm quá nhiều việc | Tách thành các method nhỏ; nghiệp vụ đưa xuống service |
