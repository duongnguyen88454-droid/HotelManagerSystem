package com.mycompany.hotelmanagersystem.room.dto;

import java.io.Serializable;
import java.time.LocalDate;

public class TimelineDayDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int dayIndex;
    private String dateStr;
    private String nextDateStr;
    private int dayOfMonth;
    private String dayOfWeekName;
    private boolean isToday;
    private String displayShort;

    public TimelineDayDTO() {
    }

    public TimelineDayDTO(int dayIndex, LocalDate date, boolean isToday) {
        this.dayIndex = dayIndex;
        this.dateStr = date.toString();
        this.nextDateStr = date.plusDays(1).toString();
        this.dayOfMonth = date.getDayOfMonth();
        this.isToday = isToday;
        this.displayShort = String.format("%02d/%02d", date.getDayOfMonth(), date.getMonthValue());

        switch (date.getDayOfWeek()) {
            case MONDAY:
                this.dayOfWeekName = "Thứ hai";
                break;
            case TUESDAY:
                this.dayOfWeekName = "Thứ ba";
                break;
            case WEDNESDAY:
                this.dayOfWeekName = "Thứ tư";
                break;
            case THURSDAY:
                this.dayOfWeekName = "Thứ năm";
                break;
            case FRIDAY:
                this.dayOfWeekName = "Thứ sáu";
                break;
            case SATURDAY:
                this.dayOfWeekName = "Thứ bảy";
                break;
            case SUNDAY:
                this.dayOfWeekName = "Chủ nhật";
                break;
            default:
                this.dayOfWeekName = "";
                break;
        }
    }

    public int getDayIndex() {
        return dayIndex;
    }

    public void setDayIndex(int dayIndex) {
        this.dayIndex = dayIndex;
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

    public int getDayOfMonth() {
        return dayOfMonth;
    }

    public void setDayOfMonth(int dayOfMonth) {
        this.dayOfMonth = dayOfMonth;
    }

    public String getDayOfWeekName() {
        return dayOfWeekName;
    }

    public void setDayOfWeekName(String dayOfWeekName) {
        this.dayOfWeekName = dayOfWeekName;
    }

    public boolean isToday() {
        return isToday;
    }

    public void setToday(boolean today) {
        isToday = today;
    }

    public String getDisplayShort() {
        return displayShort;
    }

    public void setDisplayShort(String displayShort) {
        this.displayShort = displayShort;
    }
}
