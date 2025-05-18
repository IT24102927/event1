package com.photobooking.servlet.review;

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
 * Servlet for handling viewing reviews
 */
@WebServlet("/review/myreviews")
public class ViewReviewsServlet extends HttpServlet {
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
        System.out.println("ViewReviewsServlet: User type = " + currentUser.getUserType());

        // Get reviews based on user type
        ReviewManager reviewManager = new ReviewManager();
        List<Review> reviews = null;

        if (currentUser.getUserType() == User.UserType.CLIENT) {
            // Get reviews by this client
            reviews = reviewManager.getClientReviews(currentUser.getUserId());
            System.out.println("Found " + reviews.size() + " reviews for client: " + currentUser.getUserId());
        } else if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
            // Get photographer ID
            PhotographerManager photographerManager = new PhotographerManager();
            Photographer photographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

            if (photographer == null) {
                session.setAttribute("errorMessage", "Photographer profile not found");
                response.sendRedirect(request.getContextPath() + "/photographer/dashboard");
                return;
            }

            // Get reviews for this photographer
            reviews = reviewManager.getPhotographerReviews(photographer.getPhotographerId());
            System.out.println("Found " + reviews.size() + " reviews for photographer: " + photographer.getPhotographerId());
        } else if (currentUser.getUserType() == User.UserType.ADMIN) {
            // Admin can see all reviews
            reviews = reviewManager.loadReviews();
            System.out.println("Admin viewing all reviews: " + reviews.size());
        } else {
            session.setAttribute("errorMessage", "Invalid user type");
            response.sendRedirect(request.getContextPath() + "/user/login.jsp");
            return;
        }

        // Get user and photographer details for each review
        UserManager userManager = new UserManager();
        PhotographerManager photographerManager = new PhotographerManager();

        // Set attributes for JSP
        request.setAttribute("reviews", reviews);
        request.setAttribute("userManager", userManager);
        request.setAttribute("photographerManager", photographerManager);

        System.out.println("ViewReviewsServlet: Forwarding to my_reviews.jsp with " + reviews.size() + " reviews");

        // Forward to my_reviews page
        request.getRequestDispatcher("/review/my_reviews.jsp").forward(request, response);
    }
}
