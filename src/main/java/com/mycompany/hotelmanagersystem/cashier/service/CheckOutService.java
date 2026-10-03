package com.mycompany.hotelmanagersystem.cashier.service;

import com.mycompany.hotelmanagersystem.cashier.dao.ActiveBookingDAO;
import com.mycompany.hotelmanagersystem.cashier.dao.CheckOutDAO;
import com.mycompany.hotelmanagersystem.cashier.dao.InvoiceDAO;
import com.mycompany.hotelmanagersystem.cashier.dto.CheckOutResultDTO;

import java.util.List;

/**
 * Service điều phối nghiệp vụ Check-out trả phòng và cập nhật hóa đơn.
 */
public class CheckOutService {

    private final CheckOutDAO checkOutDAO;
    private final InvoiceDAO invoiceDAO;
    private final ActiveBookingDAO activeBookingDAO;

    public CheckOutService() {
        this.checkOutDAO = new CheckOutDAO();
        this.invoiceDAO = new InvoiceDAO();
        this.activeBookingDAO = new ActiveBookingDAO();
    }

    public CheckOutService(CheckOutDAO checkOutDAO, InvoiceDAO invoiceDAO, ActiveBookingDAO activeBookingDAO) {
        this.checkOutDAO = checkOutDAO;
        this.invoiceDAO = invoiceDAO;
        this.activeBookingDAO = activeBookingDAO;
    }

    /**
     * Check-out toàn bộ các phòng còn lại trong đơn đặt phòng.
     */
    public CheckOutResultDTO processCheckOutAll(String maBooking, String maNV) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckOutResultDTO(false, "Mã Booking không được để trống!", null, null, false);
        }

        String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";
        String bookingId = maBooking.trim();

        try {
            boolean success = checkOutDAO.executeCheckOutAll(bookingId, empId);
            if (!success) {
                return new CheckOutResultDTO(false, "Không thể thực hiện Check-out!", bookingId, null, false);
            }

            String maHoaDon = invoiceDAO.createOrUpdateInvoice(bookingId, empId);
            return new CheckOutResultDTO(true,
                    "Check-out thành công toàn bộ phòng trong đơn đặt phòng " + bookingId + "!",
                    bookingId, maHoaDon, true);
        } catch (Exception e) {
            return new CheckOutResultDTO(false, e.getMessage(), bookingId, null, false);
        }
    }

    /**
     * Check-out riêng lẻ một phòng trong đơn đặt phòng (multi-room).
     */
    public CheckOutResultDTO processCheckOutRoom(String maBooking, String maPhong, String maNV) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckOutResultDTO(false, "Mã Booking không được để trống!", null, null, false);
        }
        if (maPhong == null || maPhong.trim().isEmpty()) {
            return new CheckOutResultDTO(false, "Mã phòng không được để trống!", maBooking, null, false);
        }

        String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";
        String bookingId = maBooking.trim();
        String roomId = maPhong.trim();

        try {
            boolean success = checkOutDAO.executeCheckOutRoom(bookingId, roomId, empId);
            if (!success) {
                return new CheckOutResultDTO(false, "Không thể trả phòng " + roomId + "!", bookingId, null, false);
            }

            String maHoaDon = invoiceDAO.createOrUpdateInvoice(bookingId, empId);
            boolean hasUnchecked = activeBookingDAO.hasUncheckedOutRooms(bookingId);

            String msg = hasUnchecked
                    ? "Đã trả phòng " + roomId + " thành công. Đơn vẫn còn phòng chưa Check-out."
                    : "Đã trả phòng " + roomId + " thành công. Tất cả phòng trong đơn đã được trả hoàn tất!";

            return new CheckOutResultDTO(true, msg, bookingId, maHoaDon, !hasUnchecked);
        } catch (Exception e) {
            return new CheckOutResultDTO(false, e.getMessage(), bookingId, null, false);
        }
    }

    /**
     * Check-out danh sách các phòng được chọn trong đơn đặt phòng.
     */
    public CheckOutResultDTO processCheckOutRooms(String maBooking, List<String> roomIds, String maNV) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckOutResultDTO(false, "Mã Booking không được để trống!", null, null, false);
        }
        if (roomIds == null || roomIds.isEmpty()) {
            return new CheckOutResultDTO(false, "Vui lòng chọn ít nhất một phòng để trả!", maBooking, null, false);
        }

        String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";
        String bookingId = maBooking.trim();

        try {
            for (String roomId : roomIds) {
                if (roomId != null && !roomId.trim().isEmpty()) {
                    checkOutDAO.executeCheckOutRoom(bookingId, roomId.trim(), empId);
                }
            }

            String maHoaDon = invoiceDAO.createOrUpdateInvoice(bookingId, empId);
            boolean hasUnchecked = activeBookingDAO.hasUncheckedOutRooms(bookingId);

            String msg = hasUnchecked
                    ? "Đã trả các phòng đã chọn thành công. Đơn vẫn còn phòng chưa Check-out."
                    : "Đã trả các phòng đã chọn thành công. Tất cả phòng trong đơn đã được trả hoàn tất!";

            return new CheckOutResultDTO(true, msg, bookingId, maHoaDon, !hasUnchecked);
        } catch (Exception e) {
            return new CheckOutResultDTO(false, e.getMessage(), bookingId, null, false);
        }
    }
}
