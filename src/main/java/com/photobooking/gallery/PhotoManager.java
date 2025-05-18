package com.photobooking.model.gallery;

import com.photobooking.util.FileHandler;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Logger;
import java.util.logging.Level;
import javax.servlet.ServletContext;
import java.io.File;
import java.io.FileOutputStream;
import java.io.ByteArrayInputStream;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.Image;
import java.awt.Graphics2D;
import java.awt.AlphaComposite;
import java.awt.RenderingHints;
import java.io.IOException;
import java.io.InputStream;

/**
 * Manages photo-related operations for the Event Photography System
 */
public class PhotoManager {
    private static final Logger LOGGER = Logger.getLogger(PhotoManager.class.getName());
    private static final String PHOTOS_FILE = "photos.txt";
    private static final String PHOTOS_DIRECTORY = "photos";
    private static final String THUMBNAILS_DIRECTORY = "thumbnails";
    private static final int THUMBNAIL_SIZE = 250;

    private List<Photo> photos;
    private ServletContext servletContext;

    // Constructors
    public PhotoManager() {
        this(null);
    }

    public PhotoManager(ServletContext servletContext) {
        this.servletContext = servletContext;

        // If servletContext is provided, initialize FileHandler
        if (servletContext != null) {
            FileHandler.setServletContext(servletContext);
        }

        // Ensure directories exist
        FileHandler.createDirectory(PHOTOS_DIRECTORY);
        FileHandler.createDirectory(THUMBNAILS_DIRECTORY);

        this.photos = loadPhotos();
    }

