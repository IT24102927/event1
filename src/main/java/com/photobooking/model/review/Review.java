package com.photobooking.model.review;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Represents a review for a photographer
 */
public class Review implements Serializable {
    private static final long serialVersionUID = 1L;

    private String reviewId;
    private String photographerId;
    private String clientId;
    private String bookingId;
    private int rating;
    private String comment;
    private LocalDateTime reviewDate;
    private String serviceType;
    private boolean verified;
    private boolean hasResponse;
    private String responseText;
    private LocalDateTime responseDate;

    public Review() {
        this.reviewId = UUID.randomUUID().toString();
        this.reviewDate = LocalDateTime.now();
        this.verified = false;
        this.hasResponse = false;
    }

    // Getters and Setters
    public String getReviewId() {
        return reviewId;
    }

    public void setReviewId(String reviewId) {
        this.reviewId = reviewId;
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

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public LocalDateTime getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(LocalDateTime reviewDate) {
        this.reviewDate = reviewDate;
    }

    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }

    public boolean isVerified() {
        return verified;
    }

    public void setVerified(boolean verified) {
        this.verified = verified;
    }

    public boolean isHasResponse() {
        return hasResponse;
    }

    public void setHasResponse(boolean hasResponse) {
        this.hasResponse = hasResponse;
    }

    public String getResponseText() {
        return responseText;
    }

    public void setResponseText(String responseText) {
        this.responseText = responseText;
    }

    public LocalDateTime getResponseDate() {
        return responseDate;
    }

    public void setResponseDate(LocalDateTime responseDate) {
        this.responseDate = responseDate;
    }

    public String toFileString() {
        return String.join(",",
                reviewId,
                photographerId,
                clientId,
                bookingId != null ? bookingId : "",
                String.valueOf(rating),
                comment.replace(",", ";;"),
                reviewDate.toString(),
                serviceType,
                String.valueOf(verified),
                String.valueOf(hasResponse),
                responseText != null ? responseText.replace(",", ";;") : "",
                responseDate != null ? responseDate.toString() : ""
        );
    }

    public static Review fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length >= 9) {
            Review review = new Review();
            review.setReviewId(parts[0]);
            review.setPhotographerId(parts[1]);
            review.setClientId(parts[2]);
            review.setBookingId(parts[3].isEmpty() ? null : parts[3]);
            review.setRating(Integer.parseInt(parts[4]));
            review.setComment(parts[5].replace(";;", ","));
            review.setReviewDate(LocalDateTime.parse(parts[6]));
            review.setServiceType(parts[7]);
            review.setVerified(Boolean.parseBoolean(parts[8]));

            if (parts.length > 9) review.setHasResponse(Boolean.parseBoolean(parts[9]));
            if (parts.length > 10) review.setResponseText(parts[10].replace(";;", ","));
            if (parts.length > 11 && !parts[11].isEmpty()) review.setResponseDate(LocalDateTime.parse(parts[11]));

            return review;
        }
        return null;
    }
}