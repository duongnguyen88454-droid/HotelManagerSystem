package com.mycompany.hotelmanagersystem.receptionist.controller;

import com.mycompany.hotelmanagersystem.hotelservice.dto.RoomServiceUsageDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderRequestDTO;
import com.mycompany.hotelmanagersystem.hotelservice.dto.ServiceOrderResultDTO;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.hotelservice.service.HotelServiceService;
import com.mycompany.hotelmanagersystem.hotelservice.service.RoomServiceOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Controller tiếp nhận yêu cầu gọi dịch vụ tại phòng và tra cứu bảng kê dịch vụ lưu trú (FN-3.4 & FN-3.5).
 * Tuân thủ QT 3.1: Controller mỏng, không chạm JDBC hay DAO.
 */
@WebServlet(name = "ReceptionistServiceServlet", urlPatterns = {"/receptionist/services", "/api/receptionist/services"})
public class ReceptionistServiceServlet extends HttpServlet {

    private RoomServiceOrderService orderService;
    private HotelServiceService menuService;

    @Override
    public void init() throws ServletException {
        this.orderService = new RoomServiceOrderService();
        this.menuService = new HotelServiceService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        if ("usage".equalsIgnoreCase(action)) {
            handleGetServicesUsage(request, response);
        } else {
            handleGetMenu(response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String maBooking = request.getParameter("maBooking");
        String maPhong = request.getParameter("maPhong");
        String maDichVu = request.getParameter("maDichVu");
        String soLuongStr = request.getParameter("soLuong");
        String ghiChu = request.getParameter("ghiChu");

        if ((maBooking == null || maBooking.trim().isEmpty()) && (maPhong != null && !maPhong.trim().isEmpty())) {
            maBooking = orderService.getActiveBookingByRoom(maPhong.trim());
        }

        int soLuong = 1;
        try {
            if (soLuongStr != null) {
                soLuong = Integer.parseInt(soLuongStr.trim());
            }
        } catch (NumberFormatException e) {
            soLuong = 1;
        }

        String maNV = resolveEmployeeId(request.getSession(false));
        ServiceOrderRequestDTO req = new ServiceOrderRequestDTO(maBooking, maPhong, maDichVu, soLuong, maNV, ghiChu);
        ServiceOrderResultDTO result = orderService.orderService(req);

        response.getWriter().write(buildOrderResultJson(result));
    }

    private void handleGetServicesUsage(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String maBooking = request.getParameter("maBooking");
        String maPhong = request.getParameter("maPhong");

        if ((maBooking == null || maBooking.trim().isEmpty()) && (maPhong != null && !maPhong.trim().isEmpty())) {
            maBooking = orderService.getActiveBookingByRoom(maPhong.trim());
        }

        List<RoomServiceUsageDTO> list = orderService.getServicesUsed(maBooking, maPhong);
        double total = orderService.calculateTotalServicesCost(list);
        response.getWriter().write(buildUsageListJson(maBooking, maPhong, list, total));
    }

    private void handleGetMenu(HttpServletResponse response) throws IOException {
        List<ServiceItem> menu = menuService.getAllActiveServices();
        StringBuilder sb = new StringBuilder();
        sb.append("{\"success\":true,\"menu\":[");
        for (int i = 0; i < menu.size(); i++) {
            ServiceItem item = menu.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"maDichVu\":\"").append(escapeJson(item.getMaDichVu())).append("\",")
              .append("\"tenDichVu\":\"").append(escapeJson(item.getTenDichVu())).append("\",")
              .append("\"donGia\":").append(item.getDonGia())
              .append("}");
        }
        sb.append("]}");
        response.getWriter().write(sb.toString());
    }

    private String buildUsageListJson(String maBooking, String maPhong, List<RoomServiceUsageDTO> list, double total) {
        StringBuilder sb = new StringBuilder();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");
        sb.append("{")
          .append("\"success\":true,")
          .append("\"maBooking\":\"").append(maBooking != null ? escapeJson(maBooking) : "").append("\",")
          .append("\"maPhong\":\"").append(maPhong != null ? escapeJson(maPhong) : "").append("\",")
          .append("\"totalCost\":").append(total).append(",")
          .append("\"services\":[");

        for (int i = 0; i < list.size(); i++) {
            RoomServiceUsageDTO u = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{")
              .append("\"maBookingDichVu\":\"").append(escapeJson(u.getMaBookingDichVu())).append("\",")
              .append("\"maDichVu\":\"").append(escapeJson(u.getMaDichVu())).append("\",")
              .append("\"tenDichVu\":\"").append(escapeJson(u.getTenDichVu())).append("\",")
              .append("\"donGia\":").append(u.getDonGia()).append(",")
              .append("\"soLuong\":").append(u.getSoLuong()).append(",")
              .append("\"thanhTien\":").append(u.getThanhTien()).append(",")
              .append("\"thoiDiem\":\"").append(u.getThoiDiemThem() != null ? u.getThoiDiemThem().format(fmt) : "").append("\",")
              .append("\"nguoiThem\":\"").append(escapeJson(u.getNguoiThem())).append("\"")
              .append("}");
        }
        sb.append("]}");
        return sb.toString();
    }

    private String buildOrderResultJson(ServiceOrderResultDTO result) {
        StringBuilder sb = new StringBuilder();
        sb.append("{")
          .append("\"success\":").append(result.isSuccess()).append(",")
          .append("\"message\":\"").append(escapeJson(result.getMessage())).append("\",")
          .append("\"maBookingDichVu\":\"").append(result.getMaBookingDichVu() != null ? escapeJson(result.getMaBookingDichVu()) : "").append("\",")
          .append("\"totalCost\":").append(result.getTongTienDichVuMoi())
          .append("}");
        return sb.toString();
    }

    private String resolveEmployeeId(HttpSession session) {
        if (session != null && session.getAttribute("maNV") != null) {
            return (String) session.getAttribute("maNV");
        }
        return "NV001";
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}
