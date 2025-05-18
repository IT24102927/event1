package com.photobooking.servlet.gallery;

import java.io.IOException;
import java.io.InputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.photobooking.model.gallery.Gallery;
import com.photobooking.model.gallery.GalleryManager;
import com.photobooking.model.gallery.Photo;
import com.photobooking.model.gallery.PhotoManager;
import com.photobooking.model.user.User;
import com.photobooking.util.FileHandler;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling photo uploads
 */
@WebServlet("/gallery/upload")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 20,       // 20MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class UploadPhotoServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(UploadPhotoServlet.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();
        // Initialize necessary data directories and files
        FileHandler.createDirectory("data");
        FileHandler.createDirectory("photos");
        FileHandler.createDirectory("thumbnails");
        FileHandler.ensureFileExists("galleries.txt");
        FileHandler.ensureFileExists("photos.txt");
    }

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
            session.setAttribute("errorMessage", "Only photographers can upload photos");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        // Print all request parameters for debugging
        LOGGER.info("Request parameters:");
        for (String param : request.getParameterMap().keySet()) {
            LOGGER.info(param + ": " + request.getParameter(param));
        }

        // Get parameters
        String galleryId = request.getParameter("galleryId");
        String galleryType = request.getParameter("galleryType");

        // Make sure the data directories exist
        LOGGER.info("Creating necessary directories for photo uploads");
        FileHandler.createDirectory("photos");
        FileHandler.createDirectory("thumbnails");

        // Create absolute paths for these directories
        String webAppPath = getServletContext().getRealPath("/");
        String photosPath = webAppPath + File.separator + "photos";
        String thumbnailsPath = webAppPath + File.separator + "thumbnails";

        // Create directories with absolute paths
        new File(photosPath).mkdirs();
        new File(thumbnailsPath).mkdirs();

        LOGGER.info("Photos directory path: " + photosPath);
        LOGGER.info("Thumbnails directory path: " + thumbnailsPath);

        // Validate gallery ID for existing gallery
        if ("existing".equals(galleryType) && (galleryId == null || galleryId.trim().isEmpty())) {
            session.setAttribute("errorMessage", "Gallery ID is required when selecting an existing gallery");
            response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
            return;
        }

        try {
            GalleryManager galleryManager = new GalleryManager(getServletContext());
            PhotoManager photoManager = new PhotoManager(getServletContext());

            // Get photographer ID - directly use user ID
            String photographerId = currentUser.getUserId();
            LOGGER.info("Using photographerId: " + photographerId + " for uploads");

            // Create a new gallery if requested
            if ("new".equals(galleryType)) {
                String galleryTitle = ValidationUtil.cleanInput(request.getParameter("galleryTitle"));
                String galleryDescription = ValidationUtil.cleanInput(request.getParameter("galleryDescription"));
                String galleryCategory = request.getParameter("galleryCategory");
                String galleryBooking = request.getParameter("galleryBooking");
                String galleryPublicStr = request.getParameter("galleryPublic");
                boolean galleryPublic = "on".equals(galleryPublicStr) || "true".equals(galleryPublicStr);

                if (ValidationUtil.isNullOrEmpty(galleryTitle)) {
                    session.setAttribute("errorMessage", "Gallery title is required");
                    response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
                    return;
                }

                Gallery newGallery = new Gallery();
                newGallery.setTitle(galleryTitle);
                newGallery.setDescription(galleryDescription);
                newGallery.setCategory(galleryCategory);
                newGallery.setPhotographerId(photographerId);

                LOGGER.info("Creating new gallery with title: " + galleryTitle +
                        ", category: " + galleryCategory +
                        ", photographerId: " + photographerId);

                if (!ValidationUtil.isNullOrEmpty(galleryBooking)) {
                    newGallery.setBookingId(galleryBooking);
                }

                newGallery.setStatus(galleryPublic ?
                        Gallery.GalleryStatus.PUBLISHED : Gallery.GalleryStatus.DRAFT);

                boolean created = galleryManager.createGallery(newGallery);
                if (!created) {
                    session.setAttribute("errorMessage", "Failed to create gallery");
                    response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
                    return;
                }

                galleryId = newGallery.getGalleryId();
                LOGGER.info("New gallery created with ID: " + galleryId);
            } else {
                // Verify gallery exists and belongs to the photographer
                Gallery gallery = galleryManager.getGalleryById(galleryId);

                if (gallery == null) {
                    session.setAttribute("errorMessage", "Gallery not found");
                    response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
                    return;
                }

                if (!gallery.getPhotographerId().equals(photographerId)) {
                    LOGGER.warning("Gallery photographer ID (" + gallery.getPhotographerId() +
                            ") doesn't match current user ID (" + photographerId + ")");
                    session.setAttribute("errorMessage", "You don't have permission to upload photos to this gallery");
                    response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
                    return;
                }
            }

            // Process photo uploads
            LOGGER.info("Looking for photo parts in the request...");
            List<Part> fileParts = new ArrayList<>();
            for (Part part : request.getParts()) {
                LOGGER.info("Found part: " + part.getName() + " with size: " + part.getSize());
                // Key change: Look for any part name that contains "photos"
                if (part.getName().contains("photos") && part.getSize() > 0) {
                    fileParts.add(part);
                    LOGGER.info("Found photo part: " + getFileName(part) + ", size: " + part.getSize());
                }
            }

            if (fileParts.isEmpty()) {
                LOGGER.warning("No photo parts found in the request");
                session.setAttribute("errorMessage", "No files uploaded");
                response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
                return;
            }

            // Auto-optimize images if requested
            boolean autoProcess = "on".equals(request.getParameter("autoProcess")) ||
                    "true".equals(request.getParameter("autoProcess"));

            // Upload each photo
            int successCount = 0;
            for (Part filePart : fileParts) {
                String originalFileName = getFileName(filePart);
                if (originalFileName == null || originalFileName.trim().isEmpty()) {
                    continue;
                }

                LOGGER.info("Processing upload: " + originalFileName);

                // Create photo object
                Photo photo = new Photo();
                photo.setGalleryId(galleryId);
                photo.setPhotographerId(photographerId);
                photo.setOriginalFileName(originalFileName);
                photo.setContentType(filePart.getContentType());

                // Read file data
                byte[] fileData;
                try (InputStream inputStream = filePart.getInputStream()) {
                    fileData = new byte[(int) filePart.getSize()];
                    inputStream.read(fileData);
                    LOGGER.info("Read " + fileData.length + " bytes for " + originalFileName);
                }

                // Manual saving of file for testing
                String testFilePath = photosPath + File.separator + System.currentTimeMillis() + "_" + originalFileName;
                try (FileOutputStream fos = new FileOutputStream(testFilePath)) {
                    fos.write(fileData);
                    LOGGER.info("Test file saved to: " + testFilePath);
                } catch (Exception e) {
                    LOGGER.log(Level.SEVERE, "Error saving test file: " + e.getMessage(), e);
                }

                // Upload photo
                boolean uploaded = photoManager.createPhoto(photo, fileData);

                if (uploaded) {
                    // Add to gallery
                    boolean addedToGallery = galleryManager.addPhotoToGallery(galleryId, photo.getPhotoId());
                    LOGGER.info("Photo " + photo.getPhotoId() + " uploaded and " +
                            (addedToGallery ? "added to gallery" : "FAILED to add to gallery"));

                    if (addedToGallery) {
                        successCount++;
                    }
                } else {
                    LOGGER.warning("Failed to upload photo: " + originalFileName);
                }
            }

            // Set success message and redirect
            if (successCount > 0) {
                session.setAttribute("successMessage", successCount + " photo(s) uploaded successfully");

                // Update gallery's last updated date
                Gallery gallery = galleryManager.getGalleryById(galleryId);
                if (gallery != null) {
                    gallery.setLastUpdatedDate(LocalDateTime.now());
                    galleryManager.updateGallery(gallery);
                }

                response.sendRedirect(request.getContextPath() + "/gallery/details?id=" + galleryId);
            } else {
                session.setAttribute("errorMessage", "Failed to upload photos");
                response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error uploading photos: " + e.getMessage(), e);
            e.printStackTrace();
            session.setAttribute("errorMessage", "An error occurred during upload: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/gallery/upload-form");
        }
    }

    /**
     * Extracts file name from HTTP header content-disposition
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");

        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        return "";
    }
}
