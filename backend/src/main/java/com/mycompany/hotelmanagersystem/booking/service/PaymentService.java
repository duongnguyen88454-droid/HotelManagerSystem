package com.mycompany.hotelmanagersystem.booking.service;

import com.mycompany.hotelmanagersystem.booking.dao.PaymentDAO;

/**
 * Dịch vụ xử lý nghiệp vụ thanh toán và đặt cọc cho đơn đặt phòng.
 */
public class PaymentService {

    private final PaymentDAO paymentDAO = new PaymentDAO();

    /**
     * Xác nhận thanh toán tiền cọc cho đơn booking.
     *
     * @param bookingId mã booking cần nộp cọc
     * @param paymentMethod phương thức thanh toán
     * @param note ghi chú thanh toán
     * @return mã giao dịch thanh toán PaymentId
     * @throws Exception nếu xảy ra lỗi nghiệp vụ hoặc hết hạn giữ chỗ
     */
    public String processDepositPayment(String bookingId, String paymentMethod, String note)
            throws Exception {
        if (bookingId == null || bookingId.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã đơn đặt phòng không hợp lệ!");
        }
        return paymentDAO.confirmDepositPaymentSP(bookingId.trim(), paymentMethod, note);
    }

    /**
     * Dọn dẹp các đơn đặt phòng quá hạn giữ chỗ chưa nộp cọc.
     */
    public void cleanExpiredBookings() {
        paymentDAO.cleanExpiredBookings();
    }
}
