package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.user.User;
import com.photobooking.model.photographer.UnavailableDateManager;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

/**
 * Servlet for removing blocked/unavailable dates from the photographer's calendar
 */
@WebServlet("/photographer/remove-blocked-date")
public class RemoveUnavailableDateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        // Check if user is logged in and is a photographer
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Not logged in");
            out.print(gson.toJson(errorResponse));
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Access denied");
            out.print(gson.toJson(errorResponse));
            return;
        }

        // Get dateId from request
        String dateId = request.getParameter("dateId");

        // Debug log
        System.out.println("RemoveUnavailableDateServlet - Received dateId: " + dateId);

        if (dateId == null || dateId.trim().isEmpty()) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Date ID is required");
            out.print(gson.toJson(errorResponse));
            return;
        }

        try {
            UnavailableDateManager unavailableDateManager = new UnavailableDateManager();
            boolean removed = unavailableDateManager.removeUnavailableDate(dateId);

            // Prepare JSON response
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", removed);
            if (!removed) {
                jsonResponse.addProperty("message", "Failed to remove unavailable date");
            } else {
                jsonResponse.addProperty("message", "Date removed successfully");
            }

            out.print(gson.toJson(jsonResponse));

        } catch (Exception e) {
            // Log the error
            e.printStackTrace();

            // Return error response
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("success", false);
            errorResponse.addProperty("message", "Error removing unavailable date: " + e.getMessage());
            out.print(gson.toJson(errorResponse));
        }
    }
}