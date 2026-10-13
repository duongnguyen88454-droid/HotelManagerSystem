package com.mycompany.hotelmanagersystem.cashier.service;

import com.mycompany.hotelmanagersystem.cashier.dao.ActiveBookingDAO;
import com.mycompany.hotelmanagersystem.cashier.dto.ActiveBookingItemDTO;

import java.util.Collections;
import java.util.List;

/**
 * Service tra cứu và quản lý danh sách đơn lưu trú phục vụ màn hình Thu Ngân.
 */
public class ActiveBookingService {

    private final ActiveBookingDAO activeBookingDAO;

    public ActiveBookingService() {
        this.activeBookingDAO = new ActiveBookingDAO();
    }

    public ActiveBookingService(ActiveBookingDAO activeBookingDAO) {
        this.activeBookingDAO = activeBookingDAO;
    }

    /**
     * Tìm kiếm danh sách các đơn đặt phòng đang lưu trú theo từ khóa.
     */
    public List<ActiveBookingItemDTO> findCheckedInBookings(String keyword) {
        try {
            return activeBookingDAO.findCheckedInBookings(keyword);
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    /**
     * Kiểm tra xem đơn đặt phòng có còn phòng chưa trả hay không.
     */
    public boolean hasUncheckedOutRooms(String maBooking) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return false;
        }
        try {
            return activeBookingDAO.hasUncheckedOutRooms(maBooking.trim());
        } catch (Exception e) {
            return false;
        }
    }
}
