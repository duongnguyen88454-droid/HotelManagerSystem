package com.mycompany.hotelmanagersystem.manager.dto;

import java.io.Serializable;

/**
 * DTO tiếp nhận dữ liệu thêm nhân viên mới kèm tài khoản đăng nhập.
 */
public class CreateEmployeeDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String fullName;
    private String phone;
    private String email;
    private String role;
    private String userName;
    private String password;

    public CreateEmployeeDTO() {
    }

    public CreateEmployeeDTO(String fullName, String phone, String email,
                             String role, String userName, String password) {
        this.fullName = fullName;
        this.phone = phone;
        this.email = email;
        this.role = role;
        this.userName = userName;
        this.password = password;
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

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
