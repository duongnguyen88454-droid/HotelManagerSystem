package com.mycompany.hotelmanagersystem.auth.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Tiện ích băm và xác thực mật khẩu sử dụng thuật toán SHA-256.
 * Đảm bảo an toàn một chiều, không lưu mật khẩu thô và hỗ trợ tương thích ngược.
 */
public class PasswordUtil {

    /**
     * Băm mật khẩu thô bằng thuật toán SHA-256
     * @param plainPassword Mật khẩu thô do người dùng nhập
     * @return Chuỗi Hex băm 64 ký tự (chữ thường)
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Lỗi hệ thống: Thuật toán SHA-256 không khả dụng.", e);
        }
    }

    /**
     * Xác thực mật khẩu: So sánh mật khẩu thô nhập vào với mật khẩu trong DB.
     * Hỗ trợ tương thích ngược cho dữ liệu seed ban đầu (như '1234').
     * @param plainPassword Mật khẩu thô người dùng vừa nhập
     * @param storedPassword Mật khẩu (chuỗi hash hoặc thô) lưu trong DB
     * @return true nếu mật khẩu khớp, false nếu sai
     */
    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) {
            return false;
        }
        // 1. So khớp sau khi băm SHA-256
        String hashedInput = hashPassword(plainPassword);
        if (hashedInput.equalsIgnoreCase(storedPassword)) {
            return true;
        }
        // 2. Cơ chế Fallback tương thích ngược: nếu tài khoản trong DB chưa cập nhật hash (vẫn là chuỗi thô như '1234')
        return plainPassword.equals(storedPassword);
    }
}
