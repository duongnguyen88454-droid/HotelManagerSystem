package com.mycompany.hotelmanagersystem.service.auth;

import com.mycompany.hotelmanagersystem.dao.auth.AccountDAO;
import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.model.Customer;
import com.mycompany.hotelmanagersystem.model.Account;
import com.mycompany.hotelmanagersystem.util.PasswordUtil;

public class AuthService {
    private final AccountDAO accountDAO;

    public AuthService() {
        this.accountDAO = new AccountDAO();
    }

    /**
     * Xác thực đăng nhập bằng đúng Email và Mật khẩu trong bảng TAIKHOAN
     */
    public UserSessionDTO login(String email, String password) throws Exception {
        if (email == null || email.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập Email.");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập mật khẩu.");
        }

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
     * Đăng ký tài khoản Web Khách hàng mới online (Chỉ ghi vào bảng TAIKHOAN với đúng 6 thuộc tính chuẩn;
     * Hoàn toàn không ghi vào bảng KHACHHANG, không bắt buộc SĐT lúc tạo tài khoản).
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
            throw new Exception("Email này đã được sử dụng để đăng ký tài khoản. Vui lòng đăng nhập hoặc chọn email khác.");
        }

        // Tự sinh mã tài khoản bằng SQL Server Function fn_SinhMaTaiKhoan
        String maTaiKhoan = accountDAO.getNextAccountIdFromDB();

        // Băm mật khẩu bằng thuật toán SHA-256 trước khi lưu vào CSDL
        String hashedPassword = PasswordUtil.hashPassword(password);

        // Lưu tài khoản chuẩn đúng 6 thuộc tính vào bảng TAIKHOAN:
        // MaTaiKhoan, MatKhau, MaVaiTro, TrangThai, HoTenTaiKhoan, Email
        Account tk = new Account(maTaiKhoan, hashedPassword, "VT01", "Active", hoTen.trim(), email.trim());

        return accountDAO.registerAccount(tk);
    }

    /**
     * Tương thích ngược: Đăng ký tài khoản (bỏ qua soDT vì TAIKHOAN chỉ lưu 6 thuộc tính chuẩn)
     */
    public boolean register(String hoTen, String email, String soDT, String password, String confirmPassword)
            throws Exception {
        return register(hoTen, email, password, confirmPassword);
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
