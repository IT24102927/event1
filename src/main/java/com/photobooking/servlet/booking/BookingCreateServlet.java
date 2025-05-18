package com.photobooking.servlet.booking;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.booking.BookingQueueManager;
import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.model.photographer.PhotographerService;
import com.photobooking.model.photographer.PhotographerServiceManager;
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for creating new bookings in the Event Photography System
 * Maps to both /booking/create and /booking/create-booking for compatibility
 * Modified to use the queue system for booking management
 */
@WebServlet(urlPatterns = {"/booking/create", "/booking/create-booking"})
public class BookingCreateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Forward to booking form page with the same parameters
        String photographerId = request.getParameter("photographerId");
        String serviceId = request.getParameter("serviceId");

        StringBuilder redirectURL = new StringBuilder(request.getContextPath() + "/booking/booking_form.jsp");
        boolean hasParams = false;

        if (photographerId != null && !photographerId.isEmpty()) {
            redirectURL.append("?photographerId=").append(photographerId);
            hasParams = true;
        }

        if (serviceId != null && !serviceId.isEmpty()) {
            redirectURL.append(hasParams ? "&" : "?").append("serviceId=").append(serviceId);
        }

        response.sendRedirect(redirectURL.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        try {
            // Get form parameters
            String photographerId = ValidationUtil.cleanInput(request.getParameter("photographerId"));
            String serviceId = ValidationUtil.cleanInput(request.getParameter("serviceId"));
            String eventDateStr = ValidationUtil.cleanInput(request.getParameter("eventDate"));
            String eventTimeStr = ValidationUtil.cleanInput(request.getParameter("eventTime"));
            String eventLocation = ValidationUtil.cleanInput(request.getParameter("eventLocation"));
            String eventTypeStr = ValidationUtil.cleanInput(request.getParameter("eventType"));
            String eventNotes = ValidationUtil.cleanInput(request.getParameter("eventNotes"));

            // Validate required fields
            if (ValidationUtil.isNullOrEmpty(photographerId) ||
                    ValidationUtil.isNullOrEmpty(serviceId) ||
                    ValidationUtil.isNullOrEmpty(eventDateStr) ||
                    ValidationUtil.isNullOrEmpty(eventTimeStr) ||
                    ValidationUtil.isNullOrEmpty(eventLocation) ||
                    ValidationUtil.isNullOrEmpty(eventTypeStr)) {

                session.setAttribute("errorMessage", "All required booking details must be provided");
                response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp");
                return;
            }

            // Parse date and time
            LocalDate eventDate = LocalDate.parse(eventDateStr);
            LocalTime eventTime = LocalTime.parse(eventTimeStr);
            LocalDateTime eventDateTime = LocalDateTime.of(eventDate, eventTime);

            // Parse event type
            Booking.BookingType eventType;
            try {
                eventType = Booking.BookingType.valueOf(eventTypeStr);
            } catch (IllegalArgumentException e) {
                session.setAttribute("errorMessage", "Invalid event type");
                response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp");
                return;
            }

            // Verify photographer exists
            PhotographerManager photographerManager = new PhotographerManager(getServletContext());
            Photographer photographer = photographerManager.getPhotographerById(photographerId);
            if (photographer == null) {
                session.setAttribute("errorMessage", "Selected photographer does not exist");
                response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp");
                return;
            }

            // Verify service exists and belongs to the photographer
            PhotographerServiceManager serviceManager = new PhotographerServiceManager(getServletContext());
            PhotographerService service = serviceManager.getServiceById(serviceId);
            if (service == null || !service.getPhotographerId().equals(photographerId)) {
                session.setAttribute("errorMessage", "Invalid service selected");
                response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp");
                return;
            }

            // Check if photographer is available
            BookingManager bookingManager = new BookingManager(getServletContext());
            boolean isAvailable = bookingManager.isPhotographerAvailable(
                    photographer.getUserId(), eventDateTime, service.getDurationHours());

            if (!isAvailable) {
                session.setAttribute("errorMessage",
                        "The photographer is not available at the selected date and time");
                response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp?photographerId="
                        + photographerId + "&serviceId=" + serviceId);
                return;
            }

            // Create new booking
            Booking booking = new Booking();
            booking.setClientId(currentUser.getUserId());
            booking.setPhotographerId(photographer.getUserId());
            booking.setServiceId(serviceId);
            booking.setEventDateTime(eventDateTime);
            booking.setEventLocation(eventLocation);
            booking.setEventType(eventType);
            booking.setEventNotes(eventNotes);
            booking.setTotalPrice(service.getPrice());
            booking.setBookingDateTime(LocalDateTime.now());
            booking.setStatus(Booking.BookingStatus.PENDING);

            // Use the booking queue instead of direct creation
            BookingQueueManager queueManager = BookingQueueManager.getInstance(getServletContext());
            boolean queued = queueManager.queueBooking(booking);

            if (queued) {
                // Increment service booking count
                service.incrementBookingCount();
                serviceManager.updateService(service);

                // Set success message
                session.setAttribute("successMessage",
                        "Your booking has been queued and is awaiting approval from the photographer!");

                // Redirect to the queue page to show pending booking
                response.sendRedirect(request.getContextPath() + "/booking/queue");
            } else {
                session.setAttribute("errorMessage", "Failed to queue booking. Please try again.");
                response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp?photographerId="
                        + photographerId + "&serviceId=" + serviceId);
            }

        } catch (Exception e) {
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/booking/booking_form.jsp");
        }
    }
}