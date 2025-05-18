package com.photobooking.servlet.review;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.photobooking.model.review.Review;
import com.photobooking.model.review.ReviewManager;
import com.photobooking.model.user.User;
import com.photobooking.model.photographer.Photographer;
import com.photobooking.model.photographer.PhotographerManager;
import com.photobooking.util.ValidationUtil;

/**
 * Servlet for handling deleting reviews
 */
@WebServlet("/review/delete")
public class DeleteReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

        // Get review ID from request
        String reviewId = ValidationUtil.cleanInput(request.getParameter("reviewId"));
        if (ValidationUtil.isNullOrEmpty(reviewId)) {
            session.setAttribute("errorMessage", "Review ID is required");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Get review
        ReviewManager reviewManager = new ReviewManager();
        Review review = reviewManager.getReviewById(reviewId);

        if (review == null) {
            session.setAttribute("errorMessage", "Review not found");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Verify if user owns the review or is admin
        if (!review.getClientId().equals(currentUser.getUserId()) &&
                currentUser.getUserType() != User.UserType.ADMIN) {
            session.setAttribute("errorMessage", "You don't have permission to delete this review");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Store photographer ID for rating update
        String photographerId = review.getPhotographerId();

        // Delete review
        boolean success = reviewManager.deleteReview(reviewId);

        if (success) {
            session.setAttribute("successMessage", "Review deleted successfully");

            // Update photographer's average rating
            try {
                PhotographerManager photographerManager = new PhotographerManager();
                Photographer photographer = photographerManager.getPhotographerById(photographerId);
                if (photographer != null) {
                    double avgRating = reviewManager.getAverageRating(photographerId);
                    photographer.setRating(avgRating);
                    photographer.setReviewCount(reviewManager.getReviewCount(photographerId));
                    photographerManager.updatePhotographer(photographer);
                }
            } catch (Exception e) {
                // Log error but continue
                System.err.println("Error updating photographer rating: " + e.getMessage());
            }
        } else {
            session.setAttribute("errorMessage", "Failed to delete review");
        }

        // Redirect back to my reviews
        response.sendRedirect(request.getContextPath() + "/review/myreviews");
    }
}
