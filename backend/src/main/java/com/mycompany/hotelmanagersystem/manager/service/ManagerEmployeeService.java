package com.mycompany.hotelmanagersystem.manager.service;

import com.mycompany.hotelmanagersystem.manager.dao.ManagerEmployeeDAO;
import com.mycompany.hotelmanagersystem.manager.dto.EmployeeItemDTO;

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
}
