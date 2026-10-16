package com.mycompany.hotelmanagersystem.manager.controller;

import com.mycompany.hotelmanagersystem.manager.dto.CreateRoomTypeDTO;
import com.mycompany.hotelmanagersystem.manager.dto.RoomTypePriceDTO;
import com.mycompany.hotelmanagersystem.manager.service.ManagerHotelConfigService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        } else if ("add_roomtype".equalsIgnoreCase(action)) {
            handleAddRoomType(request, session);
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
            dto.setRoomTypeName(request.getParameter("roomTypeName"));
            dto.setCapacity(parsePositiveInt(request.getParameter("capacity"), 2));
            dto.setBedTypes(extractBedTypes(request));
            dto.setAmenityIds(extractAmenities(request));

            boolean success = configService.updateRoomTypePricing(dto);
            setFlash(session, success, "Đã cập nhật thông tin và cấu hình hạng phòng thành công!",
                    "Lỗi cập nhật cấu hình hạng phòng!");
        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Dữ liệu cấu hình hạng phòng không hợp lệ!");
        }
    }

    private void handleAddRoomType(HttpServletRequest request, HttpSession session) {
        try {
            CreateRoomTypeDTO dto = new CreateRoomTypeDTO(
                    null,
                    request.getParameter("roomTypeName"),
                    Integer.parseInt(request.getParameter("capacity")),
                    Double.parseDouble(request.getParameter("basePrice")),
                    Double.parseDouble(request.getParameter("earlyFee")),
                    Double.parseDouble(request.getParameter("lateFee")),
                    Double.parseDouble(request.getParameter("depositPercent"))
            );
            dto.setBedTypes(extractBedTypes(request));
            dto.setAmenityIds(extractAmenities(request));

            boolean success = configService.addRoomType(dto);
            setFlash(session, success, "Đã thêm loại phòng mới thành công!",
                    "Không thể thêm loại phòng (có thể trùng tên loại phòng)!");
        } catch (NumberFormatException e) {
            session.setAttribute("flashError", "Dữ liệu nhập loại phòng không hợp lệ!");
        }
    }

    private Map<String, Integer> extractBedTypes(HttpServletRequest request) {
        String[] selected = request.getParameterValues("selectedBedTypes");
        if (selected == null) {
            return null;
        }
        Map<String, Integer> bedMap = new HashMap<>();
        for (String bedId : selected) {
            bedMap.put(bedId, parsePositiveInt(request.getParameter("bedQty_" + bedId), 1));
        }
        return bedMap;
    }

    private List<String> extractAmenities(HttpServletRequest request) {
        String[] selected = request.getParameterValues("selectedAmenities");
        return (selected != null) ? Arrays.asList(selected) : null;
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Math.max(1, Integer.parseInt(value.trim()));
        } catch (NumberFormatException e) {
            return defaultValue;
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
