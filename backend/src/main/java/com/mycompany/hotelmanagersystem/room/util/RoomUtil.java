package com.mycompany.hotelmanagersystem.room.util;

import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * Lớp tiện ích thuần xử lý dữ liệu và tính toán buồng phòng (QT 2.4 & QT 3.5).
 */
public final class RoomUtil {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private RoomUtil() {
        // Utility class: private constructor chống khởi tạo thể hiện
    }

    public static LocalDate[] parseAndValidateDates(String checkInStr, String checkOutStr) {
        LocalDate today = LocalDate.now();
        LocalDate checkIn;
        LocalDate checkOut;
        try {
            checkIn = (checkInStr != null && !checkInStr.trim().isEmpty()) 
                    ? LocalDate.parse(checkInStr.trim()) : today;
            checkOut = (checkOutStr != null && !checkOutStr.trim().isEmpty()) 
                    ? LocalDate.parse(checkOutStr.trim()) : checkIn.plusDays(1);
        } catch (Exception e) {
            throw new IllegalArgumentException("Định dạng ngày không hợp lệ (Vui lòng chọn theo định dạng yyyy-MM-dd)!");
        }

        if (checkIn.isBefore(today)) {
            throw new IllegalArgumentException("Ngày nhận phòng không thể trước ngày hôm nay (" + today + ")!");
        }
        if (!checkOut.isAfter(checkIn)) {
            throw new IllegalArgumentException("Ngày trả phòng phải sau ngày nhận phòng ít nhất 1 đêm!");
        }
        return new LocalDate[]{checkIn, checkOut};
    }

    public static Integer parseGuests(String guestsStr) {
        if (guestsStr != null && !guestsStr.trim().isEmpty()) {
            try {
                int g = Integer.parseInt(guestsStr.trim());
                return g > 0 ? g : null;
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    public static void applyPricingAndDates(AvailableRoomDTO room, LocalDate checkIn, LocalDate checkOut) {
        int soDem = (int) Math.max(1, ChronoUnit.DAYS.between(checkIn, checkOut));
        room.setNgayNhan(checkIn.format(DATE_FMT));
        room.setNgayTra(checkOut.format(DATE_FMT));
        room.setSoDem(soDem);
        double tongTien = room.getGiaPhong() * soDem;
        room.setTongTienDuKien(tongTien);
        room.setTienCoc((tongTien * room.getDepositPercent()) / 100.0);
    }

    public static int calculateFloor(String soPhong) {
        if (soPhong != null && !soPhong.isEmpty()) {
            char firstChar = soPhong.charAt(0);
            if (Character.isDigit(firstChar)) {
                return Character.getNumericValue(firstChar);
            }
        }
        return 1;
    }

    public static String resolveTimelineStatus(String rawStatus) {
        if (rawStatus == null || rawStatus.isEmpty()) {
            return "Available";
        }
        String[] parts = rawStatus.split("\\|", -1);
        String roomStatus = parts.length > 0 ? parts[0] : "";
        String occStatus  = parts.length > 1 ? parts[1] : "";
        String hkStatus   = parts.length > 2 ? parts[2] : "";

        if ("Maintenance".equalsIgnoreCase(roomStatus) || "OutOfService".equalsIgnoreCase(roomStatus)) {
            return "Damaged";
        }
        if ("Occupied".equalsIgnoreCase(occStatus)) {
            return "Occupied";
        }
        if ("Dirty".equalsIgnoreCase(hkStatus)) {
            return "Dirty";
        }
        if ("Cleaning".equalsIgnoreCase(hkStatus)) {
            return "Cleaning";
        }
        return "Available";
    }
}
