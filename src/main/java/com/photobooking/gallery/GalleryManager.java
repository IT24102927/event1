// GalleryManager.java
package com.photobooking.model.gallery;

import com.photobooking.util.FileHandler;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Logger;
import java.util.logging.Level;
import javax.servlet.ServletContext;
import java.time.LocalDateTime;

/**
 * Manages gallery-related operations for the Event Photography System
 */
public class GalleryManager {
    private static final Logger LOGGER = Logger.getLogger(GalleryManager.class.getName());
    private static final String GALLERY_FILE = "galleries.txt";
    private List<Gallery> galleries;
    private ServletContext servletContext;

    // Constructors
    public GalleryManager() {
        this(null);
    }

    public GalleryManager(ServletContext servletContext) {
        this.servletContext = servletContext;

        // If servletContext is provided, initialize FileHandler
        if (servletContext != null) {
            FileHandler.setServletContext(servletContext);
        }

        this.galleries = loadGalleries();
    }

    /**
     * Load galleries from file
     * @return List of galleries
     */
    private List<Gallery> loadGalleries() {
        // Ensure file exists
        FileHandler.ensureFileExists(GALLERY_FILE);

        List<String> lines = FileHandler.readLines(GALLERY_FILE);
        List<Gallery> loadedGalleries = new ArrayList<>();

        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                Gallery gallery = Gallery.fromFileString(line);
                if (gallery != null) {
                    loadedGalleries.add(gallery);
                }
            }
        }

        LOGGER.info("Loaded " + loadedGalleries.size() + " galleries from file");
        return loadedGalleries;
    }

    /**
     * Save all galleries to file
     * @return true if successful, false otherwise
     */
    private boolean saveGalleries() {
        try {
            // Create a backup first
            if (FileHandler.fileExists(GALLERY_FILE)) {
                FileHandler.copyFile(GALLERY_FILE, GALLERY_FILE + ".bak");
            }

            // Delete existing file content
            FileHandler.deleteFile(GALLERY_FILE);

            // Ensure file exists
            FileHandler.ensureFileExists(GALLERY_FILE);

            // Write all galleries at once
            StringBuilder contentToWrite = new StringBuilder();
            for (Gallery gallery : galleries) {
                contentToWrite.append(gallery.toFileString()).append(System.lineSeparator());
            }

            boolean result = FileHandler.writeToFile(GALLERY_FILE, contentToWrite.toString(), false);

            if (result) {
                LOGGER.info("Successfully saved " + galleries.size() + " galleries");
            } else {
                LOGGER.warning("Failed to save galleries");
                // Restore from backup
                if (FileHandler.fileExists(GALLERY_FILE + ".bak")) {
                    FileHandler.copyFile(GALLERY_FILE + ".bak", GALLERY_FILE);
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving galleries: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Create a new gallery
     * @param gallery The gallery to create
     * @return true if successful, false otherwise
     */
    public boolean createGallery(Gallery gallery) {
        // Basic validation
        if (gallery == null || gallery.getPhotographerId() == null || gallery.getTitle() == null) {
            return false;
        }

        // Add to list and save
        galleries.add(gallery);
        return saveGalleries();
    }

    /**
     * Get gallery by ID
     * @param galleryId The gallery ID
     * @return The gallery or null if not found
     */
    public Gallery getGalleryById(String galleryId) {
        if (galleryId == null) return null;

        return galleries.stream()
                .filter(g -> g.getGalleryId().equals(galleryId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get all galleries for a photographer
     * @param photographerId The photographer ID
     * @return List of galleries for the photographer
     */
    // Update to GalleryManager.java - getGalleriesByPhotographer method
    public List<Gallery> getGalleriesByPhotographer(String photographerId) {
        if (photographerId == null) {
            LOGGER.warning("Attempting to get galleries with null photographerId");
            return new ArrayList<>();
        }

        LOGGER.info("Getting galleries for photographer ID: " + photographerId);
        List<Gallery> result = new ArrayList<>();

        for (Gallery gallery : galleries) {
            if (gallery.getPhotographerId() != null && gallery.getPhotographerId().equals(photographerId)) {
                result.add(gallery);
                LOGGER.info("Found gallery: " + gallery.getGalleryId() + " - " + gallery.getTitle());
            }
        }

        LOGGER.info("Found " + result.size() + " galleries for photographer: " + photographerId);
        return result;
    }

    /**
     * Get all public galleries for a photographer
     * @param photographerId The photographer ID
     * @return List of public galleries for the photographer
     */
    public List<Gallery> getPublicGalleriesByPhotographer(String photographerId) {
        if (photographerId == null) return new ArrayList<>();

        return galleries.stream()
                .filter(g -> g.getPhotographerId().equals(photographerId))
                .filter(g -> g.getStatus() == Gallery.GalleryStatus.PUBLISHED)
                .collect(Collectors.toList());
    }

    /**
     * Get galleries for a client
     * @param clientId The client ID
     * @return List of galleries for the client
     */
    public List<Gallery> getGalleriesByClient(String clientId) {
        if (clientId == null) return new ArrayList<>();

        return galleries.stream()
                .filter(g -> clientId.equals(g.getClientId()) ||
                        g.getStatus() == Gallery.GalleryStatus.PUBLISHED)
                .collect(Collectors.toList());
    }

    /**
     * Get galleries for a booking
     * @param bookingId The booking ID
     * @return List of galleries for the booking
     */
    public List<Gallery> getGalleriesByBooking(String bookingId) {
        if (bookingId == null) return new ArrayList<>();

        return galleries.stream()
                .filter(g -> bookingId.equals(g.getBookingId()))
                .collect(Collectors.toList());
    }

    /**
     * Get galleries by category
     * @param category The category
     * @return List of galleries in the category
     */
    public List<Gallery> getGalleriesByCategory(String category) {
        if (category == null) return new ArrayList<>();

        return galleries.stream()
                .filter(g -> category.equals(g.getCategory()))
                .filter(g -> g.getStatus() == Gallery.GalleryStatus.PUBLISHED)
                .collect(Collectors.toList());
    }

    /**
     * Update an existing gallery
     * @param updatedGallery The updated gallery
     * @return true if successful, false otherwise
     */
    public boolean updateGallery(Gallery updatedGallery) {
        if (updatedGallery == null || updatedGallery.getGalleryId() == null) {
            return false;
        }

        // Update lastUpdatedDate
        updatedGallery.setLastUpdatedDate(LocalDateTime.now());

        for (int i = 0; i < galleries.size(); i++) {
            if (galleries.get(i).getGalleryId().equals(updatedGallery.getGalleryId())) {
                galleries.set(i, updatedGallery);
                return saveGalleries();
            }
        }

        return false; // Gallery not found
    }

    /**
     * Delete a gallery
     * @param galleryId The gallery ID
     * @return true if successful, false otherwise
     */
    public boolean deleteGallery(String galleryId) {
        if (galleryId == null) {
            return false;
        }

        boolean removed = galleries.removeIf(g -> g.getGalleryId().equals(galleryId));
        if (removed) {
            return saveGalleries();
        }

        return false; // Gallery not found
    }

    /**
     * Add a photo to a gallery
     * @param galleryId The gallery ID
     * @param photoId The photo ID
     * @return true if successful, false otherwise
     */
    public boolean addPhotoToGallery(String galleryId, String photoId) {
        Gallery gallery = getGalleryById(galleryId);
        if (gallery == null || photoId == null) {
            return false;
        }

        gallery.addPhotoId(photoId);

        // If this is the first photo, set it as the cover photo
        if (gallery.getCoverPhotoId() == null && gallery.getPhotoIds().size() == 1) {
            gallery.setCoverPhotoId(photoId);
        }

        return updateGallery(gallery);
    }

    /**
     * Remove a photo from a gallery
     * @param galleryId The gallery ID
     * @param photoId The photo ID
     * @return true if successful, false otherwise
     */
    public boolean removePhotoFromGallery(String galleryId, String photoId) {
        Gallery gallery = getGalleryById(galleryId);
        if (gallery == null || photoId == null) {
            return false;
        }

        gallery.removePhotoId(photoId);
        return updateGallery(gallery);
    }

    /**
     * Set the cover photo for a gallery
     * @param galleryId The gallery ID
     * @param photoId The photo ID to set as cover
     * @return true if successful, false otherwise
     */
    public boolean setCoverPhoto(String galleryId, String photoId) {
        Gallery gallery = getGalleryById(galleryId);
        if (gallery == null || photoId == null || !gallery.getPhotoIds().contains(photoId)) {
            return false;
        }

        gallery.setCoverPhotoId(photoId);
        return updateGallery(gallery);
    }

    /**
     * Set gallery status
     * @param galleryId The gallery ID
     * @param status The new status
     * @return true if successful, false otherwise
     */
    public boolean setGalleryStatus(String galleryId, Gallery.GalleryStatus status) {
        Gallery gallery = getGalleryById(galleryId);
        if (gallery == null || status == null) {
            return false;
        }

        gallery.setStatus(status);
        return updateGallery(gallery);
    }

    /**
     * Search galleries by keyword
     * @param keyword The keyword to search for
     * @return List of matching galleries
     */
    public List<Gallery> searchGalleries(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>(galleries);
        }

        String searchTerm = keyword.toLowerCase();

        return galleries.stream()
                .filter(g -> (g.getTitle() != null && g.getTitle().toLowerCase().contains(searchTerm)) ||
                        (g.getDescription() != null && g.getDescription().toLowerCase().contains(searchTerm)) ||
                        (g.getCategory() != null && g.getCategory().toLowerCase().contains(searchTerm)))
                .collect(Collectors.toList());
    }
}
