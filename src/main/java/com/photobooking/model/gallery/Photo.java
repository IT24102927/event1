// Photo.java
package com.photobooking.model.gallery;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Represents a photo in the Event Photography System
 */
public class Photo implements Serializable {
    private static final long serialVersionUID = 1L;

    // Photo attributes
    private String photoId;
    private String galleryId;
    private String photographerId;
    private String fileName;
    private String originalFileName;
    private String title;
    private String description;
    private String filePath;
    private String thumbnailPath;
    private LocalDateTime uploadDate;
    private int width;
    private int height;
    private long fileSize;
    private String contentType;

    // Constructors
    public Photo() {
        this.photoId = UUID.randomUUID().toString();
        this.uploadDate = LocalDateTime.now();
    }

    public Photo(String galleryId, String photographerId, String fileName, String originalFileName) {
        this();
        this.galleryId = galleryId;
        this.photographerId = photographerId;
        this.fileName = fileName;
        this.originalFileName = originalFileName;
    }

    // Getters and Setters
    public String getPhotoId() {
        return photoId;
    }

    public void setPhotoId(String photoId) {
        this.photoId = photoId;
    }

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

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getOriginalFileName() {
        return originalFileName;
    }

    public void setOriginalFileName(String originalFileName) {
        this.originalFileName = originalFileName;
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

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getThumbnailPath() {
        return thumbnailPath;
    }

    public void setThumbnailPath(String thumbnailPath) {
        this.thumbnailPath = thumbnailPath;
    }

    public LocalDateTime getUploadDate() {
        return uploadDate;
    }

    public void setUploadDate(LocalDateTime uploadDate) {
        this.uploadDate = uploadDate;
    }

    public int getWidth() {
        return width;
    }

    public void setWidth(int width) {
        this.width = width;
    }

    public int getHeight() {
        return height;
    }

    public void setHeight(int height) {
        this.height = height;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public String getContentType() {
        return contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    // Convert photo to file string representation
    public String toFileString() {
        StringBuilder sb = new StringBuilder();
        sb.append(photoId).append(",");
        sb.append(galleryId).append(",");
        sb.append(photographerId).append(",");
        sb.append(fileName).append(",");
        sb.append(originalFileName.replace(",", ";;")).append(",");
        sb.append(title != null ? title.replace(",", ";;") : "").append(",");
        sb.append(description != null ? description.replace(",", ";;") : "").append(",");
        sb.append(filePath).append(",");
        sb.append(thumbnailPath != null ? thumbnailPath : "").append(",");
        sb.append(uploadDate.toString()).append(",");
        sb.append(width).append(",");
        sb.append(height).append(",");
        sb.append(fileSize).append(",");
        sb.append(contentType != null ? contentType : "");

        return sb.toString();
    }

    // Create photo from file string
    public static Photo fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length < 10) {
            return null; // Not enough parts for a valid photo
        }

        Photo photo = new Photo();
        int index = 0;

        photo.setPhotoId(parts[index++]);
        photo.setGalleryId(parts[index++]);
        photo.setPhotographerId(parts[index++]);
        photo.setFileName(parts[index++]);
        photo.setOriginalFileName(parts[index++].replace(";;", ","));

        String title = parts[index++];
        if (!title.isEmpty()) {
            photo.setTitle(title.replace(";;", ","));
        }

        String description = parts[index++];
        if (!description.isEmpty()) {
            photo.setDescription(description.replace(";;", ","));
        }

        photo.setFilePath(parts[index++]);

        String thumbnailPath = parts[index++];
        if (!thumbnailPath.isEmpty()) {
            photo.setThumbnailPath(thumbnailPath);
        }

        photo.setUploadDate(LocalDateTime.parse(parts[index++]));
        photo.setWidth(Integer.parseInt(parts[index++]));
        photo.setHeight(Integer.parseInt(parts[index++]));
        photo.setFileSize(Long.parseLong(parts[index++]));

        if (index < parts.length) {
            photo.setContentType(parts[index]);
        }

        return photo;
    }
}
