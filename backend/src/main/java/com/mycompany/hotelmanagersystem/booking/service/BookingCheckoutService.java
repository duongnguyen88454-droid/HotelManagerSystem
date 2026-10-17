package com.mycompany.hotelmanagersystem.booking.service;

import com.mycompany.hotelmanagersystem.auth.dto.UserSessionDTO;
import com.mycompany.hotelmanagersystem.booking.dao.BookingDAO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.RoomBookingDetailDTO;
import com.mycompany.hotelmanagersystem.customer.model.Customer;
import com.mycompany.hotelmanagersystem.customer.service.CustomerService;

import java.text.SimpleDateFormat;

/**
 * Service xử lý chốt đơn và ghi nhận đặt phòng đồng thời với thanh toán cọc.
 * Tuân thủ QT 1.1-1.5, QT 3.2 trong ARCHITECTURE_RULES.md.
 */
public class BookingCheckoutService {

    private final BookingDAO bookingDAO;
    private final PaymentService paymentService;
    private final CustomerService customerService;

    public BookingCheckoutService() {
        this(new BookingDAO(), new PaymentService(), new CustomerService());
    }

    public BookingCheckoutService(BookingDAO bookingDAO, PaymentService paymentService,
                                  CustomerService customerService) {
        this.bookingDAO = bookingDAO;
        this.paymentService = paymentService;
        this.customerService = customerService;
    }

    public BookingDetailDTO buildPendingBookingDetail(BookingCartDTO cart, Customer guest, String note) {
        BookingDetailDTO detail = new BookingDetailDTO();
        detail.setMaBooking("CHO_THANH_TOAN");
        detail.setTrangThaiBooking("Pending");
        detail.setTrangThaiHoaDon("Unpaid");
        detail.setGhiChu(note);

        if (guest != null) {
            detail.setHoTenKhachHang(guest.getHoTen());
            detail.setSoDT(guest.getSoDT());
            detail.setEmail(guest.getEmail());
            detail.setCccd(guest.getCccd());
        }

        if (cart != null && cart.getItems() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            for (CartRoomItemDTO item : cart.getItems().values()) {
                RoomBookingDetailDTO room = createRoomDetail(item, sdf);
                detail.addPhong(room);
            }
        }
        return detail;
    }

    private RoomBookingDetailDTO createRoomDetail(CartRoomItemDTO item, SimpleDateFormat sdf) {
        RoomBookingDetailDTO room = new RoomBookingDetailDTO();
        room.setMaPhong(item.getMaPhong());
        room.setSoPhong(item.getSoPhong());
        room.setMaLoaiPhong(item.getMaLoaiPhong());
        room.setTenLoaiPhong(item.getTenLoaiPhong());
        room.setDonGiaPhong(item.getDonGiaPhong());
        room.setSoDem((int) item.getSoDem());
        room.setTienPhong(item.getTienPhong());
        room.setTienCoc(item.getTienCoc());
        try {
            if (item.getNgayNhan() != null) {
                room.setNgayNhanDuKien(sdf.parse(item.getNgayNhan()));
            }
            if (item.getNgayTra() != null) {
                room.setNgayTraDuKien(sdf.parse(item.getNgayTra()));
            }
        } catch (Exception ignored) {
            // bỏ qua lỗi định dạng ngày
        }
        return room;
    }

    /**
     * Thực hiện chốt đặt phòng vào CSDL và thanh toán cọc đồng thời khi khách nhấn thanh toán.
     *
     * @param guest thông tin người lưu trú
     * @param note ghi chú đơn hàng
     * @param currentUser tài khoản đang đăng nhập
     * @param cart giỏ đặt phòng
     * @param paymentMethod phương thức thanh toán
     * @return mã đơn booking vừa tạo
     * @throws Exception nếu xảy ra lỗi kiểm tra phòng hoặc giao dịch CSDL
     */
    public String executeCheckoutAndPayment(Customer guest, String note, UserSessionDTO currentUser,
                                           BookingCartDTO cart, String paymentMethod) throws Exception {
        if (guest == null || cart == null || cart.getTotalRoomCount() == 0) {
            throw new IllegalArgumentException("Thông tin giỏ phòng hoặc khách hàng không hợp lệ!");
        }

        String maKH = customerService.findOrUpsertGuestByCCCD(
                guest.getHoTen(), guest.getEmail(), guest.getSoDT(), guest.getCccd());
        String maTaiKhoan = (currentUser != null) ? currentUser.getMaTaiKhoan() : null;

        String createdBookingId = bookingDAO.createMultiRoomBookingWithServices(maKH, maTaiKhoan, cart, note);

        String method = (paymentMethod != null && !paymentMethod.trim().isEmpty())
                ? paymentMethod.trim() : "BankTransfer";
        paymentService.processDepositPayment(createdBookingId, method,
                "Khách hàng thanh toán cọc và hoàn tất đặt phòng");

        return createdBookingId;
    }
}
