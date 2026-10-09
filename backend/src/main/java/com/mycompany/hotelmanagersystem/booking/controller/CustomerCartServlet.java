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
        String roomId = request.getParameter("roomId");
        if (roomId == null) roomId = request.getParameter("maPhong");
        String checkIn = request.getParameter("checkIn");
        String checkOut = request.getParameter("checkOut");
        String action = request.getParameter("action"); // "checkout", "continue", "ajax"
        String isAjax = request.getParameter("isAjax");

        boolean ajaxRequested = "true".equalsIgnoreCase(isAjax) || "ajax".equalsIgnoreCase(action)
                || "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

        if (roomId == null || roomId.trim().isEmpty() || checkIn == null || checkOut == null) {
            if (ajaxRequested) {
                sendJsonResponse(response, false, "Thiếu thông tin phòng hoặc ngày đặt!", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
            }
            return;
        }

        try {
            AvailableRoomDTO roomDetail = roomService.getRoomBookingDetail(roomId.trim(), checkIn.trim(), checkOut.trim());
            if (roomDetail != null) {
                CartRoomItemDTO roomItem = new CartRoomItemDTO(
                        roomDetail.getMaPhong(),
                        roomDetail.getSoPhong(),
                        roomDetail.getMaLoaiPhong(),
                        roomDetail.getTenLoaiPhong(),
                        roomDetail.getGiaPhong(),
                        checkIn.trim(),
                        checkOut.trim()
                );

                // Kiểm tra nếu có dịch vụ gửi kèm
                List<ServiceItem> activeServices = bookingService.getActiveServices();
                if (activeServices != null) {
                    List<CartServiceItemDTO> selectedSvcs = new ArrayList<>();
                    for (ServiceItem svc : activeServices) {
                        String sId = svc.getMaDichVu();
                        String paramSvc = request.getParameter("service_" + sId);
                        if (paramSvc == null) {
                            paramSvc = request.getParameter("service_" + roomId + "_" + sId);
                        }
                        if (paramSvc != null) {
                            int qty = 1;
                            String qtyVal = request.getParameter("qty_" + sId);
                            if (qtyVal == null) {
                                qtyVal = request.getParameter("qty_" + roomId + "_" + sId);
                            }
                            if (qtyVal != null && !qtyVal.trim().isEmpty()) {
                                try {
                                    qty = Math.max(1, Integer.parseInt(qtyVal.trim()));
                                } catch (NumberFormatException ignored) {
                                    qty = 1;
                                }
                            }
                            selectedSvcs.add(new CartServiceItemDTO(sId, svc.getTenDichVu(), svc.getDonGia(), qty));
                        }
                    }
                    if (!selectedSvcs.isEmpty()) {
                        roomItem.setSelectedServices(selectedSvcs);
                    }
                }

                cart.addOrUpdateRoom(roomItem);

                if (ajaxRequested) {
                    String json = String.format(
                        "{\"success\":true,\"soPhong\":\"%s\",\"tenLoaiPhong\":\"%s\",\"soDem\":%d,\"roomPrice\":%.0f,\"serviceTotal\":%.0f,\"roomTotal\":%.0f,\"cartTotalRooms\":%d,\"cartGrandTotal\":%.0f,\"checkIn\":\"%s\",\"checkOut\":\"%s\"}",
                        roomItem.getSoPhong(),
                        roomItem.getTenLoaiPhong(),
                        roomItem.getSoDem(),
                        roomItem.getTienPhong(),
                        roomItem.getTongTienDichVu(),
                        roomItem.getTongTienPhongVaDichVu(),
                        cart.getTotalRoomCount(),
                        cart.getGrandTotal(),
                        checkIn.trim(),
                        checkOut.trim()
                    );
                    sendRawJsonResponse(response, json);
                    return;
                }
            }
        } catch (Exception ex) {
            if (ajaxRequested) {
                sendJsonResponse(response, false, ex.getMessage(), null);
                return;
            }
            String error = URLEncoder.encode("Không thể thêm phòng vào giỏ: " + ex.getMessage(), StandardCharsets.UTF_8.name());
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms?checkIn=" + checkIn + "&checkOut=" + checkOut + "&error=" + error);
            return;
        }

        if ("checkout".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/customer/booking");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms?checkIn=" + checkIn + "&checkOut=" + checkOut + "&addedRoom=" + roomId);
        }
    }

    private void handleRemoveRoom(HttpServletRequest request, HttpServletResponse response, BookingCartDTO cart)
            throws IOException {
        String roomId = request.getParameter("roomId");
        if (roomId == null) roomId = request.getParameter("maPhong");

        if (roomId != null) {
            cart.removeRoom(roomId.trim());
        }

        if (cart.getTotalRoomCount() == 0) {
            response.sendRedirect(request.getContextPath() + "/customer/search-rooms");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/booking");
        }
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
