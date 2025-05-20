package com.photobooking.model.booking;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.time.LocalDateTime;
import javax.servlet.ServletContext;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Manager class that integrates the BookingQueue with the rest of the application.
 * Provides methods for queuing, processing, and tracking bookings.
 */
public class BookingQueueManager {
    private static final Logger LOGGER = Logger.getLogger(BookingQueueManager.class.getName());

    // Main booking queue for all bookings
    private BookingQueue mainQueue;

    // Separate queues for each photographer to handle photographer-specific prioritization
    private Map<String, BookingQueue> photographerQueues;

    // The booking manager for persistent storage
    private BookingManager bookingManager;

    // Singleton instance
    private static BookingQueueManager instance;

    /**
     * Private constructor for singleton pattern
     * @param servletContext The servlet context
     */
    private BookingQueueManager(ServletContext servletContext) {
        try {
            LOGGER.info("Initializing BookingQueueManager with context: " +
                    (servletContext != null ? servletContext.getContextPath() : "null"));

            bookingManager = new BookingManager(servletContext);
            mainQueue = new BookingQueue(bookingManager);
            photographerQueues = new HashMap<>();

            LOGGER.info("BookingQueueManager initialized successfully");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing BookingQueueManager: " + e.getMessage(), e);
            throw new RuntimeException("Failed to initialize BookingQueueManager", e);
        }
    }

    /**
     * Get the singleton instance of BookingQueueManager
     * @param servletContext The servlet context
     * @return BookingQueueManager instance
     */
    public static synchronized BookingQueueManager getInstance(ServletContext servletContext) {
        if (instance == null) {
            try {
                LOGGER.info("Creating new BookingQueueManager instance");
                instance = new BookingQueueManager(servletContext);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Failed to create BookingQueueManager instance: " + e.getMessage(), e);
                return null; // Return null instead of throwing so that callers can handle it gracefully
            }
        }
        return instance;
    }

    /**
     * Queue a new booking request
     * @param booking The booking to queue
     * @return true if booking was successfully queued
     */
    public boolean queueBooking(Booking booking) {
        if (booking == null) {
            LOGGER.warning("Attempted to queue null booking");
            return false;
        }

        try {
            // Add to main queue
            boolean addedToMain = mainQueue.enqueue(booking);

            // Add to photographer-specific queue
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
     * Get or create a queue for a specific photographer
     * @param photographerId The photographer ID
     * @return The photographer's booking queue
     */
    private BookingQueue getPhotographerQueue(String photographerId) {
        if (!photographerQueues.containsKey(photographerId)) {
            photographerQueues.put(photographerId, new BookingQueue(bookingManager));
        }
        return photographerQueues.get(photographerId);
    }

    /**
     * Process the next booking in the main queue
     * @return The processed booking, or null if the queue is empty
     */
    public Booking processNextBooking() {
        Booking booking = mainQueue.dequeue();

        if (booking != null) {
            // Also remove from photographer queue
            String photographerId = booking.getPhotographerId();
            if (photographerId != null && photographerQueues.containsKey(photographerId)) {
                // Find and remove the booking from the photographer's queue
                BookingQueue photographerQueue = photographerQueues.get(photographerId);
                photographerQueue.processBookingById(booking.getBookingId());
            }

            LOGGER.info("Booking " + booking.getBookingId() + " processed from queue");
        }

        return booking;
    }

    /**
     * Process the next booking for a specific photographer
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
            // Also remove from main queue
            mainQueue.processBookingById(booking.getBookingId());

            LOGGER.info("Booking " + booking.getBookingId() + " processed for photographer " + photographerId);
        }

        return booking;
    }

    /**
     * Get all bookings in the queue
     * @return List of all queued bookings
     */
    public List<Booking> getAllQueuedBookings() {
        return mainQueue.getAllQueuedBookings();
    }

    /**
     * Get all queued bookings for a specific photographer
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
     * Get all queued bookings for a specific client
     * @param clientId The client ID
     * @return List of queued bookings for the client
     */
    public List<Booking> getQueuedBookingsForClient(String clientId) {
        return mainQueue.getQueuedBookingsForClient(clientId);
    }

    /**
     * Get the number of bookings in the queue
     * @return The queue size
     */
    public int getQueueSize() {
        return mainQueue.size();
    }

    /**
     * Get the number of bookings in the queue for a specific photographer
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
     * Process all pending bookings in the queue
     * @return Number of bookings processed
     */
    public int processAllQueuedBookings() {
        return mainQueue.processAllBookings();
    }

    /**
     * Batch process bookings for a specific photographer
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
     * Clear all queues
     */
    public void clearAllQueues() {
        mainQueue.clear();
        for (BookingQueue queue : photographerQueues.values()) {
            queue.clear();
        }

        LOGGER.info("All booking queues cleared");
    }

    /**
     * Reset the singleton instance (useful for testing)
     */
    public static void resetInstance() {
        instance = null;
        LOGGER.info("BookingQueueManager instance reset");
    }
}