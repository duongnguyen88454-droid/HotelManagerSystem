import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.hotelservice.dao.RoomServiceOrderDAO;
import com.mycompany.hotelmanagersystem.hotelservice.dao.ServiceDAO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.RoomServiceUsageDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderRequestDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderResultDTO;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.hotelservice.service.HotelServiceService;
import com.mycompany.hotelmanagersystem.hotelservice.service.RoomServiceOrderService;

import java.io.File;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Run10TestCasesSprint33 {

    static class TestCaseResult {
        String id;
        String name;
        String objective;
        boolean passed;
        String actual;
        String expected;
        String errorDetail;

        TestCaseResult(String id, String name, String objective, String expected) {
            this.id = id;
            this.name = name;
            this.objective = objective;
            this.expected = expected;
        }
    }

    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("BẮT ĐẦU CHẠY BỘ 10 TEST CASES SPRINT 3.3 (FN-3.4 & FN-3.5)");
        System.out.println("IN-STAY ROOM SERVICE ORDERING & SERVICE USAGE INQUIRY");
        System.out.println("==========================================================================");

        List<TestCaseResult> results = new ArrayList<>();
        ServiceDAO serviceDAO = new ServiceDAO();
        HotelServiceService hotelServiceService = new HotelServiceService(serviceDAO);
        RoomServiceOrderDAO orderDAO = new RoomServiceOrderDAO();
        RoomServiceOrderService orderService = new RoomServiceOrderService(orderDAO, serviceDAO);

        // Chuẩn bị dữ liệu kiểm thử: Đơn booking test đang ở trạng thái DaCheckIn
        String testBookingId = "T33A" + (System.currentTimeMillis() % 9000 + 1000);
        String testRoomId = "P201";

        try (Connection conn = DBContext.getConnection()) {
            // Tạo đơn test lưu trú DaCheckIn
            String insertB = "INSERT INTO BOOKING (MaBooking, MaKH, TrangThai, ChiPhiDuKien, PhuongPhapBooking) "
                           + "VALUES (?, 'KH001', 'DaCheckIn', 2000000, 'Offline')";
            try (PreparedStatement ps = conn.prepareStatement(insertB)) {
                ps.setString(1, testBookingId);
                ps.executeUpdate();
            }

            String insertBp = "INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien, NgayCheckInThucTe) "
                            + "VALUES (?, ?, 1000000, '2026-10-01', '2026-10-03', GETDATE())";
            try (PreparedStatement ps = conn.prepareStatement(insertBp)) {
                ps.setString(1, testBookingId);
                ps.setString(2, testRoomId);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            System.err.println("Lỗi khởi tạo dữ liệu test Sprint 3.3: " + e.getMessage());
        }

        // ---------------------------------------------------------------------
        // TC-3.3.01: Lấy danh mục dịch vụ đang áp dụng kinh doanh
        // ---------------------------------------------------------------------
        TestCaseResult tc01 = new TestCaseResult("TC-3.3.01", "Lấy danh mục dịch vụ đang áp dụng kinh doanh",
                "HotelServiceService.getAllActiveServices() trả về danh sách dịch vụ ApDung",
                "Danh sách không rỗng, chứa DV05 (Mini Bar) và DV01 (Buffet)");
        try {
            List<ServiceItem> menu = hotelServiceService.getAllActiveServices();
            boolean hasDv05 = menu.stream().anyMatch(s -> "DV05".equals(s.getMaDichVu()));
            boolean hasDv01 = menu.stream().anyMatch(s -> "DV01".equals(s.getMaDichVu()));
            tc01.passed = !menu.isEmpty() && hasDv05 && hasDv01;
            tc01.actual = "Tổng dịch vụ khả dụng = " + menu.size() + " (DV05=" + hasDv05 + ", DV01=" + hasDv01 + ")";
        } catch (Exception e) {
            tc01.passed = false;
            tc01.errorDetail = e.getMessage();
        }
        results.add(tc01);

        // ---------------------------------------------------------------------
        // TC-3.3.02: Chặn gọi dịch vụ với số lượng <= 0
        // ---------------------------------------------------------------------
        TestCaseResult tc02 = new TestCaseResult("TC-3.3.02", "Chặn gọi dịch vụ với số lượng không hợp lệ",
                "Gọi dịch vụ với số lượng 0 hoặc âm phải bị từ chối ngay tại tầng Service",
                "Success = false, thông báo lỗi số lượng");
        try {
            ServiceOrderRequestDTO reqZero = new ServiceOrderRequestDTO(testBookingId, testRoomId, "DV05", 0, "NV001", "Test Zero");
            ServiceOrderResultDTO resZero = orderService.orderService(reqZero);

            ServiceOrderRequestDTO reqNegative = new ServiceOrderRequestDTO(testBookingId, testRoomId, "DV05", -3, "NV001", "Test Negative");
            ServiceOrderResultDTO resNegative = orderService.orderService(reqNegative);

            tc02.passed = !resZero.isSuccess() && !resNegative.isSuccess();
            tc02.actual = "Zero success=" + resZero.isSuccess() + " | Negative success=" + resNegative.isSuccess();
        } catch (Exception e) {
            tc02.passed = false;
            tc02.errorDetail = e.getMessage();
        }
        results.add(tc02);

        // ---------------------------------------------------------------------
        // TC-3.3.03: Chặn gọi dịch vụ không tồn tại hoặc đã ngưng áp dụng
        // ---------------------------------------------------------------------
        TestCaseResult tc03 = new TestCaseResult("TC-3.3.03", "Chặn gọi dịch vụ không tồn tại trong danh mục",
                "Cố tình gửi mã dịch vụ không tồn tại DV9999",
                "Success = false, thông báo dịch vụ không tồn tại");
        try {
            ServiceOrderRequestDTO reqInvalid = new ServiceOrderRequestDTO(testBookingId, testRoomId, "DV9999", 2, "NV001", "Test Invalid DV");
            ServiceOrderResultDTO resInvalid = orderService.orderService(reqInvalid);

            tc03.passed = !resInvalid.isSuccess() && resInvalid.getMessage().contains("không tồn tại");
            tc03.actual = "Success=" + resInvalid.isSuccess() + ", Message=" + resInvalid.getMessage();
        } catch (Exception e) {
            tc03.passed = false;
            tc03.errorDetail = e.getMessage();
        }
        results.add(tc03);

        // ---------------------------------------------------------------------
        // TC-3.3.04: Chặn gọi dịch vụ cho đơn chưa Check-in (DaXacNhan)
        // ---------------------------------------------------------------------
        TestCaseResult tc04 = new TestCaseResult("TC-3.3.04", "Chặn gọi dịch vụ khi khách chưa hoàn tất Check-in",
                "Đơn đặt phòng BK003 mới chỉ DaXacNhan, chưa Check-in phòng",
                "Stored procedure từ chối với lỗi chỉ cho phép khi khách đang lưu trú");
        try {
            ServiceOrderRequestDTO reqNotCheckedIn = new ServiceOrderRequestDTO("BK003", "P202", "DV05", 1, "NV001", "Test Chưa Checkin");
            ServiceOrderResultDTO resNotCheckedIn = orderService.orderService(reqNotCheckedIn);

            tc04.passed = !resNotCheckedIn.isSuccess();
            tc04.actual = "Success=" + resNotCheckedIn.isSuccess() + ", Message=" + resNotCheckedIn.getMessage();
        } catch (Exception e) {
            tc04.passed = false;
            tc04.errorDetail = e.getMessage();
        }
        results.add(tc04);

        // ---------------------------------------------------------------------
        // TC-3.3.05: Gọi thành công dịch vụ hợp lệ cho phòng đang DaCheckIn
        // ---------------------------------------------------------------------
        TestCaseResult tc05 = new TestCaseResult("TC-3.3.05", "Gọi dịch vụ hợp lệ thành công qua sp_GoiThemDichVu",
                "Thêm 2 lon nước ngọt Mini Bar (DV05) vào phòng test",
                "Success = true, mã BookingDichVu được sinh, tổng tiền tăng");
        String createdBdvId = null;
        try {
            ServiceOrderRequestDTO reqValid = new ServiceOrderRequestDTO(testBookingId, testRoomId, "DV05", 2, "NV001", "Khách xin thêm đá");
            ServiceOrderResultDTO resValid = orderService.orderService(reqValid);

            createdBdvId = resValid.getMaBookingDichVu();
            tc05.passed = resValid.isSuccess() && createdBdvId != null && resValid.getTongTienDichVuMoi() >= 60000;
            tc05.actual = "Success=" + resValid.isSuccess() + ", MaBDV=" + createdBdvId + ", TongTienDV=" + resValid.getTongTienDichVuMoi();
        } catch (Exception e) {
            tc05.passed = false;
            tc05.errorDetail = e.getMessage();
        }
        results.add(tc05);

        // ---------------------------------------------------------------------
        // TC-3.3.06: Kiểm tra tính toàn vẹn dữ liệu trong bảng BOOKING_DICHVU
        // ---------------------------------------------------------------------
        TestCaseResult tc06 = new TestCaseResult("TC-3.3.06", "Kiểm tra dữ liệu chuẩn xác trong CSDL",
                "Bản ghi BOOKING_DICHVU vừa chèn lưu đúng Đơn giá (30.000 đ), SL (2), Người thêm (NhanVien), MaNV (NV001)",
                "Dữ liệu khớp 100% với tham số gọi");
        try (Connection conn = DBContext.getConnection()) {
            String checkSql = "SELECT DonGia, SoLuong, NguoiThem, MaNV FROM BOOKING_DICHVU WHERE MaBookingDichVu = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, createdBdvId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        double donGia = rs.getDouble("DonGia");
                        int sl = rs.getInt("SoLuong");
                        String nguoiThem = rs.getString("NguoiThem");
                        String maNV = rs.getString("MaNV");

                        tc06.passed = (donGia == 30000.0) && (sl == 2) && "NhanVien".equals(nguoiThem) && "NV001".equals(maNV);
                        tc06.actual = "DonGia=" + donGia + ", SL=" + sl + ", NguoiThem=" + nguoiThem + ", MaNV=" + maNV;
                    } else {
                        tc06.passed = false;
                        tc06.actual = "Không tìm thấy bản ghi " + createdBdvId;
                    }
                }
            }
        } catch (Exception e) {
            tc06.passed = false;
            tc06.errorDetail = e.getMessage();
        }
        results.add(tc06);

        // ---------------------------------------------------------------------
        // TC-3.3.07: Gọi thêm món thứ hai và truy vấn bảng kê dịch vụ phòng (FN-3.5)
        // ---------------------------------------------------------------------
        TestCaseResult tc07 = new TestCaseResult("TC-3.3.07", "Truy vấn danh sách dịch vụ phòng đã dùng (FN-3.5)",
                "Gọi thêm 1 suất Buffet sáng (DV01), sau đó lấy danh sách dịch vụ đã dùng",
                "Danh sách trả về chứa 2 món (DV05 và DV01)");
        try {
            ServiceOrderRequestDTO reqBuffet = new ServiceOrderRequestDTO(testBookingId, testRoomId, "DV01", 1, "NV001", "1 Buffet sang");
            orderService.orderService(reqBuffet);

            List<RoomServiceUsageDTO> usedList = orderService.getServicesUsed(testBookingId, testRoomId);
            boolean hasDv05 = usedList.stream().anyMatch(u -> "DV05".equals(u.getMaDichVu()));
            boolean hasDv01 = usedList.stream().anyMatch(u -> "DV01".equals(u.getMaDichVu()));

            tc07.passed = (usedList.size() >= 2) && hasDv05 && hasDv01;
            tc07.actual = "Tổng món đã dùng=" + usedList.size() + " (DV05=" + hasDv05 + ", DV01=" + hasDv01 + ")";
        } catch (Exception e) {
            tc07.passed = false;
            tc07.errorDetail = e.getMessage();
        }
        results.add(tc07);

        // ---------------------------------------------------------------------
        // TC-3.3.08: Tính toán chính xác tổng chi phí dịch vụ lũy kế
        // ---------------------------------------------------------------------
        TestCaseResult tc08 = new TestCaseResult("TC-3.3.08", "Tính tổng chi phí dịch vụ lũy kế chính xác",
                "2 x 30.000 đ (Mini Bar) + 1 x 150.000 đ (Buffet) = 210.000 đ",
                "Tổng tiền dịch vụ = 210.000 đ");
        try {
            List<RoomServiceUsageDTO> usedList = orderService.getServicesUsed(testBookingId, testRoomId);
            double totalCost = orderService.calculateTotalServicesCost(usedList);

            tc08.passed = (totalCost == 210000.0);
            tc08.actual = "Tổng chi phí tính được = " + totalCost + " đ";
        } catch (Exception e) {
            tc08.passed = false;
            tc08.errorDetail = e.getMessage();
        }
        results.add(tc08);

        // ---------------------------------------------------------------------
        // TC-3.3.09: Chặn gọi dịch vụ vào phòng không thuộc đơn đặt phòng
        // ---------------------------------------------------------------------
        TestCaseResult tc09 = new TestCaseResult("TC-3.3.09", "Chặn chỉ định phòng sai đơn booking",
                "Đơn booking test ở phòng P201 nhưng lại chỉ định gọi dịch vụ vào phòng P403",
                "Success = false, Stored procedure ném lỗi phòng không thuộc đơn");
        try {
            ServiceOrderRequestDTO reqWrongRoom = new ServiceOrderRequestDTO(testBookingId, "P403", "DV05", 1, "NV001", "Wrong Room");
            ServiceOrderResultDTO resWrongRoom = orderService.orderService(reqWrongRoom);

            tc09.passed = !resWrongRoom.isSuccess() && resWrongRoom.getMessage() != null && !resWrongRoom.getMessage().trim().isEmpty();
            tc09.actual = "Success=" + resWrongRoom.isSuccess() + ", Message=" + resWrongRoom.getMessage();
        } catch (Exception e) {
            tc09.passed = false;
            tc09.errorDetail = e.getMessage();
        }
        results.add(tc09);

        // ---------------------------------------------------------------------
        // TC-3.3.10: Tuân thủ quy chuẩn UI: Tuyệt đối không Icon/Emoji trên room_map.jsp
        // ---------------------------------------------------------------------
        TestCaseResult tc10 = new TestCaseResult("TC-3.3.10", "Tuân thủ quy chuẩn UI: Tuyệt đối không Icon/Emoji",
                "File room_map.jsp không chứa thẻ FontAwesome, Material Icons, Bootstrap Icons và Emoji",
                "100% Text Badges và Button Text thuần");
        try {
            File jspFile = new File("src/main/webapp/views/receptionist/room_map.jsp");
            String content = new String(Files.readAllBytes(jspFile.toPath()), "UTF-8");

            boolean hasFa = content.contains("fa-") || content.contains("fas ") || content.contains("far ");
            boolean hasMaterial = content.contains("material-icons");
            boolean hasBi = content.contains("bi-");

            boolean hasEmoji = false;
            for (int i = 0; i < content.length();) {
                int cp = content.codePointAt(i);
                if ((cp >= 0x1F300 && cp <= 0x1FAFF) || (cp >= 0x2600 && cp <= 0x27BF)) {
                    hasEmoji = true;
                    break;
                }
                i += Character.charCount(cp);
            }

            boolean uiClean = !hasFa && !hasMaterial && !hasBi && !hasEmoji;
            tc10.passed = uiClean;
            tc10.actual = "FA=" + hasFa + ", Material=" + hasMaterial + ", BI=" + hasBi + ", Emoji=" + hasEmoji;
        } catch (Exception e) {
            tc10.passed = false;
            tc10.errorDetail = e.getMessage();
        }
        results.add(tc10);

        // Dọn dẹp dữ liệu kiểm thử
        try (Connection conn = DBContext.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM THANHTOAN WHERE MaHoaDon IN (SELECT MaHoaDon FROM HOADON WHERE MaBooking = ?)")) {
                ps.setString(1, testBookingId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM HOADON WHERE MaBooking = ?")) {
                ps.setString(1, testBookingId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING_DICHVU WHERE MaBooking = ?")) {
                ps.setString(1, testBookingId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING_PHONG WHERE MaBooking = ?")) {
                ps.setString(1, testBookingId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING WHERE MaBooking = ?")) {
                ps.setString(1, testBookingId);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            System.err.println("Lỗi dọn dẹp dữ liệu test: " + e.getMessage());
        }

        // ---------------------------------------------------------------------
        // IN BẢNG BÁO CÁO KẾT QUẢ
        // ---------------------------------------------------------------------
        System.out.println("-------------------------------------------------------------------------------------------------------");
        System.out.printf("%-12s | %-40s | %-8s | %s%n", "MÃ TEST", "TÊN TEST CASE", "KẾT QUẢ", "CHI TIẾT THỰC TẾ");
        System.out.println("-------------------------------------------------------------------------------------------------------");

        int passCount = 0;
        for (TestCaseResult r : results) {
            if (r.passed) passCount++;
            String status = r.passed ? "[ PASS ]" : "[ FAIL ]";
            System.out.printf("%-12s | %-40s | %-8s | %s%n", r.id, r.name, status, r.actual != null ? r.actual : r.errorDetail);
        }

        System.out.println("-------------------------------------------------------------------------------------------------------");
        System.out.printf("TỔNG KẾT: %d/%d TEST CASES ĐẠT YÊU CẦU (%d%%).%n", passCount, results.size(), (passCount * 100 / results.size()));
        System.out.println("=======================================================================================================");
    }
}
