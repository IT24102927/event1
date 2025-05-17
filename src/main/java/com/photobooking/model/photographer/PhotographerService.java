package com.photobooking.model.photographer;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Represents a service package offered by a photographer
 */
public class PhotographerService implements Serializable {
    private static final long serialVersionUID = 1L;

    // Service attributes
    private String serviceId;
    private String photographerId;
    private String name;
    private String description;
    private double price;
    private String category; // e.g., WEDDING, PORTRAIT, EVENT, etc.
    private int durationHours;
    private int photographersCount;
    private List<String> features;
    private String deliverables;
    private boolean isActive;
    private int bookingCount;

    // Constructors
    public PhotographerService() {
        this.serviceId = UUID.randomUUID().toString();
        this.features = new ArrayList<>();
        this.isActive = true;
        this.bookingCount = 0;
    }

    public PhotographerService(String photographerId, String name, String description,
                               double price, String category, int durationHours) {
        this();
        this.photographerId = photographerId;
        this.name = name;
        this.description = description;
        this.price = price;
        this.category = category;
        this.durationHours = durationHours;
        this.photographersCount = 1; // Default to 1 photographer
    }

    // Getters and Setters
    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getPhotographerId() {
        return photographerId;
    }

    public void setPhotographerId(String photographerId) {
        this.photographerId = photographerId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getDurationHours() {
        return durationHours;
    }

    public void setDurationHours(int durationHours) {
        this.durationHours = durationHours;
    }

    public int getPhotographersCount() {
        return photographersCount;
    }

    public void setPhotographersCount(int photographersCount) {
        this.photographersCount = photographersCount;
    }

    public List<String> getFeatures() {
        return features;
    }

    public void setFeatures(List<String> features) {
        this.features = features;
    }

    public String getDeliverables() {
        return deliverables;
    }

    public void setDeliverables(String deliverables) {
        this.deliverables = deliverables;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public int getBookingCount() {
        return bookingCount;
    }

    public void setBookingCount(int bookingCount) {
        this.bookingCount = bookingCount;
    }

    // Business methods
    /**
     * Add a feature to the service package
     * @param feature Feature to add
     */
    public void addFeature(String feature) {
        if (feature != null && !feature.trim().isEmpty()) {
            features.add(feature);
        }
    }

    /**
     * Increment booking count
     */
    public void incrementBookingCount() {
        this.bookingCount++;
    }

    /**
     * Calculate total price for a custom duration
     * @param hours Custom duration in hours
     * @return Total price
     */
    public double calculatePriceForDuration(int hours) {
        if (hours <= 0) {
            return 0;
        }

        // If requested hours match the package, return the package price
        if (hours == durationHours) {
            return price;
        }

        // Otherwise, calculate hourly rate and multiply by requested hours
        double hourlyRate = price / durationHours;
        return hourlyRate * hours;
    }

    /**
     * Convert service to file string representation
     * @return String representation for file storage
     */
    public String toFileString() {
        StringBuilder sb = new StringBuilder();
        sb.append(serviceId).append(",");
        sb.append(photographerId != null ? photographerId : "").append(",");
        sb.append(name != null ? name.replace(",", ";;") : "").append(",");
        sb.append(description != null ? description.replace(",", ";;") : "").append(",");
        sb.append(price).append(",");
        sb.append(category != null ? category : "").append(",");
        sb.append(durationHours).append(",");
        sb.append(photographersCount).append(",");

        // Join features with |
        sb.append(String.join("|", features)).append(",");

        sb.append(deliverables != null ? deliverables.replace(",", ";;") : "").append(",");
        sb.append(isActive).append(",");
        sb.append(bookingCount);

        return sb.toString();
    }

    /**
     * Create service from file string
     * @param fileString String representation from file
     * @return PhotographerService object
     */
    public static PhotographerService fromFileString(String fileString) {
        String[] parts = fileString.split(",");
        if (parts.length < 11) {
            return null; // Not enough parts for a valid service
        }

        PhotographerService service = new PhotographerService();
        int index = 0;

        service.setServiceId(parts[index++]);
        service.setPhotographerId(parts[index++]);
        service.setName(parts[index++].replace(";;", ","));
        service.setDescription(parts[index++].replace(";;", ","));
        service.setPrice(Double.parseDouble(parts[index++]));
        service.setCategory(parts[index++]);
        service.setDurationHours(Integer.parseInt(parts[index++]));
        service.setPhotographersCount(Integer.parseInt(parts[index++]));

        // Parse features
        String featuresStr = parts[index++];
        if (!featuresStr.isEmpty()) {
            String[] featuresArr = featuresStr.split("\\|");
            for (String feature : featuresArr) {
                service.addFeature(feature);
            }
        }

        service.setDeliverables(parts[index++].replace(";;", ","));
        service.setActive(Boolean.parseBoolean(parts[index++]));
        service.setBookingCount(Integer.parseInt(parts[index]));

        return service;
    }

    @Override
    public String toString() {
        return "PhotographerService{" +
                "serviceId='" + serviceId + '\'' +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", price=" + price +
                ", isActive=" + isActive +
                '}';
    }
}
