package com.mycompany.hotelmanagersystem.housekeeper.controller;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.housekeeper.dto.HousekeeperTaskDTO;
import com.mycompany.hotelmanagersystem.housekeeper.service.HousekeeperTaskService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Controller tiếp nhận yêu cầu hiển thị bảng nhiệm vụ buồng phòng.
 */
@WebServlet(name = "HousekeeperPortalServlet", urlPatterns = {"/housekeeper/tasks"})
public class HousekeeperPortalServlet extends HttpServlet {

    private HousekeeperTaskService taskService;

    @Override
    public void init() throws ServletException {
        this.taskService = new HousekeeperTaskService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String status = request.getParameter("status");
        List<HousekeeperTaskDTO> taskList = taskService.getTaskList(status);
        HousekeeperTaskDTO currentActiveTask = findActiveTaskOfCurrentUser(request, taskList);

        request.setAttribute("taskList", taskList);
        request.setAttribute("currentStatus", resolveCurrentStatus(status));
        request.setAttribute("currentActiveTask", currentActiveTask);

        request.getRequestDispatcher("/views/housekeeper/tasks.jsp").forward(request, response);
    }

    private HousekeeperTaskDTO findActiveTaskOfCurrentUser(HttpServletRequest request,
                                                           List<HousekeeperTaskDTO> taskList) {
        Object userObj = request.getSession().getAttribute("CURRENT_USER");
        if (userObj instanceof UserSessionDTO) {
            String currentMaNV = ((UserSessionDTO) userObj).getMaDinhDanh();
            if (currentMaNV != null) {
                for (HousekeeperTaskDTO task : taskList) {
                    if ("DangDon".equalsIgnoreCase(task.getTrangThaiNhiemVu())
                            && currentMaNV.equalsIgnoreCase(task.getMaNV())) {
                        return task;
                    }
                }
            }
        }
        return null;
    }

    private String resolveCurrentStatus(String status) {
        if (status != null && !status.trim().isEmpty()) {
            return status.trim();
        }
        return "TatCa";
    }
}
