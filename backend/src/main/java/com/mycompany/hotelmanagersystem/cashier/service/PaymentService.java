package com.mycompany.hotelmanagersystem.cashier.service;

import com.mycompany.hotelmanagersystem.cashier.dao.CheckOutDAO;
import com.mycompany.hotelmanagersystem.cashier.dao.InvoiceDAO;
import com.mycompany.hotelmanagersystem.cashier.dao.PaymentDAO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceDetailDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.PaymentRecordDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.PaymentResultDTO;

import java.util.Collections;
import java.util.List;

/**
 * Service xử lý các giao dịch thanh toán và đối soát công nợ hóa đơn.
 */
public class PaymentService {

    private final PaymentDAO paymentDAO;
    private final InvoiceDAO invoiceDAO;
    private final CheckOutDAO checkOutDAO;

    public PaymentService() {
        this.paymentDAO = new PaymentDAO();
        this.invoiceDAO = new InvoiceDAO();
        this.checkOutDAO = new CheckOutDAO();
    }

    public PaymentService(PaymentDAO paymentDAO, InvoiceDAO invoiceDAO, CheckOutDAO checkOutDAO) {
        this.paymentDAO = paymentDAO;
        this.invoiceDAO = invoiceDAO;
        this.checkOutDAO = checkOutDAO;
    }

    /**
     * Thực hiện thanh toán / nạp tiền vào hóa đơn.
     */
    public PaymentResultDTO processPayment(String maHoaDon, String maNV, double soTien, String phuongThuc) {
        if (maHoaDon == null || maHoaDon.trim().isEmpty()) {
            return new PaymentResultDTO(false, "Mã hóa đơn không được để trống!", null, null, soTien, null);
        }
        if (soTien <= 0) {
            return new PaymentResultDTO(false, "Số tiền thanh toán phải lớn hơn 0đ!", maHoaDon, null, soTien, null);
        }

        String invoiceId = maHoaDon.trim();
        String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";
        String paymentMethod = (phuongThuc != null && !phuongThuc.trim().isEmpty())
                ? phuongThuc.trim() : "TienMat";

        try {
            String maThanhToan = paymentDAO.recordPayment(invoiceId, empId, soTien, paymentMethod);
            InvoiceDetailDTO invoice = invoiceDAO.getInvoiceHeader(invoiceId);
            String trangThaiMoi = (invoice != null) ? invoice.getTrangThaiHoaDon() : "MotPhan";

            return new PaymentResultDTO(true,
                    "Ghi nhận thanh toán thành công số tiền " + String.format("%,.0f", soTien) + "đ!",
                    invoiceId, maThanhToan, soTien, trangThaiMoi);
        } catch (Exception e) {
            return new PaymentResultDTO(false, e.getMessage(), invoiceId, null, soTien, null);
        }
    }

    /**
     * Lấy toàn bộ lịch sử thanh toán của một hóa đơn.
     */
    public List<PaymentRecordDTO> getPaymentHistory(String maHoaDon) {
        if (maHoaDon == null || maHoaDon.trim().isEmpty()) {
            return Collections.emptyList();
        }
        try {
            return paymentDAO.getPaymentHistory(maHoaDon.trim());
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }

    /**
     * Tính toán số tiền còn thiếu cần phải thanh toán của hóa đơn.
     */
    public double calculateRemainingAmount(String maHoaDon) {
        if (maHoaDon == null || maHoaDon.trim().isEmpty()) {
            return 0.0;
        }
        try {
            String invoiceId = maHoaDon.trim();
            InvoiceDetailDTO header = invoiceDAO.getInvoiceHeader(invoiceId);
            if (header == null || header.getTongTienCuoiCung() == null) {
                return 0.0;
            }
            double total = header.getTongTienCuoiCung();
            double paid = paymentDAO.getTotalPaid(invoiceId);
            return Math.max(0.0, total - paid);
        } catch (Exception e) {
            return 0.0;
        }
    }

    /**
     * Thực hiện thanh toán kết hợp trả phòng đồng thời (Phương án 2).
     */
    public PaymentResultDTO processPaymentAndCheckOut(
            String maBooking, String maHoaDon, List<String> roomIds, String maNV, double soTien, String phuongThuc) {
        String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";
        String invoiceId = maHoaDon;

        try {
            if (roomIds != null && !roomIds.isEmpty()) {
                invoiceId = checkOutRoomsInternal(maBooking, roomIds, empId);
            }

            if (soTien > 0) {
                return executePaymentInternal(invoiceId, empId, soTien, phuongThuc);
            }

            return buildZeroPaymentSuccess(invoiceId);
        } catch (Exception e) {
            return new PaymentResultDTO(false, e.getMessage(), invoiceId, null, soTien, null);
        }
    }

    private String checkOutRoomsInternal(String maBooking, List<String> roomIds, String empId) throws Exception {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }
        String bookingId = maBooking.trim();
        for (String roomId : roomIds) {
            if (roomId != null && !roomId.trim().isEmpty()) {
                checkOutDAO.executeCheckOutRoom(bookingId, roomId.trim(), empId);
            }
        }
        return invoiceDAO.createOrUpdateInvoice(bookingId, empId);
    }

    private PaymentResultDTO executePaymentInternal(
            String invoiceId, String empId, double soTien, String phuongThuc) throws Exception {
        if (invoiceId == null || invoiceId.trim().isEmpty()) {
            return new PaymentResultDTO(false, "Không tìm thấy hóa đơn hợp lệ!", null, null, soTien, null);
        }
        String method = (phuongThuc != null && !phuongThuc.trim().isEmpty()) ? phuongThuc.trim() : "TienMat";
        String maThanhToan = paymentDAO.recordPayment(invoiceId, empId, soTien, method);
        InvoiceDetailDTO invoice = invoiceDAO.getInvoiceHeader(invoiceId);
        String trangThai = (invoice != null) ? invoice.getTrangThaiHoaDon() : "MotPhan";
        return new PaymentResultDTO(true,
                "Xác nhận trả phòng và thu tiền thành công!", invoiceId, maThanhToan, soTien, trangThai);
    }

    private PaymentResultDTO buildZeroPaymentSuccess(String invoiceId) throws Exception {
        InvoiceDetailDTO invoice = (invoiceId != null) ? invoiceDAO.getInvoiceHeader(invoiceId) : null;
        String trangThai = (invoice != null) ? invoice.getTrangThaiHoaDon() : "DaThanhToanDu";
        return new PaymentResultDTO(true,
                "Đã hoàn tất trả phòng thành công!", invoiceId, null, 0.0, trangThai);
    }
}
