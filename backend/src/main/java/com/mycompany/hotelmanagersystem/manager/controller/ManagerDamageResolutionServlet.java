package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.DamagedRoomItemDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerMaintenanceService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ManagerDamageResolutionServlet", urlPatterns = {"/manager/damages"})
public class ManagerDamageResolutionServlet extends HttpServlet {

    private final ManagerMaintenanceService maintenanceService = new ManagerMaintenanceService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<DamagedRoomItemDTO> damagedRooms = maintenanceService.getPendingDamagedRooms();
        request.setAttribute("damagedRooms", damagedRooms);
        request.getRequestDispatcher("/views/manager/damages.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String maBaoCao = request.getParameter("maBaoCao");
        String maPhong = request.getParameter("maPhong");
        String soPhong = request.getParameter("soPhong");

        HttpSession session = request.getSession();
        if ("resolve".equals(action)) {
            boolean success = maintenanceService.resolveDamagedRoom(maBaoCao, maPhong);
            if (success) {
                session.setAttribute("flashSuccess",
                        "Nghiệm thu bảo trì thành công! Phòng " + soPhong + " đã mở khóa sang trạng thái Available.");
            } else {
                session.setAttribute("flashError", "Không thể cập nhật trạng thái phòng. Vui lòng thử lại!");
            }
        }
        response.sendRedirect(request.getContextPath() + "/manager/damages");
    }
}
