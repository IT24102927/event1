package com.photobooking.model.photographer;

import java.util.List;

/**
 * Represents a freelance photographer in the Event Photography System
 */
public class FreelancePhotographer extends Photographer {
    private static final long serialVersionUID = 1L;

    // Additional attributes specific to freelance photographers
    private boolean providesOwnEquipment;
    private double travelFeePerMile;
    private int maxTravelDistance;
    private boolean offersDiscounts;

    // Constructors
    public FreelancePhotographer() {
        super();
        this.providesOwnEquipment = true;
        this.travelFeePerMile = 0.50; // Default $0.50 per mile
        this.maxTravelDistance = 50; // Default 50 miles
        this.offersDiscounts = false;
    }

    public FreelancePhotographer(String userId, String businessName, String biography,
                                 List<String> specialties, String location, double basePrice) {
        super(userId, businessName, biography, specialties, location, basePrice);
        this.providesOwnEquipment = true;
        this.travelFeePerMile = 0.50;
        this.maxTravelDistance = 50;
        this.offersDiscounts = false;
    }

    // Getters and Setters
    public boolean isProvidesOwnEquipment() {
        return providesOwnEquipment;
    }

    public void setProvidesOwnEquipment(boolean providesOwnEquipment) {
        this.providesOwnEquipment = providesOwnEquipment;
    }

    public double getTravelFeePerMile() {
        return travelFeePerMile;
    }

    public void setTravelFeePerMile(double travelFeePerMile) {
        this.travelFeePerMile = travelFeePerMile;
    }

    public int getMaxTravelDistance() {
        return maxTravelDistance;
    }

    public void setMaxTravelDistance(int maxTravelDistance) {
        this.maxTravelDistance = maxTravelDistance;
    }

    public boolean isOffersDiscounts() {
        return offersDiscounts;
    }

    public void setOffersDiscounts(boolean offersDiscounts) {
        this.offersDiscounts = offersDiscounts;
    }

    // Overridden methods
    @Override
    public double calculatePrice(int hours, String bookingType) {
        // Start with base calculation from parent class
        double price = super.calculatePrice(hours, bookingType);

        // Add equipment fee if applicable (10% surcharge)
        if (providesOwnEquipment) {
            price *= 1.10;
        }

        return price;
    }

    /**
     * Calculate travel fee based on distance
     * @param distance Distance to travel in miles
     * @return Travel fee amount
     */
    public double calculateTravelFee(int distance) {
        if (distance <= 0) {
            return 0.0;
        }

        // If distance exceeds max travel distance, return -1 (not available)
        if (distance > maxTravelDistance) {
            return -1.0;
        }

        // First 10 miles are free
        int billableDistance = Math.max(0, distance - 10);
        return billableDistance * travelFeePerMile;
    }

    /**
     * Apply discount for repeat customers (if offered)
     * @param price Original price
     * @param isRepeatCustomer Whether the customer has booked before
     * @return Discounted price
     */
    public double applyDiscountIfEligible(double price, boolean isRepeatCustomer) {
        if (offersDiscounts && isRepeatCustomer) {
            return price * 0.90; // 10% discount for repeat customers
        }
        return price;
    }

    // Extended file string format
    @Override
    public String toFileString() {
        // Start with the parent class's implementation
        String baseString = super.toFileString();

        // Append freelance-specific attributes
        return baseString + "," +
                "FREELANCE" + "," +
                providesOwnEquipment + "," +
                travelFeePerMile + "," +
                maxTravelDistance + "," +
                offersDiscounts;
    }

    /**
     * Create FreelancePhotographer from file string
     * @param fileString String representation from file
     * @return FreelancePhotographer object
     */
    public static FreelancePhotographer fromFileString(String fileString) {
        // Split the string into base part and freelance part
        String[] parts = fileString.split(",FREELANCE,");
        if (parts.length < 2) {
            return null; // Not a valid freelance photographer string
        }

        // Parse the base photographer first
        Photographer basePhotographer = Photographer.fromFileString(parts[0]);
        if (basePhotographer == null) {
            return null;
        }

        // Create a new FreelancePhotographer and copy properties from base
        FreelancePhotographer freelancer = new FreelancePhotographer();
        freelancer.setPhotographerId(basePhotographer.getPhotographerId());
        freelancer.setUserId(basePhotographer.getUserId());
        freelancer.setBusinessName(basePhotographer.getBusinessName());
        freelancer.setBiography(basePhotographer.getBiography());
        freelancer.setSpecialties(basePhotographer.getSpecialties());
        freelancer.setLocation(basePhotographer.getLocation());
        freelancer.setBasePrice(basePhotographer.getBasePrice());
        freelancer.setRating(basePhotographer.getRating());
        freelancer.setReviewCount(basePhotographer.getReviewCount());
        freelancer.setVerified(basePhotographer.isVerified());
        freelancer.setContactPhone(basePhotographer.getContactPhone());
        freelancer.setWebsiteUrl(basePhotographer.getWebsiteUrl());
        freelancer.setYearsOfExperience(basePhotographer.getYearsOfExperience());
        freelancer.setEmail(basePhotographer.getEmail());

        // Parse freelance-specific properties
        String[] freelanceParts = parts[1].split(",");
        if (freelanceParts.length >= 4) {
            freelancer.setProvidesOwnEquipment(Boolean.parseBoolean(freelanceParts[0]));
            freelancer.setTravelFeePerMile(Double.parseDouble(freelanceParts[1]));
            freelancer.setMaxTravelDistance(Integer.parseInt(freelanceParts[2]));
            freelancer.setOffersDiscounts(Boolean.parseBoolean(freelanceParts[3]));
        }

        return freelancer;
    }
}