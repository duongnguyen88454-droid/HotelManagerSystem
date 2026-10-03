package com.mycompany.hotelmanagersystem.housekeeper.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.housekeeper.service.HousekeeperTaskService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller xử lý các hành động tác vụ buồng phòng (Nhận việc, Hoàn thành).
 */
@WebServlet(name = "HousekeeperTaskActionServlet", urlPatterns = {"/housekeeper/task-action"})
public class HousekeeperTaskActionServlet extends HttpServlet {

    private HousekeeperTaskService taskService;

    @Override
    public void init() throws ServletException {
        this.taskService = new HousekeeperTaskService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        UserSessionDTO currentUser = (UserSessionDTO) session.getAttribute("CURRENT_USER");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String maNhiemVu = request.getParameter("maNhiemVu");
        boolean hasDamage = "true".equalsIgnoreCase(request.getParameter("hasDamage"));

        if ("complete".equalsIgnoreCase(action) && hasDamage) {
            response.sendRedirect(request.getContextPath() + "/housekeeper/damage-report?taskId=" + maNhiemVu);
            return;
        }

        executeAction(session, currentUser.getMaDinhDanh(), action, maNhiemVu);
        response.sendRedirect(request.getContextPath() + "/housekeeper/tasks");
    }

    private void executeAction(HttpSession session, String maNV, String action, String maNhiemVu) {
        try {
            if ("start".equalsIgnoreCase(action)) {
                taskService.startCleaning(maNhiemVu, maNV);
                session.setAttribute("flashSuccess", "Đã nhận việc thành công! Phòng chuyển sang trạng thái đang dọn dẹp.");
            } else if ("complete".equalsIgnoreCase(action)) {
                taskService.completeClean(maNhiemVu, maNV);
                session.setAttribute("flashSuccess", "Đã nghiệm thu hoàn tất! Phòng đã sạch sẽ và sẵn sàng đón khách.");
            } else {
                session.setAttribute("flashError", "Hành động không hợp lệ!");
            }
        } catch (Exception e) {
            session.setAttribute("flashError", e.getMessage());
        }
    }
}
