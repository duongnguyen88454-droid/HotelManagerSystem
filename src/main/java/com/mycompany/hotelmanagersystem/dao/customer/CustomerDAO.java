package com.mycompany.hotelmanagersystem.dao.customer;

import com.mycompany.hotelmanagersystem.model.Customer;
import com.mycompany.hotelmanagersystem.util.DBContext;
import com.mycompany.hotelmanagersystem.util.KeyGenerator;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object chuyên trách quản lý Hồ Sơ Khách Hàng Lưu Trú (KHACHHANG)
 * Phục vụ nghiệp vụ đối chiếu CCCD (12 chữ số) khi đặt phòng và check-in tại quầy
 */
public class CustomerDAO {

    /**
     * Tra cứu hồ sơ khách hàng theo số Căn Cước Công Dân (CCCD)
     */
    public Customer findCustomerByCCCD(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT MaKH, MaTaiKhoan, HoTen, Email, SoDT, CCCD FROM KHACHHANG WHERE CCCD = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cccd.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getString("MaKH"),
                            rs.getString("MaTaiKhoan"),
                            rs.getNString("HoTen"),
                            rs.getString("Email"),
                            rs.getString("SoDT"),
                            rs.getString("CCCD")
                    );
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy hồ sơ khách hàng theo mã MaKH
     */
    public Customer getCustomerByMaKH(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT MaKH, MaTaiKhoan, HoTen, Email, SoDT, CCCD FROM KHACHHANG WHERE MaKH = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKH.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getString("MaKH"),
                            rs.getString("MaTaiKhoan"),
                            rs.getNString("HoTen"),
                            rs.getString("Email"),
                            rs.getString("SoDT"),
                            rs.getString("CCCD")
                    );
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tra cứu hồ sơ khách hàng lưu trú theo mã tài khoản hoặc email đăng nhập
     * Phục vụ tự động điền (Autofill) thông tin khách lưu trú (Họ tên, SĐT, Email, CCCD)
     */
    public Customer getGuestProfileByAccount(String maTaiKhoan, String email) {
        if ((maTaiKhoan == null || maTaiKhoan.trim().isEmpty()) && (email == null || email.trim().isEmpty())) {
            return null;
        }

        String sql = "SELECT TOP 1 MaKH, MaTaiKhoan, HoTen, Email, SoDT, CCCD FROM KHACHHANG "
                + "WHERE (MaTaiKhoan IS NOT NULL AND MaTaiKhoan = ?) OR Email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, (maTaiKhoan != null) ? maTaiKhoan.trim() : "");
            ps.setString(2, (email != null) ? email.trim() : "");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getString("MaKH"),
                            rs.getString("MaTaiKhoan"),
                            rs.getNString("HoTen"),
                            rs.getString("Email"),
                            rs.getString("SoDT"),
                            rs.getString("CCCD")
                    );
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thuật toán cốt lõi: Tìm kiếm hoặc Cập nhật / Tạo mới hồ sơ lưu trú theo CCCD
     */
    public String findOrUpsertGuestByCCCD(String hoTen, String email, String soDT, String cccd) throws Exception {
        return findOrUpsertGuestByCCCD(hoTen, email, soDT, cccd, null);
    }

    /**
     * Thuật toán cốt lõi: Tìm kiếm hoặc Cập nhật / Tạo mới hồ sơ lưu trú theo CCCD và liên kết tài khoản
     * - Nếu CCCD đã có: cập nhật Họ tên, SĐT, Email và liên kết MaTaiKhoan nếu chưa có
     * - Nếu CCCD chưa có: sinh MaKH mới và INSERT vào KHACHHANG kèm MaTaiKhoan
     */
    public String findOrUpsertGuestByCCCD(String hoTen, String email, String soDT, String cccd, String maTaiKhoan) throws Exception {
        if (hoTen == null || hoTen.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên người lưu trú không được để trống!");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Địa chỉ Email của người lưu trú không được để trống!");
        }
        if (soDT == null || soDT.trim().isEmpty()) {
            throw new IllegalArgumentException("Số điện thoại liên lạc không được để trống!");
        }

        String cleanCCCD = (cccd != null) ? cccd.trim() : "";
        if (cleanCCCD.isEmpty()) {
            throw new IllegalArgumentException("Số Căn Cước Công Dân (CCCD 12 chữ số) là bắt buộc khi đặt phòng!");
        }
        if (!cleanCCCD.matches("^[0-9]{12}$")) {
            throw new IllegalArgumentException("Số CCCD không đúng quy chuẩn (bắt buộc gồm 12 chữ số)!");
        }

        String cleanMaTaiKhoan = (maTaiKhoan != null && !maTaiKhoan.trim().isEmpty()) ? maTaiKhoan.trim() : null;

