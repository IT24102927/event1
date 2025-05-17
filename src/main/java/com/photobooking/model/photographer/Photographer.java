package com.photobooking.model.photographer;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
  Base Photographer class for the Event Photography System
 */
public class Photographer implements Serializable {
    private static final long serialVersionUID = 1L;

    // Photographer attributes
    protected String photographerId;
    protected String userId;
    protected String businessName;
    protected String biography;
    protected List<String> specialties;
    protected String location;
    protected double basePrice;
    protected double rating;
    protected int reviewCount;
    protected boolean isVerified;
    protected String contactPhone;
    protected String websiteUrl;
    protected int yearsOfExperience;
    protected String email;

    // Constructors
    public Photographer() {
        this.photographerId = UUID.randomUUID().toString();
        this.specialties = new ArrayList<>();
        this.rating = 0.0;
        this.reviewCount = 0;
        this.isVerified = false;
    }

    public Photographer(String userId, String businessName, String biography, List<String> specialties,
                        String location, double basePrice) {
        this();
        this.userId = userId;
        this.businessName = businessName;
        this.biography = biography;
        if (specialties != null) {
            this.specialties.addAll(specialties);
        }
        this.location = location;
        this.basePrice = basePrice;
    }

    // Getters and Setters
    public String getPhotographerId() {
        return photographerId;
    }

    public void setPhotographerId(String photographerId) {
        this.photographerId = photographerId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getBusinessName() {
        return businessName;
    }

    public void setBusinessName(String businessName) {
        this.businessName = businessName;
    }

    public String getBiography() {
        return biography;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public List<String> getSpecialties() {
        return specialties;
    }

    public void setSpecialties(List<String> specialties) {
        this.specialties = specialties;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        isVerified = verified;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getWebsiteUrl() {
        return websiteUrl;
    }

    public void setWebsiteUrl(String websiteUrl) {
        this.websiteUrl = websiteUrl;
    }

    public int getYearsOfExperience() {
        return yearsOfExperience;
    }

    public void setYearsOfExperience(int yearsOfExperience) {
        this.yearsOfExperience = yearsOfExperience;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // Business methods
    /**
     * Calculate price for a specific booking type
     * @param hours Number of hours
     * @param bookingType Type of booking
     * @return Price for the booking
     */
    public double calculatePrice(int hours, String bookingType) {
        double price = basePrice * hours;

        // Apply multiplier based on booking type
        switch (bookingType) {
            case "WEDDING":
                price *= 1.5; // 50% premium for weddings
                break;
            case "CORPORATE":
                price *= 1.25; // 25% premium for corporate events
                break;
            case "PORTRAIT":
                price *= 1.1; // 10% premium for portrait photography
                break;
        }

        return price;
    }

    /**
     * Add a new review rating
     * @param newRating Rating from 1-5
     */
    public void addReview(double newRating) {
        if (newRating < 1 || newRating > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }

        // Calculate new average rating
        double totalRating = this.rating * this.reviewCount;
        totalRating += newRating;
        this.reviewCount++;
        this.rating = totalRating / this.reviewCount;
    }

    // Convert photographer to file string representation
    public String toFileString() {
        StringBuilder sb = new StringBuilder();
        sb.append(photographerId).append(",");
        sb.append(userId).append(",");
        sb.append(businessName != null ? businessName.replace(",", ";;") : "").append(",");
        sb.append(biography != null ? biography.replace(",", ";;") : "").append(",");

        // Join specialties with |
        sb.append(String.join("|", specialties)).append(",");

        sb.append(location != null ? location : "").append(",");
        sb.append(basePrice).append(",");
        sb.append(rating).append(",");
        sb.append(reviewCount).append(",");
        sb.append(isVerified).append(",");
        sb.append(contactPhone != null ? contactPhone : "").append(",");
        sb.append(websiteUrl != null ? websiteUrl : "").append(",");
        sb.append(yearsOfExperience).append(",");
        sb.append(email != null ? email : "");

        return sb.toString();
    }

    /**
     * Create photographer from file string
     * @param fileString String representation from file
     * @return Photographer object
     */
    public static Photographer fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length < 13) {
            return null; // Not enough parts for a valid photographer
        }

        Photographer photographer = new Photographer();
        int index = 0;

        photographer.setPhotographerId(parts[index++]);
        photographer.setUserId(parts[index++]);
        photographer.setBusinessName(parts[index++].replace(";;", ","));
        photographer.setBiography(parts[index++].replace(";;", ","));

        // Parse specialties
        String specialtiesStr = parts[index++];
        if (!specialtiesStr.isEmpty()) {
            String[] specialtiesArr = specialtiesStr.split("\\|");
            for (String specialty : specialtiesArr) {
                photographer.getSpecialties().add(specialty);
            }
        }

        photographer.setLocation(parts[index++]);
        photographer.setBasePrice(Double.parseDouble(parts[index++]));
        photographer.setRating(Double.parseDouble(parts[index++]));
        photographer.setReviewCount(Integer.parseInt(parts[index++]));
        photographer.setVerified(Boolean.parseBoolean(parts[index++]));
        photographer.setContactPhone(parts[index++]);
        photographer.setWebsiteUrl(parts[index++]);
        photographer.setYearsOfExperience(Integer.parseInt(parts[index++]));

        if (index < parts.length) {
            photographer.setEmail(parts[index]);
        }

        return photographer;
    }

    @Override
    public String toString() {
        return "Photographer{" +
                "photographerId='" + photographerId + '\'' +
                ", businessName='" + businessName + '\'' +
                ", location='" + location + '\'' +
                ", rating=" + rating +
                ", reviewCount=" + reviewCount +
                '}';
    }
}