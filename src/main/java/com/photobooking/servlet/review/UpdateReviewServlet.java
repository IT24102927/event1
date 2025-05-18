package com.photobooking.servlet.review;

import java.io.IOException;
import java.time.LocalDateTime;
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
 * Servlet for handling updating reviews
 */
@WebServlet("/review/edit")
public class UpdateReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

        // Get review ID from request
        String reviewId = request.getParameter("reviewId");
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
            session.setAttribute("errorMessage", "You don't have permission to edit this review");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Get photographer details
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer photographer = photographerManager.getPhotographerById(review.getPhotographerId());

        // Set attributes for JSP
        request.setAttribute("review", review);
        request.setAttribute("photographer", photographer);

        // Forward to edit review page
        request.getRequestDispatcher("/review/edit_review.jsp").forward(request, response);
    }

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

        // Get form parameters
        String reviewId = ValidationUtil.cleanInput(request.getParameter("reviewId"));
        String ratingStr = request.getParameter("rating");
        String comment = ValidationUtil.cleanInput(request.getParameter("comment"));
        String serviceType = request.getParameter("serviceType");

        // Validate required fields
        if (ValidationUtil.isNullOrEmpty(reviewId) ||
                ValidationUtil.isNullOrEmpty(ratingStr) ||
                ValidationUtil.isNullOrEmpty(comment)) {
            session.setAttribute("errorMessage", "All fields are required");
            response.sendRedirect(request.getContextPath() + "/review/edit?reviewId=" + reviewId);
            return;
        }

        // Parse rating
        int rating;
        try {
            rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                throw new NumberFormatException("Rating must be between 1 and 5");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid rating");
            response.sendRedirect(request.getContextPath() + "/review/edit?reviewId=" + reviewId);
            return;
        }

        // Get existing review
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
            session.setAttribute("errorMessage", "You don't have permission to edit this review");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Store old rating for photographer update
        int oldRating = review.getRating();
        String photographerId = review.getPhotographerId();

        // Update review
        review.setRating(rating);
        review.setComment(comment);
        review.setServiceType(serviceType);
        review.setReviewDate(LocalDateTime.now()); // Update date to reflect changes

        // Save updated review
        boolean success = reviewManager.updateReview(review);

        if (success) {
            session.setAttribute("successMessage", "Review updated successfully");

            // Update photographer's average rating if rating changed
            if (oldRating != rating) {
                try {
                    PhotographerManager photographerManager = new PhotographerManager();
                    Photographer photographer = photographerManager.getPhotographerById(photographerId);
                    if (photographer != null) {
                        // Recalculate average rating
                        double avgRating = reviewManager.getAverageRating(photographerId);
                        photographer.setRating(avgRating);
                        photographer.setReviewCount(reviewManager.getReviewCount(photographerId));
                        photographerManager.updatePhotographer(photographer);
                    }
                } catch (Exception e) {
                    // Log error but continue
                    System.err.println("Error updating photographer rating: " + e.getMessage());
                }
            }

            // Redirect to my reviews
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
        } else {
            session.setAttribute("errorMessage", "Failed to update review");
            response.sendRedirect(request.getContextPath() + "/review/edit?reviewId=" + reviewId);
        }
    }
}