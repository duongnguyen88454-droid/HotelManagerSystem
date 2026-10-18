package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;

/**
 * DTO tiếp nhận dữ liệu cập nhật tài khoản và phân quyền cho nhân viên.
 */
public class UpdateEmployeeAccountDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String employeeId;
    private String fullName;
    private String phone;
    private String email;
    private String userName;
    private String newPassword;
    private String role;
    private String accountStatus;

    public UpdateEmployeeAccountDTO() {
    }

    public UpdateEmployeeAccountDTO(String employeeId, String fullName, String phone, String email,
                                    String userName, String newPassword, String role, String accountStatus) {
        this.employeeId = employeeId;
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.userName = userName;
        this.newPassword = newPassword;
        this.role = role;
        this.accountStatus = accountStatus;
    }

    public String getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(String employeeId) {
        this.employeeId = employeeId;
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

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }
}
