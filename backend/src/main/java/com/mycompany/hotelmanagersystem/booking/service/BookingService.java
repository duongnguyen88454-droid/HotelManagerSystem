package com.mycompany.hotelmanagersystem.booking.service;

import com.mycompany.hotelmanagersystem.booking.dao.BookingDAO;
import com.mycompany.hotelmanagersystem.booking.dao.BookingDichVuDAO;
import com.mycompany.hotelmanagersystem.booking.dao.BookingQueryDAO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CustomerBookingHistoryDTO;
import com.mycompany.hotelmanagersystem.booking.dto.SingleBookingRequestDTO;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.hotelservice.service.HotelServiceService;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Service xử lý logic nghiệp vụ đặt phòng khách sạn.
 * Tuân thủ QT 1.1-1.5, QT 2.5, QT 3.2 trong ARCHITECTURE_RULES.md.
 */
public class BookingService {

    private final BookingDAO bookingDAO;
    private final BookingQueryDAO bookingQueryDAO;
    private final BookingDichVuDAO bookingDichVuDAO;
    private final RoomService roomService;
    private final HotelServiceService hotelServiceService;

    public BookingService() {
        this(new BookingDAO(), new BookingQueryDAO(), new BookingDichVuDAO(),
                new RoomService(), new HotelServiceService());
    }

    public BookingService(BookingDAO bookingDAO, BookingQueryDAO bookingQueryDAO, BookingDichVuDAO bookingDichVuDAO,
            RoomService roomService, HotelServiceService hotelServiceService) {
        this.bookingDAO = bookingDAO;
        this.bookingQueryDAO = bookingQueryDAO;
        this.bookingDichVuDAO = bookingDichVuDAO;
        this.roomService = roomService;
        this.hotelServiceService = hotelServiceService;
    }

    /**
     * Lấy toàn bộ dịch vụ đang kinh doanh.
     */
    public List<ServiceItem> getActiveServices() {
        return hotelServiceService.getAllActiveServices();
    }

    /**
     * Tạo đơn đặt phòng trực tuyến kèm dịch vụ đã chọn cho 1 phòng.
     */
    public String createBookingWithServices(SingleBookingRequestDTO req) throws Exception {
        if (req == null) {
            throw new IllegalArgumentException("Yêu cầu đặt phòng không hợp lệ!");
        }
        if (req.getMaKH() == null || req.getMaKH().trim().isEmpty()) {
            throw new IllegalArgumentException("Khách hàng chưa đăng nhập hoặc thông tin không hợp lệ!");
        }
        if (req.getMaPhong() == null || req.getMaPhong().trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn phòng cần đặt!");
        }

        LocalDate today = LocalDate.now();
        LocalDate checkInLocal = req.getCheckIn();
        LocalDate checkOutLocal = req.getCheckOut();

        if (checkInLocal == null || checkInLocal.isBefore(today)) {
            throw new IllegalArgumentException("Ngày nhận phòng không thể trước ngày hôm nay!");
        }
        if (checkOutLocal == null || !checkOutLocal.isAfter(checkInLocal)) {
            throw new IllegalArgumentException("Ngày trả phòng phải sau ngày nhận phòng!");
        }

        AvailableRoomDTO room = roomService.getRoomDetailById(req.getMaPhong().trim());
        if (room == null) {
            throw new IllegalArgumentException("Phòng " + req.getMaPhong() + " không tồn tại!");
        }

        long daysBetween = ChronoUnit.DAYS.between(checkInLocal, checkOutLocal);
        int soDem = (int) Math.max(1, daysBetween);
        double donGiaPhong = room.getGiaPhong();
        double tienPhong = donGiaPhong * soDem;

        double tongTienDichVu = calculateServicesTotal(req.getSelectedServices());
        double tongChiPhi = tienPhong + tongTienDichVu;

        req.setDonGiaPhong(donGiaPhong);
        req.setTongChiPhi(tongChiPhi);

        return bookingDAO.createOnlineBookingWithServices(req);
    }

