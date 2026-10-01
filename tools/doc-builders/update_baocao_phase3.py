# -*- coding: utf-8 -*-
import os

target_path = r"d:\Learn\College\Lap trinh web\HotelManagerSystem\docs\02_Web_Application\BaoCao_ThucThi\02_BaoCao_KienTruc\BaoCao_ThucThi_GiaiDoan_3.md"

with open(target_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Update the table in Section 2
old_table_start = "### Bảng Tổng Hợp Phân Cấp Ưu Tiên Triển Khai\n\n| STT | Mã Chức Năng | Tên Chức Năng Con | Độ Ưu Tiên | Vai Trò Nghiệp Vụ | File Code Trọng Tâm |"
old_table_end = "| **12** | **FN-3.12** | Kiểm tra sẵn sàng bàn giao Phase 4 (Thu ngân) | **Ưu tiên 4 (Phụ trợ)** | Bảo toàn số liệu quyết toán 3NF | View `v_CongNoHoaDonKhachHang` |\n\n---"

new_table = """### Bảng Phân Cấp Độ Ưu Tiên Triển Khai & Kiểm Thử Độc Lập

| Nhóm Ưu Tiên | Mã FN | Tên Chức Năng Con | Độ Ưu Tiên | Vai Trò Nghiệp Vụ | File Code Trọng Tâm | Kịch Bản Test Độc Lập |
|:---|:---:|:---|:---:|:---|:---|:---|
| **NHÓM 1: CỐT LÕI & SỐNG CÒN**<br>*(Bắt buộc phải có để hệ thống hoạt động)* | **FN-3.1** | Tải dữ liệu phòng thực tế & KPI Buồng phòng | **Ưu tiên 1 (Cao nhất)** | Khung nhìn không gian khách sạn | `RoomDAO.java`<br>`RoomTimelineDTO.java`<br>`RoomMapKpiDTO.java` | Truy cập `/receptionist/room-map`, các số liệu KPI trên thanh đầu trang và danh sách phòng theo tầng khớp 100% CSDL SQL Server. |
| | **FN-3.2** | Truy vấn & Render thanh Đặt phòng (Booking Bars) tuần | **Ưu tiên 1 (Cao nhất)** | Trục thời gian chiếm giữ phòng | `BookingDAO.java`<br>`BookingBarDTO.java`<br>`ReceptionistPortalServlet.java` | Các đơn đặt phòng thực tế (ví dụ: `BK001`, `BK003`) hiển thị dải màu xanh/đỏ chính xác theo từng ngày và từng phòng trên ma trận Timeline. |
| | **FN-3.3** | Nghiệp vụ Check-in nhận phòng tại quầy | **Ưu tiên 1 (Cao nhất)** | Bàn giao phòng và kích hoạt Occupied | `ReceptionistCheckInServlet.java`<br>`BookingDAO.java` | Gửi request Check-in cho đơn `DaXacNhan` $\\to$ CSDL cập nhật `BOOKING.TrangThai = 'DaCheckIn'` và Trigger kích hoạt `PHONG.TrangThai = 'Occupied'`. |
| **NHÓM 2: DỊCH VỤ PHÁT SINH TẠI PHÒNG**<br>*(Doanh thu gia tăng trong kỳ nghỉ)* | **FN-3.4** | API Danh mục dịch vụ kinh doanh & Đơn giá | **Ưu tiên 2 (Cao)** | Nguồn dịch vụ khả dụng cho khách | `ServiceDAO.java`<br>`ReceptionistServiceListServlet.java` | Gọi `GET /api/receptionist/services` $\\to$ Nhận JSON danh sách dịch vụ đang kinh doanh kèm đơn giá niêm yết chuẩn. |
| | **FN-3.5** | Nghiệp vụ Gọi thêm dịch vụ vào phòng đang ở | **Ưu tiên 2 (Cao)** | Ghi nhận doanh thu phát sinh | `ReceptionistOrderServiceServlet.java`<br>`BookingDAO.java` | Gọi thêm nước ngọt cho phòng P202 $\\to$ Bảng `BOOKING_DICHVU` sinh dòng mới và chốt đơn giá thời điểm gọi. |
| | **FN-3.6** | API Chi tiết phòng đang ở & Tạm tính tiền | **Ưu tiên 2 (Cao)** | Dữ liệu hiển thị Centered Modal | `ReceptionistRoomDetailApiServlet.java` | Bấm vào phòng đang ở P202 $\\to$ Modal hiển thị chính xác tên khách, các món đã gọi và số dư công nợ. |
| **NHÓM 3: TRA CỨU & VẬN HÀNH BUỒNG PHÒNG**<br>*(Tối ưu thao tác quầy)* | **FN-3.7** | Bộ lọc & Tra cứu nhanh đa năng theo từ khóa | **Ưu tiên 3 (Trung bình)** | Tìm kiếm nhanh khách tại quầy | `BookingDAO.java`<br>JavaScript UI | Nhập SĐT hoặc CCCD khách hàng $\\to$ Tự động highlight căn phòng tương ứng trên Timeline. |
| | **FN-3.8** | Điều hướng chuyển tuần Timeline (Từ ngày - Đến ngày) | **Ưu tiên 3 (Trung bình)** | Xem quá khứ / tương lai | `ReceptionistPortalServlet.java` | Bấm `[ Tuần sau > ]` $\\to$ Lưới Timeline tải dữ liệu 7 ngày tiếp theo. |
| | **FN-3.9** | Cập nhật nhanh trạng thái buồng phòng tại quầy | **Ưu tiên 3 (Trung bình)** | Đồng bộ dọn dẹp / bảo trì | `RoomDAO.java`<br>`ReceptionistRoomStatusServlet.java` | Đổi trạng thái P102 từ `Bẩn` sang `Đã dọn` $\\to$ Badge đổi màu xanh lá và CSDL cập nhật. |
| **NHÓM 4: BẢO MẬT & BÀN GIAO PHASE 4**<br>*(An ninh & Toàn vẹn số liệu)* | **FN-3.10** | Phân quyền AuthFilter & Ghi nhận định danh MaNV | **Ưu tiên 4 (Phụ trợ)** | An ninh truy cập phân hệ lễ tân | `AuthFilter.java` | Tài khoản khách hàng (`VT01`) cố tình vào `/receptionist/room-map` bị chặn HTTP 403 Forbidden. |
| | **FN-3.11** | Tích hợp Toast Message thông báo nghiệp vụ | **Ưu tiên 4 (Phụ trợ)** | Trải nghiệm người dùng mượt mà | `room_map.jsp` (CSS/JS) | Thao tác Check-in / Thêm dịch vụ hiển thị popup trượt thông báo rõ ràng không icon. |
| | **FN-3.12** | Kiểm tra sẵn sàng bàn giao Phase 4 (Thu ngân) | **Ưu tiên 4 (Phụ trợ)** | Bảo toàn số liệu quyết toán 3NF | View `v_CongNoHoaDonKhachHang` | Chạy truy vấn đối soát công nợ đảm bảo mọi khoản dịch vụ phát sinh được ghi nhận đầy đủ. |

---"""

if old_table_start in content:
    # replace table
    idx1 = content.find(old_table_start)
    idx2 = content.find(old_table_end) + len(old_table_end)
    content = content[:idx1] + new_table + content[idx2:]
    print("Table updated successfully.")
else:
    print("Old table not found, skipping table replacement.")

# 2. Update Section 7 with detailed technical breakdown & Before/After code
old_sec7_start = "## 7. KẾ HOẠCH TRIỂN KHAI CHI TIẾT TỪNG BƯỚC & KỊCH BẢN KIỂM THỬ (TDD CHECKLIST)"
old_sec8_start = "## 8. KẾT LUẬN & TIÊU CHÍ NGHIỆM THU HOÀN THÀNH GIAI ĐOẠN 3"

new_sec7 = """## 7. KẾ HOẠCH TRIỂN KHAI CHI TIẾT TỪNG BƯỚC & KỊCH BẢN KIỂM THỬ (TDD CHECKLIST)

Quá trình lập trình được chia nhỏ thành **12 bước độc lập** theo đúng bảng phân cấp ưu tiên từ cốt lõi đến phụ trợ. Mỗi bước đều được thiết kế độc lập, có mã nguồn Before/After rõ ràng và kịch bản kiểm thử riêng biệt để nghiệm thu từng phần trước khi chuyển sang bước tiếp theo:

### 7.1. BẢNG TỔNG QUAN 12 BƯỚC THỰC THI & CHỈ TIÊU NGHIỆM THU

| Bước | Mã FN | Nhiệm Vụ Kỹ Thuật Trọng Tâm | Lớp / File Mã Nguồn Tham Gia | Tiêu Chuẩn Nghiệm Thu Độc Lập |
|:---:|:---:|:---|:---|:---|
| **Bước 1** | **FN-3.1** | Xây dựng DTOs & Truy vấn Phòng thật kèm KPI buồng phòng | `RoomTimelineDTO.java`, `RoomMapKpiDTO.java`, `RoomDAO.java` | Tải đủ 20 phòng từ SQL Server, KPI khớp số lượng từng trạng thái. |
| **Bước 2** | **FN-3.2** | Truy vấn dải Booking thật trong tuần & Gắn vào Timeline | `BookingBarDTO.java`, `BookingDAO.java` | Lấy các đơn `DaXacNhan`/`DaCheckIn`, tính đúng cột bắt đầu và số ô span. |
| **Bước 3** | **FN-3.1 & 3.2** | Ghép nối Controller & Render Timeline động bằng JSTL | `ReceptionistPortalServlet.java`, `room_map.jsp` | Thay thế toàn bộ mock HTML bằng `<c:forEach>`, hiển thị đúng dữ liệu DB. |
| **Bước 4** | **FN-3.3** | Xây dựng Controller & Gọi Stored Procedure Check-in | `ReceptionistCheckInServlet.java`, `BookingDAO.java` | Check-in đơn `BK003` $\to$ CSDL tự động đổi phòng sang `Occupied` qua Trigger. |
| **Bước 5** | **FN-3.4** | Xây dựng API Danh mục Dịch vụ đang kinh doanh | `ServiceDAO.java`, `ReceptionistServiceListServlet.java` | Gọi API trả về JSON danh sách dịch vụ (`DV01` $\to$ `DV05`) kèm đơn giá niêm yết. |
| **Bước 6** | **FN-3.5** | Xây dựng Controller Gọi thêm dịch vụ tại phòng | `ReceptionistOrderServiceServlet.java`, `BookingDAO.java` | Thêm dịch vụ cho phòng `Occupied` $\to$ Chèn `BOOKING_DICHVU` thành công. |
| **Bước 7** | **FN-3.6** | Xây dựng API Chi tiết phòng đang ở & Tạm tính công nợ | `ReceptionistRoomDetailApiServlet.java`, `BookingDAO.java` | Modal hiển thị chi tiết khách, danh sách món đã gọi và số dư còn lại. |
| **Bước 8** | **FN-3.7** | Ghép nối Tìm kiếm & Bộ lọc phòng động tại quầy | JavaScript lọc DOM / AJAX `BookingDAO.java` | Nhập SĐT, Mã BK, Tên khách $\to$ Highlight ngay căn phòng trên lưới Timeline. |
| **Bước 9** | **FN-3.8** | Điều hướng chuyển tuần Timeline (Từ ngày - Đến ngày) | `ReceptionistPortalServlet.java`, `room_map.jsp` | Bấm `[ < Tuần trước ]` hoặc `[ Tuần sau > ]` tải đúng dải booking của tuần đó. |
| **Bước 10** | **FN-3.9** | Cập nhật nhanh trạng thái buồng phòng tại quầy | `RoomDAO.java`, `ReceptionistRoomStatusServlet.java` | Đổi phòng từ `Dirty` sang `Available` $\to$ Badge đổi sang `[Đã dọn]`. |
| **Bước 11** | **FN-3.10 & 3.11** | Phân quyền AuthFilter & Tích hợp Toast Message thuần Text | `AuthFilter.java`, `room_map.jsp` (CSS/JS) | Chặn truy cập trái phép vai trò khác; thông báo Toast góc màn hình không icon. |
| **Bước 12** | **FN-3.12** | Kiểm thử tích hợp E2E & Đối soát dữ liệu bàn giao Phase 4 | Kịch bản xuyên suốt: Web Booking $\to$ Check-in $\to$ In-stay Order $\to$ View | View `v_CongNoHoaDonKhachHang` phản ánh chính xác 100% để sẵn sàng cho Thu ngân. |

---

### 7.2. CHI TIẾT KỸ THUẬT & ĐỀ XUẤT CODE BEFORE / AFTER TỪNG BƯỚC

#### BƯỚC 1: TRIỂN KHAI FN-3.1 (TẢI DỮ LIỆU PHÒNG THỰC TẾ & KPI BUỒNG PHÒNG)

##### 1. Vấn Đề Thực Tế
* File giao diện [room_map.jsp](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/src/main/webapp/views/receptionist/room_map.jsp) hiện đang chứa dữ liệu tĩnh mẫu (hardcoded mock data) cho thanh thống kê KPI (Tổng 20 phòng, Trống 12, Đang ở 4...) và các hàng phòng mẫu trên Timeline.
* [ReceptionistPortalServlet.java](file:///d:/Learn/College/Lap%20trinh%20web/HotelManagerSystem/src/main/java/com/mycompany/hotelmanagersystem/controller/receptionist/ReceptionistPortalServlet.java) hiện tại chỉ `forward` sang trang JSP mà chưa gọi `RoomDAO` để truy vấn CSDL SQL Server.

##### 2. Phương Án Kỹ Thuật Khắc Phục
1. **Tạo 2 DTO mới:**
   * `RoomTimelineDTO.java` (gói `com.mycompany.hotelmanagersystem.dto.receptionist`): Đại diện cho thông tin phòng trên sơ đồ gồm `maPhong`, `soPhong`, `soTang`, `maLoaiPhong`, `tenLoaiPhong`, `giaPhong`, `trangThaiPhong` (`Available`, `Dirty`, `Cleaning`, `Damaged`, `Occupied`), và danh sách `bookingBars`.
   * `RoomMapKpiDTO.java` (gói `com.mycompany.hotelmanagersystem.dto.receptionist`): Chứa các số liệu thống kê tổng thể gồm `tongSoPhong`, `soPhongAvailable`, `soPhongOccupied`, `soPhongDirty`, `soPhongCleaning`, `soPhongDamaged`, và `occupancyRate` (tỷ lệ lấp đầy %).
2. **Bổ sung 2 phương thức vào `RoomDAO.java`:**
   * `public List<RoomTimelineDTO> getAllRoomsForTimeline()`: Truy vấn danh sách toàn bộ phòng từ bảng `PHONG` kết hợp `LOAIPHONG`, sắp xếp tăng dần theo `SoTang` và `SoPhong`.
   * `public RoomMapKpiDTO getRoomMapKpi()`: Thực thi truy vấn tính toán thống kê tức thời bằng câu lệnh gom nhóm SQL Server.
3. **Cập nhật `ReceptionistPortalServlet.java`:**
   * Khởi tạo `RoomDAO`, trong hàm `doGet` thực hiện lấy dữ liệu phòng và KPI, gắn vào `request.setAttribute("roomList", rooms)` và `request.setAttribute("kpi", kpi)`.

##### 3. Chi Tiết Cấu Trúc Mã Nguồn & So Sánh Before vs After

* **DTO 1: `RoomTimelineDTO.java` (Tạo mới):**
```java
package com.mycompany.hotelmanagersystem.dto.receptionist;

import java.util.ArrayList;
import java.util.List;

public class RoomTimelineDTO {
    private String maPhong;
    private String soPhong;
    private int soTang;
    private String maLoaiPhong;
    private String tenLoaiPhong;
    private double giaPhong;
    private String trangThaiPhong; // Available, Dirty, Cleaning, Damaged, Occupied
    private List<BookingBarDTO> bookingBars = new ArrayList<>();

    public RoomTimelineDTO() {}

    public RoomTimelineDTO(String maPhong, String soPhong, int soTang, String maLoaiPhong, 
                           String tenLoaiPhong, double giaPhong, String trangThaiPhong) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.soTang = soTang;
        this.maLoaiPhong = maLoaiPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.giaPhong = giaPhong;
        this.trangThaiPhong = trangThaiPhong;
    }
    // Getters and Setters...
}
```

* **DTO 2: `RoomMapKpiDTO.java` (Tạo mới):**
```java
package com.mycompany.hotelmanagersystem.dto.receptionist;

public class RoomMapKpiDTO {
    private int tongSoPhong;
    private int soPhongAvailable;
    private int soPhongOccupied;
    private int soPhongDirty;
    private int soPhongCleaning;
    private int soPhongDamaged;
    private double occupancyRate;

    public RoomMapKpiDTO() {}

    public RoomMapKpiDTO(int tongSoPhong, int soPhongAvailable, int soPhongOccupied, 
                         int soPhongDirty, int soPhongCleaning, int soPhongDamaged) {
        this.tongSoPhong = tongSoPhong;
        this.soPhongAvailable = soPhongAvailable;
        this.soPhongOccupied = soPhongOccupied;
        this.soPhongDirty = soPhongDirty;
        this.soPhongCleaning = soPhongCleaning;
        this.soPhongDamaged = soPhongDamaged;
        this.occupancyRate = tongSoPhong > 0 ? ((double) soPhongOccupied / tongSoPhong) * 100.0 : 0.0;
    }
    // Getters and Setters...
}
```

* **Bổ sung trong `RoomDAO.java`:**
```java
public List<RoomTimelineDTO> getAllRoomsForTimeline() {
    List<RoomTimelineDTO> list = new ArrayList<>();
    String sql = "SELECT p.MaPhong, p.SoPhong, p.SoTang, lp.MaLoaiPhong, lp.TenLoaiPhong, lp.GiaPhong, p.TrangThai "
               + "FROM PHONG p "
               + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
               + "ORDER BY p.SoTang ASC, p.SoPhong ASC";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            list.add(new RoomTimelineDTO(
                rs.getString("MaPhong"),
                rs.getString("SoPhong"),
                rs.getInt("SoTang"),
                rs.getString("MaLoaiPhong"),
                rs.getNString("TenLoaiPhong"),
                rs.getDouble("GiaPhong"),
                rs.getString("TrangThai")
            ));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}

public RoomMapKpiDTO getRoomMapKpi() {
    String sql = "SELECT "
               + "  COUNT(*) AS TongSoPhong, "
               + "  SUM(CASE WHEN TrangThai = 'Available' THEN 1 ELSE 0 END) AS SoAvailable, "
               + "  SUM(CASE WHEN TrangThai = 'Occupied' THEN 1 ELSE 0 END) AS SoOccupied, "
               + "  SUM(CASE WHEN TrangThai = 'Dirty' THEN 1 ELSE 0 END) AS SoDirty, "
               + "  SUM(CASE WHEN TrangThai = 'Cleaning' THEN 1 ELSE 0 END) AS SoCleaning, "
               + "  SUM(CASE WHEN TrangThai = 'Damaged' THEN 1 ELSE 0 END) AS SoDamaged "
               + "FROM PHONG";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            return new RoomMapKpiDTO(
                rs.getInt("TongSoPhong"),
                rs.getInt("SoAvailable"),
                rs.getInt("SoOccupied"),
                rs.getInt("SoDirty"),
                rs.getInt("SoCleaning"),
                rs.getInt("SoDamaged")
            );
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return new RoomMapKpiDTO(0, 0, 0, 0, 0, 0);
}
```

* **So sánh Trước vs Sau trong `ReceptionistPortalServlet.java`:**
```diff
 package com.mycompany.hotelmanagersystem.controller.receptionist;
 
+import com.mycompany.hotelmanagersystem.dao.room.RoomDAO;
+import com.mycompany.hotelmanagersystem.dto.receptionist.RoomMapKpiDTO;
+import com.mycompany.hotelmanagersystem.dto.receptionist.RoomTimelineDTO;
 import javax.servlet.ServletException;
 import javax.servlet.annotation.WebServlet;
 import javax.servlet.http.HttpServlet;
 import javax.servlet.http.HttpServletRequest;
 import javax.servlet.http.HttpServletResponse;
 import java.io.IOException;
+import java.util.List;
 
 @WebServlet(name = "ReceptionistPortalServlet", urlPatterns = {"/receptionist/room-map", "/receptionist/checkin"})
 public class ReceptionistPortalServlet extends HttpServlet {
+    private RoomDAO roomDAO;
+
+    @Override
+    public void init() throws ServletException {
+        this.roomDAO = new RoomDAO();
+    }
+
     @Override
     protected void doGet(HttpServletRequest request, HttpServletResponse response)
             throws ServletException, IOException {
+        // 1. Lấy danh sách phòng thực tế theo tầng
+        List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
+        // 2. Tính toán số liệu thống kê KPI buồng phòng tức thời
+        RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();
+
+        request.setAttribute("roomList", rooms);
+        request.setAttribute("kpi", kpi);
+
         request.getRequestDispatcher("/views/receptionist/room_map.jsp").forward(request, response);
     }
 }
```

##### 4. Kịch Bản Kiểm Thử Độc Lập Cho Bước 1 (TC-3.1)
1. Đăng nhập bằng tài khoản Lễ tân (`huong.nv@hotel.com` / `1234`).
2. Mở trình duyệt đến đường dẫn: `http://localhost:8080/HotelManagerSystem/receptionist/room-map`.
3. Kiểm tra thanh KPI trên đầu trang:
   * Tổng số phòng hiển thị đúng 20 phòng.
   * Số phòng `Trống sạch`, `Đang có khách`, `Bẩn`, `Đang dọn`, `Bảo trì` khớp chính xác với kết quả câu lệnh SQL: `SELECT TrangThai, COUNT(*) FROM PHONG GROUP BY TrangThai`.
   * Tỷ lệ lấp đầy tính toán chính xác theo công thức `% Lấp đầy = (Số phòng Occupied / Tổng số phòng) * 100`.

---

#### BƯỚC 2: TRIỂN KHAI FN-3.2 (TRUY VẤN DẢI BOOKING THẬT TRONG TUẦN)
* **Mục tiêu:** Tạo `BookingBarDTO.java` và bổ sung phương thức `getBookingBarsInWeek(Date tuNgay, Date denNgay)` vào `BookingDAO.java`.
* **Logic tính toán trục tọa độ thời gian:**
  * Xác định chỉ số ngày bắt đầu của đơn booking trong tuần hiện tại: `startDayOffset = DATEDIFF(day, tuNgay, NgayNhanDuKien)`.
  * Xác định số ngày chiếm dụng trên tuần: `spanDays = DATEDIFF(day, NgayNhanDuKien, NgayTraDuKien)`.
* **Kịch bản kiểm thử độc lập (TC-3.2):** Kiểm tra đơn đặt phòng mẫu từ Phase 2 (ví dụ `BK001` đặt phòng P202) hiển thị dải màu đỏ/xanh lá nằm chính xác tại hàng của phòng P202 và chiếm đúng khoảng thời gian đặt phòng.

---

#### BƯỚC 3: GHÉP NỐI CONTROLLER & RENDER TIMELINE ĐỘNG (FN-3.1 & 3.2)
* **Mục tiêu:** Cập nhật `room_map.jsp` sử dụng thẻ JSTL `<c:forEach items="${roomList}" var="r">` để render danh sách phòng theo tầng và các dải đặt phòng thực tế thay cho mã HTML tĩnh.
* **Kịch bản kiểm thử độc lập (TC-3.3):** Khi thêm một phòng mới hoặc thay đổi trạng thái trong CSDL SQL Server, làm mới trang trên trình duyệt sẽ thấy thay đổi được cập nhật ngay lập tức.

---

#### BƯỚC 4: TRIỂN KHAI FN-3.3 (THỦ TỤC CHECK-IN NHẬN PHÒNG TẠI QUẦY)
* **Mục tiêu:** Tạo `ReceptionistCheckInServlet.java`, gọi Stored Procedure `sp_CheckInNhanPhong` (hoặc Transaction check-in) trong `BookingDAO.java`.
* **Cơ chế tự động hóa CSDL:**
  * Bảng `BOOKING` cập nhật `TrangThai = 'DaCheckIn'`, `NgayCheckInThucTe = GETDATE()`, `MaNV = [Lễ tân trực ca]`.
  * Trigger `trg_DongBoTrangThaiPhongCheckIn` tự động chuyển trạng thái phòng tương ứng sang `Occupied`.
* **Kịch bản kiểm thử độc lập (TC-3.4):** Chọn một đơn ở trạng thái `DaXacNhan` trên Modal -> Bấm `[ Xác nhận Check-in & Giao phòng ]` -> Modal đóng lại, thanh dải booking chuyển sang màu đỏ và CSDL xác nhận `Occupied`.

---

#### BƯỚC 5: TRIỂN KHAI FN-3.4 (API DANH MỤC DỊCH VỤ KINH DOANH)
* **Mục tiêu:** Tạo servlet `ReceptionistServiceListServlet.java` (URL `/api/receptionist/services`), đọc từ `ServiceDAO.java` lấy toàn bộ dịch vụ có `TrangThai = 'ApDung'`.
* **Output:** JSON danh sách dịch vụ gồm `maDichVu`, `tenDichVu`, `donGia`, `donViTinh`, `phanLoai`.
* **Kịch bản kiểm thử độc lập (TC-3.5):** Gọi lệnh HTTP GET trả về JSON chứa `DV01` (Buffet sáng - 150.000 đ), `DV02` (Giặt ủi - 50.000 đ), `DV05` (Nước ngọt - 30.000 đ).

---

#### BƯỚC 6: TRIỂN KHAI FN-3.5 (NGHIỆP VỤ GỌI THÊM DỊCH VỤ VÀO PHÒNG ĐANG Ở)
* **Mục tiêu:** Tạo servlet `ReceptionistOrderServiceServlet.java` (URL `/api/receptionist/order-service`).
* **Logic:** Kiểm tra phòng đang ở `Occupied` -> Gọi Stored Procedure `sp_GoiThemDichVu` -> Chèn vào bảng `BOOKING_DICHVU` với `KeyGenerator.generateBookingDichVuId()` và chốt đơn giá niêm yết tại thời điểm gọi.
* **Kịch bản kiểm thử độc lập (TC-3.6):** Lễ tân gọi 2 lon nước ngọt cho phòng P202 -> Bảng `BOOKING_DICHVU` xuất hiện bản ghi mới có thành tiền = 60.000 đ.

---

#### BƯỚC 7: TRIỂN KHAI FN-3.6 (API CHI TIẾT PHÒNG ĐANG Ở & TẠM TÍNH TIỀN)
* **Mục tiêu:** Tạo `ReceptionistRoomDetailApiServlet.java` (URL `/api/receptionist/room-detail`).
* **Output:** JSON trả về thông tin khách đang ở (Họ tên, SĐT, CCCD), danh sách các món dịch vụ đã sử dụng trong suốt kỳ nghỉ, tiền phòng dự kiến, tiền dịch vụ phát sinh và tổng số tiền thanh toán khi Check-out (hệ thống không áp dụng cơ chế cọc trước).
* **Kịch bản kiểm thử độc lập (TC-3.7):** Nhấp vào thanh phòng đang ở P202 trên sơ đồ -> Centered Modal 1 mở ra hiển thị đầy đủ chi tiết khách và bảng kê dịch vụ khớp 100% CSDL.

---

#### BƯỚC 8: TRIỂN KHAI FN-3.7 (BỘ LỌC & TÌM KIẾM NHANH THEO TỪ KHÓA)
* **Mục tiêu:** Xử lý JavaScript phía máy khách để lọc các hàng phòng trên ma trận Timeline theo: Số phòng, Tầng, Loại phòng, Mã đơn booking, SĐT hoặc Tên khách.
* **Kịch bản kiểm thử độc lập (TC-3.8):** Gõ `0987` vào ô tìm kiếm -> Các phòng không liên quan mờ đi, làm nổi bật phòng P101 của khách hàng tương ứng.

---

#### BƯỚC 9: TRIỂN KHAI FN-3.8 (ĐIỀU HƯỚNG CHUYỂN TUẦN TIMELINE)
* **Mục tiêu:** Xử lý tham số `weekOffset` (hoặc `startDate`) trong `ReceptionistPortalServlet.java`, hỗ trợ nút `[ < Tuần trước ]` và `[ Tuần sau > ]`.
* **Kịch bản kiểm thử độc lập (TC-3.9):** Bấm `[ Tuần sau > ]` -> Lưới ma trận chuyển sang hiển thị 7 ngày của tuần tiếp theo kèm các đơn đặt phòng của tuần đó.

---

#### BƯỚC 10: TRIỂN KHAI FN-3.9 (CẬP NHẬT NHANH TRẠNG THÁI BUỒNG PHÒNG TẠI QUẦY)
* **Mục tiêu:** Tạo servlet `ReceptionistRoomStatusServlet.java` cho phép lễ tân cập nhật trạng thái phòng giữa `Dirty`, `Cleaning` và `Available`.
* **Kịch bản kiểm thử độc lập (TC-3.10):** Sau khi buồng phòng dọn xong P102, lễ tân bấm chuyển trạng thái -> Badge trên Timeline đổi ngay sang `[Đã dọn]` màu xanh lá và CSDL cập nhật thành công.

---

#### BƯỚC 11: TRIỂN KHAI FN-3.10 & FN-3.11 (PHÂN QUYỀN AUTHFILTER & TOAST NOTIFICATION)
* **Mục tiêu:**
  * Rà soát `AuthFilter.java` để chắc chắn toàn bộ URL `/receptionist/*` và `/api/receptionist/*` chỉ cấp quyền cho vai trò `VT02` (Lễ tân) và Quản trị viên.
  * Tích hợp Toast Notification thuần CSS/JS (không icon) để thông báo kết quả thao tác nhẹ nhàng thay cho hộp thoại `alert()`.
* **Kịch bản kiểm thử độc lập (TC-3.11):** Khách hàng bình thường truy cập trực tiếp URL lễ tân bị từ chối 403 Forbidden; Lễ tân check-in thành công thấy thông báo trượt góc màn hình.

---

#### BƯỚC 12: TRIỂN KHAI FN-3.12 (KIỂM THỬ TÍCH HỢP E2E & BÀN GIAO PHASE 4)
* **Mục tiêu:** Chạy kịch bản hoàn chỉnh từ đầu đến cuối:
  1. Khách hàng đặt phòng trực tuyến từ Phase 2.
  2. Lễ tân tiếp đón khách tại quầy, tra cứu và thực hiện Check-in nhận phòng (Phase 3).
  3. Khách gọi thêm dịch vụ ăn uống / minibar tại phòng (Phase 3).
  4. Đối soát dữ liệu phát sinh với View `v_CongNoHoaDonKhachHang`.
* **Kịch bản kiểm thử độc lập (TC-3.12):** Tiền phòng + tiền dịch vụ phát sinh được ghi nhận toàn vẹn, sẵn sàng để phân hệ Thu ngân (Phase 4) thực hiện thanh toán và quyết toán hóa đơn.

---

"""

if old_sec7_start in content and old_sec8_start in content:
    idx_s7 = content.find(old_sec7_start)
    idx_s8 = content.find(old_sec8_start)
    content = content[:idx_s7] + new_sec7 + content[idx_s8:]
    print("Section 7 updated successfully.")
else:
    print("Section 7 or Section 8 not found, skipping.")

with open(target_path, "w", encoding="utf-8") as f:
    f.write(content)

print("File BaoCao_ThucThi_GiaiDoan_3.md written successfully.")
