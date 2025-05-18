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

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import com.photobooking.model.user.User;
import com.photobooking.model.photographer.UnavailableDate;
import com.photobooking.model.photographer.UnavailableDateManager;

/**
 * Servlet for handling blocking dates in photographer's calendar
 */
@WebServlet("/photographer/block-dates")
public class BlockDatesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
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
            errorResponse.addProperty("message", "Only photographers can block dates");
            out.print(gson.toJson(errorResponse));
            return;
        }

        try {
            // Get parameters
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String reason = request.getParameter("reason");
            boolean allDay = request.getParameter("allDay") != null;

            // Debug log
            System.out.println("BlockDatesServlet - Received parameters:");
            System.out.println("startDate: " + startDateStr);
            System.out.println("endDate: " + endDateStr);
            System.out.println("reason: " + reason);
            System.out.println("allDay: " + allDay);

            // Validate start date
            if (startDateStr == null || startDateStr.isEmpty()) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("success", false);
                errorResponse.addProperty("message", "Start date is required");
                out.print(gson.toJson(errorResponse));
                return;
            }

            // Parse dates
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = startDate;

            // Use end date if provided
            if (endDateStr != null && !endDateStr.isEmpty()) {
                endDate = LocalDate.parse(endDateStr);

                // Ensure end date is not before start date
                if (endDate.isBefore(startDate)) {
                    JsonObject errorResponse = new JsonObject();
                    errorResponse.addProperty("success", false);
                    errorResponse.addProperty("message", "End date cannot be before start date");
                    out.print(gson.toJson(errorResponse));
                    return;
                }
            }

            // Get photographer ID
            String photographerId = currentUser.getUserId();

            // Prepare manager and blocked dates list
            UnavailableDateManager unavailableDateManager = new UnavailableDateManager();
            JsonArray blockedDatesJson = new JsonArray();
            List<UnavailableDate> blockedDates = new ArrayList<>();

            // Block each date in the range
            for (LocalDate currentDate = startDate;
                 !currentDate.isAfter(endDate);
                 currentDate = currentDate.plusDays(1)) {

                // Create unavailable date object
                UnavailableDate unavailableDate = new UnavailableDate(
                        photographerId,
                        currentDate,
                        allDay,
                        reason != null && !reason.trim().isEmpty() ? reason : "Unavailable"
                );

                // Add to database
                if (unavailableDateManager.addUnavailableDate(unavailableDate)) {
                    blockedDates.add(unavailableDate);

                    // Prepare JSON for response
                    JsonObject dateObj = new JsonObject();
                    dateObj.addProperty("id", unavailableDate.getId());
                    dateObj.addProperty("date", currentDate.toString());
                    dateObj.addProperty("allDay", allDay);
                    dateObj.addProperty("reason", unavailableDate.getReason());

                    blockedDatesJson.add(dateObj);
                }
            }

            // Prepare success response
            JsonObject successResponse = new JsonObject();
            successResponse.addProperty("success", true);
            successResponse.addProperty("message", "Dates blocked successfully");
            successResponse.add("blockedDates", blockedDatesJson);

            // Send response
            out.print(gson.toJson(successResponse));

        } catch (Exception e) {
            // Handle any unexpected errors
            e.printStackTrace();
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Error blocking dates: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
    }
}