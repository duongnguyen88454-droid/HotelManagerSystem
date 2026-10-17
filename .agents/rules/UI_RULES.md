# QUY TẮC THIẾT KẾ UI BẮT BUỘC (UI_RULES)

> Áp dụng cho **mọi lập trình viên và mọi AI Agent** (Gemini, Claude, Copilot...) làm việc với `.jsp`, `.css`, `.js` trong `backend/src/main/webapp/`.
> File này **bổ sung** cho `GEMINI.md` (đề xuất → thẩm định → duyệt rồi mới sửa code) và `ARCHITECTURE_RULES.md` (backend). **Không thay thế** hai file đó.
> Vị trí đề xuất trong repo: `.agents/rules/UI_RULES.md`.
> Số liệu "hiện trạng" đo trên bản mã nguồn `HotelManagerSystem.zip` (17/10/2026).

---

## 0. Vì sao có file này

### 0.1. Mục tiêu
**Thống nhất toàn bộ giao diện về MỘT hệ thiết kế duy nhất, mà KHÔNG thay đổi bất kỳ chức năng nào.** Công việc này chỉ là "thay áo": đổi cách trình bày (màu, cỡ chữ, khoảng cách, bo góc, tên class, cấu trúc CSS), không đổi hành vi.

### 0.2. Hiện trạng đã đo (lý do UI đang rối)

| # | Vấn đề | Số liệu đo được |
|---|---|---|
| 1 | **Style viết thẳng trong HTML** | **1.740** thuộc tính `style="..."` trải trên **30/32** file JSP. Nặng nhất: `hotel_config.jsp` (272), `booking_detail.jsp` (124), `booking_form.jsp` (118), `tasks.jsp` (110), `room_list.jsp` (105). `navbar.jsp` (24) gần như **toàn bộ inline**, các trang khách (`room_list`, `booking_form`, `home`) **không dùng class nút/thẻ nào** của `style.css`. |
| 2 | **Quá nhiều màu** | **120** mã hex khác nhau. Cùng một ý nghĩa nhưng nhiều mã: chữ phụ có `#718096`, `#64748b`, `#475569`, `#4a5568`; viền có `#e2e8f0`, `#cbd5e0`, `#cbd5e1`; đỏ có `#dc2626`, `#e53e3e`, `#c53030`, `#b91c1c`, `#ef4444`, `#991b1b`. Hai bảng màu pha trộn: Tailwind-slate (`#475569`...) lẫn Tailwind-cũ/Chakra (`#4a5568`, `#e53e3e`...). |
| 3 | **Hai hệ biến CSS song song** | `style.css` dùng `--primary-color`, `--text-main`...; `portal_layout.css` dùng `--portal-primary`, `--portal-text-primary`... Hai màu chủ đạo khác nhau: `#1a365d` và `#1e3a8a`. |
| 4 | **Ba hệ nút bấm** | `.btn*` (`style.css`), `.portal-btn*` (`portal_layout.css`), `.pms-btn*` (copy y hệt trong **3** file CSS lễ tân). Ba bộ có bo góc, padding, font-weight khác nhau. |
| 5 | **Cùng một class, nhiều định nghĩa mâu thuẫn** | `.badge-occupied` định nghĩa ở **5** file với 3 kiểu hiển thị khác nhau (nền đỏ đặc / nền hồng nhạt / `#b91c1c` đặc). `.badge-partial` ở 5 file, `.page-header`, `.page-title`, `.nav-breadcrumbs`, `.table-card`, `.empty-state`... lặp ở 2–4 file. Trang nào nạp file CSS nào sẽ ra giao diện khác. |
| 6 | **Hai hệ modal, hai hệ tab, hai hệ phân trang** | Modal: `.portal-modal-*` vs `.pms-modal-*`. Tab: `.portal-tabs` vs `.config-tab-content`. Phân trang: `.report-pagination-*` vs `.portal-pagination-bar`. |
| 7 | **Bo góc, cỡ chữ không có thang** | 15 kiểu `border-radius` (2px, 3px, 4px, 5px, 6px, 8px, 10px, 12px, 14px, 16px, 30px...). Ít nhất 25 cỡ chữ (11px, 11.5px, 12px, 12.5px, 13px, 13.5px, 14px, 14.5px, 15px...). Chữ 11px xuất hiện 56 lần. |
| 8 | **Nạp CSS không nhất quán** | Trang portal tự thêm `<link portal_layout.css>` sau `header.jsp`; vài trang khách đặt `<link>` **giữa thân trang** (`booking_detail.jsp` dòng 10, `booking_form.jsp` dòng 565). |
| 9 | **JS ghi màu trực tiếp** | `tasks.js` gán `style.background = '#dc2626'`...; `checkin.js`, `room_map.js` sinh HTML kèm `style="color:#15803d"`. |
| 10 | **Gần như chưa responsive** | Toàn bộ CSS chỉ có 3 `@media`: 2 cái `print` và 1 cái `max-width: 768px` trong `landing.css`. |
| 11 | **Một số `<style>` nằm trong JSP** | `revenue_report.jsp` (11 dòng). |

