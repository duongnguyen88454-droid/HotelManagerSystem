package com.mycompany.hotelmanagersystem.service.booking;

import com.mycompany.hotelmanagersystem.dao.booking.BookingDAO;
import com.mycompany.hotelmanagersystem.room.dao.RoomDAO;
import com.mycompany.hotelmanagersystem.dao.service.ServiceDAO;
import com.mycompany.hotelmanagersystem.dto.booking.BookingCartDTO;
import com.mycompany.hotelmanagersystem.dto.booking.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.dto.booking.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.dto.booking.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.dto.booking.CustomerBookingHistoryDTO;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.model.ServiceItem;

import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

public class BookingService {

    private final BookingDAO bookingDAO;
    private final RoomDAO roomDAO;
    private final ServiceDAO serviceDAO;

    public BookingService() {
        this.bookingDAO = new BookingDAO();
        this.roomDAO = new RoomDAO();
        this.serviceDAO = new ServiceDAO();
    }

    public BookingService(BookingDAO bookingDAO, RoomDAO roomDAO, ServiceDAO serviceDAO) {
        this.bookingDAO = bookingDAO;
        this.roomDAO = roomDAO;
        this.serviceDAO = serviceDAO;
    }

    /**
     * Lấy toàn bộ dịch vụ đang kinh doanh
     */
    public List<ServiceItem> getActiveServices() {
        return serviceDAO.getAllActiveServices();
    }

    /**
     * Tạo đơn đặt phòng trực tuyến kèm dịch vụ đã chọn cho phòng (có lưu mã tài khoản Web)
     */
    public String createBookingWithServices(String maKH, String maTaiKhoan, String maPhong, String checkInStr, String checkOutStr,
            String note, Map<String, Integer> selectedServices) throws Exception {
        if (maKH == null || maKH.trim().isEmpty()) {
            throw new IllegalArgumentException("Khách hàng chưa đăng nhập hoặc thông tin không hợp lệ!");
        }

        if (maPhong == null || maPhong.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn phòng cần đặt!");
        }

        LocalDate today = LocalDate.now();
        LocalDate checkInLocal = LocalDate.parse(checkInStr.trim());
        LocalDate checkOutLocal = LocalDate.parse(checkOutStr.trim());

        if (checkInLocal.isBefore(today)) {
            throw new IllegalArgumentException("Ngày nhận phòng không thể trước ngày hôm nay!");
        }
        if (!checkOutLocal.isAfter(checkInLocal)) {
            throw new IllegalArgumentException("Ngày trả phòng phải sau ngày nhận phòng!");
        }

        AvailableRoomDTO room = roomDAO.getRoomDetailById(maPhong.trim());
        if (room == null) {
            throw new IllegalArgumentException("Phòng " + maPhong + " không tồn tại!");
        }

        long daysBetween = ChronoUnit.DAYS.between(checkInLocal, checkOutLocal);
        int soDem = (int) Math.max(1, daysBetween);
        double donGiaPhong = room.getGiaPhong();
        double tienPhong = donGiaPhong * soDem;

        // Tính tổng tiền các dịch vụ đã chọn
        double tongTienDichVu = 0;
        if (selectedServices != null && !selectedServices.isEmpty()) {
            for (Map.Entry<String, Integer> entry : selectedServices.entrySet()) {
                String maDv = entry.getKey();
                int soLuong = entry.getValue() != null ? entry.getValue() : 0;
                if (soLuong > 0) {
                    ServiceItem item = serviceDAO.getServiceById(maDv);
                    if (item != null) {
                        tongTienDichVu += item.getDonGia() * soLuong;
                    }
                }
            }
        }

        double tongChiPhi = tienPhong + tongTienDichVu;
        Date checkInDate = Date.valueOf(checkInLocal);
        Date checkOutDate = Date.valueOf(checkOutLocal);

        return bookingDAO.createOnlineBookingWithServices(
                maKH.trim(),
                maTaiKhoan != null ? maTaiKhoan.trim() : null,
                maPhong.trim(),
                checkInDate,
                checkOutDate,
                donGiaPhong,
                tongChiPhi,
                selectedServices,
                note);
    }

    public String createBookingWithServices(String maKH, String maPhong, String checkInStr, String checkOutStr,
            String note, Map<String, Integer> selectedServices) throws Exception {
        return createBookingWithServices(maKH, null, maPhong, checkInStr, checkOutStr, note, selectedServices);
    }

