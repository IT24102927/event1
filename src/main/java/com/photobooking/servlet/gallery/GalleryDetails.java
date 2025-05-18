// GalleryDetailsServlet.java
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

import com.photobooking.model.gallery.Gallery;
import com.photobooking.model.gallery.GalleryManager;
import com.photobooking.model.gallery.Photo;
import com.photobooking.model.gallery.PhotoManager;
import com.photobooking.model.user.User;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for displaying gallery details
 */
@WebServlet("/gallery/details")
public class GalleryDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(GalleryDetailsServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String galleryId = request.getParameter("id");

        // Redirect if no gallery ID provided
        if (galleryId == null || galleryId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/gallery/list");
            return;
        }

        try {
            GalleryManager galleryManager = new GalleryManager(getServletContext());
            Gallery gallery = galleryManager.getGalleryById(galleryId);

            // Gallery not found
            if (gallery == null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("errorMessage", "Gallery not found");
                response.sendRedirect(request.getContextPath() + "/gallery/list");
                return;
            }

            // Check gallery visibility
            HttpSession session = request.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

            boolean canView = gallery.getStatus() == Gallery.GalleryStatus.PUBLISHED ||
                    (currentUser != null && (
                            // Photographer who owns the gallery
                            (currentUser.getUserType() == User.UserType.PHOTOGRAPHER &&
                                    currentUser.getUserId().equals(gallery.getPhotographerId())) ||
                                    // Client who the gallery is shared with
                                    (currentUser.getUserType() == User.UserType.CLIENT &&
                                            currentUser.getUserId().equals(gallery.getClientId()))
                    ));

            if (!canView) {
                session.setAttribute("errorMessage", "You don't have permission to view this gallery");
                response.sendRedirect(request.getContextPath() + "/gallery/list");
                return;
            }

            // Get photos
            PhotoManager photoManager = new PhotoManager(getServletContext());
            List<Photo> photos = new ArrayList<>();

            for (String photoId : gallery.getPhotoIds()) {
                Photo photo = photoManager.getPhotoById(photoId);
                if (photo != null) {
                    photos.add(photo);
                }
            }

            // Set attributes for JSP
            request.setAttribute("gallery", gallery);
            request.setAttribute("photos", photos);

            // Check if current user is the photographer
            boolean isOwner = currentUser != null &&
                    currentUser.getUserType() == User.UserType.PHOTOGRAPHER &&
                    currentUser.getUserId().equals(gallery.getPhotographerId());
            request.setAttribute("isOwner", isOwner);

            // Forward to JSP
            request.getRequestDispatcher("/gallery/gallery_details.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error displaying gallery details: " + e.getMessage(), e);
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/gallery/list");
        }
    }
}