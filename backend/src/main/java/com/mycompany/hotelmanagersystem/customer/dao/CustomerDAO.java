package com.mycompany.hotelmanagersystem.customer.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.customer.model.Customer;

import java.sql.Connection;

/**
 * Data Access Object chuyên trách quản lý Hồ Sơ Khách Hàng Lưu Trú (Customer)
 * Phục vụ nghiệp vụ đối chiếu CCCD (12 chữ số) khi đặt phòng và check-in tại quầy
 */
public class CustomerDAO extends BaseRepository<Customer, String> {

    @Override
    protected String getTableName() {
        return "Customer";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "CustomerId";
    }

    @Override
    protected RowMapper<Customer> getRowMapper() {
        return rs -> new Customer(
                rs.getString("CustomerId"),
                rs.getNString("FullName"),
                rs.getString("Email"),
                rs.getString("PhoneNumber"),
                rs.getString("CCCD")
        );
    }

    @Override
    protected String getRole() {
        return "Customer";
    }

    public Customer findCustomerByCCCD(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM Customer WHERE CCCD = ?";
        return queryOne(sql, cccd.trim()).orElse(null);
    }

    public Customer getCustomerByMaKH(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) {
            return null;
        }
        return findById(maKH.trim()).orElse(null);
    }

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
        executeUpdate(updateSql, name, email, phone, cleanCCCD);
    }

    private String insertNewGuestWithFallback(String hoTen, String email, String soDT, String cleanCCCD) throws Exception {
        String insertSql = "INSERT INTO Customer (CustomerId, FullName, Email, PhoneNumber, CCCD) VALUES (?, ?, ?, ?, ?)";
        String newMaKH = getNextCustomerIdFromDB(null);
        try {
            executeUpdate(insertSql, newMaKH, hoTen, email, soDT, cleanCCCD);
            return newMaKH;
        } catch (Exception e) {
            String fallbackMaKH = fallbackLinkByContact(hoTen, email, soDT, cleanCCCD);
            if (fallbackMaKH != null) {
                return fallbackMaKH;
            }
            throw new Exception("Lỗi ghi nhận hồ sơ khách lưu trú: " + e.getMessage(), e);
        }
    }

    private String fallbackLinkByContact(String hoTen, String email, String soDT, String cleanCCCD) {
        String fallbackSql = "SELECT CustomerId FROM Customer WHERE PhoneNumber = ? OR Email = ?";
        String matchedMaKH = queryScalarString(fallbackSql, soDT, email);
        if (matchedMaKH != null) {
            updateGuestProfileByMaKH(matchedMaKH, cleanCCCD, hoTen, email, soDT);
            return matchedMaKH;
        }
        return null;
    }

    private void updateGuestProfileByMaKH(String maKH, String cccd, String hoTen, String email, String soDT) {
        String sql = "UPDATE Customer SET CCCD = ?, FullName = ?, Email = ?, PhoneNumber = ? WHERE CustomerId = ?";
        executeUpdate(sql, cccd, hoTen, email, soDT, maKH);
    }

    public String getNextCustomerIdFromDB(Connection conn) {
        String nextId = queryScalarString("SELECT dbo.fn_SinhMaCustomer()");
        return nextId != null ? nextId : "CUS001";
    }
}

