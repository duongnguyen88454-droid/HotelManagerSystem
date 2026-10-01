package scratch;

import com.mycompany.hotelmanagersystem.dao.booking.BookingDAO;
import com.mycompany.hotelmanagersystem.dao.room.RoomDAO;
import java.sql.Date;
import java.time.LocalDate;

public class TestSingleTC01 {
    public static void main(String[] args) {
        try {
            System.out.println("Starting TC01 test...");
            BookingDAO bookingDAO = new BookingDAO();
            RoomDAO roomDAO = new RoomDAO();
            LocalDate baseDate = LocalDate.of(2029, 6, 1);
            Date checkIn = Date.valueOf(baseDate);
            Date checkOut = Date.valueOf(baseDate.plusDays(3));

            System.out.println("Calling createOnlineBookingWithServices...");
            String bookingId = bookingDAO.createOnlineBookingWithServices("KH001", "TK001", "P101", checkIn, checkOut, 450000, 1350000, null, "Test TC01");
            System.out.println("Created booking successfully: " + bookingId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
