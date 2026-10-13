package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingDichVuItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CustomerBookingHistoryDTO;
import com.mycompany.hotelmanagersystem.booking.dto.RoomBookingDetailDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO chuyên trách các truy vấn chỉ đọc (Read-only / Query) cho Booking.
 * Áp dụng nguyên lý CQS (Command Query Separation) theo QT 2.1 và QT 2.3 trong
 * ARCHITECTURE_RULES.md.
 */
public class BookingQueryDAO {

    /**
     * Lấy danh sách lịch sử đặt phòng của một khách hàng (MaKH)
     */
    public List<CustomerBookingHistoryDTO> getBookingHistoryByCustomer(String maKH) {
        String sql = "SELECT b.BookingId AS MaBooking, CAST(COUNT(br.RoomId) AS VARCHAR) + N' phòng' AS SoPhong, "
                + "       N'' AS TenLoaiPhong, b.CreateDate AS NgayDat, "
                + "       MIN(br.ExpectedCheckInDate) AS NgayNhanDuKien, MAX(br.ExpectedCheckOutDate) AS NgayTraDuKien, "
                + "       ISNULL(inv.FinalTotalAmount, 0) AS ChiPhiDuKien, "
                + "       ISNULL(MIN(br.BookingStatus), 'Confirmed') AS TrangThaiBooking, "
                + "       inv.InvoiceId AS MaHoaDon, inv.InvoiceStatus AS TrangThaiHoaDon "
                + "FROM Booking b "
                + "LEFT JOIN Booking_Room br ON b.BookingId = br.BookingId "
                + "LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId "
                + "WHERE b.CustomerId = ? "
                + "GROUP BY b.BookingId, b.CreateDate, inv.FinalTotalAmount, inv.InvoiceId, inv.InvoiceStatus "
                + "ORDER BY b.CreateDate DESC";
        return executeBookingHistoryQuery(sql, maKH);
    }

    /**
     * Lấy danh sách lịch sử đặt phòng của một tài khoản Web (MaTaiKhoan)
     */
    public List<CustomerBookingHistoryDTO> getBookingHistoryByAccountId(String maTaiKhoan) {
        if (maTaiKhoan == null || maTaiKhoan.trim().isEmpty()) {
            return new ArrayList<>();
        }
        String sql = "SELECT b.BookingId AS MaBooking, CAST(COUNT(br.RoomId) AS VARCHAR) + N' phòng' AS SoPhong, "
                + "       N'' AS TenLoaiPhong, b.CreateDate AS NgayDat, "
                + "       MIN(br.ExpectedCheckInDate) AS NgayNhanDuKien, MAX(br.ExpectedCheckOutDate) AS NgayTraDuKien, "
                + "       ISNULL(inv.FinalTotalAmount, 0) AS ChiPhiDuKien, "
                + "       ISNULL(MIN(br.BookingStatus), 'Confirmed') AS TrangThaiBooking, "
                + "       inv.InvoiceId AS MaHoaDon, inv.InvoiceStatus AS TrangThaiHoaDon "
                + "FROM Booking b "
                + "LEFT JOIN Booking_Room br ON b.BookingId = br.BookingId "
                + "LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId "
                + "WHERE b.CreateBy = ? "
                + "GROUP BY b.BookingId, b.CreateDate, inv.FinalTotalAmount, inv.InvoiceId, inv.InvoiceStatus "
                + "ORDER BY b.CreateDate DESC";
        return executeBookingHistoryQuery(sql, maTaiKhoan.trim());
    }

