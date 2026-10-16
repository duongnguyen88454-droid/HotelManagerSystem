package com.mycompany.hotelmanagersystem.room.dto;

import java.io.Serializable;

public class TimelineCellDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int colIndex;
    private String dateStr;
    private String nextDateStr;
    private String displayDate;
    private boolean isToday;
    private boolean barStart;
    private boolean barCovered;
    private BookingBarDTO bookingBar;
    private boolean empty;

    public TimelineCellDTO() {
    }

    public TimelineCellDTO(int colIndex, String dateStr, String nextDateStr,
            String displayDate, boolean isToday) {
        this.colIndex = colIndex;
        this.dateStr = dateStr;
        this.nextDateStr = nextDateStr;
        this.displayDate = displayDate;
        this.isToday = isToday;
        this.empty = true;
    }

    public int getColIndex() {
        return colIndex;
    }

    public void setColIndex(int colIndex) {
        this.colIndex = colIndex;
    }

    public String getDateStr() {
        return dateStr;
    }

    public void setDateStr(String dateStr) {
        this.dateStr = dateStr;
    }

    public String getNextDateStr() {
        return nextDateStr;
    }

    public void setNextDateStr(String nextDateStr) {
        this.nextDateStr = nextDateStr;
    }

    public String getDisplayDate() {
        return displayDate;
    }

    public void setDisplayDate(String displayDate) {
        this.displayDate = displayDate;
    }

    public boolean isToday() {
        return isToday;
    }

    public void setToday(boolean today) {
        isToday = today;
    }

    public boolean isBarStart() {
        return barStart;
    }

    public void setBarStart(boolean barStart) {
        this.barStart = barStart;
    }

    public boolean isBarCovered() {
        return barCovered;
    }

    public void setBarCovered(boolean barCovered) {
        this.barCovered = barCovered;
    }

    public BookingBarDTO getBookingBar() {
        return bookingBar;
    }

    public void setBookingBar(BookingBarDTO bookingBar) {
        this.bookingBar = bookingBar;
    }

    public boolean isEmpty() {
        return empty;
    }

    public void setEmpty(boolean empty) {
        this.empty = empty;
    }
}
