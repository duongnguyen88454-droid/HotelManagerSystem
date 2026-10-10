package com.mycompany.hotelmanagersystem.booking.controller;

import com.mycompany.hotelmanagersystem.booking.dto.BookingCartDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartRoomItemDTO;
import com.mycompany.hotelmanagersystem.booking.dto.CartServiceItemDTO;
import com.mycompany.hotelmanagersystem.room.dto.AvailableRoomDTO;
import com.mycompany.hotelmanagersystem.hotelservice.model.ServiceItem;
import com.mycompany.hotelmanagersystem.booking.service.BookingService;
import com.mycompany.hotelmanagersystem.room.service.RoomService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CustomerCartServlet", urlPatterns = { "/customer/cart/*" })
@MultipartConfig
public class CustomerCartServlet extends HttpServlet {

    private final RoomService roomService = new RoomService();
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/";
        }

        HttpSession session = request.getSession(true);
        BookingCartDTO cart = (BookingCartDTO) session.getAttribute("BOOKING_CART");
        if (cart == null) {
            cart = new BookingCartDTO();
            session.setAttribute("BOOKING_CART", cart);
        }

        switch (pathInfo) {
            case "/add":
                handleAddRoom(request, response, cart);
                break;
            case "/remove":
                handleRemoveRoom(request, response, cart);
                break;
            case "/clear":
                handleClearCart(request, response, cart);
                break;
            case "/view":
            default:
                response.sendRedirect(request.getContextPath() + "/customer/booking");
                break;
        }
    }

    private void handleAddRoom(HttpServletRequest request, HttpServletResponse response, BookingCartDTO cart)
            throws IOException {
        String roomId = resolveRoomId(request);
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String action = request.getParameter("action");
        boolean ajaxRequested = isAjaxRequest(request, action);

        if (roomId == null || checkIn == null || checkOut == null) {
            handleMissingRoomParams(request, response, ajaxRequested);
            return;
        }

        try {
            if (!roomService.isRoomAvailable(roomId.trim(), checkIn.trim(), checkOut.trim())) {
                handleRoomAddError(request, response, ajaxRequested,
                        "Phòng này hiện đã có khách đặt trong khoảng thời gian yêu cầu, vui lòng chọn phòng khác!",
                        checkIn, checkOut);
                return;
            }

            AvailableRoomDTO roomDetail = roomService.getRoomBookingDetail(roomId.trim(), checkIn.trim(), checkOut.trim());
            if (roomDetail != null) {
                CartRoomItemDTO roomItem = buildCartRoomItem(request, roomDetail, checkIn.trim(), checkOut.trim());
                cart.addOrUpdateRoom(roomItem);

                if (ajaxRequested) {
                    sendRoomAddedJsonResponse(response, roomItem, cart, checkIn.trim(), checkOut.trim());
                    return;
                }
            }
        } catch (Exception ex) {
            handleRoomAddError(request, response, ajaxRequested, ex.getMessage(), checkIn, checkOut);
            return;
        }

        redirectAfterAddRoom(request, response, action, checkIn, checkOut, roomId);
    }

    private String resolveRoomId(HttpServletRequest request) {
        String roomId = request.getParameter("roomId");
        if (roomId == null || roomId.trim().isEmpty()) {
            roomId = request.getParameter("maPhong");
        }
        return (roomId != null && !roomId.trim().isEmpty()) ? roomId.trim() : null;
    }

    private boolean isAjaxRequest(HttpServletRequest request, String action) {
        return "true".equalsIgnoreCase(request.getParameter("isAjax"))
                || "ajax".equalsIgnoreCase(action)
                || "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));
    }

    private CartRoomItemDTO buildCartRoomItem(HttpServletRequest request, AvailableRoomDTO roomDetail,
                                              String checkIn, String checkOut) {
        CartRoomItemDTO roomItem = new CartRoomItemDTO(
                roomDetail.getMaPhong(),
                roomDetail.getSoPhong(),
                roomDetail.getMaLoaiPhong(),
                roomDetail.getTenLoaiPhong(),
                roomDetail.getGiaPhong(),
                checkIn,
                checkOut
        );
        List<CartServiceItemDTO> selectedSvcs = extractSelectedServices(request, roomDetail.getMaPhong());
        if (!selectedSvcs.isEmpty()) {
            roomItem.setSelectedServices(selectedSvcs);
        }
        roomItem.setTienCoc(roomDetail.getTienCoc());
        return roomItem;
    }

    private List<CartServiceItemDTO> extractSelectedServices(HttpServletRequest request, String roomId) {
        List<ServiceItem> activeServices = bookingService.getActiveServices();
        if (activeServices == null || activeServices.isEmpty()) {
            return new ArrayList<>();
        }
        List<CartServiceItemDTO> selectedSvcs = new ArrayList<>();
        for (ServiceItem svc : activeServices) {
            String sId = svc.getMaDichVu();
            String paramSvc = request.getParameter("service_" + sId);
            if (paramSvc == null) {
                paramSvc = request.getParameter("service_" + roomId + "_" + sId);
            }
            if (paramSvc != null) {
                int qty = parseServiceQty(request, sId, roomId);
                selectedSvcs.add(new CartServiceItemDTO(sId, svc.getTenDichVu(), svc.getDonGia(), qty));
            }
        }
        return selectedSvcs;
    }

    private int parseServiceQty(HttpServletRequest request, String sId, String roomId) {
        String qtyVal = request.getParameter("qty_" + sId);
        if (qtyVal == null) {
            qtyVal = request.getParameter("qty_" + roomId + "_" + sId);
        }
        if (qtyVal != null && !qtyVal.trim().isEmpty()) {
            try {
                return Math.max(1, Integer.parseInt(qtyVal.trim()));
            } catch (NumberFormatException ignored) {
                return 1;
            }
        }
        return 1;
    }

    private void sendRoomAddedJsonResponse(HttpServletResponse response, CartRoomItemDTO roomItem,
                                           BookingCartDTO cart, String checkIn, String checkOut) throws IOException {
        String json = String.format(
                "{\"success\":true,\"soPhong\":\"%s\",\"tenLoaiPhong\":\"%s\",\"soDem\":%d,"
                + "\"roomPrice\":%.0f,\"serviceTotal\":%.0f,\"roomTotal\":%.0f,"
                + "\"cartTotalRooms\":%d,\"cartGrandTotal\":%.0f,\"checkIn\":\"%s\",\"checkOut\":\"%s\"}",
                roomItem.getSoPhong(),
                roomItem.getTenLoaiPhong(),
                roomItem.getSoDem(),
                roomItem.getTienPhong(),
                roomItem.getTongTienDichVu(),
                roomItem.getTongTienPhongVaDichVu(),
                cart.getTotalRoomCount(),
                cart.getGrandTotal(),
                checkIn,
                checkOut
        );
        sendRawJsonResponse(response, json);
    }

    private void handleMissingRoomParams(HttpServletRequest request, HttpServletResponse response,
                                        boolean ajaxRequested) throws IOException {
        if (ajaxRequested) {
            sendJsonResponse(response, false, "Thiếu thông tin phòng hoặc ngày đặt!", null);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
        }
    }

    private void handleRoomAddError(HttpServletRequest request, HttpServletResponse response,
                                    boolean ajaxRequested, String errorMsg, String checkIn, String checkOut)
            throws IOException {
        if (ajaxRequested) {
            sendJsonResponse(response, false, errorMsg, null);
            return;
        }
        String error = URLEncoder.encode("Không thể thêm phòng vào giỏ: " + errorMsg, StandardCharsets.UTF_8.name());
        response.sendRedirect(request.getContextPath() + "/customer/search-rooms?checkIn=" + checkIn
                + "&checkOut=" + checkOut + "&error=" + error);
    }

    private void redirectAfterAddRoom(HttpServletRequest request, HttpServletResponse response,
                                     String action, String checkIn, String checkOut, String roomId)
            throws IOException {
        if ("checkout".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/customer/booking");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms?checkIn=" + checkIn
                    + "&checkOut=" + checkOut + "&addedRoom=" + roomId);
        }
    }

    private void handleRemoveRoom(HttpServletRequest request, HttpServletResponse response, BookingCartDTO cart)
            throws IOException {
        String roomId = request.getParameter("roomId");
        if (roomId == null) roomId = request.getParameter("maPhong");

        if (roomId != null) {
            cart.removeRoom(roomId.trim());
        }

        response.sendRedirect(request.getContextPath() + "/customer/booking");
    }

    private void handleClearCart(HttpServletRequest request, HttpServletResponse response, BookingCartDTO cart)
            throws IOException {
        cart.clear();
        response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
    }

    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, String dataJson) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        String json = String.format("{\"success\":%b,\"message\":\"%s\"}", success, message != null ? message.replace("\"", "\\\"") : "");
        out.print(json);
        out.flush();
    }

    private void sendRawJsonResponse(HttpServletResponse response, String rawJson) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print(rawJson);
        out.flush();
    }
}
