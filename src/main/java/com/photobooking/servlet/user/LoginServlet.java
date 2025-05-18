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
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling user login in the Event Photography System
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            // User is already logged in, redirect to dashboard
            response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
            return;
        }

        // Forward to the login page
        request.getRequestDispatcher("/user/login.jsp").forward(request, response);
    }

    /**
     * Handles POST requests - process the login form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve login parameters
        String username = ValidationUtil.cleanInput(request.getParameter("username"));
        String password = request.getParameter("password");

        // Validate input
        if (ValidationUtil.isNullOrEmpty(username) || ValidationUtil.isNullOrEmpty(password)) {
            request.setAttribute("errorMessage", "Username and password are required");
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
            return;
        }

        // Create UserManager
        UserManager userManager = new UserManager(getServletContext());

        try {
            // Attempt authentication
            User user = userManager.authenticateUser(username, password);

            if (user != null) {
                // Create a new session
                HttpSession session = request.getSession(true);

                // Store user details in session
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("userType", user.getUserType().name().toLowerCase());

                // If user is a photographer, get and store their photographer profile ID
                if (user.getUserType() == User.UserType.PHOTOGRAPHER) {
                    PhotographerManager photographerManager = new PhotographerManager();
                    Photographer photographer = photographerManager.getPhotographerByUserId(user.getUserId());

                    if (photographer != null) {
                        session.setAttribute("photographerId", photographer.getPhotographerId());
                    }
                }

                // Log successful login
                System.out.println("User logged in successfully: " + username + " (" + user.getUserType() + ")");

                // Redirect based on user type
                switch (user.getUserType()) {
                    case CLIENT:
                        response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
                        break;
                    case PHOTOGRAPHER:
                        response.sendRedirect(request.getContextPath() + "/photographer/dashboard.jsp");
                        break;
                    case ADMIN:
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                        break;
                    default:
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                }
            } else {
                // Authentication failed
                request.setAttribute("errorMessage", "Invalid username or password");
                request.getRequestDispatcher("/user/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // Log any unexpected errors
            System.err.println("Error during user login:");
            e.printStackTrace();

            request.setAttribute("errorMessage", "An unexpected error occurred. Please try again.");
            request.getRequestDispatcher("/user/login.jsp").forward(request, response);
        }
    }

    /**
     * Handles logout requests
     */
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get the current session
        HttpSession session = request.getSession(false);

        // Log logout if user was logged in
        if (session != null && session.getAttribute("username") != null) {
            System.out.println("User logged out: " + session.getAttribute("username"));

            // Invalidate session
            session.invalidate();
        }

        // Redirect to login page
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    }
}