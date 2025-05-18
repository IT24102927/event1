package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.user.User;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

/**
 * AJAX endpoint for getting photographer availability for a specific date
 */
@WebServlet("/photographer/get-availability")
public class GetAvailabilityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a photographer
        if (session == null || session.getAttribute("user") == null) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("message", "Not logged in");
            out.print(gson.toJson(error));
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("message", "Access denied");
            out.print(gson.toJson(error));
            return;
        }

        String dateStr = request.getParameter("date");
        if (dateStr == null) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("message", "Date parameter is required");
            out.print(gson.toJson(error));
            return;
        }

        try {
            LocalDate date = LocalDate.parse(dateStr);
            String photographerId = currentUser.getUserId();

            // Standard time slots
            List<String> timeSlots = new ArrayList<>();
            timeSlots.add("09:00");
            timeSlots.add("10:00");
            timeSlots.add("11:00");
            timeSlots.add("12:00");
            timeSlots.add("13:00");
            timeSlots.add("14:00");
            timeSlots.add("15:00");
            timeSlots.add("16:00");
            timeSlots.add("17:00");
            timeSlots.add("18:00");
            timeSlots.add("19:00");
            timeSlots.add("20:00");

            // Check which time slots are available
            BookingManager bookingManager = new BookingManager();
            List<String> availableTimeSlots = new ArrayList<>();

            for (String timeSlot : timeSlots) {
                LocalTime time = LocalTime.parse(timeSlot);
                LocalDateTime dateTime = LocalDateTime.of(date, time);

                if (bookingManager.isPhotographerAvailable(photographerId, dateTime, 1)) {
                    availableTimeSlots.add(timeSlot);
                }
            }

            JsonObject jsonResponse = new JsonObject(); // Changed variable name to avoid conflict
            jsonResponse.addProperty("success", true);
            jsonResponse.add("availableTimeSlots", gson.toJsonTree(availableTimeSlots));

            out.print(gson.toJson(jsonResponse));
        } catch (Exception e) {
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("message", "Error processing request: " + e.getMessage());
            out.print(gson.toJson(error));
        }
    }
}