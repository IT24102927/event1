package com.photobooking.model.photographer;

import com.photobooking.util.FileHandler;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Logger;
import java.util.logging.Level;
import javax.servlet.ServletContext;

/**
 * Manages service packages offered by photographers
 */
public class PhotographerServiceManager {
    private static final Logger LOGGER = Logger.getLogger(PhotographerServiceManager.class.getName());
    private static final String SERVICE_FILE = "services.txt";
    private List<PhotographerService> services;
    private ServletContext servletContext;

    /**
     * Constructor initializes the manager and loads services
     */
    public PhotographerServiceManager() {
        this(null);
    }

    /**
     * Constructor with ServletContext
     * @param servletContext the servlet context
     */
    public PhotographerServiceManager(ServletContext servletContext) {
        this.servletContext = servletContext;

        // If servletContext is provided, make sure FileHandler is initialized with it
        if (servletContext != null) {
            FileHandler.setServletContext(servletContext);
        }

        this.services = loadServices();
    }

    /**
     * Load services from file
     * @return List of services
     */
    public List<PhotographerService> loadServices() {
        // Ensure file exists before loading
        FileHandler.ensureFileExists(SERVICE_FILE);

        List<String> lines = FileHandler.readLines(SERVICE_FILE);
        List<PhotographerService> loadedServices = new ArrayList<>();

        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                PhotographerService service = PhotographerService.fromFileString(line);
                if (service != null) {
                    loadedServices.add(service);
                }
            }
        }

        LOGGER.info("Loaded " + loadedServices.size() + " services from file");
        return loadedServices;
    }

    /**
     * Save all services to file
     * @return true if successful, false otherwise
     */
    private boolean saveServices() {
        try {
            // First create a backup of the existing file
            String backupFile = SERVICE_FILE + ".bak";
            if (FileHandler.fileExists(SERVICE_FILE)) {
                FileHandler.copyFile(SERVICE_FILE, backupFile);
            }

            // Delete existing file content
            FileHandler.deleteFile(SERVICE_FILE);

            // Ensure file exists after deletion
            FileHandler.ensureFileExists(SERVICE_FILE);

            // Write all services at once for better performance
            StringBuilder contentToWrite = new StringBuilder();
            for (PhotographerService service : services) {
                contentToWrite.append(service.toFileString()).append(System.lineSeparator());
            }

            // Write all content at once
            boolean result = FileHandler.writeToFile(SERVICE_FILE, contentToWrite.toString(), false);

            if (result) {
                LOGGER.info("Successfully saved " + services.size() + " services to file");
            } else {
                LOGGER.warning("Failed to save services to file");
                // Restore from backup if save failed
                if (FileHandler.fileExists(backupFile)) {
                    FileHandler.copyFile(backupFile, SERVICE_FILE);
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving services: " + e.getMessage(), e);
            return false;
        }
    }

    /**
     * Add a new service
     * @param service The service to add
     * @return true if successful, false otherwise
     */
    public boolean addService(PhotographerService service) {
        if (service == null || service.getPhotographerId() == null) {
            return false;
        }

        services.add(service);
        return saveServices();
    }

    /**
     * Get service by ID
     * @param serviceId The service ID
     * @return The service or null if not found
     */
    public PhotographerService getServiceById(String serviceId) {
        if (serviceId == null) return null;

        return services.stream()
                .filter(s -> s.getServiceId().equals(serviceId))
                .findFirst()
                .orElse(null);
    }

    /**
     * Get services by photographer
     * @param photographerId The photographer ID
     * @return List of services for the photographer
     */
    public List<PhotographerService> getServicesByPhotographer(String photographerId) {
        if (photographerId == null) return new ArrayList<>();

        return services.stream()
                .filter(s -> s.getPhotographerId().equals(photographerId))
                .collect(Collectors.toList());
    }

    /**
     * Get active services by photographer
     * @param photographerId The photographer ID
     * @return List of active services for the photographer
     */
    public List<PhotographerService> getActiveServicesByPhotographer(String photographerId) {
        if (photographerId == null) return new ArrayList<>();

        return services.stream()
                .filter(s -> s.getPhotographerId().equals(photographerId))
                .filter(PhotographerService::isActive)
                .collect(Collectors.toList());
    }

    /**
     * Get services by category
     * @param category The service category
     * @return List of services in the given category
     */
    public List<PhotographerService> getServicesByCategory(String category) {
        if (category == null) return new ArrayList<>();

        return services.stream()
                .filter(s -> s.getCategory().equals(category))
                .filter(PhotographerService::isActive)
                .collect(Collectors.toList());
    }

    /**
     * Update an existing service
     * @param updatedService The updated service
     * @return true if successful, false otherwise
     */
    public boolean updateService(PhotographerService updatedService) {
        if (updatedService == null || updatedService.getServiceId() == null) {
            return false;
        }

        for (int i = 0; i < services.size(); i++) {
            if (services.get(i).getServiceId().equals(updatedService.getServiceId())) {
                services.set(i, updatedService);
                return saveServices();
            }
        }

        return false; // Service not found
    }

    /**
     * Delete a service
     * @param serviceId The service ID
     * @return true if successful, false otherwise
     */
    public boolean deleteService(String serviceId) {
        if (serviceId == null) {
            return false;
        }

        boolean removed = services.removeIf(s -> s.getServiceId().equals(serviceId));
        if (removed) {
            return saveServices();
        }

        return false; // Service not found
    }

    /**
     * Toggle service active status
     * @param serviceId The service ID
     * @return true if successful, false otherwise
     */
    public boolean toggleServiceActiveStatus(String serviceId) {
        if (serviceId == null) {
            return false;
        }

        PhotographerService service = getServiceById(serviceId);
        if (service == null) {
            return false;
        }

        service.setActive(!service.isActive());
        return updateService(service);
    }

    /**
     * Create a default set of services for a new photographer
     * @param photographerId The photographer ID
     * @return true if successful, false otherwise
     */
    public boolean createDefaultServices(String photographerId) {
        if (photographerId == null) {
            return false;
        }

        // Check if photographer already has services
        if (!getServicesByPhotographer(photographerId).isEmpty()) {
            return false; // Photographer already has services
        }

        LOGGER.info("Creating default services for photographer ID: " + photographerId);

        // Create wedding package
        PhotographerService weddingPackage = new PhotographerService(
                photographerId,
                "Silver Wedding Package",
                "Basic wedding coverage with essential services for couples on a budget.",
                1800.00,
                "WEDDING",
                6
        );
        weddingPackage.setPhotographersCount(2);
        weddingPackage.setDeliverables("100+ edited digital images");
        weddingPackage.addFeature("6 hours of coverage");
        weddingPackage.addFeature("Two photographers");
        weddingPackage.addFeature("Online gallery with digital downloads");
        weddingPackage.addFeature("Engagement session (1 hour)");
        weddingPackage.addFeature("100+ edited digital images");
        addService(weddingPackage);

        // Create portrait package
        PhotographerService portraitPackage = new PhotographerService(
                photographerId,
                "Portrait Session",
                "Professional portrait photography session at a location of your choice.",
                350.00,
                "PORTRAIT",
                1
        );
        portraitPackage.setPhotographersCount(1);
        portraitPackage.setDeliverables("25+ edited digital images");
        portraitPackage.addFeature("1-hour session at location of your choice");
        portraitPackage.addFeature("Online gallery with digital downloads");
        portraitPackage.addFeature("25+ edited digital images");
        portraitPackage.addFeature("Print release");
        portraitPackage.addFeature("One outfit change");
        addService(portraitPackage);

        // Create event package
        PhotographerService eventPackage = new PhotographerService(
                photographerId,
                "Corporate Event Coverage",
                "Professional photography coverage for corporate events, conferences, and meetings.",
                800.00,
                "CORPORATE",
                4
        );
        eventPackage.setPhotographersCount(1);
        eventPackage.setDeliverables("100+ edited digital images");
        eventPackage.addFeature("4 hours of coverage");
        eventPackage.addFeature("Online gallery with digital downloads");
        eventPackage.addFeature("100+ edited digital images");
        eventPackage.addFeature("Corporate usage rights");
        eventPackage.addFeature("Quick turnaround (3 business days)");
        addService(eventPackage);

        LOGGER.info("Successfully created default services for photographer ID: " + photographerId);
        return true;
    }

    /**
     * Set ServletContext (can be used to update the context after initialization)
     * @param servletContext the servlet context
     */
    public void setServletContext(ServletContext servletContext) {
        this.servletContext = servletContext;

        // Update FileHandler with the new ServletContext
        FileHandler.setServletContext(servletContext);

        // Reload services with the new file path
        services.clear();
        services = loadServices();
    }
}
