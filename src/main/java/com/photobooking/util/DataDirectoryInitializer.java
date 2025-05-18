package com.photobooking.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.File;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Initializes the data directory structure when the application starts
 */
@WebListener
public class DataDirectoryInitializer implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(DataDirectoryInitializer.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            LOGGER.info("Initializing data directory structure");

            // Set the ServletContext in FileHandler
            FileHandler.setServletContext(sce.getServletContext());

            // Create required files
            String[] requiredFiles = {
                    "users.txt",
                    "photographers.txt",
                    "services.txt",
                    "bookings.txt",
                    "reviews.txt",
                    "unavailable_dates.txt"
            };

            for (String file : requiredFiles) {
                boolean created = FileHandler.ensureFileExists(file);
                if (created) {
                    LOGGER.info("Created file: " + file);
                } else {
                    LOGGER.info("File already exists: " + file);
                }
            }

            LOGGER.info("Data directory structure initialized successfully");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error initializing data directory structure", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Cleanup code if needed
    }
}