### 0.3. Điều **đã tốt** và phải giữ
- **Không dùng icon/emoji** ở bất kỳ đâu (đã kiểm tra: 0 emoji, 0 thư viện icon; `portal_layout.css` có ghi rõ quy định này). **Giữ nguyên**, xem UI 4.9.
- Cấu trúc Portal "Sidebar trái + Workspace phải" của `portal_layout.css` (nhân viên) là khung tốt, dùng làm chuẩn cho khu nhân viên.
- Dữ liệu trạng thái phòng/thanh toán đã có sẵn ngôn ngữ màu ngầm (xanh = trống/đã trả, đỏ = đang ở/chưa trả, vàng/cam = chờ/dọn). Quy tắc này chỉ **chuẩn hóa** lại.

### 0.4. Vì sao quy tắc cần nhiều lớp
Quy tắc chỉ nằm trên giấy thì sẽ bị bỏ qua. Vì vậy mỗi quy tắc đều có **cách kiểm tra bằng lệnh** (mục 9) để AI/PR dán kết quả vào báo cáo.

---

## 1. Nguyên tắc vàng: BẤT BIẾN CHỨC NĂNG

**UI 1.1 – Không đổi hành vi.** Mọi thay đổi UI phải cho ra **cùng chức năng, cùng luồng, cùng dữ liệu**. Nếu một thay đổi thẩm mỹ buộc phải sửa logic để chạy được, **dừng lại** và đề xuất theo `GEMINI.md`.

**UI 1.2 – Danh sách "ĐƯỢC PHÉP / CẤM" khi sửa JSP**

| ĐƯỢC PHÉP | CẤM TUYỆT ĐỐI |
|---|---|
| Thêm / đổi / xóa thuộc tính `class` | Đổi hoặc xóa `id` |
| Xóa thuộc tính `style="..."` (chuyển thành class) | Đổi hoặc xóa `name` của input/select/textarea |
| Đổi thẻ bao ngoài thuần trình bày (`div` ↔ `section`) khi không có JS tham chiếu | Đổi `action`, `method`, `href`, `enctype`, `type` của form/nút/link |
| Sắp xếp lại thứ tự khối **thuần hiển thị** | Đổi, xóa, thêm `data-*`, `onclick`, `onsubmit`, `onchange` |
| Gộp, tách, đổi tên file CSS | Đổi cú pháp EL `${...}`, JSTL `<c:...>`, `<fmt:...>`, scriptlet `<% %>` |
| Đổi `<jsp:param title>` nếu chỉ sửa chữ hiển thị thống nhất theo UI 4.10 | Đổi `<jsp:param name="activeMenu"/"activeSubMenu">` (sidebar dựa vào đây) |
| | Đổi thứ tự các input trong form khi JS lấy theo chỉ số |
| | Thêm, bớt trường dữ liệu, cột bảng có dữ liệu thật (chỉ được đổi tiêu đề chữ theo UI 4.10) |
| | Sửa file `.java`, `.sql`, `web.xml` |

**UI 1.3 – "Khóa JS" (JS hook lock).** Trước khi đổi/xóa **bất kỳ class nào**, phải kiểm tra class đó có được JS dùng hay không:
```bash
# chạy trong backend/src/main/webapp
grep -rn "<tên-class>" assets/js views index.jsp --include=*.js --include=*.jsp | grep -E "getElementsByClassName|querySelector|classList|closest|\.className|\\$\\("
```
Class nào có mặt trong kết quả là **"class bị JS khóa"**: **KHÔNG được đổi tên hoặc xóa**. Chỉ được **thêm** class mới bên cạnh (xem UI 8.2).
Cũng áp dụng cho chuỗi class bên trong HTML do JS sinh ra (`innerHTML`, template string trong `checkin.js`, `room_map.js`, `tasks.js`...).

