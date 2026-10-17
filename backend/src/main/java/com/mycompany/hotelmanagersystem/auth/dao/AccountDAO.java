package com.mycompany.hotelmanagersystem.auth.dao;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.auth.model.Account;
import com.mycompany.hotelmanagersystem.auth.util.PasswordUtil;
import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;

import java.util.Optional;

/**
 * Data Access Object phụ trách xác thực và quản lý tài khoản người dùng
 * Kế thừa BaseRepository để chuẩn hóa truy vấn và tự quản lý kết nối.
 */
public class AccountDAO extends BaseRepository<Account, String> {

    @Override
    protected String getTableName() {
        return "Account";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "AccountId";
    }

    @Override
    protected RowMapper<Account> getRowMapper() {
        return rs -> new Account(
                rs.getString("AccountId"),
                rs.getString("Email"),
                rs.getString("Role"),
                rs.getString("UserName"),
                rs.getString("Password"),
                rs.getString("AccountStatus")
        );
    }

    @Override
    protected String getRole() {
        return "Manager";
    }

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

        String cleanIdentifier = identifier.trim();
        RowMapper<UserSessionDTO> mapper = rs -> {
            String storedPassword = rs.getString("Password");
            if (PasswordUtil.verifyPassword(password, storedPassword)) {
                String role = rs.getString("Role");
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
            return null;
        };

        Optional<UserSessionDTO> userOpt = queryOneCustom(sql, mapper, cleanIdentifier, cleanIdentifier);
        return userOpt.orElse(null);
    }

    public boolean checkEmailExists(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return exists("Email = ?", email.trim());
    }

    public boolean registerAccount(Account tk) {
        if (tk == null || tk.getEmail() == null || tk.getMatKhau() == null) {
            return false;
        }

        String sqlAccount = "INSERT INTO Account (AccountId, Email, Role, UserName, Password, AccountStatus) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        String role = tk.getRole() != null ? tk.getRole() : "Customer";
        String userName = resolveUserName(tk);
        String status = tk.getTrangThai() != null ? tk.getTrangThai() : "Active";

        return executeUpdate(sqlAccount, tk.getMaTaiKhoan(), tk.getEmail(), role, userName, tk.getMatKhau(), status) > 0;
    }

    public String getNextAccountIdFromDB() {
        String nextId = queryScalarString("SELECT dbo.fn_SinhMaAccount()");
        return nextId != null ? nextId : "ACC999";
    }

    private String resolveUserName(Account tk) {
        if (tk.getHoTen() != null && !tk.getHoTen().trim().isEmpty()) {
            return tk.getHoTen().trim();
        }
        if (tk.getEmail() != null && tk.getEmail().contains("@")) {
            return tk.getEmail().substring(0, tk.getEmail().indexOf('@')).trim();
        }
        return tk.getMaTaiKhoan();
    }
}

