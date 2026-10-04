package com.mycompany.hotelmanagersystem.hotelservice.service;

import com.mycompany.hotelmanagersystem.hotelservice.dao.RoomServiceOrderDAO;
import com.mycompany.hotelmanagersystem.hotelservice.dao.ServiceDAO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.RoomServiceUsageDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderRequestDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderResultDTO;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;

import java.util.Collections;
import java.util.List;

/**
 * Service điều phối nghiệp vụ gọi thêm dịch vụ tại phòng cho khách đang lưu trú (FN-3.4 & FN-3.5).
 * Tuân thủ QT 3.2: Không chứa Servlet API, không chứa JDBC.
 */
public class RoomServiceOrderService {

    private final RoomServiceOrderDAO roomServiceOrderDAO;
    private final ServiceDAO serviceDAO;

    public RoomServiceOrderService() {
        this.roomServiceOrderDAO = new RoomServiceOrderDAO();
        this.serviceDAO = new ServiceDAO();
    }

    public RoomServiceOrderService(RoomServiceOrderDAO roomServiceOrderDAO, ServiceDAO serviceDAO) {
        this.roomServiceOrderDAO = roomServiceOrderDAO;
        this.serviceDAO = serviceDAO;
    }

    /**
     * Thực hiện kiểm tra nghiệp vụ và ghi nhận gọi dịch vụ vào đơn đặt phòng.
     */
    public ServiceOrderResultDTO orderService(ServiceOrderRequestDTO req) {
        if (req == null) {
            return ServiceOrderResultDTO.failure("Yêu cầu gọi dịch vụ không hợp lệ (dữ liệu trống)!");
        }

        if (req.getMaBooking() == null || req.getMaBooking().trim().isEmpty()) {
            return ServiceOrderResultDTO.failure("Mã đơn đặt phòng không được để trống!");
        }

        if (req.getMaDichVu() == null || req.getMaDichVu().trim().isEmpty()) {
            return ServiceOrderResultDTO.failure("Vui lòng chọn dịch vụ cần thêm!");
        }

        if (req.getSoLuong() <= 0) {
            return ServiceOrderResultDTO.failure("Số lượng dịch vụ phải lớn hơn 0!");
        }

        ServiceItem serviceItem = serviceDAO.getServiceById(req.getMaDichVu().trim());
        if (serviceItem == null || !"ApDung".equalsIgnoreCase(serviceItem.getTrangThai())) {
            return ServiceOrderResultDTO.failure("Dịch vụ không tồn tại hoặc đã tạm ngưng cung cấp!");
        }

        return roomServiceOrderDAO.executeOrderService(req);
    }

    /**
     * Lấy danh sách dịch vụ đã sử dụng của phòng trong đợt lưu trú.
     */
    public List<RoomServiceUsageDTO> getServicesUsed(String maBooking, String maPhong) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return Collections.emptyList();
        }
        return roomServiceOrderDAO.getServicesUsedByBooking(maBooking.trim(), maPhong);
    }

    /**
     * Lấy mã Booking đang lưu trú (DaCheckIn) của một phòng cụ thể.
     */
    public String getActiveBookingByRoom(String maPhong) {
        if (maPhong == null || maPhong.trim().isEmpty()) {
            return null;
        }
        return roomServiceOrderDAO.findActiveBookingByRoom(maPhong.trim());
    }

    /**
     * Tính tổng chi phí từ danh sách dịch vụ đã sử dụng.
     */
    public double calculateTotalServicesCost(List<RoomServiceUsageDTO> list) {
        if (list == null || list.isEmpty()) {
            return 0.0;
        }
        double total = 0.0;
        for (RoomServiceUsageDTO item : list) {
            total += item.getThanhTien();
        }
        return total;
    }
}
