package com.photobooking.model.booking;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * A queue-based implementation to manage photography bookings.
 * This class implements a FIFO (First-In-First-Out) queue using a custom singly linked list
 * with explicit front and rear pointers to process booking requests.
 */
public class BookingQueue {
    private static class Node {
        Booking booking;
        Node next;

        Node(Booking booking) {
            this.booking = booking;
            this.next = null;
        }
    }

    private Node front; // Points to the head of the queue (dequeue point)
    private Node rear;  // Points to the tail of the queue (enqueue point)
    private int size;   // Tracks the number of bookings in the queue
    private BookingManager bookingManager;

    /**
     * Constructor initializes an empty booking queue.
     * @param bookingManager The booking manager to save processed bookings
     */
    public BookingQueue(BookingManager bookingManager) {
        this.front = null;
        this.rear = null;
        this.size = 0;
        this.bookingManager = bookingManager;
    }

    /**
     * Add a new booking to the end of the queue.
     * @param booking The booking to add to the queue
     * @return true if the booking was added successfully
     */
    public boolean enqueue(Booking booking) {
        if (booking == null) {
            return false;
        }

        // Set booking status to PENDING by default
        booking.setStatus(Booking.BookingStatus.PENDING);

        Node newNode = new Node(booking);
        if (isEmpty()) {
            front = newNode;
            rear = newNode;
        } else {
            rear.next = newNode;
            rear = newNode;
        }
        size++;
        return true;
    }

    /**
     * Process and remove the booking at the front of the queue.
     * @return The processed booking, or null if the queue is empty
     */
    public Booking dequeue() {
        if (isEmpty()) {
            return null;
        }

        // Remove the booking at the front
        Booking booking = front.booking;
        front = front.next;
        size--;

        if (isEmpty()) {
            rear = null; // Reset rear when queue becomes empty
        }

        // Save the booking to the database/file
        bookingManager.createBooking(booking);
        return booking;
    }

    /**
     * Process and remove a specific booking from the queue by ID.
     * @param bookingId The ID of the booking to process
     * @return The processed booking, or null if not found
     */
    public Booking processBookingById(String bookingId) {
        if (bookingId == null || isEmpty()) {
            return null;
        }

        Node current = front;
        Node prev = null;

        // Search for the booking
        while (current != null && !current.booking.getBookingId().equals(bookingId)) {
            prev = current;
            current = current.next;
        }

        if (current == null) {
            return null; // Booking not found
        }

        // Remove the booking
        if (prev == null) {
            front = front.next; // Removing the front node
        } else {
            prev.next = current.next; // Bypass the current node
        }

        if (current == rear) {
            rear = prev; // Update rear if removing the last node
        }

        size--;

        // Save the booking to the database/file
        bookingManager.createBooking(current.booking);
        return current.booking;
    }

    /**
     * View the booking at the front of the queue without removing it.
     * @return The next booking in the queue, or null if the queue is empty
     */
    public Booking peek() {
        return isEmpty() ? null : front.booking;
    }

    /**
     * Get all bookings in the queue.
     * @return List of bookings currently in the queue
     */
    public List<Booking> getAllQueuedBookings() {
        List<Booking> bookings = new ArrayList<>();
        Node current = front;
        while (current != null) {
            bookings.add(current.booking);
            current = current.next;
        }
        return bookings;
    }

    /**
     * Get all bookings in the queue for a specific photographer.
     * @param photographerId The photographer's ID
     * @return List of bookings for the specified photographer
     */
    public List<Booking> getQueuedBookingsForPhotographer(String photographerId) {
        if (photographerId == null) {
            return new ArrayList<>();
        }

        return getAllQueuedBookings().stream()
                .filter(booking -> booking.getPhotographerId().equals(photographerId))
                .collect(Collectors.toList());
    }

    /**
     * Get all bookings in the queue for a specific client.
     * @param clientId The client's ID
     * @return List of bookings for the specified client
     */
    public List<Booking> getQueuedBookingsForClient(String clientId) {
        if (clientId == null) {
            return new ArrayList<>();
        }

        return getAllQueuedBookings().stream()
                .filter(booking -> booking.getClientId().equals(clientId))
                .collect(Collectors.toList());
    }

    /**
     * Check if the queue is empty.
     * @return true if the queue is empty, false otherwise
     */
    public boolean isEmpty() {
        return size == 0;
    }

    /**
     * Get the number of bookings in the queue.
     * @return The size of the queue
     */
    public int size() {
        return size;
    }

    /**
     * Clear all bookings from the queue.
     */
    public void clear() {
        front = null;
        rear = null;
        size = 0;
    }

    /**
     * Process all bookings in the queue.
     * @return Number of bookings processed
     */
    public int processAllBookings() {
        int processedCount = 0;
        while (!isEmpty()) {
            Booking booking = dequeue();
            if (booking != null) {
                processedCount++;
            }
        }
        return processedCount;
    }
}