    /**
     * Điều phối lấy chi tiết toàn diện của 1 booking
     */
    public BookingDetailDTO getBookingDetailById(String maBooking) {
        try (Connection conn = DBContext.getConnection()) {
            BookingDetailDTO dto = fetchBookingHeader(conn, maBooking);
            if (dto == null) {
                return null;
            }

            List<RoomBookingDetailDTO> rooms = fetchBookingRooms(conn, maBooking);
            attachBookingServicesToRooms(conn, maBooking, rooms);
            dto.setDanhSachPhong(rooms);
            return dto;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Trách nhiệm: Thực thi truy vấn danh sách lịch sử đặt phòng và chuyển đổi dữ
     * liệu
     */
    private List<CustomerBookingHistoryDTO> executeBookingHistoryQuery(String sql, String parameterValue) {
        List<CustomerBookingHistoryDTO> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, parameterValue);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToBookingHistoryDTO(rs));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Trách nhiệm: Ánh xạ 1 dòng ResultSet sang CustomerBookingHistoryDTO
     */
    private CustomerBookingHistoryDTO mapRowToBookingHistoryDTO(ResultSet rs) throws SQLException {
        Date nhan = rs.getDate("NgayNhanDuKien");
        Date tra = rs.getDate("NgayTraDuKien");
        int soDem = calculateNights(nhan, tra);

        return new CustomerBookingHistoryDTO(
                rs.getString("MaBooking"),
                rs.getString("SoPhong"),
                rs.getNString("TenLoaiPhong"),
                rs.getTimestamp("NgayDat"),
                nhan,
                tra,
                soDem,
                rs.getDouble("ChiPhiDuKien"),
                rs.getString("TrangThaiBooking"),
                rs.getString("MaHoaDon"),
                rs.getString("TrangThaiHoaDon"));
    }

    /**
     * Trách nhiệm: Truy vấn thông tin chung của đơn đặt phòng (Header)
     */
    private BookingDetailDTO fetchBookingHeader(Connection conn, String maBooking) throws SQLException {
        String bookingSql = "SELECT b.BookingId AS MaBooking, b.CreateBy AS MaTaiKhoan, b.CreateDate AS NgayDat, "
                + "       (SELECT TOP 1 br.BookingStatus FROM Booking_Room br WHERE br.BookingId = b.BookingId) AS TrangThaiBooking, "
                + "       inv.FinalTotalAmount AS ChiPhiDuKien, c.CustomerId AS MaKH, c.FullName AS HoTen, "
                + "       c.PhoneNumber AS SoDT, c.Email, c.CCCD, inv.InvoiceId AS MaHoaDon, "
                + "       inv.InvoiceStatus AS TrangThaiHoaDon "
                + "FROM Booking b "
                + "INNER JOIN Customer c ON b.CustomerId = c.CustomerId "
                + "LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId "
                + "WHERE b.BookingId = ?";

        try (PreparedStatement ps = conn.prepareStatement(bookingSql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BookingDetailDTO dto = new BookingDetailDTO();
                    dto.setMaBooking(rs.getString("MaBooking"));
                    dto.setMaTaiKhoan(rs.getString("MaTaiKhoan"));
                    dto.setNgayDat(rs.getTimestamp("NgayDat"));
                    dto.setTrangThaiBooking(rs.getString("TrangThaiBooking"));
                    dto.setMaKH(rs.getString("MaKH"));
                    dto.setHoTenKhachHang(rs.getNString("HoTen"));
                    dto.setSoDT(rs.getString("SoDT"));
                    dto.setEmail(rs.getString("Email"));
                    dto.setCccd(rs.getString("CCCD"));
                    dto.setMaHoaDon(rs.getString("MaHoaDon"));
                    dto.setTrangThaiHoaDon(rs.getString("TrangThaiHoaDon"));
                    dto.setTongChiPhiDuKien(rs.getDouble("ChiPhiDuKien"));
                    return dto;
                }
            }
        }
        return null;
    }

