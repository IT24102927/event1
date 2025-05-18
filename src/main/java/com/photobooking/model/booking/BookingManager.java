package com.photobooking.model.booking;

import com.photobooking.util.FileHandler;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import javax.servlet.ServletContext;

/**
 * Manages all booking-related operations and queue-based processing for the Event Photography System.
 * Combines persistence, CRUD operations, and queue management for bookings.
 */
public class BookingManager {
    private static final Logger LOGGER = Logger.getLogger(BookingManager.class.getName());
    private static final String BOOKING_FILE = "bookings.txt";
    private List<Booking> bookings; // Persisted bookings
    private BookingQueue mainQueue; // Main queue for all bookings
    private Map<String, BookingQueue> photographerQueues; // Photographer-specific queues
    private ServletContext servletContext;

    /**
     * Constructor initializes the booking manager with persisted bookings and queues.
     * @param servletContext The servlet context for file operations
     */
    public BookingManager(ServletContext servletContext) {
        try {
            LOGGER.info("Initializing BookingManager with context: " +
                    (servletContext != null ? servletContext.getContextPath() : "null"));
            this.servletContext = servletContext;
            if (servletContext != null) {
                FileHandler.setServletContext(servletContext);
            }
            this.bookings = loadBookings();
            this.mainQueue = new BookingQueue(this);
            this.photographerQueues = new HashMap<>();
            LOGGER.info("BookingManager initialized successfully");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing BookingManager: " + e.getMessage(), e);
            throw new RuntimeException("Failed to initialize BookingManager", e);
        }
    }

