package com.mycompany.hotelmanagersystem.booking.dto;

import java.util.ArrayList;
import java.util.List;

/**
 * DTO đại diện cho một phòng kèm dịch vụ đã đặt trước trong Modal Chi Tiết Check-in.
 */
public class CheckInRoomDetailDTO {

    private String maPhong;
    private String soPhong;
    private String tenLoaiPhong;
    private String trangThaiBuong;
    private String trangThaiBuongText;
    private String trangThaiBuongCss;
    private String ngayCheckInThucTe;
    private boolean daNhanPhong;
    private List<String> danhSachDichVu;

    public CheckInRoomDetailDTO() {
        this.danhSachDichVu = new ArrayList<>();
    }

    public CheckInRoomDetailDTO(String maPhong, String soPhong, String tenLoaiPhong,
                                String trangThaiBuong, String ngayCheckInThucTe) {
        this.maPhong = maPhong;
        this.soPhong = soPhong;
        this.tenLoaiPhong = tenLoaiPhong;
        this.trangThaiBuong = trangThaiBuong;
        this.ngayCheckInThucTe = ngayCheckInThucTe;
        this.daNhanPhong = (ngayCheckInThucTe != null && !ngayCheckInThucTe.trim().isEmpty());
        this.trangThaiBuongText = resolveStatusText(trangThaiBuong);
        this.trangThaiBuongCss = resolveStatusCss(trangThaiBuong);
        this.danhSachDichVu = new ArrayList<>();
    }

    private String resolveStatusText(String status) {
        if ("Available".equalsIgnoreCase(status)) {
            return "[Đã dọn sạch]";
        } else if ("Cleaning".equalsIgnoreCase(status)) {
            return "[Đang dọn]";
        } else if ("Dirty".equalsIgnoreCase(status)) {
            return "[Bẩn chờ dọn]";
        } else if ("Damaged".equalsIgnoreCase(status)) {
            return "[Bảo trì]";
        } else if ("Occupied".equalsIgnoreCase(status)) {
            return "[Đang có khách]";
        }
        return status != null ? status : "[Chưa rõ]";
    }

    private String resolveStatusCss(String status) {
        if ("Available".equalsIgnoreCase(status)) {
            return "badge-clean";
        } else if ("Cleaning".equalsIgnoreCase(status)) {
            return "badge-cleaning";
        } else if ("Dirty".equalsIgnoreCase(status)) {
            return "badge-dirty";
        } else if ("Damaged".equalsIgnoreCase(status)) {
            return "badge-damaged";
        } else if ("Occupied".equalsIgnoreCase(status)) {
            return "badge-occupied";
        }
        return "badge-clean";
    }

    public String getMaPhong() {
        return maPhong;
    }

    public void setMaPhong(String maPhong) {
        this.maPhong = maPhong;
    }

    public String getSoPhong() {
        return soPhong;
    }

    public void setSoPhong(String soPhong) {
        this.soPhong = soPhong;
    }

    public String getTenLoaiPhong() {
        return tenLoaiPhong;
    }

    public void setTenLoaiPhong(String tenLoaiPhong) {
        this.tenLoaiPhong = tenLoaiPhong;
    }

    public String getTrangThaiBuong() {
        return trangThaiBuong;
    }

    public void setTrangThaiBuong(String trangThaiBuong) {
        this.trangThaiBuong = trangThaiBuong;
        this.trangThaiBuongText = resolveStatusText(trangThaiBuong);
        this.trangThaiBuongCss = resolveStatusCss(trangThaiBuong);
    }

    public String getTrangThaiBuongText() {
        return trangThaiBuongText;
    }

    public String getTrangThaiBuongCss() {
        return trangThaiBuongCss;
    }

    public String getNgayCheckInThucTe() {
        return ngayCheckInThucTe;
    }

    public void setNgayCheckInThucTe(String ngayCheckInThucTe) {
        this.ngayCheckInThucTe = ngayCheckInThucTe;
        this.daNhanPhong = (ngayCheckInThucTe != null && !ngayCheckInThucTe.trim().isEmpty());
    }

    public boolean isDaNhanPhong() {
        return daNhanPhong;
    }

    public void setDaNhanPhong(boolean daNhanPhong) {
        this.daNhanPhong = daNhanPhong;
    }

    public List<String> getDanhSachDichVu() {
        return danhSachDichVu;
    }

    public void setDanhSachDichVu(List<String> danhSachDichVu) {
        this.danhSachDichVu = danhSachDichVu;
    }
}