        Customer existing = findCustomerByCCCD(cleanCCCD);
        if (existing != null) {
            // CCCD đã có trong hệ thống -> Kiểm tra xem SĐT, Email hoặc Họ tên có thay đổi không
            boolean needUpdate = false;
            String newName = hoTen.trim();
            String newEmail = email.trim();
            String newPhone = soDT.trim();

            if (!newName.equalsIgnoreCase(existing.getHoTen()) ||
                !newEmail.equalsIgnoreCase(existing.getEmail()) ||
                !newPhone.equalsIgnoreCase(existing.getSoDT()) ||
                (existing.getMaTaiKhoan() == null && cleanMaTaiKhoan != null)) {
                needUpdate = true;
            }

            if (needUpdate) {
                String updateSql = "UPDATE KHACHHANG SET HoTen = ?, Email = ?, SoDT = ?, "
                        + "MaTaiKhoan = COALESCE(MaTaiKhoan, ?) WHERE CCCD = ?";
                try (Connection conn = DBContext.getConnection();
                     PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setNString(1, newName);
                    ps.setString(2, newEmail);
                    ps.setString(3, newPhone);
                    ps.setString(4, cleanMaTaiKhoan);
                    ps.setString(5, cleanCCCD);
                    ps.executeUpdate();
                } catch (SQLException | ClassNotFoundException e) {
                    // Nếu lỗi do ràng buộc MaTaiKhoan đã gán cho khách khác, fallback cập nhật không có MaTaiKhoan
                    String fallbackUpdate = "UPDATE KHACHHANG SET HoTen = ?, Email = ?, SoDT = ? WHERE CCCD = ?";
                    try (Connection conn = DBContext.getConnection();
                         PreparedStatement ps = conn.prepareStatement(fallbackUpdate)) {
                        ps.setNString(1, newName);
                        ps.setString(2, newEmail);
                        ps.setString(3, newPhone);
                        ps.setString(4, cleanCCCD);
                        ps.executeUpdate();
                    } catch (Exception ignored) {
                    }
                }
            }
            return existing.getMaKH();
        }

        // CCCD chưa có trong hệ thống -> Tạo hồ sơ khách hàng mới
        String newMaKH = KeyGenerator.generateCustomerId();
        String insertSql = "INSERT INTO KHACHHANG (MaKH, HoTen, Email, SoDT, CCCD, MaTaiKhoan) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, newMaKH);
            ps.setNString(2, hoTen.trim());
            ps.setString(3, email.trim());
            ps.setString(4, soDT.trim());
            ps.setString(5, cleanCCCD);
            ps.setString(6, cleanMaTaiKhoan);
            ps.executeUpdate();
            return newMaKH;
        } catch (SQLException | ClassNotFoundException e) {
            // Trường hợp lỗi (ví dụ MaTaiKhoan đã liên kết hoặc trùng SĐT/Email cũ):
            try (Connection conn = DBContext.getConnection()) {
                // Fallback 1: Thử chèn với MaTaiKhoan = NULL
                String insertNullSql = "INSERT INTO KHACHHANG (MaKH, HoTen, Email, SoDT, CCCD, MaTaiKhoan) VALUES (?, ?, ?, ?, ?, NULL)";
                try (PreparedStatement psNull = conn.prepareStatement(insertNullSql)) {
                    psNull.setString(1, newMaKH);
                    psNull.setNString(2, hoTen.trim());
                    psNull.setString(3, email.trim());
                    psNull.setString(4, soDT.trim());
                    psNull.setString(5, cleanCCCD);
                    psNull.executeUpdate();
                    return newMaKH;
                } catch (SQLException insertErr) {
                    // Fallback 2: Nếu trùng SĐT hoặc Email của hồ sơ cũ khác -> tra cứu để tái sử dụng
                    String fallbackSql = "SELECT MaKH FROM KHACHHANG WHERE SoDT = ? OR Email = ?";
                    try (PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                        ps.setString(1, soDT.trim());
                        ps.setString(2, email.trim());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                String matchedMaKH = rs.getString("MaKH");
                                String updateCccdSql = "UPDATE KHACHHANG SET CCCD = ?, HoTen = ?, Email = ?, SoDT = ? WHERE MaKH = ?";
                                try (PreparedStatement psUp = conn.prepareStatement(updateCccdSql)) {
                                    psUp.setString(1, cleanCCCD);
                                    psUp.setNString(2, hoTen.trim());
                                    psUp.setString(3, email.trim());
                                    psUp.setString(4, soDT.trim());
                                    psUp.setString(5, matchedMaKH);
                                    psUp.executeUpdate();
                                }
                                return matchedMaKH;
                            }
                        }
                    }
                }
            } catch (Exception exFallback) {
                exFallback.printStackTrace();
            }
            throw new Exception("Lỗi ghi nhận hồ sơ khách lưu trú: " + e.getMessage());
        }
    }
}
