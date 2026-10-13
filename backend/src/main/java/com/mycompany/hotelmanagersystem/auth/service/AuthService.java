package com.mycompany.hotelmanagersystem.auth.service;

import com.mycompany.hotelmanagersystem.auth.dao.AccountDAO;
import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.customer.model.Customer;
import com.mycompany.hotelmanagersystem.auth.model.Account;
import com.mycompany.hotelmanagersystem.auth.util.PasswordUtil;

public class AuthService {
    private final AccountDAO accountDAO;

    public AuthService() {
        this.accountDAO = new AccountDAO();
    }

    /**
     * Xác thực đăng nhập bằng đúng Email và Mật khẩu trong bảng TAIKHOAN:
     * - Băm mật khẩu thô người dùng vừa nhập bằng thuật toán SHA-256.
     * - So sánh chuỗi băm này với chuỗi băm đã lưu trong CSDL (qua PasswordUtil).
     * - Hỗ trợ tương thích ngược (fallback) cho tài khoản seed mẫu.
     */
    public UserSessionDTO login(String email, String password) throws Exception {
        if (email == null || email.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập Email.");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập mật khẩu.");
        }

        // Xác thực đăng nhập: So khớp chuỗi băm với CSDL
        UserSessionDTO user = accountDAO.checkLogin(email.trim(), password);
        if (user == null) {
            throw new Exception("Email hoặc mật khẩu không chính xác.");
        }

        if ("Locked".equalsIgnoreCase(user.getTrangThai())) {
            throw new Exception("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ ban quản lý.");
        }

        return user;
    }

    /**
     * Xác định URL đích theo vai trò sau khi đăng nhập thành công
     */
    public String getRedirectUrlByRole(String contextPath, String role) {
        if (role == null) {
            return contextPath + "/index.jsp";
        }
        switch (role.toUpperCase()) {
            case "CUSTOMER":
                return contextPath + "/customer/home";
            case "RECEPTIONIST":
                return contextPath + "/receptionist/room-map";
            case "HOUSEKEEPER":
                return contextPath + "/housekeeper/tasks";
            case "MANAGER":
                return contextPath + "/manager/dashboard";
            default:
                return contextPath + "/index.jsp";
        }
    }

    /**
     * Đăng ký tài khoản Web Khách hàng mới online (Chỉ ghi vào bảng TAIKHOAN với
     * đúng 6 thuộc tính chuẩn;
     * Hoàn toàn không ghi vào bảng KHACHHANG, không bắt buộc SĐT lúc tạo tài
     * khoản).
     */
    public boolean register(String hoTen, String email, String password, String confirmPassword)
            throws Exception {
        if (hoTen == null || hoTen.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {
            throw new Exception("Vui lòng điền đầy đủ: Họ tên, Email và Mật khẩu.");
        }

        if (!password.equals(confirmPassword)) {
            throw new Exception("Mật khẩu xác nhận không khớp.");
        }

        if (!email.contains("@") || !email.contains(".")) {
            throw new Exception("Địa chỉ email không đúng định dạng.");
        }

        if (accountDAO.checkEmailExists(email.trim())) {
            throw new Exception(
                    "Email này đã được sử dụng để đăng ký tài khoản. Vui lòng đăng nhập hoặc chọn email khác.");
        }

        // Tự sinh mã tài khoản bằng SQL Server Function fn_SinhMaTaiKhoan
        String maTaiKhoan = accountDAO.getNextAccountIdFromDB();

        // Băm mật khẩu bằng thuật toán SHA-256 trước khi lưu vào CSDL
        String hashedPassword = PasswordUtil.hashPassword(password);

        // Lưu tài khoản
        Account tk = new Account(maTaiKhoan, hashedPassword, "Customer", "Active", hoTen.trim(), email.trim());

        return accountDAO.registerAccount(tk);
    }

    public boolean register(String hoTen, String email, String soDT, String password, String confirmPassword)
            throws Exception {
        return register(hoTen, email, password, confirmPassword);
    }

    public boolean validateCccd(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return false;
        }
        return cccd.trim().matches("^[0-9]{12}$");
    }
}