**UI 1.4 – Không đổi nội dung hiển thị của dữ liệu.** Giữ nguyên định dạng tiền, ngày, mã (`fmt:formatNumber`, `fmt:formatDate`...). Nếu muốn thống nhất định dạng (ví dụ luôn có hậu tố "VNĐ"), phải **đề xuất riêng** và chờ duyệt.

**UI 1.5 – Sửa JS rất hạn chế.** Mặc định **không sửa file `.js`**. Ngoại lệ duy nhất được xin phép (theo UI 7.3): thay `element.style.xxx = '#hex'` bằng `classList.add/remove('is-...')` khi **kết quả hiển thị y hệt**.

**UI 1.6 – Một lần một phạm vi.** Mỗi lần chỉnh sửa chỉ động vào một nhóm trang theo kế hoạch ở mục 8. Không "tiện tay" sửa thêm trang khác.

---

## 2. Kiến trúc file CSS/JS

### 2.1. Cây thư mục đích

```
assets/css/
├─ tokens.css          ← CHỈ chứa biến :root (màu, cỡ chữ, khoảng cách, bo góc, bóng đổ). Nơi DUY NHẤT được viết mã hex.
├─ base.css            ← reset, body, thẻ HTML thuần (h1–h6, a, hr, table mặc định), ẩn nút spin của input number
├─ components.css      ← .btn .card .form-* .table .badge .alert .modal .tabs .pagination .page-header ... (dùng chung MỌI khu)
├─ utilities.css       ← bộ class tiện ích nhỏ cố định (UI 4.12)
├─ layouts/
│   ├─ public.css      ← navbar công khai + footer + .container (khu khách / đăng nhập)
│   └─ portal.css      ← .portal-wrapper .portal-sidebar .portal-main ... (khu nhân viên)  (= phần khung của portal_layout.css hiện nay)
└─ <khu>/<trang>.css   ← giữ nguyên thư mục hiện có (booking/, cashier/, housekeeper/, home/, manager/, receptionist/) — CHỈ chứa bố cục riêng của đúng trang đó
```

- `style.css` và `portal_layout.css` hiện tại sẽ được **tách** vào các file trên (xem lộ trình mục 8), sau đó xóa.
- **Thứ tự nạp bắt buộc:** `tokens.css` → `base.css` → `components.css` → `utilities.css` → `layouts/*.css` → `<khu>/<trang>.css`.
  Trang sau chỉ được **bổ sung**, không được định nghĩa lại component ở trang trước.

### 2.2. Ba "khu" giao diện và khung dùng cho từng khu

| Khu | Ai dùng | Trang | Khung (layout) |
|---|---|---|---|
| **public** | Khách vãng lai, khách hàng | `index.jsp`, `home/home.jsp`, `room/*`, `booking/*`, `auth/*`, `common/error_403.jsp` | Navbar ngang + `.container` + Footer |
| **portal** | Lễ tân, buồng phòng, quản lý, thu ngân | `receptionist/*`, `housekeeper/*`, `manager/*`, `cashier/*` | `.portal-wrapper` = Sidebar trái + `.portal-main` |
| **landing** | Trang giới thiệu | `index.jsp`, `home/home.jsp` (+ `landing.css`) | Public shell, thêm khối hero/section riêng (class tiền tố `landing-`) |

Tất cả ba khu **dùng chung** `tokens.css + base.css + components.css`. Khác biệt giữa các khu chỉ nằm ở file `layouts/*` và CSS trang.

### 2.3. Cách nạp CSS (sửa `header.jsp` một lần)

Hiện `header.jsp` đóng luôn `</head>`, nên các trang phải chèn `<link>` vào thân trang (sai chuẩn HTML, gây nháy giao diện). Quy tắc mới:

