package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.manager.dao.RevenueReportDAO;
import com.mycompany.hotelmanagersystem.manager.dto.InvoiceRevenueItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.PaymentReceiptItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.ProductRevenueItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.RoomRevenueItemDTO;

import java.time.LocalDate;
import java.util.List;

public class ManagerReportService {

    private final RevenueReportDAO revenueReportDAO;

    public ManagerReportService() {
        this.revenueReportDAO = new RevenueReportDAO();
    }

    public ManagerReportService(RevenueReportDAO revenueReportDAO) {
        this.revenueReportDAO = revenueReportDAO;
    }

    public List<InvoiceRevenueItemDTO> getInvoiceRevenueReport(LocalDate from, LocalDate to, String empId) {
        return revenueReportDAO.getInvoiceRevenueReport(from, to, empId);
    }

    public List<RoomRevenueItemDTO> getRoomRevenueReport(LocalDate from, LocalDate to, String empId) {
        return revenueReportDAO.getRoomRevenueReport(from, to, empId);
    }

    public List<ProductRevenueItemDTO> getProductRevenueReport(LocalDate from, LocalDate to) {
        return revenueReportDAO.getProductRevenueReport(from, to);
    }

    public List<PaymentReceiptItemDTO> getPaymentReceiptReport(LocalDate from, LocalDate to, String empId) {
        return revenueReportDAO.getPaymentReceiptReport(from, to, empId);
    }
}

