package com.photobooking.servlet.booking;

import java.io.IOException;
import java.time.LocalDateTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.photobooking.model.booking.*;
import com.photobooking.model.user.User;

@WebServlet("/booking/modify")
public class BookingModifyServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }
        String bookingId = request.getParameter("id");
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/booking/list");
            return;
        }
        BookingManager bookingManager = new BookingManager();
        Booking booking = bookingManager.getBookingById(bookingId);
        if (booking == null) {
            session.setAttribute("errorMessage", "Booking not found");
            response.sendRedirect(request.getContextPath() + "/booking/list");
            return;
        }
        // Set event types and statuses for dropdowns
        request.setAttribute("booking", booking);
        request.setAttribute("eventTypes", Booking.BookingType.values());
        request.setAttribute("statuses", Booking.BookingStatus.values());
        request.getRequestDispatcher("/booking/modify_booking.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }
        String bookingId = request.getParameter("bookingId");
        BookingManager bookingManager = new BookingManager();
        Booking booking = bookingManager.getBookingById(bookingId);
        if (booking == null) {
            session.setAttribute("errorMessage", "Booking not found");
            response.sendRedirect(request.getContextPath() + "/booking/list");
            return;
        }
        try {
            // Parse and update fields
            booking.setEventLocation(request.getParameter("eventLocation"));
            booking.setEventNotes(request.getParameter("eventNotes"));
            booking.setEventType(Booking.BookingType.valueOf(request.getParameter("eventType")));
            booking.setStatus(Booking.BookingStatus.valueOf(request.getParameter("status")));
            booking.setEventDateTime(LocalDateTime.parse(request.getParameter("eventDateTime")));
            // Save update
            if (bookingManager.updateBooking(booking)) {
                session.setAttribute("successMessage", "Booking updated successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to update booking");
            }
            response.sendRedirect(request.getContextPath() + "/booking/details?id=" + bookingId);
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Invalid input: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/modify?id=" + bookingId);
        }
    }
}