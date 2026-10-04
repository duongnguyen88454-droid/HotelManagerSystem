package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.DailyAuditReportDTO;
import com.mycompany.hotelmanagersystem.manager.dto.MonthlyRevenueDTO;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ManagerReportDAO extends DBContext {

    private static final String SP_DAILY_AUDIT_SQL =
            "{CALL sp_BaoCaoTongHopKinhDoanhTheoNgay(?)}";
    private static final String SELECT_MONTHLY_REVENUE_SQL =
            "SELECT Nam, Thang, SoLuotGiaoDich, SoHoaDonDaThanhToan, TongDoanhThuThucThu "
                    + "FROM v_BaoCaoDoanhThuTheoThang ORDER BY Nam DESC, Thang DESC";
    private static final String FN_REVENUE_BY_RANGE_SQL =
            "SELECT dbo.fn_DoanhThuTheoKhoangThoiGian(?, ?) AS TongDoanhThu";

    public DailyAuditReportDTO getDailyAuditReport(LocalDate reportDate) {
        LocalDate targetDate = (reportDate != null) ? reportDate : LocalDate.now();
        try (Connection conn = getConnection();
             CallableStatement cs = conn.prepareCall(SP_DAILY_AUDIT_SQL)) {
            cs.setDate(1, Date.valueOf(targetDate));
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return mapDailyReport(rs, targetDate);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new DailyAuditReportDTO(targetDate, 0, 0, 0, BigDecimal.ZERO,
                BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal.ZERO);
    }

    private DailyAuditReportDTO mapDailyReport(ResultSet rs, LocalDate date) throws Exception {
        int soDonMoi = rs.getInt("SoDonDatMoi");
        int checkIn = rs.getInt("SoPhongCheckIn");
        int checkOut = rs.getInt("SoPhongCheckOut");
        BigDecimal tong = getNonNullBigDecimal(rs, "TongTienThucThu");
        BigDecimal tienMat = getNonNullBigDecimal(rs, "ThuTienMat");
        BigDecimal chuyenKhoan = getNonNullBigDecimal(rs, "ThuChuyenKhoan");
        BigDecimal the = getNonNullBigDecimal(rs, "ThuTheNganHang");
        return new DailyAuditReportDTO(date, soDonMoi, checkIn, checkOut,
                tong, tienMat, chuyenKhoan, the);
    }

    public List<MonthlyRevenueDTO> getMonthlyRevenueList() {
        List<MonthlyRevenueDTO> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_MONTHLY_REVENUE_SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new MonthlyRevenueDTO(
                        rs.getInt("Nam"),
                        rs.getInt("Thang"),
                        rs.getInt("SoLuotGiaoDich"),
                        rs.getInt("SoHoaDonDaThanhToan"),
                        getNonNullBigDecimal(rs, "TongDoanhThuThucThu")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public BigDecimal getRevenueByRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null) {
            return BigDecimal.ZERO;
        }
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(FN_REVENUE_BY_RANGE_SQL)) {
            ps.setDate(1, Date.valueOf(fromDate));
            ps.setDate(2, Date.valueOf(toDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return getNonNullBigDecimal(rs, "TongDoanhThu");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    private BigDecimal getNonNullBigDecimal(ResultSet rs, String col) throws Exception {
        BigDecimal val = rs.getBigDecimal(col);
        return (val != null) ? val : BigDecimal.ZERO;
    }
}
