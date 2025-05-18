package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.model.photographer.PhotographerService;
import com.photobooking.model.photographer.PhotographerServiceManager;
import com.photobooking.model.user.User;
import com.photobooking.util.FileHandler;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for displaying photographer service management dashboard
 */
@WebServlet("/photographer/service-management")
public class ServiceManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(ServiceManagementServlet.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();
        // Initialize necessary data directories and files
        FileHandler.setServletContext(getServletContext());
        FileHandler.createDirectory("data");
        FileHandler.ensureFileExists("photographers.txt");
        FileHandler.ensureFileExists("services.txt");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a photographer
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            session.setAttribute("errorMessage", "Access denied");
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        // Debug logging
        LOGGER.info("ServiceManagementServlet doGet - UserId: " + currentUser.getUserId());

        // Get photographer ID from session or from database
        String photographerId = (String) session.getAttribute("photographerId");
        LOGGER.info("ServiceManagementServlet doGet - Session photographerId: " + photographerId);

        // If photographerId is not in session, try to get it from the database
        if (photographerId == null) {
            try {
                PhotographerManager photographerManager = new PhotographerManager(getServletContext());
                Photographer photographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

                if (photographer != null) {
                    // Set photographerId in session for future use
                    photographerId = photographer.getPhotographerId();
                    session.setAttribute("photographerId", photographerId);
                    LOGGER.info("Retrieved photographer ID for user: " + currentUser.getUsername() + ", ID: " + photographerId);
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
                        LOGGER.info("Created missing photographer profile for user: " + currentUser.getUsername() + ", ID: " + photographerId);

                        // Create default services for the photographer
                        try {
                            PhotographerServiceManager serviceManager = new PhotographerServiceManager(getServletContext());
                            serviceManager.createDefaultServices(photographerId);
                            LOGGER.info("Created default services for new photographer profile");
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

        // Double-check if we have a photographerId at this point
        if (photographerId == null) {
            LOGGER.severe("Failed to obtain photographerId after all attempts");
            session.setAttribute("errorMessage", "System error: Could not determine photographer ID");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
            return;
        }

        // Get photographer services
        try {
            PhotographerServiceManager serviceManager = new PhotographerServiceManager(getServletContext());

            // Debug: Load all services first to see what's available
            List<PhotographerService> allServices = serviceManager.loadServices();
            LOGGER.info("Total services loaded: " + allServices.size());
            for (PhotographerService service : allServices) {
                LOGGER.info("Service: ID=" + service.getServiceId() + ", Name=" + service.getName() + ", PhotographerId=" + service.getPhotographerId());
            }

            // Now get services specific to this photographer
            List<PhotographerService> services = serviceManager.getServicesByPhotographer(photographerId);
            LOGGER.info("Services found for photographerId " + photographerId + ": " + services.size());

            // Set attributes for JSP
            request.setAttribute("services", services);

            // Add additional debug information for JSP
            request.setAttribute("debugInfo", "PhotographerId: " + photographerId + ", Services found: " + services.size());

            request.getRequestDispatcher("/photographer/service_management.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading services: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "Error loading services: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
        }
    }
}
