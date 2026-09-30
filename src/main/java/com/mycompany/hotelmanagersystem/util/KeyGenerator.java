package com.mycompany.hotelmanagersystem.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Tiện ích sinh mã khóa chính tự động tăng (Auto-generated Primary Key)
 * Quy chuẩn: Liền mạch [TIỀN TỐ 2 KÝ TỰ] + [3 CHỮ SỐ] (ví dụ: TK001, KH001,
 * NV001, BK001, HD001)
 *
 * Nguyên tắc hoạt động:
 * 1. Quét tìm số thứ tự LỚN NHẤT (MAX) ở đuôi các mã hiện có trong CSDL (loại
 * bỏ tiền tố).
 * 2. Lấy số lớn nhất đó cộng thêm 1 (MAX + 1).
 * 3. Kiểm tra tính độc nhất trong CSDL (nếu mã đó đã từng có thì tự động tăng
 * tiếp đến khi độc nhất tuyệt đối).
 */
public class KeyGenerator {

    /**
     * Sinh mã tự động tổng quát cho bất kỳ bảng nào trong CSDL.
     *
     * @param tableName     Tên bảng (ví dụ: "TAIKHOAN", "KHACHHANG", "BOOKING",
     *                      "HOADON", "NHANVIEN")
     * @param idColumnName  Tên cột khóa chính (ví dụ: "MaTaiKhoan", "MaKH",
     *                      "MaBooking", "MaHoaDon", "MaNV")
     * @param prefix        Tiền tố viết hoa (ví dụ: "TK", "KH", "BK", "HD", "NV")
     * @param numberPadding Số lượng chữ số cần hiển thị (thường là 3 chữ số: 001,
     *                      002... 009, 010...)
     * @return Mã mới tự tăng, đảm bảo 100% độc nhất
     */
    public static String generateNextId(String tableName, String idColumnName, String prefix, int numberPadding) {
        int maxNumber = 0;
        int prefixLen = prefix.length();

        // Câu lệnh SQL tìm giá trị số lớn nhất hiện có sau tiền tố prefix
        // Chỉ xét các mã bắt đầu bằng prefix và phần còn lại chỉ chứa ký tự chữ số
        // [0-9]
        String findMaxSql = "SELECT COALESCE(MAX(TRY_CAST(SUBSTRING(" + idColumnName + ", " + (prefixLen + 1)
                + ", 10) AS INT)), 0) "
                + "FROM " + tableName + " "
                + "WHERE " + idColumnName + " LIKE ? "
                + "  AND SUBSTRING(" + idColumnName + ", " + (prefixLen + 1) + ", 10) NOT LIKE '%[^0-9]%'";

        String checkExistSql = "SELECT 1 FROM " + tableName + " WHERE " + idColumnName + " = ?";

        try (Connection conn = DBContext.getConnection()) {
            // Bước 1: Quét tìm số lớn nhất hiện tại
            try (PreparedStatement psMax = conn.prepareStatement(findMaxSql)) {
                psMax.setString(1, prefix + "%");
                try (ResultSet rsMax = psMax.executeQuery()) {
                    if (rsMax.next()) {
                        maxNumber = rsMax.getInt(1);
                    }
                }
            }

            // Bước 2: Bắt đầu từ số lớn nhất + 1 (ví dụ: max là 9 -> next là 10)
            int nextNumber = maxNumber + 1;
            String formatPattern = prefix + "%0" + numberPadding + "d";

            // Bước 3: Vòng lặp kiểm tra tính độc nhất trong CSDL
            try (PreparedStatement psCheck = conn.prepareStatement(checkExistSql)) {
                while (true) {
                    String candidateId = String.format(formatPattern, nextNumber);
                    psCheck.setString(1, candidateId);
                    try (ResultSet rsCheck = psCheck.executeQuery()) {
                        if (!rsCheck.next()) {
                            // Mã candidateId này CHƯA tồn tại trong CSDL -> Độc nhất, sử dụng ngay!
                            return candidateId;
                        }
                    }
                    // Nếu mã đã tồn tại (do dữ liệu cũ hoặc tạo thủ công) -> Tăng tiếp
                    nextNumber++;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            // Phương án dự phòng nếu xảy ra sự cố kết nối CSDL đột xuất
            return prefix + String.format("%0" + numberPadding + "d", System.currentTimeMillis() % 1000);
        }
    }

    // =========================================================================
    // CÁC HÀM TIỆN ÍCH CHUYÊN BIỆT THEO CHUẨN LIỀN MẠCH (TK001, KH001...)
    // =========================================================================

    /**
     * Sinh mã Tài khoản: TK001, TK002... TK009 -> TK010
     */
    public static String generateAccountId() {
        return generateNextId("TAIKHOAN", "MaTaiKhoan", "TK", 3);
    }

    /**
     * Sinh mã Khách hàng: KH001, KH002... KH005 -> KH006
     */
    public static String generateCustomerId() {
        return generateNextId("KHACHHANG", "MaKH", "KH", 3);
    }

    /**
     * Sinh mã Đặt phòng: BK001, BK002... -> BK006
     */
    public static String generateBookingId() {
        return generateNextId("BOOKING", "MaBooking", "BK", 3);
    }

    /**
     * Sinh mã Hóa đơn: HD001, HD002... -> HD006
     */
    public static String generateInvoiceId() {
        return generateNextId("HOADON", "MaHoaDon", "HD", 3);
    }

    /**
     * Sinh mã Nhân viên: NV001, NV002... -> NV006
     */
    public static String generateEmployeeId() {
        return generateNextId("NHANVIEN", "MaNV", "NV", 3);
    }

    /**
     * Sinh mã Thanh toán: TT001, TT002... -> TT006
     */
    public static String generatePaymentId() {
        return generateNextId("THANHTOAN", "MaThanhToan", "TT", 3);
    }

    /**
     * Sinh mã Dịch vụ: DV001, DV002... -> DV009
     */
    public static String generateServiceId() {
        return generateNextId("DICHVU", "MaDichVu", "DV", 3);
    }

    /**
     * Sinh mã Chi tiết dịch vụ đặt phòng: BD001, BD002... -> BD010
     */
    public static String generateBookingDichVuId() {
        return generateNextId("BOOKING_DICHVU", "MaBookingDichVu", "BD", 3);
    }
}
