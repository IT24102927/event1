<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%@ page import="com.photobooking.model.booking.BookingManager" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="com.photobooking.model.user.UserManager" %>
<%@ page import="com.photobooking.model.photographer.PhotographerManager" %>
<%@ page import="com.photobooking.model.photographer.Photographer" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>

<%
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("user");
    String currentUserId = (String) session.getAttribute("userId");

    if (currentUser == null || currentUserId == null) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    // Initialize managers
    BookingManager bookingManager = new BookingManager();
    UserManager userManager = new UserManager(getServletContext());
    PhotographerManager photographerManager = new PhotographerManager();

    // Get user's bookings
    List<Booking> allBookings = bookingManager.getBookingsByClient(currentUserId);

    // Filter bookings by status
    int pendingCount = 0;
    int confirmedCount = 0;
    int completedCount = 0;
    int cancelledCount = 0;

    for (Booking booking : allBookings) {
        switch (booking.getStatus()) {
            case PENDING:
                pendingCount++;
                break;
            case CONFIRMED:
                confirmedCount++;
                break;
            case COMPLETED:
                completedCount++;
                break;
            case CANCELLED:
                cancelledCount++;
                break;
        }
    }

    // Get upcoming bookings (next 5)
    List<Booking> upcomingBookings = bookingManager.getUpcomingBookings(currentUserId, false);
    List<Map<String, Object>> upcomingBookingsWithDetails = new ArrayList<>();

    for (Booking booking : upcomingBookings.subList(0, Math.min(5, upcomingBookings.size()))) {
        Map<String, Object> bookingDetails = new HashMap<>();
        bookingDetails.put("booking", booking);

        // Get photographer details
        Photographer photographer = photographerManager.getPhotographerByUserId(booking.getPhotographerId());
        bookingDetails.put("photographer", photographer);

        upcomingBookingsWithDetails.add(bookingDetails);
    }

    // Set attributes for JSP
    request.setAttribute("totalBookings", allBookings.size());
    request.setAttribute("pendingBookings", pendingCount);
    request.setAttribute("confirmedBookings", confirmedCount);
    request.setAttribute("completedBookings", completedCount);
    request.setAttribute("cancelledBookings", cancelledCount);
    request.setAttribute("upcomingBookingsWithDetails", upcomingBookingsWithDetails);

    // Format current date
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMMM d, yyyy");
    String currentDate = LocalDateTime.now().format(formatter);
    request.setAttribute("currentDate", currentDate);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        .stat-card {
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .stat-icon {
            font-size: 2rem;
            opacity: 0.8;
        }
        .booking-card {
            border-radius: 8px;
            margin-bottom: 1rem;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.875rem;
        }
        .quick-action-btn {
            height: 100px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
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
            <!-- Page Header -->
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <div>
                    <h1 class="h2">Welcome back, ${sessionScope.user.fullName}</h1>
                    <p class="text-muted">${currentDate}</p>
                </div>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="btn-group me-2">
                        <a href="${pageContext.request.contextPath}/booking/booking_form.jsp" class="btn btn-sm btn-primary">
                            <i class="bi bi-calendar-plus me-1"></i>New Booking
                        </a>
                        <a href="${pageContext.request.contextPath}/photographer/photographer_list.jsp" class="btn btn-sm btn-outline-primary">
                            <i class="bi bi-search me-1"></i>Find Photographers
                        </a>
                    </div>
                </div>
            </div>

            <!-- Include Messages -->
            <jsp:include page="/includes/messages.jsp" />

            <!-- Statistics Cards -->
            <div class="row mb-4">
                <div class="col-md-3 mb-3">
                    <div class="card stat-card bg-primary text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Total Bookings</h6>
                                    <h2 class="card-title mb-0">${totalBookings}</h2>
                                </div>
                                <i class="bi bi-calendar3 stat-icon"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="card stat-card bg-warning text-dark">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Pending</h6>
                                    <h2 class="card-title mb-0">${pendingBookings}</h2>
                                </div>
                                <i class="bi bi-clock-history stat-icon"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="card stat-card bg-success text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Confirmed</h6>
                                    <h2 class="card-title mb-0">${confirmedBookings}</h2>
                                </div>
                                <i class="bi bi-check-circle stat-icon"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 mb-3">
                    <div class="card stat-card bg-info text-white">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <h6 class="card-subtitle mb-2">Completed</h6>
                                    <h2 class="card-title mb-0">${completedBookings}</h2>
                                </div>
                                <i class="bi bi-check2-all stat-icon"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Main Content Row -->
            <div class="row">
                <!-- Upcoming Bookings -->
                <div class="col-lg-8 mb-4">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="card-title mb-0">Upcoming Bookings</h5>
                            <a href="${pageContext.request.contextPath}/booking/booking_list.jsp" class="btn btn-sm btn-outline-primary">View All</a>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty upcomingBookingsWithDetails}">
                                    <c:forEach var="item" items="${upcomingBookingsWithDetails}">
                                        <c:set var="booking" value="${item.booking}" />
                                        <c:set var="photographer" value="${item.photographer}" />

                                        <div class="booking-card border rounded p-3">
                                            <div class="row align-items-center">
                                                <div class="col-md-8">
                                                    <h6 class="mb-1">${booking.eventType}</h6>
                                                    <p class="text-muted mb-1">
                                                        <i class="bi bi-calendar3 me-2"></i>
                                                        <% pageContext.setAttribute("dateTimeFormatter", java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy 'at' h:mm a")); %>
                                                            ${booking.eventDateTime.format(dateTimeFormatter)}
                                                    </p>
                                                    <p class="text-muted mb-1">
                                                        <i class="bi bi-geo-alt me-2"></i>${booking.eventLocation}
                                                    </p>
                                                    <c:if test="${not empty photographer}">
                                                        <p class="text-muted mb-0">
                                                            <i class="bi bi-camera me-2"></i>${photographer.businessName}
                                                        </p>
                                                    </c:if>
                                                </div>
                                                <div class="col-md-4 text-md-end">
                                                        <span class="status-badge ${booking.status == 'CONFIRMED' ? 'bg-success text-white' : 'bg-warning text-dark'} mb-3 d-inline-block">
                                                                ${booking.status}
                                                        </span>
                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/booking/booking_details.jsp?id=${booking.bookingId}"
                                                           class="btn btn-sm btn-outline-primary">
                                                            View Details
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-4">
                                        <i class="bi bi-calendar-x fs-1 text-muted mb-3"></i>
                                        <h6 class="text-muted">No upcoming bookings</h6>
                                        <a href="${pageContext.request.contextPath}/photographer/photographer_list.jsp" class="btn btn-sm btn-primary mt-3">
                                            Find Photographers
                                        </a>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="col-lg-4 mb-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Quick Actions</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/booking/booking_form.jsp"
                                       class="btn btn-outline-primary quick-action-btn w-100">
                                        <i class="bi bi-calendar-plus fs-3 mb-2"></i>
                                        <span>New Booking</span>
                                    </a>
                                </div>
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/booking/booking_list.jsp"
                                       class="btn btn-outline-secondary quick-action-btn w-100">
                                        <i class="bi bi-list-ul fs-3 mb-2"></i>
                                        <span>All Bookings</span>
                                    </a>
                                </div>
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/photographer/photographer_list.jsp"
                                       class="btn btn-outline-info quick-action-btn w-100">
                                        <i class="bi bi-search fs-3 mb-2"></i>
                                        <span>Find Photographers</span>
                                    </a>
                                </div>
                                <div class="col-6">
                                    <a href="${pageContext.request.contextPath}/user/profile.jsp"
                                       class="btn btn-outline-success quick-action-btn w-100">
                                        <i class="bi bi-person-circle fs-3 mb-2"></i>
                                        <span>My Profile</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Stats -->
                    <div class="card mt-4">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Account Overview</h5>
                        </div>
                        <div class="card-body">
                            <ul class="list-group list-group-flush">
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    Account Type
                                    <span class="badge bg-primary rounded-pill">${sessionScope.user.userType}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    Total Bookings
                                    <span class="badge bg-secondary rounded-pill">${totalBookings}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    Pending Approval
                                    <span class="badge bg-warning rounded-pill">${pendingBookings}</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                    Total Completed
                                    <span class="badge bg-success rounded-pill">${completedBookings}</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Recent Activity</h5>
                        </div>
                        <div class="card-body">
                            <div class="list-group list-group-flush">
                                <div class="list-group-item d-flex align-items-center">
                                    <i class="bi bi-check-circle-fill text-success me-3"></i>
                                    <div>
                                        <p class="mb-1">You have successfully logged in</p>
                                        <small class="text-muted">Today</small>
                                    </div>
                                </div>
                                <c:if test="${totalBookings > 0}">
                                    <div class="list-group-item d-flex align-items-center">
                                        <i class="bi bi-calendar-check-fill text-primary me-3"></i>
                                        <div>
                                            <p class="mb-1">Latest booking status updated</p>
                                            <small class="text-muted">Recent activity</small>
                                        </div>
                                    </div>
                                </c:if>
                                <c:if test="${sessionScope.user.userType == 'CLIENT'}">
                                    <div class="list-group-item d-flex align-items-center">
                                        <i class="bi bi-person-check-fill text-info me-3"></i>
                                        <div>
                                            <p class="mb-1">Profile information verified</p>
                                            <small class="text-muted">Account status: Active</small>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Auto-refresh page every 5 minutes to get updated booking data
    setTimeout(function() {
        window.location.reload();
    }, 300000);
</script>
</body>
</html>