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
 * Servlet for handling booking cancellations
 */
@WebServlet("/booking/cancel")
public class BookingCancelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles POST requests - process cancellation form
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
            // Get booking ID
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
                session.setAttribute("errorMessage", "You don't have permission to cancel this booking");
                response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
                return;
            }

            // Check if booking can be cancelled
            if (booking.getStatus() == Booking.BookingStatus.COMPLETED ||
                    booking.getStatus() == Booking.BookingStatus.CANCELLED) {
                session.setAttribute("errorMessage", "Cannot cancel a " + booking.getStatus() + " booking");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);
                return;
            }

            // Get cancellation reason
            String cancellationReason = request.getParameter("cancellationReason");
            String confirmedCancel = request.getParameter("confirmedCancel");

            // Ensure user confirmed cancellation
            if (!"yes".equals(confirmedCancel)) {
                session.setAttribute("errorMessage", "Please confirm that you want to cancel this booking");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);
                return;
            }

            // Add cancellation reason to notes
            String updatedNotes = booking.getEventNotes();
            if (updatedNotes == null) {
                updatedNotes = "";
            }

            // Append cancellation info to notes
            String cancellationNote = "\n\n[CANCELLATION] " +
                    LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) +
                    " - Cancelled by: " + currentUser.getUsername() +
                    " - Reason: " + (ValidationUtil.isNullOrEmpty(cancellationReason) ? "Not provided" : cancellationReason);

            booking.setEventNotes(updatedNotes + cancellationNote);

            // Update notes first
            bookingManager.updateBooking(booking);

            // Then cancel the booking
            if (bookingManager.cancelBooking(booking.getBookingId())) {
                session.setAttribute("successMessage", "Booking cancelled successfully");

                // Record in logs for audit trail
                System.out.println("Booking " + bookingId + " cancelled by " + currentUser.getUsername() +
                        " at " + LocalDateTime.now() +
                        " - Reason: " + (ValidationUtil.isNullOrEmpty(cancellationReason) ? "Not provided" : cancellationReason));

                response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
            } else {
                session.setAttribute("errorMessage", "Failed to cancel booking");
                response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);
            }

        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
        }
    }

    /**
     * Handles GET requests - display cancellation confirmation page
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

        // Get booking ID
        String bookingId = request.getParameter("id");
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
            session.setAttribute("errorMessage", "You don't have permission to cancel this booking");
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
            return;
        }

        // Check if booking can be cancelled
        if (booking.getStatus() == Booking.BookingStatus.COMPLETED ||
                booking.getStatus() == Booking.BookingStatus.CANCELLED) {
            session.setAttribute("errorMessage", "Cannot cancel a " + booking.getStatus() + " booking");
            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);
            return;
        }

        // Set booking as request attribute
        request.setAttribute("booking", booking);

        // Forward to cancellation confirmation page
        request.getRequestDispatcher("/booking/cancel_booking.jsp").forward(request, response);
    }
}