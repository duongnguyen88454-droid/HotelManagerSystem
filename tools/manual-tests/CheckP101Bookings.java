import com.mycompany.hotelmanagersystem.common.config.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CheckP101Bookings {
    public static void main(String[] args) {
        try (Connection conn = DBContext.getConnection()) {
            System.out.println("Checking P101 bookings in DB...");
            String sql = "SELECT b.MaBooking, bp.MaPhong, bp.NgayNhanDuKien, bp.NgayTraDuKien, b.TrangThai "
                       + "FROM BOOKING_PHONG bp JOIN BOOKING b ON bp.MaBooking = b.MaBooking "
                       + "WHERE bp.MaPhong = 'P101'";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.printf("Booking: %s, Room: %s, In: %s, Out: %s, Status: %s%n",
                            rs.getString(1), rs.getString(2), rs.getDate(3), rs.getDate(4), rs.getString(5));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
