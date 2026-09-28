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

| STT | Tên Tài Liệu | Nội Dung Chính | Trạng Thái |
| :---: | :--- | :--- | :---: |
| 1 | 📄 [Lo_Trinh_Phat_Trien_UI_Va_Kiem_Thu.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/Lo_Trinh_Phat_Trien_UI_Va_Kiem_Thu.md) | Bản đồ lộ trình tổng thể 6 giai đoạn phát triển giao diện theo chu trình khép kín: Khách hàng $\to$ Lễ tân $\to$ Thu ngân $\to$ Buồng phòng $\to$ Quản lý. | ✅ Đã duyệt |
| 2 | 📄 [KienTruc_Va_NhiemVu_Cac_ThuMuc_Code.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/KienTruc_Va_NhiemVu_Cac_ThuMuc_Code.md) | **Cẩm nang kiến trúc:** Tóm tắt chi tiết chức năng, nhiệm vụ cốt lõi, bảng ranh giới trách nhiệm và chu trình tương tác thực tế của từng thư mục (`controller`, `service`, `dao`, `model`, `dto`, `filter`, `util`, `views`). | ✅ Đã ban hành |
| 3 | 📄 [BaoCao_ThucThi_GiaiDoan_0.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi_GiaiDoan_0.md) | Bản thuyết minh chi tiết luồng dữ liệu 3 lớp, tương tác giữa các class/tầng và toàn bộ code của Giai đoạn 0 (`pom.xml`, `DBContext`, `EncodingFilter`, Base UI, `index.jsp`). | ✅ Đã hoàn thành |
| 4 | 📄 [BaoCao_ThucThi_GiaiDoan_1.md](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/TaiLieu_DuAn/02_Web_Application/BaoCao_ThucThi_GiaiDoan_1.md) | Báo cáo chi tiết luồng tương tác, phân định trách nhiệm từng class, kiến trúc phân quyền 4 vai trò, bộ lọc `AuthFilter`, băm mật khẩu `SHA-256`, chuẩn hóa tên Tiếng Anh và chia sub-package. | ✅ Đã hoàn thành |

---

*Lưu ý: Mọi giai đoạn tiếp theo (Giai đoạn 2: Quản lý phòng, Giai đoạn 3: Đặt phòng, Giai đoạn 4: Hóa đơn & Dịch vụ...) đều sẽ được lập báo cáo chi tiết và lưu trữ tại thư mục `TaiLieu_DuAn/02_Web_Application/`.*