**UI 2.3.1** `header.jsp` nhận hai tham số tùy chọn và nạp CSS **trong `<head>`**:
```jsp
<jsp:include page="/views/common/header.jsp">
    <jsp:param name="title"   value="Tên Trang" />
    <jsp:param name="zone"    value="portal" />                       <%-- public | portal --%>
    <jsp:param name="pageCss" value="cashier/cashier_dashboard.css" /> <%-- tùy chọn --%>
</jsp:include>
```
`header.jsp` nạp theo thứ tự UI 2.1: `tokens` → `base` → `components` → `utilities` → `layouts/${zone}.css` → `${pageCss}`.
**UI 2.3.2** Cấm `<link rel="stylesheet">` trong thân trang JSP.
**UI 2.3.3** Cấm `@import` trong CSS. Cấm CDN, thư viện CSS ngoài (Bootstrap, Tailwind, FontAwesome...). Dự án tự chủ bằng CSS thuần.
**UI 2.3.4** Cấm khối `<style>` trong JSP (hiện còn `revenue_report.jsp`) → chuyển sang file CSS của trang.
**UI 2.3.5** Cache-busting `?v=<%= System.currentTimeMillis() %>` đang có ở `tasks.js`, `checkin.js` là logic nạp script, **giữ nguyên**, không thuộc phạm vi UI.

### 2.4. Quy tắc viết CSS

| Mã | Quy tắc |
|---|---|
| UI 2.4.1 | **Mã hex / `rgb()` / `rgba()` chỉ được xuất hiện trong `tokens.css`.** Mọi nơi khác dùng `var(--...)`. Ngoại lệ duy nhất: `rgba(15,23,42,x)` cho lớp phủ/bóng đổ phải được khai báo thành token (`--shadow-*`, `--overlay`). |
| UI 2.4.2 | **Cấm `!important`.** Ngoại lệ đã có: quy tắc ẩn navbar/footer công khai trong portal (`body:has(.portal-wrapper)...`) và `@media print`. |
| UI 2.4.3 | **Cấm selector theo `id`** (`#abc {}`) để tạo kiểu. `id` chỉ dành cho JS và `label for`. |
| UI 2.4.4 | **Độ sâu selector tối đa 3 cấp** (`.a .b .c`). Cấm dùng thẻ + class + class + class. |
| UI 2.4.5 | **CSS của trang phải có tiền tố tên trang** cho mọi class riêng: `.checkin-*`, `.roommap-*`, `.timeline-*`, `.damage-*`, `.hotelcfg-*`, `.revenue-*`, `.invoice-*`. Cấm đặt class tên chung (`.page-title`, `.table-card`, `.info-grid`...) trong CSS trang vì đó là việc của `components.css`. |
| UI 2.4.6 | **Một class component chỉ được định nghĩa MỘT lần trong toàn dự án** (tại `components.css`). CSS trang chỉ được **tinh chỉnh** bằng selector có tiền tố trang: `.checkin-toolbar .btn { ... }`. |
| UI 2.4.7 | Giá trị số cho `padding/margin/gap/font-size/border-radius/box-shadow` phải lấy từ **token** (UI 3). Cấm số lẻ kiểu `12.5px`, `13.5px`, `14.5px`. |
| UI 2.4.8 | Đơn vị: `px` cho cỡ chữ, khoảng cách, bo góc; `%`, `fr`, `minmax()` cho bố cục; `rem` không dùng trộn lẫn (đã chọn `px`). |
| UI 2.4.9 | Mỗi file CSS trang ≤ **250 dòng**. Vượt thì tách theo khối chức năng (tránh tái diễn các file như `hotel_config.jsp` 1.137 dòng). |
| UI 2.4.10 | Thứ tự trong một rule: bố cục (`display`, `position`, `flex`, `grid`) → kích thước → khoảng cách → chữ → màu/viền → hiệu ứng. |

---

## 3. Design Tokens (nguồn sự thật duy nhất)

