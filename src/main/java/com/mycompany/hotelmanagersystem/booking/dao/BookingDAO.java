package com.mycompany.hotelmanagersystem.booking.dao;

import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
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
import java.util.Map;

/**
 * Data Access Object quản lý toàn diện các nghiệp vụ Đặt phòng (Booking),
 * Dịch vụ phòng, Hóa đơn đi kèm và Lịch sử lưu trú.
 * 
 * Áp dụng triệt để nguyên lý Single Responsibility Principle (SRP):
 * Mỗi hàm chỉ đảm nhận một trách nhiệm duy nhất (Điều phối, Kiểm tra, Chèn dữ
 * liệu, Tra cứu, Cập nhật chi phí).
 */
public class BookingDAO {

    // =========================================================================
    // 1. CÁC HÀM ĐIỀU PHỐI TẠO ĐƠN ĐẶT PHÒNG (TRANSACTION ORCHESTRATORS)
    // =========================================================================

    /**
     * Điều phối tạo đơn đặt phòng trực tuyến 1 phòng kèm dịch vụ trong 1
     * Transaction
     */
    public String createOnlineBookingWithServices(String maKH, String maTaiKhoan, String maPhong, Date checkIn,
            Date checkOut,
            double donGiaPhong, double tongChiPhi,
            Map<String, Integer> selectedServices, String ghiChu) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            validateRoomAvailability(conn, maPhong, checkIn, checkOut);
            String maBooking = getNextBookingIdFromDB(conn);
            insertBookingHeader(conn, maBooking, maKH, maTaiKhoan, tongChiPhi);
            insertBookingRoom(conn, maBooking, maPhong, donGiaPhong, checkIn, checkOut);
            insertBookingServices(conn, maBooking, maPhong, selectedServices);
            ensureInvoiceExists(conn, maBooking);

            conn.commit();
            return maBooking;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    /**
     * Điều phối tạo đơn đặt đa phòng kèm dịch vụ riêng cho từng phòng trong 1
     * Transaction
     */
    public String createMultiRoomBookingWithServices(String maKH, String maTaiKhoan, BookingCartDTO cart, String ghiChu)
            throws Exception {
        if (cart == null || cart.getTotalRoomCount() == 0) {
            throw new IllegalArgumentException("Giỏ đặt phòng đang trống, vui lòng chọn ít nhất 1 phòng!");
        }

        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            for (CartRoomItemDTO roomItem : cart.getItems().values()) {
                Date dIn = Date.valueOf(roomItem.getNgayNhan());
                Date dOut = Date.valueOf(roomItem.getNgayTra());
                validateRoomAvailability(conn, roomItem.getMaPhong(), dIn, dOut);
            }

            String maBooking = getNextBookingIdFromDB(conn);
            insertBookingHeader(conn, maBooking, maKH, maTaiKhoan, cart.getGrandTotal());

            for (CartRoomItemDTO roomItem : cart.getItems().values()) {
                Date dIn = Date.valueOf(roomItem.getNgayNhan());
                Date dOut = Date.valueOf(roomItem.getNgayTra());
                insertBookingRoom(conn, maBooking, roomItem.getMaPhong(), roomItem.getDonGiaPhong(), dIn, dOut);
            }

            for (CartRoomItemDTO roomItem : cart.getItems().values()) {
                List<CartServiceItemDTO> svcs = roomItem.getSelectedServices();
                if (svcs != null && !svcs.isEmpty()) {
                    for (CartServiceItemDTO svc : svcs) {
                        if (svc.getSoLuong() > 0) {
                            insertSingleBookingService(conn, maBooking, roomItem.getMaPhong(),
                                    svc.getMaDichVu(), svc.getDonGia(), svc.getSoLuong(), "KhachHang");
                        }
                    }
                }
            }

            ensureInvoiceExists(conn, maBooking);
            conn.commit();
            return maBooking;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    public String createMultiRoomBookingWithServices(String maKH, BookingCartDTO cart, String ghiChu) throws Exception {
        return createMultiRoomBookingWithServices(maKH, null, cart, ghiChu);
    }

    // =========================================================================
    // 2. CÁC HÀM ĐIỀU PHỐI DỊCH VỤ PHÒNG (SERVICE ORCHESTRATORS)
    // =========================================================================

    /**
     * Điều phối thêm dịch vụ vào phòng cụ thể trong đơn booking
     */
    public boolean addServiceToBookingRoom(String maBooking, String maPhong, String maDichVu, int soLuong,
            String nguoiThem) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            validateRoomBelongsToBooking(conn, maBooking, maPhong);
            double donGia = getActiveServicePrice(conn, maDichVu);
            insertSingleBookingService(conn, maBooking, maPhong, maDichVu, donGia, soLuong,
                    nguoiThem != null ? nguoiThem : "KhachHang");
            updateBookingTotalCost(conn, maBooking, donGia * soLuong);

            conn.commit();
            return true;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    /**
     * Điều phối xóa dịch vụ khỏi phòng đã đặt (khi chưa check-in)
     */
    public boolean removeServiceFromBookingRoom(String maBookingDichVu, String maBooking) throws Exception {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            double thanhTien = getBookingServiceCost(conn, maBookingDichVu, maBooking);
            if (thanhTien < 0) {
                conn.rollback();
                return false;
            }

            deleteBookingServiceRecord(conn, maBookingDichVu, maBooking);
            updateBookingTotalCost(conn, maBooking, -thanhTien);

            conn.commit();
            return true;
        } catch (Exception e) {
            rollbackTransaction(conn);
            throw e;
        } finally {
            closeTransactionConnection(conn);
        }
    }

