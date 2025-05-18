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
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling user profile updates in the Event Photography System
 */
@WebServlet("/update-profile")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles GET requests - display the update profile form
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            // Not logged in, redirect to login
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Get user ID from session
        String userId = (String) session.getAttribute("userId");

        // Create UserManager and get user
        UserManager userManager = new UserManager(getServletContext());
        User user = userManager.getUserById(userId);

        if (user == null) {
            // User not found (should not happen normally)
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Add user to request attributes
        request.setAttribute("user", user);

        // Forward to update profile page
        request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
    }

    /**
     * Handles POST requests - process the update profile form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if user is logged in
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            // Not logged in, redirect to login
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Get user ID from session
        String userId = (String) session.getAttribute("userId");

        // Create UserManager and get user
        UserManager userManager = new UserManager(getServletContext());
        User user = userManager.getUserById(userId);

        if (user == null) {
            // User not found (should not happen normally)
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Retrieve form parameters
        String email = ValidationUtil.cleanInput(request.getParameter("email"));
        String fullName = ValidationUtil.cleanInput(request.getParameter("fullName"));
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate email and full name
        if (ValidationUtil.isNullOrEmpty(email) || ValidationUtil.isNullOrEmpty(fullName)) {
            request.setAttribute("errorMessage", "Email and Full Name are required");
            request.setAttribute("user", user);
            request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (!ValidationUtil.isValidEmail(email)) {
            request.setAttribute("errorMessage", "Invalid email format");
            request.setAttribute("user", user);
            request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
            return;
        }

        // Check current password if changing password
        if (!ValidationUtil.isNullOrEmpty(newPassword)) {
            // Verify current password
            if (ValidationUtil.isNullOrEmpty(currentPassword) || !user.authenticate(currentPassword)) {
                request.setAttribute("errorMessage", "Current password is incorrect");
                request.setAttribute("user", user);
                request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
                return;
            }

            // Validate new password
            if (!ValidationUtil.isValidPassword(newPassword)) {
                request.setAttribute("errorMessage", "Invalid new password format");
                request.setAttribute("user", user);
                request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
                return;
            }

            // Confirm new password
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "New passwords do not match");
                request.setAttribute("user", user);
                request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
                return;
            }

            // Update password
            user.setPassword(newPassword);
        }

        // Update email and full name
        user.setEmail(email);
        user.setFullName(fullName);

        // Save updated user
        boolean updateSuccess = userManager.updateUser(user);

        if (updateSuccess) {
            // Update session with new user data
            session.setAttribute("user", user);
            session.setAttribute("username", user.getUsername());

            // Set success message
            session.setAttribute("successMessage", "Profile updated successfully!");

            // Redirect to profile page
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
        } else {
            // Update failed
            request.setAttribute("errorMessage", "Failed to update profile. Please try again.");
            request.setAttribute("user", user);
            request.getRequestDispatcher("/user/update-profile.jsp").forward(request, response);
        }
    }
}