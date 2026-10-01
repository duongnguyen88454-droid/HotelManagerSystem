import com.mycompany.hotelmanagersystem.room.dao.RoomDAO;
import com.mycompany.hotelmanagersystem.room.dto.RoomMapKpiDTO;
import com.mycompany.hotelmanagersystem.room.dto.RoomTimelineDTO;

import java.util.List;

public class TestFN31 {
    public static void main(String[] args) {
        System.out.println("=================================================================");
        System.out.println("KIỂM THỬ ĐỘC LẬP BƯỚC 1 (FN-3.1): TẢI PHÒNG THỰC TẾ & KPI BUỒNG");
        System.out.println("=================================================================");

        RoomDAO roomDAO = new RoomDAO();

        // 1. Kiểm tra tải danh sách phòng thực tế
        System.out.println("\n--- 1. KIỂM TRA TẢI DANH SÁCH PHÒNG THEO TẦNG ---");
        List<RoomTimelineDTO> rooms = roomDAO.getAllRoomsForTimeline();
        System.out.println("-> Tổng số phòng truy vấn được từ CSDL: " + rooms.size());

        if (rooms.isEmpty()) {
            System.err.println("[FAIL] Không tìm thấy phòng nào trong CSDL!");
            System.exit(1);
        }

        int prevFloor = 0;
        for (RoomTimelineDTO r : rooms) {
            if (r.getSoTang() != prevFloor) {
                prevFloor = r.getSoTang();
                System.out.println("\n  [+] KHU VỰC TẦNG " + prevFloor + ":");
            }
            System.out.printf("      - Phòng: %-5s | Hạng: %-18s | Giá: %,10.0f đ | Trạng thái: %-10s | Badge: %-15s | CSS: %s\n",
                    r.getSoPhong(), r.getTenLoaiPhong(), r.getGiaPhong(), r.getTrangThaiPhong(),
                    r.getTrangThaiBadgeText(), r.getTrangThaiCssClass());
        }

        // 2. Kiểm tra tính toán KPI buồng phòng thời gian thực
        System.out.println("\n--- 2. KIỂM TRA CHỈ SỐ KPI BUỒNG PHÒNG THỜI GIAN THỰC ---");
        RoomMapKpiDTO kpi = roomDAO.getRoomMapKpi();
        System.out.println("-> Tổng số phòng     : " + kpi.getTongSoPhong());
        System.out.println("-> Phòng [Đã dọn]    : " + kpi.getSoPhongAvailable());
        System.out.println("-> Phòng [Đang ở]    : " + kpi.getSoPhongOccupied());
        System.out.println("-> Phòng [Bẩn]       : " + kpi.getSoPhongDirty());
        System.out.println("-> Phòng [Đang dọn]  : " + kpi.getSoPhongCleaning());
        System.out.println("-> Phòng [Bảo trì]   : " + kpi.getSoPhongDamaged());
        System.out.println("-> Phòng [Đã giữ]    : " + kpi.getSoPhongBooked());
        System.out.println("-> Tỷ lệ lấp đầy     : " + kpi.getFormattedOccupancyRate());

        // Assertions
        boolean passRooms = (rooms.size() == 12);
        boolean passKpiTotal = (kpi.getTongSoPhong() == 12);
        boolean passSum = (kpi.getSoPhongAvailable() + kpi.getSoPhongOccupied() + kpi.getSoPhongDirty() +
                           kpi.getSoPhongCleaning() + kpi.getSoPhongDamaged() + kpi.getSoPhongBooked()) == kpi.getTongSoPhong();

        System.out.println("\n--- 3. ĐỐI SOÁT TÍNH TOÀN VẸN LOGIC ---");
        System.out.println("-> Khớp số lượng 12 phòng thực tế: " + (passRooms ? "PASS" : "FAIL"));
        System.out.println("-> Tổng KPI khớp tổng phòng      : " + (passKpiTotal ? "PASS" : "FAIL"));
        System.out.println("-> Tổng chi tiết các trạng thái  : " + (passSum ? "PASS (100% Khớp)" : "FAIL"));

        if (passRooms && passKpiTotal && passSum) {
            System.out.println("\n>>> KẾT QUẢ NGHIỆM THU FN-3.1: 100% PASS <<<");
        } else {
            System.err.println("\n>>> KẾT QUẢ NGHIỆM THU FN-3.1: FAIL <<<");
            System.exit(1);
        }
    }
}
