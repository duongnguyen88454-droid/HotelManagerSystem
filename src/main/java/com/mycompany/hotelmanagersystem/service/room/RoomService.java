package com.mycompany.hotelmanagersystem.service.room;

import com.mycompany.hotelmanagersystem.dao.room.RoomDAO;
import com.mycompany.hotelmanagersystem.dto.room.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.model.RoomType;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

public class RoomService {

    private final RoomDAO roomDAO;

    public RoomService() {
        this.roomDAO = new RoomDAO();
    }

    public RoomService(RoomDAO roomDAO) {
        this.roomDAO = roomDAO;
    }

    /**
     * Lấy toàn bộ hạng phòng đang kinh doanh
     */
    public List<RoomType> getActiveRoomTypes() {
        return roomDAO.getAllActiveRoomTypes();
    }

    /**
     * Tìm kiếm phòng trống theo tiêu chí và tính toán chi phí lưu trú
     */
    public List<AvailableRoomDTO> searchRooms(String checkInStr, String checkOutStr, String guestsStr, String roomTypeId) throws IllegalArgumentException {
        LocalDate checkInLocal;
        LocalDate checkOutLocal;
        LocalDate today = LocalDate.now();

        // 1. Phân tích ngày nhận / trả
        try {
            checkInLocal = (checkInStr != null && !checkInStr.trim().isEmpty()) 
                    ? LocalDate.parse(checkInStr.trim()) 
                    : today;
            checkOutLocal = (checkOutStr != null && !checkOutStr.trim().isEmpty()) 
                    ? LocalDate.parse(checkOutStr.trim()) 
                    : checkInLocal.plusDays(1);
        } catch (Exception e) {
            throw new IllegalArgumentException("Định dạng ngày không hợp lệ (Vui lòng chọn theo định dạng yyyy-MM-dd)!");
        }

        // 2. Validate nghiệp vụ ngày
        if (checkInLocal.isBefore(today)) {
            throw new IllegalArgumentException("Ngày nhận phòng không thể trước ngày hôm nay (" + today + ")!");
        }

        if (!checkOutLocal.isAfter(checkInLocal)) {
            throw new IllegalArgumentException("Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 đêm!");
        }

        long daysBetween = ChronoUnit.DAYS.between(checkInLocal, checkOutLocal);
        int soDem = (int) Math.max(1, daysBetween);

        // 3. Phân tích số lượng khách
        Integer guests = null;
        if (guestsStr != null && !guestsStr.trim().isEmpty()) {
            try {
                guests = Integer.parseInt(guestsStr.trim());
                if (guests <= 0) {
                    guests = null;
                }
            } catch (NumberFormatException ignored) {
            }
        }

        // 4. Gọi DAO truy vấn CSDL
        Date checkInDate = Date.valueOf(checkInLocal);
        Date checkOutDate = Date.valueOf(checkOutLocal);
        List<AvailableRoomDTO> rooms = roomDAO.searchAvailableRooms(checkInDate, checkOutDate, guests, roomTypeId);

        // 5. Tính toán số đêm và tổng tiền dự kiến cho từng thẻ phòng
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        String formatNhan = sdf.format(checkInDate);
        String formatTra = sdf.format(checkOutDate);

        for (AvailableRoomDTO room : rooms) {
            room.setNgayNhan(formatNhan);
            room.setNgayTra(formatTra);
            room.setSoDem(soDem);
            room.setTongTienDuKien(room.getGiaPhong() * soDem);
        }

        return rooms;
    }

    /**
     * Lấy thông tin chi tiết của phòng đã chọn để chuẩn bị xác nhận đặt phòng
     */
    public AvailableRoomDTO getRoomBookingDetail(String maPhong, String checkInStr, String checkOutStr) throws IllegalArgumentException {
        if (maPhong == null || maPhong.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã phòng không hợp lệ!");
        }

        LocalDate today = LocalDate.now();
        LocalDate checkInLocal;
        LocalDate checkOutLocal;

        try {
            checkInLocal = (checkInStr != null && !checkInStr.trim().isEmpty()) 
                    ? LocalDate.parse(checkInStr.trim()) 
                    : today;
            checkOutLocal = (checkOutStr != null && !checkOutStr.trim().isEmpty()) 
                    ? LocalDate.parse(checkOutStr.trim()) 
                    : checkInLocal.plusDays(1);
        } catch (Exception e) {
            throw new IllegalArgumentException("Định dạng ngày không hợp lệ!");
        }

        if (checkInLocal.isBefore(today)) {
            throw new IllegalArgumentException("Ngày nhận phòng không thể trước ngày hôm nay!");
        }
        if (!checkOutLocal.isAfter(checkInLocal)) {
            throw new IllegalArgumentException("Ngày trả phòng phải sau ngày nhận phòng!");
        }

        AvailableRoomDTO room = roomDAO.getRoomDetailById(maPhong.trim());
        if (room == null) {
            throw new IllegalArgumentException("Không tìm thấy thông tin phòng yêu cầu!");
        }

        long daysBetween = ChronoUnit.DAYS.between(checkInLocal, checkOutLocal);
        int soDem = (int) Math.max(1, daysBetween);

        Date checkInDate = Date.valueOf(checkInLocal);
        Date checkOutDate = Date.valueOf(checkOutLocal);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

        room.setNgayNhan(sdf.format(checkInDate));
        room.setNgayTra(sdf.format(checkOutDate));
        room.setSoDem(soDem);
        room.setTongTienDuKien(room.getGiaPhong() * soDem);

        return room;
    }
}
