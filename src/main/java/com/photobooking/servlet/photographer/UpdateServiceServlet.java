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
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet for handling service package updates
 */
@WebServlet("/photographer/update-service")
public class UpdateServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(UpdateServiceServlet.class.getName());

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
            session.setAttribute("errorMessage", "Only photographers can update services");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
            return;
        }

        // Get photographer ID from session
        String photographerId = (String) session.getAttribute("photographerId");
        if (photographerId == null) {
            session.setAttribute("errorMessage", "Photographer profile not found");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
            return;
        }

        try {
            // Get form parameters
            String packageId = ValidationUtil.cleanInput(request.getParameter("packageId"));
            if (ValidationUtil.isNullOrEmpty(packageId)) {
                session.setAttribute("errorMessage", "Package ID is required");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            String packageName = ValidationUtil.cleanInput(request.getParameter("packageName"));
            String packageCategory = request.getParameter("packageCategory");
            String packageDescription = ValidationUtil.cleanInput(request.getParameter("packageDescription"));
            String packageDeliverables = ValidationUtil.cleanInput(request.getParameter("packageDeliverables"));
            String packageFeaturesStr = request.getParameter("packageFeatures");
            boolean packageActive = request.getParameter("packageActive") != null;

            // Parse numeric values
            double packagePrice;
            int packageDuration;
            int packagePhotographers;

            try {
                packagePrice = Double.parseDouble(request.getParameter("packagePrice"));
                packageDuration = Integer.parseInt(request.getParameter("packageDuration"));
                packagePhotographers = Integer.parseInt(request.getParameter("packagePhotographers"));
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Invalid numeric values provided");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Validate required fields
            if (ValidationUtil.isNullOrEmpty(packageName) || ValidationUtil.isNullOrEmpty(packageCategory) ||
                    ValidationUtil.isNullOrEmpty(packageDescription) || packagePrice <= 0 || packageDuration <= 0) {
                session.setAttribute("errorMessage", "All required fields must be filled correctly");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Get current service
            PhotographerServiceManager serviceManager = new PhotographerServiceManager();
            PhotographerService service = serviceManager.getServiceById(packageId);

            if (service == null) {
                session.setAttribute("errorMessage", "Service package not found");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Verify ownership
            if (!service.getPhotographerId().equals(photographerId)) {
                session.setAttribute("errorMessage", "You don't have permission to update this service");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Update service properties
            service.setName(packageName);
            service.setCategory(packageCategory);
            service.setDescription(packageDescription);
            service.setPrice(packagePrice);
            service.setDurationHours(packageDuration);
            service.setPhotographersCount(packagePhotographers);
            service.setDeliverables(packageDeliverables);
            service.setActive(packageActive);

            // Process features
            List<String> features = new ArrayList<>();
            if (!ValidationUtil.isNullOrEmpty(packageFeaturesStr)) {
                String[] featuresArray = packageFeaturesStr.split("\\r?\\n");
                for (String feature : featuresArray) {
                    if (!feature.trim().isEmpty()) {
                        features.add(feature.trim());
                    }
                }
            }
            service.setFeatures(features);

            // Save updated service
            boolean updateSuccess = serviceManager.updateService(service);

            if (updateSuccess) {
                session.setAttribute("successMessage", "Service package updated successfully!");
                LOGGER.info("Service package updated successfully: " + packageId);
            } else {
                session.setAttribute("errorMessage", "Failed to update service package");
                LOGGER.warning("Failed to update service package: " + packageId);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating service: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
    }
}
