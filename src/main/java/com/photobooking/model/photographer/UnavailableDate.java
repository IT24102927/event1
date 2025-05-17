package com.photobooking.model.photographer;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.UUID;

/**
 * Represents an unavailable date/time for a photographer
 */
public class UnavailableDate implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String photographerId;
    private LocalDate date;
    private boolean allDay;
    private String startTime;
    private String endTime;
    private String reason;

    public UnavailableDate() {
        this.id = UUID.randomUUID().toString();
    }

    public UnavailableDate(String photographerId, LocalDate date, boolean allDay, String reason) {
        this();
        this.photographerId = photographerId;
        this.date = date;
        this.allDay = allDay;
        this.reason = reason;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPhotographerId() {
        return photographerId;
    }

    public void setPhotographerId(String photographerId) {
        this.photographerId = photographerId;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public boolean isAllDay() {
        return allDay;
    }

    public void setAllDay(boolean allDay) {
        this.allDay = allDay;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String toFileString() {
        return String.join(",",
                id,
                photographerId,
                date.toString(),
                String.valueOf(allDay),
                startTime != null ? startTime : "",
                endTime != null ? endTime : "",
                reason != null ? reason : ""
        );
    }

    public static UnavailableDate fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length >= 4) {
            UnavailableDate date = new UnavailableDate();
            date.setId(parts[0]);
            date.setPhotographerId(parts[1]);
            date.setDate(LocalDate.parse(parts[2]));
            date.setAllDay(Boolean.parseBoolean(parts[3]));

            if (parts.length > 4) date.setStartTime(parts[4].isEmpty() ? null : parts[4]);
            if (parts.length > 5) date.setEndTime(parts[5].isEmpty() ? null : parts[5]);
            if (parts.length > 6) date.setReason(parts[6].isEmpty() ? null : parts[6]);

            return date;
        }
        return null;
    }
}