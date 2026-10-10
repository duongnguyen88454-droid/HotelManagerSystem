package com.mycompany.hotelmanagersystem.customer.dao;

import com.mycompany.hotelmanagersystem.customer.model.Customer;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object chuyên trách quản lý Hồ Sơ Khách Hàng Lưu Trú (KHACHHANG)
 * Phục vụ nghiệp vụ đối chiếu CCCD (12 chữ số) khi đặt phòng và check-in tại quầy
 *
 * Lưu ý thiết kế: KHACHHANG không còn liên kết MaTaiKhoan.
 * Việc ai đặt phòng (tài khoản) được ghi nhận tại bảng BOOKING.MaTaiKhoan.
 */
public class CustomerDAO {

    /**
     * Tra cứu hồ sơ khách hàng theo số Căn Cước Công Dân (CCCD)
     */
    public Customer findCustomerByCCCD(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return null;
        }

        String sql = "SELECT CustomerId AS MaKH, FullName AS HoTen, Email, PhoneNumber AS SoDT, CCCD FROM Customer WHERE CCCD = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cccd.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getString("MaKH"),
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

        String sql = "SELECT CustomerId AS MaKH, FullName AS HoTen, Email, PhoneNumber AS SoDT, CCCD FROM Customer WHERE CustomerId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maKH.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Customer(
                            rs.getString("MaKH"),
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
     * - Nếu CCCD đã có: cập nhật Họ tên, SĐT, Email nếu có thay đổi
     * - Nếu CCCD chưa có: sinh MaKH mới và INSERT vào KHACHHANG
     *
     * Lưu ý: MaTaiKhoan (ai đặt) được lưu tại BOOKING, không còn trong KHACHHANG
     */
    public String findOrUpsertGuestByCCCD(String hoTen, String email, String soDT, String cccd) throws Exception {
        validateGuestInput(hoTen, email, soDT, cccd);
        String cleanCCCD = cccd.trim();

        Customer existing = findCustomerByCCCD(cleanCCCD);
        if (existing != null) {
            updateExistingGuestIfNeeded(existing, cleanCCCD, hoTen.trim(), email.trim(), soDT.trim());
            return existing.getMaKH();
        }

        return insertNewGuestWithFallback(hoTen.trim(), email.trim(), soDT.trim(), cleanCCCD);
    }

    private void validateGuestInput(String hoTen, String email, String soDT, String cccd) {
        if (hoTen == null || hoTen.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên người lưu trú không được để trống!");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Địa chỉ Email của người lưu trú không được để trống!");
        }
        if (soDT == null || soDT.trim().isEmpty()) {
            throw new IllegalArgumentException("Số điện thoại liên lạc không được để trống!");
        }
        if (cccd == null || !cccd.trim().matches("^[0-9]{12}$")) {
            throw new IllegalArgumentException("Số CCCD không đúng quy chuẩn (bắt buộc gồm 12 chữ số)!");
        }
    }

    private void updateExistingGuestIfNeeded(Customer existing, String cleanCCCD, String name, String email, String phone) {
        boolean needUpdate = !name.equalsIgnoreCase(existing.getHoTen())
                || !email.equalsIgnoreCase(existing.getEmail())
                || !phone.equalsIgnoreCase(existing.getSoDT());

        if (!needUpdate) {
            return;
        }

        String updateSql = "UPDATE Customer SET FullName = ?, Email = ?, PhoneNumber = ? WHERE CCCD = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {
            ps.setNString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, cleanCCCD);
            ps.executeUpdate();
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private String insertNewGuestWithFallback(String hoTen, String email, String soDT, String cleanCCCD) throws Exception {
        String insertSql = "INSERT INTO Customer (CustomerId, FullName, Email, PhoneNumber, CCCD) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection()) {
            String newMaKH = getNextCustomerIdFromDB(conn);
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setString(1, newMaKH);
                ps.setNString(2, hoTen);
                ps.setString(3, email);
                ps.setString(4, soDT);
                ps.setString(5, cleanCCCD);
                ps.executeUpdate();
                return newMaKH;
            }
        } catch (SQLException | ClassNotFoundException e) {
            String fallbackMaKH = fallbackLinkByContact(hoTen, email, soDT, cleanCCCD);
            if (fallbackMaKH != null) {
                return fallbackMaKH;
            }
            throw new Exception("Lỗi ghi nhận hồ sơ khách lưu trú: " + e.getMessage());
        }
    }

    private String fallbackLinkByContact(String hoTen, String email, String soDT, String cleanCCCD) {
        String fallbackSql = "SELECT CustomerId AS MaKH FROM Customer WHERE PhoneNumber = ? OR Email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
            ps.setString(1, soDT);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String matchedMaKH = rs.getString("MaKH");
                    updateGuestProfileByMaKH(conn, matchedMaKH, cleanCCCD, hoTen, email, soDT);
                    return matchedMaKH;
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    private void updateGuestProfileByMaKH(Connection conn, String maKH, String cccd, String hoTen, String email, String soDT)
            throws SQLException {
        String sql = "UPDATE Customer SET CCCD = ?, FullName = ?, Email = ?, PhoneNumber = ? WHERE CustomerId = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cccd);
            ps.setNString(2, hoTen);
            ps.setString(3, email);
            ps.setString(4, soDT);
            ps.setString(5, maKH);
            ps.executeUpdate();
        }
    }

    public String getNextCustomerIdFromDB(Connection conn) {
        try (PreparedStatement ps = conn.prepareStatement("SELECT dbo.fn_SinhMaCustomer()");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getString(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "CUS001";
    }
}