    /**
     * Tạo đơn đặt đa phòng kèm các dịch vụ đi kèm riêng cho từng phòng.
     */
    public String createMultiRoomBooking(String maKH, String maTaiKhoan, BookingCartDTO cart, String note)
            throws Exception {
        if (maKH == null || maKH.trim().isEmpty()) {
            throw new IllegalArgumentException("Hồ sơ khách hàng lưu trú không hợp lệ!");
        }
        if (cart == null || cart.getTotalRoomCount() == 0) {
            throw new IllegalArgumentException("Giỏ đặt phòng đang trống, vui lòng chọn phòng trước khi thanh toán!");
        }

        validateCartItems(cart);

        return bookingDAO.createMultiRoomBookingWithServices(maKH.trim(),
                maTaiKhoan != null ? maTaiKhoan.trim() : null, cart, note);
    }

    /**
     * Lấy chi tiết đơn đặt phòng (kèm kiểm tra bảo mật chống IDOR).
     */
    public BookingDetailDTO getBookingDetail(String maBooking, String maKH, String maTaiKhoan)
            throws SecurityException {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }

        BookingDetailDTO dto = bookingQueryDAO.getBookingDetailById(maBooking.trim());
        if (dto == null) {
            return null;
        }

        if (!isAuthorized(dto, maKH, maTaiKhoan)) {
            throw new SecurityException("Quý khách không có quyền truy cập vào đơn đặt phòng này!");
        }

