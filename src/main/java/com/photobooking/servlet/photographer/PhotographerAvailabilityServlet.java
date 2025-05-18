package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.user.User;
import com.photobooking.model.photographer.UnavailableDate;
import com.photobooking.model.photographer.UnavailableDateManager;

/**
 * Servlet for handling photographer availability calendar
 */
@WebServlet("/photographer/availability")
public class PhotographerAvailabilityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a photographer
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            session.setAttribute("errorMessage", "Access denied");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        String photographerId = currentUser.getUserId();

        // For debugging
        System.out.println("Loading calendar for photographer ID: " + photographerId);

        try {
            // Get all bookings (both upcoming and past) for the photographer
            BookingManager bookingManager = new BookingManager(getServletContext());
            List<Booking> allBookings = bookingManager.getBookingsByPhotographer(photographerId);
            List<Booking> upcomingBookings = bookingManager.getUpcomingBookings(photographerId, true);

            // Log bookings for debugging
            System.out.println("Found " + allBookings.size() + " total bookings");
            System.out.println("Found " + upcomingBookings.size() + " upcoming bookings");

            // Get unavailable dates for photographer
            UnavailableDateManager unavailableDateManager = new UnavailableDateManager();
            List<UnavailableDate> unavailableDates = unavailableDateManager.getUnavailableDatesForPhotographer(photographerId);
            System.out.println("Found " + unavailableDates.size() + " unavailable dates");

            // Convert bookings and unavailable dates to calendar events
            JsonArray calendarEvents = new JsonArray();

            // Add booked events
            for (Booking booking : allBookings) {
                try {
                    JsonObject event = new JsonObject();
                    event.addProperty("id", "booking-" + booking.getBookingId());
                    event.addProperty("title", getBookingTypeDisplayName(booking.getEventType()));

                    // Make sure we have a valid date
                    if (booking.getEventDateTime() != null) {
                        event.addProperty("start", booking.getEventDateTime().toString());

                        // Calculate end time (assume 3 hours for simplicity, adjust as needed)
                        LocalDateTime endTime = booking.getEventDateTime().plusHours(3);
                        event.addProperty("end", endTime.toString());
                    } else {
                        System.out.println("Warning: Booking " + booking.getBookingId() + " has null eventDateTime");
                        continue; // Skip this booking
                    }

                    // Set color based on booking status
                    String backgroundColor = getBookingStatusColor(booking.getStatus());
                    event.addProperty("backgroundColor", backgroundColor);
                    event.addProperty("borderColor", backgroundColor);

                    // Add more details
                    event.addProperty("description", "Location: " + booking.getEventLocation());
                    event.addProperty("status", booking.getStatus().toString());

                    calendarEvents.add(event);
                } catch (Exception e) {
                    System.out.println("Error processing booking: " + e.getMessage());
                }
            }

            // Add unavailable dates
            for (UnavailableDate date : unavailableDates) {
                try {
                    JsonObject event = new JsonObject();
                    event.addProperty("id", "unavailable-" + date.getId());
                    event.addProperty("title", date.getReason() != null ? date.getReason() : "Unavailable");

                    // Format as full day event if allDay is true
                    if (date.isAllDay()) {
                        event.addProperty("start", date.getDate().toString());
                        event.addProperty("allDay", true);
                    } else {
                        // Format as time slot if not all day
                        String startDateTime = date.getDate().toString() + "T" + date.getStartTime() + ":00";
                        String endDateTime = date.getDate().toString() + "T" + date.getEndTime() + ":00";
                        event.addProperty("start", startDateTime);
                        event.addProperty("end", endDateTime);
                        event.addProperty("allDay", false);
                    }

                    // Red color for unavailable dates
                    event.addProperty("backgroundColor", "#dc3545");
                    event.addProperty("borderColor", "#dc3545");

                    calendarEvents.add(event);
                } catch (Exception e) {
                    System.out.println("Error processing unavailable date: " + e.getMessage());
                }
            }

            // Set attributes for JSP
            request.setAttribute("upcomingBookings", upcomingBookings);
            request.setAttribute("unavailableDates", unavailableDates);
            request.setAttribute("calendarEventsJson", new Gson().toJson(calendarEvents));

            // Debug log
            System.out.println("Calendar events prepared: " + calendarEvents.size() + " events");
            System.out.println("Calendar JSON: " + new Gson().toJson(calendarEvents));

            request.getRequestDispatcher("/photographer/availability_calendar.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error loading calendar: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
        }
    }

    /**
     * Get booking type display name
     */
    private String getBookingTypeDisplayName(Booking.BookingType type) {
        if (type == null) return "Photography Session";

        switch (type) {
            case WEDDING:
                return "Wedding Photography";
            case CORPORATE:
                return "Corporate Event";
            case PORTRAIT:
                return "Portrait Session";
            case EVENT:
                return "Event Photography";
            case FAMILY:
                return "Family Photography";
            case PRODUCT:
                return "Product Photography";
            default:
                return "Photography Session";
        }
    }

    /**
     * Get booking status color
     */
    private String getBookingStatusColor(Booking.BookingStatus status) {
        if (status == null) return "#6c757d";  // Gray

        switch (status) {
            case CONFIRMED:
                return "#28a745";  // Green
            case PENDING:
                return "#ffc107";  // Yellow
            case CANCELLED:
                return "#dc3545";  // Red
            case COMPLETED:
                return "#007bff";  // Blue
            default:
                return "#6c757d";  // Gray
        }
    }
}