    // =========================================================================
    // 3. CÁC HÀM TRA CỨU DỮ LIỆU (QUERY ORCHESTRATORS)
    // =========================================================================

    /**
     * Lấy danh sách lịch sử đặt phòng của một khách hàng (MaKH)
     */
    public List<CustomerBookingHistoryDTO> getBookingHistoryByCustomer(String maKH) {
        String sql = "SELECT b.MaBooking, p.SoPhong, lp.TenLoaiPhong, b.NgayDat, "
                + "       bp.NgayNhanDuKien, bp.NgayTraDuKien, b.ChiPhiDuKien, "
                + "       b.TrangThai AS TrangThaiBooking, hd.MaHoaDon, hd.TrangThai AS TrangThaiHoaDon "
                + "FROM BOOKING b "
                + "INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking "
                + "INNER JOIN PHONG p ON bp.MaPhong = p.MaPhong "
                + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                + "LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking "
                + "WHERE b.MaKH = ? "
                + "ORDER BY b.NgayDat DESC";
        return executeBookingHistoryQuery(sql, maKH);
    }

    /**
     * Lấy danh sách lịch sử đặt phòng của một tài khoản Web (MaTaiKhoan)
     */
    public List<CustomerBookingHistoryDTO> getBookingHistoryByAccountId(String maTaiKhoan) {
        if (maTaiKhoan == null || maTaiKhoan.trim().isEmpty()) {
            return new ArrayList<>();
        }
        String sql = "SELECT b.MaBooking, p.SoPhong, lp.TenLoaiPhong, b.NgayDat, "
                + "       bp.NgayNhanDuKien, bp.NgayTraDuKien, b.ChiPhiDuKien, "
                + "       b.TrangThai AS TrangThaiBooking, hd.MaHoaDon, hd.TrangThai AS TrangThaiHoaDon "
                + "FROM BOOKING b "
                + "INNER JOIN BOOKING_PHONG bp ON b.MaBooking = bp.MaBooking "
                + "INNER JOIN PHONG p ON bp.MaPhong = p.MaPhong "
                + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                + "LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking "
                + "WHERE b.MaTaiKhoan = ? "
                + "ORDER BY b.NgayDat DESC";
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
     * Hủy đơn đặt phòng khi chưa Check-in (theo MaKH)
     * Backward-compatible overload — gọi về phương thức đầy đủ.
     */
    public boolean cancelBooking(String maBooking, String maKH) {
        return cancelBooking(maBooking, maKH, null);
    }

    /**
     * [BUG-04 FIX] Hủy đơn đặt phòng theo MaKH HOẶC MaTaiKhoan.
     * Xử lý trường hợp user mới đăng ký qua web chưa có MaDinhDanh (KH profile).
     */
    public boolean cancelBooking(String maBooking, String maKH, String maTaiKhoan) {
        // OR fallback: nếu MaKH null/không khớp, thử khớp MaTaiKhoan
        String sql = "UPDATE BOOKING "
                + "SET TrangThai = 'DaHuy', ThoiDiemHuy = GETDATE() "
                + "WHERE MaBooking = ? "
                + "  AND TrangThai = 'DaXacNhan' "
                + "  AND (MaKH = ? OR (? IS NOT NULL AND MaTaiKhoan = ?))";

        try (Connection conn = DBContext.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maBooking);
            ps.setString(2, maKH);
            ps.setString(3, maTaiKhoan);
            ps.setString(4, maTaiKhoan);
            return ps.executeUpdate() > 0;
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    // =========================================================================
    // 4. CÁC HÀM CON ĐƠN TRÁCH NHIỆM (SINGLE RESPONSIBILITY HELPERS)
    // =========================================================================

    /**
     * Trách nhiệm: Kiểm tra phòng có khả dụng trong khoảng ngày không (Chống Race
     * Condition)
     */
    private void validateRoomAvailability(Connection conn, String maPhong, Date checkIn, Date checkOut)
            throws SQLException {
        String checkSql = "SELECT 1 FROM PHONG p "
                + "WHERE p.MaPhong = ? "
                + "  AND p.TrangThai <> 'Damaged' "
                + "  AND NOT EXISTS ( "
                + "      SELECT 1 FROM BOOKING_PHONG bp "
                + "      INNER JOIN BOOKING b ON bp.MaBooking = b.MaBooking "
                + "      WHERE bp.MaPhong = p.MaPhong "
                + "        AND b.TrangThai IN ('ChoXacNhan', 'DaXacNhan', 'DaCheckIn') "
                + "        AND NOT (bp.NgayTraDuKien <= ? OR bp.NgayNhanDuKien >= ?) "
                + "  )";
        try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
            psCheck.setString(1, maPhong);
            psCheck.setDate(2, checkIn);
            psCheck.setDate(3, checkOut);
            try (ResultSet rsCheck = psCheck.executeQuery()) {
                if (!rsCheck.next()) {
                    throw new SQLException("Phòng " + maPhong + " vừa có khách khác đặt trước hoặc không khả dụng!");
                }
            }
        }
    }

    /**
     * Trách nhiệm: Chèn thông tin chung vào bảng BOOKING
     */
    private void insertBookingHeader(Connection conn, String maBooking, String maKH, String maTaiKhoan,
            double tongChiPhi) throws SQLException {
        String insertBookingSql = "INSERT INTO BOOKING (MaBooking, MaKH, MaTaiKhoan, MaNV, NgayDat, TrangThai, ChiPhiDuKien) "
                + "VALUES (?, ?, ?, NULL, GETDATE(), 'DaXacNhan', ?)";
        try (PreparedStatement psBooking = conn.prepareStatement(insertBookingSql)) {
            psBooking.setString(1, maBooking);
            psBooking.setString(2, maKH);
            if (maTaiKhoan != null && !maTaiKhoan.trim().isEmpty()) {
                psBooking.setString(3, maTaiKhoan.trim());
            } else {
                psBooking.setNull(3, java.sql.Types.VARCHAR);
            }
            psBooking.setDouble(4, tongChiPhi);
            psBooking.executeUpdate();
        }
    }

    /**
     * Trách nhiệm: Chèn thông tin phòng và thời gian lưu trú vào bảng BOOKING_PHONG
     */
    private void insertBookingRoom(Connection conn, String maBooking, String maPhong, double donGiaPhong, Date checkIn,
            Date checkOut) throws SQLException {
        String insertRoomSql = "INSERT INTO BOOKING_PHONG (MaBooking, MaPhong, DonGiaPhong, NgayNhanDuKien, NgayTraDuKien) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement psRoom = conn.prepareStatement(insertRoomSql)) {
            psRoom.setString(1, maBooking);
            psRoom.setString(2, maPhong);
            psRoom.setDouble(3, donGiaPhong);
            psRoom.setDate(4, checkIn);
            psRoom.setDate(5, checkOut);
            psRoom.executeUpdate();
        }
    }

