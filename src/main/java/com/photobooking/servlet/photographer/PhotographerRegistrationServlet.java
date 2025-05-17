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

import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.model.photographer.PhotographerServiceManager;
import com.photobooking.model.user.User;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling photographer registration and profile creation
 */
@WebServlet("/photographer/register")
public class PhotographerRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles GET requests - display registration form
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is already registered as a photographer
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer existingPhotographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

        if (existingPhotographer != null) {
            // Already registered, redirect to dashboard
            session.setAttribute("infoMessage", "You are already registered as a photographer");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard");
            return;
        }

        // Forward to registration form
        request.getRequestDispatcher("/photographer/register.jsp").forward(request, response);
    }

    /**
     * Handles POST requests - process registration form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");

        // Check if user is already registered as a photographer
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer existingPhotographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

        if (existingPhotographer != null) {
            // Already registered, redirect to dashboard
            session.setAttribute("infoMessage", "You are already registered as a photographer");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard");
            return;
        }

        // Get form parameters
        String businessName = ValidationUtil.cleanInput(request.getParameter("businessName"));
        String biography = ValidationUtil.cleanInput(request.getParameter("biography"));
        String location = ValidationUtil.cleanInput(request.getParameter("location"));
        String[] specialtiesArray = request.getParameterValues("specialties");
        String basePriceStr = request.getParameter("basePrice");
        String yearsOfExperienceStr = request.getParameter("yearsOfExperience");
        String contactPhone = ValidationUtil.cleanInput(request.getParameter("contactPhone"));
        String websiteUrl = ValidationUtil.cleanInput(request.getParameter("websiteUrl"));
        String photographerType = request.getParameter("photographerType");

        // Validate input
        if (ValidationUtil.isNullOrEmpty(businessName) ||
                ValidationUtil.isNullOrEmpty(biography) ||
                ValidationUtil.isNullOrEmpty(location) ||
                specialtiesArray == null || specialtiesArray.length == 0 ||
                ValidationUtil.isNullOrEmpty(basePriceStr) ||
                ValidationUtil.isNullOrEmpty(photographerType)) {

            request.setAttribute("errorMessage", "All required fields must be filled");
            request.getRequestDispatcher("/photographer/register.jsp").forward(request, response);
            return;
        }

        // Parse numeric values
        double basePrice;
        int yearsOfExperience;

        try {
            basePrice = Double.parseDouble(basePriceStr);
            if (basePrice <= 0) {
                request.setAttribute("errorMessage", "Base price must be positive");
                request.getRequestDispatcher("/photographer/register.jsp").forward(request, response);
                return;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid base price");
            request.getRequestDispatcher("/photographer/register.jsp").forward(request, response);
            return;
        }

        try {
            yearsOfExperience = ValidationUtil.isNullOrEmpty(yearsOfExperienceStr) ?
                    0 : Integer.parseInt(yearsOfExperienceStr);
            if (yearsOfExperience < 0) {
                yearsOfExperience = 0;
            }
        } catch (NumberFormatException e) {
            yearsOfExperience = 0;
        }

        // Create specialties list
        List<String> specialtiesList = Arrays.asList(specialtiesArray);

        // Create new photographer profile
        Photographer newPhotographer = photographerManager.createPhotographerProfile(
                currentUser.getUserId(),
                businessName,
                biography,
                specialtiesList,
                location,
                basePrice,
                photographerType,
                currentUser.getEmail()
        );

        if (newPhotographer == null) {
            request.setAttribute("errorMessage", "Failed to create photographer profile");
            request.getRequestDispatcher("/photographer/register.jsp").forward(request, response);
            return;
        }

        // Set additional properties
        newPhotographer.setYearsOfExperience(yearsOfExperience);
        newPhotographer.setContactPhone(contactPhone);
        newPhotographer.setWebsiteUrl(websiteUrl);

        // Update the photographer
        boolean updateSuccess = photographerManager.updatePhotographer(newPhotographer);

        if (!updateSuccess) {
            request.setAttribute("errorMessage", "Failed to update photographer profile");
            request.getRequestDispatcher("/photographer/register.jsp").forward(request, response);
            return;
        }

        // Create default services
        PhotographerServiceManager serviceManager = new PhotographerServiceManager();
        serviceManager.createDefaultServices(newPhotographer.getPhotographerId());

        // Set success message and redirect to dashboard
        session.setAttribute("successMessage", "Photographer profile created successfully!");
        response.sendRedirect(request.getContextPath() + "/photographer/dashboard");
    }
}
