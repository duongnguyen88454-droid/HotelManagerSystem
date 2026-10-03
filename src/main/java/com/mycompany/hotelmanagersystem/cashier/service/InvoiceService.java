package com.mycompany.hotelmanagersystem.cashier.service;

import com.mycompany.hotelmanagersystem.cashier.dao.InvoiceDAO;
import com.mycompany.hotelmanagersystem.cashier.dao.PaymentDAO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceDetailDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceRoomItemDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceServiceItemDTO;

import java.util.List;

/**
 * Service tổng hợp đầy đủ dữ liệu hóa đơn quyết toán phục vụ hiển thị và in hóa đơn.
 */
public class InvoiceService {

    private final InvoiceDAO invoiceDAO;
    private final PaymentDAO paymentDAO;

    public InvoiceService() {
        this.invoiceDAO = new InvoiceDAO();
        this.paymentDAO = new PaymentDAO();
    }

    public InvoiceService(InvoiceDAO invoiceDAO, PaymentDAO paymentDAO) {
        this.invoiceDAO = invoiceDAO;
        this.paymentDAO = paymentDAO;
    }

    /**
     * Lấy toàn bộ chi tiết hóa đơn (tiêu đề, khách, bảng kê phòng, bảng kê dịch vụ, tiền đã trả, còn thiếu).
     */
    public InvoiceDetailDTO getFullInvoiceForDisplay(String maHoaDon) {
        if (maHoaDon == null || maHoaDon.trim().isEmpty()) {
            return null;
        }

        try {
            String invoiceId = maHoaDon.trim();
            InvoiceDetailDTO invoice = invoiceDAO.getInvoiceHeader(invoiceId);
            if (invoice == null) {
                return null;
            }

            String bookingId = invoice.getMaBooking();
            List<InvoiceRoomItemDTO> rooms = invoiceDAO.getInvoiceRooms(bookingId);
            List<InvoiceServiceItemDTO> services = invoiceDAO.getInvoiceServices(bookingId);
            double totalPaid = paymentDAO.getTotalPaid(invoiceId);

            double totalAmount = invoice.getTongTienCuoiCung() != null ? invoice.getTongTienCuoiCung() : 0.0;
            if (totalAmount <= 0.0) {
                totalAmount = sumRooms(rooms, null) + sumServices(services, null);
                invoice.setTongTienCuoiCung(totalAmount);
            }
            double remaining = Math.max(0.0, totalAmount - totalPaid);

            invoice.setRooms(rooms);
            invoice.setServices(services);
            invoice.setDaThanhToan(totalPaid);
            invoice.setConThieu(remaining);

            return invoice;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Tự động tính số tiền cần thanh toán cho các phòng được tích chọn trả (gồm tiền phòng + dịch vụ).
     */
    public double calculateAmountForSelectedRooms(InvoiceDetailDTO invoice, List<String> selectedRooms) {
        if (invoice == null) {
            return 0.0;
        }
        double remaining = invoice.getConThieu() != null ? invoice.getConThieu() : 0.0;
        if (remaining <= 0.0) {
            return 0.0;
        }
        if (selectedRooms == null || selectedRooms.isEmpty()) {
            return remaining;
        }
        double totalSelected = sumRooms(invoice.getRooms(), selectedRooms)
                + sumServices(invoice.getServices(), selectedRooms);
        return Math.min(totalSelected, remaining);
    }

    private double sumRooms(List<InvoiceRoomItemDTO> rooms, List<String> filter) {
        if (rooms == null) {
            return 0.0;
        }
        double sum = 0.0;
        for (InvoiceRoomItemDTO r : rooms) {
            if ((filter == null || filter.contains(r.getMaPhong())) && r.getThanhTien() != null) {
                sum += r.getThanhTien();
            }
        }
        return sum;
    }

    private double sumServices(List<InvoiceServiceItemDTO> services, List<String> filter) {
        if (services == null) {
            return 0.0;
        }
        double sum = 0.0;
        for (InvoiceServiceItemDTO s : services) {
            if ((filter == null || filter.contains(s.getMaPhong())) && s.getThanhTien() != null) {
                sum += s.getThanhTien();
            }
        }
        return sum;
    }

    /**
     * Tìm hoặc tạo mới hóa đơn theo mã đơn Booking để hiển thị.
     */
    public InvoiceDetailDTO getInvoiceByBooking(String maBooking, String maNV) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }

        try {
            String bookingId = maBooking.trim();
            String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";

            String invoiceId = invoiceDAO.findInvoiceIdByBooking(bookingId);
            if (invoiceId == null) {
                invoiceId = invoiceDAO.createOrUpdateInvoice(bookingId, empId);
            }

            return getFullInvoiceForDisplay(invoiceId);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Kiểm tra xem hóa đơn đã được thanh toán đủ hay chưa.
     */
    public boolean isFullyPaid(String maHoaDon) {
        InvoiceDetailDTO invoice = getFullInvoiceForDisplay(maHoaDon);
        if (invoice == null) {
            return false;
        }
        return "DaThanhToanDu".equals(invoice.getTrangThaiHoaDon());
    }
}
