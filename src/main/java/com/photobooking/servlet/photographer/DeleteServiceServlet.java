package com.photobooking.servlet.photographer;

import java.io.IOException;
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
 * Servlet for handling service package deletion
 */
@WebServlet("/photographer/delete-service")
public class DeleteServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DeleteServiceServlet.class.getName());

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
            session.setAttribute("errorMessage", "Only photographers can delete services");
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
            // Get package ID from request
            String packageId = ValidationUtil.cleanInput(request.getParameter("packageId"));
            if (ValidationUtil.isNullOrEmpty(packageId)) {
                session.setAttribute("errorMessage", "Package ID is required");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Get service to verify ownership
            PhotographerServiceManager serviceManager = new PhotographerServiceManager();
            PhotographerService service = serviceManager.getServiceById(packageId);

            if (service == null) {
                session.setAttribute("errorMessage", "Service package not found");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Verify ownership
            if (!service.getPhotographerId().equals(photographerId)) {
                session.setAttribute("errorMessage", "You don't have permission to delete this service");
                response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                return;
            }

            // Check if service has bookings
            if (service.getBookingCount() > 0) {
                // Optional: Instead of disallowing deletion, you could set to inactive instead
                session.setAttribute("warningMessage",
                        "This service has " + service.getBookingCount() +
                                " bookings. Consider setting it to inactive instead of deleting.");
                // Uncomment below to enforce this restriction
                // response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
                // return;
            }

            // Delete the service
            boolean deleteSuccess = serviceManager.deleteService(packageId);

            if (deleteSuccess) {
                session.setAttribute("successMessage", "Service package deleted successfully!");
                LOGGER.info("Service package deleted successfully: " + packageId);
            } else {
                session.setAttribute("errorMessage", "Failed to delete service package");
                LOGGER.warning("Failed to delete service package: " + packageId);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting service: " + e.getMessage(), e);
            session.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/photographer/service_management.jsp");
    }
}
