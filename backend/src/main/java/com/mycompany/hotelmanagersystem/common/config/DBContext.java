package com.mycompany.hotelmanagersystem.common.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Quản lý kết nối cơ sở dữ liệu (JDBC Connection) phân quyền thuần túy theo Role (RBAC).
 * Bắt buộc mọi kết nối phải chỉ định vai trò nghiệp vụ (Manager, Receptionist, Housekeeper, Customer).
 */
public class DBContext {

    private static String buildUrl() {
        String server = EnvConfig.get("DB_SERVER", "localhost");
        String port = EnvConfig.get("DB_PORT", "1433");
        String database = EnvConfig.get("DB_NAME", "QuanLyKhachSan");
        return String.format(
                "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=false;trustServerCertificate=true;characterEncoding=UTF-8",
                server, port, database);
    }

    /**
     * Mở kết nối CSDL phân quyền thuần túy theo vai trò nghiệp vụ (RBAC).
     * BẮT BUỘC phải chỉ định vai trò hợp lệ, không cho phép dùng tài khoản mặc định.
     *
     * @param role Tên vai trò (Manager, Receptionist, Housekeeper, Customer)
     * @return Connection gắn liền với quyền hạn của vai trò đó trong SQL Server
     * @throws ClassNotFoundException nếu thiếu driver JDBC
     * @throws SQLException nếu kết nối thất bại
     */
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

    public static boolean testConnection(String role) {
        Connection conn = null;
        try {
            conn = getConnection(role);
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            System.err.println("Lỗi kết nối [" + role + "]: " + e.getMessage());
            return false;
        } finally {
            closeConnection(conn, null, null);
        }
    }

    public static void main(String[] args) {
        String dbName = EnvConfig.get("DB_NAME", "QuanLyKhachSan");
        System.out.println("===============================================================");
        System.out.println("   KIỂM TRA HỆ THỐNG PHÂN QUYỀN CSDL THUẦN TÚY (PURE RBAC)     ");
        System.out.println("   Cơ sở dữ liệu đích: " + dbName);
        System.out.println("===============================================================");

        String[] roles = {"Manager", "Receptionist", "Housekeeper", "Customer"};

        for (String r : roles) {
            boolean ok = testConnection(r);
            String status = ok ? "[THÀNH CÔNG]" : "[THẤT BẠI]";
            System.out.printf("Vai trò: %-15s -> %s%n", r, status);
        }
        System.out.println("===============================================================");
    }
}
