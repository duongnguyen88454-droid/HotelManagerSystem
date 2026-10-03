package com.mycompany.hotelmanagersystem.cashier.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceDetailDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.PaymentRecordDTO;
import com.mycompany.hotelmanagersystem.cashier.service.InvoiceService;
import com.mycompany.hotelmanagersystem.cashier.service.PaymentService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller hiển thị chi tiết hóa đơn thanh toán và lịch sử giao dịch phục vụ in hóa đơn.
 */
@WebServlet(name = "CashierInvoiceServlet", urlPatterns = {"/cashier/invoice"})
public class CashierInvoiceServlet extends HttpServlet {

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
        String maNV = resolveEmployeeId(request.getSession(false));

        InvoiceDetailDTO invoice = (maHoaDon != null && !maHoaDon.trim().isEmpty())
                ? invoiceService.getFullInvoiceForDisplay(maHoaDon.trim())
                : invoiceService.getInvoiceByBooking(maBooking, maNV);

        if (invoice == null) {
            response.sendRedirect(request.getContextPath() + "/cashier/dashboard");
            return;
        }

        List<PaymentRecordDTO> paymentHistory = paymentService.getPaymentHistory(invoice.getMaHoaDon());

        request.setAttribute("invoice", invoice);
        request.setAttribute("paymentHistory", paymentHistory);
        request.setAttribute("paymentSuccess", "1".equals(request.getParameter("paymentSuccess")));
        request.getRequestDispatcher("/views/cashier/invoice_detail.jsp").forward(request, response);
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
