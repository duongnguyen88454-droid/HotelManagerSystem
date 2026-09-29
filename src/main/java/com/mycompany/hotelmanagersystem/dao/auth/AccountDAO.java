package com.mycompany.hotelmanagersystem.dao.auth;

import com.mycompany.hotelmanagersystem.dto.auth.UserSessionDTO;
import com.mycompany.hotelmanagersystem.model.Account;
import com.mycompany.hotelmanagersystem.model.Customer;
import com.mycompany.hotelmanagersystem.util.DBContext;
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
     * Xác thực thông tin đăng nhập bằng EMAIL hoặc SỐ ĐIỆN THOẠI đã đăng ký
     * Hỗ trợ xác thực mật khẩu băm SHA-256 (kèm Fallback cho mật khẩu seed '1234')
     */
    public UserSessionDTO checkLogin(String loginIdentifier, String password) {
        String sql = "SELECT tk.MaTaiKhoan, tk.MatKhau, tk.MaVaiTro, vt.TenVaiTro, tk.TrangThai, "
                + "COALESCE(kh.HoTen, nv.HoTen, N'Người Dùng') AS HoTen, "
                + "COALESCE(kh.MaKH, nv.MaNV, '') AS MaDinhDanh, "
                + "COALESCE(kh.Email, nv.Email, tk.TenDangNhap) AS Email, "
                + "COALESCE(kh.SoDT, nv.SoDienThoai, '') AS SoDT "
                + "FROM TAIKHOAN tk "
                + "JOIN VAITRO vt ON tk.MaVaiTro = vt.MaVaiTro "
                + "LEFT JOIN KHACHHANG kh ON tk.MaTaiKhoan = kh.MaTaiKhoan "
                + "LEFT JOIN NHANVIEN nv ON tk.MaTaiKhoan = nv.MaTaiKhoan "
                + "WHERE (kh.Email = ? OR kh.SoDT = ? OR nv.Email = ? OR nv.SoDienThoai = ? OR tk.TenDangNhap = ?)";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            // Truyền định danh đăng nhập vào cả 5 vị trí: Email khách, SĐT khách, Email NV,
            // SĐT NV, Tên đăng nhập gốc
            ps.setString(1, loginIdentifier);
            ps.setString(2, loginIdentifier);
            ps.setString(3, loginIdentifier);
            ps.setString(4, loginIdentifier);
            ps.setString(5, loginIdentifier);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("MatKhau");
                    // Xác thực mật khẩu qua PasswordUtil (hỗ trợ hash SHA-256 và fallback)
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
     * Kiểm tra Email đã tồn tại trong CSDL chưa (bảng KHACHHANG hoặc TAIKHOAN)
     */
    public boolean checkEmailExists(String email) {
        String sql = "SELECT 1 FROM KHACHHANG WHERE Email = ? UNION SELECT 1 FROM TAIKHOAN WHERE TenDangNhap = ?";
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
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
     * Đăng ký tài khoản Khách hàng mới bằng Transaction ACID
     */
    public boolean registerCustomer(Account tk, Customer kh) {
        String sqlTaiKhoan = "INSERT INTO TAIKHOAN (MaTaiKhoan, TenDangNhap, MatKhau, MaVaiTro, TrangThai) "
                + "VALUES (?, ?, ?, ?, ?)";
        String sqlKhachHang = "INSERT INTO KHACHHANG (MaKH, MaTaiKhoan, HoTen, Email, SoDT, CCCD) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Chèn vào TAIKHOAN (TenDangNhap = Email)
            try (PreparedStatement psTK = conn.prepareStatement(sqlTaiKhoan)) {
                psTK.setString(1, tk.getMaTaiKhoan());
                psTK.setString(2, tk.getTenDangNhap());
                psTK.setString(3, tk.getMatKhau());
                psTK.setString(4, tk.getMaVaiTro());
                psTK.setString(5, tk.getTrangThai());
                psTK.executeUpdate();
            }

            // 2. Chèn vào KHACHHANG
            try (PreparedStatement psKH = conn.prepareStatement(sqlKhachHang)) {
                psKH.setString(1, kh.getMaKH());
                psKH.setString(2, kh.getMaTaiKhoan());
                psKH.setString(3, kh.getHoTen());
                psKH.setString(4, kh.getEmail());
                psKH.setString(5, kh.getSoDT());
                if (kh.getCccd() != null && !kh.getCccd().trim().isEmpty()) {
                    psKH.setString(6, kh.getCccd().trim());
                } else {
                    psKH.setNull(6, java.sql.Types.VARCHAR);
                }
                psKH.executeUpdate();
            }

            conn.commit(); // Thành công cả 2 bảng
            return true;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
