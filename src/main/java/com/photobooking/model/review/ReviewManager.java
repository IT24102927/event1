package com.photobooking.model.review;

import com.photobooking.util.FileHandler;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.time.LocalDateTime;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Manages reviews for photographers
 */
public class ReviewManager {
    private static final Logger LOGGER = Logger.getLogger(ReviewManager.class.getName());
    private static final String REVIEWS_FILE = "reviews.txt";
    private List<Review> reviews;

    public ReviewManager() {
        this.reviews = loadReviews();
    }

    // Changed from private to public to allow access from ViewReviewsServlet
    public List<Review> loadReviews() {
        // Ensure file exists
        FileHandler.ensureFileExists(REVIEWS_FILE);

        List<String> lines = FileHandler.readLines(REVIEWS_FILE);
        List<Review> loadedReviews = new ArrayList<>();

        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                Review review = Review.fromFileString(line);
                if (review != null) {
                    loadedReviews.add(review);
                }
            }
        }

        LOGGER.info("Loaded " + loadedReviews.size() + " reviews from file");
        return loadedReviews;
    }

    private boolean saveReviews() {
        try {
            // Create a backup first
            if (FileHandler.fileExists(REVIEWS_FILE)) {
                FileHandler.copyFile(REVIEWS_FILE, REVIEWS_FILE + ".bak");
            }

            // Delete existing file content
            FileHandler.deleteFile(REVIEWS_FILE);

            // Ensure file exists after deletion
            FileHandler.ensureFileExists(REVIEWS_FILE);

            // Write all reviews at once
            StringBuilder contentToWrite = new StringBuilder();
            for (Review review : reviews) {
                contentToWrite.append(review.toFileString()).append(System.lineSeparator());
            }

            boolean result = FileHandler.writeToFile(REVIEWS_FILE, contentToWrite.toString(), false);

            if (result) {
                LOGGER.info("Successfully saved " + reviews.size() + " reviews");
            } else {
                LOGGER.warning("Failed to save reviews");
                // Restore from backup
                if (FileHandler.fileExists(REVIEWS_FILE + ".bak")) {
                    FileHandler.copyFile(REVIEWS_FILE + ".bak", REVIEWS_FILE);
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving reviews: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Add a new review
     * @param review The review to add
     * @return true if successful, false otherwise
     */
    public boolean addReview(Review review) {
        // Check if user already has a review for this photographer
        Review existingReview = getReviewByClientAndPhotographer(review.getClientId(), review.getPhotographerId());
        if (existingReview != null) {
            return false; // Client already has a review for this photographer
        }

        reviews.add(review);
        return saveReviews();
    }

    /**
     * Get a review by its ID
     * @param reviewId The review ID
     * @return The review, or null if not found
     */
    public Review getReviewById(String reviewId) {
        if (reviewId == null) return null;

        return reviews.stream()
                .filter(r -> r.getReviewId().equals(reviewId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get a review by client and photographer IDs
     * @param clientId The client ID
     * @param photographerId The photographer ID
     * @return The review, or null if not found
     */
    public Review getReviewByClientAndPhotographer(String clientId, String photographerId) {
        if (clientId == null || photographerId == null) return null;

        return reviews.stream()
                .filter(r -> r.getClientId().equals(clientId) && r.getPhotographerId().equals(photographerId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get all reviews for a photographer
     * @param photographerId The photographer ID
     * @return List of reviews, sorted by date (newest first)
     */
    public List<Review> getPhotographerReviews(String photographerId) {
        if (photographerId == null) return new ArrayList<>();

        return reviews.stream()
                .filter(review -> review.getPhotographerId().equals(photographerId))
                .sorted((r1, r2) -> r2.getReviewDate().compareTo(r1.getReviewDate()))
                .collect(Collectors.toList());
    }

    /**
     * Get all reviews by a client
     * @param clientId The client ID
     * @return List of reviews, sorted by date (newest first)
     */
    public List<Review> getClientReviews(String clientId) {
        if (clientId == null) return new ArrayList<>();

        return reviews.stream()
                .filter(review -> review.getClientId().equals(clientId))
                .sorted((r1, r2) -> r2.getReviewDate().compareTo(r1.getReviewDate()))
                .collect(Collectors.toList());
    }

    /**
     * Update an existing review
     * @param updatedReview The updated review
     * @return true if successful, false otherwise
     */
    public boolean updateReview(Review updatedReview) {
        if (updatedReview == null || updatedReview.getReviewId() == null) {
            return false;
        }

        for (int i = 0; i < reviews.size(); i++) {
            if (reviews.get(i).getReviewId().equals(updatedReview.getReviewId())) {
                reviews.set(i, updatedReview);
                return saveReviews();
            }
        }

        return false; // Review not found
    }

    /**
     * Delete a review
     * @param reviewId The review ID
     * @return true if successful, false otherwise
     */
    public boolean deleteReview(String reviewId) {
        if (reviewId == null) {
            return false;
        }

        boolean removed = reviews.removeIf(r -> r.getReviewId().equals(reviewId));
        if (removed) {
            return saveReviews();
        }

        return false; // Review not found
    }

    /**
     * Get average rating for a photographer
     * @param photographerId The photographer ID
     * @return Average rating (0.0 to 5.0), or 0.0 if no reviews
     */
    public double getAverageRating(String photographerId) {
        List<Review> photographerReviews = getPhotographerReviews(photographerId);
        if (photographerReviews.isEmpty()) {
            return 0.0;
        }

        double sum = photographerReviews.stream()
                .mapToInt(Review::getRating)
                .sum();
        return sum / photographerReviews.size();
    }

    /**
     * Get rating distribution for a photographer
     * @param photographerId The photographer ID
     * @return Array with count of ratings [1,2,3,4,5]
     */
    public int[] getRatingDistribution(String photographerId) {
        int[] distribution = new int[5]; // For ratings 1-5

        getPhotographerReviews(photographerId).forEach(review -> {
            if (review.getRating() >= 1 && review.getRating() <= 5) {
                distribution[review.getRating() - 1]++;
            }
        });

        return distribution;
    }

    /**
     * Get total review count for a photographer
     * @param photographerId The photographer ID
     * @return Total number of reviews
     */
    public int getReviewCount(String photographerId) {
        return getPhotographerReviews(photographerId).size();
    }

    /**
     * Add photographer response to a review
     * @param reviewId The review ID
     * @param responseText The response text
     * @return true if successful, false otherwise
     */
    public boolean addResponseToReview(String reviewId, String responseText) {
        Review review = getReviewById(reviewId);
        if (review == null) {
            return false;
        }

        review.setHasResponse(true);
        review.setResponseText(responseText);
        review.setResponseDate(LocalDateTime.now());

        return updateReview(review);
    }
}