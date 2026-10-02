package com.mycompany.hotelmanagersystem.booking.service;

import com.mycompany.hotelmanagersystem.booking.dao.BookingCheckInDAO;
import com.mycompany.hotelmanagersystem.booking.dao.BookingCheckInQueryDAO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInArrivalItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInRequestDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInResultDTO;
import com.mycompany.hotelmanagersystem.room.dto.BookingBarDTO;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

/**
 * Service nghiệp vụ xử lý thủ tục Check-in và cung cấp dải đặt phòng trên Timeline.
 */
public class CheckInService {

    private final BookingCheckInDAO checkInDAO;
    private final BookingCheckInQueryDAO checkInQueryDAO;

    public CheckInService() {
        this.checkInDAO = new BookingCheckInDAO();
        this.checkInQueryDAO = new BookingCheckInQueryDAO();
    }

    public CheckInService(BookingCheckInDAO checkInDAO, BookingCheckInQueryDAO checkInQueryDAO) {
        this.checkInDAO = checkInDAO;
        this.checkInQueryDAO = checkInQueryDAO;
    }

    /**
     * Lấy toàn bộ dải đặt phòng trong tuần để hiển thị trên PMS Timeline.
     */
    public List<BookingBarDTO> getBookingBarsInWeek(LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null || startDate.isAfter(endDate)) {
            return Collections.emptyList();
        }
        return checkInDAO.getBookingBarsInWeek(startDate, endDate);
    }

    /**
     * Lấy danh sách các đơn đặt phòng chờ tiếp nhận tại Quầy Check-in.
     * Hỗ trợ lọc độc lập theo: HoTen (LIKE), CCCD (khớp chính xác), MaBooking (LIKE).
     */
    public List<CheckInArrivalItemDTO> getArrivalBookings(String hoTen, String cccd, String maBK) {
        return checkInQueryDAO.getArrivalBookings(hoTen, cccd, maBK);
    }

    /**
     * Lấy chi tiết đơn đặt phòng gồm danh sách phòng và dịch vụ đặt trước.
     */
    public CheckInDetailDTO getBookingCheckInDetail(String maBooking) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return null;
        }
        return checkInQueryDAO.getBookingCheckInDetail(maBooking.trim());
    }

    /**
     * Thực hiện Check-in cho nhiều phòng được chọn trong đơn.
     */
    public CheckInResultDTO executeCheckInMultipleRooms(String maBooking, List<String> roomIds, String maNV) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckInResultDTO(false, "Mã Booking không được để trống!", null, null, null);
        }
        if (roomIds == null || roomIds.isEmpty()) {
            return new CheckInResultDTO(false, "Vui lòng chọn ít nhất một phòng để Check-in!", maBooking, null, null);
        }

        String empId = (maNV != null && !maNV.trim().isEmpty()) ? maNV.trim() : "NV001";
        boolean success = checkInDAO.executeCheckInRooms(maBooking.trim(), roomIds, empId);

        if (success) {
            String roomListStr = String.join(", ", roomIds);
            return new CheckInResultDTO(true,
                    "Xác nhận Check-in nhận phòng (" + roomListStr + ") thành công!",
                    maBooking, roomListStr, "Occupied");
        } else {
            return new CheckInResultDTO(false,
                    "Không thể thực hiện Check-in do lỗi hệ thống CSDL!",
                    maBooking, null, null);
        }
    }

    /**
     * Thực hiện thủ tục Check-in nhận 1 phòng (tương thích ngược).
     */
    public CheckInResultDTO executeCheckIn(CheckInRequestDTO request) {
        if (request == null) {
            return new CheckInResultDTO(false, "Yêu cầu Check-in không hợp lệ!", null, null, null);
        }

        String maBooking = request.getMaBooking();
        String maPhong = request.getMaPhong();
        String maNV = (request.getMaNV() != null && !request.getMaNV().trim().isEmpty())
                ? request.getMaNV().trim() : "NV001";

        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckInResultDTO(false, "Mã Booking không được để trống!", maBooking, maPhong, null);
        }
        if (maPhong == null || maPhong.trim().isEmpty()) {
            return new CheckInResultDTO(false, "Mã phòng không được để trống!", maBooking, maPhong, null);
        }

        boolean eligible = checkInDAO.isBookingEligibleForCheckIn(maBooking.trim(), maPhong.trim());
        if (!eligible) {
            return new CheckInResultDTO(false,
                    "Đơn đặt phòng không hợp lệ hoặc phòng này đã hoàn tất Check-in trước đó!",
                    maBooking, maPhong, null);
        }

        boolean success = checkInDAO.executeCheckIn(maBooking.trim(), maPhong.trim(), maNV);
        if (success) {
            return new CheckInResultDTO(true,
                    "Xác nhận Check-in nhận phòng " + maPhong + " thành công!",
                    maBooking, maPhong, "Occupied");
        } else {
            return new CheckInResultDTO(false,
                    "Không thể thực hiện Check-in do lỗi hệ thống CSDL!",
                    maBooking, maPhong, null);
        }
    }
}