```css
:root {
  /* ---------- Thương hiệu ---------- */
  --color-primary:          #1a365d;   /* Navy chủ đạo: nút chính, tiêu đề, sidebar active */
  --color-primary-hover:    #2b6cb0;   /* Hover nút chính, link */
  --color-primary-soft:     #eff6ff;   /* Nền nhạt: hàng được chọn, vùng nhấn mạnh */
  --color-accent:           #c5a880;   /* Vàng kim — CHỈ khu public/landing (nút Đăng Ký, điểm nhấn) */
  --color-on-accent:        #1a365d;
  --color-link:             #2b6cb0;

  /* ---------- Trung tính (thang slate) ---------- */
  --color-bg:               #f4f6fa;   /* Nền trang */
  --color-surface:          #ffffff;   /* Nền thẻ, bảng, modal, sidebar */
  --color-surface-alt:      #f8fafc;   /* Nền header bảng, thanh công cụ, hàng hover */
  --color-border:           #e2e8f0;   /* Viền mặc định */
  --color-border-strong:    #cbd5e1;   /* Viền input, đường phân cách đậm */
  --color-text:             #0f172a;   /* Chữ chính */
  --color-text-secondary:   #475569;   /* Chữ phụ, nhãn */
  --color-text-muted:       #64748b;   /* Ghi chú, mô tả nhỏ (đạt AA trên nền trắng) */
  --color-text-disabled:    #94a3b8;   /* CHỈ placeholder và trạng thái disabled */
  --color-text-inverse:     #ffffff;

  /* ---------- Ngữ nghĩa (mỗi loại 5 sắc độ) ---------- */
  --color-success:          #15803d;
  --color-success-strong:   #166534;
  --color-success-soft:     #f0fdf4;
  --color-success-border:   #bbf7d0;
  --color-on-success-soft:  #15803d;

  --color-danger:           #dc2626;
  --color-danger-strong:    #b91c1c;
  --color-danger-soft:      #fef2f2;
  --color-danger-border:    #fecaca;
  --color-on-danger-soft:   #b91c1c;

  --color-warning:          #b45309;
  --color-warning-strong:   #92400e;
  --color-warning-soft:     #fffbeb;
  --color-warning-border:   #fde68a;
  --color-on-warning-soft:  #92400e;

  --color-info:             #2563eb;
  --color-info-strong:      #1d4ed8;
  --color-info-soft:        #eff6ff;
  --color-info-border:      #bfdbfe;
  --color-on-info-soft:     #1d4ed8;

  --color-neutral:          #64748b;
  --color-neutral-strong:   #475569;
  --color-neutral-soft:     #f1f5f9;
  --color-neutral-border:   #e2e8f0;
  --color-on-neutral-soft:  #475569;

  /* ---------- Chữ ---------- */
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;

  --fs-xs:  12px;   /* nhãn phụ, badge, chú thích — KHÔNG nhỏ hơn 12px */
  --fs-sm:  13px;   /* chữ bảng, nút, input, menu */
  --fs-md:  14px;   /* chữ thân mặc định */
  --fs-lg:  16px;   /* tiêu đề thẻ, chữ nhấn */
  --fs-xl:  20px;   /* tiêu đề trang (h1 trong portal) */
  --fs-2xl: 24px;   /* tiêu đề trang public, số KPI */
  --fs-3xl: 32px;   /* tiêu đề hero/landing */

  --fw-regular:  400;
  --fw-medium:   500;
  --fw-semibold: 600;
  --fw-bold:     700;     /* không dùng 800/900 */

  --lh-tight:  1.25;      /* tiêu đề */
  --lh-normal: 1.5;       /* chữ thân */

  /* ---------- Khoảng cách (bước 4px) ---------- */
  --space-1:  4px;
  --space-2:  8px;
  --space-3:  12px;
  --space-4:  16px;
  --space-5:  20px;
  --space-6:  24px;
  --space-8:  32px;
  --space-10: 40px;
  --space-12: 48px;

  /* ---------- Bo góc ---------- */
  --radius-sm:   4px;      /* badge vuông, tag nhỏ, thanh timeline */
  --radius-md:   8px;      /* nút, input, select, alert, ô nhỏ */
  --radius-lg:   12px;     /* thẻ, bảng, modal */
  --radius-pill: 9999px;   /* badge dạng viên thuốc, pill, avatar tròn */

  /* ---------- Bóng đổ & lớp phủ ---------- */
  --shadow-sm: 0 1px 2px rgba(15, 23, 42, 0.06);                         /* thẻ thường */
  --shadow-md: 0 4px 12px rgba(15, 23, 42, 0.08);                        /* dropdown, thẻ nổi khi hover */
  --shadow-lg: 0 12px 32px rgba(15, 23, 42, 0.18);                       /* modal */
  --overlay:   rgba(15, 23, 42, 0.5);                                    /* nền mờ phía sau modal */
  --focus-ring: 0 0 0 3px rgba(43, 108, 176, 0.25);

  /* ---------- Kích thước điều khiển ---------- */
  --control-h-sm: 30px;
  --control-h-md: 36px;    /* mặc định cho .btn và .form-control */
  --control-h-lg: 44px;    /* nút lớn: đăng nhập, thanh toán, xác nhận đặt phòng */

  /* ---------- Bố cục ---------- */
  --sidebar-w:    260px;
  --container-w:  1200px;
  --container-narrow-w: 480px;   /* đăng nhập / đăng ký */
  --container-form-w:   800px;   /* form một cột dài */

  /* ---------- Tầng z-index ---------- */
  --z-sticky:  20;
  --z-sidebar: 50;
  --z-modal:   100;
  --z-toast:   200;

  /* ---------- Chuyển động ---------- */
  --transition: 0.15s ease;      /* duy nhất một giá trị */
}
```

