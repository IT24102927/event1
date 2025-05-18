<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${photographer.businessName} - SnapEvent</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
  <style>
    .photographer-banner {
      height: 250px;
      background-color: #f8f9fa;
      background-size: cover;
      background-position: center;
    }
    .profile-image {
      width: 150px;
      height: 150px;
      border-radius: 50%;
      border: 5px solid #fff;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
      margin-top: -75px;
      background-color: #f0f0f0;
    }
    .rating-display {
      color: #ffcc00;
    }
    .rating-distribution .progress {
      height: 10px;
    }
    .specialties-badge {
      margin-right: 5px;
      margin-bottom: 5px;
    }
    .photographer-response {
      background-color: #f8f9fa;
      border-left: 3px solid #6c757d;
      padding: 15px;
      margin-top: 10px;
    }
  </style>
</head>
<body>
<jsp:include page="../includes/header.jsp" />

<div class="photographer-banner" style="background-color: #343a40;">
</div>

<div class="container mt-3">
  <jsp:include page="../includes/messages.jsp" />

  <div class="row">
    <!-- Profile Information -->
    <div class="col-lg-4 text-center text-lg-start">
      <div class="d-flex flex-column align-items-center align-items-lg-start">
        <div class="profile-image d-flex align-items-center justify-content-center">
          <i class="bi bi-camera text-secondary" style="font-size: 50px;"></i>
        </div>
        <h2 class="mt-3">${photographer.businessName}</h2>
        <div class="d-flex align-items-center mb-2">
          <div class="rating-display me-2">
            <c:forEach begin="1" end="5" var="i">
              <i class="bi ${i <= photographer.rating ? 'bi-star-fill' : 'bi-star'}"></i>
            </c:forEach>
          </div>
          <span>${photographer.rating} (${photographer.reviewCount} reviews)</span>
        </div>
        <p class="text-muted">
          <i class="bi bi-geo-alt"></i> ${photographer.location}
        </p>

        <div class="d-grid gap-2 col-12 mt-3">
          <c:if test="${sessionScope.userType == 'client'}">
            <a href="${pageContext.request.contextPath}/booking/booking_form.jsp?photographerId=${photographer.photographerId}"
               class="btn btn-primary">
              <i class="bi bi-calendar-plus"></i> Book Now
            </a>
            <a href="${pageContext.request.contextPath}/review/add?photographerId=${photographer.photographerId}"
               class="btn btn-outline-primary">
              <i class="bi bi-star"></i> Write a Review
            </a>
          </c:if>
          <a href="#services" class="btn btn-outline-secondary">
            <i class="bi bi-camera"></i> View Services
          </a>
        </div>
      </div>

      <div class="card mt-4">
        <div class="card-header">
          <h5 class="mb-0">Contact Information</h5>
        </div>
        <div class="card-body">
          <ul class="list-group list-group-flush">
            <li class="list-group-item border-0 ps-0">
              <i class="bi bi-envelope me-2"></i> ${photographer.email}
            </li>
            <c:if test="${not empty photographer.contactPhone}">
              <li class="list-group-item border-0 ps-0">
                <i class="bi bi-telephone me-2"></i> ${photographer.contactPhone}
              </li>
            </c:if>
            <c:if test="${not empty photographer.websiteUrl}">
              <li class="list-group-item border-0 ps-0">
                <i class="bi bi-globe me-2"></i>
                <a href="${photographer.websiteUrl}" target="_blank">${photographer.websiteUrl}</a>
              </li>
            </c:if>
          </ul>
        </div>
      </div>
    </div>

    <!--  About and Services -->
    <div class="col-lg-8 mt-4 mt-lg-0">
      <div class="card mb-4">
        <div class="card-header">
          <h4 class="mb-0">About Me</h4>
        </div>
        <div class="card-body">
          <p>${photographer.biography}</p>

          <ul class="list-group list-group-flush">
            <c:if test="${photographer.yearsOfExperience > 0}">
              <li class="list-group-item border-0 ps-0">
                <strong>Experience:</strong> ${photographer.yearsOfExperience} years
              </li>
            </c:if>
            <c:if test="${not empty photographer.specialties}">
              <li class="list-group-item border-0 ps-0">
                <strong>Specialties:</strong>
                <c:forEach var="specialty" items="${photographer.specialties}" varStatus="status">
                  ${specialty}<c:if test="${!status.last}">, </c:if>
                </c:forEach>
              </li>
            </c:if>
          </ul>
        </div>
      </div>

      <!-- Services Section -->
      <div class="card mb-4" id="services">
        <div class="card-header">
          <h4 class="mb-0">Services</h4>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${empty services}">
              <p class="text-muted">No services available at the moment.</p>
            </c:when>
            <c:otherwise>
              <div class="row">
                <c:forEach var="service" items="${services}">
                  <div class="col-md-6 mb-4">
                    <div class="card h-100">
                      <div class="card-header bg-light">
                        <h5 class="mb-0">${service.name}</h5>
                        <p class="mb-0 text-primary fw-bold">$${service.price}</p>
                      </div>
                      <div class="card-body">
                        <p class="card-text">${service.description}</p>
                        <c:if test="${not empty service.features}">
                          <h6>Features:</h6>
                          <ul>
                            <c:forEach var="feature" items="${service.features}">
                              <li>${feature}</li>
                            </c:forEach>
                          </ul>
                        </c:if>
                        <p><strong>Duration:</strong> ${service.durationHours} hours</p>
                        <c:if test="${not empty service.deliverables}">
                          <p><strong>Deliverables:</strong> ${service.deliverables}</p>
                        </c:if>
                      </div>
                      <div class="card-footer">
                        <a href="${pageContext.request.contextPath}/booking/booking_form.jsp?photographerId=${photographer.photographerId}&serviceId=${service.serviceId}"
                           class="btn btn-primary btn-sm">Book Now</a>
                      </div>
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <!-- Reviews Section -->
      <div class="card mt-4">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h4 class="mb-0">Reviews</h4>
          <c:if test="${sessionScope.userType == 'client'}">
            <a href="${pageContext.request.contextPath}/review/add?photographerId=${photographer.photographerId}"
               class="btn btn-primary">Write a Review</a>
          </c:if>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${empty reviews}">
              <p class="text-muted">No reviews yet. Be the first to review this photographer!</p>
            </c:when>
            <c:otherwise>
              <!-- Display a few recent reviews -->
              <div class="rating-summary mb-4">
                <div class="d-flex align-items-center mb-2">
                  <div class="rating-display me-2">
                    <c:forEach begin="1" end="5" var="i">
                      <i class="bi ${i <= averageRating ? 'bi-star-fill' : 'bi-star'}"></i>
                    </c:forEach>
                  </div>
                  <span class="fw-bold h4 mb-0">${averageRating}</span>
                  <span class="text-muted ms-2">(${reviews.size()} reviews)</span>
                </div>

                <!-- Rating distribution bars - Fixed version without negative step -->
                <div class="rating-distribution">
                  <!-- Using 5 separate elements instead of a loop with negative step -->
                  <div class="d-flex align-items-center mb-1">
                    <div class="me-2" style="width: 35px;">
                      5 <i class="bi bi-star-fill rating-display"></i>
                    </div>
                    <div class="progress flex-grow-1" style="height: 8px;">
                      <div class="progress-bar bg-warning" role="progressbar"
                           style="width: ${reviews.size() > 0 ? ratingDistribution[4] * 100 / reviews.size() : 0}%"
                           aria-valuenow="${ratingDistribution[4]}"
                           aria-valuemin="0" aria-valuemax="${reviews.size()}"></div>
                    </div>
                    <div class="ms-2" style="width: 30px;">${ratingDistribution[4]}</div>
                  </div>
                  <div class="d-flex align-items-center mb-1">
                    <div class="me-2" style="width: 35px;">
                      4 <i class="bi bi-star-fill rating-display"></i>
                    </div>
                    <div class="progress flex-grow-1" style="height: 8px;">
                      <div class="progress-bar bg-warning" role="progressbar"
                           style="width: ${reviews.size() > 0 ? ratingDistribution[3] * 100 / reviews.size() : 0}%"
                           aria-valuenow="${ratingDistribution[3]}"
                           aria-valuemin="0" aria-valuemax="${reviews.size()}"></div>
                    </div>
                    <div class="ms-2" style="width: 30px;">${ratingDistribution[3]}</div>
                  </div>
                  <div class="d-flex align-items-center mb-1">
                    <div class="me-2" style="width: 35px;">
                      3 <i class="bi bi-star-fill rating-display"></i>
                    </div>
                    <div class="progress flex-grow-1" style="height: 8px;">
                      <div class="progress-bar bg-warning" role="progressbar"
                           style="width: ${reviews.size() > 0 ? ratingDistribution[2] * 100 / reviews.size() : 0}%"
                           aria-valuenow="${ratingDistribution[2]}"
                           aria-valuemin="0" aria-valuemax="${reviews.size()}"></div>
                    </div>
                    <div class="ms-2" style="width: 30px;">${ratingDistribution[2]}</div>
                  </div>
                  <div class="d-flex align-items-center mb-1">
                    <div class="me-2" style="width: 35px;">
                      2 <i class="bi bi-star-fill rating-display"></i>
                    </div>
                    <div class="progress flex-grow-1" style="height: 8px;">
                      <div class="progress-bar bg-warning" role="progressbar"
                           style="width: ${reviews.size() > 0 ? ratingDistribution[1] * 100 / reviews.size() : 0}%"
                           aria-valuenow="${ratingDistribution[1]}"
                           aria-valuemin="0" aria-valuemax="${reviews.size()}"></div>
                    </div>
                    <div class="ms-2" style="width: 30px;">${ratingDistribution[1]}</div>
                  </div>
                  <div class="d-flex align-items-center mb-1">
                    <div class="me-2" style="width: 35px;">
                      1 <i class="bi bi-star-fill rating-display"></i>
                    </div>
                    <div class="progress flex-grow-1" style="height: 8px;">
                      <div class="progress-bar bg-warning" role="progressbar"
                           style="width: ${reviews.size() > 0 ? ratingDistribution[0] * 100 / reviews.size() : 0}%"
                           aria-valuenow="${ratingDistribution[0]}"
                           aria-valuemin="0" aria-valuemax="${reviews.size()}"></div>
                    </div>
                    <div class="ms-2" style="width: 30px;">${ratingDistribution[0]}</div>
                  </div>
                </div>
              </div>

              <!-- Recent reviews -->
              <h5 class="mb-3">Recent Reviews</h5>
              <c:forEach var="review" items="${reviews}" begin="0" end="2">
                <div class="review-item mb-3 pb-3 border-bottom">
                  <div class="d-flex justify-content-between mb-2">
                    <div>
                      <h6>${userManager.getUserById(review.clientId).fullName}</h6>
                      <div class="rating-display">
                        <c:forEach begin="1" end="5" var="i">
                          <i class="bi ${i <= review.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                        </c:forEach>
                      </div>
                    </div>
                    <div class="text-muted">
                      <small>
                        <fmt:parseDate value="${review.reviewDate}"
                                       pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                        <fmt:formatDate value="${parsedDate}"
                                        pattern="MMM d, yyyy" />
                      </small>
                    </div>
                  </div>

                  <p class="mb-1"><span class="badge bg-secondary">${review.serviceType}</span></p>
                  <p>${review.comment}</p>

                  <c:if test="${review.hasResponse}">
                    <div class="photographer-response">
                      <h6 class="mb-1">Response from ${photographer.businessName}</h6>
                      <p class="mb-1">${review.responseText}</p>
                      <small class="text-muted">
                        <fmt:parseDate value="${review.responseDate}"
                                       pattern="yyyy-MM-dd'T'HH:mm" var="parsedRespDate" />
                        <fmt:formatDate value="${parsedRespDate}"
                                        pattern="MMM d, yyyy" />
                      </small>
                    </div>
                  </c:if>
                </div>
              </c:forEach>

              <a href="${pageContext.request.contextPath}/photographer/reviews?id=${photographer.photographerId}"
                 class="btn btn-outline-primary">See All Reviews</a>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
