// DeleteGalleryServlet.java
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
import com.photobooking.model.gallery.PhotoManager;
import com.photobooking.model.user.User;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for deleting galleries
 */
@WebServlet("/gallery/delete")
public class DeleteGalleryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DeleteGalleryServlet.class.getName());

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
            session.setAttribute("errorMessage", "Only photographers can delete galleries");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        // Get gallery ID from request
        String galleryId = request.getParameter("galleryId");
        if (galleryId == null || galleryId.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Gallery ID is required");
            response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
            return;
        }

        try {
            // Verify gallery ownership
            GalleryManager galleryManager = new GalleryManager(getServletContext());
            Gallery gallery = galleryManager.getGalleryById(galleryId);

            if (gallery == null) {
                session.setAttribute("errorMessage", "Gallery not found");
                response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
                return;
            }

            if (!gallery.getPhotographerId().equals(currentUser.getUserId())) {
                session.setAttribute("errorMessage", "You don't have permission to delete this gallery");
                response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
                return;
            }

            // Delete all photos in the gallery
            PhotoManager photoManager = new PhotoManager(getServletContext());
            photoManager.deleteGalleryPhotos(galleryId);

            // Delete gallery
            boolean success = galleryManager.deleteGallery(galleryId);

            if (success) {
                session.setAttribute("successMessage", "Gallery deleted successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to delete gallery");
            }

            response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting gallery: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
        }
    }
}
