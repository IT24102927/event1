package com.photobooking.servlet.gallery;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.booking.Booking;
import com.photobooking.model.booking.BookingManager;
import com.photobooking.model.gallery.Gallery;
import com.photobooking.model.gallery.GalleryManager;
import com.photobooking.model.user.User;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for preparing data for photo upload page
 */
@WebServlet("/gallery/upload-form")
public class UploadPhotosServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(UploadPhotosServlet.class.getName());

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
            session.setAttribute("errorMessage", "Only photographers can upload photos");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        try {
            LOGGER.info("UploadPhotosServlet: Starting to prepare upload form for user: " + currentUser.getUserId());

            // Get the photographer ID
            String photographerId = currentUser.getUserId();
            session.setAttribute("photographerId", photographerId);
            LOGGER.info("Using photographer ID: " + photographerId);

            // Get galleries for the photographer
            GalleryManager galleryManager = new GalleryManager(getServletContext());
            List<Gallery> galleries = galleryManager.getGalleriesByPhotographer(photographerId);
            LOGGER.info("Found " + galleries.size() + " galleries for photographer: " + photographerId);

            // Get bookings for the photographer
            BookingManager bookingManager = new BookingManager(getServletContext());
            List<Booking> bookings = bookingManager.getBookingsByPhotographer(photographerId);
            LOGGER.info("Found " + bookings.size() + " bookings for photographer: " + photographerId);

            // Set attributes for the JSP
            request.setAttribute("galleries", galleries);
            request.setAttribute("bookings", bookings);

            // Handle a pre-selected gallery ID if provided
            String selectedGalleryId = request.getParameter("galleryId");
            if (selectedGalleryId != null && !selectedGalleryId.isEmpty()) {
                LOGGER.info("Pre-selected gallery ID: " + selectedGalleryId);
                request.setAttribute("selectedGalleryId", selectedGalleryId);
            }

            // Forward to the upload form
            LOGGER.info("Forwarding to upload_photos.jsp");
            request.getRequestDispatcher("/gallery/upload_photos.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error preparing upload form: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "Error loading upload form: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
        }
    }
}
