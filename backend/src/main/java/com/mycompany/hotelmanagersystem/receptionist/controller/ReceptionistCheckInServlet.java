package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.booking.dto.CheckInArrivalItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInDetailDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInResultDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInRoomDetailDTO;
import com.mycompany.hotelmanagersystem.booking.service.CheckInService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Controller tiếp nhận yêu cầu Check-in nhận phòng từ quầy lễ tân (Phase 3).
 */
@WebServlet(name = "ReceptionistCheckInServlet", urlPatterns = {"/receptionist/checkin", "/api/receptionist/checkin"})
public class ReceptionistCheckInServlet extends HttpServlet {

    private CheckInService checkInService;

    @Override
    public void init() throws ServletException {
        this.checkInService = new CheckInService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("detail".equalsIgnoreCase(action)) {
            handleGetDetailAjax(request, response);
            return;
        }

        String filterHoTen = request.getParameter("filterHoTen");
        String filterCccd  = request.getParameter("filterCccd");
        String filterMaBK  = request.getParameter("filterMaBK");
        List<CheckInArrivalItemDTO> arrivalList = checkInService.getArrivalBookings(filterHoTen, filterCccd, filterMaBK);
        request.setAttribute("arrivalList", arrivalList);
        request.setAttribute("filterHoTen", filterHoTen != null ? filterHoTen.trim() : "");
        request.setAttribute("filterCccd",  filterCccd  != null ? filterCccd.trim()  : "");
        request.setAttribute("filterMaBK",  filterMaBK  != null ? filterMaBK.trim()  : "");
        request.setAttribute("autoSelectBooking", request.getParameter("maBooking"));

        request.getRequestDispatcher("/views/receptionist/checkin.jsp").forward(request, response);
    }

    private void handleGetDetailAjax(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String maBooking = request.getParameter("maBooking");
        CheckInDetailDTO detail = checkInService.getBookingCheckInDetail(maBooking);

        if (detail == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy đơn đặt phòng!\"}");
            return;
        }
        response.getWriter().write(buildDetailJsonResponse(detail));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String maBooking = request.getParameter("maBooking");
        String[] maPhongArr = request.getParameterValues("maPhong[]");
        if (maPhongArr == null || maPhongArr.length == 0) {
            String single = request.getParameter("maPhong");
            if (single != null && !single.trim().isEmpty()) {
                maPhongArr = new String[]{single.trim()};
            }
        }

        List<String> roomIds = (maPhongArr != null) ? Arrays.asList(maPhongArr) : new ArrayList<>();
        String maNV = resolveEmployeeId(request.getSession(false));

        CheckInResultDTO result = checkInService.executeCheckInMultipleRooms(maBooking, roomIds, maNV);
        response.getWriter().write(buildJsonResponse(result));
    }

    private String resolveEmployeeId(HttpSession session) {
        if (session != null && session.getAttribute("maNV") != null) {
            return (String) session.getAttribute("maNV");
        }
        return "NV001";
    }

    private String buildJsonResponse(CheckInResultDTO result) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":").append(result.isSuccess()).append(",");
        sb.append("\"message\":\"").append(escapeJson(result.getMessage())).append("\",");
        sb.append("\"maBooking\":\"").append(result.getMaBooking() != null ? escapeJson(result.getMaBooking()) : "").append("\",");
        sb.append("\"maPhong\":\"").append(result.getMaPhong() != null ? escapeJson(result.getMaPhong()) : "").append("\"");
        sb.append("}");
        return sb.toString();
    }

    private String buildDetailJsonResponse(CheckInDetailDTO dto) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"maBooking\":\"").append(escapeJson(dto.getMaBooking())).append("\",");
        sb.append("\"tenKhachHang\":\"").append(escapeJson(dto.getTenKhachHang())).append("\",");
        sb.append("\"soDienThoai\":\"").append(escapeJson(dto.getSoDienThoai())).append("\",");
        sb.append("\"soCccd\":\"").append(escapeJson(dto.getSoCccd())).append("\",");
        sb.append("\"email\":\"").append(escapeJson(dto.getEmail())).append("\",");
        sb.append("\"ngayNhanDuKien\":\"").append(dto.getNgayNhanDuKien() != null ? dto.getNgayNhanDuKien().toString() : "").append("\",");
        sb.append("\"ngayTraDuKien\":\"").append(dto.getNgayTraDuKien() != null ? dto.getNgayTraDuKien().toString() : "").append("\",");
        sb.append("\"soDem\":").append(dto.getSoDem()).append(",");
        sb.append("\"rooms\":[");
        List<CheckInRoomDetailDTO> rooms = dto.getDanhSachPhong();
        for (int i = 0; i < rooms.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            appendRoomJson(sb, rooms.get(i));
        }
        sb.append("]}");
        return sb.toString();
    }

    private void appendRoomJson(StringBuilder sb, CheckInRoomDetailDTO r) {
        sb.append("{");
        sb.append("\"maPhong\":\"").append(escapeJson(r.getMaPhong())).append("\",");
        sb.append("\"soPhong\":\"").append(escapeJson(r.getSoPhong())).append("\",");
        sb.append("\"tenLoaiPhong\":\"").append(escapeJson(r.getTenLoaiPhong())).append("\",");
        sb.append("\"trangThaiBuong\":\"").append(escapeJson(r.getTrangThaiBuong())).append("\",");
        sb.append("\"trangThaiBuongText\":\"").append(escapeJson(r.getTrangThaiBuongText())).append("\",");
        sb.append("\"trangThaiBuongCss\":\"").append(escapeJson(r.getTrangThaiBuongCss())).append("\",");
        sb.append("\"ngayCheckInThucTe\":\"").append(escapeJson(r.getNgayCheckInThucTe())).append("\",");
        sb.append("\"daNhanPhong\":").append(r.isDaNhanPhong()).append(",");
        sb.append("\"dichVu\":[");
        List<String> svcs = r.getDanhSachDichVu();
        for (int j = 0; j < svcs.size(); j++) {
            if (j > 0) {
                sb.append(",");
            }
            sb.append("\"").append(escapeJson(svcs.get(j))).append("\"");
        }
        sb.append("]}");
    }

    private String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
