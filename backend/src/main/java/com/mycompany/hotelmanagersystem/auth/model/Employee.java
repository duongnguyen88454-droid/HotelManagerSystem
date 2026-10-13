package com.mycompany.hotelmanagersystem.auth.model;

import java.io.Serializable;
import java.time.LocalDate;

/**
 * Entity ánh xạ bảng Employee (Hồ sơ nhân viên) trong CSDL 3NF.
 */
public class Employee implements Serializable {
    private static final long serialVersionUID = 1L;

    private String employeeId;
    private String accountId;
    private String fullName;
    private String phone;
    private String email;
    private LocalDate hireDate;
    private LocalDate resignationDate;
    private String employeeStatus;

    public Employee() {
    }

    public Employee(String employeeId, String accountId, String fullName, String phone,
                    String email, LocalDate hireDate, LocalDate resignationDate, String employeeStatus) {
        this.employeeId = employeeId;
        this.accountId = accountId;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.hireDate = hireDate;
        this.resignationDate = resignationDate;
        this.employeeStatus = employeeStatus;
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
}