    /**
     * Load photos from file
     * @return List of photos
     */
    private List<Photo> loadPhotos() {
        // Ensure file exists
        FileHandler.ensureFileExists(PHOTOS_FILE);

        List<String> lines = FileHandler.readLines(PHOTOS_FILE);
        List<Photo> loadedPhotos = new ArrayList<>();

        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                Photo photo = Photo.fromFileString(line);
                if (photo != null) {
                    loadedPhotos.add(photo);
                }
            }
        }

        LOGGER.info("Loaded " + loadedPhotos.size() + " photos from file");
        return loadedPhotos;
    }

    /**
     * Save all photos to file
     * @return true if successful, false otherwise
     */
    private boolean savePhotos() {
        try {
            // Create a backup first
            if (FileHandler.fileExists(PHOTOS_FILE)) {
                FileHandler.copyFile(PHOTOS_FILE, PHOTOS_FILE + ".bak");
            }

            // Delete existing file content
            FileHandler.deleteFile(PHOTOS_FILE);

            // Ensure file exists
            FileHandler.ensureFileExists(PHOTOS_FILE);

            // Write all photos at once
            StringBuilder contentToWrite = new StringBuilder();
            for (Photo photo : photos) {
                contentToWrite.append(photo.toFileString()).append(System.lineSeparator());
            }

            boolean result = FileHandler.writeToFile(PHOTOS_FILE, contentToWrite.toString(), false);

            if (result) {
                LOGGER.info("Successfully saved " + photos.size() + " photos");
            } else {
                LOGGER.warning("Failed to save photos");
                // Restore from backup
                if (FileHandler.fileExists(PHOTOS_FILE + ".bak")) {
                    FileHandler.copyFile(PHOTOS_FILE + ".bak", PHOTOS_FILE);
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving photos: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Create a new photo with file upload
     * @param photo The photo metadata
     * @param fileData The binary file data
     * @return true if successful, false otherwise
     */
    public boolean createPhoto(Photo photo, byte[] fileData) {
        // Basic validation
        if (photo == null || photo.getGalleryId() == null || photo.getPhotographerId() == null ||
                fileData == null || fileData.length == 0) {
            LOGGER.severe("Invalid photo data or empty file data");
            return false;
        }

        try {
            // Ensure directories exist
            FileHandler.createDirectory(PHOTOS_DIRECTORY);
            FileHandler.createDirectory(THUMBNAILS_DIRECTORY);
            LOGGER.info("Directories created/verified: " + PHOTOS_DIRECTORY + ", " + THUMBNAILS_DIRECTORY);

            // Generate file paths
            String extension = getFileExtension(photo.getOriginalFileName());
            String fileName = photo.getPhotoId() + "." + extension;
            String filePath = PHOTOS_DIRECTORY + File.separator + fileName;
            String thumbnailPath = THUMBNAILS_DIRECTORY + File.separator + fileName;

            LOGGER.info("Saving photo to: " + filePath);
            LOGGER.info("Thumbnail path: " + thumbnailPath);

            // Create parent directories if they don't exist
            File photoFile = new File(filePath);
            if (photoFile.getParentFile() != null) {
                photoFile.getParentFile().mkdirs();
            }

            File thumbnailFile = new File(thumbnailPath);
            if (thumbnailFile.getParentFile() != null) {
                thumbnailFile.getParentFile().mkdirs();
            }

            // Save original file directly
            try (FileOutputStream fos = new FileOutputStream(filePath)) {
                fos.write(fileData);
                LOGGER.info("Wrote " + fileData.length + " bytes to " + filePath);
            }

            // Generate and save thumbnail
            createThumbnail(fileData, thumbnailPath);
            LOGGER.info("Thumbnail created at: " + thumbnailPath);

            // Set file paths
            photo.setFileName(fileName);
            photo.setFilePath(filePath);
            photo.setThumbnailPath(thumbnailPath);

            // Extract image dimensions
            try {
                BufferedImage bufferedImage = ImageIO.read(new ByteArrayInputStream(fileData));
                if (bufferedImage != null) {
                    photo.setWidth(bufferedImage.getWidth());
                    photo.setHeight(bufferedImage.getHeight());
                    LOGGER.info("Image dimensions: " + bufferedImage.getWidth() + "x" + bufferedImage.getHeight());
                } else {
                    LOGGER.warning("Could not read image dimensions");
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error reading image dimensions: " + e.getMessage(), e);
                // Continue processing even if we can't read dimensions
            }

            // Set file size
            photo.setFileSize(fileData.length);

            // Add to list and save
            photos.add(photo);
            boolean saved = savePhotos();
            LOGGER.info("Photo metadata " + (saved ? "saved" : "failed to save"));
            return saved;

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating photo: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Write binary data to a file
     * @param filePath Path to the file
     * @param data Binary data to write
     * @return true if successful, false otherwise
     */
    private boolean writeBinaryFile(String filePath, byte[] data) {
        try {
            File file = new File(filePath);

            // Ensure parent directory exists
            if (file.getParentFile() != null) {
                file.getParentFile().mkdirs();
            }

            // Write binary data
            try (FileOutputStream fos = new FileOutputStream(file)) {
                fos.write(data);
            }

            return true;
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error writing binary file: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Create a thumbnail of an image
     * @param fileData The original image data
     * @param thumbnailPath The path to save the thumbnail
     * @throws IOException If there's an error processing the image
     */
    private void createThumbnail(byte[] fileData, String thumbnailPath) throws IOException {
        BufferedImage originalImage = ImageIO.read(new ByteArrayInputStream(fileData));
        if (originalImage == null) {
            throw new IOException("Could not read image data");
        }

        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();

        // Calculate dimensions to maintain aspect ratio
        int width, height;
        if (originalWidth > originalHeight) {
            width = THUMBNAIL_SIZE;
            height = (int) (originalHeight * ((double) THUMBNAIL_SIZE / originalWidth));
        } else {
            height = THUMBNAIL_SIZE;
            width = (int) (originalWidth * ((double) THUMBNAIL_SIZE / originalHeight));
        }

        // Create thumbnail
        BufferedImage thumbnailImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = thumbnailImage.createGraphics();
        g2d.setComposite(AlphaComposite.Src);
        g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2d.drawImage(originalImage, 0, 0, width, height, null);
        g2d.dispose();

        // Save thumbnail
        File thumbnailFile = new File(thumbnailPath);

        // Ensure parent directory exists
        if (thumbnailFile.getParentFile() != null) {
            thumbnailFile.getParentFile().mkdirs();
        }

        // Get file extension
        String extension = thumbnailPath.substring(thumbnailPath.lastIndexOf('.') + 1);
        if (extension.toLowerCase().equals("jpg")) {
            extension = "jpeg"; // ImageIO requires "jpeg" not "jpg"
        }

        // Write thumbnail file
        ImageIO.write(thumbnailImage, extension, thumbnailFile);
    }

    /**
     * Get file extension from filename
     * @param fileName The filename
     * @return The file extension
     */
    private String getFileExtension(String fileName) {
        if (fileName == null) return "";
        int dotIndex = fileName.lastIndexOf('.');
        return (dotIndex == -1) ? "" : fileName.substring(dotIndex + 1).toLowerCase();
    }

    /**
     * Get photo by ID
     * @param photoId The photo ID
     * @return The photo or null if not found
     */
    public Photo getPhotoById(String photoId) {
        if (photoId == null) return null;

        return photos.stream()
                .filter(p -> p.getPhotoId().equals(photoId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get photos by gallery ID
     * @param galleryId The gallery ID
     * @return List of photos in the gallery
     */
    public List<Photo> getPhotosByGallery(String galleryId) {
        if (galleryId == null) return new ArrayList<>();

        return photos.stream()
                .filter(p -> p.getGalleryId().equals(galleryId))
                .collect(Collectors.toList());
    }

    /**
     * Get photos by photographer ID
     * @param photographerId The photographer ID
     * @return List of photos by the photographer
     */
    public List<Photo> getPhotosByPhotographer(String photographerId) {
        if (photographerId == null) return new ArrayList<>();

        return photos.stream()
                .filter(p -> p.getPhotographerId().equals(photographerId))
                .collect(Collectors.toList());
    }

    /**
     * Update an existing photo's metadata
     * @param updatedPhoto The updated photo
     * @return true if successful, false otherwise
     */
    public boolean updatePhoto(Photo updatedPhoto) {
        if (updatedPhoto == null || updatedPhoto.getPhotoId() == null) {
            return false;
        }

        for (int i = 0; i < photos.size(); i++) {
            if (photos.get(i).getPhotoId().equals(updatedPhoto.getPhotoId())) {
                // Keep original file paths and dimensions
                updatedPhoto.setFilePath(photos.get(i).getFilePath());
                updatedPhoto.setThumbnailPath(photos.get(i).getThumbnailPath());
                updatedPhoto.setWidth(photos.get(i).getWidth());
                updatedPhoto.setHeight(photos.get(i).getHeight());
                updatedPhoto.setFileSize(photos.get(i).getFileSize());

                photos.set(i, updatedPhoto);
                return savePhotos();
            }
        }

        return false; // Photo not found
    }

    /**
     * Delete a photo
     * @param photoId The photo ID
     * @return true if successful, false otherwise
     */
    public boolean deletePhoto(String photoId) {
        if (photoId == null) {
            return false;
        }

        Photo photo = getPhotoById(photoId);
        if (photo == null) {
            return false;
        }

        // Delete files
        try {
            if (photo.getFilePath() != null) {
                File file = new File(photo.getFilePath());
                if (file.exists()) {
                    file.delete();
                }
            }

            if (photo.getThumbnailPath() != null) {
                File thumbnail = new File(photo.getThumbnailPath());
                if (thumbnail.exists()) {
                    thumbnail.delete();
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error deleting photo files: " + e.getMessage(), e);
        }

        // Remove from list
        boolean removed = photos.removeIf(p -> p.getPhotoId().equals(photoId));
        if (removed) {
            return savePhotos();
        }

        return false; // Photo not found
    }

    /**
     * Delete all photos in a gallery
     * @param galleryId The gallery ID
     * @return true if successful, false otherwise
     */
    public boolean deleteGalleryPhotos(String galleryId) {
        if (galleryId == null) {
            return false;
        }

        List<Photo> galleryPhotos = getPhotosByGallery(galleryId);

        // Delete each photo's files
        for (Photo photo : galleryPhotos) {
            try {
                if (photo.getFilePath() != null) {
                    File file = new File(photo.getFilePath());
                    if (file.exists()) {
                        file.delete();
                    }
                }

                if (photo.getThumbnailPath() != null) {
                    File thumbnail = new File(photo.getThumbnailPath());
                    if (thumbnail.exists()) {
                        thumbnail.delete();
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error deleting photo files: " + e.getMessage(), e);
            }
        }

        // Remove all gallery photos from list
        boolean removed = photos.removeIf(p -> galleryId.equals(p.getGalleryId()));
        if (removed) {
            return savePhotos();
        }

        return !galleryPhotos.isEmpty(); // Return true if there were photos to delete
    }
}