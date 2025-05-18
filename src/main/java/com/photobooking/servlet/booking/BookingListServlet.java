package com.photobooking.servlet.booking;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.user.User;

@WebServlet("/booking/list")
public class BookingListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        BookingManager bookingManager = new BookingManager();
        List<Booking> bookings;

        // Get bookings based on user type
        if (user.getUserType() == User.UserType.CLIENT) {
            bookings = bookingManager.getBookingsByClient(user.getUserId());
        } else if (user.getUserType() == User.UserType.PHOTOGRAPHER) {
            bookings = bookingManager.getBookingsByPhotographer(user.getUserId());
        } else {
            // For admin, get all bookings (you might want to implement a different method)
            bookings = null;
        }

        // Set bookings as attribute
        request.setAttribute("bookings", bookings);

        // Forward to booking list page
        request.getRequestDispatcher("/booking/booking_list.jsp").forward(request, response);
    }
}