package com.mycompany.hotelmanagersystem.manager.dao;

import com.mycompany.hotelmanagersystem.common.base.BaseRepository;
import com.mycompany.hotelmanagersystem.common.base.RowMapper;
import com.mycompany.hotelmanagersystem.common.config.DBContext;
import com.mycompany.hotelmanagersystem.manager.dto.DailyAuditReportDTO;
import com.mycompany.hotelmanagersystem.manager.dto.MonthlyRevenueDTO;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

public class ManagerReportDAO extends BaseRepository<MonthlyRevenueDTO, String> {

    private static final String SP_DAILY_AUDIT_SQL =
            "{CALL sp_BaoCaoDoanhThuTheoNgay(?)}";
    private static final String SELECT_MONTHLY_REVENUE_SQL =
            "SELECT Nam, Thang, SoLuotGiaoDich, SoHoaDonDaThanhToan, TongDoanhThuThucThu "
                    + "FROM v_BaoCaoDoanhThuTheoThang ORDER BY Nam DESC, Thang DESC";
    private static final String FN_REVENUE_BY_RANGE_SQL =
            "SELECT dbo.fn_DoanhThuTheoKhoangThoiGian(?, ?) AS TongDoanhThu";

    @Override
    protected String getTableName() {
        return "v_BaoCaoDoanhThuTheoThang";
    }

    @Override
    protected String getPrimaryKeyColumnName() {
        return "Nam";
    }

    @Override
    protected RowMapper<MonthlyRevenueDTO> getRowMapper() {
        return rs -> new MonthlyRevenueDTO(
                rs.getInt("Nam"),
                rs.getInt("Thang"),
                rs.getInt("SoLuotGiaoDich"),
                rs.getInt("SoHoaDonDaThanhToan"),
                getNonNullBigDecimal(rs, "TongDoanhThuThucThu")
        );
    }

    public DailyAuditReportDTO getDailyAuditReport(LocalDate reportDate) {
        LocalDate targetDate = (reportDate != null) ? reportDate : LocalDate.now();
        try (Connection conn = DBContext.getConnection();
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

    public List<MonthlyRevenueDTO> getMonthlyRevenueList() {
        return query(SELECT_MONTHLY_REVENUE_SQL);
    }

    public BigDecimal getRevenueByRange(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null || toDate == null) {
            return BigDecimal.ZERO;
        }
        RowMapper<BigDecimal> mapper = rs -> getNonNullBigDecimal(rs, "TongDoanhThu");
        return queryOneCustom(FN_REVENUE_BY_RANGE_SQL, mapper, Date.valueOf(fromDate), Date.valueOf(toDate))
                .orElse(BigDecimal.ZERO);
    }

    private DailyAuditReportDTO mapDailyReport(ResultSet rs, LocalDate date) throws SQLException {
        int soDonMoi = rs.getInt("TotalNewBookings");
        int checkIn = rs.getInt("TotalRoomsCheckedIn");
        int checkOut = rs.getInt("TotalRoomsCheckedOut");
        BigDecimal tong = getNonNullBigDecimal(rs, "TotalRevenue");
        BigDecimal tienMat = getNonNullBigDecimal(rs, "RevenueCash");
        BigDecimal chuyenKhoan = getNonNullBigDecimal(rs, "RevenueBankTransfer");
        BigDecimal the = getNonNullBigDecimal(rs, "RevenueCreditCard");
        return new DailyAuditReportDTO(date, soDonMoi, checkIn, checkOut,
                tong, tienMat, chuyenKhoan, the);
    }

    private BigDecimal getNonNullBigDecimal(ResultSet rs, String col) throws SQLException {
        BigDecimal val = rs.getBigDecimal(col);
        return (val != null) ? val : BigDecimal.ZERO;
    }
}