    /**
     * Trách nhiệm: Tra cứu giá và chèn danh sách dịch vụ đã chọn vào bảng
     * BOOKING_DICHVU
     */
    private void insertBookingServices(Connection conn, String maBooking, String maPhong,
            Map<String, Integer> selectedServices) throws SQLException {
        if (selectedServices == null || selectedServices.isEmpty()) {
            return;
        }

        String selectPriceSql = "SELECT DonGia FROM DICHVU WHERE MaDichVu = ?";
        for (Map.Entry<String, Integer> entry : selectedServices.entrySet()) {
            String maDichVu = entry.getKey();
            int soLuong = entry.getValue() != null ? entry.getValue() : 0;
            if (soLuong > 0) {
                double donGiaDichVu = 0;
                try (PreparedStatement psPrice = conn.prepareStatement(selectPriceSql)) {
                    psPrice.setString(1, maDichVu);
                    try (ResultSet rsPrice = psPrice.executeQuery()) {
                        if (rsPrice.next()) {
                            donGiaDichVu = rsPrice.getDouble("DonGia");
                        }
                    }
                }
                insertSingleBookingService(conn, maBooking, maPhong, maDichVu, donGiaDichVu, soLuong, "KhachHang");
            }
        }
    }

    /**
     * Trách nhiệm: Chèn một bản ghi dịch vụ cụ thể vào bảng BOOKING_DICHVU
     */
    private void insertSingleBookingService(Connection conn, String maBooking, String maPhong,
            String maDichVu, double donGia, int soLuong, String nguoiThem) throws SQLException {
        String insertBdvSql = "INSERT INTO BOOKING_DICHVU (MaBooking, MaPhong, MaDichVu, DonGia, SoLuong, ThoiDiemThem, NguoiThem, MaNV) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE(), ?, NULL)";
        try (PreparedStatement psBdv = conn.prepareStatement(insertBdvSql)) {
            psBdv.setString(1, maBooking);
            psBdv.setString(2, maPhong);
            psBdv.setString(3, maDichVu);
            psBdv.setDouble(4, donGia);
            psBdv.setInt(5, soLuong);
            psBdv.setString(6, nguoiThem);
            psBdv.executeUpdate();
        }
    }

