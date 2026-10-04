package com.mycompany.hotelmanagersystem.hotelservice.service;

import com.mycompany.hotelmanagersystem.hotelservice.dao.ServiceDAO;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;

import java.util.List;

/**
 * Service chuyên trách quản lý danh mục dịch vụ tiện ích bổ trợ khách sạn (DICHVU)
 * Đảm bảo nguyên lý phân tầng và độc lập nghiệp vụ giữa các domain
 */
public class HotelServiceService {

    private final ServiceDAO serviceDAO;

    public HotelServiceService() {
        this.serviceDAO = new ServiceDAO();
    }

    public HotelServiceService(ServiceDAO serviceDAO) {
        this.serviceDAO = serviceDAO;
    }

    /**
     * Lấy toàn bộ danh sách dịch vụ đang được áp dụng kinh doanh
     */
    public List<ServiceItem> getAllActiveServices() {
        return serviceDAO.getAllActiveServices();
    }

    /**
     * Lấy thông tin chi tiết dịch vụ theo mã dịch vụ
     */
    public ServiceItem getServiceById(String maDichVu) {
        if (maDichVu == null || maDichVu.trim().isEmpty()) {
            return null;
        }
        return serviceDAO.getServiceById(maDichVu.trim());
    }
}
