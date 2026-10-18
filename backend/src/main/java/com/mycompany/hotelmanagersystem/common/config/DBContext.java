package com.mycompany.hotelmanagersystem.common.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Quản lý kết nối cơ sở dữ liệu (JDBC Connection) phân quyền thuần túy theo
 * Role (RBAC).
 * Bắt buộc mọi kết nối phải chỉ định vai trò nghiệp vụ (Manager, Receptionist,
 * Housekeeper, Customer).
 */
public class DBContext {

    private static String buildUrl() {
        String server = EnvConfig.get("DB_SERVER", "localhost");
        String port = EnvConfig.get("DB_PORT", "1433");
        String database = EnvConfig.get("DB_NAME", "QuanLyKhachSan");
        return String.format(
                "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=false;trustServerCertificate=true;characterEncoding=UTF-8;sendStringParametersAsUnicode=true",
                server, port, database);
    }

    public static Connection getConnection(String role) throws ClassNotFoundException, SQLException {
        if (role == null || role.trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Bảo mật RBAC: Vai trò (Role) bắt buộc phải được chỉ định khi mở kết nối CSDL!");
        }
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String roleName = role.trim().toUpperCase();
        String userKey = "DB_LOGIN_" + roleName;
        String passKey = "DB_PASS_" + roleName;

        String user = EnvConfig.get(userKey);
        String pass = EnvConfig.get(passKey);

        if (user.isEmpty() || pass.isEmpty()) {
            throw new IllegalArgumentException(
                    "Không tìm thấy cấu hình tài khoản CSDL trong .env cho vai trò: " + roleName);
        }

        return DriverManager.getConnection(buildUrl(), user, pass);
    }

    public static void closeConnection(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null && !rs.isClosed()) {
                rs.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
            if (ps != null && !ps.isClosed()) {
                ps.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
            if (conn != null && !conn.isClosed()) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