    private String getNextBookingIdFromDB(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT dbo.fn_SinhMaBooking()");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getString(1);
            }
        }
        return "BK001";
    }

    /**
     * Trách nhiệm: Khởi tạo/đồng bộ hóa đơn trong bảng HOADON nếu chưa tồn tại
     */
    private void ensureInvoiceExists(Connection conn, String maBooking) throws SQLException {
        String checkInvoiceSql = "SELECT 1 FROM HOADON WHERE MaBooking = ?";
        boolean hasInvoice = false;
        try (PreparedStatement psCheckInv = conn.prepareStatement(checkInvoiceSql)) {
            psCheckInv.setString(1, maBooking);
            try (ResultSet rsInv = psCheckInv.executeQuery()) {
                if (rsInv.next()) {
                    hasInvoice = true;
                }
            }
        }

        if (!hasInvoice) {
            String insertInvSql = "INSERT INTO HOADON (MaHoaDon, MaBooking, NgayLap, TongTienCuoiCung, MaNV, TrangThai) "
                    + "VALUES (?, ?, GETDATE(), NULL, 'NV001', 'ChuaThanhToan')";
            try (PreparedStatement psInv = conn.prepareStatement(insertInvSql)) {
                String maHoaDon = "HD" + maBooking.substring(2);
                psInv.setString(1, maHoaDon);
                psInv.setString(2, maBooking);
                psInv.executeUpdate();
            }
        }
    }

    /**
     * Trách nhiệm: Kiểm tra phòng có thuộc đơn đặt phòng hay không
     */
    private void validateRoomBelongsToBooking(Connection conn, String maBooking, String maPhong) throws SQLException {
        String checkRoomSql = "SELECT 1 FROM BOOKING_PHONG WHERE MaBooking = ? AND MaPhong = ?";
        try (PreparedStatement psCheck = conn.prepareStatement(checkRoomSql)) {
            psCheck.setString(1, maBooking);
            psCheck.setString(2, maPhong);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Phòng không thuộc đơn đặt phòng này!");
                }
            }
        }
    }

    /**
     * Trách nhiệm: Lấy đơn giá dịch vụ đang áp dụng
     */
    private double getActiveServicePrice(Connection conn, String maDichVu) throws SQLException {
        String selectPriceSql = "SELECT DonGia FROM DICHVU WHERE MaDichVu = ? AND TrangThai = 'ApDung'";
        try (PreparedStatement psPrice = conn.prepareStatement(selectPriceSql)) {
            psPrice.setString(1, maDichVu);
            try (ResultSet rs = psPrice.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("DonGia");
                } else {
                    throw new SQLException("Dịch vụ không tồn tại hoặc đã tạm dừng!");
                }
            }
        }
    }

    /**
     * Trách nhiệm: Cập nhật tổng chi phí dự kiến trong BOOKING (cộng hoặc trừ)
     */
    private void updateBookingTotalCost(Connection conn, String maBooking, double deltaAmount) throws SQLException {
        String updateBookingPriceSql = "UPDATE BOOKING SET ChiPhiDuKien = ChiPhiDuKien + ? WHERE MaBooking = ?";
        try (PreparedStatement psUpdate = conn.prepareStatement(updateBookingPriceSql)) {
            psUpdate.setDouble(1, deltaAmount);
            psUpdate.setString(2, maBooking);
            psUpdate.executeUpdate();
        }
    }

    /**
     * Trách nhiệm: Lấy thành tiền của 1 dịch vụ đã đặt trong phòng (trả về -1 nếu
     * không tìm thấy)
     */
    private double getBookingServiceCost(Connection conn, String maBookingDichVu, String maBooking)
            throws SQLException {
        String selectSql = "SELECT DonGia, SoLuong FROM BOOKING_DICHVU WHERE MaBookingDichVu = ? AND MaBooking = ?";
        try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
            psSelect.setString(1, maBookingDichVu);
            psSelect.setString(2, maBooking);
            try (ResultSet rs = psSelect.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("DonGia") * rs.getInt("SoLuong");
                }
            }
        }
        return -1;
    }

    /**
     * Trách nhiệm: Xóa bản ghi dịch vụ khỏi bảng BOOKING_DICHVU
     */
    private void deleteBookingServiceRecord(Connection conn, String maBookingDichVu, String maBooking)
            throws SQLException {
        String deleteSql = "DELETE FROM BOOKING_DICHVU WHERE MaBookingDichVu = ? AND MaBooking = ?";
        try (PreparedStatement psDelete = conn.prepareStatement(deleteSql)) {
            psDelete.setString(1, maBookingDichVu);
            psDelete.setString(2, maBooking);
            psDelete.executeUpdate();
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
        String bookingSql = "SELECT b.MaBooking, b.MaTaiKhoan, b.NgayDat, b.TrangThai AS TrangThaiBooking, "
                + "       b.ChiPhiDuKien, kh.MaKH, kh.HoTen, kh.SoDT, kh.Email, kh.CCCD, "
                + "       hd.MaHoaDon, hd.TrangThai AS TrangThaiHoaDon "
                + "FROM BOOKING b "
                + "INNER JOIN KHACHHANG kh ON b.MaKH = kh.MaKH "
                + "LEFT JOIN HOADON hd ON b.MaBooking = hd.MaBooking "
                + "WHERE b.MaBooking = ?";

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
        String roomsSql = "SELECT bp.MaPhong, p.SoPhong, lp.MaLoaiPhong, lp.TenLoaiPhong, "
                + "       bp.DonGiaPhong, bp.NgayNhanDuKien, bp.NgayTraDuKien, "
                + "       bp.NgayCheckInThucTe, bp.NgayCheckOutThucTe "
                + "FROM BOOKING_PHONG bp "
                + "INNER JOIN PHONG p ON bp.MaPhong = p.MaPhong "
                + "INNER JOIN LOAIPHONG lp ON p.MaLoaiPhong = lp.MaLoaiPhong "
                + "WHERE bp.MaBooking = ?";

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
        String servicesSql = "SELECT bdv.MaBookingDichVu, bdv.MaPhong, bdv.MaDichVu, dv.TenDichVu, "
                + "       bdv.DonGia, bdv.SoLuong, bdv.ThoiDiemThem, bdv.NguoiThem "
                + "FROM BOOKING_DICHVU bdv "
                + "INNER JOIN DICHVU dv ON bdv.MaDichVu = dv.MaDichVu "
                + "WHERE bdv.MaBooking = ? "
                + "ORDER BY bdv.ThoiDiemThem ASC";

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

    /**
     * Trách nhiệm: Tính toán số đêm lưu trú giữa 2 mốc thời gian (tối thiểu 1 đêm)
     */
    private int calculateNights(Date nhan, Date tra) {
        if (nhan != null && tra != null) {
            long diff = tra.getTime() - nhan.getTime();
            return (int) Math.max(1, diff / (24 * 60 * 60 * 1000));
        }
        return 1;
    }

    /**
     * Trách nhiệm: Hoàn tác Transaction an toàn
     */
    private void rollbackTransaction(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    /**
     * Trách nhiệm: Khôi phục autoCommit và đóng kết nối an toàn
     */
    private void closeTransactionConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