    /**
     * Trách nhiệm: Truy vấn danh sách các phòng trong đơn đặt phòng
     */
    private List<RoomBookingDetailDTO> fetchBookingRooms(Connection conn, String maBooking) throws SQLException {
        String roomsSql = "SELECT br.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, br.Price AS DonGiaPhong, br.Deposit AS TienCoc, "
                + "       br.ExpectedCheckInDate AS NgayNhanDuKien, br.ExpectedCheckOutDate AS NgayTraDuKien, "
                + "       br.ActualCheckInDate AS NgayCheckInThucTe, br.ActualCheckOutDate AS NgayCheckOutThucTe "
                + "FROM Booking_Room br "
                + "INNER JOIN Room r ON br.RoomId = r.RoomId "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE br.BookingId = ?";

        List<RoomBookingDetailDTO> rooms = new ArrayList<>();
        try (PreparedStatement psRooms = conn.prepareStatement(roomsSql)) {
            psRooms.setString(1, maBooking);
            try (ResultSet rs = psRooms.executeQuery()) {
                while (rs.next()) {
                    Date nhan = rs.getDate("NgayNhanDuKien");
                    Date tra = rs.getDate("NgayTraDuKien");
                    int soDem = calculateNights(nhan, tra);

                    RoomBookingDetailDTO r = new RoomBookingDetailDTO(
                            rs.getString("MaPhong"),
                            rs.getString("SoPhong"),
                            rs.getString("MaLoaiPhong"),
                            rs.getNString("TenLoaiPhong"),
                            rs.getDouble("DonGiaPhong"),
                            nhan,
                            tra,
                            soDem);
                    r.setNgayCheckInThucTe(rs.getTimestamp("NgayCheckInThucTe"));
                    r.setNgayCheckOutThucTe(rs.getTimestamp("NgayCheckOutThucTe"));
                    r.setTienCoc(rs.getDouble("TienCoc"));
                    rooms.add(r);
                }
            }
        }
        return rooms;
    }

    /**
     * Trách nhiệm: Truy vấn các dịch vụ đã đặt và gắn vào đúng phòng tương ứng
     */
    private void attachBookingServicesToRooms(Connection conn, String maBooking, List<RoomBookingDetailDTO> rooms)
            throws SQLException {
        String servicesSql = "SELECT (brs.RoomId + '_' + brs.ServiceId) AS MaBookingDichVu, "
                + "       brs.RoomId AS MaPhong, brs.ServiceId AS MaDichVu, s.ServiceName AS TenDichVu, "
                + "       brs.UnitPrice AS DonGia, brs.Quantity AS SoLuong, b.CreateDate AS ThoiDiemThem, "
                + "       'KhachHang' AS NguoiThem "
                + "FROM Booking_Room_Service brs "
                + "INNER JOIN Service s ON brs.ServiceId = s.ServiceId "
                + "INNER JOIN Booking b ON brs.BookingId = b.BookingId "
                + "WHERE brs.BookingId = ? "
                + "ORDER BY s.ServiceName ASC";

        try (PreparedStatement psServices = conn.prepareStatement(servicesSql)) {
            psServices.setString(1, maBooking);
            try (ResultSet rs = psServices.executeQuery()) {
                while (rs.next()) {
                    String maPhong = rs.getString("MaPhong");
                    BookingDichVuItemDTO item = new BookingDichVuItemDTO(
                            rs.getString("MaBookingDichVu"),
                            rs.getString("MaDichVu"),
                            rs.getNString("TenDichVu"),
                            rs.getDouble("DonGia"),
                            rs.getInt("SoLuong"),
                            rs.getTimestamp("ThoiDiemThem"),
                            rs.getString("NguoiThem"));

                    for (RoomBookingDetailDTO room : rooms) {
                        if (room.getMaPhong() != null && room.getMaPhong().equalsIgnoreCase(maPhong)) {
                            room.addDichVu(item);
                            break;
                        }
                    }
                }
            }
        }
    }

    private int calculateNights(Date nhan, Date tra) {
        if (nhan != null && tra != null) {
            long diff = tra.getTime() - nhan.getTime();
            return (int) Math.max(1, diff / (24 * 60 * 60 * 1000));
        }
        return 1;
    }
}
