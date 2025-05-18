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
 * Servlet for handling photographer responses to reviews
 */
@WebServlet("/review/respond")
public class RespondToReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if user is logged in and is a photographer
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        User currentUser = (User) session.getAttribute("user");
        if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
            session.setAttribute("errorMessage", "Only photographers can respond to reviews");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Get form parameters
        String reviewId = ValidationUtil.cleanInput(request.getParameter("reviewId"));
        String responseText = ValidationUtil.cleanInput(request.getParameter("responseText"));

        // Validate required fields
        if (ValidationUtil.isNullOrEmpty(reviewId) || ValidationUtil.isNullOrEmpty(responseText)) {
            session.setAttribute("errorMessage", "Review ID and response text are required");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Get the review
        ReviewManager reviewManager = new ReviewManager();
        Review review = reviewManager.getReviewById(reviewId);

        if (review == null) {
            session.setAttribute("errorMessage", "Review not found");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Verify the review is for this photographer
        PhotographerManager photographerManager = new PhotographerManager();
        Photographer photographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

        if (photographer == null) {
            session.setAttribute("errorMessage", "Photographer profile not found");
            response.sendRedirect(request.getContextPath() + "/photographer/dashboard");
            return;
        }

        if (!review.getPhotographerId().equals(photographer.getPhotographerId())) {
            session.setAttribute("errorMessage", "You don't have permission to respond to this review");
            response.sendRedirect(request.getContextPath() + "/review/myreviews");
            return;
        }

        // Add response to review
        boolean success = reviewManager.addResponseToReview(reviewId, responseText);

        if (success) {
            session.setAttribute("successMessage", "Response added successfully");
        } else {
            session.setAttribute("errorMessage", "Failed to add response");
        }

        response.sendRedirect(request.getContextPath() + "/review/myreviews");
    }
}
