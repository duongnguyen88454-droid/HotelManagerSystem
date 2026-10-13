package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.EmployeeItemDTO;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý hồ sơ nhân sự Employee và tài khoản Account cho Manager.
 */
public class ManagerEmployeeDAO extends DBContext {

    private static final String SELECT_EMPLOYEES_SQL =
            "SELECT e.EmployeeId, e.AccountId, acc.UserName, e.FullName, e.Phone, e.Email, "
                    + "ISNULL(acc.Role, 'Staff') AS Role, e.HireDate, e.ResignationDate, "
                    + "e.EmployeeStatus, ISNULL(acc.AccountStatus, 'Active') AS AccountStatus "
                    + "FROM Employee e "
                    + "LEFT JOIN Account acc ON e.AccountId = acc.AccountId "
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

    public List<EmployeeItemDTO> getAllEmployees() {
        List<EmployeeItemDTO> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_EMPLOYEES_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToDTO(rs));
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateEmployeeResignation(String employeeId, boolean isResigned) {
        try (Connection conn = getConnection()) {
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
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(UPDATE_CONTACT_SQL)) {
            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setString(4, employeeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
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
