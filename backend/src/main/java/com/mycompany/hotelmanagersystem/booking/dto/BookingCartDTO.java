package com.mycompany.hotelmanagersystem.booking.dto;

import java.io.Serializable;
import java.util.LinkedHashMap;
import java.util.Map;

public class BookingCartDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private Map<String, CartRoomItemDTO> items = new LinkedHashMap<>();
    private String ghiChuChung;

    public BookingCartDTO() {
    }

    public Map<String, CartRoomItemDTO> getItems() {
        if (items == null) {
            items = new LinkedHashMap<>();
        }
        return items;
    }

    public void setItems(Map<String, CartRoomItemDTO> items) {
        this.items = items != null ? items : new LinkedHashMap<>();
    }

    public void addOrUpdateRoom(CartRoomItemDTO roomItem) {
        if (roomItem != null && roomItem.getMaPhong() != null) {
            getItems().put(roomItem.getMaPhong(), roomItem);
        }
    }

    public void removeRoom(String maPhong) {
        if (maPhong != null) {
            getItems().remove(maPhong);
        }
    }

    public void clear() {
        getItems().clear();
        this.ghiChuChung = null;
    }

    public int getTotalRoomCount() {
        return getItems().size();
    }

    public boolean isCartEmpty() {
        return getItems().isEmpty();
    }

    public double getTotalRoomCost() {
        double total = 0.0;
        for (CartRoomItemDTO room : getItems().values()) {
            total += room.getTienPhong();
        }
        return total;
    }

    public double getTotalServiceCost() {
        double total = 0.0;
        for (CartRoomItemDTO room : getItems().values()) {
            total += room.getTongTienDichVu();
        }
        return total;
    }

    public double getGrandTotal() {
        return getTotalRoomCost() + getTotalServiceCost();
    }

    public double getTotalDeposit() {
        double total = 0.0;
        for (CartRoomItemDTO room : getItems().values()) {
            total += room.getTienCoc();
        }
        return total;
    }

    public String getGhiChuChung() {
        return ghiChuChung;
    }

    public void setGhiChuChung(String ghiChuChung) {
        this.ghiChuChung = ghiChuChung;
    }
}
