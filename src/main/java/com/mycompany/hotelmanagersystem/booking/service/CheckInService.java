package com.mycompany.hotelmanagersystem.booking.service;

import com.mycompany.hotelmanagersystem.booking.dao.BookingCheckInDAO;
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

    public CheckInService() {
        this.checkInDAO = new BookingCheckInDAO();
    }

    public CheckInService(BookingCheckInDAO checkInDAO) {
        this.checkInDAO = checkInDAO;
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
     * Thực hiện thủ tục Check-in nhận phòng tại quầy lễ tân.
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
        if (!request.isDaDoiChieuCccd()) {
            return new CheckInResultDTO(false, "Vui lòng xác nhận đã đối chiếu CCCD / Hộ chiếu bản gốc!",
                    maBooking, maPhong, null);
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
