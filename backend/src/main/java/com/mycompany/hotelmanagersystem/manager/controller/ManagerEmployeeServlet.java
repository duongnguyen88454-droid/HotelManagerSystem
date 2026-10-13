package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.EmployeeItemDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerEmployeeService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Controller tiếp nhận yêu cầu quản lý nhân sự và tài khoản cho Ban Quản Lý.
 */
@WebServlet(name = "ManagerEmployeeServlet", urlPatterns = {"/manager/employees"})
public class ManagerEmployeeServlet extends HttpServlet {

    private final ManagerEmployeeService employeeService = new ManagerEmployeeService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<EmployeeItemDTO> employees = employeeService.getAllEmployees();
        request.setAttribute("employees", employees);
        request.getRequestDispatcher("/views/manager/employees.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String employeeId = request.getParameter("employeeId");
        HttpSession session = request.getSession();

        if ("resign".equalsIgnoreCase(action)) {
            boolean success = employeeService.updateEmployeeResignation(employeeId, true);
            setFlashMessage(session, success, "Đã cập nhật trạng thái nghỉ việc và khóa tài khoản thành công!",
                    "Không thể cập nhật trạng thái nghỉ việc!");
        } else if ("reinstate".equalsIgnoreCase(action)) {
            boolean success = employeeService.updateEmployeeResignation(employeeId, false);
            setFlashMessage(session, success, "Đã kích hoạt lại nhân viên và mở khóa tài khoản thành công!",
                    "Không thể kích hoạt lại nhân viên!");
        } else if ("update_contact".equalsIgnoreCase(action)) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            boolean success = employeeService.updateEmployeeContact(employeeId, fullName, phone, email);
            setFlashMessage(session, success, "Đã cập nhật thông tin liên hệ nhân viên thành công!",
                    "Không thể cập nhật thông tin nhân viên!");
        }
        response.sendRedirect(request.getContextPath() + "/manager/employees");
    }

    private void setFlashMessage(HttpSession session, boolean success, String successMsg, String errorMsg) {
        if (success) {
            session.setAttribute("flashSuccess", successMsg);
        } else {
            session.setAttribute("flashError", errorMsg);
        }
    }
}
