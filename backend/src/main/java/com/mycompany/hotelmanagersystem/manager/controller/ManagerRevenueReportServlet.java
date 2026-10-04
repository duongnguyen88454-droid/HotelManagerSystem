package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.DailyAuditReportDTO;
import com.mycompany.hotelmanagersystem.manager.dto.MonthlyRevenueDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerReportService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "ManagerRevenueReportServlet", urlPatterns = {"/manager/revenue"})
public class ManagerRevenueReportServlet extends HttpServlet {

    private final ManagerReportService reportService = new ManagerReportService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LocalDate reportDate = parseDate(request.getParameter("date"), LocalDate.now());
        DailyAuditReportDTO dailyReport = reportService.getDailyAuditReport(reportDate);
        List<MonthlyRevenueDTO> monthlyList = reportService.getMonthlyRevenueList();

        handleRangeFilter(request);

        request.setAttribute("reportDate", reportDate);
        request.setAttribute("dailyReport", dailyReport);
        request.setAttribute("monthlyList", monthlyList);
        request.getRequestDispatcher("/views/manager/revenue_report.jsp").forward(request, response);
    }

    private void handleRangeFilter(HttpServletRequest request) {
        String fromStr = request.getParameter("fromDate");
        String toStr = request.getParameter("toDate");
        if (fromStr != null && toStr != null && !fromStr.isEmpty() && !toStr.isEmpty()) {
            LocalDate fromDate = parseDate(fromStr, null);
            LocalDate toDate = parseDate(toStr, null);
            if (fromDate != null && toDate != null && !fromDate.isAfter(toDate)) {
                BigDecimal rangeRev = reportService.getRevenueByRange(fromDate, toDate);
                request.setAttribute("rangeRevenue", rangeRev);
                request.setAttribute("filterFromDate", fromDate);
                request.setAttribute("filterToDate", toDate);
            }
        }
    }

    private LocalDate parseDate(String val, LocalDate fallback) {
        if (val == null || val.trim().isEmpty()) {
            return fallback;
        }
        try {
            return LocalDate.parse(val.trim());
        } catch (DateTimeParseException e) {
            return fallback;
        }
    }
}
