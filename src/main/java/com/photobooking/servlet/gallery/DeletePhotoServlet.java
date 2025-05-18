// DeletePhotoServlet.java
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
import com.photobooking.model.gallery.Photo;
import com.photobooking.model.gallery.PhotoManager;
import com.photobooking.model.user.User;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for deleting photos
 */
@WebServlet("/gallery/delete-photo")
public class DeletePhotoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DeletePhotoServlet.class.getName());

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
            session.setAttribute("errorMessage", "Only photographers can delete photos");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        // Get photo ID from request
        String photoId = request.getParameter("photoId");
        if (photoId == null || photoId.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Photo ID is required");
            response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
            return;
        }

        try {
            // Get the photo to get its gallery ID
            PhotoManager photoManager = new PhotoManager(getServletContext());
            Photo photo = photoManager.getPhotoById(photoId);

            if (photo == null) {
                session.setAttribute("errorMessage", "Photo not found");
                response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
                return;
            }

            String galleryId = photo.getGalleryId();

            // Verify ownership
            GalleryManager galleryManager = new GalleryManager(getServletContext());
            Gallery gallery = galleryManager.getGalleryById(galleryId);

            if (gallery == null) {
                session.setAttribute("errorMessage", "Gallery not found");
                response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
                return;
            }

            if (!gallery.getPhotographerId().equals(currentUser.getUserId())) {
                session.setAttribute("errorMessage", "You don't have permission to delete photos from this gallery");
                response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
                return;
            }

            // Remove from gallery
            galleryManager.removePhotoFromGallery(galleryId, photoId);

            // Delete photo
            boolean success = photoManager.deletePhoto(photoId);

            if (success) {
                session.setAttribute("successMessage", "Photo deleted successfully");
            } else {
                session.setAttribute("errorMessage", "Failed to delete photo");
            }

            response.sendRedirect(request.getContextPath() + "/gallery/details?id=" + galleryId);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting photo: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/gallery/list?userOnly=true");
        }
    }
}