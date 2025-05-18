package com.photobooking.util;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.logging.Logger;

/**
 * Application context listener to initialize system components
 */
@WebListener
public class ApplicationContextListener implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(ApplicationContextListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        LOGGER.info("Application context initialized. Configuring file system...");

        // Initialize FileHandler with ServletContext
        FileHandler.setServletContext(context);

        LOGGER.info("File system configured successfully.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("Application context destroyed");
    }
}