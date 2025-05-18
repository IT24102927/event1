package com.photobooking.model.booking;

/**
 * Enum representing the possible status values for a booking
 */
public enum BookingStatus {
    PENDING("Pending", "Booking has been created but not yet confirmed"),
    CONFIRMED("Confirmed", "Booking has been confirmed by the photographer"),
    CANCELLED("Cancelled", "Booking has been cancelled"),
    COMPLETED("Completed", "Photography service has been completed"),
    RESCHEDULED("Rescheduled", "Booking has been rescheduled to a new date/time");

    private final String displayName;
    private final String description;

    BookingStatus(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getDescription() {
        return description;
    }

    // Get status from display name
    public static BookingStatus fromDisplayName(String displayName) {
        for (BookingStatus status : values()) {
            if (status.getDisplayName().equalsIgnoreCase(displayName)) {
                return status;
            }
        }
        throw new IllegalArgumentException("No status found for display name: " + displayName);
    }
}
