package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.booking.dto.CheckInRequestDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CheckInResultDTO;
import com.mycompany.hotelmanagersystem.booking.service.CheckInService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String maBooking = request.getParameter("maBooking");
        String maPhong = request.getParameter("maPhong");
        String ghiChu = request.getParameter("ghiChu");
        boolean chkCccd = Boolean.parseBoolean(request.getParameter("chkCccd"));

        String maNV = resolveEmployeeId(request.getSession(false));

        CheckInRequestDTO reqDto = new CheckInRequestDTO(maBooking, maPhong, maNV, ghiChu, chkCccd);
        CheckInResultDTO result = checkInService.executeCheckIn(reqDto);

        String json = buildJsonResponse(result);
        response.getWriter().write(json);
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
        sb.append("\"maPhong\":\"").append(result.getMaPhong() != null ? escapeJson(result.getMaPhong()) : "").append("\",");
        sb.append("\"newRoomStatus\":\"").append(result.getNewRoomStatus() != null ? escapeJson(result.getNewRoomStatus()) : "").append("\"");
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
