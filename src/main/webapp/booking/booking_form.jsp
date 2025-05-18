<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.photobooking.model.photographer.PhotographerManager" %>
<%@ page import="com.photobooking.model.photographer.Photographer" %>
<%@ page import="com.photobooking.model.photographer.PhotographerServiceManager" %>
<%@ page import="com.photobooking.model.photographer.PhotographerService" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>

<%
  // Check if user is logged in
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null) {
    session.setAttribute("errorMessage", "Please login to book a photographer");
    response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    return;
  }

  // Get photographer ID and service ID from request
  String photographerId = request.getParameter("photographerId");
  String serviceId = request.getParameter("serviceId");

  // Initialize managers
  PhotographerManager photographerManager = new PhotographerManager(application);
  PhotographerServiceManager serviceManager = new PhotographerServiceManager(application);

  // Get all photographers for selection dropdown
  List<Photographer> allPhotographers = photographerManager.getAllPhotographers();

  // Get selected photographer (if any)
  Photographer selectedPhotographer = null;
  List<PhotographerService> services = null;

  if (photographerId != null && !photographerId.isEmpty()) {
    selectedPhotographer = photographerManager.getPhotographerById(photographerId);
    if (selectedPhotographer != null) {
      // Get services for the selected photographer
      services = serviceManager.getActiveServicesByPhotographer(photographerId);
    }
  }

  // Get selected service (if any)
  PhotographerService selectedService = null;
  if (serviceId != null && !serviceId.isEmpty() && services != null) {
    for (PhotographerService service : services) {
      if (service.getServiceId().equals(serviceId)) {
        selectedService = service;
        break;
      }
    }
  }

  // Set minimum date for booking (tomorrow)
  LocalDate tomorrow = LocalDate.now().plusDays(1);

  // Set attributes for JSP
  request.setAttribute("allPhotographers", allPhotographers);
  request.setAttribute("selectedPhotographer", selectedPhotographer);
  request.setAttribute("services", services);
  request.setAttribute("selectedService", selectedService);
  request.setAttribute("minDate", tomorrow);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Photography Session - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <!-- Custom CSS -->
  <style>
    .booking-header {
      background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
      color: white;
      padding: 30px 0;
      margin-bottom: 30px;
      border-radius: 0 0 10px 10px;
    }

    .booking-card {
      background-color: white;
      border-radius: 10px;
      box-shadow: 0 0 20px rgba(0,0,0,0.05);
      padding: 30px;
      margin-bottom: 30px;
    }

    .package-details {
      background-color: #f8f9fa;
      border-radius: 10px;
      padding: 20px;
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

<!-- Booking Header -->
<div class="booking-header">
  <div class="container">
    <h1 class="display-5">Book Photography Session</h1>
    <p class="lead">Complete the form below to book your photography session</p>
  </div>
</div>

<div class="container">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <div class="row">
    <div class="col-lg-8">
      <div class="booking-card">
        <h3 class="mb-4">Booking Details</h3>

        <form action="${pageContext.request.contextPath}/booking/create-booking" method="post" id="bookingForm">
          <!-- Photographer Selection -->
          <div class="mb-4">
            <label for="photographerId" class="form-label">Select Photographer</label>
            <select class="form-select" id="photographerId" name="photographerId" required>
              <option value="" disabled ${empty selectedPhotographer ? 'selected' : ''}>
                Select a photographer...
              </option>
              <c:forEach var="photographer" items="${allPhotographers}">
                <option value="${photographer.photographerId}"
                  ${selectedPhotographer != null && photographer.photographerId == selectedPhotographer.photographerId ? 'selected' : ''}>
                    ${photographer.businessName}
                </option>
              </c:forEach>
            </select>
          </div>

          <!-- Service/Package Selection -->
          <div class="mb-4">
            <label for="serviceId" class="form-label">Select Package</label>
            <select class="form-select" id="serviceId" name="serviceId" required>
              <option value="" selected disabled>
                ${empty services ? 'Please select a photographer first' : 'Select a package...'}
              </option>
              <c:if test="${not empty services}">
                <c:forEach var="service" items="${services}">
                  <option value="${service.serviceId}"
                    ${selectedService != null && service.serviceId == selectedService.serviceId ? 'selected' : ''}>
                      ${service.name} - $${service.price}
                  </option>
                </c:forEach>
              </c:if>
            </select>
          </div>

          <!-- Event Details -->
          <h4 class="mt-5 mb-3">Event Details</h4>

          <div class="row mb-3">
            <div class="col-md-6">
              <label for="eventDate" class="form-label">Event Date</label>
              <input type="date" class="form-control" id="eventDate" name="eventDate" required
                     min="${minDate}">
            </div>
            <div class="col-md-6">
              <label for="eventTime" class="form-label">Start Time</label>
              <input type="time" class="form-control" id="eventTime" name="eventTime" required>
            </div>
          </div>

          <div class="mb-3">
            <label for="eventLocation" class="form-label">Event Location</label>
            <input type="text" class="form-control" id="eventLocation" name="eventLocation"
                   placeholder="Address or venue name" required>
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
            <textarea class="form-control" id="eventNotes" name="eventNotes" rows="4"
                      placeholder="Any special requirements or details the photographer should know"></textarea>
          </div>

          <!-- Submit Button -->
          <div class="d-grid gap-2 mt-5">
            <button type="submit" class="btn btn-primary btn-lg">
              <i class="bi bi-calendar-check me-2"></i>Book Now
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Package Details Sidebar -->
    <div class="col-lg-4">
      <c:if test="${not empty selectedPhotographer}">
        <div class="booking-card">
          <h4 class="mb-3">Photographer</h4>
          <div class="d-flex align-items-center mb-3">
            <img src="${pageContext.request.contextPath}/assets/images/default-photographer.jpg"
                 alt="${selectedPhotographer.businessName}"
                 class="rounded-circle me-3"
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
        <div class="booking-card">
          <h4 class="mb-3">Selected Package</h4>
          <div class="package-details">
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

      <!-- Booking Tips -->
      <div class="booking-card">
        <h4 class="mb-3">Booking Tips</h4>
        <ul class="list-group list-group-flush">
          <li class="list-group-item border-0 ps-0">
            <i class="bi bi-calendar3 text-primary me-2"></i>
            Book at least 2-4 weeks in advance for best availability
          </li>
          <li class="list-group-item border-0 ps-0">
            <i class="bi bi-clock text-primary me-2"></i>
            Consider golden hour (sunrise/sunset) for outdoor shoots
          </li>
          <li class="list-group-item border-0 ps-0">
            <i class="bi bi-geo-alt text-primary me-2"></i>
            Provide detailed location information to help the photographer prepare
          </li>
          <li class="list-group-item border-0 ps-0">
            <i class="bi bi-chat-text text-primary me-2"></i>
            Include special requirements in the notes section
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Update packages when photographer is selected
    document.getElementById('photographerId').addEventListener('change', function() {
      // Redirect to same page with new photographer parameter
      window.location.href = '${pageContext.request.contextPath}/booking/booking_form.jsp?photographerId=' + this.value;
    });

    // Update sidebar when service is selected
    document.getElementById('serviceId').addEventListener('change', function() {
      if (this.value) {
        // Redirect with both photographer and service
        const photographerId = document.getElementById('photographerId').value;
        window.location.href = '${pageContext.request.contextPath}/booking/booking_form.jsp?photographerId=' +
                photographerId + '&serviceId=' + this.value;
      }
    });
  });
</script>
</body>
</html>