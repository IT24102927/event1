<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.photobooking.model.booking.BookingManager" %>
<%@ page import="com.photobooking.model.booking.BookingQueueManager" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.user.UserManager" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="com.photobooking.model.photographer.PhotographerManager" %>
<%@ page import="com.photobooking.model.photographer.Photographer" %>
<%@ page import="com.photobooking.model.photographer.PhotographerServiceManager" %>
<%@ page import="com.photobooking.model.photographer.PhotographerService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalDateTime" %>

<%
    // Get current user
    User currentUser = (User) session.getAttribute("user");
    String currentUserId = (String) session.getAttribute("userId");
    if (currentUser == null || currentUserId == null) {
        session.setAttribute("errorMessage", "Please login to access booking features");
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    // Get action parameter
    String action = request.getParameter("action");
    if (action == null) {
        action = "list"; // Default to booking list
    }

    // Initialize managers
    BookingManager bookingManager = new BookingManager(application);
    BookingQueueManager queueManager = BookingQueueManager.getInstance(application);
    PhotographerManager photographerManager = new PhotographerManager(application);
    PhotographerServiceManager serviceManager = new PhotographerServiceManager(application);
    UserManager userManager = new UserManager(application);

    // Data for booking list
    List<Booking> bookings = null;
    if (action.equals("list")) {
        if (currentUser.getUserType() == User.UserType.CLIENT) {
            bookings = bookingManager.getBookingsByClient(currentUserId);
        } else if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
            bookings = bookingManager.getBookingsByPhotographer(currentUserId);
        } else {
            bookings = bookingManager.getAllBookings();
        }
        request.setAttribute("bookings", bookings);
    }

    // Data for booking queue
    List<Booking> queuedBookings = null;
    Integer totalQueueSize = null;
    Integer userQueueSize = null;
    if (action.equals("queue")) {
        if (currentUser.getUserType() == User.UserType.CLIENT) {
            queuedBookings = queueManager.getQueuedBookingsForClient(currentUserId);
        } else if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
            queuedBookings = queueManager.getQueuedBookingsForPhotographer(currentUserId);
        } else {
            queuedBookings = queueManager.getAllQueuedBookings();
        }
        totalQueueSize = queueManager.getQueueSize();
        userQueueSize = queuedBookings.size();
        request.setAttribute("queuedBookings", queuedBookings);
        request.setAttribute("totalQueueSize", totalQueueSize);
        request.setAttribute("userQueueSize", userQueueSize);
    }

    // Data for booking details, confirmation, or cancellation
    Booking booking = null;
    User client = null;
    User photographer = null;
    Photographer photographerDetails = null;
    PhotographerService service = null;
    if (action.equals("details") || action.equals("confirmation") || action.equals("cancel")) {
        String bookingId = request.getParameter("id");
        if (bookingId != null && !bookingId.trim().isEmpty()) {
            booking = bookingManager.getBookingById(bookingId);
            if (booking == null) {
                session.setAttribute("errorMessage", "Booking not found");
                response.sendRedirect(request.getContextPath() + "/booking.jsp?action=list");
                return;
            }
            client = userManager.getUserById(booking.getClientId());
            photographer = userManager.getUserById(booking.getPhotographerId());
            photographerDetails = photographerManager.getPhotographerByUserId(booking.getPhotographerId());
            if (booking.getServiceId() != null && photographerDetails != null) {
                service = serviceManager.getServiceById(booking.getServiceId());
            }
            request.setAttribute("booking", booking);
            request.setAttribute("client", client);
            request.setAttribute("photographer", photographer);
            request.setAttribute("photographerDetails", photographerDetails);
            request.setAttribute("service", service);
        } else {
            session.setAttribute("errorMessage", "Invalid booking ID");
            response.sendRedirect(request.getContextPath() + "/booking.jsp?action=list");
            return;
        }
    }

    // Data for booking form
    List<Photographer> allPhotographers = null;
    Photographer selectedPhotographer = null;
    List<PhotographerService> services = null;
    PhotographerService selectedService = null;
    LocalDate tomorrow = null;
    if (action.equals("form")) {
        String photographerId = request.getParameter("photographerId");
        String serviceId = request.getParameter("serviceId");
        allPhotographers = photographerManager.getAllPhotographers();
        if (photographerId != null && !photographerId.isEmpty()) {
            selectedPhotographer = photographerManager.getPhotographerById(photographerId);
            if (selectedPhotographer != null) {
                services = serviceManager.getActiveServicesByPhotographer(photographerId);
            }
        }
        if (serviceId != null && !serviceId.isEmpty() && services != null) {
            for (PhotographerService svc : services) {
                if (svc.getServiceId().equals(serviceId)) {
                    selectedService = svc;
                    break;
                }
            }
        }
        tomorrow = LocalDate.now().plusDays(1);
        request.setAttribute("allPhotographers", allPhotographers);
        request.setAttribute("selectedPhotographer", selectedPhotographer);
        request.setAttribute("services", services);
        request.setAttribute("selectedService", selectedService);
        request.setAttribute("minDate", tomorrow);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- Consolidated CSS -->
    <style>
        .header-section {
            background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            border-radius: 0 0 10px 10px;
            text-align: center;
        }

        .card-section {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
            padding: 30px;
            margin-bottom: 30px;
        }

        .details-section {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .detail-row {
            margin-bottom: 15px;
        }

        .detail-label {
            font-weight: 600;
            color: #6c757d;
        }

        .success-badge {
            position: absolute;
            top: 0;
            right: 0;
            background-color: #4361ee;
            color: white;
            padding: 10px 20px;
            transform: rotate(45deg) translate(20px, -15px);
            transform-origin: top right;
            font-size: 0.8rem;
            font-weight: 600;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        .queue-item {
            border-left: 5px solid #4361ee;
            margin-bottom: 15px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 5px;
            transition: all 0.3s ease;
        }

        .queue-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .queue-stats {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .stat-item {
            text-align: center;
            padding: 15px;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 600;
            color: #4361ee;
        }

        .stat-label {
            font-size: 0.9rem;
            color: #6c757d;
        }

        .package-price {
            font-size: 2rem;
            font-weight: 600;
            color: #4361ee;
        }

        .feature-list {
            list-style-type: none;
            padding-left: 0;
        }

        .feature-list li {
            padding: 5px 0;
        }

        .feature-list li::before {
            content: "✓";
            color: #4361ee;
            font-weight: bold;
            margin-right: 10px;
        }
    </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container">
    <!-- Include Messages -->
    <jsp:include page="/includes/messages.jsp" />

    <c:choose>
        <!-- Booking Form -->
        <c:when test="${param.action == 'form'}">
            <div class="header-section">
                <h1 class="display-5">Book Photography Session</h1>
                <p class="lead">Complete the form below to book your photography session</p>
            </div>

            <div class="row">
                <div class="col-lg-8">
                    <div class="card-section">
                        <h3 class="mb-4">Booking Details</h3>
                        <form action="${pageContext.request.contextPath}/booking/create-booking" method="post" id="bookingForm">
                            <div class="mb-4">
                                <label for="photographerId" class="form-label">Select Photographer</label>
                                <select class="form-select" id="photographerId" name="photographerId" required>
                                    <option value="" disabled ${empty selectedPhotographer ? 'selected' : ''}>Select a photographer...</option>
                                    <c:forEach var="photographer" items="${allPhotographers}">
                                        <option value="${photographer.photographerId}"
                                            ${selectedPhotographer != null && photographer.photographerId == selectedPhotographer.photographerId ? 'selected' : ''}>
                                                ${photographer.businessName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="mb-4">
                                <label for="serviceId" class="form-label">Select Package</label>
                                <select class="form-select" id="serviceId" name="serviceId" required>
                                    <option value="" disabled ${empty services ? 'selected' : ''}>
                                            ${empty services ? 'Please select a photographer first' : 'Select a package...'}
                                    </option>
                                    <c:forEach var="service" items="${services}">
                                        <option value="${service.serviceId}"
                                            ${selectedService != null && service.serviceId == selectedService.serviceId ? 'selected' : ''}>
                                                ${service.name} - $${service.price}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <h4 class="mt-5 mb-3">Event Details</h4>
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="eventDate" class="form-label">Event Date</label>
                                    <input type="date" class="form-control" id="eventDate" name="eventDate" required min="${minDate}">
                                </div>
                                <div class="col-md-6">
                                    <label for="eventTime" class="form-label">Start Time</label>
                                    <input type="time" class="form-control" id="eventTime" name="eventTime" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="eventLocation" class="form-label">Event Location</label>
                                <input type="text" class="form-control" id="eventLocation" name="eventLocation" placeholder="Address or venue name" required>
                            </div>

                            <div class="mb-4">
                                <label for="eventType" class="form-label">Event Type</label>
                                <select class="form-select" id="eventType" name="eventType" required>
                                    <option value="" disabled selected>Select event type</option>
                                    <option value="WEDDING">Wedding</option>
                                    <option value="CORPORATE">Corporate Event</option>
                                    <option value="PORTRAIT">Portrait Session</option>
                                    <option value="EVENT">General Event</option>
                                    <option value="FAMILY">Family Session</option>
                                    <option value="PRODUCT">Product Photography</option>
                                    <option value="OTHER">Other</option>
                                </select>
                            </div>

                            <div class="mb-4">
                                <label for="eventNotes" class="form-label">Special Requests or Notes</label>
                                <textarea class="form-control" id="eventNotes" name="eventNotes" rows="4" placeholder="Any special requirements"></textarea>
                            </div>

                            <div class="d-grid gap-2 mt-5">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="bi bi-calendar-check me-2"></i>Book Now
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="col-lg-4">
                    <c:if test="${not empty selectedPhotographer}">
                        <div class="card-section">
                            <h4 class="mb-3">Photographer</h4>
                            <div class="d-flex align-items-center mb-3">
                                <img src="${pageContext.request.contextPath}/assets/images/default-photographer.jpg"
                                     alt="${selectedPhotographer.businessName}" class="rounded-circle me-3"
                                     style="width: 60px; height: 60px; object-fit: cover;"
                                     onerror="this.src='${pageContext.request.contextPath}/assets/images/user-placeholder.png'">
                                <div>
                                    <h5 class="mb-0">${selectedPhotographer.businessName}</h5>
                                    <p class="text-muted mb-0">${selectedPhotographer.location}</p>
                                </div>
                            </div>
                            <div class="d-flex align-items-center mb-3">
                                <div class="me-2">
                                    <c:forEach begin="1" end="5" var="i">
                                        <c:choose>
                                            <c:when test="${i <= selectedPhotographer.rating}">
                                                <i class="bi bi-star-fill text-warning"></i>
                                            </c:when>
                                            <c:when test="${i > selectedPhotographer.rating && i < selectedPhotographer.rating + 1}">
                                                <i class="bi bi-star-half text-warning"></i>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="bi bi-star text-warning"></i>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </div>
                                <span>${selectedPhotographer.rating} (${selectedPhotographer.reviewCount} reviews)</span>
                            </div>
                            <p>${selectedPhotographer.biography}</p>
                            <a href="${pageContext.request.contextPath}/photographer/profile?id=${selectedPhotographer.photographerId}"
                               class="btn btn-outline-primary btn-sm">
                                <i class="bi bi-person me-1"></i>View Profile
                            </a>
                        </div>
                    </c:if>

                    <c:if test="${not empty selectedService}">
                        <div class="card-section">
                            <h4 class="mb-3">Selected Package</h4>
                            <div class="details-section">
                                <h5>${selectedService.name}</h5>
                                <div class="package-price mb-3">$${selectedService.price}</div>
                                <p>${selectedService.description}</p>
                                <div class="mb-3">
                                    <strong>Duration:</strong> ${selectedService.durationHours} hours<br>
                                    <strong>Photographers:</strong> ${selectedService.photographersCount}<br>
                                    <strong>Deliverables:</strong> ${selectedService.deliverables}
                                </div>
                                <c:if test="${not empty selectedService.features}">
                                    <h6>Package Includes:</h6>
                                    <ul class="feature-list">
                                        <c:forEach var="feature" items="${selectedService.features}">
                                            <li>${feature}</li>
                                        </c:forEach>
                                    </ul>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <div class="card-section">
                        <h4 class="mb-3">Booking Tips</h4>
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item border-0 ps-0">
                                <i class="bi bi-calendar3 text-primary me-2"></i>Book 2-4 weeks in advance
                            </li>
                            <li class="list-group-item border-0 ps-0">
                                <i class="bi bi-clock text-primary me-2"></i>Consider golden hour for outdoor shoots
                            </li>
                            <li class="list-group-item border-0 ps-0">
                                <i class="bi bi-geo-alt text-primary me-2"></i>Provide detailed location information
                            </li>
                            <li class="list-group-item border-0 ps-0">
                                <i class="bi bi-chat-text text-primary me-2"></i>Include special requirements in notes
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </c:when>

        <!-- Booking Confirmation -->
        <c:when test="${param.action == 'confirmation'}">
            <div class="header-section">
                <h1 class="display-4">Booking Confirmed!</h1>
                <p class="lead">Your photography session has been successfully booked</p>
            </div>

            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card-section text-center">
                        <div class="success-badge">CONFIRMED</div>
                        <div class="confirmation-icon" style="font-size: 60px; color: #4361ee; margin-bottom: 20px;">
                            <i class="bi bi-check-circle"></i>
                        </div>
                        <h2 class="mb-4">Thank You for Your Booking!</h2>
                        <p class="mb-4">Your booking has been confirmed and the photographer has been notified. You'll receive an email confirmation shortly.</p>

                        <div class="details-section text-start">
                            <h4 class="mb-4">Booking Details</h4>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Booking ID:</div>
                                <div class="col-md-8">${booking.bookingId}</div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Photographer:</div>
                                <div class="col-md-8">${photographerDetails.businessName}</div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Service Package:</div>
                                <div class="col-md-8">${service.name}</div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Event Date:</div>
                                <div class="col-md-8">
                                    <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                    <fmt:formatDate value="${parsedDate}" pattern="MMMM d, yyyy" />
                                </div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Time:</div>
                                <div class="col-md-8">
                                    <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedTime" />
                                    <fmt:formatDate value="${parsedTime}" pattern="h:mm a" />
                                </div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Location:</div>
                                <div class="col-md-8">${booking.eventLocation}</div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Event Type:</div>
                                <div class="col-md-8">${booking.eventType}</div>
                            </div>
                            <div class="row detail-row">
                                <div class="col-md-4 detail-label">Total Price:</div>
                                <div class="col-md-8">$${booking.totalPrice}</div>
                            </div>
                        </div>

                        <p class="mb-4">Contact the photographer or visit your bookings page for changes or questions.</p>

                        <div class="d-grid gap-3 d-md-flex justify-content-md-center mt-5">
                            <a href="${pageContext.request.contextPath}/booking.jsp?action=list" class="btn btn-primary btn-lg">
                                <i class="bi bi-list me-2"></i>View All Bookings
                            </a>
                            <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-outline-primary btn-lg">
                                <i class="bi bi-speedometer2 me-2"></i>Go to Dashboard
                            </a>
                        </div>
                    </div>

                    <div class="card-section">
                        <h3 class="mb-4">What's Next?</h3>
                        <div class="row">
                            <div class="col-md-6 mb-4">
                                <div class="d-flex">
                                    <div class="flex-shrink-0 me-3 text-primary">
                                        <i class="bi bi-envelope-check fs-3"></i>
                                    </div>
                                    <div>
                                        <h5>Check Your Email</h5>
                                        <p>You'll receive a detailed confirmation email.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 mb-4">
                                <div class="d-flex">
                                    <div class="flex-shrink-0 me-3 text-primary">
                                        <i class="bi bi-chat-dots fs-3"></i>
                                    </div>
                                    <div>
                                        <h5>Photographer Contact</h5>
                                        <p>The photographer may discuss session details.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 mb-4">
                                <div class="d-flex">
                                    <div class="flex-shrink-0 me-3 text-primary">
                                        <i class="bi bi-calendar-check fs-3"></i>
                                    </div>
                                    <div>
                                        <h5>Prepare for Your Session</h5>
                                        <p>Plan outfits, locations, and specific shots.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="d-flex">
                                    <div class="flex-shrink-0 me-3 text-primary">
                                        <i class="bi bi-clock-history fs-3"></i>
                                    </div>
                                    <div>
                                        <h5>Day of Your Event</h5>
                                        <p>The photographer will arrive as scheduled.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:when>

        <!-- Booking Details -->
        <c:when test="${param.action == 'details'}">
            <div class="header-section">
                <h1 class="display-5">Booking Details</h1>
                <p class="lead">View details of your booking</p>
            </div>

            <div class="row">
                <div class="col-lg-8">
                    <div class="card-section">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h3 class="mb-0">Booking Details</h3>
                            <c:choose>
                                <c:when test="${booking.status == 'PENDING'}">
                                    <span class="badge bg-warning fs-6">Pending</span>
                                </c:when>
                                <c:when test="${booking.status == 'CONFIRMED'}">
                                    <span class="badge bg-success fs-6">Confirmed</span>
                                </c:when>
                                <c:when test="${booking.status == 'COMPLETED'}">
                                    <span class="badge bg-primary fs-6">Completed</span>
                                </c:when>
                                <c:when test="${booking.status == 'CANCELLED'}">
                                    <span class="badge bg-danger fs-6">Cancelled</span>
                                </c:when>
                            </c:choose>
                        </div>
                        <div class="details-section">
                            <div class="row mb-3">
                                <div class="col-sm-3"><strong>Booking ID:</strong></div>
                                <div class="col-sm-9">${booking.bookingId}</div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3"><strong>Event Type:</strong></div>
                                <div class="col-sm-9">${booking.eventType}</div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3"><strong>Event Date:</strong></div>
                                <div class="col-sm-9">
                                    <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                    <fmt:formatDate value="${parsedDate}" pattern="MMMM d, yyyy h:mm a" />
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3"><strong>Location:</strong></div>
                                <div class="col-sm-9">${booking.eventLocation}</div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3"><strong>Total Price:</strong></div>
                                <div class="col-sm-9">$${booking.totalPrice}</div>
                            </div>
                            <c:if test="${not empty booking.eventNotes}">
                                <div class="row mb-3">
                                    <div class="col-sm-3"><strong>Notes:</strong></div>
                                    <div class="col-sm-9">${booking.eventNotes}</div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <c:if test="${not empty service}">
                        <div class="card-section">
                            <h4 class="mb-3">Service Package</h4>
                            <div class="details-section">
                                <h5>${service.name}</h5>
                                <p>${service.description}</p>
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong>Duration:</strong> ${service.durationHours} hours</p>
                                        <p><strong>Photographers:</strong> ${service.photographersCount}</p>
                                    </div>
                                    <div class="col-md-6">
                                        <p><strong>Deliverables:</strong> ${service.deliverables}</p>
                                    </div>
                                </div>
                                <c:if test="${not empty service.features}">
                                    <h6>Package Includes:</h6>
                                    <ul>
                                        <c:forEach var="feature" items="${service.features}">
                                            <li>${feature}</li>
                                        </c:forEach>
                                    </ul>
                                </c:if>
                            </div>
                        </div>
                    </c:if>

                    <div class="card-section">
                        <h5 class="mb-3">Actions</h5>
                        <div class="btn-group">
                            <c:if test="${booking.status != 'CANCELLED' && booking.status != 'COMPLETED'}">
                                <c:if test="${sessionScope.user.userId == booking.clientId || sessionScope.user.userId == booking.photographerId || sessionScope.user.userType == 'ADMIN'}">
                                    <a href="${pageContext.request.contextPath}/booking.jsp?action=cancel&id=${booking.bookingId}"
                                       class="btn btn-outline-danger"
                                       onclick="return confirm('Are you sure you want to cancel this booking?')">
                                        <i class="bi bi-x-circle me-1"></i>Cancel Booking
                                    </a>
                                </c:if>
                            </c:if>

                            <c:if test="${sessionScope.user.userId == booking.photographerId && booking.status == 'PENDING'}">
                                <form action="${pageContext.request.contextPath}/booking/update" method="post" style="display: inline;">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="status" value="CONFIRMED">
                                    <button type="submit" class="btn btn-outline-success">
                                        <i class="bi bi-check-circle me-1"></i>Confirm Booking
                                    </button>
                                </form>
                            </c:if>

                            <c:if test="${sessionScope.user.userId == booking.photographerId && booking.status == 'CONFIRMED'}">
                                <form action="${pageContext.request.contextPath}/booking/update" method="post" style="display: inline;">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="status" value="COMPLETED">
                                    <button type="submit" class="btn btn-outline-primary">
                                        <i class="bi bi-check2-all me-1"></i>Mark as Completed
                                    </button>
                                </form>
                            </c:if>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <c:if test="${sessionScope.user.userId == booking.clientId && not empty photographerDetails}">
                        <div class="card-section">
                            <h4 class="mb-3">Photographer Details</h4>
                            <h5>${photographerDetails.businessName}</h5>
                            <p><i class="bi bi-geo-alt me-2"></i>${photographerDetails.location}</p>
                            <p><i class="bi bi-star-fill me-2 text-warning"></i>${photographerDetails.rating}</p>
                            <c:if test="${not empty photographerDetails.contactPhone}">
                                <p><i class="bi bi-telephone me-2"></i>${photographerDetails.contactPhone}</p>
                            </c:if>
                            <c:if test="${not empty photographerDetails.email}">
                                <p><i class="bi bi-envelope me-2"></i>${photographerDetails.email}</p>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographerDetails.photographerId}"
                               class="btn btn-outline-primary w-100">
                                View Full Profile
                            </a>
                        </div>
                    </c:if>

                    <c:if test="${sessionScope.user.userId == booking.photographerId && not empty client}">
                        <div class="card-section">
                            <h4 class="mb-3">Client Details</h4>
                            <h5>${client.fullName}</h5>
                            <p><i class="bi bi-envelope me-2"></i>${client.email}</p>
                        </div>
                    </c:if>

                    <div class="d-grid gap-2">
                        <a href="${pageContext.request.contextPath}/booking.jsp?action=list" class="btn btn-secondary">
                            <i class="bi bi-arrow-left me-2"></i>Back to Bookings
                        </a>
                    </div>
                </div>
            </div>
        </c:when>

        <!-- Booking List -->
        <c:when test="${param.action == 'list' || empty param.action}">
            <div class="header-section">
                <h1 class="display-5">My Bookings</h1>
                <p class="lead">View and manage your bookings</p>
            </div>

            <div class="row">
                <div class="col-md-3">
                    <c:set var="activePage" value="bookings" scope="request"/>
                    <jsp:include page="/includes/sidebar.jsp" />
                </div>
                <div class="col-md-9">
                    <div class="card-section">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h3 class="mb-0">Bookings</h3>
                            <a href="${pageContext.request.contextPath}/booking.jsp?action=form" class="btn btn-primary btn-sm">
                                <i class="bi bi-calendar-plus me-1"></i>New Booking
                            </a>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <select class="form-select" id="statusFilter">
                                    <option value="">All Status</option>
                                    <option value="PENDING">Pending</option>
                                    <option value="CONFIRMED">Confirmed</option>
                                    <option value="COMPLETED">Completed</option>
                                    <option value="CANCELLED">Cancelled</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <input type="text" class="form-control" id="searchInput" placeholder="Search bookings...">
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-striped" id="bookingsTable">
                                <thead>
                                <tr>
                                    <th>Booking ID</th>
                                    <th>Date</th>
                                    <th>Event Type</th>
                                    <th>Location</th>
                                    <c:if test="${sessionScope.user.userType == 'CLIENT'}">
                                        <th>Photographer</th>
                                    </c:if>
                                    <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                                        <th>Client</th>
                                    </c:if>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty bookings}">
                                        <c:forEach var="booking" items="${bookings}">
                                            <tr>
                                                <td>${booking.bookingId}</td>
                                                <td>
                                                    <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                                    <fmt:formatDate value="${parsedDate}" pattern="MMM d, yyyy h:mm a" />
                                                </td>
                                                <td>${booking.eventType}</td>
                                                <td>${booking.eventLocation}</td>
                                                <c:if test="${sessionScope.user.userType == 'CLIENT'}">
                                                    <td>${booking.photographerId}</td>
                                                </c:if>
                                                <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                                                    <td>${booking.clientId}</td>
                                                </c:if>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${booking.status == 'PENDING'}">
                                                            <span class="badge bg-warning">Pending</span>
                                                        </c:when>
                                                        <c:when test="${booking.status == 'CONFIRMED'}">
                                                            <span class="badge bg-success">Confirmed</span>
                                                        </c:when>
                                                        <c:when test="${booking.status == 'COMPLETED'}">
                                                            <span class="badge bg-primary">Completed</span>
                                                        </c:when>
                                                        <c:when test="${booking.status == 'CANCELLED'}">
                                                            <span class="badge bg-danger">Cancelled</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/booking.jsp?action=details&id=${booking.bookingId}"
                                                       class="btn btn-sm btn-outline-primary">
                                                        <i class="bi bi-eye me-1"></i>View
                                                    </a>
                                                    <c:if test="${booking.status != 'CANCELLED' && booking.status != 'COMPLETED'}">
                                                        <a href="${pageContext.request.contextPath}/booking.jsp?action=cancel&id=${booking.bookingId}"
                                                           class="btn btn-sm btn-outline-danger"
                                                           onclick="return confirm('Are you sure you want to cancel this booking?')">
                                                            <i class="bi bi-x-circle me-1"></i>Cancel
                                                        </a>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="text-center py-4">No bookings found</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </c:when>

        <!-- Booking Queue -->
        <c:when test="${param.action == 'queue'}">
            <div class="header-section">
                <h1 class="display-5">Booking Queue</h1>
                <p class="lead">Manage your photography booking requests</p>
            </div>

            <div class="row mb-4">
                <div class="col-md-8 offset-md-2">
                    <div class="queue-stats">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="stat-item">
                                    <div class="stat-number">${userQueueSize}</div>
                                    <div class="stat-label">
                                        <c:choose>
                                            <c:when test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">Bookings Awaiting Your Approval</c:when>
                                            <c:when test="${sessionScope.user.userType == 'CLIENT'}">Your Pending Bookings</c:when>
                                            <c:otherwise>Total Bookings in Queue</c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                            <c:if test="${sessionScope.user.userType == 'ADMIN' || sessionScope.user.userType == 'PHOTOGRAPHER'}">
                                <div class="col-md-6">
                                    <div class="stat-item">
                                        <div class="stat-number">${totalQueueSize}</div>
                                        <div class="stat-label">System-wide Queue Size</div>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-8">
                    <div class="card-section">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h2 class="h4 mb-0">
                                <c:choose>
                                    <c:when test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">Bookings Pending Your Approval</c:when>
                                    <c:when test="${sessionScope.user.userType == 'CLIENT'}">Your Pending Booking Requests</c:when>
                                    <c:otherwise>All Pending Bookings</c:otherwise>
                                </c:choose>
                            </h2>
                            <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER' || sessionScope.user.userType == 'ADMIN'}">
                                <div class="btn-group">
                                    <form action="${pageContext.request.contextPath}/booking/queue" method="post">
                                        <input type="hidden" name="action" value="processNext">
                                        <button type="submit" class="btn btn-primary btn-sm">
                                            <i class="bi bi-check2-circle me-1"></i>Process Next
                                        </button>
                                    </form>
                                    <c:if test="${sessionScope.user.userType == 'ADMIN'}">
                                        <form action="${pageContext.request.contextPath}/booking/queue" method="post" class="ms-2">
                                            <input type="hidden" name="action" value="clear">
                                            <button type="submit" class="btn btn-outline-danger btn-sm"
                                                    onclick="return confirm('Are you sure you want to clear all queues?')">
                                                <i class="bi bi-trash3 me-1"></i>Clear All
                                            </button>
                                        </form>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>

                        <c:choose>
                            <c:when test="${not empty queuedBookings && queuedBookings.size() > 0}">
                                <c:forEach var="booking" items="${queuedBookings}" varStatus="status">
                                    <div class="queue-item">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div>
                                                <h5 class="mb-1">Queue Position #${status.index + 1}</h5>
                                                <p class="mb-1"><strong>Booking ID:</strong> ${booking.bookingId}</p>
                                                <p class="mb-1"><strong>Event Type:</strong> ${booking.eventType}</p>
                                                <p class="mb-1"><strong>Event Date:</strong>
                                                    <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                                    <fmt:formatDate value="${parsedDate}" pattern="MMM d, yyyy h:mm a" />
                                                </p>
                                                <p class="mb-1"><strong>Location:</strong> ${booking.eventLocation}</p>
                                                <p class="mb-0"><strong>Price:</strong> $${booking.totalPrice}</p>
                                            </div>
                                            <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER' || sessionScope.user.userType == 'ADMIN'}">
                                                <form action="${pageContext.request.contextPath}/booking/queue" method="post">
                                                    <input type="hidden" name="action" value="processSpecific">
                                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                                    <button type="submit" class="btn btn-success">
                                                        <i class="bi bi-check-circle me-1"></i>Approve
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="alert alert-info">
                                    <i class="bi bi-info-circle me-2"></i>
                                    <c:choose>
                                        <c:when test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">No pending bookings awaiting your approval.</c:when>
                                        <c:when test="${sessionScope.user.userType == 'CLIENT'}">You don't have any pending booking requests.</c:when>
                                        <c:otherwise>No bookings in the queue.</c:otherwise>
                                    </c:choose>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="card-section">
                        <h3 class="h5 mb-4">Queue Actions</h3>
                        <c:if test="${sessionScope.user.userType == 'CLIENT'}">
                            <div class="d-grid gap-2 mb-4">
                                <a href="${pageContext.request.contextPath}/booking.jsp?action=form" class="btn btn-primary">
                                    <i class="bi bi-calendar-plus me-2"></i>Create New Booking
                                </a>
                            </div>
                            <div class="alert alert-info">
                                <h6><i class="bi bi-info-circle me-2"></i>About the Booking Queue</h6>
                                <p class="mb-0">Your booking requests are queued and processed by photographers in order. You'll be notified once approved.</p>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                            <div class="card mb-4">
                                <div class="card-header">Batch Processing</div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/booking/queue" method="post">
                                        <input type="hidden" name="action" value="processBatch">
                                        <div class="mb-3">
                                            <label for="limit" class="form-label">Number of bookings to process:</label>
                                            <select class="form-select" id="limit" name="limit">
                                                <option value="1">1 booking</option>
                                                <option value="5" selected>5 bookings</option>
                                                <option value="10">10 bookings</option>
                                                <option value="20">20 bookings</option>
                                            </select>
                                        </div>
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="bi bi-lightning-charge me-1"></i>Process Batch
                                        </button>
                                    </form>
                                </div>
                            </div>
                            <div class="alert alert-info">
                                <h6><i class="bi bi-info-circle me-2"></i>Processing Tips</h6>
                                <p class="mb-0">Process bookings regularly to maintain client satisfaction. Approve individually or in batches.</p>
                            </div>
                        </c:if>

                        <c:if test="${sessionScope.user.userType == 'ADMIN'}">
                            <div class="card mb-4">
                                <div class="card-header">Advanced Queue Management</div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/booking/queue" method="post" class="mb-3">
                                        <input type="hidden" name="action" value="processBatch">
                                        <div class="mb-3">
                                            <label for="adminLimit" class="form-label">Batch process:</label>
                                            <select class="form-select" id="adminLimit" name="limit">
                                                <option value="5">5 bookings</option>
                                                <option value="10">10 bookings</option>
                                                <option value="20">20 bookings</option>
                                                <option value="100">All bookings</option>
                                            </select>
                                        </div>
                                        <button type="submit" class="btn btn-success w-100">
                                            <i class="bi bi-lightning-charge me-1"></i>Process Batch
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:if>

                        <div class="d-grid">
                            <a href="${pageContext.request.contextPath}/booking.jsp?action=list" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left me-2"></i>Back to Bookings
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:when>

        <!-- Cancel Booking -->
        <c:when test="${param.action == 'cancel'}">
            <div class="header-section">
                <h1 class="display-5">Cancel Booking</h1>
                <p class="lead">Confirm cancellation of your booking</p>
            </div>

            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card-section">
                        <div class="bg-danger text-white p-3 mb-4 rounded">
                            <h3 class="mb-0">Cancel Booking</h3>
                        </div>
                        <h5>Are you sure you want to cancel this booking?</h5>

                        <div class="details-section mb-4">
                            <h6>Booking Details:</h6>
                            <p><strong>Booking ID:</strong> ${booking.bookingId}</p>
                            <p><strong>Event Type:</strong> ${booking.eventType}</p>
                            <p><strong>Event Date:</strong>
                                <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                <fmt:formatDate value="${parsedDate}" pattern="MMM d, yyyy h:mm a" />
                            </p>
                            <p><strong>Location:</strong> ${booking.eventLocation}</p>
                        </div>

                        <form action="${pageContext.request.contextPath}/booking/cancel" method="post">
                            <input type="hidden" name="bookingId" value="${param.id}">
                            <div class="mb-3">
                                <label for="cancellationReason" class="form-label">Reason for cancellation:</label>
                                <textarea class="form-control" id="cancellationReason" name="cancellationReason" rows="3"></textarea>
                            </div>
                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="confirmedCancel" name="confirmedCancel" value="yes" required>
                                <label class="form-check-label" for="confirmedCancel">I confirm cancellation</label>
                            </div>
                            <div class="d-grid gap-2 d-md-flex">
                                <button type="submit" class="btn btn-danger">
                                    <i class="bi bi-x-circle me-2"></i>Cancel Booking
                                </button>
                                <a href="${pageContext.request.contextPath}/booking.jsp?action=details&id=${param.id}" class="btn btn-secondary">
                                    <i class="bi bi-arrow-left me-2"></i>Go Back
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </c:when>

        <!-- Default: Redirect to List -->
        <c:otherwise>
            <c:redirect url="/booking.jsp?action=list"/>
        </c:otherwise>
    </c:choose>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Booking Form: Update photographer/service selection
        const photographerSelect = document.getElementById('photographerId');
        const serviceSelect = document.getElementById('serviceId');
        if (photographerSelect) {
            photographerSelect.addEventListener('change', function() {
                window.location.href = '${pageContext.request.contextPath}/booking.jsp?action=form&photographerId=' + this.value;
            });
        }
        if (serviceSelect) {
            serviceSelect.addEventListener('change', function() {
                if (this.value) {
                    const photographerId = photographerSelect ? photographerSelect.value : '';
                    window.location.href = '${pageContext.request.contextPath}/booking.jsp?action=form&photographerId=' + photographerId + '&serviceId=' + this.value;
                }
            });
        }

        // Booking List: Filter table
        const statusFilter = document.getElementById('statusFilter');
        const searchInput = document.getElementById('searchInput');
        const bookingsTable = document.getElementById('bookingsTable');
        if (statusFilter && searchInput && bookingsTable) {
            statusFilter.addEventListener('change', filterTable);
            searchInput.addEventListener('keyup', filterTable);

            function filterTable() {
                const status = statusFilter.value.toLowerCase();
                const search = searchInput.value.toLowerCase();
                const rows = bookingsTable.getElementsByTagName('tr');
                for (let i = 1; i < rows.length; i++) {
                    const row = rows[i];
                    const cells = row.getElementsByTagName('td');
                    let showRow = true;

                    if (status) {
                        const statusBadge = cells[cells.length - 2].querySelector('.badge');
                        if (statusBadge && statusBadge.textContent.toLowerCase() !== status) {
                            showRow = false;
                        }
                    }

                    if (search && showRow) {
                        let rowText = '';
                        for (let j = 0; j < cells.length; j++) {
                            rowText += cells[j].textContent.toLowerCase() + ' ';
                        }
                        if (!rowText.includes(search)) {
                            showRow = false;
                        }
                    }

                    row.style.display = showRow ? '' : 'none';
                }
            }
        }
    });
</script>
</body>
</html>