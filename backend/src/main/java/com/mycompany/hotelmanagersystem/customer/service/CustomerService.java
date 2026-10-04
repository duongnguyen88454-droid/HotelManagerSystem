package com.mycompany.hotelmanagersystem.customer.service;

import com.mycompany.hotelmanagersystem.customer.dao.CustomerDAO;
import com.mycompany.hotelmanagersystem.customer.model.Customer;

/**
 * Service chuyên trách quản lý nghiệp vụ hồ sơ khách hàng lưu trú (KHACHHANG)
 * Đảm bảo nguyên lý phân tầng: Controller không gọi trực tiếp CustomerDAO
 */
public class CustomerService {

    private final CustomerDAO customerDAO;

    public CustomerService() {
        this.customerDAO = new CustomerDAO();
    }

    public CustomerService(CustomerDAO customerDAO) {
        this.customerDAO = customerDAO;
    }

    /**
     * Tra cứu hồ sơ khách hàng theo số Căn Cước Công Dân (CCCD 12 chữ số)
     */
    public Customer findCustomerByCCCD(String cccd) {
        if (cccd == null || cccd.trim().isEmpty()) {
            return null;
        }
        return customerDAO.findCustomerByCCCD(cccd.trim());
    }

    /**
     * Lấy hồ sơ khách hàng theo mã định danh MaKH
     */
    public Customer getCustomerByMaKH(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) {
            return null;
        }
        return customerDAO.getCustomerByMaKH(maKH.trim());
    }

    /**
     * Đồng bộ hoặc tạo mới hồ sơ khách hàng lưu trú dựa theo CCCD.
     * Ai đặt phòng (MaTaiKhoan) được ghi nhận riêng tại BOOKING, không lưu trong KHACHHANG.
     */
    public String findOrUpsertGuestByCCCD(String hoTen, String email, String soDT, String cccd)
            throws Exception {
        if (hoTen == null || hoTen.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || soDT == null || soDT.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên, Email và Số điện thoại của người lưu trú không được để trống!");
        }

        if (cccd == null || !cccd.trim().matches("^[0-9]{12}$")) {
            throw new IllegalArgumentException("Số Căn Cước Công Dân (CCCD) không hợp lệ (phải gồm đúng 12 chữ số)!");
        }

        return customerDAO.findOrUpsertGuestByCCCD(hoTen.trim(), email.trim(), soDT.trim(), cccd.trim());
    }
}
