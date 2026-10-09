package com.mycompany.hotelmanagersystem.auth.dao;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.auth.model.Account;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.auth.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object phụ trách xác thực và quản lý tài khoản người dùng
 * Đồng bộ chuẩn 3NF: Bảng Account, Employee và Function dbo.fn_SinhMaAccount()
 */
public class AccountDAO {
    public UserSessionDTO checkLogin(String identifier, String password) {
        if (identifier == null || identifier.trim().isEmpty() || password == null) {
            return null;
        }

        String sql = "SELECT acc.AccountId, acc.Password, acc.Role, acc.AccountStatus, "
                + "acc.Email, acc.UserName, "
                + "emp.FullName AS EmpFullName, emp.Phone AS EmpPhone, emp.EmployeeId "
                + "FROM Account acc "
                + "LEFT JOIN Employee emp ON acc.AccountId = emp.AccountId "
                + "WHERE acc.Email = ? OR acc.UserName = ?";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            String cleanIdentifier = identifier.trim();
            ps.setString(1, cleanIdentifier);
            ps.setString(2, cleanIdentifier);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("Password");
                    if (PasswordUtil.verifyPassword(password, storedPassword)) {
                        String role = rs.getString("Role");

                        // Nếu là nhân viên thì lấy tên nhân viên, khách thì lấy UserName
                        String empName = rs.getString("EmpFullName");
                        String displayName = (empName != null && !empName.trim().isEmpty())
                                ? empName
                                : rs.getString("UserName");

                        String phone = rs.getString("EmpPhone") != null ? rs.getString("EmpPhone") : "";
                        String identifierCode = rs.getString("EmployeeId") != null ? rs.getString("EmployeeId") : "";

                        return new UserSessionDTO(
                                rs.getString("AccountId"),
                                rs.getString("Email"),
                                phone,
                                role,
                                displayName,
                                identifierCode,
                                rs.getString("AccountStatus"));
                    }
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra Email đã tồn tại trong bảng Account chưa
     */
    public boolean checkEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM Account WHERE Email = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đăng ký tài khoản mới vào bảng Account (6 cột chuẩn)
     */
    public boolean registerAccount(Account tk) {
        if (tk == null || tk.getEmail() == null || tk.getMatKhau() == null) {
            return false;
        }

        String sqlAccount = "INSERT INTO Account (AccountId, Email, Role, UserName, Password, AccountStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sqlAccount)) {
            ps.setString(1, tk.getMaTaiKhoan());
            ps.setString(2, tk.getEmail());
            ps.setString(3, tk.getRole() != null ? tk.getRole() : "Customer");
            ps.setString(4, resolveUserName(tk));
            ps.setString(5, tk.getMatKhau());
            ps.setString(6, tk.getTrangThai() != null ? tk.getTrangThai() : "Active");
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy mã tài khoản kế tiếp qua UDF fn_SinhMaAccount trong CSDL
     */
    public String getNextAccountIdFromDB() {
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT dbo.fn_SinhMaAccount()");
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "ACC999";
    }

    private String resolveUserName(Account tk) {
        if (tk.getTenDangNhap() != null && !tk.getTenDangNhap().trim().isEmpty()
                && !tk.getTenDangNhap().contains("@")) {
            return tk.getTenDangNhap().trim();
        }
        if (tk.getEmail() != null && tk.getEmail().contains("@")) {
            return tk.getEmail().substring(0, tk.getEmail().indexOf('@')).trim();
        }
        return tk.getMaTaiKhoan();
    }
}
