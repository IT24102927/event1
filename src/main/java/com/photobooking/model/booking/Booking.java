package com.photobooking.model.booking;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Represents a booking in the Event Photography System
 */
public class Booking implements Serializable {
    private static final long serialVersionUID = 1L;

    // Booking status enum
    public enum BookingStatus {
        PENDING, CONFIRMED, COMPLETED, CANCELLED
    }

    // Booking types
    public enum BookingType {
        WEDDING, CORPORATE, PORTRAIT, EVENT, FAMILY, PRODUCT, OTHER
    }

    // Booking attributes
    private String bookingId;
    private String clientId;
    private String photographerId;
    private String serviceId;
    private LocalDateTime bookingDateTime;
    private LocalDateTime eventDateTime;
    private String eventLocation;
    private String eventNotes;
    private BookingType eventType;
    private BookingStatus status;
    private double totalPrice;

    // Constructors
    public Booking() {
        this.bookingId = UUID.randomUUID().toString();
        this.status = BookingStatus.PENDING;
    }

    public Booking(String clientId, String photographerId, String serviceId,
                   LocalDateTime eventDateTime, String eventLocation,
                   BookingType eventType, double totalPrice) {
        this.bookingId = UUID.randomUUID().toString();
        this.clientId = clientId;
        this.photographerId = photographerId;
        this.serviceId = serviceId;
        this.bookingDateTime = LocalDateTime.now();
        this.eventDateTime = eventDateTime;
        this.eventLocation = eventLocation;
        this.eventType = eventType;
        this.totalPrice = totalPrice;
        this.status = BookingStatus.PENDING;
    }

    // Getters and Setters
    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getClientId() {
        return clientId;
    }

    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    public String getPhotographerId() {
        return photographerId;
    }

    public void setPhotographerId(String photographerId) {
        this.photographerId = photographerId;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public LocalDateTime getBookingDateTime() {
        return bookingDateTime;
    }

    public void setBookingDateTime(LocalDateTime bookingDateTime) {
        this.bookingDateTime = bookingDateTime;
    }

    public LocalDateTime getEventDateTime() {
        return eventDateTime;
    }

    public void setEventDateTime(LocalDateTime eventDateTime) {
        this.eventDateTime = eventDateTime;
    }

    public String getEventLocation() {
        return eventLocation;
    }

    public void setEventLocation(String eventLocation) {
        this.eventLocation = eventLocation;
    }

    public String getEventNotes() {
        return eventNotes;
    }

    public void setEventNotes(String eventNotes) {
        this.eventNotes = eventNotes;
    }

    public BookingType getEventType() {
        return eventType;
    }

    public void setEventType(BookingType eventType) {
        this.eventType = eventType;
    }

    public BookingStatus getStatus() {
        return status;
    }

    public void setStatus(BookingStatus status) {
        this.status = status;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    // Convert booking to file string representation
    public String toFileString() {
        return String.join(",",
                bookingId,
                clientId,
                photographerId,
                serviceId,
                bookingDateTime.toString(),
                eventDateTime.toString(),
                eventLocation,
                eventNotes != null ? eventNotes : "",
                eventType.name(),
                status.name(),
                String.valueOf(totalPrice)
        );
    }

    // Create booking from file string
    public static Booking fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length >= 11) {
            Booking booking = new Booking();
            booking.setBookingId(parts[0]);
            booking.setClientId(parts[1]);
            booking.setPhotographerId(parts[2]);
            booking.setServiceId(parts[3]);
            booking.setBookingDateTime(LocalDateTime.parse(parts[4]));
            booking.setEventDateTime(LocalDateTime.parse(parts[5]));
            booking.setEventLocation(parts[6]);
            booking.setEventNotes(parts[7].isEmpty() ? null : parts[7]);
            booking.setEventType(BookingType.valueOf(parts[8]));
            booking.setStatus(BookingStatus.valueOf(parts[9]));
            booking.setTotalPrice(Double.parseDouble(parts[10]));
            return booking;
        }
        return null;
    }

    @Override
    public String toString() {
        return "Booking{" +
                "bookingId='" + bookingId + '\'' +
                ", clientId='" + clientId + '\'' +
                ", photographerId='" + photographerId + '\'' +
                ", serviceId='" + serviceId + '\'' +
                ", eventDateTime=" + eventDateTime +
                ", eventType=" + eventType +
                ", status=" + status +
                '}';
    }
}