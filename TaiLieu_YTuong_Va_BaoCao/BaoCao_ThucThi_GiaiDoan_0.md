# BÁO CÁO THỰC THI GIAI ĐOẠN 0: NỀN TẢNG KỸ THUẬT & KIẾN TRÚC TƯƠNG TÁC 3 LỚP (3-TIER / MVC)

**Dự án:** Hệ Thống Quản Lý Khách Sạn (Hotel Management System) — Nhóm 10  
**Môn học:** Lập Trình Web (JSP/Servlet) & Hệ Quản Trị CSDL — HCMUTE  
**Người lập:** AI Assistant  
**Trạng thái:** Chờ phê duyệt từ Trưởng nhóm / Lập trình viên trước khi áp dụng code  

---

## MỤC LỤC
1. [Mục Tiêu & Tiêu Chí Của Giai Đoạn 0](#1-mục-tiêu--tiêu-chí-của-giai-đoạn-0)
2. [Sơ Đồ Luồng Dữ Liệu & Nguyên Tắc Tương Tác 3 Lớp](#2-sơ-đồ-luồng-dữ-liệu--nguyên-tắc-tương-tác-3-lớp)
3. [Phân Định Trách Nhiệm Chi Tiết Giữa Các Tầng & Các Class](#3-phân-định-trách-nhiệm-chi-tiết-giữa-các-tầng--các-class)
4. [Đặc Tả Chi Tiết 5 Bước Thực Hiện & Code Dự Kiến](#4-đặc-tả-chi-tiết-5-bước-thực-hiện--code-dự-kiến)
   - [Bước 1: Cấu hình thư viện pom.xml](#bước-1-cấu-hình-thư-viện-pomxml)
   - [Bước 2: Lớp kết nối CSDL DBContext.java](#bước-2-lớp-kết-nối-csdl-dbcontextjava)
   - [Bước 3: Bộ lọc tiếng Việt EncodingFilter.java](#bước-3-bộ-lọc-tiếng-việt-encodingfilterjava)
   - [Bước 4: Bộ khung giao diện nền tảng Functional Base UI](#bước-4-bộ-khung-giao-diện-nền-tảng-functional-base-ui)
   - [Bước 5: Trang kiểm thử sức khỏe hệ thống index.jsp](#bước-5-trang-kiểm-thử-sức-khỏe-hệ-thống-indexjsp)
5. [Kịch Bản Kiểm Thử Giai Đoạn 0 (Test Checklist)](#5-kịch-bản-kiểm-thử-giai-đoạn-0-test-checklist)

---

## 1. MỤC TIÊU & TIÊU CHÍ CỦA GIAI ĐOẠN 0

* **Mục tiêu cốt lõi:** Thiết lập nền tảng kỹ thuật vững chắc để toàn bộ 6 giai đoạn phát triển tiếp theo (Đăng nhập, Đặt phòng, Check-in, Check-out, Buồng phòng, Quản lý) có thể chạy mượt mà, không gặp lỗi kết nối hay lỗi font chữ.
* **Tiêu chí giao diện (UI):** Vì chưa có bản thiết kế Figma, giao diện trong giai đoạn này được xây dựng ở mức **Functional Base UI (giao diện chức năng cơ bản, sạch sẽ, chuẩn thẻ màu trạng thái phòng)** với mục tiêu cao nhất là **phục vụ kiểm thử logic cuốn chiếu**.

---

## 2. SƠ ĐỒ LUỒNG DỮ LIỆU & NGUYÊN TẮC TƯƠNG TÁC 3 LỚP

Dữ liệu trong toàn bộ hệ thống di chuyển theo chu trình khép kín một chiều, tuyệt đối không nhảy cóc qua các tầng:

```
[ Trình duyệt Web (Client / Browser) ]
         │  ▲
         │  │ (1) Gửi HTTP Request (GET/POST) / Nhận HTML Response
         ▼  │
┌─────────────────────────────────────────────────────────────┐
│ 1. PRESENTATION LAYER (TẦNG TRÌNH DIỄN & ĐIỀU KHIỂN)        │
│    ├── Filter (EncodingFilter): Ép toàn bộ Request sang UTF-8│
│    ├── Controller (HttpServlet): Đọc tham số, validate form  │
│    └── View (JSP): Chỉ hiển thị dữ liệu qua EL & JSTL        │
└──────────────────────────┬───▲──────────────────────────────┘
                           │   │ (2) Controller gọi Service xử lý
                           │   │     Service trả kết quả Model/DTO
                           ▼   │
┌─────────────────────────────────────────────────────────────┐
│ 2. BUSINESS LOGIC LAYER (TẦNG NGHIỆP VỤ - BLL)              │
│    └── Service (BookingService, CheckInService, ...):       │
│        Chứa 100% quy tắc tính tiền, kiểm tra phòng trống,    │
│        xử lý nghiệp vụ khách sạn                             │
└──────────────────────────┬───▲──────────────────────────────┘
                           │   │ (3) Service gọi DAO đọc/ghi
                           │   │     DAO trả List<Entity> hoặc Object
                           ▼   │
┌─────────────────────────────────────────────────────────────┐
│ 3. DATA ACCESS LAYER (TẦNG TRUY XUẤT DỮ LIỆU - DAL)         │
│    ├── DAO (PhongDAO, BookingDAO, HoaDonDAO, ...):          │
│    │   Thực thi SQL, gọi Stored Procedure, ánh xạ ResultSet │
│    └── DBContext (util/DBContext.java):                     │
│        Mở Connection JDBC an toàn và quản lý đóng tài nguyên │
└──────────────────────────┬───▲──────────────────────────────┘
                           │   │ (4) Gửi lệnh T-SQL qua cổng 1433
                           │   │     Nhận bảng dữ liệu ResultSet
                           ▼   │
┌─────────────────────────────────────────────────────────────┐
│ 4. DATABASE SERVER (HỆ CSDL MICROSOFT SQL SERVER)           │
│    └── Database QuanLyKhachSan (17 bảng, 7 Function,        │
│        8 Procedure, 7 Trigger, 7 View, 5 Transaction)        │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. PHÂN ĐỊNH TRÁCH NHIỆM CHI TIẾT GIỮA CÁC TẦNG & CÁC CLASS

| Tầng kiến trúc | Thành phần | Trách nhiệm cụ thể | Quy tắc bắt buộc |
| :--- | :--- | :--- | :--- |
| **Presentation** | `EncodingFilter.java` | Can thiệp trước mọi request, ép mã hóa UTF-8 cho cả request và response. | Chạy tự động với mọi URL `/*`. |
| **Presentation** | `HttpServlet` (Controller) | Đọc tham số từ URL/Form bằng `request.getParameter()`, kiểm tra rỗng/hợp lệ sơ bộ, gọi Service. Nhận kết quả và chuyển tiếp qua `request.getRequestDispatcher().forward()`. | Không chứa câu lệnh SQL, không tính toán logic phức tạp. |
| **Presentation** | `JSP` (View) | Đọc dữ liệu từ `${requestScope}` và render ra mã HTML bằng thẻ JSTL `<c:forEach>`, `<c:if>`. | Tuyệt đối không viết code scriptlet Java `<% ... %>` kết nối DB. |
| **Business Logic**| `Service` | Nhận yêu cầu từ Controller, áp dụng quy tắc kinh doanh (ví dụ: ngày trả phải sau ngày nhận, tính số đêm nhân đơn giá phòng, kiểm tra cọc), gọi DAO để đọc/lưu. | Độc lập với HttpServletRequest/Response, dễ dàng viết Unit Test. |
| **Data Access** | `DAO` | Chuyên trách JDBC: lấy Connection từ DBContext, chuẩn bị `PreparedStatement` hoặc `CallableStatement`, thực thi câu lệnh SQL/Procedure, duyệt `ResultSet` để ánh xạ vào Java Entity. | Phải luôn đóng `ResultSet`, `PreparedStatement`, `Connection` trong khối `finally`. |
| **Data Access** | `DBContext.java` | Quản lý thông tin kết nối máy chủ SQL Server: `localhost`, cổng `1433`, CSDL `QuanLyKhachSan`, user `sa`. | Cung cấp hàm `getConnection()` và phương thức kiểm tra sức khỏe `testConnection()`. |

---

## 4. ĐẶC TẢ CHI TIẾT 5 BƯỚC THỰC HIỆN & CODE DỰ KIẾN

### Bước 1: Cấu hình thư viện `pom.xml`
* **Lý do kỹ thuật:** Dự án Java 1.8 (Jakarta EE 8) mặc định chưa có driver giao tiếp với Microsoft SQL Server và chưa có thư viện JSTL để render dữ liệu trên JSP.
* **Đoạn code dự kiến thêm vào khối `<dependencies>` của `pom.xml`:**

```xml
        <!-- 1. Driver chính thức của Microsoft để kết nối SQL Server qua cổng 1433 -->
        <dependency>
            <groupId>com.microsoft.sqlserver</groupId>
            <artifactId>mssql-jdbc</artifactId>
            <version>9.4.1.jre8</version>
        </dependency>

        <!-- 2. Thư viện JSTL để dùng các thẻ chuẩn trên JSP: <c:if>, <c:forEach> -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>jstl</artifactId>
            <version>1.2</version>
        </dependency>
```

---

### Bước 2: Lớp kết nối CSDL `DBContext.java`
* **Vị trí file:** `src/main/java/com/mycompany/hotelmanagersystem/util/DBContext.java`
* **Logic hoạt động:**
  - Nạp driver `com.microsoft.sqlserver.jdbc.SQLServerDriver`.
  - Kết nối với chuỗi URL cấu hình đầy đủ `encrypt=false;trustServerCertificate=true;characterEncoding=UTF-8`.
  - Có hàm `closeConnection()` bảo vệ an toàn tài nguyên.
  - Có hàm `main()` để chạy độc lập kiểm tra kết nối ngay trong IDE.
* **Toàn bộ đoạn code dự kiến:**

```java
package com.mycompany.hotelmanagersystem.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DBContext {

    // Thông số kết nối Microsoft SQL Server
    private static final String SERVER_NAME = "localhost";
    private static final String PORT_NUMBER = "1433";
    private static final String DATABASE_NAME = "QuanLyKhachSan";
    private static final String USER_NAME = "sa";
    private static final String PASSWORD = "sa"; // Điều chỉnh theo mật khẩu SQL Server máy bạn (vd: 123456, sa, ...)

    public static Connection getConnection() throws ClassNotFoundException, SQLException {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = String.format(
            "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=false;trustServerCertificate=true;characterEncoding=UTF-8",
            SERVER_NAME, PORT_NUMBER, DATABASE_NAME
        );
        return DriverManager.getConnection(url, USER_NAME, PASSWORD);
    }

    public static void closeConnection(Connection conn, PreparedStatement ps, ResultSet rs) {
        try { if (rs != null && !rs.isClosed()) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (ps != null && !ps.isClosed()) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null && !conn.isClosed()) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }

    public static boolean testConnection() {
        Connection conn = null;
        try {
            conn = getConnection();
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            System.err.println("Lỗi kiểm tra kết nối CSDL: " + e.getMessage());
            return false;
        } finally {
            closeConnection(conn, null, null);
        }
    }

    public static void main(String[] args) {
        System.out.println("--- ĐANG KIỂM TRA KẾT NỐI TỚI CSDL: " + DATABASE_NAME + " ---");
        if (testConnection()) {
            System.out.println("=> KẾT NỐI THÀNH CÔNG VỚI DATABASE QuanLyKhachSan!");
        } else {
            System.out.println("=> KẾT NỐI THẤT BẠI! Kiểm tra lại cổng 1433, tên DB hoặc mật khẩu sa.");
        }
    }
}
```

---

### Bước 3: Bộ lọc tiếng Việt `EncodingFilter.java`
* **Vị trí file:** `src/main/java/com/mycompany/hotelmanagersystem/filter/EncodingFilter.java`
* **Logic hoạt động:** Chặn trước mọi Request/Response trên toàn website và đặt encoding sang UTF-8.
* **Toàn bộ đoạn code dự kiến:**

```java
package com.mycompany.hotelmanagersystem.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;

@WebFilter(filterName = "EncodingFilter", urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
```

---

### Bước 4: Bộ khung giao diện nền tảng (Functional Base UI)
Gồm 4 thành phần định dạng cơ bản:

1. **`src/main/webapp/assets/css/style.css`:**
   - Định nghĩa biến màu sắc đại diện cho 5 trạng thái phòng khách sạn:
     - 🟩 `Available` (`#38a169`): Phòng trống sạch.
     - 🟥 `Occupied` (`#e53e3e`): Phòng đang có khách ở.
     - 🟨 `Dirty` (`#d69e2e`): Phòng bẩn chờ dọn.
     - 🟧 `Cleaning` (`#dd6b20`): Phòng đang dọn dẹp.
     - ⬛ `Damaged` (`#718096`): Phòng hư hại chờ bảo trì.
   - Định nghĩa layout `.container`, thanh `.navbar`, khung `.card`, bảng `.table`, nút bấm `.btn`, nhãn `.badge` và thông báo `.alert`.

2. **`src/main/webapp/views/common/header.jsp`:**
```html
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle != null ? pageTitle : "Hệ Thống Quản Lý Khách Sạn - Nhóm 10"}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<div class="content-wrapper">
```

3. **`src/main/webapp/views/common/navbar.jsp`:**
```html
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<nav class="navbar">
    <div class="nav-container">
        <a href="${pageContext.request.contextPath}/index.jsp" class="brand">
            🏨 <span>HotelManagerSystem</span>
        </a>
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
            <li><a href="${pageContext.request.contextPath}/views/guest/home.jsp">Khách hàng</a></li>
            <li><a href="${pageContext.request.contextPath}/views/receptionist/room_map.jsp">Lễ tân</a></li>
            <li><a href="${pageContext.request.contextPath}/views/housekeeper/task_list.jsp">Buồng phòng</a></li>
            <li><a href="${pageContext.request.contextPath}/views/manager/dashboard.jsp">Quản lý</a></li>
            <li><a href="${pageContext.request.contextPath}/views/common/login.jsp" class="btn btn-primary" style="padding: 4px 10px; font-size: 0.85rem;">Đăng nhập</a></li>
        </ul>
    </div>
</nav>
```

4. **`src/main/webapp/views/common/footer.jsp`:**
```html
</div> <!-- Đóng content-wrapper -->
<footer class="footer">
    <div class="container">
        <p>&copy; 2026 Hệ Thống Quản Lý Khách Sạn (Hotel Management System) - Nhóm 10 (HCMUTE)</p>
    </div>
</footer>
</body>
</html>
```

---

### Bước 5: Trang kiểm thử sức khỏe hệ thống `index.jsp`
* **Vị trí file:** `src/main/webapp/index.jsp`
* **Nhiệm vụ:** Là trang bảng điều khiển kiểm thử trung tâm. Khi bạn chạy dự án lên Tomcat, trang này sẽ kiểm tra ngay lập tức xem kết nối SQL Server có thông suốt hay không, đồng thời cung cấp các nút bấm điều hướng nhanh đến các màn hình của từng vai trò để tiện kiểm thử.

---

## 5. KỊCH BẢN KIỂM THỬ GIAI ĐOẠN 0 (TEST CHECKLIST)

Sau khi được phê duyệt và áp dụng code, bạn có thể thực hiện kiểm thử ngay theo 2 cách:
1. **Kiểm thử độc lập không cần bật Server:** Mở file `DBContext.java` trong IDE $\to$ Bấm chuột phải chọn **Run File** (hoặc `Shift + F6`) $\to$ Quan sát Console xem có in ra thông báo `KẾT NỐI THÀNH CÔNG` hay không.
2. **Kiểm thử trên trình duyệt Web:** Bật ứng dụng trên Tomcat/GlassFish $\to$ Mở `http://localhost:8080/HotelManagerSystem/index.jsp` $\to$ Quan sát đèn thông báo trạng thái kết nối màu xanh lá và kiểm tra thanh Navbar điều hướng.
