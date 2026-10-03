package com.mycompany.hotelmanagersystem.housekeeper.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageCategoryDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.DamageDetailItemDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.HousekeeperTaskDTO;
import com.mycompany.hotelmanagersystem.housekeeper.service.HousekeeperTaskService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller phục vụ màn hình lập biên bản báo cáo hư hại cơ sở vật chất (F5.3).
 */
@WebServlet(name = "HousekeeperDamageReportServlet", urlPatterns = {"/housekeeper/damage-report"})
public class HousekeeperDamageReportServlet extends HttpServlet {

    private HousekeeperTaskService taskService;

    @Override
    public void init() throws ServletException {
        this.taskService = new HousekeeperTaskService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        UserSessionDTO currentUser = (UserSessionDTO) session.getAttribute("CURRENT_USER");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String taskId = request.getParameter("taskId");
        HousekeeperTaskDTO task = taskService.getTaskDetails(taskId);
        if (task == null) {
            session.setAttribute("flashError", "Không tìm thấy thông tin nhiệm vụ phòng!");
            response.sendRedirect(request.getContextPath() + "/housekeeper/tasks");
            return;
        }

        List<DamageCategoryDTO> damageCategories = taskService.getDamageCategories();
        request.setAttribute("task", task);
        request.setAttribute("damageCategories", damageCategories);

        request.getRequestDispatcher("/views/housekeeper/damage_report.jsp").forward(request, response);
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

        String taskId = request.getParameter("taskId");
        String moTaChung = request.getParameter("moTaChung");
        String[] categories = request.getParameterValues("maLoaiHuHai");
        String[] details = request.getParameterValues("moTaChiTiet");

        try {
            List<DamageDetailItemDTO> damageItems = buildDamageItemList(categories, details);
            taskService.submitDamageReport(taskId, currentUser.getMaDinhDanh(), moTaChung, damageItems);
            session.setAttribute("flashSuccess", "Đã lập biên bản sự cố gồm " + damageItems.size()
                    + " mục hư hại và khóa phòng để bảo trì!");
            response.sendRedirect(request.getContextPath() + "/housekeeper/tasks");
        } catch (Exception e) {
            session.setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/housekeeper/damage-report?taskId=" + taskId);
        }
    }

    private List<DamageDetailItemDTO> buildDamageItemList(String[] categories, String[] details) {
        List<DamageDetailItemDTO> list = new ArrayList<>();
        if (categories == null || details == null) {
            return list;
        }
        int length = Math.min(categories.length, details.length);
        for (int i = 0; i < length; i++) {
            String cat = categories[i];
            String det = details[i];
            if (cat != null && !cat.trim().isEmpty()) {
                list.add(new DamageDetailItemDTO(cat.trim(), det != null ? det.trim() : ""));
            }
        }
        return list;
    }
}
