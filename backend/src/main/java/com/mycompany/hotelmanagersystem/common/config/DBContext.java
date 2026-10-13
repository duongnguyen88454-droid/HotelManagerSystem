package com.mycompany.hotelmanagersystem.common.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DBContext {

    private static final String SERVER_NAME = "localhost";
    private static final String PORT_NUMBER = "1433";
    private static final String DATABASE_NAME = "QuanLyKhachSan";
    private static final String USER_NAME = "sa";
    private static final String PASSWORD = "1234";

    public static Connection getConnection() throws ClassNotFoundException, SQLException {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        // Chuỗi kết nối JDBC với cấu hình bảo mật và UTF-8
        String url = String.format(
                "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=false;trustServerCertificate=true;characterEncoding=UTF-8",
                SERVER_NAME, PORT_NUMBER, DATABASE_NAME);

        return DriverManager.getConnection(url, USER_NAME, PASSWORD);
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

    public static boolean testConnection() {
        Connection conn = null;
        try {
            conn = getConnection();
            return conn != null && !conn.isClosed();
        } catch (Exception e) {
            System.err.println("Lỗi kiểm tra kết nối Database: " + e.getMessage());
            return false;
        } finally {
            closeConnection(conn, null, null);
        }
    }

    public static void main(String[] args) {
        System.out.println("--- ĐANG THỬ KẾT NỐI TỚI DATABASE: " + DATABASE_NAME + " ---");
        if (testConnection()) {
            System.out.println("=> KẾT NỐI THÀNH CÔNG VỚI DATABASE QuanLyKhachSan!");
        } else {
            System.out.println(
                    "=> KẾT NỐI THẤT BẠI! Vui lòng kiểm tra lại SQL Server Service, cổng 1433 và tài khoản sa.");
        }
    }
}
