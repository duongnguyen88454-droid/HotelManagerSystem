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
     * Gọi sp_TaoHoaDon để tạo mới hoặc cập nhật hóa đơn quyết toán/tạm tính.
     */
    public String createOrUpdateInvoice(String maBooking, String maNV) throws SQLException, ClassNotFoundException {
        String sql = "{call sp_TaoHoaDon(?, ?, ?)}";
        try (Connection conn = DBContext.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            cs.setString(1, maBooking);
            cs.setString(2, maNV);
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.execute();
            return cs.getString(3);
        }
    }

    /**
     * Truy vấn thông tin tiêu đề hóa đơn theo mã hóa đơn.
     */
    public InvoiceDetailDTO getInvoiceHeader(String maHoaDon) throws SQLException, ClassNotFoundException {
        String sql = "SELECT hd.MaHoaDon, hd.MaBooking, hd.NgayLap, hd.TongTienCuoiCung, " +
                     "       hd.TrangThai AS TrangThaiHoaDon, b.MaKH, kh.HoTen AS TenKhachHang, " +
                     "       kh.SoDT, kh.CCCD, nv.HoTen AS TenNVLap " +
                     "FROM HOADON hd " +
                     "INNER JOIN BOOKING b ON hd.MaBooking = b.MaBooking " +
                     "INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH " +
                     "LEFT JOIN NHANVIEN nv ON hd.MaNV = nv.MaNV " +
                     "WHERE hd.MaHoaDon = ?";
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
        String sql = "SELECT bp.MaPhong, lp.TenLoaiPhong, bp.DonGiaPhong, " +
                     "       bp.NgayNhanDuKien, bp.NgayTraDuKien, bp.NgayCheckInThucTe, bp.NgayCheckOutThucTe, " +
                     "       DATEDIFF(DAY, bp.NgayNhanDuKien, " +
                     "                ISNULL(CAST(bp.NgayCheckOutThucTe AS DATE), bp.NgayTraDuKien)) AS SoDem " +
                     "FROM BOOKING_PHONG bp " +
                     "INNER JOIN PHONG p ON bp.MaPhong = p.MaPhong " +
                     "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong " +
                     "WHERE bp.MaBooking = ?";
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
        String sql = "SELECT bdv.MaBookingDichVu, bdv.MaPhong, dv.TenDichVu, bdv.DonGia, bdv.SoLuong, " +
                     "       (bdv.DonGia * bdv.SoLuong) AS ThanhTien, bdv.ThoiDiemThem " +
                     "FROM BOOKING_DICHVU bdv " +
                     "INNER JOIN DICHVU dv ON bdv.MaDichVu = dv.MaDichVu " +
                     "WHERE bdv.MaBooking = ? " +
                     "ORDER BY bdv.ThoiDiemThem ASC";
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
        String sql = "SELECT MaHoaDon FROM HOADON WHERE MaBooking = ?";
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