    /**
     * Tạo đơn đặt đa phòng kèm các dịch vụ đi kèm riêng cho từng phòng (hỗ trợ lưu maTaiKhoan)
     */
    public String createMultiRoomBooking(String maKH, String maTaiKhoan, BookingCartDTO cart, String note) throws Exception {
        if (maKH == null || maKH.trim().isEmpty()) {
            throw new IllegalArgumentException("Hồ sơ khách hàng lưu trú không hợp lệ!");
        }

        if (cart == null || cart.getTotalRoomCount() == 0) {
            throw new IllegalArgumentException("Giỏ đặt phòng đang trống, vui lòng chọn phòng trước khi thanh toán!");
        }

        LocalDate today = LocalDate.now();

        // Kiểm tra và tính toán lại từng phòng
        for (CartRoomItemDTO roomItem : cart.getItems().values()) {
            if (roomItem.getNgayNhan() == null || roomItem.getNgayTra() == null) {
                throw new IllegalArgumentException("Vui lòng chọn ngày nhận và trả cho phòng " + roomItem.getSoPhong() + "!");
            }

            LocalDate checkInLocal = LocalDate.parse(roomItem.getNgayNhan().trim());
            LocalDate checkOutLocal = LocalDate.parse(roomItem.getNgayTra().trim());

            if (checkInLocal.isBefore(today)) {
                throw new IllegalArgumentException("Ngày nhận của phòng " + roomItem.getSoPhong() + " không thể trước ngày hôm nay!");
            }

            if (!checkInLocal.isBefore(checkOutLocal)) {
                throw new IllegalArgumentException("Ngày trả phòng phải sau ngày nhận phòng đối với phòng " + roomItem.getSoPhong() + "!");
            }

            roomItem.recalculate();

            // Cập nhật đơn giá dịch vụ chính xác từ DB
            if (roomItem.getSelectedServices() != null) {
                for (CartServiceItemDTO svc : roomItem.getSelectedServices()) {
                    if (svc.getDonGia() <= 0) {
                        ServiceItem dbSvc = serviceDAO.getServiceById(svc.getMaDichVu());
                        if (dbSvc != null) {
                            svc.setDonGia(dbSvc.getDonGia());
                            svc.setTenDichVu(dbSvc.getTenDichVu());
                        }
                    }
                }
            }
        }

        return bookingDAO.createMultiRoomBookingWithServices(maKH.trim(), maTaiKhoan != null ? maTaiKhoan.trim() : null, cart, note);
    }

    public String createMultiRoomBooking(String maKH, BookingCartDTO cart, String note) throws Exception {
        return createMultiRoomBooking(maKH, null, cart, note);
    }

    /**
     * Lấy chi tiết đơn đặt phòng (kèm kiểm tra bảo mật chống IDOR theo maKH hoặc maTaiKhoan)
     */
    public BookingDetailDTO getBookingDetail(String maBooking, String maKH, String maTaiKhoan) throws SecurityException {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }

        BookingDetailDTO dto = bookingDAO.getBookingDetailById(maBooking.trim());
        if (dto == null) {
            return null;
        }

        // Kiểm tra quyền: Cho phép nếu maTaiKhoan khớp với tài khoản web đặt phòng
        // HOẶC maKH khớp với hồ sơ khách hàng lưu trú
        boolean authorized = false;
        if (maTaiKhoan != null && !maTaiKhoan.trim().isEmpty() && dto.getMaTaiKhoan() != null) {
            if (maTaiKhoan.trim().equalsIgnoreCase(dto.getMaTaiKhoan().trim())) {
                authorized = true;
            }
        }
        if (!authorized && maKH != null && !maKH.trim().isEmpty() && dto.getMaKH() != null) {
            if (maKH.trim().equalsIgnoreCase(dto.getMaKH().trim())) {
                authorized = true;
            }
        }
        if (!authorized && maKH == null && maTaiKhoan == null) {
            authorized = true; // Cho phép nội bộ / quản trị
        }

        if (!authorized) {
            throw new SecurityException("Quý khách không có quyền truy cập vào đơn đặt phòng này!");
        }

