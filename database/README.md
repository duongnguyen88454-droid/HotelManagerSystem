# HƯỚNG DẪN KHỞI TẠO CƠ SỞ DỮ LIỆU (DATABASE INITIALIZATION)

Thư mục này chứa toàn bộ các kịch bản T-SQL khởi tạo và cấu hình cơ sở dữ liệu `QuanLyKhachSan` trên Microsoft SQL Server.

---

## 1. Thứ Tự Thực Thi Bắt Buộc (Execution Order)

Để đảm bảo toàn vẹn dữ liệu, ràng buộc khóa ngoại (Foreign Keys) và tính phụ thuộc giữa Function, View, Stored Procedure và Trigger, các tệp phải được thực thi tuần tự theo thứ tự số tiền tố:

| Thứ Tự | Tên Tệp | Vai Trò & Nội Dung |
| :---: | :--- | :--- |
| **01** | `01_Script_QuanLyKhachSan.sql` | Khởi tạo CSDL `QuanLyKhachSan`, tạo toàn bộ 14 bảng quan hệ, thiết lập khóa chính/khóa ngoại, và nạp dữ liệu mẫu ban đầu (Seed Data). |
| **02** | `02_Function.sql` | Tạo các hàm vô hướng (Scalar UDF) và hàm bảng (Table-valued UDF): tính tiền phòng, tiền dịch vụ, kiểm tra phòng trống và 10 hàm tự sinh khóa chính (`fn_SinhMa...`). |
| **03** | `03_View.sql` | Tạo các View báo cáo: danh sách phòng khả dụng, chi tiết hóa đơn, thống kê doanh thu. |
| **04** | `04_Procedure.sql` | Tạo các Stored Procedure nghiệp vụ: đặt phòng online, check-in tại quầy, gọi thêm dịch vụ, thanh toán & check-out... |
| **05** | `05_Trigger.sql` | Tạo các Trigger kiểm soát xung đột đặt phòng (chặn Overbooking), tự sinh khóa chính (Auto-PK), tự tạo hóa đơn khi có booking mới, đồng bộ trạng thái phòng. |
| **06** | `06_Index.sql` | Tạo các chỉ mục (Indexes) trên các cột thường xuyên tìm kiếm, lọc và kết nối bảng để tối ưu hiệu năng truy vấn. |
| **07** | `07_Transaction.sql` | Các kịch bản kiểm thử mức cô lập giao dịch (Isolation Level) và kiểm chứng ACID trong môi trường đa người dùng. |

---

## 2. Hướng Dẫn Thực Thi

### Cách 1: Sử dụng SQL Server Management Studio (SSMS)
1. Mở SSMS và kết nối đến instance SQL Server (ví dụ: `localhost\SQLEXPRESS` hoặc `localhost,1433`).
2. Mở từng tệp từ `01_` đến `07_` theo thứ tự trên.
3. Nhấn **Execute (F5)** cho từng tệp.

### Cách 2: Sử dụng SQLCMD (Command Line)
```bash
sqlcmd -S localhost -U sa -P 1234 -i database/01_Script_QuanLyKhachSan.sql
sqlcmd -S localhost -U sa -P 1234 -d QuanLyKhachSan -i database/02_Function.sql
sqlcmd -S localhost -U sa -P 1234 -d QuanLyKhachSan -i database/03_View.sql
sqlcmd -S localhost -U sa -P 1234 -d QuanLyKhachSan -i database/04_Procedure.sql
sqlcmd -S localhost -U sa -P 1234 -d QuanLyKhachSan -i database/05_Trigger.sql
sqlcmd -S localhost -U sa -P 1234 -d QuanLyKhachSan -i database/06_Index.sql
sqlcmd -S localhost -U sa -P 1234 -d QuanLyKhachSan -i database/07_Transaction.sql
```
