package com.photobooking.servlet.photographer;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.review.Review;
import com.photobooking.model.review.ReviewManager;
import com.photobooking.model.user.User;
import com.photobooking.model.user.UserManager;
import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for viewing all reviews for a photographer
 */
@WebServlet("/photographer/reviews")
public class PhotographerReviewsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get photographer ID from request
        String photographerId = request.getParameter("id");
        if (ValidationUtil.isNullOrEmpty(photographerId)) {
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Get photographer details
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer photographer = photographerManager.getPhotographerById(photographerId);

        if (photographer == null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("errorMessage", "Photographer not found");
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Get reviews for this photographer
        ReviewManager reviewManager = new ReviewManager();
        List<Review> reviews = reviewManager.getPhotographerReviews(photographerId);
        double averageRating = reviewManager.getAverageRating(photographerId);
        int[] ratingDistribution = reviewManager.getRatingDistribution(photographerId);

        // Get UserManager for displaying client names
        UserManager userManager = new UserManager();

        // Set attributes for JSP
        request.setAttribute("photographer", photographer);
        request.setAttribute("reviews", reviews);
        request.setAttribute("averageRating", averageRating);
        request.setAttribute("ratingDistribution", ratingDistribution);
        request.setAttribute("userManager", userManager);

        // Forward to photographer reviews page
        request.getRequestDispatcher("/review/photographer_reviews.jsp").forward(request, response);
    }
}