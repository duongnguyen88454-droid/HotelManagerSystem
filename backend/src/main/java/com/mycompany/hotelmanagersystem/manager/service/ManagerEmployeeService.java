package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.auth.util.PasswordUtil;
import com.mycompany.hotelmanagersystem.manager.dao.ManagerEmployeeDAO;
import com.mycompany.hotelmanagersystem.manager.dto.CreateEmployeeDTO;
import com.mycompany.hotelmanagersystem.manager.dto.EmployeeItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.UpdateEmployeeAccountDTO;

import java.util.List;

/**
 * Service xử lý nghiệp vụ quản lý nhân sự cho Manager.
 */
public class ManagerEmployeeService {

    private final ManagerEmployeeDAO employeeDAO;

    public ManagerEmployeeService() {
        this.employeeDAO = new ManagerEmployeeDAO();
    }

    public ManagerEmployeeService(ManagerEmployeeDAO employeeDAO) {
        this.employeeDAO = employeeDAO;
    }

    public List<EmployeeItemDTO> getAllEmployees() {
        return employeeDAO.getAllEmployees();
    }

    public boolean updateEmployeeResignation(String employeeId, boolean isResigned) {
        if (employeeId == null || employeeId.trim().isEmpty()) {
            return false;
        }
        return employeeDAO.updateEmployeeResignation(employeeId.trim(), isResigned);
    }

    public boolean updateEmployeeContact(String employeeId, String fullName, String phone, String email) {
        if (employeeId == null || employeeId.trim().isEmpty()) {
            return false;
        }
        return employeeDAO.updateEmployeeContact(employeeId.trim(), fullName, phone, email);
    }

    public boolean createEmployee(CreateEmployeeDTO dto) {
        if (dto == null || isBlank(dto.getFullName()) || isBlank(dto.getPhone())
                || isBlank(dto.getEmail()) || isBlank(dto.getUserName()) || isBlank(dto.getPassword())) {
            return false;
        }
        String role = dto.getRole();
        if (!"Receptionist".equalsIgnoreCase(role) && !"Housekeeper".equalsIgnoreCase(role)) {
            return false;
        }
        dto.setPassword(PasswordUtil.hashPassword(dto.getPassword().trim()));
        return employeeDAO.createEmployeeWithAccount(dto);
    }

    public boolean updateEmployeeAccount(UpdateEmployeeAccountDTO dto) {
        if (dto == null || isBlank(dto.getEmployeeId()) || isBlank(dto.getFullName())
                || isBlank(dto.getPhone()) || isBlank(dto.getEmail()) || isBlank(dto.getUserName())) {
            return false;
        }
        String role = dto.getRole();
        if (!"Receptionist".equalsIgnoreCase(role) && !"Housekeeper".equalsIgnoreCase(role)) {
            return false;
        }
        String status = dto.getAccountStatus();
        if (!"Active".equalsIgnoreCase(status) && !"Locked".equalsIgnoreCase(status)) {
            return false;
        }
        if (!isBlank(dto.getNewPassword())) {
            dto.setNewPassword(PasswordUtil.hashPassword(dto.getNewPassword().trim()));
        }
        return employeeDAO.updateEmployeeAccount(dto);
    }

    private boolean isBlank(String str) {
        return str == null || str.trim().isEmpty();
    }
}
