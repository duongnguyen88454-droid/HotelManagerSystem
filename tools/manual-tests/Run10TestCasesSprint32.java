import com.mycompany.hotelmanagersystem.booking.dao.BookingCheckInDAO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInRequestDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInResultDTO;
import com.mycompany.hotelmanagersystem.booking.service.CheckInService;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.receptionist.service.RoomMapService;
import com.mycompany.hotelmanagersystem.room.dao.RoomDAO;
import com.mycompany.hotelmanagersystem.room.dto.BookingBarDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import java.io.File;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Run10TestCasesSprint32 {

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
        System.out.println("BẮT ĐẦU CHẠY BỘ 10 TEST CASES SPRINT 3.2 (FN-3.2 & FN-3.3)");
        System.out.println("TIMELINE BOOKING BARS & CHECK-IN ENGINE");
        System.out.println("==========================================================================");

        List<TestCaseResult> results = new ArrayList<>();
        BookingCheckInDAO checkInDAO = new BookingCheckInDAO();
        CheckInService checkInService = new CheckInService(checkInDAO);
        RoomService roomService = new RoomService(new RoomDAO());
        RoomMapService roomMapService = new RoomMapService(roomService, checkInService);

        LocalDate startDate = LocalDate.of(2026, 9, 29);
        LocalDate endDate = LocalDate.of(2026, 10, 5);

        // ---------------------------------------------------------------------
        // TC-3.2.01: Truy vấn danh sách dải đặt phòng trong tuần
        // ---------------------------------------------------------------------
        TestCaseResult tc01 = new TestCaseResult("TC-3.2.01", "Truy vấn dải đặt phòng tuần trên CSDL",
                "Lấy toàn bộ các booking có hiệu lực trong tuần 29/09 -> 05/10/2026",
                "Trả về danh sách BookingBarDTO không rỗng chứa BK003");
        try {
            List<BookingBarDTO> bars = checkInService.getBookingBarsInWeek(startDate, endDate);
            boolean hasBk003 = false;
            for (BookingBarDTO b : bars) {
                if ("BK003".equals(b.getMaBooking())) {
                    hasBk003 = true;
                    break;
                }
            }
            tc01.passed = !bars.isEmpty() && hasBk003;
            tc01.actual = "Tìm thấy " + bars.size() + " dải booking trong tuần, có BK003 = " + hasBk003;
        } catch (Exception e) {
            tc01.passed = false;
            tc01.errorDetail = e.getMessage();
        }
        results.add(tc01);

        // ---------------------------------------------------------------------
        // TC-3.2.02: Tính toán chính xác tọa độ cột startCol và colSpan cho BK003
        // ---------------------------------------------------------------------
        TestCaseResult tc02 = new TestCaseResult("TC-3.2.02", "Tính toán vị trí dải đặt phòng (startCol & colSpan)",
                "BK003 nhận ngày 29/09 (Thứ 2), trả ngày 01/10 (Thứ 4) trong tuần bắt đầu 29/09",
                "startCol = 1 (Thứ 2), colSpan = 2 hoặc 3 đêm");
        try {
            List<BookingBarDTO> bars = checkInService.getBookingBarsInWeek(startDate, endDate);
            BookingBarDTO bk03Bar = null;
            for (BookingBarDTO b : bars) {
                if ("BK003".equals(b.getMaBooking())) {
                    bk03Bar = b;
                    break;
                }
            }
            if (bk03Bar != null && bk03Bar.getStartCol() == 1 && bk03Bar.getColSpan() >= 2) {
                tc02.passed = true;
                tc02.actual = "BK003 startCol = " + bk03Bar.getStartCol() + ", colSpan = " + bk03Bar.getColSpan();
            } else {
                tc02.passed = false;
                tc02.actual = bk03Bar == null ? "Không tìm thấy BK003" : "startCol=" + bk03Bar.getStartCol() + ", colSpan=" + bk03Bar.getColSpan();
            }
        } catch (Exception e) {
            tc02.passed = false;
            tc02.errorDetail = e.getMessage();
        }
        results.add(tc02);

        // ---------------------------------------------------------------------
        // TC-3.2.03: RoomMapService phân phối BookingBarDTO vào đúng RoomTimelineDTO
        // ---------------------------------------------------------------------
        TestCaseResult tc03 = new TestCaseResult("TC-3.2.03", "RoomMapService gắn dải booking vào phòng tương ứng",
                "Gọi getTimelineWithBookingBars nạp danh sách phòng và dải đặt phòng",
                "Phòng P202 chứa dải đặt phòng của đơn BK003");
        try {
            List<RoomTimelineDTO> timelineRooms = roomMapService.getTimelineWithBookingBars(startDate, endDate);
            boolean p202HasBar = false;
            for (RoomTimelineDTO r : timelineRooms) {
                if ("P202".equals(r.getMaPhong())) {
                    for (BookingBarDTO b : r.getBookingBars()) {
                        if ("BK003".equals(b.getMaBooking())) {
                            p202HasBar = true;
                            break;
                        }
                    }
                }
            }
            tc03.passed = p202HasBar;
            tc03.actual = "P202 có dải booking BK003 = " + p202HasBar;
        } catch (Exception e) {
            tc03.passed = false;
            tc03.errorDetail = e.getMessage();
        }
        results.add(tc03);

        // ---------------------------------------------------------------------
        // TC-3.2.04: Chặn Check-in khi chưa tích xác nhận đối chiếu CCCD
        // ---------------------------------------------------------------------
        TestCaseResult tc04 = new TestCaseResult("TC-3.2.04", "Ràng buộc kiểm tra CCCD khi Check-in",
                "Gửi CheckInRequestDTO với daDoiChieuCccd = false",
                "Trả về success = false kèm thông báo yêu cầu đối chiếu CCCD");
        try {
            CheckInRequestDTO req = new CheckInRequestDTO("BK003", "P202", "NV001", "Ghi chu", false);
            CheckInResultDTO res = checkInService.executeCheckIn(req);
            tc04.passed = !res.isSuccess() && res.getMessage().contains("CCCD");
            tc04.actual = "Success = " + res.isSuccess() + ", Message = " + res.getMessage();
        } catch (Exception e) {
            tc04.passed = false;
            tc04.errorDetail = e.getMessage();
        }
        results.add(tc04);

        // ---------------------------------------------------------------------
        // TC-3.2.05: Chặn Check-in với tham số rỗng hoặc không hợp lệ
        // ---------------------------------------------------------------------
        TestCaseResult tc05 = new TestCaseResult("TC-3.2.05", "Xử lý tham số rỗng / null an toàn",
                "Gửi request với mã booking null hoặc mã phòng rỗng",
                "Bị từ chối an toàn, không ném NullPointerException");
        try {
            CheckInRequestDTO reqNull = new CheckInRequestDTO(null, "P202", "NV001", null, true);
            CheckInResultDTO resNull = checkInService.executeCheckIn(reqNull);

            CheckInRequestDTO reqEmpty = new CheckInRequestDTO("BK003", "", "NV001", null, true);
            CheckInResultDTO resEmpty = checkInService.executeCheckIn(reqEmpty);

            tc05.passed = !resNull.isSuccess() && !resEmpty.isSuccess();
            tc05.actual = "Null check: " + resNull.isSuccess() + ", Empty check: " + resEmpty.isSuccess();
        } catch (Exception e) {
            tc05.passed = false;
            tc05.errorDetail = e.getMessage();
        }
        results.add(tc05);

        // ---------------------------------------------------------------------
        // TC-3.2.06: Chặn Check-in cho đơn không tồn tại
        // ---------------------------------------------------------------------
        TestCaseResult tc06 = new TestCaseResult("TC-3.2.06", "Chặn Check-in đơn không tồn tại",
                "Thử check-in đơn BK999999",
                "Trả về success = false");
        try {
            CheckInRequestDTO req = new CheckInRequestDTO("BK999999", "P101", "NV001", null, true);
            CheckInResultDTO res = checkInService.executeCheckIn(req);
            tc06.passed = !res.isSuccess();
            tc06.actual = "Success = " + res.isSuccess() + ", Message = " + res.getMessage();
        } catch (Exception e) {
            tc06.passed = false;
            tc06.errorDetail = e.getMessage();
        }
        results.add(tc06);

        // ---------------------------------------------------------------------
        // TC-3.2.07: Kiểm thử thực thi Check-in thật trên CSDL với Booking test riêng
        // ---------------------------------------------------------------------
        TestCaseResult tc07 = new TestCaseResult("TC-3.2.07", "Thực thi Check-in thật kích hoạt Trigger đổi phòng sang Occupied",
                "Tạo đơn đặt phòng test trên phòng P403, gọi executeCheckIn, kiểm tra DB",
                "BOOKING.TrangThai = DaCheckIn, NgayCheckInThucTe != null, PHONG.TrangThai = Occupied");
        String testBookingId = "T32A" + (System.currentTimeMillis() % 9000 + 1000);
        try {
            // 1. Chèn đơn test vào CSDL
            try (Connection conn = DBContext.getConnection()) {
                String insertB = "INSERT INTO BOOKING (MaBooking, MaKH, TrangThai, ChiPhiDuKien) "
                               + "VALUES (?, 'KH001', 'DaXacNhan', 1000000)";
                try (PreparedStatement ps = conn.prepareStatement(insertB)) {
                    ps.setString(1, testBookingId);
                    ps.executeUpdate();
                }

                String insertBp = "INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien) "
                                + "VALUES (?, 'P403', 1000000, '2026-10-01', '2026-10-03')";
                try (PreparedStatement ps = conn.prepareStatement(insertBp)) {
                    ps.setString(1, testBookingId);
                    ps.executeUpdate();
                }
            }

            // 2. Thực hiện Check-in qua CheckInService
            CheckInRequestDTO req = new CheckInRequestDTO(testBookingId, "P403", "NV001", "Test Check-in", true);
            CheckInResultDTO res = checkInService.executeCheckIn(req);

            // 3. Kiểm tra dữ liệu CSDL sau khi Check-in
            boolean bStatusOk = false;
            boolean bpCheckInTimeOk = false;
            boolean pOccupiedOk = false;

            try (Connection conn = DBContext.getConnection()) {
                String qB = "SELECT TrangThai FROM BOOKING WHERE MaBooking = ?";
                try (PreparedStatement ps = conn.prepareStatement(qB)) {
                    ps.setString(1, testBookingId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            bStatusOk = "DaCheckIn".equalsIgnoreCase(rs.getString("TrangThai"));
                        }
                    }
                }

                String qBp = "SELECT NgayCheckInThucTe FROM BOOKING_PHONG WHERE MaBooking = ? AND MaPhong = 'P403'";
                try (PreparedStatement ps = conn.prepareStatement(qBp)) {
                    ps.setString(1, testBookingId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            bpCheckInTimeOk = (rs.getTimestamp("NgayCheckInThucTe") != null);
                        }
                    }
                }

                String qP = "SELECT TrangThai FROM PHONG WHERE MaPhong = 'P403'";
                try (PreparedStatement ps = conn.prepareStatement(qP)) {
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            pOccupiedOk = "Occupied".equalsIgnoreCase(rs.getString("TrangThai"));
                        }
                    }
                }
            }

            tc07.passed = res.isSuccess() && bStatusOk && bpCheckInTimeOk && pOccupiedOk;
            tc07.actual = "Service res=" + res.isSuccess() + ", Booking DaCheckIn=" + bStatusOk 
                        + ", CheckInThucTe=" + bpCheckInTimeOk + ", Phong Occupied=" + pOccupiedOk;

        } catch (Exception e) {
            tc07.passed = false;
            tc07.errorDetail = e.getMessage();
        } finally {
            // Dọn dẹp dữ liệu test để phục hồi trạng thái P403
            try (Connection conn = DBContext.getConnection()) {
                String delBp = "DELETE FROM BOOKING_PHONG WHERE MaBooking = ?";
                try (PreparedStatement ps = conn.prepareStatement(delBp)) {
                    ps.setString(1, testBookingId);
                    ps.executeUpdate();
                }
                String delB = "DELETE FROM BOOKING WHERE MaBooking = ?";
                try (PreparedStatement ps = conn.prepareStatement(delB)) {
                    ps.setString(1, testBookingId);
                    ps.executeUpdate();
                }
                String resetP = "UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = 'P403'";
                try (PreparedStatement ps = conn.prepareStatement(resetP)) {
                    ps.executeUpdate();
                }
            } catch (Exception ignored) {
            }
        }
        results.add(tc07);

        // ---------------------------------------------------------------------
        // TC-3.2.08: Chặn Check-in lần thứ hai trên cùng một đơn đã Check-in
        // ---------------------------------------------------------------------
        TestCaseResult tc08 = new TestCaseResult("TC-3.2.08", "Tính bất biến (Idempotency) khi Check-in lại phòng đã ở",
                "Thử check-in đơn BK001 (đã Check-in từ trước)",
                "Bị từ chối vì phòng đã hoàn tất Check-in");
        try {
            CheckInRequestDTO req = new CheckInRequestDTO("BK001", "P201", "NV001", "Check lại", true);
            CheckInResultDTO res = checkInService.executeCheckIn(req);
            tc08.passed = !res.isSuccess();
            tc08.actual = "Success = " + res.isSuccess() + ", Message = " + res.getMessage();
        } catch (Exception e) {
            tc08.passed = false;
            tc08.errorDetail = e.getMessage();
        }
        results.add(tc08);

        // ---------------------------------------------------------------------
        // TC-3.2.09: Kiểm thử tranh chấp đồng thời (Concurrency) khi nhiều luồng cùng Check-in
        // ---------------------------------------------------------------------
        TestCaseResult tc09 = new TestCaseResult("TC-3.2.09", "An toàn tranh chấp đồng thời (Concurrency Test)",
                "5 luồng đồng thời gọi executeCheckIn trên cùng một đơn test",
                "Chính xác duy nhất 1 luồng thành công, 4 luồng còn lại bị từ chối");
        String concurBookingId = "T32B" + (System.currentTimeMillis() % 9000 + 1000);
        try {
            try (Connection conn = DBContext.getConnection()) {
                String insertB = "INSERT INTO BOOKING (MaBooking, MaKH, TrangThai, ChiPhiDuKien) "
                               + "VALUES (?, 'KH001', 'DaXacNhan', 1000000)";
                try (PreparedStatement ps = conn.prepareStatement(insertB)) {
                    ps.setString(1, concurBookingId);
                    ps.executeUpdate();
                }

                String insertBp = "INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien) "
                                + "VALUES (?, 'P402', 1000000, '2026-10-01', '2026-10-03')";
                try (PreparedStatement ps = conn.prepareStatement(insertBp)) {
                    ps.setString(1, concurBookingId);
                    ps.executeUpdate();
                }
            }

            int threadCount = 5;
            ExecutorService executor = Executors.newFixedThreadPool(threadCount);
            CountDownLatch latch = new CountDownLatch(1);
            CountDownLatch doneLatch = new CountDownLatch(threadCount);
            AtomicInteger successCount = new AtomicInteger(0);

            for (int i = 0; i < threadCount; i++) {
                final int idx = i;
                executor.submit(() -> {
                    try {
                        latch.await();
                        CheckInRequestDTO req = new CheckInRequestDTO(concurBookingId, "P402", "NV00" + (idx + 1), "Concur test", true);
                        CheckInResultDTO res = checkInService.executeCheckIn(req);
                        if (res.isSuccess()) {
                            successCount.incrementAndGet();
                        }
                    } catch (Exception ignored) {
                    } finally {
                        doneLatch.countDown();
                    }
                });
            }

            latch.countDown();
            doneLatch.await();
            executor.shutdown();

            tc09.passed = (successCount.get() == 1);
            tc09.actual = "Số luồng check-in thành công: " + successCount.get() + " / " + threadCount;
        } catch (Exception e) {
            tc09.passed = false;
            tc09.errorDetail = e.getMessage();
        } finally {
            try (Connection conn = DBContext.getConnection()) {
                String delBp = "DELETE FROM BOOKING_PHONG WHERE MaBooking = ?";
                try (PreparedStatement ps = conn.prepareStatement(delBp)) {
                    ps.setString(1, concurBookingId);
                    ps.executeUpdate();
                }
                String delB = "DELETE FROM BOOKING WHERE MaBooking = ?";
                try (PreparedStatement ps = conn.prepareStatement(delB)) {
                    ps.setString(1, concurBookingId);
                    ps.executeUpdate();
                }
                String resetP = "UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = 'P402'";
                try (PreparedStatement ps = conn.prepareStatement(resetP)) {
                    ps.executeUpdate();
                }
            } catch (Exception ignored) {
            }
        }
        results.add(tc09);

        // ---------------------------------------------------------------------
        // TC-3.2.10: Kiểm tra tuân thủ giao diện UI: Tuyệt đối không dùng Icon/Emoji
        // ---------------------------------------------------------------------
        TestCaseResult tc10 = new TestCaseResult("TC-3.2.10", "Tuân thủ quy chuẩn UI: Tuyệt đối không Icon/Emoji",
                "Quét file views/receptionist/room_map.jsp kiểm tra icon font và emoji",
                "0 icon font, 0 emoji character");
        try {
            File jspFile = new File("src/main/webapp/views/receptionist/room_map.jsp");
            String content = new String(Files.readAllBytes(jspFile.toPath()), "UTF-8");

            boolean hasFa = content.contains("fa-") || content.contains("fas ") || content.contains("far ") || content.contains("fontawesome");
            boolean hasMaterial = content.contains("material-icons");
            boolean hasBootstrapIcons = content.contains("bi-");

            boolean hasEmoji = false;
            for (int i = 0; i < content.length(); ) {
                int cp = content.codePointAt(i);
                if ((cp >= 0x1F300 && cp <= 0x1FAFF) || (cp >= 0x2600 && cp <= 0x27BF)) {
                    hasEmoji = true;
                    break;
                }
                i += Character.charCount(cp);
            }

            tc10.passed = !hasFa && !hasMaterial && !hasBootstrapIcons && !hasEmoji;
            tc10.actual = "FA=" + hasFa + ", Material=" + hasMaterial + ", BI=" + hasBootstrapIcons + ", Emoji=" + hasEmoji;
        } catch (Exception e) {
            tc10.passed = false;
            tc10.errorDetail = e.getMessage();
        }
        results.add(tc10);

        // ---------------------------------------------------------------------
        // IN BẢNG BÁO CÁO KẾT QUẢ
        // ---------------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------------------------------------------------");
        System.out.printf("%-12s | %-40s | %-8s | %s\n", "MÃ TEST", "TÊN TEST CASE", "KẾT QUẢ", "CHI TIẾT THỰC TẾ");
        System.out.println("-------------------------------------------------------------------------------------------------------");
        int passCount = 0;
        for (TestCaseResult r : results) {
            if (r.passed) {
                passCount++;
                System.out.printf("%-12s | %-40s | %-8s | %s\n", r.id, r.name, "[ PASS ]", r.actual);
            } else {
                System.out.printf("%-12s | %-40s | %-8s | %s (Lỗi: %s)\n", r.id, r.name, "[ FAIL ]", r.actual, r.errorDetail);
            }
        }
        System.out.println("-------------------------------------------------------------------------------------------------------");
        System.out.println("TỔNG KẾT: " + passCount + "/" + results.size() + " TEST CASES ĐẠT YÊU CẦU (" + (passCount * 100 / results.size()) + "%).");
        System.out.println("=======================================================================================================\n");

        if (passCount != results.size()) {
            System.exit(1);
        }
    }
}
