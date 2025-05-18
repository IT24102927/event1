package com.photobooking.servlet.user;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.user.User;
import com.photobooking.model.user.UserManager;
import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.model.photographer.PhotographerServiceManager;
import com.photobooking.util.ValidationUtil;
import com.photobooking.util.FileHandler;
import java.util.ArrayList;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 * Servlet implementation for user registration
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();
        // Initialize data directory and files
        FileHandler.createDirectory("data");
        FileHandler.ensureFileExists("users.txt");
        FileHandler.ensureFileExists("photographers.txt");
        FileHandler.ensureFileExists("services.txt");
    }

    /**
     * Handles GET requests - display registration page
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // Redirect to dashboard based on user type
            User user = (User) session.getAttribute("user");
            switch (user.getUserType()) {
                case CLIENT:
                    response.sendRedirect(request.getContextPath() + "/client/dashboard.jsp");
                    break;
                case PHOTOGRAPHER:
                    response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
                    break;
                case ADMIN:
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                    break;
            }
            return;
        }

        // Forward to registration page
        request.getRequestDispatcher("/user/register.jsp").forward(request, response);
    }

    /**
     * Handles POST requests - process registration form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve form parameters
        String fullName = ValidationUtil.cleanInput(request.getParameter("fullName"));
        String username = ValidationUtil.cleanInput(request.getParameter("username"));
        String email = ValidationUtil.cleanInput(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String userTypeStr = request.getParameter("userType");

        // Validate input
        if (ValidationUtil.isNullOrEmpty(fullName) ||
                ValidationUtil.isNullOrEmpty(username) ||
                ValidationUtil.isNullOrEmpty(email) ||
                ValidationUtil.isNullOrEmpty(password) ||
                ValidationUtil.isNullOrEmpty(userTypeStr)) {

            request.setAttribute("errorMessage", "All fields are required");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        // Validate full name
        if (!ValidationUtil.isValidFullName(fullName)) {
            request.setAttribute("errorMessage", "Invalid full name format");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        // Validate username
        if (!ValidationUtil.isValidUsername(username)) {
            request.setAttribute("errorMessage", "Invalid username format");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        // Validate email
        if (!ValidationUtil.isValidEmail(email)) {
            request.setAttribute("errorMessage", "Invalid email format");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        // Validate password
        if (!ValidationUtil.isValidPassword(password)) {
            request.setAttribute("errorMessage", "Password does not meet requirements");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        // Check password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        // Create UserManager
        UserManager userManager = new UserManager(getServletContext());

        // Check if username already exists
        if (userManager.getUserByUsername(username) != null) {
            request.setAttribute("errorMessage", "Username already exists");
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            return;
        }

        try {
            // Determine user type
            User.UserType userType;
            try {
                userType = User.UserType.valueOf(userTypeStr.toUpperCase());
            } catch (IllegalArgumentException e) {
                request.setAttribute("errorMessage", "Invalid user type");
                request.getRequestDispatcher("/user/register.jsp").forward(request, response);
                return;
            }

            // Create new user
            User newUser = new User(username, password, email, fullName, userType);

            // Attempt to add user
            boolean registrationSuccess = userManager.addUser(newUser);

            if (registrationSuccess) {
                // If user is a photographer, create basic photographer profile
                if (userType == User.UserType.PHOTOGRAPHER) {
                    try {
                        // Ensure photographers.txt file exists
                        FileHandler.ensureFileExists("photographers.txt");

                        PhotographerManager photographerManager = new PhotographerManager();

                        // Create a simple photographer profile with default values
                        Photographer photographer = new Photographer();
                        photographer.setUserId(newUser.getUserId());
                        photographer.setBusinessName(fullName + "'s Photography");
                        photographer.setBiography("Professional photographer offering various photography services.");
                        photographer.setSpecialties(new ArrayList<>());
                        photographer.getSpecialties().add("General");
                        photographer.setLocation("Not specified");
                        photographer.setBasePrice(100.0); // Default base price
                        photographer.setEmail(email);

                        // Save the photographer profile
                        boolean photographerProfileCreated = photographerManager.addPhotographer(photographer);

                        if (photographerProfileCreated) {
                            // Log the creation of photographer profile
                            LOGGER.info("Photographer profile created for user: " + username);

                            // Create default services for the photographer
                            try {
                                // Ensure services.txt file exists
                                FileHandler.ensureFileExists("services.txt");

                                PhotographerServiceManager serviceManager = new PhotographerServiceManager();
                                serviceManager.createDefaultServices(photographer.getPhotographerId());
                                LOGGER.info("Default services created for photographer: " + username);
                            } catch (Exception e) {
                                LOGGER.log(Level.WARNING, "Error creating default services: " + e.getMessage(), e);
                            }
                        } else {
                            // Log the failure
                            LOGGER.log(Level.WARNING, "Failed to create photographer profile for user: " + username);
                        }
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "Error during photographer profile creation: " + e.getMessage(), e);
                    }
                }

                // Log successful registration
                LOGGER.info("User registered successfully: " + username + " (" + userType + ")");

                // Create session and add success message
                HttpSession session = request.getSession(true);
                session.setAttribute("successMessage", "Registration successful! Please log in.");

                // Redirect to login page
                response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            } else {
                // Registration failed
                request.setAttribute("errorMessage", "Registration failed. Please try again.");
                request.getRequestDispatcher("/user/register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // Log any unexpected errors
            LOGGER.log(Level.SEVERE, "Error during user registration: " + e.getMessage(), e);

            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("/user/register.jsp").forward(request, response);
        }
    }
}