        return dto;
    }

    /**
     * Thêm dịch vụ vào phòng cụ thể trong đơn booking.
     */
    public boolean addServiceToRoom(String maBooking, String maPhong, String maDichVu, int soLuong,
            String maKH, String maTaiKhoan) throws Exception {
        if (soLuong <= 0) {
            throw new IllegalArgumentException("Số lượng dịch vụ phải lớn hơn 0!");
        }

        BookingDetailDTO booking = getBookingDetail(maBooking, maKH, maTaiKhoan);
        if (booking == null) {
            throw new IllegalArgumentException("Đơn đặt phòng không tồn tại!");
        }
        if (isDepositPaid(booking)) {
            throw new IllegalStateException("Đơn đặt phòng đã được xác nhận và nộp cọc, không thể thêm dịch vụ!");
        }

        String trangThai = booking.getTrangThaiBooking();
        if (!"Confirmed".equalsIgnoreCase(trangThai) && !"CheckedIn".equalsIgnoreCase(trangThai)) {
            throw new IllegalStateException(
                    "Chỉ có thể gọi thêm dịch vụ khi đơn đặt phòng đang có hiệu lực (Đã xác nhận hoặc Đang lưu trú)!");
        }

        return bookingDichVuDAO.addServiceToBookingRoom(maBooking.trim(), maPhong.trim(), maDichVu.trim(),
                soLuong, "KhachHang");
    }

    /**
     * Xóa dịch vụ khỏi phòng (khi đơn chưa Check-in).
     */
    public boolean removeServiceFromRoom(String maBookingDichVu, String maBooking, String maKH,
            String maTaiKhoan) throws Exception {
        BookingDetailDTO booking = getBookingDetail(maBooking, maKH, maTaiKhoan);
        if (booking == null) {
            throw new IllegalArgumentException("Đơn đặt phòng không tồn tại!");
        }
        if (isDepositPaid(booking)) {
            throw new IllegalStateException("Đơn đặt phòng đã nộp cọc, không thể sửa đổi dịch vụ trực tuyến!");
        }

        if (!"Confirmed".equalsIgnoreCase(booking.getTrangThaiBooking())) {
            throw new IllegalStateException("Chỉ được hủy dịch vụ khi chưa làm thủ tục nhận phòng (Check-in)!");
        }

        return bookingDichVuDAO.removeServiceFromBookingRoom(maBookingDichVu.trim(), maBooking.trim());
    }

    /**
     * Lấy lịch sử đặt phòng của tài khoản Web (MaTaiKhoan).
     */
    public List<CustomerBookingHistoryDTO> getCustomerHistoryByAccountId(String maTaiKhoan) {
        return (maTaiKhoan == null || maTaiKhoan.trim().isEmpty()) ? new ArrayList<>()
                : bookingQueryDAO.getBookingHistoryByAccountId(maTaiKhoan.trim());
    }

    /**
     * Lấy lịch sử đặt phòng của khách hàng theo mã hồ sơ MaKH.
     */
    public List<CustomerBookingHistoryDTO> getCustomerHistory(String maKH) {
        return (maKH == null || maKH.trim().isEmpty()) ? new ArrayList<>()
                : bookingQueryDAO.getBookingHistoryByCustomer(maKH.trim());
    }

    /**
     * Hủy đơn đặt phòng khi chưa Check-in.
     */
    public boolean cancelBooking(String maBooking, String maKH, String maTaiKhoan) throws Exception {
        if (maBooking == null) {
            return false;
        }
        BookingDetailDTO booking = getBookingDetail(maBooking, maKH, maTaiKhoan);
        if (booking == null) {
            throw new IllegalArgumentException("Đơn đặt phòng không tồn tại!");
        }
        if (!"Confirmed".equalsIgnoreCase(booking.getTrangThaiBooking())) {
            throw new IllegalStateException("Đơn đặt phòng đã Check-in hoặc đã hủy, không thể hủy!");
        }
        return bookingDAO.cancelBooking(maBooking.trim(), booking.getMaKH(), maTaiKhoan);
    }

    // --- CÁC PHƯƠNG THỨC HELPER NỘI BỘ (PRIVATE) ---

    private boolean isDepositPaid(BookingDetailDTO b) {
        return b != null && ("PartiallyPaid".equalsIgnoreCase(b.getTrangThaiHoaDon())
                || "Paid".equalsIgnoreCase(b.getTrangThaiHoaDon()));
    }

    private boolean isAuthorized(BookingDetailDTO dto, String maKH, String maTaiKhoan) {
        if ((maKH == null || maKH.trim().isEmpty()) && (maTaiKhoan == null || maTaiKhoan.trim().isEmpty())) {
            return false;
        }
        if (maTaiKhoan != null && !maTaiKhoan.trim().isEmpty() && dto.getMaTaiKhoan() != null
                && maTaiKhoan.trim().equalsIgnoreCase(dto.getMaTaiKhoan().trim())) {
            return true;
        }
        if (maKH != null && !maKH.trim().isEmpty() && dto.getMaKH() != null) {
            return maKH.trim().equalsIgnoreCase(dto.getMaKH().trim());
        }
        return false;
    }

    private void validateCartItems(BookingCartDTO cart) {
        LocalDate today = LocalDate.now();
        for (CartRoomItemDTO roomItem : cart.getItems().values()) {
            if (roomItem.getNgayNhan() == null || roomItem.getNgayTra() == null) {
                throw new IllegalArgumentException("Vui lòng chọn ngày nhận và trả cho phòng "
                        + roomItem.getSoPhong() + "!");
            }
            LocalDate inDate = LocalDate.parse(roomItem.getNgayNhan().trim());
            LocalDate outDate = LocalDate.parse(roomItem.getNgayTra().trim());
            if (inDate.isBefore(today) || !inDate.isBefore(outDate)) {
                throw new IllegalArgumentException("Thời gian lưu trú phòng " + roomItem.getSoPhong()
                        + " không hợp lệ!");
            }
            roomItem.recalculate();
            syncCartServicePrices(roomItem);
        }
    }

    private void syncCartServicePrices(CartRoomItemDTO roomItem) {
        if (roomItem.getSelectedServices() == null) {
            return;
        }
        for (CartServiceItemDTO svc : roomItem.getSelectedServices()) {
            if (svc.getDonGia() <= 0) {
                ServiceItem dbSvc = hotelServiceService.getServiceById(svc.getMaDichVu());
                if (dbSvc != null) {
                    svc.setDonGia(dbSvc.getDonGia());
                    svc.setTenDichVu(dbSvc.getTenDichVu());
                }
            }
        }
    }

    private double calculateServicesTotal(Map<String, Integer> selectedServices) {
        if (selectedServices == null || selectedServices.isEmpty()) {
            return 0.0;
        }
        double total = 0.0;
        for (Map.Entry<String, Integer> entry : selectedServices.entrySet()) {
            int soLuong = entry.getValue() != null ? entry.getValue() : 0;
            if (soLuong > 0) {
                ServiceItem item = hotelServiceService.getServiceById(entry.getKey());
                if (item != null) {
                    total += item.getDonGia() * soLuong;
                }
            }
        }
        return total;
    }
}
