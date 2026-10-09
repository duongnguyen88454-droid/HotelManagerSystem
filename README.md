# HỆ THỐNG QUẢN LÝ KHÁCH SẠN (HOTEL MANAGEMENT SYSTEM)

**Môn học:** Lập Trình Web (Jakarta EE 8 / Java Web) & Hệ Quản Trị Cơ Sở Dữ Liệu  
**Đơn vị đào tạo:** Trường Đại Học Sư Phạm Kỹ Thuật TP.HCM (HCMUTE) — Nhóm 10  
**Kiến trúc:** Feature-based / Package-by-Feature Architecture  

---

## 1. CÔNG NGHỆ SỬ DỤNG (TECH STACK)

* **Backend:** Java 17, Jakarta EE 10 (Servlet 6.0, Filter, JSP, JSTL 3.0).
* **Database:** Microsoft SQL Server 2019/2022 (16 bảng, Stored Procedure, Function, Trigger, Index).
* **Database Access:** JDBC thuần (Driver `mssql-jdbc-9.4.1.jre8`) kết nối qua connection pool tùy biến trong `DBContext`.
* **Frontend:** JSP, JSTL, CSS thuần Responsive (Zero-Icon-Font, Zero-Emoji trên giao diện nhân viên chuyên nghiệp).
* **Build Tool:** Apache Maven (Packaging WAR).
* **Web Server:** Apache Tomcat 10.1.x (khuyến nghị phiên bản 10.1.60+).

---

## 2. CẤU TRÚC THƯ MỤC THEO TÍNH NĂNG (FEATURE-BASED)

```text
HotelManagerSystem/
├── .gitignore                          # Cấu hình bỏ qua target, class, cache
├── pom.xml                             # Cấu hình Maven build và dependencies
├── README.md                           # Tài liệu tổng quan dự án
├── database/                           # Kịch bản SQL theo thứ tự thực thi chuẩn (01 -> 07)
│   ├── README.md                       # Hướng dẫn chạy khởi tạo CSDL
│   ├── 01_Script_QuanLyKhachSan.sql    # Schema, bảng quan hệ và seed data
│   ├── 02_Function.sql                 # Hàm tính tiền và 10 hàm tự sinh khóa chính
│   ├── 03_View.sql                     # View báo cáo thống kê
│   ├── 04_Procedure.sql                # Stored Procedure quy trình nghiệp vụ
│   ├── 05_Trigger.sql                  # Trigger chống xung đột và Auto-PK
│   ├── 06_Index.sql                    # Chỉ mục tối ưu hóa truy vấn
│   └── 07_Transaction.sql              # Kịch bản kiểm thử ACID / Isolation
├── docs/                               # Toàn bộ tài liệu kỹ thuật & kiểm thử
│   ├── README.md                       # Mục lục trung tâm toàn bộ tài liệu
│   ├── 01_DBMS/                        # Tài liệu thiết kế CSDL
│   └── 02_Web_Application/             # Tài liệu kiến trúc và báo cáo Sprint
├── tools/                              # Công cụ phát triển & kiểm thử độc lập
│   ├── manual-tests/                   # Bộ test runner Java chạy độc lập (javac)
│   └── doc-builders/                   # Script Python hỗ trợ cập nhật tài liệu
└── src/
    ├── main/
    │   ├── java/com/mycompany/hotelmanagersystem/
    │   │   ├── common/                 # Cấu hình DBContext và EncodingFilter dùng chung
    │   │   ├── auth/                   # Phân hệ Xác thực & Phân quyền (Login, Register, Session)
    │   │   ├── customer/               # Phân hệ Khách hàng (Portal, CustomerDAO, Model)
    │   │   ├── room/                   # Phân hệ Buồng phòng (Search, Detail, Service, DAO, DTO)
    │   │   ├── booking/                # Phân hệ Đặt phòng (Cart, Booking, History, Service, DAO)
    │   │   ├── hotelservice/           # Phân hệ Dịch vụ khách sạn đi kèm (ServiceDAO, Model)
    │   │   ├── employee/               # Phân hệ Nhân sự (Employee Model)
    │   │   ├── receptionist/           # Cổng Lễ tân (Sơ đồ phòng Timeline trực quan)
    │   │   ├── housekeeper/            # Cổng Buồng phòng (Nhiệm vụ vệ sinh phòng)
    │   │   └── manager/                # Cổng Quản lý (Bảng điều khiển kinh doanh)
    │   └── webapp/
    │       ├── assets/                 # Tài nguyên tĩnh (css, js, images)
    │       ├── views/                  # Giao diện JSP phân bổ theo vai trò
    │       │   ├── common/             # Header, navbar, footer, login, register, 403
    │       │   ├── customer/           # Giao diện tra cứu, giỏ phòng, thanh toán, lịch sử
    │       │   ├── receptionist/       # Sơ đồ phòng trực quan 4 tầng
    │       │   ├── housekeeper/        # Danh sách nhiệm vụ dọn buồng
    │       │   └── manager/            # Bảng số liệu kinh doanh
    │       ├── WEB-INF/
    │       │   └── web.xml             # Khai báo cấu hình ứng dụng web
    │       └── index.jsp               # Trang chủ điều hướng và kiểm tra kết nối CSDL
    └── test/java/com/mycompany/hotelmanagersystem/
        └── (Skeleton cấu trúc test theo từng feature tương ứng)
```

---

## 3. HƯỚNG DẪN KHỞI CHẠY (QUICK START)

### 3.1. Khởi tạo Cơ sở Dữ liệu
1. Đảm bảo dịch vụ SQL Server đang hoạt động trên cổng 1433 với tài khoản `sa` / mật khẩu `1234`.
2. Mở SSMS hoặc sử dụng `sqlcmd` thực thi tuần tự 7 tệp trong thư mục `database/` theo hướng dẫn tại [database/README.md](database/README.md).

### 3.2. Biên dịch & Đóng gói Ứng dụng
```bash
mvn clean package
```
Tệp WAR đóng gói hoàn chỉnh sẽ được tạo tại: `target/HotelManagerSystem-1.0-SNAPSHOT.war`.

### 3.3. Triển khai & Chạy Ứng dụng
* Triển khai tệp `.war` lên máy chủ Apache Tomcat (phiên bản 10.1.x, sao chép vào thư mục `webapps/`).
* Mở trình duyệt và truy cập: `http://localhost:8080/HotelManagerSystem/`.

---

## 4. TÀI LIỆU THAM CHIẾU CHI TIẾT

* [Cẩm Nang Kiến Trúc Thư Mục Feature-Based](docs/02_Web_Application/KienTruc_Va_LoTrinh/CAU_TRUC_THU_MUC.md)
* [Báo Cáo Đề Xuất Tái Cấu Trúc](docs/02_Web_Application/DeXuat_TaiCauTruc_FeatureBased.md)
* [Mục Lục Tài Liệu Dự Án](docs/README.md)
