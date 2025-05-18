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

/**
 * Servlet for handling user account deletion in the Event Photography System
 */
@WebServlet("/delete-account")
public class DeleteUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles GET requests - display the delete account confirmation page
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

        // Forward to the delete confirmation page
        request.getRequestDispatcher("/user/delete-account.jsp").forward(request, response);
    }

    /**
     * Handles POST requests - process the account deletion
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
        String username = (String) session.getAttribute("username");

        // Get confirmation parameter
        String confirmDelete = request.getParameter("confirmDelete");
        String currentPassword = request.getParameter("currentPassword");

        // Validate confirmation
        if (!"yes".equals(confirmDelete)) {
            // User did not confirm deletion
            request.setAttribute("errorMessage", "Account deletion requires confirmation");
            request.getRequestDispatcher("/user/delete-account.jsp").forward(request, response);
            return;
        }

        // Create UserManager
        UserManager userManager = new UserManager(getServletContext());

        // Get the current user
        User user = userManager.getUserById(userId);

        // Validate current password
        if (user == null || !user.authenticate(currentPassword)) {
            request.setAttribute("errorMessage", "Incorrect password. Account deletion cancelled.");
            request.getRequestDispatcher("/user/delete-account.jsp").forward(request, response);
            return;
        }

        try {
            // Attempt to delete user
            boolean deleted = userManager.deleteUser(userId);

            if (deleted) {
                // Log account deletion
                System.out.println("User account deleted: " + username + " (ID: " + userId + ")");

                // Invalidate session
                session.invalidate();

                // Create a new session to display success message
                session = request.getSession(true);
                session.setAttribute("successMessage", "Your account has been permanently deleted.");

                // Redirect to home page
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                // Deletion failed
                request.setAttribute("errorMessage", "Failed to delete account. Please try again.");
                request.getRequestDispatcher("/user/delete-account.jsp").forward(request, response);
            }
        } catch (Exception e) {
            // Log any unexpected errors
            System.err.println("Error during account deletion:");
            e.printStackTrace();

            request.setAttribute("errorMessage", "An unexpected error occurred: " + e.getMessage());
            request.getRequestDispatcher("/user/delete-account.jsp").forward(request, response);
        }
    }
}