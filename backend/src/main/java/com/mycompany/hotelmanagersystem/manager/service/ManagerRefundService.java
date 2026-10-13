package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.booking.dto.CancellationRecordDTO;
import com.mycompany.hotelmanagersystem.manager.dao.ManagerRefundDAO;

import java.util.List;

/**
 * Service xử lý xét duyệt hoàn tiền cọc hủy phòng cho Ban Quản Lý (Manager).
 */
public class ManagerRefundService {

    private final ManagerRefundDAO refundDAO;

    public ManagerRefundService() {
        this.refundDAO = new ManagerRefundDAO();
    }

    public ManagerRefundService(ManagerRefundDAO refundDAO) {
        this.refundDAO = refundDAO;
    }

    public List<CancellationRecordDTO> getAllCancellationRequests() {
        return refundDAO.getAllCancellationRequests();
    }

    public boolean processRefund(String cancellationId, boolean isApproved) {
        if (cancellationId == null || cancellationId.trim().isEmpty()) {
            return false;
        }
        String status = isApproved ? "Completed" : "Rejected";
        return refundDAO.updateRefundStatus(cancellationId.trim(), status);
    }
}
