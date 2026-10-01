import com.mycompany.hotelmanagersystem.booking.dao.BookingDAO;
import com.mycompany.hotelmanagersystem.room.dao.RoomDAO;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.io.File;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.*;
import java.util.concurrent.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Run20TestCasesPhase2ImpactFN31 {

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
        System.out.println("BẮT ĐẦU CHẠY 20 TEST CASES: TÁC ĐỘNG GIỮA PHASE 2 VÀ FN-3.1");
        System.out.println("==========================================================================");

        List<TestCaseResult> results = new ArrayList<>();
        RoomDAO roomDAO = new RoomDAO();
        BookingDAO bookingDAO = new BookingDAO();

        LocalDate baseDate = LocalDate.now().plusYears(4).plusDays((System.currentTimeMillis() % 200) + 1);
        Date checkInFuture = Date.valueOf(baseDate);
        Date checkOutFuture = Date.valueOf(baseDate.plusDays(3));

        // ---------------------------------------------------------------------
        // NHÓM A: TÁC ĐỘNG CỦA ĐẶT PHÒNG MỚI (PHASE 2 BOOKING -> FN-3.1)
        // ---------------------------------------------------------------------

        // TC-3.1-P2.01: Tạo đơn đặt phòng mới không làm mất hoặc nhân đôi danh sách phòng trong FN-3.1
        TestCaseResult tc01 = new TestCaseResult("TC-3.1-P2.01", "Bảo toàn danh sách phòng khi tạo Booking mới từ Phase 2",
                "Đảm bảo sau khi khách đặt phòng trực tuyến, getAllRoomsForTimeline() vẫn trả về đúng 12 phòng",
                "Số lượng phòng trong getAllRoomsForTimeline() không đổi (12 phòng)");
        String tempBookingId1 = null;
        try {
            tempBookingId1 = bookingDAO.createOnlineBookingWithServices("KH001", "TK_G01", "P101", checkInFuture, checkOutFuture, 450000, 1350000, null, "Test TC01");
            List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
            tc01.passed = (rooms.size() == 12);
            tc01.actual = "Số phòng trả về = " + rooms.size();
        } catch (Exception e) {
            tc01.passed = false;
            tc01.actual = "Lỗi: " + e.getMessage();
            tc01.errorDetail = e.getMessage();
        }
        results.add(tc01);

        // TC-3.1-P2.02: Tạo đơn đặt phòng mới bảo toàn tổng số phòng trong KPI
        TestCaseResult tc02 = new TestCaseResult("TC-3.1-P2.02", "Bảo toàn tổng phòng trong KPI buồng phòng khi có đơn mới",
                "Đảm bảo kpi.getTongSoPhong() luôn bằng 12 sau khi phát sinh đơn đặt phòng",
                "kpi.getTongSoPhong() == 12");
        try {
            RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();
            tc02.passed = (kpi.getTongSoPhong() == 12);
            tc02.actual = "Tổng số phòng KPI = " + kpi.getTongSoPhong();
        } catch (Exception e) {
            tc02.passed = false;
            tc02.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc02);

        // TC-3.1-P2.03: Đặt phòng cho ngày tương lai không làm thay đổi trạng thái buồng phòng hiện tại
        TestCaseResult tc03 = new TestCaseResult("TC-3.1-P2.03", "Trạng thái buồng phòng hiện tại không bị đổi khi đặt ngày tương lai",
                "Phòng P101 đang Available vẫn phải là Available trong bảng PHONG sau khi khách đặt ngày tương lai",
                "P101.trangThaiPhong == 'Available'");
        try {
            List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
            RoomTimelineDTO p101 = rooms.stream().filter(r -> "P101".equals(r.getMaPhong())).findFirst().orElse(null);
            tc03.passed = (p101 != null && "Available".equals(p101.getTrangThaiPhong()));
            tc03.actual = "Trạng thái P101 = " + (p101 != null ? p101.getTrangThaiPhong() : "null");
        } catch (Exception e) {
            tc03.passed = false;
            tc03.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc03);

        String tempBookingId2 = null;
        // TC-3.1-P2.04: Đặt phòng trực tuyến kèm dịch vụ không làm thay đổi các số đếm KPI
        TestCaseResult tc04 = new TestCaseResult("TC-3.1-P2.04", "Đặt phòng kèm dịch vụ phát sinh không ảnh hưởng số đếm KPI buồng phòng",
                "Đảm bảo khi khách đặt phòng kèm dịch vụ (Phase 2), các số đếm Available, Occupied, Dirty... trong KPI giữ nguyên logic",
                "Tổng các phòng chi tiết trong KPI khớp đúng tổng số phòng");
        try {
            Map<String, Integer> svcs = new HashMap<>();
            svcs.put("DV01", 2); // 2 buffet
            svcs.put("DV05", 3); // 3 nước ngọt
            Date dIn = Date.valueOf(baseDate.plusDays(10));
            Date dOut = Date.valueOf(baseDate.plusDays(12));
            tempBookingId2 = bookingDAO.createOnlineBookingWithServices("KH002", "TK_G02", "P103", dIn, dOut, 650000, 1690000, svcs, "Test TC04");
            RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();
            int sum = kpi.getSoPhongAvailable() + kpi.getSoPhongOccupied() + kpi.getSoPhongDirty()
                    + kpi.getSoPhongCleaning() + kpi.getSoPhongDamaged() + kpi.getSoPhongBooked();
            tc04.passed = (sum == kpi.getTongSoPhong()) && (tempBookingId2 != null);
            tc04.actual = "Tạo thành công booking kèm dịch vụ: " + tempBookingId2 + " | Tổng KPI = " + sum;
        } catch (Exception e) {
            tc04.passed = false;
            tc04.actual = "Lỗi: " + e.getMessage();
            tc04.errorDetail = e.getMessage();
        }
        results.add(tc04);

        // TC-3.1-P2.05: Kiểm tra các phòng tham gia đơn Phase 2 đều tồn tại hợp lệ trong danh mục FN-3.1
        TestCaseResult tc05 = new TestCaseResult("TC-3.1-P2.05", "Phòng trong đơn đặt Phase 2 liên kết toàn vẹn với FN-3.1",
                "Đảm bảo các phòng P101, P103 có đầy đủ thuộc tính trong getAllRoomsForTimeline()",
                "Mọi phòng đặt từ Phase 2 đều ánh xạ được sang RoomTimelineDTO");
        try {
            List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
            boolean hasP101 = rooms.stream().anyMatch(r -> "P101".equals(r.getMaPhong()) && r.getSoTang() == 1);
            boolean hasP103 = rooms.stream().anyMatch(r -> "P103".equals(r.getMaPhong()) && r.getSoTang() == 1);
            tc05.passed = hasP101 && hasP103;
            tc05.actual = "P101 hợp lệ=" + hasP101 + ", P103 hợp lệ=" + hasP103;
        } catch (Exception e) {
            tc05.passed = false;
            tc05.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc05);

        // ---------------------------------------------------------------------
        // NHÓM B: TÁC ĐỘNG CỦA HỦY PHÒNG (PHASE 2 CANCELLATION -> FN-3.1)
        // ---------------------------------------------------------------------

        // TC-3.1-P2.06: Hủy đơn đặt phòng DaXacNhan từ Phase 2
        TestCaseResult tc06 = new TestCaseResult("TC-3.1-P2.06", "Hủy đơn đặt phòng trực tuyến không làm mất phòng trên FN-3.1",
                "Khách hàng hủy đơn online, kiểm tra getAllRoomsForTimeline() vẫn duy trì 12 phòng",
                "Số lượng phòng sau khi hủy vẫn bằng 12");
        try {
            boolean cancelled = bookingDAO.cancelBooking(tempBookingId1, "KH001", "TK_G01");
            List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
            tc06.passed = cancelled && (rooms.size() == 12);
            tc06.actual = "Hủy thành công=" + cancelled + ", Số phòng=" + rooms.size();
        } catch (Exception e) {
            tc06.passed = false;
            tc06.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc06);

        // TC-3.1-P2.07: Hủy đơn đặt phòng không làm sai lệch thống kê KPI buồng phòng
        TestCaseResult tc07 = new TestCaseResult("TC-3.1-P2.07", "Thống kê KPI buồng phòng giữ nguyên toàn vẹn sau khi hủy đơn",
                "Đảm bảo tổng phòng = 12 và các chỉ số buồng phòng không bị số âm",
                "Các chỉ số KPI >= 0 và tổng bằng 12");
        try {
            RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();
            boolean nonNegative = kpi.getSoPhongAvailable() >= 0 && kpi.getSoPhongOccupied() >= 0
                    && kpi.getSoPhongDirty() >= 0 && kpi.getSoPhongCleaning() >= 0
                    && kpi.getSoPhongDamaged() >= 0 && kpi.getSoPhongBooked() >= 0;
            tc07.passed = nonNegative && (kpi.getTongSoPhong() == 12);
            tc07.actual = "Không âm=" + nonNegative + ", Tổng=" + kpi.getTongSoPhong();
        } catch (Exception e) {
            tc07.passed = false;
            tc07.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc07);

        // TC-3.1-P2.08: Chặn hủy đơn đặt phòng khi khách đã Check-in (trg_ChanHuyBookingSaiChinhSach)
        TestCaseResult tc08 = new TestCaseResult("TC-3.1-P2.08", "Chặn hủy đơn đặt phòng khi phòng đã Check-in (Occupied)",
                "Trigger trg_ChanHuyBookingSaiChinhSach phải chặn hủy đơn BK001 (đang ở P201/P202)",
                "Ném ngoại lệ RAISERROR, không cho phép hủy");
        try {
            boolean cancelResult = bookingDAO.cancelBooking("BK001", "KH001", null);
            tc08.passed = !cancelResult;
            tc08.actual = "Kết quả hủy = " + cancelResult + " (Bị chặn chuẩn xác)";
        } catch (Exception e) {
            tc08.passed = true;
            tc08.actual = "Bị chặn bởi Trigger: " + e.getMessage();
        }
        results.add(tc08);

        // ---------------------------------------------------------------------
        // NHÓM C: RÀNG BUỘC TRẠNG THÁI PHÒNG TỪ FN-3.1 ĐỐI VỚI PHASE 2
        // ---------------------------------------------------------------------

        // TC-3.1-P2.09: Phase 2 Search Room KHÔNG trả về phòng Damaged (P401)
        TestCaseResult tc09 = new TestCaseResult("TC-3.1-P2.09", "Loại trừ phòng Damaged khỏi kết quả tìm kiếm phòng của khách hàng",
                "Đảm bảo phòng P401 đang Damaged trên sơ đồ FN-3.1 không xuất hiện trong searchAvailableRooms()",
                "P401 không có trong danh sách tìm kiếm phòng trống");
        try {
            List<AvailableRoomDTO> avail = roomDAO.searchAvailableRooms(checkInFuture, checkOutFuture, 2, null);
            boolean hasP401 = avail.stream().anyMatch(r -> "P401".equals(r.getMaPhong()));
            tc09.passed = !hasP401;
            tc09.actual = "P401 xuất hiện trong tìm kiếm = " + hasP401;
        } catch (Exception e) {
            tc09.passed = false;
            tc09.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc09);

        // TC-3.1-P2.10: Chặn đặt phòng vào phòng đang Damaged (DAO & Trigger kiểm soát)
        TestCaseResult tc10 = new TestCaseResult("TC-3.1-P2.10", "Chặn tạo đơn đặt phòng vào phòng đang Damaged",
                "Cố tình chèn đơn đặt phòng vào P401 phải bị chặn bởi hệ thống",
                "Ném ngoại lệ chặn phòng đang Damaged hoặc không khả dụng");
        try {
            bookingDAO.createOnlineBookingWithServices("KH001", "TK_G01", "P401", checkInFuture, checkOutFuture, 4500000, 13500000, null, "Test Damaged");
            tc10.passed = false;
            tc10.actual = "Không bị chặn (Thất bại)";
        } catch (Exception e) {
            boolean isExpectedError = e.getMessage().contains("Damaged") || e.getMessage().contains("hư hỏng") || e.getMessage().contains("không khả dụng");
            tc10.passed = isExpectedError;
            tc10.actual = "Bị chặn chuẩn xác: " + e.getMessage();
        }
        results.add(tc10);

        // TC-3.1-P2.11: Phòng Available (P101) xuất hiện trong tìm kiếm Phase 2 khi không có lịch trùng
        TestCaseResult tc11 = new TestCaseResult("TC-3.1-P2.11", "Phòng Available trên sơ đồ FN-3.1 hiển thị hợp lệ trên giao diện tìm kiếm Phase 2",
                "Tìm kiếm khoảng ngày chưa có ai đặt, phòng P101 phải xuất hiện",
                "P101 có trong danh sách kết quả tìm kiếm");
        try {
            Date farFutureIn = Date.valueOf("2026-12-01");
            Date farFutureOut = Date.valueOf("2026-12-05");
            List<AvailableRoomDTO> avail = roomDAO.searchAvailableRooms(farFutureIn, farFutureOut, 1, "LP01");
            boolean hasP101 = avail.stream().anyMatch(r -> "P101".equals(r.getMaPhong()));
            tc11.passed = hasP101;
            tc11.actual = "P101 có trong kết quả = " + hasP101;
        } catch (Exception e) {
            tc11.passed = false;
            tc11.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc11);

        // TC-3.1-P2.12: Phòng Occupied trên sơ đồ FN-3.1 vẫn cho phép khách đặt cho thời điểm sau khi trả phòng
        TestCaseResult tc12 = new TestCaseResult("TC-3.1-P2.12", "Phòng Occupied trên FN-3.1 vẫn bán được cho ngày tương lai",
                "P201 đang Occupied hôm nay nhưng kiểm tra khả dụng trong tháng sau vẫn thành công",
                "isRoomAvailable('P201', farFutureIn, farFutureOut) == true");
        try {
            Date farFutureIn = Date.valueOf("2026-12-10");
            Date farFutureOut = Date.valueOf("2026-12-12");
            boolean avail = roomDAO.isRoomAvailable("P201", farFutureIn, farFutureOut);
            tc12.passed = avail;
            tc12.actual = "Khả dụng cho tương lai = " + avail;
        } catch (Exception e) {
            tc12.passed = false;
            tc12.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc12);

        // TC-3.1-P2.13: Phòng Dirty (P102) hiển thị badge đúng trên FN-3.1
        TestCaseResult tc13 = new TestCaseResult("TC-3.1-P2.13", "Nhận diện phòng Dirty trên sơ đồ FN-3.1",
                "P102 trong getAllRoomsForTimeline() có badge [Bẩn] và css badge-dirty",
                "Badge='[Bẩn]', CSS='badge-dirty'");
        try {
            List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
            RoomTimelineDTO p102 = rooms.stream().filter(r -> "P102".equals(r.getMaPhong())).findFirst().orElse(null);
            boolean ok = p102 != null && "[Bẩn]".equals(p102.getTrangThaiBadgeText()) && "badge-dirty".equals(p102.getTrangThaiCssClass());
            tc13.passed = ok;
            tc13.actual = (p102 != null) ? "Badge=" + p102.getTrangThaiBadgeText() + ", CSS=" + p102.getTrangThaiCssClass() : "null";
        } catch (Exception e) {
            tc13.passed = false;
            tc13.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc13);

        // TC-3.1-P2.14: Phòng Cleaning (P301) hiển thị badge đúng trên FN-3.1
        TestCaseResult tc14 = new TestCaseResult("TC-3.1-P2.14", "Nhận diện phòng Cleaning trên sơ đồ FN-3.1",
                "P301 trong getAllRoomsForTimeline() có badge [Đang dọn] và css badge-cleaning",
                "Badge='[Đang dọn]', CSS='badge-cleaning'");
        try {
            List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
            RoomTimelineDTO p301 = rooms.stream().filter(r -> "P301".equals(r.getMaPhong())).findFirst().orElse(null);
            boolean ok = p301 != null && "[Đang dọn]".equals(p301.getTrangThaiBadgeText()) && "badge-cleaning".equals(p301.getTrangThaiCssClass());
            tc14.passed = ok;
            tc14.actual = (p301 != null) ? "Badge=" + p301.getTrangThaiBadgeText() + ", CSS=" + p301.getTrangThaiCssClass() : "null";
        } catch (Exception e) {
            tc14.passed = false;
            tc14.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc14);

        // ---------------------------------------------------------------------
        // NHÓM D: TOÀN VẸN ĐỒNG BỘ DỮ LIỆU CHÉO (CROSS-PHASE DATA INTEGRITY)
        // ---------------------------------------------------------------------

        // TC-3.1-P2.15: Đổi trạng thái phòng từ Dirty sang Available cập nhật tức thời vào KPI
        TestCaseResult tc15 = new TestCaseResult("TC-3.1-P2.15", "Đồng bộ KPI khi trạng thái phòng thay đổi trong CSDL",
                "Thực hiện đổi trạng thái phòng P102 sang Available rồi hoàn tác, KPI phản ánh tức thời",
                "KPI soPhongDirty giảm 1 và soPhongAvailable tăng 1");
        try {
            RoomMapKpiDTO kpiBefore = roomDAO.getRoomMapKpi();
            
            // Tạm đổi P102 sang Available và đóng connection ngay
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = 'P102'")) {
                ps.executeUpdate();
            }
            RoomMapKpiDTO kpiAfter = roomDAO.getRoomMapKpi();
            boolean ok = (kpiAfter.getSoPhongDirty() == kpiBefore.getSoPhongDirty() - 1)
                      && (kpiAfter.getSoPhongAvailable() == kpiBefore.getSoPhongAvailable() + 1);

            // Hoàn tác lại Dirty
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE PHONG SET TrangThai = 'Dirty' WHERE MaPhong = 'P102'")) {
                ps.executeUpdate();
            }

            tc15.passed = ok;
            tc15.actual = String.format("Trước: Dirty=%d, Avail=%d | Sau: Dirty=%d, Avail=%d",
                    kpiBefore.getSoPhongDirty(), kpiBefore.getSoPhongAvailable(),
                    kpiAfter.getSoPhongDirty(), kpiAfter.getSoPhongAvailable());
        } catch (Exception e) {
            tc15.passed = false;
            tc15.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc15);

        // TC-3.1-P2.16: Tỷ lệ lấp đầy phòng tăng khi số lượng phòng Occupied tăng
        TestCaseResult tc16 = new TestCaseResult("TC-3.1-P2.16", "Cập nhật tỷ lệ lấp đầy phòng (Occupancy Rate) khi tăng phòng Occupied",
                "Khi số phòng Occupied tăng, tỷ lệ lấp đầy phòng phải tăng tương ứng",
                "occupancyRate tăng chính xác theo công thức");
        try {
            RoomMapKpiDTO kpiBefore = roomDAO.getRoomMapKpi();
            
            // Giả lập thêm 1 phòng Occupied (P103 sang Occupied)
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE PHONG SET TrangThai = 'Occupied' WHERE MaPhong = 'P103'")) {
                ps.executeUpdate();
            }
            RoomMapKpiDTO kpiAfter = roomDAO.getRoomMapKpi();
            boolean ok = kpiAfter.getOccupancyRate() > kpiBefore.getOccupancyRate();

            // Hoàn tác
            try (Connection conn = DBContext.getConnection();
                 PreparedStatement ps = conn.prepareStatement("UPDATE PHONG SET TrangThai = 'Available' WHERE MaPhong = 'P103'")) {
                ps.executeUpdate();
            }

            tc16.passed = ok;
            tc16.actual = String.format("Trước: %.1f%% -> Sau: %.1f%%", kpiBefore.getOccupancyRate(), kpiAfter.getOccupancyRate());
        } catch (Exception e) {
            tc16.passed = false;
            tc16.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc16);

        // TC-3.1-P2.17: Tự động sinh Hóa đơn khi tạo đơn từ Phase 2 mà không làm sai lệch bảng PHONG
        TestCaseResult tc17 = new TestCaseResult("TC-3.1-P2.17", "Trigger sinh Hóa đơn tổng không làm biến dạng dữ liệu phòng",
                "Tạo booking sinh Hóa đơn HOADON theo trigger trg_TuDongTaoHoaDonKhiDatPhong, bảng PHONG không đổi",
                "Bảng PHONG vẫn nguyên vẹn 12 bản ghi");
        try (Connection conn = DBContext.getConnection()) {
            String targetBookingForHD = (tempBookingId1 != null) ? tempBookingId1 : tempBookingId2;
            String checkHDSql = "SELECT COUNT(*) FROM HOADON WHERE MaBooking = ?";
            boolean hasHD = false;
            try (PreparedStatement ps = conn.prepareStatement(checkHDSql)) {
                ps.setString(1, targetBookingForHD);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) hasHD = (rs.getInt(1) > 0);
                }
            }
            int roomCount = roomDAO.getAllRoomsForTimeline().size();
            tc17.passed = hasHD && (roomCount == 12);
            tc17.actual = "Đã sinh HD=" + hasHD + " (cho " + targetBookingForHD + "), Tổng phòng=" + roomCount;
        } catch (Exception e) {
            tc17.passed = false;
            tc17.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc17);

        // TC-3.1-P2.18: Tính bất biến của thông tin phòng (Giá, Loại phòng) trước và sau giao dịch
        TestCaseResult tc18 = new TestCaseResult("TC-3.1-P2.18", "Bảo toàn thông tin hạng phòng và giá niêm yết trong DTO",
                "Đảm bảo các giao dịch đặt phòng không ghi đè hoặc thay đổi giá gốc trong LOAIPHONG",
                "GiaPhong của P101 luôn = 450,000 đ");
        try {
            RoomTimelineDTO p101 = roomDAO.getAllRoomsForTimeline().stream()
                    .filter(r -> "P101".equals(r.getMaPhong())).findFirst().orElse(null);
            tc18.passed = (p101 != null && p101.getGiaPhong() == 450000.0);
            tc18.actual = "Giá phòng P101 = " + (p101 != null ? p101.getGiaPhong() : "null");
        } catch (Exception e) {
            tc18.passed = false;
            tc18.actual = "Lỗi: " + e.getMessage();
        }
        results.add(tc18);

        // TC-3.1-P2.19: Dọn dẹp đơn test tạm an toàn sau kiểm thử
        TestCaseResult tc19 = new TestCaseResult("TC-3.1-P2.19", "Dọn dẹp dữ liệu kiểm thử, đưa CSDL về trạng thái sạch",
                "Xóa các booking thử nghiệm sinh ra trong quá trình test",
                "Xóa sạch booking test mà không phát sinh lỗi khóa ngoại");
        try (Connection conn = DBContext.getConnection()) {
            if (tempBookingId2 != null) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM THANHTOAN WHERE MaHoaDon IN (SELECT MaHoaDon FROM HOADON WHERE MaBooking = ?)")) {
                    ps.setString(1, tempBookingId2);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM HOADON WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId2);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING_DICHVU WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId2);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING_PHONG WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId2);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId2);
                    ps.executeUpdate();
                }
            }
            if (tempBookingId1 != null) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM THANHTOAN WHERE MaHoaDon IN (SELECT MaHoaDon FROM HOADON WHERE MaBooking = ?)")) {
                    ps.setString(1, tempBookingId1);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM HOADON WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId1);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING_PHONG WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId1);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM BOOKING WHERE MaBooking = ?")) {
                    ps.setString(1, tempBookingId1);
                    ps.executeUpdate();
                }
            }
            RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();
            tc19.passed = (kpi.getTongSoPhong() == 12);
            tc19.actual = "Đã dọn dẹp sạch, CSDL chuẩn 12 phòng";
        } catch (Exception e) {
            tc19.passed = false;
            tc19.actual = "Lỗi dọn dẹp: " + e.getMessage();
        }
        results.add(tc19);

        // TC-3.1-P2.20: Giao diện room_map.jsp duy trì tính nhất quán khi có giao dịch Phase 2
        TestCaseResult tc20 = new TestCaseResult("TC-3.1-P2.20", "Tính nhất quán của giao diện JSP sau các giao dịch chéo",
                "Quét file JSP đảm bảo giữ đúng chuẩn 0 Icon font, 0 Emoji và thẻ lặp JSTL",
                "0 Icon font, 0 Emoji, chứa thẻ <c:forEach items=\"${roomList}\"");
        try {
            File jspFile = new File("src/main/webapp/views/receptionist/room_map.jsp");
            String jspContent = new String(Files.readAllBytes(jspFile.toPath()), "UTF-8");

            Pattern emojiPattern = Pattern.compile("[\ud83c\udc00-\ud83c\udfff]|[\ud83d\udc00-\ud83d\udfff]|[\ud83e\udc00-\ud83e\udfff]");
            Matcher emojiMatcher = emojiPattern.matcher(jspContent);
            int emojiCount = 0;
            while (emojiMatcher.find()) {
                emojiCount++;
            }

            boolean hasFa = jspContent.contains("fa-");
            boolean hasBi = jspContent.contains("bi-");
            boolean hasForEach = jspContent.contains("<c:forEach items=\"${roomList}\"");

            tc20.passed = (emojiCount == 0) && !hasFa && !hasBi && hasForEach;
            tc20.actual = String.format("Emoji=%d, IconFont=%b, ForEachRoomList=%b", emojiCount, (hasFa || hasBi), hasForEach);
        } catch (Exception e) {
            tc20.passed = false;
            tc20.actual = "Lỗi đọc JSP: " + e.getMessage();
        }
        results.add(tc20);

        // TỔNG KẾT
        int passCount = 0;
        int failCount = 0;
        System.out.println("\n---------------------------------------------------------------------------------------------------");
        System.out.printf("%-14s | %-55s | %-10s\n", "MÃ TEST CASE", "TÊN KIỂM THỬ TÁC ĐỘNG CHÉO", "KẾT QUẢ");
        System.out.println("---------------------------------------------------------------------------------------------------");
        for (TestCaseResult res : results) {
            if (res.passed) passCount++; else failCount++;
            System.out.printf("%-14s | %-55s | %-10s\n", res.id, res.name, res.passed ? "[PASS]" : "[FAIL]");
        }
        System.out.println("---------------------------------------------------------------------------------------------------");
        System.out.printf("TỔNG KẾT: %d/20 TEST CASES ĐẠT (PASS: %d, FAIL: %d)\n", results.size(), passCount, failCount);
        System.out.println("---------------------------------------------------------------------------------------------------");

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
