package com.photobooking.servlet.booking;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingQueueManager;
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for handling booking queue operations
 */
@WebServlet("/booking/queue")
public class BookingQueueServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(BookingQueueServlet.class.getName());

    /**
     * Handles GET requests - display queued bookings
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        try {
            // Get booking queue manager with proper error handling
            BookingQueueManager queueManager = BookingQueueManager.getInstance(getServletContext());
            if (queueManager == null) {
                session.setAttribute("errorMessage", "Error initializing booking queue manager");
                response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
                return;
            }

            List<Booking> queuedBookings = new ArrayList<>();

            // Get bookings based on user type
            if (currentUser.getUserType() == User.UserType.CLIENT) {
                // Clients can only see their own queued bookings
                queuedBookings = queueManager.getQueuedBookingsForClient(currentUser.getUserId());
            } else if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
                // Photographers can see bookings queued for them
                queuedBookings = queueManager.getQueuedBookingsForPhotographer(currentUser.getUserId());
            } else {
                // Admins can see all queued bookings
                queuedBookings = queueManager.getAllQueuedBookings();
            }

            // Set attributes for JSP
            request.setAttribute("queuedBookings", queuedBookings);

            // Forward to booking queue page
            request.getRequestDispatcher("/booking/booking_queue.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading booking queue: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "Error loading booking queue: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
        }
    }

    /**
     * Handles POST requests - process queued bookings
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Get action parameter
        String action = request.getParameter("action");

        try {
            // Get booking queue manager with proper error handling
            BookingQueueManager queueManager = BookingQueueManager.getInstance(getServletContext());
            if (queueManager == null) {
                session.setAttribute("errorMessage", "Error initializing booking queue manager");
                response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
                return;
            }

            if ("processNext".equals(action)) {
                // Process next booking (photographers process their own, admins can process any)
                if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
                    Booking processed = queueManager.processNextBookingForPhotographer(currentUser.getUserId());
                    if (processed != null) {
                        session.setAttribute("successMessage", "Booking processed successfully: " + processed.getBookingId());
                    } else {
                        session.setAttribute("infoMessage", "No bookings in your queue");
                    }
                } else if (currentUser.getUserType() == User.UserType.ADMIN) {
                    Booking processed = queueManager.processNextBooking();
                    if (processed != null) {
                        session.setAttribute("successMessage", "Booking processed successfully: " + processed.getBookingId());
                    } else {
                        session.setAttribute("infoMessage", "No bookings in the queue");
                    }
                } else {
                    session.setAttribute("errorMessage", "You don't have permission to process bookings");
                }
            } else if ("processBatch".equals(action)) {
                // Process batch of bookings (for photographers and admins)
                String limitStr = request.getParameter("limit");
                int limit = 5; // Default limit

                try {
                    if (!ValidationUtil.isNullOrEmpty(limitStr)) {
                        limit = Integer.parseInt(limitStr);
                    }
                } catch (NumberFormatException e) {
                    // Use default limit if parsing fails
                }

                if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
                    int processed = queueManager.processBatchForPhotographer(currentUser.getUserId(), limit);
                    session.setAttribute("successMessage", processed + " bookings processed successfully");
                } else if (currentUser.getUserType() == User.UserType.ADMIN) {
                    // For admins, just process the next N bookings
                    int processed = 0;
                    for (int i = 0; i < limit && queueManager.getQueueSize() > 0; i++) {
                        Booking booking = queueManager.processNextBooking();
                        if (booking != null) {
                            processed++;
                        }
                    }
                    session.setAttribute("successMessage", processed + " bookings processed successfully");
                } else {
                    session.setAttribute("errorMessage", "You don't have permission to process bookings");
                }
            } else if ("processSpecific".equals(action)) {
                // Process a specific booking
                String bookingId = request.getParameter("bookingId");

                if (ValidationUtil.isNullOrEmpty(bookingId)) {
                    session.setAttribute("errorMessage", "Booking ID is required");
                    response.sendRedirect(request.getContextPath() + "/booking/queue");
                    return;
                }

                // Get all queued bookings
                List<Booking> queuedBookings = queueManager.getAllQueuedBookings();

                // Find the booking and check permissions
                boolean bookingFound = false;
                boolean hasPermission = false;

                for (Booking booking : queuedBookings) {
                    if (booking.getBookingId().equals(bookingId)) {
                        bookingFound = true;

                        // Check if user has permission to process this booking
                        if (currentUser.getUserType() == User.UserType.ADMIN ||
                                (currentUser.getUserType() == User.UserType.PHOTOGRAPHER &&
                                        currentUser.getUserId().equals(booking.getPhotographerId()))) {
                            hasPermission = true;
                        }

                        break;
                    }
                }

                if (!bookingFound) {
                    session.setAttribute("errorMessage", "Booking not found in queue");
                } else if (!hasPermission) {
                    session.setAttribute("errorMessage", "You don't have permission to process this booking");
                } else {
                    // Process the booking
                    // For a client, this would be the main queue removal
                    // For a photographer, this would be both queues

                    if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
                        Booking processed = queueManager.processNextBookingForPhotographer(currentUser.getUserId());
                        if (processed != null && processed.getBookingId().equals(bookingId)) {
                            session.setAttribute("successMessage", "Booking processed successfully: " + processed.getBookingId());
                        } else {
                            session.setAttribute("errorMessage", "Failed to process booking");
                        }
                    } else {
                        // Admin can process any booking
                        boolean processed = false;

                        // Find and remove the booking from all queues
                        List<Booking> allBookings = queueManager.getAllQueuedBookings();
                        for (int i = 0; i < allBookings.size(); i++) {
                            if (allBookings.get(i).getBookingId().equals(bookingId)) {
                                // Found the booking, process it
                                queueManager.processNextBooking(); // This will remove it from both queues
                                processed = true;
                                break;
                            }
                        }

                        if (processed) {
                            session.setAttribute("successMessage", "Booking processed successfully: " + bookingId);
                        } else {
                            session.setAttribute("errorMessage", "Failed to process booking");
                        }
                    }
                }
            } else if ("clear".equals(action)) {
                // Only admins can clear the queue
                if (currentUser.getUserType() != User.UserType.ADMIN) {
                    session.setAttribute("errorMessage", "You don't have permission to clear the queue");
                } else {
                    queueManager.clearAllQueues();
                    session.setAttribute("successMessage", "All booking queues cleared");
                }
            } else if ("queue".equals(action)) {
                // Handle queue creation (this would be implemented separately)
                processQueueCreation(request, response, session, currentUser, queueManager);
            } else {
                session.setAttribute("errorMessage", "Invalid action requested");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing booking queue action: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
        }

        // Redirect back to booking queue page
        response.sendRedirect(request.getContextPath() + "/booking/queue");
    }

    /**
     * Helper method to process queue creation
     */
    private void processQueueCreation(HttpServletRequest request, HttpServletResponse response,
                                      HttpSession session, User currentUser, BookingQueueManager queueManager)
            throws ServletException, IOException {
        // Create a new booking and queue it (simplified version)
        try {
            // Just set a message here - this would be implemented in a separate method
            session.setAttribute("infoMessage", "Queue creation functionality is not yet implemented");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating booking: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "Error creating booking: " + e.getMessage());
        }
    }
}