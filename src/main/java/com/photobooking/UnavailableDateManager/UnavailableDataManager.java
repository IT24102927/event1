package com.photobooking.model.photographer;

import com.photobooking.util.FileHandler;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.stream.Collectors;

/**
 * Manages photographer unavailable dates
 */
public class UnavailableDateManager {
    private static final Logger LOGGER = Logger.getLogger(UnavailableDateManager.class.getName());
    private static final String UNAVAILABLE_DATES_FILE = "unavailable_dates.txt";
    private List<UnavailableDate> unavailableDates;

    public UnavailableDateManager() {
        this.unavailableDates = loadUnavailableDates();
    }

    /**
     * Load unavailable dates from file
     * @return List of unavailable dates
     */
    private List<UnavailableDate> loadUnavailableDates() {
        try {
            // Ensure file exists
            FileHandler.ensureFileExists(UNAVAILABLE_DATES_FILE);

            // Read lines from file
            List<String> lines = FileHandler.readLines(UNAVAILABLE_DATES_FILE);
            List<UnavailableDate> dates = new ArrayList<>();

            for (String line : lines) {
                if (!line.trim().isEmpty()) {
                    try {
                        UnavailableDate date = UnavailableDate.fromFileString(line);
                        if (date != null) {
                            dates.add(date);
                        }
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "Error parsing unavailable date: " + line, e);
                    }
                }
            }

            LOGGER.info("Loaded " + dates.size() + " unavailable dates");
            return dates;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading unavailable dates", e);
            return new ArrayList<>();
        }
    }

    /**
     * Save unavailable dates to file
     * @return true if save was successful, false otherwise
     */
    private boolean saveUnavailableDates() {
        try {
            // Delete existing file
            FileHandler.deleteFile(UNAVAILABLE_DATES_FILE);

            // Write each unavailable date
            for (UnavailableDate date : unavailableDates) {
                FileHandler.appendLine(UNAVAILABLE_DATES_FILE, date.toFileString());
            }
            LOGGER.info("Successfully saved " + unavailableDates.size() + " unavailable dates");
            return true;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving unavailable dates", e);
            return false;
        }
    }

    /**
     * Add a new unavailable date
     * @param date UnavailableDate to add
     * @return true if added successfully, false otherwise
     */
    public boolean addUnavailableDate(UnavailableDate date) {
        // Check for duplicates
        boolean exists = unavailableDates.stream()
                .anyMatch(existingDate ->
                        existingDate.getPhotographerId().equals(date.getPhotographerId()) &&
                                existingDate.getDate().equals(date.getDate()) &&
                                existingDate.isAllDay() == date.isAllDay()
                );

        if (exists) {
            LOGGER.info("Duplicate unavailable date not added");
            return false;
        }

        unavailableDates.add(date);
        return saveUnavailableDates();
    }

    /**
     * Get all unavailable dates for a photographer
     * @param photographerId Photographer's ID
     * @return List of unavailable dates
     */
    public List<UnavailableDate> getUnavailableDatesForPhotographer(String photographerId) {
        return unavailableDates.stream()
                .filter(date -> date.getPhotographerId().equals(photographerId))
                .collect(Collectors.toList());
    }

    /**
     * Remove an unavailable date by its ID
     * @param dateId ID of the unavailable date to remove
     * @return true if removed successfully, false otherwise
     */
    public boolean removeUnavailableDate(String dateId) {
        boolean removed = unavailableDates.removeIf(date -> date.getId().equals(dateId));

        if (removed) {
            return saveUnavailableDates();
        }

        return false;
    }

    /**
     * Check if a date is unavailable for a photographer
     * @param photographerId Photographer's ID
     * @param date Date to check
     * @return true if date is unavailable, false otherwise
     */
    public boolean isDateUnavailable(String photographerId, LocalDate date) {
        return unavailableDates.stream()
                .anyMatch(ud ->
                        ud.getPhotographerId().equals(photographerId) &&
                                ud.getDate().equals(date) &&
                                ud.isAllDay()
                );
    }
}