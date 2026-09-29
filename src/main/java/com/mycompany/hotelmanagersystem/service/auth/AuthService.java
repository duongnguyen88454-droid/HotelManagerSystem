package com.mycompany.hotelmanagersystem.service.auth;

import com.mycompany.hotelmanagersystem.dao.auth.AccountDAO;
import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.model.Customer;
import com.mycompany.hotelmanagersystem.model.Account;
import com.mycompany.hotelmanagersystem.util.KeyGenerator;
import com.mycompany.hotelmanagersystem.util.PasswordUtil;

public class AuthService {
    private final AccountDAO accountDAO;

    public AuthService() {
        this.accountDAO = new AccountDAO();
    }

    /**
     * Xác thực đăng nhập bằng Email hoặc Số điện thoại
     */
    public UserSessionDTO login(String loginIdentifier, String password) throws Exception {
        if (loginIdentifier == null || loginIdentifier.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập Email hoặc Số điện thoại.");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập mật khẩu.");
        }

        UserSessionDTO user = accountDAO.checkLogin(loginIdentifier.trim(), password);
        if (user == null) {
            throw new Exception("Email/Số điện thoại hoặc mật khẩu không chính xác.");
        }

        if ("Locked".equalsIgnoreCase(user.getTrangThai())) {
            throw new Exception("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ ban quản lý.");
        }

        return user;
    }

    /**
     * Xác định URL đích theo vai trò sau khi đăng nhập thành công
     */
    public String getRedirectUrlByRole(String contextPath, String maVaiTro) {
        if (maVaiTro == null) {
            return contextPath + "/index.jsp";
        }
        switch (maVaiTro.toUpperCase()) {
            case "VT01": // Khách hàng
                return contextPath + "/customer/home";
            case "VT02": // Lễ tân
                return contextPath + "/receptionist/room-map";
            case "VT03": // Buồng phòng
                return contextPath + "/housekeeper/tasks";
            case "VT04": // Quản lý
                return contextPath + "/manager/dashboard";
            default:
                return contextPath + "/index.jsp";
        }
    }

    /**
     * Đăng ký tài khoản Khách hàng mới online (Email và SĐT là 2 trường bắt buộc duy nhất; CCCD không yêu cầu khi đăng ký).
     */
    public boolean register(String hoTen, String email, String soDT, String password, String confirmPassword) throws Exception {
        if (hoTen == null || hoTen.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            soDT == null || soDT.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            throw new Exception("Vui lòng điền đầy đủ: Họ tên, Email, Số điện thoại và Mật khẩu.");
        }

        if (!password.equals(confirmPassword)) {
            throw new Exception("Mật khẩu xác nhận không khớp.");
        }

        if (!email.contains("@") || !email.contains(".")) {
            throw new Exception("Địa chỉ email không đúng định dạng.");
        }

        // Kiểm tra định dạng số điện thoại (chứa chữ số, từ 9-11 ký tự)
        if (!soDT.trim().matches("^[0-9]{9,11}$")) {
            throw new Exception("Số điện thoại không hợp lệ (phải từ 9 đến 11 chữ số).");
        }

        if (accountDAO.checkEmailExists(email.trim())) {
            throw new Exception("Email này đã được sử dụng. Vui lòng chọn email khác.");
        }

        if (accountDAO.checkPhoneExists(soDT.trim())) {
            throw new Exception("Số điện thoại này đã được đăng ký cho tài khoản khác.");
        }

        // Tự sinh mã tự tăng theo chuẩn liền mạch (TK001, KH001...) dựa trên số lớn nhất hiện có
        String maTaiKhoan = KeyGenerator.generateAccountId();
        String maKH = KeyGenerator.generateCustomerId();

        // Băm mật khẩu bằng thuật toán SHA-256 trước khi lưu vào CSDL
        String hashedPassword = PasswordUtil.hashPassword(password);

        // Lưu tài khoản với TenDangNhap = Email và mật khẩu đã băm; CCCD để null khi đăng ký online
        Account tk = new Account(maTaiKhoan, email.trim(), hashedPassword, "VT01", "Active");
        Customer kh = new Customer(maKH, maTaiKhoan, hoTen.trim(), email.trim(), soDT.trim(), null);

        return accountDAO.registerCustomer(tk, kh);
    }

    /**
     * Kiểm tra tính hợp lệ của số CCCD theo quy chuẩn Nhà nước Việt Nam:
     * - Bắt buộc đúng 12 ký tự chữ số [0-9]
     * - Được sử dụng khi khách hàng check-in tại quầy hoặc cập nhật hồ sơ cá nhân
     */
    public boolean validateCccd(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return false;
        }
        return cccd.trim().matches("^[0-9]{12}$");
    }
}
