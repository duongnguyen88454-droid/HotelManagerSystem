package com.mycompany.hotelmanagersystem.dao.auth;

import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.model.Account;
import com.mycompany.hotelmanagersystem.customer.model.Customer;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object phụ trách xác thực và quản lý tài khoản người dùng
 */
public class AccountDAO {

    /**
     * Xác thực thông tin đăng nhập:
     * - Đăng nhập bằng đúng EMAIL và MẬT KHẨU tồn tại trong bảng TAIKHOAN.
     * - Đồng bộ với CSDL chuẩn 3NF: TAIKHOAN có 6 thuộc tính (HoTenTaiKhoan, Email trực tiếp).
     * - Xác thực mật khẩu mã hóa SHA-256 (kèm Fallback cho mật khẩu seed '1234').
     */
    public UserSessionDTO checkLogin(String email, String password) {
        if (email == null || email.trim().isEmpty() || password == null) {
            return null;
        }

        String sql = "SELECT tk.MaTaiKhoan, tk.MatKhau, tk.MaVaiTro, vt.TenVaiTro, tk.TrangThai, "
                + "COALESCE(tk.HoTenTaiKhoan, N'Người Dùng') AS HoTen, "
                + "tk.Email, "
                + "COALESCE(kh.SoDT, nv.SoDienThoai, '') AS SoDT, "
                + "COALESCE(kh.MaKH, nv.MaNV, '') AS MaDinhDanh "
                + "FROM TAIKHOAN tk "
                + "JOIN VAITRO vt ON tk.MaVaiTro = vt.MaVaiTro "
                + "LEFT JOIN KHACHHANG kh ON tk.MaTaiKhoan = kh.MaTaiKhoan "
                + "LEFT JOIN NHANVIEN nv ON tk.MaTaiKhoan = nv.MaTaiKhoan "
                + "WHERE tk.Email = ?";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("MatKhau");
                    // Xác thực mật khẩu qua PasswordUtil (hỗ trợ hash SHA-256 và fallback seed)
                    if (PasswordUtil.verifyPassword(password, storedPassword)) {
                        return new UserSessionDTO(
                                rs.getString("MaTaiKhoan"),
                                rs.getString("Email"),
                                rs.getString("SoDT"),
                                rs.getString("MaVaiTro"),
                                rs.getString("TenVaiTro"),
                                rs.getString("HoTen"),
                                rs.getString("MaDinhDanh"),
                                rs.getString("TrangThai"));
                    }
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiểm tra Email đã tồn tại trong bảng TAIKHOAN chưa
     */
    public boolean checkEmailExists(String email) {
        String sql = "SELECT 1 FROM TAIKHOAN WHERE Email = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Kiểm tra Số điện thoại đã tồn tại trong CSDL chưa (bảng KHACHHANG hoặc NHANVIEN)
     */
    public boolean checkPhoneExists(String phone) {
        String sql = "SELECT 1 FROM KHACHHANG WHERE SoDT = ? UNION SELECT 1 FROM NHANVIEN WHERE SoDienThoai = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, phone);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Đăng ký tài khoản Web mới (CHỈ ghi vào TAIKHOAN với đúng 6 thuộc tính chuẩn, 
     * không can thiệp vào bảng KHACHHANG)
     */
    public boolean registerAccount(Account tk) {
        String sqlTaiKhoan = "INSERT INTO TAIKHOAN (MaTaiKhoan, MatKhau, MaVaiTro, TrangThai, HoTenTaiKhoan, Email) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement psTK = conn.prepareStatement(sqlTaiKhoan)) {
            psTK.setString(1, tk.getMaTaiKhoan());
            psTK.setString(2, tk.getMatKhau());
            psTK.setString(3, tk.getMaVaiTro() != null ? tk.getMaVaiTro() : "VT01");
            psTK.setString(4, tk.getTrangThai() != null ? tk.getTrangThai() : "Active");
            psTK.setString(5, tk.getHoTenTaiKhoan());
            psTK.setString(6, tk.getEmail());
            return psTK.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Tương thích ngược: Đăng ký tài khoản (chuyển tiếp sang registerAccount)
     */
    public boolean registerCustomer(Account tk, Customer kh) {
        if (tk.getHoTenTaiKhoan() == null && kh != null) {
            tk.setHoTenTaiKhoan(kh.getHoTen());
        }
        if (tk.getEmail() == null && kh != null) {
            tk.setEmail(kh.getEmail());
        }
        return registerAccount(tk);
    }

    public String getNextAccountIdFromDB() {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT dbo.fn_SinhMaTaiKhoan()");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "TK001";
    }
}
