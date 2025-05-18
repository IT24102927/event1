package com.photobooking.servlet.booking;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling updates to bookings
 */
@WebServlet("/booking/update")
public class BookingUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles POST requests - processes booking update form
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

        try {
            // Get booking ID and basic info
            String bookingId = request.getParameter("bookingId");
            if (ValidationUtil.isNullOrEmpty(bookingId)) {
                session.setAttribute("errorMessage", "Booking ID is required");
                response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
                return;
            }

            // Get booking manager and retrieve booking
            BookingManager bookingManager = new BookingManager();
            Booking booking = bookingManager.getBookingById(bookingId);

            if (booking == null) {
                session.setAttribute("errorMessage", "Booking not found");
                response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
                return;
            }

            // Check permissions
            boolean isClient = currentUser.getUserId().equals(booking.getClientId());
            boolean isPhotographer = currentUser.getUserId().equals(booking.getPhotographerId());
            boolean isAdmin = currentUser.getUserType() == User.UserType.ADMIN;

            if (!isClient && !isPhotographer && !isAdmin) {
                session.setAttribute("errorMessage", "You don't have permission to update this booking");
                response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
                return;
            }

            // Check the action parameter
            String action = request.getParameter("action");
            if (ValidationUtil.isNullOrEmpty(action)) {
                session.setAttribute("errorMessage", "Action is required");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);
                return;
            }

            // Process based on action
            switch (action) {
                case "updateStatus":
                    processStatusUpdate(request, response, booking, bookingManager, isClient, isPhotographer, isAdmin);
                    break;
                case "updateDetails":
                    processDetailsUpdate(request, response, booking, bookingManager, isClient, isPhotographer, isAdmin);
                    break;
                case "cancel":
                    processCancel(request, response, booking, bookingManager, isClient, isPhotographer, isAdmin);
                    break;
                default:
                    session.setAttribute("errorMessage", "Invalid action");
                    response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);
                    break;
            }

        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
        }
    }

    /**
     * Process booking status update
     */
    private void processStatusUpdate(HttpServletRequest request, HttpServletResponse response,
                                     Booking booking, BookingManager bookingManager,
                                     boolean isClient, boolean isPhotographer, boolean isAdmin)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Get the new status
        String statusStr = request.getParameter("status");
        if (ValidationUtil.isNullOrEmpty(statusStr)) {
            session.setAttribute("errorMessage", "Status is required");
            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
            return;
        }

        try {
            Booking.BookingStatus newStatus = Booking.BookingStatus.valueOf(statusStr);

            // Validate the status update based on user type and current status
            if (!isValidStatusUpdate(booking, newStatus, isClient, isPhotographer, isAdmin)) {
                session.setAttribute("errorMessage", "You don't have permission to change to this status");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
                return;
            }

            // Update booking status
            if (bookingManager.updateBookingStatus(booking.getBookingId(), newStatus)) {
                session.setAttribute("successMessage", "Booking status updated successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to update booking status");
            }

            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", "Invalid status value");
            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
        }
    }

    /**
     * Process booking details update
     */
    private void processDetailsUpdate(HttpServletRequest request, HttpServletResponse response,
                                      Booking booking, BookingManager bookingManager,
                                      boolean isClient, boolean isPhotographer, boolean isAdmin)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Only clients and admins can update details
        if (!isClient && !isAdmin) {
            session.setAttribute("errorMessage", "You don't have permission to update booking details");
            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
            return;
        }

        // Only allow updates for pending and confirmed bookings
        if (booking.getStatus() != Booking.BookingStatus.PENDING &&
                booking.getStatus() != Booking.BookingStatus.CONFIRMED) {
            session.setAttribute("errorMessage", "Cannot update details for " + booking.getStatus() + " bookings");
            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
            return;
        }

        // Get updated details
        String eventLocation = request.getParameter("eventLocation");
        String eventNotes = request.getParameter("eventNotes");
        String eventDateTimeStr = request.getParameter("eventDateTime");
        String eventTypeStr = request.getParameter("eventType");

        // Update booking object
        if (!ValidationUtil.isNullOrEmpty(eventLocation)) {
            booking.setEventLocation(eventLocation);
        }

        booking.setEventNotes(eventNotes);

        // Update event date/time if provided and valid
        if (!ValidationUtil.isNullOrEmpty(eventDateTimeStr)) {
            try {
                LocalDateTime eventDateTime = LocalDateTime.parse(eventDateTimeStr);

                // Validate that date is in the future
                if (eventDateTime.isBefore(LocalDateTime.now())) {
                    session.setAttribute("errorMessage", "Event date must be in the future");
                    response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
                    return;
                }

                booking.setEventDateTime(eventDateTime);
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Invalid date/time format");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
                return;
            }
        }

        // Update event type if provided and valid
        if (!ValidationUtil.isNullOrEmpty(eventTypeStr)) {
            try {
                Booking.BookingType eventType = Booking.BookingType.valueOf(eventTypeStr);
                booking.setEventType(eventType);
            } catch (IllegalArgumentException e) {
                session.setAttribute("errorMessage", "Invalid event type");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
                return;
            }
        }

        // Update the booking
        if (bookingManager.updateBooking(booking)) {
            session.setAttribute("successMessage", "Booking details updated successfully");
        } else {
            session.setAttribute("errorMessage", "Failed to update booking details");
        }

        response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
    }

    /**
     * Process booking cancellation
     */
    private void processCancel(HttpServletRequest request, HttpServletResponse response,
                               Booking booking, BookingManager bookingManager,
                               boolean isClient, boolean isPhotographer, boolean isAdmin)
            throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Anyone involved can cancel, but only in certain statuses
        if (booking.getStatus() == Booking.BookingStatus.COMPLETED ||
                booking.getStatus() == Booking.BookingStatus.CANCELLED) {
            session.setAttribute("errorMessage", "Cannot cancel a " + booking.getStatus() + " booking");
            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + booking.getBookingId());
            return;
        }

        // Get cancellation reason
        String cancellationReason = request.getParameter("cancellationReason");

        // Add cancellation reason to notes
        String updatedNotes = booking.getEventNotes();
        if (updatedNotes == null) {
            updatedNotes = "";
        }

        // Append cancellation info to notes
        String cancellationNote = "\n\n[CANCELLATION] " +
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) +
                " - Reason: " + (ValidationUtil.isNullOrEmpty(cancellationReason) ? "Not provided" : cancellationReason);

        booking.setEventNotes(updatedNotes + cancellationNote);

        // Cancel the booking
        if (bookingManager.cancelBooking(booking.getBookingId())) {
            session.setAttribute("successMessage", "Booking cancelled successfully");
        } else {
            session.setAttribute("errorMessage", "Failed to cancel booking");
        }

        response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
    }

    /**
     * Check if status update is valid based on user role and current status
     */
    private boolean isValidStatusUpdate(Booking booking, Booking.BookingStatus newStatus,
                                        boolean isClient, boolean isPhotographer, boolean isAdmin) {
        // Admin can make any status change
        if (isAdmin) {
            return true;
        }

        Booking.BookingStatus currentStatus = booking.getStatus();

        // Client can only cancel their booking
        if (isClient) {
            return newStatus == Booking.BookingStatus.CANCELLED;
        }

        // Photographer cannot change status from cancelled
        if (isPhotographer && currentStatus == Booking.BookingStatus.CANCELLED) {
            return false;
        }

        // Photographer can confirm a pending booking
        if (isPhotographer && currentStatus == Booking.BookingStatus.PENDING &&
                newStatus == Booking.BookingStatus.CONFIRMED) {
            return true;
        }

        // Photographer can mark a confirmed booking as completed
        if (isPhotographer && currentStatus == Booking.BookingStatus.CONFIRMED &&
                newStatus == Booking.BookingStatus.COMPLETED) {
            return true;
        }

        // Photographer can cancel a pending or confirmed booking
        if (isPhotographer &&
                (currentStatus == Booking.BookingStatus.PENDING ||
                        currentStatus == Booking.BookingStatus.CONFIRMED) &&
                newStatus == Booking.BookingStatus.CANCELLED) {
            return true;
        }

        // Default to disallow
        return false;
    }
}