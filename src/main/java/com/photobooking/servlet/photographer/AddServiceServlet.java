package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.photographer.PhotographerService;
import com.photobooking.model.photographer.PhotographerServiceManager;
import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;
import com.photobooking.util.FileHandler;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for adding new service packages
 */
@WebServlet("/photographer/add-service")
public class AddServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AddServiceServlet.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();
        // Initialize necessary data directories and files
        FileHandler.createDirectory("data");
        FileHandler.ensureFileExists("photographers.txt");
        FileHandler.ensureFileExists("services.txt");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a photographer
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            session.setAttribute("errorMessage", "Only photographers can add services");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
            return;
        }

        // Get photographer ID from session
        String photographerId = (String) session.getAttribute("photographerId");

        // If photographerId is not in session, try to get it from the database
        if (photographerId == null) {
            try {
                PhotographerManager photographerManager = new PhotographerManager();
                Photographer photographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

                if (photographer != null) {
                    // Set photographerId in session for future use
                    photographerId = photographer.getPhotographerId();
                    session.setAttribute("photographerId", photographerId);
                    LOGGER.info("Retrieved photographer ID for user: " + currentUser.getUsername());
                } else {
                    // Create a new photographer profile if one doesn't exist
                    photographer = new Photographer();
                    photographer.setUserId(currentUser.getUserId());
                    photographer.setBusinessName(currentUser.getFullName() + "'s Photography");
                    photographer.setBiography("Professional photographer offering various photography services.");
                    photographer.setSpecialties(new ArrayList<>());
                    photographer.getSpecialties().add("General");
                    photographer.setLocation("Not specified");
                    photographer.setBasePrice(100.0); // Default base price
                    photographer.setEmail(currentUser.getEmail());

                    // Add photographer to database
                    boolean profileCreated = photographerManager.addPhotographer(photographer);

                    if (profileCreated) {
                        photographerId = photographer.getPhotographerId();
                        session.setAttribute("photographerId", photographerId);
                        LOGGER.info("Created missing photographer profile for user: " + currentUser.getUsername());

                        // Create default services
                        try {
                            PhotographerServiceManager serviceManager = new PhotographerServiceManager();
                            serviceManager.createDefaultServices(photographerId);
                        } catch (Exception e) {
                            LOGGER.log(Level.WARNING, "Error creating default services: " + e.getMessage(), e);
                        }
                    } else {
                        session.setAttribute("errorMessage", "Failed to create photographer profile. Please contact support.");
                        response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
                        return;
                    }
                }
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error retrieving/creating photographer profile: " + e.getMessage(), e);
                session.setAttribute("errorMessage", "Error processing photographer profile: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
                return;
            }
        }

        try {
            // Get form parameters
            String packageName = ValidationUtil.cleanInput(request.getParameter("packageName"));
            String packageCategory = request.getParameter("packageCategory");
            String packageDescription = ValidationUtil.cleanInput(request.getParameter("packageDescription"));
            double packagePrice = Double.parseDouble(request.getParameter("packagePrice"));
            int packageDuration = Integer.parseInt(request.getParameter("packageDuration"));
            int packagePhotographers = Integer.parseInt(request.getParameter("packagePhotographers"));
            String packageFeatures = request.getParameter("packageFeatures");
            String packageDeliverables = ValidationUtil.cleanInput(request.getParameter("packageDeliverables"));
            boolean packageActive = request.getParameter("packageActive") != null;

            // Validate required fields
            if (ValidationUtil.isNullOrEmpty(packageName) || ValidationUtil.isNullOrEmpty(packageCategory) ||
                    ValidationUtil.isNullOrEmpty(packageDescription) || packagePrice <= 0 || packageDuration <= 0) {
                session.setAttribute("errorMessage", "All required fields must be filled correctly");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Create new service
            PhotographerService newService = new PhotographerService(
                    photographerId,
                    packageName,
                    packageDescription,
                    packagePrice,
                    packageCategory,
                    packageDuration
            );

            newService.setPhotographersCount(packagePhotographers);
            newService.setDeliverables(packageDeliverables);
            newService.setActive(packageActive);

            // Parse features
            if (!ValidationUtil.isNullOrEmpty(packageFeatures)) {
                String[] features = packageFeatures.trim().split("\n");
                for (String feature : features) {
                    if (!feature.trim().isEmpty()) {
                        newService.addFeature(feature.trim());
                    }
                }
            }

            // Save service
            PhotographerServiceManager serviceManager = new PhotographerServiceManager();
            if (serviceManager.addService(newService)) {
                session.setAttribute("successMessage", "Service package added successfully!");
                LOGGER.info("Service package added successfully for photographer ID: " + photographerId);
            } else {
                session.setAttribute("errorMessage", "Failed to add service package");
                LOGGER.warning("Failed to add service package for photographer ID: " + photographerId);
            }

        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid price or duration format: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "Invalid price or duration format: Please enter valid numbers.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error adding service: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
    }
}