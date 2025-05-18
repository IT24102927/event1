package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.photographer.UnavailableDate;
import com.photobooking.model.photographer.UnavailableDateManager;
import com.photobooking.model.user.User;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonParser;

/**
 * Servlet for saving photographer's availability (blocked time slots)
 */
@WebServlet("/photographer/save-availability")
public class SaveAvailabilityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Create Gson for JSON parsing/serialization
        Gson gson = new Gson();

        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "User not logged in");
            out.print(gson.toJson(errorResponse));
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Only photographers can update availability");
            out.print(gson.toJson(errorResponse));
            return;
        }

        try {
            // Read JSON input
            StringBuilder jsonBuffer = new StringBuilder();
            String line;
            try (java.io.BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    jsonBuffer.append(line);
                }
            }

            String jsonInput = jsonBuffer.toString();
            System.out.println("SaveAvailabilityServlet - Received JSON: " + jsonInput);

            // Parse JSON input
            JsonObject jsonObj = JsonParser.parseString(jsonInput).getAsJsonObject();
            String dateStr = jsonObj.get("date").getAsString();
            JsonArray unavailableTimeSlotsJson = jsonObj.getAsJsonArray("unavailableTimeSlots");

            // Debug log
            System.out.println("SaveAvailabilityServlet - Parsed parameters:");
            System.out.println("date: " + dateStr);
            System.out.println("unavailableTimeSlots: " + unavailableTimeSlotsJson);

            // Convert to Java objects
            LocalDate date = LocalDate.parse(dateStr);
            List<String> unavailableTimeSlots = new ArrayList<>();
            for (int i = 0; i < unavailableTimeSlotsJson.size(); i++) {
                unavailableTimeSlots.add(unavailableTimeSlotsJson.get(i).getAsString());
            }

            String photographerId = currentUser.getUserId();
            UnavailableDateManager unavailableDateManager = new UnavailableDateManager();

            // If all time slots (12) are blocked, create an all-day unavailable date
            if (unavailableTimeSlots.size() == 12) {
                UnavailableDate allDayUnavailable = new UnavailableDate(
                        photographerId,
                        date,
                        true,
                        "Blocked entire day"
                );
                unavailableDateManager.addUnavailableDate(allDayUnavailable);
            } else {
                // Block individual time slots
                for (String timeSlot : unavailableTimeSlots) {
                    // Calculate end time (1 hour after start time)
                    String[] timeParts = timeSlot.split(":");
                    int hour = Integer.parseInt(timeParts[0]);
                    String endTime = String.format("%02d:00", (hour + 1) % 24);

                    UnavailableDate partialUnavailable = new UnavailableDate(
                            photographerId,
                            date,
                            false,
                            "Blocked time slot"
                    );
                    partialUnavailable.setStartTime(timeSlot);
                    partialUnavailable.setEndTime(endTime);
                    unavailableDateManager.addUnavailableDate(partialUnavailable);
                }
            }

            // Prepare JSON response
            JsonObject successResponse = new JsonObject();
            successResponse.addProperty("success", true);
            successResponse.addProperty("message", "Availability updated successfully");

            out.print(gson.toJson(successResponse));

        } catch (Exception e) {
            // Handle any unexpected errors
            e.printStackTrace();
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Error saving availability: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
    }
}