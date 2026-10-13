package com.mycompany.hotelmanagersystem.cashier.dao;

import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceDetailDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceRoomItemDTO;
import com.mycompany.hotelmanagersystem.cashier.dto.InvoiceServiceItemDTO;
import com.mycompany.hotelmanagersystem.common.config.DBContext;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO phụ trách tạo hóa đơn (sp_TaoHoaDon) và truy vấn chi tiết hóa đơn quyết toán.
 */
public class InvoiceDAO {

    /**
     * Lấy mã hóa đơn tương ứng với đơn đặt phòng.
     */
    public String createOrUpdateInvoice(String maBooking, String maNV) throws SQLException, ClassNotFoundException {
        String findSql = "SELECT InvoiceId FROM Invoice WHERE BookingId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(findSql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("InvoiceId");
                }
            }
        }
        return null;
    }

    /**
     * Truy vấn thông tin tiêu đề hóa đơn theo mã hóa đơn.
     */
    public InvoiceDetailDTO getInvoiceHeader(String maHoaDon) throws SQLException, ClassNotFoundException {
        String sql = "SELECT inv.InvoiceId AS MaHoaDon, inv.BookingId AS MaBooking, inv.CreateDate AS NgayLap, " +
                     "       inv.TotalRoomCharge, inv.TotalServiceCharge, inv.EarlyCheckInFee, inv.LateCheckOutFee, " +
                     "       inv.FinalTotalAmount AS TongTienCuoiCung, inv.InvoiceStatus AS TrangThaiHoaDon, " +
                     "       b.CustomerId AS MaKH, c.FullName AS TenKhachHang, " +
                     "       c.PhoneNumber AS SoDT, c.CCCD, ISNULL(acc.Username, N'Hệ Thống') AS TenNVLap " +
                     "FROM Invoice inv " +
                     "INNER JOIN Booking b ON inv.BookingId = b.BookingId " +
                     "INNER JOIN Customer c ON b.CustomerId = c.CustomerId " +
                     "LEFT JOIN Account acc ON b.CreateBy = acc.AccountId " +
                     "WHERE inv.InvoiceId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maHoaDon);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToInvoiceDetail(rs);
                }
            }
        }
        return null;
    }

    /**
     * Truy vấn danh sách tiền phòng trong hóa đơn theo mã Booking.
     */
    public List<InvoiceRoomItemDTO> getInvoiceRooms(String maBooking) throws SQLException, ClassNotFoundException {
        List<InvoiceRoomItemDTO> list = new ArrayList<>();
        String sql = "SELECT br.RoomId AS MaPhong, rt.RoomTypeName AS TenLoaiPhong, br.Price AS DonGiaPhong, " +
                     "       br.ExpectedCheckInDate AS NgayNhanDuKien, br.ExpectedCheckOutDate AS NgayTraDuKien, " +
                     "       br.ActualCheckInDate AS NgayCheckInThucTe, br.ActualCheckOutDate AS NgayCheckOutThucTe, " +
                     "       DATEDIFF(DAY, br.ExpectedCheckInDate, " +
                     "                ISNULL(CAST(br.ActualCheckOutDate AS DATE), br.ExpectedCheckOutDate)) AS SoDem " +
                     "FROM Booking_Room br " +
                     "INNER JOIN Room r ON br.RoomId = r.RoomId " +
                     "INNER JOIN RoomType rt ON r.RoomTypeId = rt.RoomTypeId " +
                     "WHERE br.BookingId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToInvoiceRoom(rs));
                }
            }
        }
        return list;
    }

    /**
     * Truy vấn danh sách dịch vụ phát sinh trong hóa đơn theo mã Booking.
     */
    public List<InvoiceServiceItemDTO> getInvoiceServices(String maBooking)
            throws SQLException, ClassNotFoundException {
        List<InvoiceServiceItemDTO> list = new ArrayList<>();
        String sql = "SELECT (brs.BookingId + '_' + brs.RoomId + '_' + brs.ServiceId) AS MaBookingDichVu, " +
                     "       brs.RoomId AS MaPhong, s.ServiceName AS TenDichVu, " +
                     "       brs.UnitPrice AS DonGia, brs.Quantity AS SoLuong, " +
                     "       (brs.UnitPrice * brs.Quantity) AS ThanhTien, GETDATE() AS ThoiDiemThem " +
                     "FROM Booking_Room_Service brs " +
                     "INNER JOIN Service s ON brs.ServiceId = s.ServiceId " +
                     "WHERE brs.BookingId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToInvoiceService(rs));
                }
            }
        }
        return list;
    }

    /**
     * Tìm mã hóa đơn tương ứng với đơn đặt phòng (nếu đã được sinh).
     */
    public String findInvoiceIdByBooking(String maBooking) throws SQLException, ClassNotFoundException {
        String sql = "SELECT InvoiceId AS MaHoaDon FROM Invoice WHERE BookingId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("MaHoaDon");
                }
            }
        }
        return null;
    }

    private InvoiceDetailDTO mapRowToInvoiceDetail(ResultSet rs) throws SQLException {
        InvoiceDetailDTO dto = new InvoiceDetailDTO();
        dto.setMaHoaDon(rs.getString("MaHoaDon"));
        dto.setMaBooking(rs.getString("MaBooking"));
        dto.setNgayLap(rs.getTimestamp("NgayLap"));
        dto.setTongTienCuoiCung(rs.getObject("TongTienCuoiCung") != null
                ? rs.getDouble("TongTienCuoiCung") : null);
        dto.setTotalRoomCharge(rs.getObject("TotalRoomCharge") != null
                ? rs.getDouble("TotalRoomCharge") : 0.0);
        dto.setTotalServiceCharge(rs.getObject("TotalServiceCharge") != null
                ? rs.getDouble("TotalServiceCharge") : 0.0);
        dto.setEarlyCheckInFee(rs.getObject("EarlyCheckInFee") != null
                ? rs.getDouble("EarlyCheckInFee") : 0.0);
        dto.setLateCheckOutFee(rs.getObject("LateCheckOutFee") != null
                ? rs.getDouble("LateCheckOutFee") : 0.0);
        dto.setTrangThaiHoaDon(rs.getString("TrangThaiHoaDon"));
        dto.setMaKH(rs.getString("MaKH"));
        dto.setTenKhachHang(rs.getString("TenKhachHang"));
        dto.setSoDT(rs.getString("SoDT"));
        dto.setCccd(rs.getString("CCCD"));
        dto.setTenNVLap(rs.getString("TenNVLap"));
        return dto;
    }

    private InvoiceRoomItemDTO mapRowToInvoiceRoom(ResultSet rs) throws SQLException {
        int soDem = rs.getInt("SoDem");
        if (soDem <= 0) {
            soDem = 1;
        }
        double donGia = rs.getDouble("DonGiaPhong");
        return new InvoiceRoomItemDTO(
                rs.getString("MaPhong"),
                rs.getString("TenLoaiPhong"),
                donGia,
                rs.getTimestamp("NgayNhanDuKien"),
                rs.getTimestamp("NgayTraDuKien"),
                rs.getTimestamp("NgayCheckInThucTe"),
                rs.getTimestamp("NgayCheckOutThucTe"),
                soDem,
                donGia * soDem
        );
    }

    private InvoiceServiceItemDTO mapRowToInvoiceService(ResultSet rs) throws SQLException {
        return new InvoiceServiceItemDTO(
                rs.getString("MaBookingDichVu"),
                rs.getString("MaPhong"),
                rs.getString("TenDichVu"),
                rs.getDouble("DonGia"),
                rs.getInt("SoLuong"),
                rs.getDouble("ThanhTien"),
                rs.getTimestamp("ThoiDiemThem")
        );
    }
}
