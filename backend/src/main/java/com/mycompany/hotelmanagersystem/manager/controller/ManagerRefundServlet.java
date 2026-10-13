package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.booking.dto.CancellationRecordDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerRefundService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller xử lý tiếp nhận và xét duyệt hoàn tiền cọc hủy phòng cho Quản Lý.
 */
@WebServlet(name = "ManagerRefundServlet", urlPatterns = {"/manager/refunds"})
public class ManagerRefundServlet extends HttpServlet {

    private final ManagerRefundService refundService = new ManagerRefundService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<CancellationRecordDTO> cancellations = refundService.getAllCancellationRequests();
        request.setAttribute("cancellations", cancellations);
        request.getRequestDispatcher("/views/manager/refunds.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String cancellationId = request.getParameter("cancellationId");
        HttpSession session = request.getSession();

        if ("approve".equalsIgnoreCase(action)) {
            boolean success = refundService.processRefund(cancellationId, true);
            setFlashMessage(session, success, "Đã duyệt hoàn tiền cọc hủy phòng thành công!",
                    "Không thể cập nhật trạng thái duyệt hoàn tiền!");
        } else if ("reject".equalsIgnoreCase(action)) {
            boolean success = refundService.processRefund(cancellationId, false);
            setFlashMessage(session, success, "Đã từ chối hoàn tiền cọc hủy phòng!",
                    "Không thể cập nhật trạng thái từ chối hoàn tiền!");
        }

        response.sendRedirect(request.getContextPath() + "/manager/refunds");
    }

    private void setFlashMessage(HttpSession session, boolean success, String successMsg, String errorMsg) {
        if (success) {
            session.setAttribute("flashSuccess", successMsg);
        } else {
            session.setAttribute("flashError", errorMsg);
        }
    }
}
