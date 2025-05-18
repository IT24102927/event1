package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.util.List;
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
import com.photobooking.model.review.Review;
import com.photobooking.model.review.ReviewManager;
import com.photobooking.model.user.User;
import com.photobooking.model.user.UserManager;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling photographer profile display
 */
@WebServlet("/photographer/profile")
public class PhotographerProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handles GET requests - display photographer profile
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get photographer ID from request
        String photographerId = request.getParameter("id");

        // If photographer ID not provided, try to get from user ID
        if (ValidationUtil.isNullOrEmpty(photographerId)) {
            String userId = request.getParameter("userId");

            if (!ValidationUtil.isNullOrEmpty(userId)) {
                // Look up photographer by user ID
                PhotographerManager photographerManager = new PhotographerManager();
                Photographer photographer = photographerManager.getPhotographerByUserId(userId);

                if (photographer != null) {
                    photographerId = photographer.getPhotographerId();
                }
            }
        }

        // If still no photographer ID, check if current user is a photographer
        if (ValidationUtil.isNullOrEmpty(photographerId)) {
            HttpSession session = request.getSession(false);

            if (session != null && session.getAttribute("user") != null) {
                User currentUser = (User) session.getAttribute("user");

                if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
                    // Look up photographer by user ID
                    PhotographerManager photographerManager = new PhotographerManager();
                    Photographer photographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

                    if (photographer != null) {
                        photographerId = photographer.getPhotographerId();
                    }
                }
            }
        }

        // If still no photographer ID, redirect to photographer list
        if (ValidationUtil.isNullOrEmpty(photographerId)) {
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Get photographer details
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer photographer = photographerManager.getPhotographerById(photographerId);

        if (photographer == null) {
            // Photographer not found
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Photographer not found");
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Get photographer's services
        PhotographerServiceManager serviceManager = new PhotographerServiceManager();
        List<PhotographerService> services = serviceManager.getActiveServicesByPhotographer(photographerId);

        // Load reviews for this photographer
        ReviewManager reviewManager = new ReviewManager();
        List<Review> reviews = reviewManager.getPhotographerReviews(photographerId);
        double averageRating = reviewManager.getAverageRating(photographerId);
        int[] ratingDistribution = reviewManager.getRatingDistribution(photographerId);

        // Get UserManager for displaying client names
        UserManager userManager = new UserManager();

        // Set attributes for the view
        request.setAttribute("photographer", photographer);
        request.setAttribute("services", services);
        request.setAttribute("reviews", reviews);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("ratingDistribution", ratingDistribution);
        request.setAttribute("userManager", userManager);

        // Forward to photographer profile JSP
        request.getRequestDispatcher("/photographer/photographer_profile.jsp").forward(request, response);
    }
}
