package com.photobooking.model.photographer;

import com.photobooking.util.FileHandler;
import com.photobooking.util.EnhancedSortingUtility;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Logger;
import java.util.logging.Level;
import javax.servlet.ServletContext;

/**
 * Manages photographer-related operations for the Event Photography System
 * Updated to use the enhanced bubble sort implementation
 */
public class PhotographerManager {
    private static final Logger LOGGER = Logger.getLogger(PhotographerManager.class.getName());
    private static final String PHOTOGRAPHER_FILE = "photographers.txt";
    private List<Photographer> photographers;
    private ServletContext servletContext;

    /**
     * Constructor initializes the manager and loads photographers
     */
    public PhotographerManager() {
        this(null);
    }

    /**
     * Constructor with ServletContext
     * @param servletContext the servlet context
     */
    public PhotographerManager(ServletContext servletContext) {
        this.servletContext = servletContext;

        // If servletContext is provided, make sure FileHandler is initialized with it
        if (servletContext != null) {
            FileHandler.setServletContext(servletContext);
        }

        this.photographers = loadPhotographers();
    }

    /**
     * Load photographers from file
     * @return List of photographers
     */
    private List<Photographer> loadPhotographers() {
        // Ensure file exists before loading
        FileHandler.ensureFileExists(PHOTOGRAPHER_FILE);

        List<String> lines = FileHandler.readLines(PHOTOGRAPHER_FILE);
        List<Photographer> loadedPhotographers = new ArrayList<>();

        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                // Determine the type of photographer based on the line content
                Photographer photographer = null;

                if (line.contains("FREELANCE,")) {
                    photographer = FreelancePhotographer.fromFileString(line);
                } else {
                    photographer = Photographer.fromFileString(line);
                }

                if (photographer != null) {
                    loadedPhotographers.add(photographer);
                }
            }
        }

        LOGGER.info("Loaded " + loadedPhotographers.size() + " photographers from file");
        return loadedPhotographers;
    }

    /**
     * Save all photographers to file
     * @return true if successful, false otherwise
     */
    private boolean savePhotographers() {
        try {
            // First create a backup of the existing file
            String backupFile = PHOTOGRAPHER_FILE + ".bak";
            if (FileHandler.fileExists(PHOTOGRAPHER_FILE)) {
                FileHandler.copyFile(PHOTOGRAPHER_FILE, backupFile);
            }

            // Delete existing file content
            FileHandler.deleteFile(PHOTOGRAPHER_FILE);

            // Ensure file exists after deletion
            FileHandler.ensureFileExists(PHOTOGRAPHER_FILE);

            // Write all content at once
            StringBuilder contentToWrite = new StringBuilder();
            for (Photographer photographer : photographers) {
                contentToWrite.append(photographer.toFileString()).append(System.lineSeparator());
            }

            boolean result = FileHandler.writeToFile(PHOTOGRAPHER_FILE, contentToWrite.toString(), false);

            if (result) {
                LOGGER.info("Successfully saved " + photographers.size() + " photographers to file");
            } else {
                LOGGER.warning("Failed to save photographers to file");
                // Restore from backup if save failed
                if (FileHandler.fileExists(backupFile)) {
                    FileHandler.copyFile(backupFile, PHOTOGRAPHER_FILE);
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving photographers: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Add a new photographer
     * @param photographer The photographer to add
     * @return true if successful, false otherwise
     */
    public boolean addPhotographer(Photographer photographer) {
        if (photographer == null || photographer.getUserId() == null) {
            return false;
        }

        // Check if photographer with same user ID already exists
        if (getPhotographerByUserId(photographer.getUserId()) != null) {
            return false; // Photographer already exists
        }

        photographers.add(photographer);
        return savePhotographers();
    }

    /**
     * Get photographer by ID
     * @param photographerId The photographer ID
     * @return The photographer or null if not found
     */
    public Photographer getPhotographerById(String photographerId) {
        if (photographerId == null) return null;

        return photographers.stream()
                .filter(p -> p.getPhotographerId().equals(photographerId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get photographer by user ID
     * @param userId The user ID
     * @return The photographer or null if not found
     */
    public Photographer getPhotographerByUserId(String userId) {
        if (userId == null) return null;

        return photographers.stream()
                .filter(p -> p.getUserId().equals(userId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Update an existing photographer
     * @param updatedPhotographer The updated photographer
     * @return true if successful, false otherwise
     */
    public boolean updatePhotographer(Photographer updatedPhotographer) {
        if (updatedPhotographer == null || updatedPhotographer.getPhotographerId() == null) {
            return false;
        }

        for (int i = 0; i < photographers.size(); i++) {
            if (photographers.get(i).getPhotographerId().equals(updatedPhotographer.getPhotographerId())) {
                photographers.set(i, updatedPhotographer);
                return savePhotographers();
            }
        }

        return false; // Photographer not found
    }

    /**
     * Delete a photographer
     * @param photographerId The photographer ID
     * @return true if successful, false otherwise
     */
    public boolean deletePhotographer(String photographerId) {
        if (photographerId == null) {
            return false;
        }

        boolean removed = photographers.removeIf(p -> p.getPhotographerId().equals(photographerId));
        if (removed) {
            return savePhotographers();
        }

        return false; // Photographer not found
    }

    /**
     * Get all photographers
     * @return List of all photographers
     */
    public List<Photographer> getAllPhotographers() {
        return new ArrayList<>(photographers);
    }

    /**
     * Get photographers by specialty
     * @param specialty The specialty to filter by
     * @return List of photographers with the given specialty
     */
    public List<Photographer> getPhotographersBySpecialty(String specialty) {
        if (specialty == null) return new ArrayList<>();

        return photographers.stream()
                .filter(p -> p.getSpecialties().contains(specialty))
                .collect(Collectors.toList());
    }

    /**
     * Get photographers by location
     * @param location The location to filter by
     * @return List of photographers in the given location
     */
    public List<Photographer> getPhotographersByLocation(String location) {
        if (location == null) return new ArrayList<>();

        return photographers.stream()
                .filter(p -> p.getLocation() != null && p.getLocation().toLowerCase().contains(location.toLowerCase()))
                .collect(Collectors.toList());
    }

    /**
     * Sort photographers by rating using enhanced bubble sort
     * @param photographerList List of photographers to sort
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public List<Photographer> sortPhotographersByRating(List<Photographer> photographerList, boolean ascending) {
        // Use the enhanced bubble sort implementation
        return EnhancedSortingUtility.bubbleSortByRating(photographerList, ascending);
    }

    /**
     * Search photographers by keyword (in name, biography, or specialties)
     * @param keyword The keyword to search for
     * @return List of photographers matching the keyword
     */
    public List<Photographer> searchPhotographers(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>(photographers);
        }

        String searchTerm = keyword.toLowerCase().trim();

        return photographers.stream()
                .filter(p -> {
                    // Search in business name
                    if (p.getBusinessName() != null &&
                            p.getBusinessName().toLowerCase().contains(searchTerm)) {
                        return true;
                    }

                    // Search in biography
                    if (p.getBiography() != null &&
                            p.getBiography().toLowerCase().contains(searchTerm)) {
                        return true;
                    }

                    // Search in specialties
                    for (String specialty : p.getSpecialties()) {
                        if (specialty.toLowerCase().contains(searchTerm)) {
                            return true;
                        }
                    }

                    // Search in location
                    if (p.getLocation() != null &&
                            p.getLocation().toLowerCase().contains(searchTerm)) {
                        return true;
                    }

                    return false;
                })
                .collect(Collectors.toList());
    }

    /**
     * Sort photographers by price using enhanced bubble sort
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public List<Photographer> sortPhotographersByPrice(boolean ascending) {
        // Use the enhanced bubble sort implementation
        return EnhancedSortingUtility.bubbleSortByPrice(photographers, ascending);
    }

    /**
     * Sort photographers by experience using enhanced bubble sort with generic implementation
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public List<Photographer> sortPhotographersByExperience(boolean ascending) {
        // Create a comparator for years of experience
        Comparator<Photographer> comparator = (p1, p2) -> {
            if (ascending) {
                return Integer.compare(p1.getYearsOfExperience(), p2.getYearsOfExperience());
            } else {
                return Integer.compare(p2.getYearsOfExperience(), p1.getYearsOfExperience());
            }
        };

        // Use the generic bubble sort implementation
        return EnhancedSortingUtility.bubbleSort(photographers, comparator);
    }

    /**
     * Sort photographers by name using enhanced bubble sort
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public List<Photographer> sortPhotographersByName(boolean ascending) {
        // Use the enhanced bubble sort implementation for names
        return EnhancedSortingUtility.bubbleSortByName(photographers, ascending);
    }

    /**
     * Create a new photographer profile for a user
     * @param userId User ID
     * @param businessName Business name
     * @param biography Biography
     * @param specialtiesList List of specialties
     * @param location Location
     * @param basePrice Base price
     * @param photographerType Type of photographer (freelance or other)
     * @return The created photographer, or null if creation failed
     */
    public Photographer createPhotographerProfile(String userId, String businessName, String biography,
                                                  List<String> specialtiesList, String location,
                                                  double basePrice, String photographerType,
                                                  String email) {
        if (userId == null || photographerType == null) {
            return null;
        }

        Photographer photographer;

        if ("freelance".equalsIgnoreCase(photographerType)) {
            photographer = new FreelancePhotographer(userId, businessName, biography,
                    specialtiesList, location, basePrice);
        } else {
            photographer = new Photographer(userId, businessName, biography,
                    specialtiesList, location, basePrice);
        }

        photographer.setEmail(email);

        if (addPhotographer(photographer)) {
            return photographer;
        } else {
            return null;
        }
    }

    /**
     * Set ServletContext (can be used to update the context after initialization)
     * @param servletContext the servlet context
     */
    public void setServletContext(ServletContext servletContext) {
        this.servletContext = servletContext;

        // Update FileHandler with the new ServletContext
        FileHandler.setServletContext(servletContext);

        // Reload photographers with the new file path
        photographers.clear();
        photographers = loadPhotographers();
    }
}