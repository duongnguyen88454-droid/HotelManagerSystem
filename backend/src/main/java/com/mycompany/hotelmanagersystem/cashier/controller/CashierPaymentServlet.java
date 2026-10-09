package com.mycompany.hotelmanagersystem.cashier.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceDetailDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.PaymentRecordDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.PaymentResultDTO;
import com.mycompany.hotelmanagersystem.cashier.service.InvoiceService;
import com.mycompany.hotelmanagersystem.cashier.service.PaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * Controller tiếp nhận giao dịch thanh toán và đối soát số dư của hóa đơn.
 */
@WebServlet(name = "CashierPaymentServlet", urlPatterns = {"/cashier/payment"})
public class CashierPaymentServlet extends HttpServlet {

    private InvoiceService invoiceService;
    private PaymentService paymentService;

    @Override
    public void init() throws ServletException {
        this.invoiceService = new InvoiceService();
        this.paymentService = new PaymentService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String maHoaDon = request.getParameter("maHoaDon");
        String maBooking = request.getParameter("maBooking");
        String[] selectedRooms = request.getParameterValues("selectedRooms");
        String maNV = resolveEmployeeId(request.getSession(false));

        InvoiceDetailDTO invoice = (maHoaDon != null && !maHoaDon.trim().isEmpty())
                ? invoiceService.getFullInvoiceForDisplay(maHoaDon.trim())
                : invoiceService.getInvoiceByBooking(maBooking, maNV);

        if (invoice == null) {
            response.sendRedirect(request.getContextPath() + "/cashier/dashboard");
            return;
        }

        List<String> roomList = (selectedRooms != null) ? Arrays.asList(selectedRooms) : Collections.emptyList();
        double paymentAmount = invoiceService.calculateAmountForSelectedRooms(invoice, roomList);
        List<PaymentRecordDTO> paymentHistory = paymentService.getPaymentHistory(invoice.getMaHoaDon());

        request.setAttribute("invoice", invoice);
        request.setAttribute("selectedRooms", selectedRooms);
        request.setAttribute("paymentAmount", paymentAmount);
        request.setAttribute("paymentHistory", paymentHistory);
        String sessionErr = (String) request.getSession().getAttribute("cashierError");
        request.setAttribute("errorMessage", (sessionErr != null) ? sessionErr : request.getParameter("error"));
        if (sessionErr != null) {
            request.getSession().removeAttribute("cashierError");
        }
        request.getRequestDispatcher("/views/cashier/payment_form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String maBooking = request.getParameter("maBooking");
        String maHoaDon = request.getParameter("maHoaDon");
        String phuongThuc = request.getParameter("phuongThuc");
        String strSoTien = request.getParameter("soTien");
        String[] selectedRoomsArr = request.getParameterValues("selectedRooms");
        List<String> roomList = (selectedRoomsArr != null) ? Arrays.asList(selectedRoomsArr) : Collections.emptyList();

        if ((maHoaDon == null || maHoaDon.trim().isEmpty())
                && (maBooking == null || maBooking.trim().isEmpty())) {
            response.sendRedirect(request.getContextPath() + "/cashier/dashboard");
            return;
        }

        double soTien = parseAmount(strSoTien);
        if (soTien < 0) {
            request.getSession().setAttribute("cashierError", "Số tiền thanh toán không được âm!");
            response.sendRedirect(request.getContextPath() + "/cashier/payment?maHoaDon=" + maHoaDon);
            return;
        }

        String maNV = resolveEmployeeId(request.getSession(false));
        PaymentResultDTO result = paymentService.processPaymentAndCheckOut(
                maBooking, maHoaDon, roomList, maNV, soTien, phuongThuc);

        if (result.isSuccess()) {
            response.sendRedirect(request.getContextPath() + "/cashier/invoice?maHoaDon="
                    + result.getMaHoaDon() + "&paymentSuccess=1");
        } else {
            request.getSession().setAttribute("cashierError", result.getMessage());
            response.sendRedirect(request.getContextPath() + "/cashier/payment?maHoaDon=" + maHoaDon);
        }
    }

    private double parseAmount(String str) {
        if (str == null || str.trim().isEmpty()) {
            return 0.0;
        }
        try {
            return Double.parseDouble(str.trim());
        } catch (NumberFormatException e) {
            try {
                return Double.parseDouble(str.trim().replaceAll("[,.]", ""));
            } catch (NumberFormatException ex) {
                return 0.0;
            }
        }
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
