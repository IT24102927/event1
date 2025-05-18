package com.photobooking.servlet.photographer;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.user.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/photographer/get-availability")
public class GetAvailabilityServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(GetAvailabilityServlet.class.getName());
    private static final long serialVersionUID = 1L;

    @Override
    public void init() throws ServletException {
        // Initialize BookingManager and store in ServletContext
        BookingManager bookingManager = new BookingManager(getServletContext());
        getServletContext().setAttribute("bookingManager", bookingManager);
        LOGGER.info("BookingManager initialized in GetAvailabilityServlet");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            sendError(out, gson, "Not logged in");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            sendError(out, gson, "Access denied: User is not a photographer");
            return;
        }

        String dateStr = request.getParameter("date");
        if (dateStr == null) {
            sendError(out, gson, "Date parameter is required");
            return;
        }

        try {
            LocalDate date = LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE);
            String photographerId = currentUser.getUserId();

            // Retrieve BookingManager from ServletContext
            BookingManager bookingManager = (BookingManager) getServletContext().getAttribute("bookingManager");
            if (bookingManager == null) {
                LOGGER.severe("BookingManager not found in ServletContext");
                sendError(out, gson, "Server configuration error");
                return;
            }

            List<String> timeSlots = generateTimeSlots();
            List<String> availableTimeSlots = new ArrayList<>();

            for (String timeSlot : timeSlots) {
                LocalTime time = LocalTime.parse(timeSlot);
                LocalDateTime dateTime = LocalDateTime.of(date, time);
                if (bookingManager.isPhotographerAvailable(photographerId, dateTime, 1)) {
                    availableTimeSlots.add(timeSlot);
                }
            }

            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("date", dateStr);
            jsonResponse.add("availableTimeSlots", gson.toJsonTree(availableTimeSlots));

            out.print(gson.toJson(jsonResponse));
        } catch (java.time.format.DateTimeParseException e) {
            LOGGER.warning("Invalid date format: " + dateStr);
            sendError(out, gson, "Invalid date format. Use YYYY-MM-DD");
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, "Error processing availability request", e);
            sendError(out, gson, "Server error");
        } finally {
            out.close();
        }
    }

    private List<String> generateTimeSlots() {
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
        return timeSlots;
    }

    private void sendError(PrintWriter out, Gson gson, String message) {
        JsonObject error = new JsonObject();
        error.addProperty("success", false);
        error.addProperty("message", message);
        out.print(gson.toJson(error));
    }
}