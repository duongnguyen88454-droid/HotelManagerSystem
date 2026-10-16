package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.BookingDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.BookingDichVuItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CustomerBookingHistoryDTO;
import com.mycompany.hotelmanagersystem.booking.dto.RoomBookingDetailDTO;
import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO chuyên trách các truy vấn chỉ đọc (Read-only / Query) cho Booking.
 * Áp dụng nguyên lý CQS (Command Query Separation) theo QT 2.1 và QT 2.3 trong
 * ARCHITECTURE_RULES.md.
 */
public class BookingQueryDAO extends BaseRepository<CustomerBookingHistoryDTO, String> {

    @Override
    protected String getTableName() {
        return "Booking";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "BookingId";
    }

    @Override
    protected RowMapper<CustomerBookingHistoryDTO> getRowMapper() {
        return this::mapRowToBookingHistoryDTO;
    }

    /**
     * Lấy danh sách lịch sử đặt phòng của một khách hàng (MaKH)
     */
    public List<CustomerBookingHistoryDTO> getBookingHistoryByCustomer(String maKH) {
        String sql = "SELECT * FROM v_CustomerBookingHistory WHERE CustomerId = ? ORDER BY CreateDate DESC";
        return query(sql, maKH);
    }

    /**
     * Lấy danh sách lịch sử đặt phòng của một tài khoản Web (MaTaiKhoan)
     */
    public List<CustomerBookingHistoryDTO> getBookingHistoryByAccountId(String maTaiKhoan) {
        if (maTaiKhoan == null || maTaiKhoan.trim().isEmpty()) {
            return new ArrayList<>();
        }
        String sql = "SELECT * FROM v_CustomerBookingHistory WHERE AccountId = ? ORDER BY CreateDate DESC";
        return query(sql, maTaiKhoan.trim());
    }

    /**
     * Điều phối lấy chi tiết toàn diện của 1 booking
     */
    public BookingDetailDTO getBookingDetailById(String maBooking) {
        BookingDetailDTO dto = fetchBookingHeader(maBooking);
        if (dto == null) {
            return null;
        }

        List<RoomBookingDetailDTO> rooms = fetchRoomsForBooking(maBooking);
        attachBookingServicesToRooms(maBooking, rooms);
        dto.setDanhSachPhong(rooms);
        return dto;
    }

    private CustomerBookingHistoryDTO mapRowToBookingHistoryDTO(ResultSet rs) throws SQLException {
        Date nhan = rs.getDate("ExpectedCheckInDate");
        Date tra = rs.getDate("ExpectedCheckOutDate");
        int soDem = calculateNights(nhan, tra);

        return new CustomerBookingHistoryDTO(
                rs.getString("BookingId"),
                rs.getString("RoomSummary"),
                rs.getNString("RoomTypeName"),
                rs.getTimestamp("CreateDate"),
                nhan,
                tra,
                soDem,
                rs.getDouble("EstimatedTotal"),
                rs.getString("BookingStatus"),
                rs.getString("InvoiceId"),
                rs.getString("InvoiceStatus"));
    }

    private BookingDetailDTO fetchBookingHeader(String maBooking) {
        String bookingSql = "SELECT b.BookingId AS MaBooking, b.CreateBy AS MaTaiKhoan, b.CreateDate AS NgayDat, "
                + "       (SELECT TOP 1 br.BookingStatus FROM Booking_Room br WHERE br.BookingId = b.BookingId) AS TrangThaiBooking, "
                + "       inv.FinalTotalAmount AS ChiPhiDuKien, c.CustomerId AS MaKH, c.FullName AS HoTen, "
                + "       c.PhoneNumber AS SoDT, c.Email, c.CCCD, inv.InvoiceId AS MaHoaDon, "
                + "       inv.InvoiceStatus AS TrangThaiHoaDon "
                + "FROM Booking b "
                + "INNER JOIN Customer c ON b.CustomerId = c.CustomerId "
                + "LEFT JOIN Invoice inv ON b.BookingId = inv.BookingId "
                + "WHERE b.BookingId = ?";

        return queryOneCustom(bookingSql, rs -> {
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
        }, maBooking).orElse(null);
    }

    private List<RoomBookingDetailDTO> fetchRoomsForBooking(String maBooking) {
        String roomsSql = "SELECT br.RoomId AS MaPhong, r.RoomName AS SoPhong, rt.RoomTypeId AS MaLoaiPhong, "
                + "       rt.RoomTypeName AS TenLoaiPhong, br.Price AS DonGiaPhong, br.Deposit AS TienCoc, "
                + "       br.ExpectedCheckInDate AS NgayNhanDuKien, br.ExpectedCheckOutDate AS NgayTraDuKien, "
                + "       br.ActualCheckInDate AS NgayCheckInThucTe, br.ActualCheckOutDate AS NgayCheckOutThucTe "
                + "FROM Booking_Room br "
                + "INNER JOIN Room r ON br.RoomId = r.RoomId "
                + "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId "
                + "WHERE br.BookingId = ?";

        return queryCustom(roomsSql, rs -> {
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
            return r;
        }, maBooking);
    }

    private void attachBookingServicesToRooms(String maBooking, List<RoomBookingDetailDTO> rooms) {
        String servicesSql = "SELECT (brs.RoomId + '_' + brs.ServiceId) AS MaBookingDichVu, "
                + "       brs.RoomId AS MaPhong, brs.ServiceId AS MaDichVu, s.ServiceName AS TenDichVu, "
                + "       brs.UnitPrice AS DonGia, brs.Quantity AS SoLuong, b.CreateDate AS ThoiDiemThem, "
                + "       'KhachHang' AS NguoiThem "
                + "FROM Booking_Room_Service brs "
                + "INNER JOIN Service s ON brs.ServiceId = s.ServiceId "
                + "INNER JOIN Booking b ON brs.BookingId = b.BookingId "
                + "WHERE brs.BookingId = ? "
                + "ORDER BY s.ServiceName ASC";

        queryCustom(servicesSql, rs -> {
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
            return null;
        }, maBooking);
    }

    private int calculateNights(Date nhan, Date tra) {
        if (nhan != null && tra != null) {
            long diff = tra.getTime() - nhan.getTime();
            return (int) Math.max(1, diff / (24 * 60 * 60 * 1000));
        }
        return 1;
    }
}
