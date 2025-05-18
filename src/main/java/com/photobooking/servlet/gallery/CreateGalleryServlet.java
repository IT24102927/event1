
package com.photobooking.servlet.gallery;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.gallery.Gallery;
import com.photobooking.model.gallery.GalleryManager;
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for creating new galleries
 */
@WebServlet("/gallery/create")
public class CreateGalleryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(CreateGalleryServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a photographer
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            session.setAttribute("errorMessage", "Only photographers can create galleries");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        // Get form parameters
        String title = ValidationUtil.cleanInput(request.getParameter("title"));
        String description = ValidationUtil.cleanInput(request.getParameter("description"));
        String category = request.getParameter("category");
        String bookingId = request.getParameter("bookingId");
        String clientId = request.getParameter("clientId");
        String statusStr = request.getParameter("status");

        // Validate required fields
        if (ValidationUtil.isNullOrEmpty(title)) {
            session.setAttribute("errorMessage", "Gallery title is required");
            response.sendRedirect(request.getContextPath() + "/gallery/create_gallery.jsp");
            return;
        }

        try {
            // Create gallery
            Gallery gallery = new Gallery();
            gallery.setTitle(title);
            gallery.setDescription(description);
            gallery.setCategory(category);
            gallery.setPhotographerId(currentUser.getUserId());

            // Optional fields
            if (!ValidationUtil.isNullOrEmpty(bookingId)) {
                gallery.setBookingId(bookingId);
            }

            if (!ValidationUtil.isNullOrEmpty(clientId)) {
                gallery.setClientId(clientId);
            }

            // Set status
            if (!ValidationUtil.isNullOrEmpty(statusStr)) {
                try {
                    Gallery.GalleryStatus status = Gallery.GalleryStatus.valueOf(statusStr);
                    gallery.setStatus(status);
                } catch (IllegalArgumentException e) {
                    // Invalid status, keep default (DRAFT)
                    LOGGER.warning("Invalid gallery status: " + statusStr);
                }
            }

            // Save gallery
            GalleryManager galleryManager = new GalleryManager(getServletContext());
            boolean success = galleryManager.createGallery(gallery);

            if (success) {
                session.setAttribute("successMessage", "Gallery created successfully");
                response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
            } else {
                session.setAttribute("errorMessage", "Failed to create gallery");
                response.sendRedirect(request.getContextPath() + "/gallery/create_gallery.jsp");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating gallery: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/gallery/create_gallery.jsp");
        }
    }
}
