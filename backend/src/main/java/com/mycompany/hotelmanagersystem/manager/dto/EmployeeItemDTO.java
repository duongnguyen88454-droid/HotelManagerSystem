package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * DTO hiển thị danh sách hồ sơ nhân viên và trạng thái tài khoản cho Manager.
 */
public class EmployeeItemDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String employeeId;
    private String accountId;
    private String userName;
    private String fullName;
    private String phone;
    private String email;
    private String role;
    private LocalDate hireDate;
    private LocalDate resignationDate;
    private String employeeStatus;
    private String accountStatus;

    public EmployeeItemDTO() {
    }

    public EmployeeItemDTO(String employeeId, String accountId, String userName,
                           String fullName, String phone, String email, String role,
                           LocalDate hireDate, LocalDate resignationDate,
                           String employeeStatus, String accountStatus) {
        this.employeeId = employeeId;
        this.accountId = accountId;
        this.userName = userName;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.role = role;
        this.hireDate = hireDate;
        this.resignationDate = resignationDate;
        this.employeeStatus = employeeStatus;
        this.accountStatus = accountStatus;
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
    }

    public String getAccountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public LocalDate getHireDate() {
        return hireDate;
    }

    public void setHireDate(LocalDate hireDate) {
        this.hireDate = hireDate;
    }

    public LocalDate getResignationDate() {
        return resignationDate;
    }

    public void setResignationDate(LocalDate resignationDate) {
        this.resignationDate = resignationDate;
    }

    public String getEmployeeStatus() {
        return employeeStatus;
    }

    public void setEmployeeStatus(String employeeStatus) {
        this.employeeStatus = employeeStatus;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }
}
