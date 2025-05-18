package com.photobooking.model.booking;

import com.photobooking.util.FileHandler;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Logger;
import java.util.logging.Level;
import javax.servlet.ServletContext;

/**
 * Manages all booking-related operations for the Event Photography System
 */
public class BookingManager {
    private static final Logger LOGGER = Logger.getLogger(BookingManager.class.getName());
    private static final String BOOKING_FILE = "bookings.txt";
    private List<Booking> bookings;
    private ServletContext servletContext;

    public BookingManager() {
        this(null);
    }

    public BookingManager(ServletContext servletContext) {
        this.servletContext = servletContext;

        // If servletContext is provided, make sure FileHandler is initialized with it
        if (servletContext != null) {
            FileHandler.setServletContext(servletContext);
        }

        this.bookings = loadBookings();
    }

    /**
     * Load bookings from file
     * @return List of bookings
     */
    private List<Booking> loadBookings() {
        // Ensure file exists before loading
        FileHandler.ensureFileExists(BOOKING_FILE);

        List<String> lines = FileHandler.readLines(BOOKING_FILE);
        List<Booking> loadedBookings = new ArrayList<>();

        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                Booking booking = Booking.fromFileString(line);
                if (booking != null) {
                    loadedBookings.add(booking);
                }
            }
        }

        LOGGER.info("Loaded " + loadedBookings.size() + " bookings from file");
        return loadedBookings;
    }

    /**
     * Save all bookings to file
     * @return true if successful, false otherwise
     */
    private boolean saveBookings() {
        try {
            // Create a backup first
            if (FileHandler.fileExists(BOOKING_FILE)) {
                FileHandler.copyFile(BOOKING_FILE, BOOKING_FILE + ".bak");
            }

            // Delete existing file content
            FileHandler.deleteFile(BOOKING_FILE);

            // Ensure file exists
            FileHandler.ensureFileExists(BOOKING_FILE);

            // Write all bookings at once for better performance
            StringBuilder contentToWrite = new StringBuilder();
            for (Booking booking : bookings) {
                contentToWrite.append(booking.toFileString()).append(System.lineSeparator());
            }

            boolean result = FileHandler.writeToFile(BOOKING_FILE, contentToWrite.toString(), false);

            if (result) {
                LOGGER.info("Successfully saved " + bookings.size() + " bookings");
            } else {
                LOGGER.warning("Failed to save bookings");
                // Restore from backup
                if (FileHandler.fileExists(BOOKING_FILE + ".bak")) {
                    FileHandler.copyFile(BOOKING_FILE + ".bak", BOOKING_FILE);
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving bookings: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Create a new booking
     * @param booking The booking to create
     * @return true if successful, false otherwise
     */
    public boolean createBooking(Booking booking) {
        // Basic validation
        if (booking == null || booking.getClientId() == null || booking.getPhotographerId() == null) {
            return false;
        }

        // Set booking date time to now if not set
        if (booking.getBookingDateTime() == null) {
            booking.setBookingDateTime(LocalDateTime.now());
        }

        // Set status to PENDING if not set
        if (booking.getStatus() == null) {
            booking.setStatus(Booking.BookingStatus.PENDING);
        }

        // Add to list and save
        bookings.add(booking);
        return saveBookings();
    }

    /**
     * Get booking by ID
     * @param bookingId The booking ID
     * @return The booking or null if not found
     */
    public Booking getBookingById(String bookingId) {
        if (bookingId == null) return null;

        return bookings.stream()
                .filter(b -> b.getBookingId().equals(bookingId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get all bookings for a client
     * @param clientId The client ID
     * @return List of bookings for the client
     */
    public List<Booking> getBookingsByClient(String clientId) {
        if (clientId == null) return new ArrayList<>();

        return bookings.stream()
                .filter(b -> b.getClientId().equals(clientId))
                .collect(Collectors.toList());
    }

    /**
     * Get all bookings for a photographer
     * @param photographerId The photographer ID
     * @return List of bookings for the photographer
     */
    public List<Booking> getBookingsByPhotographer(String photographerId) {
        if (photographerId == null) return new ArrayList<>();

        return bookings.stream()
                .filter(b -> b.getPhotographerId().equals(photographerId))
                .collect(Collectors.toList());
    }

    /**
     * Get all bookings with a specific status
     * @param status The booking status
     * @return List of bookings with the specified status
     */
    public List<Booking> getBookingsByStatus(Booking.BookingStatus status) {
        if (status == null) return new ArrayList<>();

        return bookings.stream()
                .filter(b -> b.getStatus() == status)
                .collect(Collectors.toList());
    }

    /**
     * Get all bookings for a date range
     * @param startDate The start date (inclusive)
     * @param endDate The end date (inclusive)
     * @return List of bookings in the date range
     */
    public List<Booking> getBookingsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        if (startDate == null || endDate == null) return new ArrayList<>();

        return bookings.stream()
                .filter(b -> !b.getEventDateTime().isBefore(startDate) && !b.getEventDateTime().isAfter(endDate))
                .collect(Collectors.toList());
    }

    /**
     * Get all bookings
     * @return List of all bookings
     */
    public List<Booking> getAllBookings() {
        return new ArrayList<>(bookings);
    }

    /**
     * Update an existing booking
     * @param updatedBooking The updated booking
     * @return true if successful, false otherwise
     */
    public boolean updateBooking(Booking updatedBooking) {
        if (updatedBooking == null || updatedBooking.getBookingId() == null) {
            return false;
        }

        for (int i = 0; i < bookings.size(); i++) {
            if (bookings.get(i).getBookingId().equals(updatedBooking.getBookingId())) {
                bookings.set(i, updatedBooking);
                return saveBookings();
            }
        }

        return false; // Booking not found
    }

    /**
     * Update booking status
     * @param bookingId The booking ID
     * @param newStatus The new status
     * @return true if successful, false otherwise
     */
    public boolean updateBookingStatus(String bookingId, Booking.BookingStatus newStatus) {
        if (bookingId == null || newStatus == null) {
            return false;
        }

        for (Booking booking : bookings) {
            if (booking.getBookingId().equals(bookingId)) {
                booking.setStatus(newStatus);
                return saveBookings();
            }
        }

        return false; // Booking not found
    }

    /**
     * Cancel a booking
     * @param bookingId The booking ID
     * @return true if successful, false otherwise
     */
    public boolean cancelBooking(String bookingId) {
        return updateBookingStatus(bookingId, Booking.BookingStatus.CANCELLED);
    }

    /**
     * Delete a booking
     * @param bookingId The booking ID
     * @return true if successful, false otherwise
     */
    public boolean deleteBooking(String bookingId) {
        if (bookingId == null) {
            return false;
        }

        boolean removed = bookings.removeIf(b -> b.getBookingId().equals(bookingId));
        if (removed) {
            return saveBookings();
        }

        return false; // Booking not found
    }

    /**
     * Check if a photographer is available for a given date and time
     * @param photographerId The photographer ID
     * @param eventDateTime The event date and time
     * @param durationHours The duration in hours
     * @return true if available, false otherwise
     */
    public boolean isPhotographerAvailable(String photographerId, LocalDateTime eventDateTime, int durationHours) {
        if (photographerId == null || eventDateTime == null) {
            return false;
        }

        LocalDateTime eventEndTime = eventDateTime.plusHours(durationHours);

        // Check existing bookings for conflicts
        for (Booking booking : bookings) {
            if (booking.getPhotographerId().equals(photographerId) &&
                    booking.getStatus() != Booking.BookingStatus.CANCELLED) {

                // Estimate booking duration as 3 hours if not specified
                int existingBookingDuration = 3;

                LocalDateTime existingStart = booking.getEventDateTime();
                LocalDateTime existingEnd = existingStart.plusHours(existingBookingDuration);

                // Check for overlap
                if ((eventDateTime.isBefore(existingEnd) && eventEndTime.isAfter(existingStart))) {
                    return false; // Conflict found
                }
            }
        }

        return true; // No conflicts found
    }

    /**
     * Get upcoming bookings for a user
     * @param userId The user ID
     * @param isPhotographer true if user is a photographer, false if client
     * @return List of upcoming bookings
     */
    public List<Booking> getUpcomingBookings(String userId, boolean isPhotographer) {
        if (userId == null) return new ArrayList<>();

        LocalDateTime now = LocalDateTime.now();

        return bookings.stream()
                .filter(b -> {
                    if (isPhotographer) {
                        return b.getPhotographerId().equals(userId);
                    } else {
                        return b.getClientId().equals(userId);
                    }
                })
                .filter(b -> b.getEventDateTime().isAfter(now))
                .filter(b -> b.getStatus() != Booking.BookingStatus.CANCELLED)
                .sorted((b1, b2) -> b1.getEventDateTime().compareTo(b2.getEventDateTime()))
                .collect(Collectors.toList());
    }

    /**
     * Get past bookings for a user
     * @param userId The user ID
     * @param isPhotographer true if user is a photographer, false if client
     * @return List of past bookings
     */
    public List<Booking> getPastBookings(String userId, boolean isPhotographer) {
        if (userId == null) return new ArrayList<>();

        LocalDateTime now = LocalDateTime.now();

        return bookings.stream()
                .filter(b -> {
                    if (isPhotographer) {
                        return b.getPhotographerId().equals(userId);
                    } else {
                        return b.getClientId().equals(userId);
                    }
                })
                .filter(b -> b.getEventDateTime().isBefore(now))
                .sorted((b1, b2) -> b2.getEventDateTime().compareTo(b1.getEventDateTime())) // Newest first
                .collect(Collectors.toList());
    }

    /**
     * Set ServletContext (can be used to update the context after initialization)
     * @param servletContext the servlet context
     */
    public void setServletContext(ServletContext servletContext) {
        this.servletContext = servletContext;

        // Update FileHandler with the new ServletContext
        FileHandler.setServletContext(servletContext);

        // Reload bookings with the new file path
        bookings.clear();
        bookings = loadBookings();
    }
}