package com.mycompany.hotelmanagersystem.cashier.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceDetailDTO;
import com.mycompany.hotelmanagersystem.cashier.service.InvoiceService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller hiển thị chi tiết đơn đặt phòng và danh sách phòng phục vụ chọn trả phòng.
 */
@WebServlet(name = "CashierBookingDetailServlet", urlPatterns = {"/cashier/booking-detail"})
public class CashierBookingDetailServlet extends HttpServlet {

    private InvoiceService invoiceService;

    @Override
    public void init() throws ServletException {
        this.invoiceService = new InvoiceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String maBooking = request.getParameter("maBooking");

        if (maBooking == null || maBooking.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cashier/dashboard");
            return;
        }

        String maNV = resolveEmployeeId(request.getSession(false));
        InvoiceDetailDTO invoice = invoiceService.getInvoiceByBooking(maBooking.trim(), maNV);

        if (invoice == null) {
            response.sendRedirect(request.getContextPath() + "/cashier/dashboard?error=notfound");
            return;
        }

        request.setAttribute("invoice", invoice);
        request.setAttribute("errorMessage", request.getParameter("error"));
        request.getRequestDispatcher("/views/cashier/booking_detail.jsp").forward(request, response);
    }

    private String resolveEmployeeId(HttpSession session) {
        if (session != null) {
            UserSessionDTO user = (UserSessionDTO) session.getAttribute("CURRENT_USER");
            if (user != null && user.getMaDinhDanh() != null && !user.getMaDinhDanh().trim().isEmpty()) {
                return user.getMaDinhDanh().trim();
            }
        }
        return "NV001";
    }
}
