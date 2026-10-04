package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.manager.dao.ManagerReportDAO;
import com.mycompany.hotelmanagersystem.manager.dao.ServiceAnalyticsDAO;
import com.mycompany.hotelmanagersystem.manager.dto.DailyAuditReportDTO;
import com.mycompany.hotelmanagersystem.manager.dto.MonthlyRevenueDTO;
import com.mycompany.hotelmanagersystem.manager.dto.ServiceAnalyticsDTO;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public class ManagerReportService {

    private final ManagerReportDAO reportDAO;
    private final ServiceAnalyticsDAO serviceAnalyticsDAO;

    public ManagerReportService() {
        this.reportDAO = new ManagerReportDAO();
        this.serviceAnalyticsDAO = new ServiceAnalyticsDAO();
    }

    public ManagerReportService(ManagerReportDAO reportDAO, ServiceAnalyticsDAO serviceAnalyticsDAO) {
        this.reportDAO = reportDAO;
        this.serviceAnalyticsDAO = serviceAnalyticsDAO;
    }

    public DailyAuditReportDTO getDailyAuditReport(LocalDate reportDate) {
        return reportDAO.getDailyAuditReport(reportDate);
    }

    public List<MonthlyRevenueDTO> getMonthlyRevenueList() {
        return reportDAO.getMonthlyRevenueList();
    }

    public BigDecimal getRevenueByRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
            return BigDecimal.ZERO;
        }
        return reportDAO.getRevenueByRange(fromDate, toDate);
    }

    public List<ServiceAnalyticsDTO> getServiceAnalytics() {
        return serviceAnalyticsDAO.getServiceAnalytics();
    }
}
