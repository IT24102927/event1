package com.photobooking.servlet.user;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet for handling user logout in the Event Photography System
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles logout requests
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get the current session
        HttpSession session = request.getSession(false);

        // Log logout if user was logged in
        if (session != null) {
            String username = (String) session.getAttribute("username");
            if (username != null) {
                System.out.println("User logged out: " + username);
            }

            // Invalidate session
            session.invalidate();
        }

        // Create a new session to display logout message
        session = request.getSession(true);
        session.setAttribute("successMessage", "You have been successfully logged out.");

        // Redirect to login page
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    }

    /**
     * Alternative logout method for POST requests
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Reuse the GET method logic
        doGet(request, response);
    }
}