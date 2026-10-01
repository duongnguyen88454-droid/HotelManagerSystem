# TỔNG MỤC TÀI LIỆU DỰ ÁN (PROJECT DOCUMENTATION HUB)
**Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10  
**Môn học:** Lập Trình Web & Hệ Quản Trị Cơ Sở Dữ Liệu — HCMUTE  

---

## 📌 QUY ƯỚC QUẢN LÝ TÀI LIỆU
* Thư mục `TaiLieu_DuAn/` là **nơi duy nhất** lưu trữ toàn bộ các file tài liệu định dạng Markdown (`.md`) của toàn bộ dự án.
* Tuyệt đối không đặt file `.md` rời rạc ở thư mục gốc hoặc các thư mục con khác để đảm bảo dự án luôn gọn gàng, chuyên nghiệp và dễ tra cứu.

---

## 📚 DANH MỤC TÀI LIỆU ĐƯỢC PHÂN THEO NHÓM

### PHÂN HỆ 1: TÀI LIỆU HỆ QUẢN TRỊ CSDL (`01_DBMS/`)

| STT | Tên Tài Liệu | Nội Dung Chính | Trạng Thái |
| :---: | :--- | :--- | :---: |
| 1 | 📄 [Ke_Hoach_Thuc_Thi_Function_Va_Procedure.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/01_DBMS/Ke_Hoach_Thuc_Thi_Function_Va_Procedure.md) | Thiết kế chi tiết các Function tính toán giá, kiểm tra trạng thái và Stored Procedure nghiệp vụ trong SQL Server. | ✅ Đã lưu trữ |
| 2 | 📄 [Ke_Hoach_Thuc_Thi_Transaction_Va_Index.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/01_DBMS/Ke_Hoach_Thuc_Thi_Transaction_Va_Index.md) | Thiết kế kiểm soát giao dịch ACID (Transaction) chống tranh chấp phòng và tối ưu tốc độ truy vấn bằng Index. | ✅ Đã lưu trữ |
| 3 | 📄 [Ke_Hoach_Thuc_Thi_Trigger_Va_View.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/01_DBMS/Ke_Hoach_Thuc_Thi_Trigger_Va_View.md) | Thiết kế các Trigger tự động cập nhật trạng thái phòng/hóa đơn và View tổng hợp dữ liệu báo cáo. | ✅ Đã lưu trữ |

---

### PHÂN HỆ 2: TÀI LIỆU ỨNG DỤNG WEB & BÁO CÁO GIAI ĐOẠN (`02_Web_Application/`)

#### 📂 1. Kiến Trúc & Lộ Trình Tổng Thể (`KienTruc_Va_LoTrinh/`)
| STT | Tên Tài Liệu | Nội Dung Chính | Trạng Thái |
| :---: | :--- | :--- | :---: |
| 1 | 📄 [Lo_Trinh_Phat_Trien_UI_Va_Kiem_Thu.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/KienTruc_Va_LoTrinh/Lo_Trinh_Phat_Trien_UI_Va_Kiem_Thu.md) | Bản đồ lộ trình tổng thể 6 giai đoạn phát triển giao diện theo chu trình khép kín: Khách hàng $\to$ Lễ tân $\to$ Thu ngân $\to$ Buồng phòng $\to$ Quản lý. | ✅ Đã duyệt |
| 2 | 📄 [KienTruc_Va_NhiemVu_Cac_ThuMuc_Code.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/KienTruc_Va_LoTrinh/KienTruc_Va_NhiemVu_Cac_ThuMuc_Code.md) | **Cẩm nang kiến trúc:** Tóm tắt chi tiết chức năng, nhiệm vụ cốt lõi, bảng ranh giới trách nhiệm và chu trình tương tác thực tế của từng thư mục (`controller`, `service`, `dao`, `model`, `dto`, `filter`, `util`, `views`). | ✅ Đã ban hành |

#### 📂 2. Hồ Sơ Báo Cáo Thực Thi & Kiểm Thử (`BaoCao_ThucThi/`)
> 👉 Xem danh mục chi tiết tại [Mục lục trung tâm BaoCao_ThucThi/README.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/README.md)

* **Nhóm 1 - Kế hoạch thực thi (`01_KeHoach_ThucThi/`):**
  - [KeHoach_ThucThi_GiaiDoan_3.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/01_KeHoach_ThucThi/KeHoach_ThucThi_GiaiDoan_3.md): Kế hoạch phân hệ Lễ tân, 4 Sprint, 20 Test Cases, Wireframe thuần Text, 5 REST APIs.
* **Nhóm 2 - Báo cáo kiến trúc (`02_BaoCao_KienTruc/`):**
  - [BaoCao_ThucThi_GiaiDoan_0.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_0.md): Khởi tạo dự án, Maven, UTF-8 EncodingFilter, Base UI.
  - [BaoCao_ThucThi_GiaiDoan_1.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_1.md): Xác thực, AuthFilter, SHA-256, 4 vai trò.
  - [BaoCao_ThucThi_GiaiDoan_2.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_2.md): Đặt phòng 5 bước, chống Overbooking, dịch vụ đi kèm.
  - [BaoCao_ThucThi_GiaiDoan_3.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/02_BaoCao_KienTruc/BaoCao_ThucThi_GiaiDoan_3.md): Phân rã 4 nhóm & 12 bước triển khai TDD chi tiết cho Lễ tân.
* **Nhóm 3 - Nghiệm thu & Kiểm thử (`03_TongKet_Va_KiemThu/`):**
  - [BaoCao_TongKet_GiaiDoan_2.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_TongKet_GiaiDoan_2.md): Nghiệm thu Phase 2 (40/40 Test Cases PASS 100%).
  - [BaoCao_Loi_TestCase_Phase0_2.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_Loi_TestCase_Phase0_2.md): Sổ tay phân tích và khắc phục lỗi kỹ thuật.
  - [BaoCao_KiemThu_FN31.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_KiemThu_FN31.md): Báo cáo kiểm thử FN-3.1 (20/20 Test Cases PASS 100%).
  - [BaoCao_KiemThu_Phase2_TacDong_FN31.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi/03_TongKet_Va_KiemThu/BaoCao_KiemThu_Phase2_TacDong_FN31.md): Kiểm thử tác động chéo Phase 2 -> FN-3.1 (19/20 PASS, phát hiện lỗi Deadlock kiến trúc).

---

*Lưu ý: Mọi giai đoạn tiếp theo (Giai đoạn 4: Thu ngân & Quyết toán, Giai đoạn 5: Buồng phòng & Báo cáo...) đều sẽ được lập tài liệu và lưu trữ khoa học theo các nhóm trên.*