---

## 4. Thành phần (Components) & 5. Ngữ nghĩa màu & 6. Khung điều hướng & 7. Quy tắc JSP/JS

*(Xem chi tiết trong tài liệu thiết kế)*

---

## 8. Lộ trình chuyển đổi (từng Phase, có duyệt)

| Phase | Việc làm | Phạm vi file | Rủi ro | Nghiệm thu |
|---|---|---|---|---|
| **0 – Kiểm kê** (chỉ đọc, KHÔNG sửa) | Lập 4 báo cáo: (a) danh sách **class bị JS khóa** (UI 1.3); (b) bảng ánh xạ class cũ → chuẩn cho từng file CSS/JSP; (c) hex không có trong bảng 3.4; (d) danh sách inline style theo trang kèm đề xuất class | toàn bộ | Không | Người duyệt đồng ý bảng ánh xạ + danh sách class khóa |
| **1 – Nền tảng** | Tạo `tokens.css`, `base.css`, `components.css`, `utilities.css`, `layouts/public.css`, `layouts/portal.css` (**chưa nạp**) | CSS mới | Không (chưa hiển thị) | Mở được từng file, không lỗi cú pháp |
| **2 – Khung chung** | Sửa `header.jsp` (UI 2.3), `navbar.jsp`, `footer.jsp`, `portal_sidebar.jsp`, `error_403.jsp`; bật nạp CSS mới cho **các trang đã chuyển** | `views/common/*` | **Cao** — ảnh hưởng mọi trang | Duyệt tay: đăng nhập, mỗi vai trò vào được sidebar, active đúng mục, đăng xuất |
| **3 – Xác thực** | `auth/login.jsp`, `auth/register.jsp` | 2 JSP | Thấp | Đăng nhập/đăng ký hoạt động, thông báo lỗi hiển thị |
| **4 – Khu Thu ngân** (đã có CSS riêng sạch nhất) | `cashier/*` 4 JSP + 4 CSS | 8 file | Thấp | Thanh toán, hóa đơn, in hóa đơn (print) giống trước |
| **5 – Khu Lễ tân** | `receptionist/*` 5 JSP + `checkin.css`, `booking_form.css`, `room_map.css`, `timeline.css` | ~10 file | Trung bình (JS sinh HTML) | Check-in, sơ đồ phòng, timeline, đặt phòng, hoàn cọc |
| **6 – Khu Buồng phòng** | `housekeeper/*` 2 JSP + `tasks.js`/`damage_report.js` (nếu cần UI 7.3) | ~6 file | Trung bình | Nhận/hoàn thành nhiệm vụ, báo hư hại |
| **7 – Khu Quản lý** | `manager/*` 6 JSP; `hotel_config.jsp` làm **cuối cùng** và riêng một lượt | ~8 file | Cao (hotel_config 272 inline) | Cấu hình, nhân sự, doanh thu (phân trang), nghiệm thu hư hại, hoàn tiền |
| **8 – Khu Khách hàng** | `room/*`, `booking/*` | 6 JSP | Trung bình | Tìm phòng, giỏ, đặt cọc, lịch sử, chi tiết |
| **9 – Landing** | `index.jsp`, `home/home.jsp`, `landing.css` (đổi sang token, giữ bố cục hero) | 3 file | Thấp | Trang chủ đúng thiết kế, responsive |
| **10 – Dọn dẹp** | Xóa bí danh cũ (UI 3.2, UI 8.2), xóa `style.css`, `portal_layout.css`, các class chết; chạy lại toàn bộ kiểm tra mục 9 | toàn bộ | Trung bình | Đạt mục tiêu định lượng UI 9.2 |
