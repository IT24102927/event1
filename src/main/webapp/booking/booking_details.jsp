<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.photobooking.model.booking.BookingManager" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.user.UserManager" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="com.photobooking.model.photographer.PhotographerManager" %>
<%@ page import="com.photobooking.model.photographer.Photographer" %>
<%@ page import="com.photobooking.model.photographer.PhotographerServiceManager" %>
<%@ page import="com.photobooking.model.photographer.PhotographerService" %>

<%
  String bookingId = request.getParameter("id");
  if (bookingId == null || bookingId.trim().isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
    return;
  }

  BookingManager bookingManager = new BookingManager();
  Booking booking = bookingManager.getBookingById(bookingId);

  if (booking == null) {
    session.setAttribute("errorMessage", "Booking not found");
    response.sendRedirect(request.getContextPath() + "/booking/booking_list.jsp");
    return;
  }

  // Get user details
  UserManager userManager = new UserManager(getServletContext());
  User client = userManager.getUserById(booking.getClientId());
  User photographer = userManager.getUserById(booking.getPhotographerId());

  // Get photographer details
  PhotographerManager photographerManager = new PhotographerManager();
  Photographer photographerDetails = photographerManager.getPhotographerByUserId(booking.getPhotographerId());

  // Get service details if available
  PhotographerServiceManager serviceManager = new PhotographerServiceManager();
  PhotographerService service = null;
  if (booking.getServiceId() != null && photographerDetails != null) {
    service = serviceManager.getServiceById(booking.getServiceId());
  }

  request.setAttribute("booking", booking);
  request.setAttribute("client", client);
  request.setAttribute("photographer", photographer);
  request.setAttribute("photographerDetails", photographerDetails);
  request.setAttribute("service", service);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Booking Details - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container mt-4">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <div class="row">
    <div class="col-lg-8">
      <div class="card mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h3 class="card-title mb-0">Booking Details</h3>
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
        <div class="card-body">
          <div class="row mb-3">
            <div class="col-sm-3">
              <strong>Booking ID:</strong>
            </div>
            <div class="col-sm-9">
              ${booking.bookingId}
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-sm-3">
              <strong>Event Type:</strong>
            </div>
            <div class="col-sm-9">
              ${booking.eventType}
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-sm-3">
              <strong>Event Date:</strong>
            </div>
            <div class="col-sm-9">
              ${booking.eventDateTime}
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-sm-3">
              <strong>Location:</strong>
            </div>
            <div class="col-sm-9">
              ${booking.eventLocation}
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-sm-3">
              <strong>Total Price:</strong>
            </div>
            <div class="col-sm-9">
              $${booking.totalPrice}
            </div>
          </div>
          <c:if test="${not empty booking.eventNotes}">
            <div class="row mb-3">
              <div class="col-sm-3">
                <strong>Notes:</strong>
              </div>
              <div class="col-sm-9">
                  ${booking.eventNotes}
              </div>
            </div>
          </c:if>
        </div>
      </div>

      <!-- Service Details -->
      <c:if test="${not empty service}">
        <div class="card mb-4">
          <div class="card-header">
            <h4 class="card-title mb-0">Service Package</h4>
          </div>
          <div class="card-body">
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

      <!-- Actions -->
      <div class="card">
        <div class="card-body">
          <h5 class="card-title">Actions</h5>
          <div class="btn-group">
            <c:if test="${booking.status != 'CANCELLED' && booking.status != 'COMPLETED'}">
              <c:if test="${sessionScope.user.userId == booking.clientId || sessionScope.user.userId == booking.photographerId || sessionScope.user.userType == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/booking/cancel?id=${booking.bookingId}"
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

            <c:if test="${booking.status != 'CANCELLED' && booking.status != 'COMPLETED'
                          && (sessionScope.user.userId == booking.clientId
                              || sessionScope.user.userId == booking.photographerId
                              || sessionScope.user.userType == 'ADMIN')}">
              <a href="${pageContext.request.contextPath}/booking/modify?id=${booking.bookingId}"
                 class="btn btn-outline-secondary">
                <i class="bi bi-pencil-square me-1"></i>Modify Booking
              </a>
            </c:if>
          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-4">
      <!-- Photographer Details -->
      <c:if test="${sessionScope.user.userId == booking.clientId && not empty photographerDetails}">
        <div class="card mb-4">
          <div class="card-header">
            <h4 class="card-title mb-0">Photographer Details</h4>
          </div>
          <div class="card-body">
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
        </div>
      </c:if>

      <!-- Client Details -->
      <c:if test="${sessionScope.user.userId == booking.photographerId && not empty client}">
        <div class="card mb-4">
          <div class="card-header">
            <h4 class="card-title mb-0">Client Details</h4>
          </div>
          <div class="card-body">
            <h5>${client.fullName}</h5>
            <p><i class="bi bi-envelope me-2"></i>${client.email}</p>
          </div>
        </div>
      </c:if>

      <!-- Navigation -->
      <div class="d-grid gap-2">
        <a href="${pageContext.request.contextPath}/booking/booking_list.jsp" class="btn btn-secondary">
          <i class="bi bi-arrow-left me-2"></i>Back to Bookings
        </a>
      </div>
    </div>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>