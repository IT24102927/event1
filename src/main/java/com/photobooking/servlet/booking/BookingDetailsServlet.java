package com.photobooking.servlet.booking;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.user.User;
import com.photobooking.model.user.UserManager;

@WebServlet("/booking/details")
public class BookingDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Get booking ID from request
        String bookingId = request.getParameter("id");
        if (bookingId == null || bookingId.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Invalid booking ID");
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
            return;
        }

        // Get current user
        User currentUser = (User) session.getAttribute("user");

        // Fetch booking details
        BookingManager bookingManager = new BookingManager();
        Booking booking = bookingManager.getBookingById(bookingId);

        if (booking == null) {
            session.setAttribute("errorMessage", "Booking not found");
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
            return;
        }

        // Verify user access (client can see their bookings, photographer can see their assignments)
        if (!booking.getClientId().equals(currentUser.getUserId()) &&
                !booking.getPhotographerId().equals(currentUser.getUserId()) &&
                currentUser.getUserType() != User.UserType.ADMIN) {
            session.setAttribute("errorMessage", "You do not have permission to view this booking");
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
            return;
        }

        // Fetch additional details for the booking
        UserManager userManager = new UserManager(getServletContext());
        User client = userManager.getUserById(booking.getClientId());
        User photographer = userManager.getUserById(booking.getPhotographerId());

        // Set attributes for the view
        request.setAttribute("booking", booking);
        request.setAttribute("client", client);
        request.setAttribute("photographer", photographer);

        // Forward to booking details page
        request.getRequestDispatcher("/booking/booking_details.jsp").forward(request, response);
    }

    // Optional: Add doPost method for updating booking status
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Get current user
        User currentUser = (User) session.getAttribute("user");

        // Get booking ID and new status
        String bookingId = request.getParameter("bookingId");
        String statusStr = request.getParameter("status");

        try {
            Booking.BookingStatus newStatus = Booking.BookingStatus.valueOf(statusStr);
            BookingManager bookingManager = new BookingManager();
            Booking booking = bookingManager.getBookingById(bookingId);

            // Verify user can update status
            if (booking == null ||
                    (!booking.getPhotographerId().equals(currentUser.getUserId()) &&
                            currentUser.getUserType() != User.UserType.ADMIN)) {
                session.setAttribute("errorMessage", "You cannot update this booking");
                response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
                return;
            }

            // Update booking status
            if (bookingManager.updateBookingStatus(bookingId, newStatus)) {
                session.setAttribute("successMessage", "Booking status updated successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to update booking status");
            }

            response.sendRedirect(request.getContextPath() + "/booking/booking_details.jsp?id=" + bookingId);

        } catch (IllegalArgumentException e) {
            session.setAttribute("errorMessage", "Invalid booking status");
            response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
        }
    }
}