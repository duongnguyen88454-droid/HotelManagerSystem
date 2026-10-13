# MỤC LỤC TỔNG QUAN: BÁO CÁO THỰC THI & KIẾN TRÚC PHẦN MỀM
## HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM) — NHÓM 10

> **Môn học:** Lập Trình Web (JSP/Servlet) & Hệ Quản Trị CSDL (DBMS330284) — HCMUTE  
> **Cấu trúc thư mục:** Được chuẩn hóa theo **Loại tài liệu chuyên biệt** giúp việc tra cứu, thẩm định và nghiệm thu của giảng viên/lập trình viên diễn ra mạch lạc, rõ ràng.

---

## 1. CẤU TRÚC PHÂN CẤP THƯ MỤC

```text
docs/02_Web_Application/BaoCao_ThucThi/
│
├── 📂 01_KeHoach_ThucThi/              # Kế hoạch chi tiết, lộ trình Sprint, Wireframe & API
│   └── 📄 KeHoach_ThucThi_GiaiDoan_3.md # Kế hoạch Phase 3: Timeline PMS, 4 Sprint, 20 TC, Wireframe thuần Text
│
├── 📂 02_BaoCao_KienTruc/              # Báo cáo kiến trúc 3 lớp MVC, Sequence Diagrams & Class Design
│   ├── 📄 BaoCao_ThucThi_GiaiDoan_0.md # Phase 0: Cấu hình Maven, Base UI, EncodingFilter, DBContext
│   ├── 📄 BaoCao_ThucThi_GiaiDoan_1.md # Phase 1: Xác thực, Phân quyền 4 vai trò qua AuthFilter, SHA-256
│   ├── 📄 BaoCao_ThucThi_GiaiDoan_2.md # Phase 2: Phân hệ Khách hàng, Luồng đặt phòng 5 bước, Chống Overbooking
│   └── 📄 BaoCao_ThucThi_GiaiDoan_3.md # Phase 3: Phân hệ Lễ tân, 12 Bước triển khai TDD, SP & Trigger Check-in
│
├── 📂 03_TongKet_Va_KiemThu/           # Biên bản tổng kết nghiệm thu, Kết quả Test Case & Sửa lỗi
│   ├── 📄 BaoCao_TongKet_GiaiDoan_2.md # Biên bản nghiệm thu Phase 2: 40/40 Test Cases PASS 100%
│   └── 📄 BaoCao_Loi_TestCase_Phase0_2.md # Nhật ký phân tích & khắc phục toàn bộ lỗi phát sinh (Phase 0 - 2)
│
└── 📄 README.md                        # Bản đồ chỉ mục điều hướng tổng quan (File hiện tại)
```

---

## 2. BẢNG TRA CỨU NHANH TÀI LIỆU THEO PHÂN LOẠI

### 📂 Thư Mục 1: Kế Hoạch Thực Thi (`01_KeHoach_ThucThi/`)
Tập hợp các tài liệu định hướng, phân rã chức năng con, phác thảo giao diện Wireframe và đặc tả API trước khi bước vào lập trình:

| STT | Tài Liệu | Giai Đoạn | Nội Dung Trọng Tâm | Trạng Thái |
|:---:|:---|:---:|:---|:---:|
| 1 | [KeHoach_ThucThi_GiaiDoan_3.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/01_KeHoach_ThucThi/KeHoach_ThucThi_GiaiDoan_3.md) | Giai đoạn 3 | Kế hoạch xây dựng phân hệ Lễ tân: Sơ đồ Timeline tuần, 3 Centered Popup Modal (Check-in, Xem phòng, Gọi dịch vụ), 4 Sprint Agile, 20 Test Cases và đặc tả 5 REST APIs. | Sẵn sàng thực thi |

---

### 📂 Thư Mục 2: Báo Cáo Kiến Trúc & Luồng Dữ Liệu (`02_BaoCao_KienTruc/`)
Tập hợp các bản thuyết minh kỹ thuật chuyên sâu, sơ đồ tuần tự (Sequence Diagrams), cấu trúc Class, DTO, DAO, Service và cơ chế tích hợp CSDL:

| STT | Tài Liệu | Giai Đoạn | Nội Dung Trọng Tâm | Trạng Thái |
|:---:|:---|:---:|:---|:---:|
| 1 | [BaoCao_ThucThi_GiaiDoan_0.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_0.md) | Giai đoạn 0 | Nền tảng dự án: `pom.xml`, `DBContext` kết nối SQL Server, `EncodingFilter` UTF-8, CSS Base Theme, trang chủ `index.jsp`. | Đã hoàn thành |
| 2 | [BaoCao_ThucThi_GiaiDoan_1.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_1.md) | Giai đoạn 1 | Phân hệ Tài khoản & Xác thực: Đăng nhập/Đăng ký, bảo vệ URL qua `AuthFilter` theo 4 vai trò (`VT01` -> `VT04`), mã hóa mật khẩu `SHA-256`. | Đã hoàn thành |
| 3 | [BaoCao_ThucThi_GiaiDoan_2.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_2.md) | Giai đoạn 2 | Phân hệ Khách hàng: Tra cứu phòng trống thời gian thực, luồng đặt phòng 5 bước phong cách quốc tế, thêm dịch vụ từng phòng, chống đặt trùng phòng (Overbooking). | Đã hoàn thành |
| 4 | [BaoCao_ThucThi_GiaiDoan_3.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_3.md) | Giai đoạn 3 | Phân hệ Lễ tân: 4 Nhóm ưu tiên, 12 bước triển khai TDD chi tiết, kế thừa Stored Procedure `sp_CheckInNhanPhong`, `sp_GoiThemDichVu`, Trigger `trg_DongBoTrangThaiPhongCheckIn`. | Sẵn sàng thực thi |

---

### 📂 Thư Mục 3: Tổng Kết Nghiệm Thu & Kiểm Thử (`03_TongKet_Va_KiemThu/`)
Tập hợp các biên bản nghiệm thu thực tế, kết quả chạy kịch bản kiểm thử tự động (Unit Test / Integration Test) và nhật ký sửa lỗi:

| STT | Tài Liệu | Giai Đoạn | Nội Dung Trọng Tâm | Trạng Thái |
|:---:|:---|:---:|:---|:---:|
| 1 | [BaoCao_TongKet_GiaiDoan_2.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_TongKet_GiaiDoan_2.md) | Giai đoạn 2 | Biên bản tổng kết nghiệm thu Giai đoạn 2: Toàn bộ **40/40 Test Cases (TC01 -> TC40) đạt PASS 100%**, minh chứng CSDL và luồng khách hàng hoàn hảo. | Nghiệm thu PASS |
| 2 | [BaoCao_Loi_TestCase_Phase0_2.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_Loi_TestCase_Phase0_2.md) | Phase 0 - 2 | Nhật ký điều tra lỗi kỹ thuật: Khắc phục lỗi khóa ngoại, đồng bộ UTF-8, sửa lỗi tính tiền giỏ hàng, chuẩn hóa sinh mã `KeyGenerator`. | Đã khắc phục 100% |
| 3 | [BaoCao_KiemThu_FN31.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/docs/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_KiemThu_FN31.md) | Giai đoạn 3 | Báo cáo kiểm thử chức năng FN-3.1: Toàn bộ **20/20 Test Cases (TC-3.1.01 -> TC-3.1.20) đạt PASS 100%**, tải đủ 12 phòng theo 4 tầng, khớp KPI buồng phòng thời gian thực, 0 emoji, 0 icon font. | Nghiệm thu PASS |

---

## 3. NGUYÊN TẮC QUẢN LÝ TÀI LIỆU DỰ ÁN
1. **Chuẩn mã hóa UTF-8:** Toàn bộ tài liệu markdown bắt buộc lưu trữ dưới định dạng UTF-8 chuẩn, tuyệt đối không để xảy ra lỗi hiển thị tiếng Việt (Mojibake).
2. **Quy chuẩn thiết kế UI thuần Text:** Mọi tài liệu thiết kế giao diện từ Giai đoạn 3 trở đi tuân thủ nguyên tắc **tuyệt đối không dùng Icon font hoặc ký tự Emoji**, biểu diễn trạng thái bằng Text Badge (`[Đã dọn]`, `[Bẩn]`, `[Đang dọn]`, `[Bảo trì]`).
3. **Quy tắc an toàn mã nguồn (.agents/rules/GEMINI.md):** Trước khi viết code hoặc sửa đổi bất kỳ file nào, phải phân tích nguyên nhân, trình bày Before/After và được User duyệt.