        return dto;
    }

    public BookingDetailDTO getBookingDetail(String maBooking, String maKH) throws SecurityException {
        return getBookingDetail(maBooking, maKH, null);
    }

    /**
     * Thêm dịch vụ vào phòng cụ thể trong đơn booking
     */
    public boolean addServiceToRoom(String maBooking, String maPhong, String maDichVu, int soLuong, String maKH, String maTaiKhoan)
            throws Exception {
        if (soLuong <= 0) {
            throw new IllegalArgumentException("Số lượng dịch vụ phải lớn hơn 0!");
        }

        // Kiểm tra quyền sở hữu đơn
        BookingDetailDTO booking = getBookingDetail(maBooking, maKH, maTaiKhoan);
        if (booking == null) {
            throw new IllegalArgumentException("Đơn đặt phòng không tồn tại!");
        }

        // Chỉ cho phép thêm khi đang ở trạng thái DaXacNhan hoặc DaCheckIn
        String trangThai = booking.getTrangThaiBooking();
        if (!"DaXacNhan".equalsIgnoreCase(trangThai) && !"DaCheckIn".equalsIgnoreCase(trangThai)) {
            throw new IllegalStateException(
                    "Chỉ có thể gọi thêm dịch vụ khi đơn đặt phòng đang có hiệu lực (Đã xác nhận hoặc Đang lưu trú)!");
        }

        return bookingDAO.addServiceToBookingRoom(maBooking.trim(), maPhong.trim(), maDichVu.trim(), soLuong,
                "KhachHang");
    }

    public boolean addServiceToRoom(String maBooking, String maPhong, String maDichVu, int soLuong, String maKH)
            throws Exception {
        return addServiceToRoom(maBooking, maPhong, maDichVu, soLuong, maKH, null);
    }

    /**
     * Xóa dịch vụ khỏi phòng (khi đơn chưa Check-in)
     */
    public boolean removeServiceFromRoom(String maBookingDichVu, String maBooking, String maKH, String maTaiKhoan) throws Exception {
        BookingDetailDTO booking = getBookingDetail(maBooking, maKH, maTaiKhoan);
        if (booking == null) {
            throw new IllegalArgumentException("Đơn đặt phòng không tồn tại!");
        }

        if (!"DaXacNhan".equalsIgnoreCase(booking.getTrangThaiBooking())) {
            throw new IllegalStateException("Chỉ được hủy dịch vụ khi chưa làm thủ tục nhận phòng (Check-in)!");
        }

        return bookingDAO.removeServiceFromBookingRoom(maBookingDichVu.trim(), maBooking.trim());
    }

    public boolean removeServiceFromRoom(String maBookingDichVu, String maBooking, String maKH) throws Exception {
        return removeServiceFromRoom(maBookingDichVu, maBooking, maKH, null);
    }

    /**
     * Lấy lịch sử đặt phòng của tài khoản Web (MaTaiKhoan)
     * Đảm bảo tính độc lập: Mỗi tài khoản chỉ xem lịch sử do chính mình đặt
     */
    public List<CustomerBookingHistoryDTO> getCustomerHistoryByAccountId(String maTaiKhoan) {
        if (maTaiKhoan == null || maTaiKhoan.trim().isEmpty()) {
            return new java.util.ArrayList<>();
        }
        return bookingDAO.getBookingHistoryByAccountId(maTaiKhoan.trim());
    }

    /**
     * Lấy lịch sử đặt phòng của khách hàng theo mã hồ sơ MaKH
     */
    public List<CustomerBookingHistoryDTO> getCustomerHistory(String maKH) {
        if (maKH == null || maKH.trim().isEmpty()) {
            return new java.util.ArrayList<>();
        }
        return bookingDAO.getBookingHistoryByCustomer(maKH.trim());
    }

    /**
     * Hủy đơn đặt phòng khi chưa Check-in
     */
    public boolean cancelBooking(String maBooking, String maKH, String maTaiKhoan) throws Exception {
        if (maBooking == null) {
            return false;
        }

        BookingDetailDTO booking = getBookingDetail(maBooking, maKH, maTaiKhoan);
        if (booking == null) {
            throw new IllegalArgumentException("Đơn đặt phòng không tồn tại!");
        }

        if (!"DaXacNhan".equalsIgnoreCase(booking.getTrangThaiBooking())) {
            throw new IllegalStateException(
                    "Đơn đặt phòng đã được Check-in hoặc đã hủy, không thể thực hiện thao tác này!");
        }

        // [BUG-04 FIX] Truyền maTaiKhoan để DAO có thể fallback cancel qua web account
        return bookingDAO.cancelBooking(maBooking.trim(), booking.getMaKH(), maTaiKhoan);
    }

    public boolean cancelBooking(String maBooking, String maKH) throws Exception {
        return cancelBooking(maBooking, maKH, null);
    }
}
