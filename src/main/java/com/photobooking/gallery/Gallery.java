// Gallery.java
package com.photobooking.model.gallery;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Represents a photo gallery in the Event Photography System
 */
public class Gallery implements Serializable {
    private static final long serialVersionUID = 1L;

    // Gallery status enum
    public enum GalleryStatus {
        DRAFT, PUBLISHED, PRIVATE
    }

    // Gallery attributes
    private String galleryId;
    private String photographerId;
    private String clientId;
    private String bookingId;
    private String title;
    private String description;
    private String category;
    private LocalDateTime createdDate;
    private LocalDateTime lastUpdatedDate;
    private GalleryStatus status;
    private List<String> photoIds;
    private String coverPhotoId;

    // Constructors
    public Gallery() {
        this.galleryId = UUID.randomUUID().toString();
        this.createdDate = LocalDateTime.now();
        this.lastUpdatedDate = LocalDateTime.now();
        this.status = GalleryStatus.DRAFT;
        this.photoIds = new ArrayList<>();
    }

    public Gallery(String photographerId, String title, String description, String category) {
        this();
        this.photographerId = photographerId;
        this.title = title;
        this.description = description;
        this.category = category;
    }

    // Getters and Setters
    public String getGalleryId() {
        return galleryId;
    }

    public void setGalleryId(String galleryId) {
        this.galleryId = galleryId;
    }

    public String getPhotographerId() {
        return photographerId;
    }

    public void setPhotographerId(String photographerId) {
        this.photographerId = photographerId;
    }

    public String getClientId() {
        return clientId;
    }

    public void setClientId(String clientId) {
        this.clientId = clientId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public LocalDateTime getLastUpdatedDate() {
        return lastUpdatedDate;
    }

    public void setLastUpdatedDate(LocalDateTime lastUpdatedDate) {
        this.lastUpdatedDate = lastUpdatedDate;
    }

    public GalleryStatus getStatus() {
        return status;
    }

    public void setStatus(GalleryStatus status) {
        this.status = status;
    }

    public List<String> getPhotoIds() {
        return photoIds;
    }

    public void setPhotoIds(List<String> photoIds) {
        this.photoIds = photoIds;
    }

    public String getCoverPhotoId() {
        return coverPhotoId;
    }

    public void setCoverPhotoId(String coverPhotoId) {
        this.coverPhotoId = coverPhotoId;
    }

    // Business methods
    public void addPhotoId(String photoId) {
        if (photoId != null && !photoIds.contains(photoId)) {
            photoIds.add(photoId);
            lastUpdatedDate = LocalDateTime.now();
        }
    }

    public void removePhotoId(String photoId) {
        if (photoId != null && photoIds.contains(photoId)) {
            photoIds.remove(photoId);

            // If the removed photo was the cover photo, set new cover photo
            if (photoId.equals(coverPhotoId) && !photoIds.isEmpty()) {
                coverPhotoId = photoIds.get(0);
            } else if (photoId.equals(coverPhotoId)) {
                coverPhotoId = null;
            }

            lastUpdatedDate = LocalDateTime.now();
        }
    }

    // Convert gallery to file string representation
    public String toFileString() {
        StringBuilder sb = new StringBuilder();
        sb.append(galleryId).append(",");
        sb.append(photographerId).append(",");
        sb.append(clientId != null ? clientId : "").append(",");
        sb.append(bookingId != null ? bookingId : "").append(",");
        sb.append(title.replace(",", ";;")).append(",");
        sb.append(description != null ? description.replace(",", ";;") : "").append(",");
        sb.append(category != null ? category : "").append(",");
        sb.append(createdDate.toString()).append(",");
        sb.append(lastUpdatedDate.toString()).append(",");
        sb.append(status.name()).append(",");

        // Join photoIds with |
        sb.append(String.join("|", photoIds)).append(",");

        sb.append(coverPhotoId != null ? coverPhotoId : "");

        return sb.toString();
    }

    // Create gallery from file string
    public static Gallery fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length < 10) {
            return null; // Not enough parts for a valid gallery
        }

        Gallery gallery = new Gallery();
        int index = 0;

        gallery.setGalleryId(parts[index++]);
        gallery.setPhotographerId(parts[index++]);

        String clientId = parts[index++];
        if (!clientId.isEmpty()) {
            gallery.setClientId(clientId);
        }

        String bookingId = parts[index++];
        if (!bookingId.isEmpty()) {
            gallery.setBookingId(bookingId);
        }

        gallery.setTitle(parts[index++].replace(";;", ","));

        String description = parts[index++];
        if (!description.isEmpty()) {
            gallery.setDescription(description.replace(";;", ","));
        }

        String category = parts[index++];
        if (!category.isEmpty()) {
            gallery.setCategory(category);
        }

        gallery.setCreatedDate(LocalDateTime.parse(parts[index++]));
        gallery.setLastUpdatedDate(LocalDateTime.parse(parts[index++]));
        gallery.setStatus(GalleryStatus.valueOf(parts[index++]));

        // Parse photoIds
        if (index < parts.length) {
            String photoIdsStr = parts[index++];
            if (!photoIdsStr.isEmpty()) {
                String[] photoIdsArray = photoIdsStr.split("\\|");
                for (String photoId : photoIdsArray) {
                    gallery.addPhotoId(photoId);
                }
            }
        }

        // Check if there's a cover photo ID
        if (index < parts.length && !parts[index].isEmpty()) {
            gallery.setCoverPhotoId(parts[index]);
        }

        return gallery;
    }
}
