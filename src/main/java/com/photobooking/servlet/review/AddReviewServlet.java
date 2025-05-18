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
 * Servlet for handling adding reviews
 */
@WebServlet("/review/add")
public class AddReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a client
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.CLIENT) {
            session.setAttribute("errorMessage", "Only clients can leave reviews");
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Get photographer ID from request
        String photographerId = request.getParameter("photographerId");
        if (ValidationUtil.isNullOrEmpty(photographerId)) {
            session.setAttribute("errorMessage", "Photographer ID is required");
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Check if user already has a review for this photographer
        ReviewManager reviewManager = new ReviewManager();
        Review existingReview = reviewManager.getReviewByClientAndPhotographer(
                currentUser.getUserId(), photographerId);

        if (existingReview != null) {
            // User already has a review, redirect to edit page
            response.sendRedirect(request.getContextPath() +
                    "/review/edit?reviewId=" + existingReview.getReviewId());
            return;
        }

        // Get photographer details
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer photographer = photographerManager.getPhotographerById(photographerId);

        if (photographer == null) {
            session.setAttribute("errorMessage", "Photographer not found");
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Set photographer details in request
        request.setAttribute("photographer", photographer);

        // Forward to add review page
        request.getRequestDispatcher("/review/add_review.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a client
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.CLIENT) {
            session.setAttribute("errorMessage", "Only clients can leave reviews");
            response.sendRedirect(request.getContextPath() + "/photographer/list");
            return;
        }

        // Get form parameters
        String photographerId = ValidationUtil.cleanInput(request.getParameter("photographerId"));
        String ratingStr = request.getParameter("rating");
        String comment = ValidationUtil.cleanInput(request.getParameter("comment"));
        String serviceType = request.getParameter("serviceType");

        // Validate required fields
        if (ValidationUtil.isNullOrEmpty(photographerId) ||
                ValidationUtil.isNullOrEmpty(ratingStr) ||
                ValidationUtil.isNullOrEmpty(comment)) {
            session.setAttribute("errorMessage", "All fields are required");
            response.sendRedirect(request.getContextPath() +
                    "/review/add?photographerId=" + photographerId);
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
            response.sendRedirect(request.getContextPath() +
                    "/review/add?photographerId=" + photographerId);
            return;
        }

        // Check if user already has a review for this photographer
        ReviewManager reviewManager = new ReviewManager();
        Review existingReview = reviewManager.getReviewByClientAndPhotographer(
                currentUser.getUserId(), photographerId);

        if (existingReview != null) {
            session.setAttribute("errorMessage", "You already have a review for this photographer");
            response.sendRedirect(request.getContextPath() +
                    "/review/edit?reviewId=" + existingReview.getReviewId());
            return;
        }

        // Create new review
        Review newReview = new Review();
        newReview.setPhotographerId(photographerId);
        newReview.setClientId(currentUser.getUserId());
        newReview.setRating(rating);
        newReview.setComment(comment);
        newReview.setReviewDate(LocalDateTime.now());
        newReview.setServiceType(serviceType);
        newReview.setVerified(true); // Assume all reviews are verified for simplicity

        // Save review
        boolean success = reviewManager.addReview(newReview);

        if (success) {
            session.setAttribute("successMessage", "Review submitted successfully");

            // Also update photographer's average rating
            try {
                PhotographerManager photographerManager = new PhotographerManager();
                Photographer photographer = photographerManager.getPhotographerById(photographerId);
                if (photographer != null) {
                    photographer.addReview(rating);
                    photographerManager.updatePhotographer(photographer);
                }
            } catch (Exception e) {
                // Log error but continue
                System.err.println("Error updating photographer rating: " + e.getMessage());
            }

            // Redirect to photographer profile
            response.sendRedirect(request.getContextPath() +
                    "/photographer/profile?id=" + photographerId);
        } else {
            session.setAttribute("errorMessage", "Failed to submit review");
            response.sendRedirect(request.getContextPath() +
                    "/review/add?photographerId=" + photographerId);
        }
    }
}
