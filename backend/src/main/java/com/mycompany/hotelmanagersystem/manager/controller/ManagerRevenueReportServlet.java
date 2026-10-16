package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.service.ManagerEmployeeService;
import com.mycompany.hotelmanagersystem.manager.service.ManagerReportService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet(name = "ManagerRevenueReportServlet", urlPatterns = {"/manager/revenue"})
public class ManagerRevenueReportServlet extends HttpServlet {

    private final ManagerReportService reportService = new ManagerReportService();
    private final ManagerEmployeeService employeeService = new ManagerEmployeeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String reportType = request.getParameter("type");
        if (reportType == null || reportType.trim().isEmpty()) {
            reportType = "invoice";
        }
        LocalDate fromDate = parseDate(request.getParameter("fromDate"), LocalDate.now().withDayOfMonth(1));
        LocalDate toDate = parseDate(request.getParameter("toDate"), LocalDate.now());
        String employeeId = request.getParameter("employeeId");

        request.setAttribute("employeeList", employeeService.getAllEmployees());
        request.setAttribute("reportType", reportType);
        request.setAttribute("fromDate", fromDate);
        request.setAttribute("toDate", toDate);
        request.setAttribute("selectedEmployeeId", employeeId);

        loadReportData(request, reportType, fromDate, toDate, employeeId);
        request.getRequestDispatcher("/views/manager/revenue_report.jsp").forward(request, response);
    }

    private void loadReportData(HttpServletRequest req, String type, LocalDate from, LocalDate to, String empId) {
        switch (type) {
            case "room":
                req.setAttribute("roomReport", reportService.getRoomRevenueReport(from, to, empId));
                break;
            case "product":
                req.setAttribute("productReport", reportService.getProductRevenueReport(from, to));
                break;
            case "overall":
                req.setAttribute("overallReport", reportService.getPaymentReceiptReport(from, to, empId));
                break;
            case "invoice":
            default:
                req.setAttribute("invoiceReport", reportService.getInvoiceRevenueReport(from, to, empId));
                break;
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

