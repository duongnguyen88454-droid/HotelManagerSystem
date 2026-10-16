package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.CreateEmployeeDTO;
import com.mycompany.hotelmanagersystem.manager.dto.EmployeeItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.UpdateEmployeeAccountDTO;
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
        HttpSession session = request.getSession();

        if ("resign".equalsIgnoreCase(action)) {
            handleResign(request, session);
        } else if ("reinstate".equalsIgnoreCase(action)) {
            handleReinstate(request, session);
        } else if ("update_contact".equalsIgnoreCase(action)) {
            handleUpdateContact(request, session);
        } else if ("create".equalsIgnoreCase(action)) {
            handleCreate(request, session);
        } else if ("update_account".equalsIgnoreCase(action)) {
            handleUpdateAccount(request, session);
        }
        response.sendRedirect(request.getContextPath() + "/manager/employees");
    }

    private void handleResign(HttpServletRequest request, HttpSession session) {
        String employeeId = request.getParameter("employeeId");
        boolean success = employeeService.updateEmployeeResignation(employeeId, true);
        setFlashMessage(session, success, "Đã cập nhật trạng thái nghỉ việc và khóa tài khoản thành công!",
                "Không thể cập nhật trạng thái nghỉ việc!");
    }

    private void handleReinstate(HttpServletRequest request, HttpSession session) {
        String employeeId = request.getParameter("employeeId");
        boolean success = employeeService.updateEmployeeResignation(employeeId, false);
        setFlashMessage(session, success, "Đã kích hoạt lại nhân viên và mở khóa tài khoản thành công!",
                "Không thể kích hoạt lại nhân viên!");
    }

    private void handleUpdateContact(HttpServletRequest request, HttpSession session) {
        String employeeId = request.getParameter("employeeId");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        boolean success = employeeService.updateEmployeeContact(employeeId, fullName, phone, email);
        setFlashMessage(session, success, "Đã cập nhật thông tin liên hệ nhân viên thành công!",
                "Không thể cập nhật thông tin nhân viên!");
    }

    private void handleCreate(HttpServletRequest request, HttpSession session) {
        CreateEmployeeDTO dto = new CreateEmployeeDTO(
                request.getParameter("fullName"),
                request.getParameter("phone"),
                request.getParameter("email"),
                request.getParameter("role"),
                request.getParameter("userName"),
                request.getParameter("password")
        );
        boolean success = employeeService.createEmployee(dto);
        setFlashMessage(session, success, "Thêm nhân viên mới thành công!",
                "Không thể thêm nhân viên mới (Số ĐT, Email hoặc Tên đăng nhập có thể đã tồn tại)!");
    }

    private void handleUpdateAccount(HttpServletRequest request, HttpSession session) {
        UpdateEmployeeAccountDTO dto = new UpdateEmployeeAccountDTO(
                request.getParameter("employeeId"),
                request.getParameter("userName"),
                request.getParameter("newPassword"),
                request.getParameter("role"),
                request.getParameter("accountStatus")
        );
        boolean success = employeeService.updateEmployeeAccount(dto);
        setFlashMessage(session, success, "Đã cập nhật thông tin tài khoản nhân viên thành công!",
                "Không thể cập nhật tài khoản (Tên đăng nhập có thể đã tồn tại hoặc dữ liệu không hợp lệ)!");
    }

    private void setFlashMessage(HttpSession session, boolean success, String successMsg, String errorMsg) {
        if (success) {
            session.setAttribute("flashSuccess", successMsg);
        } else {
            session.setAttribute("flashError", errorMsg);
        }
    }
}
