package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.RoomTypePriceDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerHotelConfigService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller tiếp nhận và xử lý cấu hình khách sạn: hạng phòng, loại giường, tiện nghi và dịch vụ.
 */
@WebServlet(name = "ManagerHotelConfigServlet", urlPatterns = {"/manager/hotel-config"})
public class ManagerHotelConfigServlet extends HttpServlet {

    private final ManagerHotelConfigService configService = new ManagerHotelConfigService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("roomTypes", configService.getAllRoomTypes());
        request.setAttribute("bedTypes", configService.getAllBedTypes());
        request.setAttribute("amenities", configService.getAllRoomAmenities());
        request.setAttribute("services", configService.getAllServices());
        request.getRequestDispatcher("/views/manager/hotel_config.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("update_roomtype".equalsIgnoreCase(action)) {
            handleRoomTypeUpdate(request, session);
        } else if ("add_bedtype".equalsIgnoreCase(action) || "toggle_bedtype".equalsIgnoreCase(action)) {
            handleBedType(request, session, action);
        } else if ("add_amenity".equalsIgnoreCase(action) || "toggle_amenity".equalsIgnoreCase(action)) {
            handleAmenity(request, session, action);
        } else if ("add_service".equalsIgnoreCase(action) || "update_service".equalsIgnoreCase(action)) {
            handleService(request, session, action);
        }

        response.sendRedirect(request.getContextPath() + "/manager/hotel-config");
    }

    private void handleRoomTypeUpdate(HttpServletRequest request, HttpSession session) {
        try {
            RoomTypePriceDTO dto = new RoomTypePriceDTO(
                    request.getParameter("roomTypeId"),
                    Double.parseDouble(request.getParameter("basePrice")),
                    Double.parseDouble(request.getParameter("earlyFee")),
                    Double.parseDouble(request.getParameter("lateFee")),
                    Double.parseDouble(request.getParameter("depositPercent")),
                    "true".equalsIgnoreCase(request.getParameter("isActive"))
            );
            boolean success = configService.updateRoomTypePricing(dto);
            setFlash(session, success, "Đã cập nhật biểu phí hạng phòng thành công!", "Lỗi cập nhật biểu phí hạng phòng!");
        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Dữ liệu biểu phí không hợp lệ!");
        }
    }

    private void handleBedType(HttpServletRequest request, HttpSession session, String action) {
        String bedTypeId = request.getParameter("bedTypeId");
        if ("add_bedtype".equalsIgnoreCase(action)) {
            String bedTypeName = request.getParameter("bedTypeName");
            boolean success = configService.addBedType(bedTypeId, bedTypeName);
            setFlash(session, success, "Đã thêm loại giường mới thành công!", "Không thể thêm loại giường (có thể trùng mã)!");
        } else {
            boolean active = "true".equalsIgnoreCase(request.getParameter("isActive"));
            boolean success = configService.toggleBedTypeStatus(bedTypeId, active);
            setFlash(session, success, "Đã cập nhật trạng thái loại giường!", "Lỗi cập nhật trạng thái loại giường!");
        }
    }

    private void handleAmenity(HttpServletRequest request, HttpSession session, String action) {
        String amenityId = request.getParameter("amenityId");
        if ("add_amenity".equalsIgnoreCase(action)) {
            String amenityName = request.getParameter("amenityName");
            boolean success = configService.addRoomAmenity(amenityId, amenityName);
            setFlash(session, success, "Đã thêm tiện nghi phòng thành công!", "Không thể thêm tiện nghi (có thể trùng mã)!");
        } else {
            boolean active = "true".equalsIgnoreCase(request.getParameter("isActive"));
            boolean success = configService.toggleRoomAmenityStatus(amenityId, active);
            setFlash(session, success, "Đã cập nhật trạng thái tiện nghi phòng!", "Lỗi cập nhật trạng thái tiện nghi!");
        }
    }

    private void handleService(HttpServletRequest request, HttpSession session, String action) {
        String serviceId = request.getParameter("serviceId");
        try {
            double price = Double.parseDouble(request.getParameter("basePrice"));
            if ("add_service".equalsIgnoreCase(action)) {
                String serviceName = request.getParameter("serviceName");
                boolean success = configService.addService(serviceId, serviceName, price);
                setFlash(session, success, "Đã thêm dịch vụ tiêu dùng thành công!", "Không thể thêm dịch vụ!");
            } else {
                boolean active = "true".equalsIgnoreCase(request.getParameter("isActive"));
                boolean success = configService.updateService(serviceId, price, active);
                setFlash(session, success, "Đã cập nhật dịch vụ tiêu dùng thành công!", "Lỗi cập nhật dịch vụ!");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Đơn giá dịch vụ không hợp lệ!");
        }
    }

    private void setFlash(HttpSession session, boolean success, String successMsg, String errorMsg) {
        if (success) {
            session.setAttribute("flashSuccess", successMsg);
        } else {
            session.setAttribute("flashError", errorMsg);
        }
    }
}