    /**
     * Load bookings from file.
     * @return List of bookings
     */
    private List<Booking> loadBookings() {
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
     * Save all bookings to file.
     * @return true if successful, false otherwise
     */
    private boolean saveBookings() {
        try {
            if (FileHandler.fileExists(BOOKING_FILE)) {
                FileHandler.copyFile(BOOKING_FILE, BOOKING_FILE + ".bak");
            }
            FileHandler.deleteFile(BOOKING_FILE);
            FileHandler.ensureFileExists(BOOKING_FILE);
            StringBuilder contentToWrite = new StringBuilder();
            for (Booking booking : bookings) {
                contentToWrite.append(booking.toFileString()).append(System.lineSeparator());
            }
            boolean result = FileHandler.writeToFile(BOOKING_FILE, contentToWrite.toString(), false);
            if (result) {
                LOGGER.info("Successfully saved " + bookings.size() + " bookings");
            } else {
                LOGGER.warning("Failed to save bookings");
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
     * Queue a new booking request.
     * @param booking The booking to queue
     * @return true if successfully queued
     */
    public boolean queueBooking(Booking booking) {
        if (booking == null) {
            LOGGER.warning("Attempted to queue null booking");
            return false;
        }
        try {
            boolean addedToMain = mainQueue.enqueue(booking);
            String photographerId = booking.getPhotographerId();
            if (photographerId != null) {
                BookingQueue photographerQueue = getPhotographerQueue(photographerId);
                boolean addedToPhotographer = photographerQueue.enqueue(booking);
                LOGGER.info("Booking " + booking.getBookingId() + " queued for photographer " + photographerId);
                return addedToMain && addedToPhotographer;
            }
            return addedToMain;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error queuing booking: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Get or create a queue for a specific photographer.
     * @param photographerId The photographer ID
     * @return The photographer's booking queue
     */
    private BookingQueue getPhotographerQueue(String photographerId) {
        if (!photographerQueues.containsKey(photographerId)) {
            photographerQueues.put(photographerId, new BookingQueue(this));
        }
        return photographerQueues.get(photographerId);
    }

    /**
     * Process the next booking in the main queue.
     * @return The processed booking, or null if the queue is empty
     */
    public Booking processNextBooking() {
        Booking booking = mainQueue.dequeue();
        if (booking != null) {
            String photographerId = booking.getPhotographerId();
            if (photographerId != null && photographerQueues.containsKey(photographerId)) {
                BookingQueue photographerQueue = photographerQueues.get(photographerId);
                photographerQueue.processBookingById(booking.getBookingId());
            }
            LOGGER.info("Booking " + booking.getBookingId() + " processed from queue");
        }
        return booking;
    }

    /**
     * Process the next booking for a specific photographer.
     * @param photographerId The photographer ID
     * @return The processed booking, or null if the queue is empty
     */
    public Booking processNextBookingForPhotographer(String photographerId) {
        if (photographerId == null || !photographerQueues.containsKey(photographerId)) {
            return null;
        }
        BookingQueue photographerQueue = photographerQueues.get(photographerId);
        Booking booking = photographerQueue.dequeue();
        if (booking != null) {
            mainQueue.processBookingById(booking.getBookingId());
            LOGGER.info("Booking " + booking.getBookingId() + " processed for photographer " + photographerId);
        }
        return booking;
    }

    /**
     * Create a new booking (persists to file).
     * @param booking The booking to create
     * @return true if successful, false otherwise
     */
    public boolean createBooking(Booking booking) {
        if (booking == null || booking.getClientId() == null || booking.getPhotographerId() == null) {
            return false;
        }
        if (booking.getBookingDateTime() == null) {
            booking.setBookingDateTime(LocalDateTime.now());
        }
        if (booking.getStatus() == null) {
            booking.setStatus(Booking.BookingStatus.PENDING);
        }
        bookings.add(booking);
        return saveBookings();
    }

    /**
     * Get booking by ID.
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
     * Get all bookings for a client.
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
     * Get all bookings for a photographer.
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
     * Get all bookings with a specific status.
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
     * Get all bookings for a date range.
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
     * Get all persisted bookings.
     * @return List of all bookings
     */
    public List<Booking> getAllBookings() {
        return new ArrayList<>(bookings);
    }

    /**
     * Get all queued bookings.
     * @return List of all queued bookings
     */
    public List<Booking> getAllQueuedBookings() {
        return mainQueue.getAllQueuedBookings();
    }

    /**
     * Get all queued bookings for a specific photographer.
     * @param photographerId The photographer ID
     * @return List of queued bookings for the photographer
     */
    public List<Booking> getQueuedBookingsForPhotographer(String photographerId) {
        if (photographerId == null || !photographerQueues.containsKey(photographerId)) {
            return new ArrayList<>();
        }
        return photographerQueues.get(photographerId).getAllQueuedBookings();
    }

    /**
     * Get all queued bookings for a specific client.
     * @param clientId The client ID
     * @return List of queued bookings for the client
     */
    public List<Booking> getQueuedBookingsForClient(String clientId) {
        return mainQueue.getQueuedBookingsForClient(clientId);
    }

    /**
     * Update an existing booking.
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
        return false;
    }

    /**
     * Update booking status.
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
        return false;
    }

    /**
     * Cancel a booking.
     * @param bookingId The booking ID
     * @return true if successful, false otherwise
     */
    public boolean cancelBooking(String bookingId) {
        return updateBookingStatus(bookingId, Booking.BookingStatus.CANCELLED);
    }

    /**
     * Delete a booking.
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
        return false;
    }

    /**
     * Check if a photographer is available for a given date and time.
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
        for (Booking booking : bookings) {
            if (booking.getPhotographerId().equals(photographerId) &&
                    booking.getStatus() != Booking.BookingStatus.CANCELLED) {
                int existingBookingDuration = 3;
                LocalDateTime existingStart = booking.getEventDateTime();
                LocalDateTime existingEnd = existingStart.plusHours(existingBookingDuration);
                if ((eventDateTime.isBefore(existingEnd) && eventEndTime.isAfter(existingStart))) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * Get upcoming bookings for a user.
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
     * Get past bookings for a user.
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
                .sorted((b1, b2) -> b2.getEventDateTime().compareTo(b1.getEventDateTime()))
                .collect(Collectors.toList());
    }

    /**
     * Batch process bookings for a specific photographer.
     * @param photographerId The photographer ID
     * @param limit Maximum number of bookings to process
     * @return Number of bookings processed
     */
    public int processBatchForPhotographer(String photographerId, int limit) {
        if (photographerId == null || !photographerQueues.containsKey(photographerId)) {
            return 0;
        }
        BookingQueue photographerQueue = photographerQueues.get(photographerId);
        int processed = 0;
        while (!photographerQueue.isEmpty() && processed < limit) {
            Booking booking = processNextBookingForPhotographer(photographerId);
            if (booking != null) {
                processed++;
            }
        }
        return processed;
    }

    /**
     * Get the number of bookings in the main queue.
     * @return The queue size
     */
    public int getQueueSize() {
        return mainQueue.size();
    }

    /**
     * Get the number of bookings in the queue for a specific photographer.
     * @param photographerId The photographer ID
     * @return The queue size for the photographer
     */
    public int getQueueSizeForPhotographer(String photographerId) {
        if (photographerId == null || !photographerQueues.containsKey(photographerId)) {
            return 0;
        }
        return photographerQueues.get(photographerId).size();
    }

    /**
     * Process all pending bookings in the main queue.
     * @return Number of bookings processed
     */
    public int processAllQueuedBookings() {
        return mainQueue.processAllBookings();
    }

    /**
     * Clear all queues.
     */
    public void clearAllQueues() {
        mainQueue.clear();
        for (BookingQueue queue : photographerQueues.values()) {
            queue.clear();
        }
        LOGGER.info("All booking queues cleared");
    }

    /**
     * Set ServletContext and reload bookings.
     * @param servletContext The servlet context
     */
    public void setServletContext(ServletContext servletContext) {
        this.servletContext = servletContext;
        FileHandler.setServletContext(servletContext);
        bookings.clear();
        bookings = loadBookings();
    }
}