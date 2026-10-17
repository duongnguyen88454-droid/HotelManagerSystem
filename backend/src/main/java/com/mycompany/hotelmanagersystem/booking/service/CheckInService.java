package com.mycompany.hotelmanagersystem.booking.service;

import com.mycompany.hotelmanagersystem.booking.dao.BookingCancellationDAO;
import com.mycompany.hotelmanagersystem.booking.dao.BookingCheckInDAO;
import com.mycompany.hotelmanagersystem.booking.dao.BookingCheckInQueryDAO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInArrivalItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInDetailDTO;
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
    private final BookingCancellationDAO cancellationDAO;

    public CheckInService() {
        this.checkInDAO = new BookingCheckInDAO();
        this.checkInQueryDAO = new BookingCheckInQueryDAO();
        this.cancellationDAO = new BookingCancellationDAO();
    }

    public CheckInService(BookingCheckInDAO checkInDAO, BookingCheckInQueryDAO checkInQueryDAO,
                          BookingCancellationDAO cancellationDAO) {
        this.checkInDAO = checkInDAO;
        this.checkInQueryDAO = checkInQueryDAO;
        this.cancellationDAO = cancellationDAO;
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
     * Hỗ trợ tìm kiếm theo từ khóa hoặc lọc độc lập theo: HoTen, CCCD, MaBooking.
     */
    public List<CheckInArrivalItemDTO> getArrivalBookings(String hoTen, String cccd, String maBK, String keyword) {
        return checkInQueryDAO.getArrivalBookings(hoTen, cccd, maBK, keyword);
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
    public CheckInResultDTO executeCheckInMultipleRooms(String maBooking, List<String> roomIds) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckInResultDTO(false, "Mã Booking không được để trống!", null, null, null);
        }
        if (roomIds == null || roomIds.isEmpty()) {
            return new CheckInResultDTO(false, "Vui lòng chọn ít nhất một phòng để Check-in!", maBooking, null, null);
        }

        boolean success = checkInDAO.executeCheckInRooms(maBooking.trim(), roomIds);

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
     * Thực hiện hủy các phòng được chọn hoặc toàn bộ đơn đặt phòng.
     * Tái sử dụng sp_HuyPhong qua BookingCancellationDAO.
     */
    public CheckInResultDTO executeCancelRooms(String maBooking, List<String> roomIds,
                                              String cancelledBy, String reason) {
        if (maBooking == null || maBooking.trim().isEmpty()) {
            return new CheckInResultDTO(false, "Mã Booking không được để trống!", null, null, null);
        }
        String cleanBk = maBooking.trim();
        String validReason = (reason != null && !reason.trim().isEmpty())
                ? reason.trim() : "Khách yêu cầu hủy phòng tại quầy tiếp đón";

        try {
            if (roomIds == null || roomIds.isEmpty()) {
                boolean ok = cancellationDAO.cancelAllRoomsInBooking(cleanBk, cancelledBy, validReason);
                if (ok) {
                    return new CheckInResultDTO(true,
                            "Đã hủy toàn bộ đơn đặt phòng " + cleanBk + " thành công!",
                            cleanBk, "ALL", "Cancelled");
                }
                return new CheckInResultDTO(false,
                        "Hủy đơn đặt phòng thất bại hoặc trạng thái không hợp lệ!",
                        cleanBk, null, null);
            }

            int successCount = 0;
            for (String roomId : roomIds) {
                if (roomId != null && !roomId.trim().isEmpty()) {
                    if (cancellationDAO.cancelSingleRoom(cleanBk, roomId.trim(), cancelledBy, validReason)) {
                        successCount++;
                    }
                }
            }
            if (successCount > 0) {
                String roomListStr = String.join(", ", roomIds);
                return new CheckInResultDTO(true,
                        "Đã hủy thành công " + successCount + " phòng (" + roomListStr + ") trong đơn " + cleanBk + "!",
                        cleanBk, roomListStr, "Cancelled");
            }
            return new CheckInResultDTO(false,
                    "Không thể hủy các phòng đã chọn. Vui lòng kiểm tra lại trạng thái phòng!",
                    cleanBk, null, null);
        } catch (Exception e) {
            return new CheckInResultDTO(false,
                    "Lỗi cơ sở dữ liệu khi hủy phòng: " + e.getMessage(),
                    cleanBk, null, null);
        }
    }
}
