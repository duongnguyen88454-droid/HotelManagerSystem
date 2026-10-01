package scratch;

import com.mycompany.hotelmanagersystem.dao.room.RoomDAO;
import com.mycompany.hotelmanagersystem.dto.receptionist.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.dto.receptionist.RoomTimelineDTO;

import java.io.File;
import java.nio.file.Files;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Run20TestCasesFN31 {

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
        System.out.println("BẮT ĐẦU CHẠY 20 TEST CASES CHO CHỨC NĂNG FN-3.1 (PHÂN HỆ LỄ TÂN)");
        System.out.println("==========================================================================");

        List<TestCaseResult> results = new ArrayList<>();
        RoomDAO roomDAO = new RoomDAO();

        // Query DB once for testing
        List<RoomTimelineDTO> rooms = null;
        RoomMapKpiDTO kpi = null;
        try {
            rooms = roomDAO.getAllRoomsForTimeline();
            kpi = roomDAO.getRoomMapKpi();
        } catch (Exception e) {
            System.err.println("Lỗi khi kết nối CSDL: " + e.getMessage());
        }

        // TC-3.1.01: Truy vấn danh sách phòng không rỗng
        TestCaseResult tc01 = new TestCaseResult("TC-3.1.01", "Truy vấn danh sách phòng thực tế từ CSDL",
                "Đảm bảo DAO trả về danh sách phòng không bị null và có dữ liệu",
                "Danh sách phòng không null, số lượng phòng > 0");
        if (rooms != null && !rooms.isEmpty()) {
            tc01.passed = true;
            tc01.actual = "Tìm thấy " + rooms.size() + " phòng trong CSDL";
        } else {
            tc01.passed = false;
            tc01.actual = (rooms == null) ? "null" : "rỗng (0 phòng)";
            tc01.errorDetail = "Không kết nối được hoặc bảng PHONG trống";
        }
        results.add(tc01);

        // TC-3.1.02: Thứ tự sắp xếp phòng tăng dần theo số phòng
        TestCaseResult tc02 = new TestCaseResult("TC-3.1.02", "Sắp xếp phòng tăng dần theo số phòng",
                "Kiểm tra thứ tự phòng hiển thị trên timeline phải được sắp xếp theo SoPhong tăng dần",
                "SoPhong các phòng liền kề phải tăng dần (ví dụ 101, 102, 103...)");
        if (rooms != null && rooms.size() > 1) {
            boolean sorted = true;
            String prev = rooms.get(0).getSoPhong();
            for (int i = 1; i < rooms.size(); i++) {
                String curr = rooms.get(i).getSoPhong();
                if (curr.compareTo(prev) < 0) {
                    sorted = false;
                    tc02.errorDetail = "Phòng " + curr + " đứng sau phòng " + prev;
                    break;
                }
                prev = curr;
            }
            tc02.passed = sorted;
            tc02.actual = sorted ? "Toàn bộ danh sách sắp xếp tăng dần chính xác" : tc02.errorDetail;
        } else {
            tc02.passed = false;
            tc02.actual = "Không đủ phòng để kiểm tra";
        }
        results.add(tc02);

        // TC-3.1.03: Phân rã tầng chính xác từ số phòng
        TestCaseResult tc03 = new TestCaseResult("TC-3.1.03", "Trích xuất tầng (SoTang) từ số phòng",
                "Đảm bảo ký tự đầu của số phòng (ví dụ 101 -> Tầng 1, 402 -> Tầng 4) được trích xuất đúng",
                "SoTang == Character.getNumericValue(soPhong[0])");
        if (rooms != null && !rooms.isEmpty()) {
            boolean allFloorMatch = true;
            for (RoomTimelineDTO r : rooms) {
                int expectedFloor = Character.getNumericValue(r.getSoPhong().charAt(0));
                if (r.getSoTang() != expectedFloor) {
                    allFloorMatch = false;
                    tc03.errorDetail = "Phòng " + r.getSoPhong() + " có soTang=" + r.getSoTang() + ", kỳ vọng=" + expectedFloor;
                    break;
                }
            }
            tc03.passed = allFloorMatch;
            tc03.actual = allFloorMatch ? "100% phòng được phân tầng chính xác" : tc03.errorDetail;
        } else {
            tc03.passed = false;
            tc03.actual = "Danh sách phòng rỗng";
        }
        results.add(tc03);

        // TC-3.1.04: Xử lý an toàn khi số phòng không hợp lệ (Edge case)
        TestCaseResult tc04 = new TestCaseResult("TC-3.1.04", "Xử lý an toàn trích xuất tầng khi SoPhong đặc biệt",
                "Kiểm tra không bị văng Exception khi SoPhong là null, rỗng hoặc chứa chữ",
                "Không bị Exception, trả về tầng mặc định");
        try {
            RoomTimelineDTO dummy1 = new RoomTimelineDTO("P00", null, 1, "LP01", "Test", 100000, "Available", "");
            RoomTimelineDTO dummy2 = new RoomTimelineDTO("P00", "", 1, "LP01", "Test", 100000, "Available", "");
            RoomTimelineDTO dummy3 = new RoomTimelineDTO("P00", "VIP1", 1, "LP01", "Test", 100000, "Available", "");
            tc04.passed = true;
            tc04.actual = "Khởi tạo an toàn, không bị NullPointerException hoặc IndexOutOfBoundsException";
        } catch (Exception e) {
            tc04.passed = false;
            tc04.actual = "Bị Exception: " + e.getMessage();
        }
        results.add(tc04);

        // TC-3.1.05: Toàn vẹn dữ liệu JOIN LOAIPHONG (TenLoaiPhong)
        TestCaseResult tc05 = new TestCaseResult("TC-3.1.05", "Dữ liệu Hạng phòng (TenLoaiPhong) từ bảng LOAIPHONG",
                "Đảm bảo câu lệnh JOIN không bị rỗng tên loại phòng",
                "Tất cả phòng đều có tenLoaiPhong != null và không rỗng");
        if (rooms != null && !rooms.isEmpty()) {
            boolean valid = true;
            for (RoomTimelineDTO r : rooms) {
                if (r.getTenLoaiPhong() == null || r.getTenLoaiPhong().trim().isEmpty()) {
                    valid = false;
                    tc05.errorDetail = "Phòng " + r.getMaPhong() + " bị null hoặc rỗng tenLoaiPhong";
                    break;
                }
            }
            tc05.passed = valid;
            tc05.actual = valid ? "100% phòng có đầy đủ thông tin tên hạng phòng" : tc05.errorDetail;
        } else {
            tc05.passed = false;
            tc05.actual = "Danh sách phòng rỗng";
        }
        results.add(tc05);

        // TC-3.1.06: Giá phòng không âm và hợp lệ
        TestCaseResult tc06 = new TestCaseResult("TC-3.1.06", "Kiểm tra đơn giá niêm yết của phòng",
                "Đảm bảo giá phòng từ LOAIPHONG phải lớn hơn 0",
                "giaPhong > 0 cho toàn bộ phòng");
        if (rooms != null && !rooms.isEmpty()) {
            boolean valid = true;
            for (RoomTimelineDTO r : rooms) {
                if (r.getGiaPhong() <= 0) {
                    valid = false;
                    tc06.errorDetail = "Phòng " + r.getMaPhong() + " có giá không hợp lệ: " + r.getGiaPhong();
                    break;
                }
            }
            tc06.passed = valid;
            tc06.actual = valid ? "100% phòng có đơn giá hợp lệ > 0" : tc06.errorDetail;
        } else {
            tc06.passed = false;
            tc06.actual = "Danh sách phòng rỗng";
        }
        results.add(tc06);

        // TC-3.1.07: Trạng thái phòng hợp lệ theo CHECK constraint của CSDL
        TestCaseResult tc07 = new TestCaseResult("TC-3.1.07", "Tính hợp lệ của trạng thái buồng phòng",
                "Kiểm tra trạng thái phòng phải nằm trong tập ('Available', 'Booked', 'Occupied', 'Dirty', 'Cleaning', 'Damaged')",
                "Tất cả phòng có trạng thái hợp lệ");
        Set<String> validStatuses = new HashSet<>(Arrays.asList("Available", "Booked", "Occupied", "Dirty", "Cleaning", "Damaged"));
        if (rooms != null && !rooms.isEmpty()) {
            boolean valid = true;
            for (RoomTimelineDTO r : rooms) {
                if (!validStatuses.contains(r.getTrangThaiPhong())) {
                    valid = false;
                    tc07.errorDetail = "Phòng " + r.getMaPhong() + " có trạng thái lạ: " + r.getTrangThaiPhong();
                    break;
                }
            }
            tc07.passed = valid;
            tc07.actual = valid ? "100% phòng có trạng thái chuẩn CSDL" : tc07.errorDetail;
        } else {
            tc07.passed = false;
            tc07.actual = "Danh sách phòng rỗng";
        }
        results.add(tc07);

        // TC-3.1.08: Text Badge & CSS cho trạng thái Available
        TestCaseResult tc08 = new TestCaseResult("TC-3.1.08", "Quy đổi Text Badge cho phòng Available",
                "Kiểm tra getTrangThaiBadgeText() và getTrangThaiCssClass() cho Available",
                "Badge: [Đã dọn], CSS: badge-clean");
        RoomTimelineDTO rAvail = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "Available", "");
        boolean p8 = "[Đã dọn]".equals(rAvail.getTrangThaiBadgeText()) && "badge-clean".equals(rAvail.getTrangThaiCssClass());
        tc08.passed = p8;
        tc08.actual = "Badge=" + rAvail.getTrangThaiBadgeText() + ", CSS=" + rAvail.getTrangThaiCssClass();
        results.add(tc08);

        // TC-3.1.09: Text Badge & CSS cho trạng thái Occupied
        TestCaseResult tc09 = new TestCaseResult("TC-3.1.09", "Quy đổi Text Badge cho phòng Occupied",
                "Kiểm tra getTrangThaiBadgeText() và getTrangThaiCssClass() cho Occupied",
                "Badge: [Đang có khách], CSS: badge-occupied");
        RoomTimelineDTO rOcc = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "Occupied", "");
        boolean p9 = "[Đang có khách]".equals(rOcc.getTrangThaiBadgeText()) && "badge-occupied".equals(rOcc.getTrangThaiCssClass());
        tc09.passed = p9;
        tc09.actual = "Badge=" + rOcc.getTrangThaiBadgeText() + ", CSS=" + rOcc.getTrangThaiCssClass();
        results.add(tc09);

        // TC-3.1.10: Text Badge & CSS cho trạng thái Dirty
        TestCaseResult tc10 = new TestCaseResult("TC-3.1.10", "Quy đổi Text Badge cho phòng Dirty",
                "Kiểm tra getTrangThaiBadgeText() và getTrangThaiCssClass() cho Dirty",
                "Badge: [Bẩn], CSS: badge-dirty");
        RoomTimelineDTO rDirty = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "Dirty", "");
        boolean p10 = "[Bẩn]".equals(rDirty.getTrangThaiBadgeText()) && "badge-dirty".equals(rDirty.getTrangThaiCssClass());
        tc10.passed = p10;
        tc10.actual = "Badge=" + rDirty.getTrangThaiBadgeText() + ", CSS=" + rDirty.getTrangThaiCssClass();
        results.add(tc10);

        // TC-3.1.11: Text Badge & CSS cho trạng thái Cleaning
        TestCaseResult tc11 = new TestCaseResult("TC-3.1.11", "Quy đổi Text Badge cho phòng Cleaning",
                "Kiểm tra getTrangThaiBadgeText() và getTrangThaiCssClass() cho Cleaning",
                "Badge: [Đang dọn], CSS: badge-cleaning");
        RoomTimelineDTO rClean = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "Cleaning", "");
        boolean p11 = "[Đang dọn]".equals(rClean.getTrangThaiBadgeText()) && "badge-cleaning".equals(rClean.getTrangThaiCssClass());
        tc11.passed = p11;
        tc11.actual = "Badge=" + rClean.getTrangThaiBadgeText() + ", CSS=" + rClean.getTrangThaiCssClass();
        results.add(tc11);

        // TC-3.1.12: Text Badge & CSS cho trạng thái Damaged
        TestCaseResult tc12 = new TestCaseResult("TC-3.1.12", "Quy đổi Text Badge cho phòng Damaged",
                "Kiểm tra getTrangThaiBadgeText() và getTrangThaiCssClass() cho Damaged",
                "Badge: [Bảo trì], CSS: badge-maintenance");
        RoomTimelineDTO rDmg = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "Damaged", "");
        boolean p12 = "[Bảo trì]".equals(rDmg.getTrangThaiBadgeText()) && "badge-maintenance".equals(rDmg.getTrangThaiCssClass());
        tc12.passed = p12;
        tc12.actual = "Badge=" + rDmg.getTrangThaiBadgeText() + ", CSS=" + rDmg.getTrangThaiCssClass();
        results.add(tc12);

        // TC-3.1.13: Text Badge & CSS cho trạng thái Booked
        TestCaseResult tc13 = new TestCaseResult("TC-3.1.13", "Quy đổi Text Badge cho phòng Booked",
                "Kiểm tra getTrangThaiBadgeText() và getTrangThaiCssClass() cho Booked",
                "Badge: [Đã giữ chỗ], CSS: badge-booked");
        RoomTimelineDTO rBooked = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "Booked", "");
        boolean p13 = "[Đã giữ chỗ]".equals(rBooked.getTrangThaiBadgeText()) && "badge-booked".equals(rBooked.getTrangThaiCssClass());
        tc13.passed = p13;
        tc13.actual = "Badge=" + rBooked.getTrangThaiBadgeText() + ", CSS=" + rBooked.getTrangThaiCssClass();
        results.add(tc13);

        // TC-3.1.14: Text Badge cho trạng thái ngoại lệ (Default Fallback)
        TestCaseResult tc14 = new TestCaseResult("TC-3.1.14", "Xử lý Text Badge cho trạng thái không xác định",
                "Kiểm tra fallback an toàn khi trạng thái phòng không nằm trong danh mục biết trước",
                "Badge: [CustomStatus], CSS: badge-secondary");
        RoomTimelineDTO rUnknown = new RoomTimelineDTO("P01", "101", 1, "LP01", "Single", 500000, "CustomStatus", "");
        boolean p14 = "[CustomStatus]".equals(rUnknown.getTrangThaiBadgeText()) && "badge-secondary".equals(rUnknown.getTrangThaiCssClass());
        tc14.passed = p14;
        tc14.actual = "Badge=" + rUnknown.getTrangThaiBadgeText() + ", CSS=" + rUnknown.getTrangThaiCssClass();
        results.add(tc14);

        // TC-3.1.15: Tổng số phòng trong KPI khớp tổng danh sách phòng
        TestCaseResult tc15 = new TestCaseResult("TC-3.1.15", "Đồng bộ Tổng số phòng giữa KPI và Danh sách phòng",
                "Đảm bảo kpi.tongSoPhong == rooms.size()",
                "kpi.getTongSoPhong() == rooms.size()");
        if (kpi != null && rooms != null) {
            boolean p15 = (kpi.getTongSoPhong() == rooms.size());
            tc15.passed = p15;
            tc15.actual = "KPI Tổng=" + kpi.getTongSoPhong() + ", Danh sách phòng=" + rooms.size();
        } else {
            tc15.passed = false;
            tc15.actual = "kpi hoặc rooms bị null";
        }
        results.add(tc15);

        // TC-3.1.16: Tổng phân loại trạng thái bằng tổng số phòng trong KPI
        TestCaseResult tc16 = new TestCaseResult("TC-3.1.16", "Tính bảo toàn tổng phòng trong KPI",
                "Đảm bảo sum(các phòng theo trạng thái) == tongSoPhong",
                "avail + occ + dirty + clean + dmg + booked == tongSoPhong");
        if (kpi != null) {
            int sum = kpi.getSoPhongAvailable() + kpi.getSoPhongOccupied() + kpi.getSoPhongDirty()
                    + kpi.getSoPhongCleaning() + kpi.getSoPhongDamaged() + kpi.getSoPhongBooked();
            boolean p16 = (sum == kpi.getTongSoPhong());
            tc16.passed = p16;
            tc16.actual = "Tổng chi tiết = " + sum + ", Tổng số phòng = " + kpi.getTongSoPhong();
        } else {
            tc16.passed = false;
            tc16.actual = "kpi bị null";
        }
        results.add(tc16);

        // TC-3.1.17: Đối soát chéo từng số liệu KPI với đếm thực tế trên danh sách phòng
        TestCaseResult tc17 = new TestCaseResult("TC-3.1.17", "Đối soát chéo số liệu KPI với đếm thực tế",
                "Đếm số lượng từng trạng thái trong rooms.list và đối chiếu với KPI query",
                "Từng chỉ số Available, Occupied, Dirty, Cleaning, Damaged, Booked phải trùng khớp 100%");
        if (kpi != null && rooms != null) {
            int cAvail = 0, cOcc = 0, cDirty = 0, cClean = 0, cDmg = 0, cBooked = 0;
            for (RoomTimelineDTO r : rooms) {
                switch (r.getTrangThaiPhong()) {
                    case "Available": cAvail++; break;
                    case "Occupied": cOcc++; break;
                    case "Dirty": cDirty++; break;
                    case "Cleaning": cClean++; break;
                    case "Damaged": cDmg++; break;
                    case "Booked": cBooked++; break;
                }
            }
            boolean p17 = (cAvail == kpi.getSoPhongAvailable())
                    && (cOcc == kpi.getSoPhongOccupied())
                    && (cDirty == kpi.getSoPhongDirty())
                    && (cClean == kpi.getSoPhongCleaning())
                    && (cDmg == kpi.getSoPhongDamaged())
                    && (cBooked == kpi.getSoPhongBooked());
            tc17.passed = p17;
            tc17.actual = String.format("Đếm: Avail=%d, Occ=%d, Dirty=%d, Clean=%d, Dmg=%d, Booked=%d | KPI: Avail=%d, Occ=%d, Dirty=%d, Clean=%d, Dmg=%d, Booked=%d",
                    cAvail, cOcc, cDirty, cClean, cDmg, cBooked,
                    kpi.getSoPhongAvailable(), kpi.getSoPhongOccupied(), kpi.getSoPhongDirty(),
                    kpi.getSoPhongCleaning(), kpi.getSoPhongDamaged(), kpi.getSoPhongBooked());
        } else {
            tc17.passed = false;
            tc17.actual = "Dữ liệu null";
        }
        results.add(tc17);

        // TC-3.1.18: Tính toán tỷ lệ lấp đầy phòng (Occupancy Rate)
        TestCaseResult tc18 = new TestCaseResult("TC-3.1.18", "Công thức và định dạng Tỷ lệ lấp đầy phòng",
                "Đảm bảo occupancyRate = (soPhongOccupied / tongSoPhong) * 100 và định dạng dạng 'xx.x%'",
                "occupancyRate chuẩn xác và format dạng 'xx.x%'");
        if (kpi != null && kpi.getTongSoPhong() > 0) {
            double expectedRate = ((double) kpi.getSoPhongOccupied() / kpi.getTongSoPhong()) * 100.0;
            String expectedFmt = String.format("%.1f%%", expectedRate);
            boolean p18 = Math.abs(kpi.getOccupancyRate() - expectedRate) < 0.001
                    && expectedFmt.equals(kpi.getFormattedOccupancyRate());
            tc18.passed = p18;
            tc18.actual = "Rate=" + kpi.getOccupancyRate() + ", Format=" + kpi.getFormattedOccupancyRate();
        } else {
            tc18.passed = false;
            tc18.actual = "kpi null hoặc tongSoPhong = 0";
        }
        results.add(tc18);

        // TC-3.1.19: Xử lý an toàn mẫu số bằng 0 (Zero Division) trong KPI
        TestCaseResult tc19 = new TestCaseResult("TC-3.1.19", "Xử lý an toàn khi tổng số phòng = 0 (Chia cho 0)",
                "Đảm bảo không bị NaN hoặc Infinity khi tongSoPhong = 0",
                "occupancyRate = 0.0, format = '0.0%'");
        RoomMapKpiDTO zeroKpi = new RoomMapKpiDTO(0, 0, 0, 0, 0, 0, 0);
        boolean p19 = (zeroKpi.getOccupancyRate() == 0.0) && "0.0%".equals(zeroKpi.getFormattedOccupancyRate())
                && !Double.isNaN(zeroKpi.getOccupancyRate()) && !Double.isInfinite(zeroKpi.getOccupancyRate());
        tc19.passed = p19;
        tc19.actual = "Zero KPI Rate=" + zeroKpi.getOccupancyRate() + ", Format=" + zeroKpi.getFormattedOccupancyRate();
        results.add(tc19);

        // TC-3.1.20: Kiểm tra tuân thủ UI 100% không dùng Icon font và Emoji trong room_map.jsp
        TestCaseResult tc20 = new TestCaseResult("TC-3.1.20", "Tuân thủ quy chuẩn UI: 0 Icon Font, 0 Emoji",
                "Quét file room_map.jsp đảm bảo không xuất hiện class icon (fa-, bi-, glyphicon) và không chứa ký tự Emoji",
                "0 Icon font, 0 Emoji");
        try {
            File jspFile = new File("src/main/webapp/views/receptionist/room_map.jsp");
            String jspContent = new String(Files.readAllBytes(jspFile.toPath()), "UTF-8");

            // Kiểm tra Emoji
            Pattern emojiPattern = Pattern.compile("[\ud83c\udc00-\ud83c\udfff]|[\ud83d\udc00-\ud83d\udfff]|[\ud83e\udc00-\ud83e\udfff]");
            Matcher emojiMatcher = emojiPattern.matcher(jspContent);
            int emojiCount = 0;
            while (emojiMatcher.find()) {
                emojiCount++;
            }

            // Kiểm tra icon fonts
            boolean hasFa = jspContent.contains("fa-");
            boolean hasBi = jspContent.contains("bi-");
            boolean hasGlyph = jspContent.contains("glyphicon");

            boolean p20 = (emojiCount == 0) && !hasFa && !hasBi && !hasGlyph;
            tc20.passed = p20;
            tc20.actual = String.format("Emoji count=%d, FontAwesome=%b, BootstrapIcons=%b", emojiCount, hasFa, hasBi);
            if (!p20) {
                tc20.errorDetail = "Phát hiện icon hoặc emoji trong giao diện!";
            }
        } catch (Exception e) {
            tc20.passed = false;
            tc20.actual = "Lỗi đọc file: " + e.getMessage();
        }
        results.add(tc20);

        // TỔNG KẾT & IN BẢNG BÁO CÁO
        int passCount = 0;
        int failCount = 0;
        System.out.println("\n--------------------------------------------------------------------------");
        System.out.printf("%-10s | %-45s | %-10s\n", "MÃ TC", "TÊN TEST CASE", "KẾT QUẢ");
        System.out.println("--------------------------------------------------------------------------");
        for (TestCaseResult res : results) {
            if (res.passed) passCount++; else failCount++;
            System.out.printf("%-10s | %-45s | %-10s\n", res.id, res.name, res.passed ? "[PASS]" : "[FAIL]");
        }
        System.out.println("--------------------------------------------------------------------------");
        System.out.printf("TỔNG KẾT: %d/20 TEST CASES ĐẠT (PASS: %d, FAIL: %d)\n", results.size(), passCount, failCount);
        System.out.println("--------------------------------------------------------------------------");

        if (failCount > 0) {
            System.out.println("\n=== DANH SÁCH TEST CASE BỊ LỖI ===");
            for (TestCaseResult res : results) {
                if (!res.passed) {
                    System.out.println("[-] " + res.id + ": " + res.name);
                    System.out.println("    Kỳ vọng : " + res.expected);
                    System.out.println("    Thực tế : " + res.actual);
                    System.out.println("    Chi tiết: " + res.errorDetail);
                }
            }
        }
    }
}
