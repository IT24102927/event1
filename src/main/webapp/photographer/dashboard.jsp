<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.photographer.Photographer" %>
<%@ page import="com.photobooking.model.photographer.PhotographerManager" %>
<%@ page import="com.photobooking.model.review.Review" %>
<%@ page import="com.photobooking.model.review.ReviewManager" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // Ensure user is logged in and is a photographer
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    // If we are coming from a redirect, look for data in request attributes
    // If not, redirect to the DashboardServlet to load data
    Photographer photographer = (Photographer) request.getAttribute("photographer");
    List<Booking> upcomingBookings = (List<Booking>) request.getAttribute("upcomingBookings");
    Integer totalBookings = (Integer) request.getAttribute("totalBookings");
    Integer completedBookings = (Integer) request.getAttribute("completedBookings");
    List<Review> recentReviews = (List<Review>) request.getAttribute("recentReviews");
    String calendarEvents = (String) request.getAttribute("calendarEvents");

    if (photographer == null || upcomingBookings == null || totalBookings == null ||
            completedBookings == null || recentReviews == null || calendarEvents == null) {
        // If data is not set, redirect to servlet to load data
        response.sendRedirect(request.getContextPath() + "/photographer/dashboard");
        return;
    }

    // Fallback for null values
    if (upcomingBookings == null) upcomingBookings = new ArrayList<>();
    if (recentReviews == null) recentReviews = new ArrayList<>();
    if (calendarEvents == null) calendarEvents = "[]";
    if (totalBookings == null) totalBookings = 0;
    if (completedBookings == null) completedBookings = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Photographer Dashboard - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }

        .dashboard-header {
            background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
            border-radius: 0 0 10px 10px;
        }

        .dashboard-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            margin-bottom: 1.5rem;
            padding: 1.5rem;
            height: calc(100% - 1.5rem);
        }

        .dashboard-card-header {
            border-bottom: 1px solid #e9ecef;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
        }

        .booking-item {
            border-bottom: 1px solid #e9ecef;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
        }

        .booking-item:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .status-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.5rem;
        }

        .stats-card {
            text-align: center;
            padding: 1.5rem;
            border-radius: 10px;
            margin-bottom: 1.5rem;
            transition: transform 0.3s;
        }

        .stats-card:hover {
            transform: translateY(-5px);
        }

        .stats-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
        }

        .stats-number {
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .stats-label {
            color: #6c757d;
            font-size: 0.9rem;
        }

        .calendar-container {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            padding: 1.5rem;
            height: 400px;
        }

        .review-item {
            border-bottom: 1px solid #e9ecef;
            padding-bottom: 1rem;
            margin-bottom: 1rem;
        }

        .review-item:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .review-rating {
            margin-bottom: 0.5rem;
        }

        .star-filled {
            color: #ffc107;
        }

        .star-empty {
            color: #e4e5e9;
        }
    </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Include Sidebar with "dashboard" as active page -->
        <c:set var="activePage" value="dashboard" scope="request"/>
        <jsp:include page="/includes/sidebar.jsp" />

        <!-- Main Content Area -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
            <!-- Dashboard Header -->
            <div class="dashboard-header mb-4">
                <div class="container-fluid">
                    <h1 class="display-6">Welcome, ${photographer.businessName}</h1>
                    <p class="lead">Manage your photography business efficiently</p>
                </div>
            </div>

            <!-- Include Messages -->
            <jsp:include page="/includes/messages.jsp" />

            <!-- Stats Row -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="stats-card bg-primary bg-opacity-10">
                        <div class="stats-icon text-primary">
                            <i class="bi bi-calendar-check"></i>
                        </div>
                        <div class="stats-number">${upcomingBookings.size()}</div>
                        <div class="stats-label">Upcoming Bookings</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card bg-success bg-opacity-10">
                        <div class="stats-icon text-success">
                            <i class="bi bi-calendar2-check"></i>
                        </div>
                        <div class="stats-number">${totalBookings}</div>
                        <div class="stats-label">Total Bookings</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card bg-info bg-opacity-10">
                        <div class="stats-icon text-info">
                            <i class="bi bi-check2-all"></i>
                        </div>
                        <div class="stats-number">${completedBookings}</div>
                        <div class="stats-label">Completed Sessions</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stats-card bg-warning bg-opacity-10">
                        <div class="stats-icon text-warning">
                            <i class="bi bi-star"></i>
                        </div>
                        <div class="stats-number">${photographer.rating}</div>
                        <div class="stats-label">Rating (${photographer.reviewCount} reviews)</div>
                    </div>
                </div>
            </div>

            <!-- Main Content -->
            <div class="row">
                <!-- Left Column (8 units) -->
                <div class="col-lg-8">
                    <!-- Upcoming Bookings Card -->
                    <div class="dashboard-card mb-4">
                        <div class="dashboard-card-header d-flex justify-content-between align-items-center">
                            <h2 class="h5 mb-0">Upcoming Bookings</h2>
                            <a href="${pageContext.request.contextPath}/booking/booking_list.jsp" class="btn btn-sm btn-outline-primary">View All</a>
                        </div>

                        <c:choose>
                            <c:when test="${not empty upcomingBookings}">
                                <c:forEach var="booking" items="${upcomingBookings}" varStatus="loop">
                                    <c:if test="${loop.index < 3}">
                                        <div class="booking-item">
                                            <div class="row align-items-center">
                                                <div class="col-md-8">
                                                    <h6 class="mb-1">${booking.eventType}</h6>
                                                    <p class="text-muted mb-1">
                                                        <i class="bi bi-calendar3 me-2"></i>
                                                        <c:if test="${not empty booking.eventDateTime}">
                                                            <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDateTime" />
                                                            <fmt:formatDate value="${parsedDateTime}" pattern="MMMM d, yyyy 'at' h:mm a" />
                                                        </c:if>
                                                    </p>
                                                    <p class="text-muted mb-1">
                                                        <i class="bi bi-geo-alt me-2"></i>${booking.eventLocation}
                                                    </p>
                                                </div>
                                                <div class="col-md-4 text-md-end">
                                                    <c:choose>
                                                        <c:when test="${booking.status == 'PENDING'}">
                                                            <span class="badge bg-warning status-badge">Pending</span>
                                                        </c:when>
                                                        <c:when test="${booking.status == 'CONFIRMED'}">
                                                            <span class="badge bg-success status-badge">Confirmed</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary status-badge">${booking.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="mt-2">
                                                        <a href="${pageContext.request.contextPath}/booking/booking_details.jsp?id=${booking.bookingId}" class="btn btn-sm btn-primary">Details</a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info mb-0">
                                    <i class="bi bi-info-circle me-2"></i>
                                    You have no upcoming bookings.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${upcomingBookings.size() > 3}">
                            <div class="text-center mt-3">
                                <a href="${pageContext.request.contextPath}/booking/booking_list.jsp" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-arrow-right"></i> See all ${upcomingBookings.size()} upcoming bookings
                                </a>
                            </div>
                        </c:if>
                    </div>

                    <!-- Calendar Card -->
                    <div class="dashboard-card">
                        <div class="dashboard-card-header d-flex justify-content-between align-items-center">
                            <h2 class="h5 mb-0">Your Schedule</h2>
                            <a href="${pageContext.request.contextPath}/photographer/availability" class="btn btn-sm btn-outline-primary">Manage Availability</a>
                        </div>
                        <div class="calendar-container">
                            <div id="calendar"></div>
                        </div>
                    </div>
                </div>

                <!-- Right Column (4 units) -->
                <div class="col-lg-4">
                    <!-- Profile Card -->
                    <div class="dashboard-card mb-4">
                        <div class="text-center mb-4">
                            <img src="${pageContext.request.contextPath}/assets/images/default-avatar.jpg" alt="Profile Picture" class="rounded-circle mb-3" width="100" height="100" style="object-fit: cover;">
                            <h3 class="h5 mb-1">${photographer.businessName}</h3>
                            <p class="text-muted mb-3">${photographer.location}</p>

                            <div class="d-flex justify-content-center mb-3">
                                <div class="me-3">
                                    <c:forEach begin="1" end="5" var="i">
                                        <c:choose>
                                            <c:when test="${i <= photographer.rating}">
                                                <i class="bi bi-star-fill star-filled"></i>
                                            </c:when>
                                            <c:when test="${i <= photographer.rating + 0.5}">
                                                <i class="bi bi-star-half star-filled"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="bi bi-star star-empty"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <span>${photographer.rating} (${photographer.reviewCount})</span>
                            </div>

                            <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographer.photographerId}" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-eye me-1"></i>View Public Profile
                            </a>
                        </div>

                        <div class="dashboard-card-header border-bottom-0 mb-0 pb-0">
                            <h4 class="h6 mb-0">Quick Links</h4>
                        </div>
                        <div class="list-group list-group-flush">
                            <a href="${pageContext.request.contextPath}/photographer/service_management.jsp" class="list-group-item list-group-item-action border-0 ps-0 pe-0">
                                <i class="bi bi-camera me-2"></i>Manage Services
                            </a>
                            <a href="${pageContext.request.contextPath}/photographer/availability" class="list-group-item list-group-item-action border-0 ps-0 pe-0">
                                <i class="bi bi-calendar-week me-2"></i>Manage Availability
                            </a>
                            <a href="${pageContext.request.contextPath}/gallery/gallery_list.jsp?userOnly=true" class="list-group-item list-group-item-action border-0 ps-0 pe-0">
                                <i class="bi bi-images me-2"></i>Manage Galleries
                            </a>
                            <a href="${pageContext.request.contextPath}/booking/queue" class="list-group-item list-group-item-action border-0 ps-0 pe-0">
                                <i class="bi bi-hourglass-split me-2"></i>Booking Queue
                            </a>
                        </div>
                    </div>

                    <!-- Recent Reviews Card -->
                    <div class="dashboard-card">
                        <div class="dashboard-card-header d-flex justify-content-between align-items-center">
                            <h2 class="h5 mb-0">Recent Reviews</h2>
                            <a href="${pageContext.request.contextPath}/review/view_reviews.jsp?photographerId=${photographer.photographerId}" class="btn btn-sm btn-outline-primary">View All</a>
                        </div>

                        <c:choose>
                            <c:when test="${not empty recentReviews}">
                                <c:forEach var="review" items="${recentReviews}" varStatus="loop">
                                    <c:if test="${loop.index < 3}">
                                        <div class="review-item">
                                            <div class="review-rating">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <c:choose>
                                                        <c:when test="${i <= review.rating}">
                                                            <i class="bi bi-star-fill star-filled"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="bi bi-star star-empty"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:forEach>
                                            </div>
                                            <p class="review-text mb-1">${review.comment}</p>
                                            <p class="review-author text-muted small mb-0">
                                                <i class="bi bi-person me-1"></i>
                                                    ${review.clientId}
                                                <span class="mx-1">•</span>
                                                <i class="bi bi-calendar3 me-1"></i>
                                                Recent
                                            </p>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info mb-0">
                                    <i class="bi bi-info-circle me-2"></i>
                                    No reviews yet.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- FullCalendar JS -->
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js"></script>

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Initialize FullCalendar
        const calendarEl = document.getElementById('calendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            height: '100%',
            headerToolbar: {
                left: 'prev,next',
                center: 'title',
                right: 'dayGridMonth,listWeek'
            },
            events: <%= calendarEvents %>,
            eventTimeFormat: {
                hour: 'numeric',
                minute: '2-digit',
                meridiem: 'short'
            },
            eventClick: function(info) {
                // Redirect to booking details if it's a booking
                const eventId = info.event.id;
                if (eventId && eventId.startsWith('booking-')) {
                    const bookingId = eventId.replace('booking-', '');
                    window.location.href = '${pageContext.request.contextPath}/booking/booking_details.jsp?id=' + bookingId;
                }
            }
        });
        calendar.render();
    });
</script>
</body>
</html>