package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.CreateEmployeeDTO;
import com.mycompany.hotelmanagersystem.manager.dto.EmployeeItemDTO;
import com.mycompany.hotelmanagersystem.manager.dto.UpdateEmployeeAccountDTO;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.time.LocalDate;
import java.util.List;

/**
 * DAO xử lý hồ sơ nhân sự Employee và tài khoản Account cho Manager.
 */
public class ManagerEmployeeDAO extends BaseRepository<EmployeeItemDTO, String> {

    private static final String SELECT_EMPLOYEES_SQL =
            "SELECT e.EmployeeId, e.AccountId, acc.UserName, e.FullName, e.Phone, e.Email, "
                    + "ISNULL(acc.Role, 'Staff') AS Role, e.HireDate, e.ResignationDate, "
                    + "e.EmployeeStatus, ISNULL(acc.AccountStatus, 'Active') AS AccountStatus "
                    + "FROM Employee e "
                    + "LEFT JOIN Account acc ON e.AccountId = acc.AccountId "
                    + "WHERE ISNULL(acc.Role, '') <> 'Manager' "
                    + "ORDER BY CASE WHEN e.EmployeeStatus = 'Working' THEN 1 ELSE 2 END, e.EmployeeId ASC";

    private static final String RESIGN_EMPLOYEE_SQL =
            "UPDATE Employee SET EmployeeStatus = 'Resigned', ResignationDate = CAST(GETDATE() AS DATE) "
                    + "WHERE EmployeeId = ?";

    private static final String REINSTATE_EMPLOYEE_SQL =
            "UPDATE Employee SET EmployeeStatus = 'Working', ResignationDate = NULL "
                    + "WHERE EmployeeId = ?";

    private static final String UNLOCK_ACCOUNT_SQL =
            "UPDATE Account SET AccountStatus = 'Active' "
                    + "WHERE AccountId = (SELECT AccountId FROM Employee WHERE EmployeeId = ?)";

    private static final String UPDATE_CONTACT_SQL =
            "UPDATE Employee SET FullName = ?, Phone = ?, Email = ? WHERE EmployeeId = ?";

    @Override
    protected String getTableName() {
        return "Employee";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "EmployeeId";
    }

    @Override
    protected RowMapper<EmployeeItemDTO> getRowMapper() {
        return this::mapRowToDTO;
    }

    @Override
    protected String getRole() {
        return "Manager";
    }

    public List<EmployeeItemDTO> getAllEmployees() {
        return query(SELECT_EMPLOYEES_SQL);
    }

    public boolean updateEmployeeResignation(String employeeId, boolean isResigned) {
        try (Connection conn = DBContext.getConnection(getRole())) {
            conn.setAutoCommit(false);
            if (isResigned) {
                try (PreparedStatement ps = conn.prepareStatement(RESIGN_EMPLOYEE_SQL)) {
                    ps.setString(1, employeeId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement psEmp = conn.prepareStatement(REINSTATE_EMPLOYEE_SQL);
                     PreparedStatement psAcc = conn.prepareStatement(UNLOCK_ACCOUNT_SQL)) {
                    psEmp.setString(1, employeeId);
                    psEmp.executeUpdate();
                    psAcc.setString(1, employeeId);
                    psAcc.executeUpdate();
                }
            }
            conn.commit();
            return true;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateEmployeeContact(String employeeId, String fullName, String phone, String email) {
        return executeUpdate(UPDATE_CONTACT_SQL, fullName, phone, email, employeeId) > 0;
    }

    public boolean createEmployeeWithAccount(CreateEmployeeDTO dto) {
        String callAccountSql = "{call dbo.sp_ThemTaiKhoan(?, ?, ?, ?, ?)}";
        String callEmployeeSql = "{call dbo.sp_ThemNhanVien(?, ?, ?, ?, NULL, ?)}";
        try (Connection conn = DBContext.getConnection(getRole())) {
            conn.setAutoCommit(false);
            String newAccountId;
            try (CallableStatement csAcc = conn.prepareCall(callAccountSql)) {
                csAcc.setString(1, dto.getEmail().trim());
                csAcc.setString(2, dto.getRole().trim());
                csAcc.setString(3, dto.getUserName().trim());
                csAcc.setString(4, dto.getPassword().trim());
                csAcc.registerOutParameter(5, Types.VARCHAR);
                csAcc.execute();
                newAccountId = csAcc.getString(5);
            }
            try (CallableStatement csEmp = conn.prepareCall(callEmployeeSql)) {
                csEmp.setString(1, newAccountId);
                csEmp.setString(2, dto.getFullName().trim());
                csEmp.setString(3, dto.getPhone().trim());
                csEmp.setString(4, dto.getEmail().trim());
                csEmp.registerOutParameter(5, Types.VARCHAR);
                csEmp.execute();
            }
            conn.commit();
            return true;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateEmployeeAccount(UpdateEmployeeAccountDTO dto) {
        String findAccSql = "SELECT AccountId FROM Employee WHERE EmployeeId = ?";
        String checkUserSql = "SELECT 1 FROM Account WHERE UserName = ? AND AccountId <> ?";
        String updateWithPassSql = "UPDATE Account SET UserName = ?, Password = ?, Role = ?, AccountStatus = ? WHERE AccountId = ?";
        String updateNoPassSql = "UPDATE Account SET UserName = ?, Role = ?, AccountStatus = ? WHERE AccountId = ?";

        try (Connection conn = DBContext.getConnection(getRole())) {
            String accountId = findAccountIdByEmpId(conn, findAccSql, dto.getEmployeeId());
            if (accountId == null) {
                return false;
            }
            if (isUserNameTaken(conn, checkUserSql, dto.getUserName(), accountId)) {
                return false;
            }
            return executeUpdateAccount(conn, updateWithPassSql, updateNoPassSql, dto, accountId);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private String findAccountIdByEmpId(Connection conn, String sql, String empId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, empId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("AccountId") : null;
            }
        }
    }

    private boolean isUserNameTaken(Connection conn, String sql, String userName, String accountId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userName);
            ps.setString(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean executeUpdateAccount(Connection conn, String sqlWithPass, String sqlNoPass,
                                         UpdateEmployeeAccountDTO dto, String accountId) throws SQLException {
        boolean hasNewPass = (dto.getNewPassword() != null && !dto.getNewPassword().trim().isEmpty());
        String sql = hasNewPass ? sqlWithPass : sqlNoPass;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dto.getUserName().trim());
            if (hasNewPass) {
                ps.setString(2, dto.getNewPassword().trim());
                ps.setString(3, dto.getRole());
                ps.setString(4, dto.getAccountStatus());
                ps.setString(5, accountId);
            } else {
                ps.setString(2, dto.getRole());
                ps.setString(3, dto.getAccountStatus());
                ps.setString(4, accountId);
            }
            return ps.executeUpdate() > 0;
        }
    }

    private EmployeeItemDTO mapRowToDTO(ResultSet rs) throws SQLException {
        Date hire = rs.getDate("HireDate");
        Date resign = rs.getDate("ResignationDate");
        LocalDate hireDate = (hire != null) ? hire.toLocalDate() : null;
        LocalDate resignDate = (resign != null) ? resign.toLocalDate() : null;

        return new EmployeeItemDTO(
                rs.getString("EmployeeId"),
                rs.getString("AccountId"),
                rs.getString("UserName"),
                rs.getNString("FullName"),
                rs.getString("Phone"),
                rs.getString("Email"),
                rs.getString("Role"),
                hireDate,
                resignDate,
                rs.getString("EmployeeStatus"),
                rs.getString("AccountStatus")
        );
    }
}

