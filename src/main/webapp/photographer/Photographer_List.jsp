<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Find Photographers - SnapEvent</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
  <style>
    .photographer-card {
      transition: transform 0.3s;
      height: 100%;
      margin-bottom: 20px;
    }
    .photographer-card:hover {
      transform: translateY(-5px);
    }
    .photographer-thumbnail {
      height: 200px;
      object-fit: cover;
    }
    .filter-form {
      background-color: #f8f9fa;
      border-radius: 8px;
      padding: 15px;
      margin-bottom: 20px;
    }
    .rating-display {
      color: #ffcc00;
    }
    .specialty-badge {
      margin-right: 5px;
      margin-bottom: 5px;
    }
    .search-container {
      background-color: #f8f9fa;
      padding: 30px 0;
      margin-bottom: 30px;
    }
  </style>
</head>
<body>
<jsp:include page="../includes/header.jsp" />

<!--  Search Section -->
<div class="search-container">
  <div class="container">
    <h1 class="mb-4">Find Your Perfect Photographer</h1>

    <form action="${pageContext.request.contextPath}/photographer/list" method="get" class="mb-4">
      <div class="row g-3">
        <div class="col-md-6">
          <div class="input-group">
            <span class="input-group-text"><i class="bi bi-search"></i></span>
            <input type="text" class="form-control" name="search" placeholder="Search by name, specialty, or location..."
                   value="${param.search}">
          </div>
        </div>
        <div class="col-md-4">
          <select name="specialty" class="form-select">
            <option value="">All Specialties</option>
            <c:forEach var="specialty" items="${specialties}">
              <option value="${specialty}" ${param.specialty == specialty ? 'selected' : ''}>
                  ${specialty}
              </option>
            </c:forEach>
          </select>
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100">Search</button>
        </div>
      </div>
    </form>
  </div>
</div>

<div class="container">
  <jsp:include page="../includes/messages.jsp" />

  <!-- Debug info - uncomment if needed -->
  <div class="alert alert-secondary mb-3">
    Photographers count: ${photographers.size()}
    ${debugInfo}
  </div>

  <div class="row">
    <!-- Filters Sidebar -->
    <div class="col-lg-3">
      <div class="filter-form">
        <h5>Filter Photographers</h5>
        <form action="${pageContext.request.contextPath}/photographer/list" method="get" id="filterForm">
          <input type="hidden" name="search" value="${param.search}">
          <input type="hidden" name="specialty" value="${param.specialty}">

          <div class="mb-3">
            <label class="form-label">Location</label>
            <input type="text" class="form-control" name="location" placeholder="Enter location"
                   value="${param.location}" onchange="document.getElementById('filterForm').submit()">
          </div>

          <div class="mb-3">
            <label class="form-label">Sort By</label>
            <select class="form-select" name="sortBy" onchange="document.getElementById('filterForm').submit()">
              <option value="rating-desc" ${param.sortBy == 'rating-desc' || param.sortBy == null ? 'selected' : ''}>
                Highest Rating
              </option>
              <option value="price-asc" ${param.sortBy == 'price-asc' ? 'selected' : ''}>
                Price: Low to High
              </option>
              <option value="price-desc" ${param.sortBy == 'price-desc' ? 'selected' : ''}>
                Price: High to Low
              </option>
              <option value="experience-desc" ${param.sortBy == 'experience-desc' ? 'selected' : ''}>
                Most Experienced
              </option>
              <option value="name-asc" ${param.sortBy == 'name-asc' ? 'selected' : ''}>
                Name: A to Z
              </option>
            </select>
          </div>

          <div class="d-grid">
            <a href="${pageContext.request.contextPath}/photographer/list" class="btn btn-outline-secondary">
              Clear Filters
            </a>
          </div>
        </form>
      </div>
    </div>

    <!-- Photographers List -->
    <div class="col-lg-9">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Photographers</h2>
        <div>
          <span>Page ${currentPage} of ${totalPages}</span>
        </div>
      </div>

      <c:choose>
        <c:when test="${not empty photographers}">
          <div class="row">
            <c:forEach var="photographer" items="${photographers}">
              <div class="col-md-6 col-lg-4 mb-4">
                <div class="card photographer-card h-100">
                  <!-- Default image -->
                  <div class="bg-light d-flex justify-content-center align-items-center photographer-thumbnail">
                    <i class="bi bi-camera" style="font-size: 50px; color: #6c757d;"></i>
                  </div>
                  <div class="card-body">
                    <h5 class="card-title">
                      <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographer.photographerId}"
                         class="text-decoration-none">
                          ${photographer.businessName}
                      </a>
                    </h5>
                    <p class="card-text text-muted">
                      <i class="bi bi-geo-alt me-1"></i>${photographer.location}
                    </p>
                    <div class="d-flex align-items-center mb-2">
                      <div class="rating-display me-2">
                        <c:forEach begin="1" end="5" var="i">
                          <i class="bi ${i <= photographer.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                        </c:forEach>
                      </div>
                      <span>${photographer.rating} (${photographer.reviewCount})</span>
                    </div>
                    <p class="card-text">
                      <small class="text-muted">
                        <c:if test="${photographer.yearsOfExperience > 0}">
                          <i class="bi bi-calendar-check me-1"></i>
                          ${photographer.yearsOfExperience} years experience
                        </c:if>
                      </small>
                    </p>

                    <!-- Safely display specialties -->
                    <c:if test="${not empty photographer.specialties}">
                      <div class="mb-3">
                        <c:forEach var="specialty" items="${photographer.specialties}" varStatus="status">
                          <c:if test="${status.index < 3}">
                            <span class="badge bg-secondary me-1">${specialty}</span>
                          </c:if>
                        </c:forEach>
                      </div>
                    </c:if>

                    <div class="d-grid">
                      <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographer.photographerId}"
                         class="btn btn-outline-primary">View Profile</a>
                    </div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>

          <!-- Pagination -->
          <c:if test="${totalPages > 1}">
            <nav aria-label="Page navigation" class="mt-4">
              <ul class="pagination justify-content-center">
                <!-- Previous page link -->
                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/photographer/list?page=${currentPage - 1}&search=${param.search}&specialty=${param.specialty}&location=${param.location}&sortBy=${param.sortBy}"
                     aria-label="Previous">
                    <span aria-hidden="true">&laquo;</span>
                  </a>
                </li>

                <!-- Page number links -->
                <c:forEach begin="1" end="${totalPages}" var="i">
                  <li class="page-item ${currentPage == i ? 'active' : ''}">
                    <a class="page-link" href="${pageContext.request.contextPath}/photographer/list?page=${i}&search=${param.search}&specialty=${param.specialty}&location=${param.location}&sortBy=${param.sortBy}">
                        ${i}
                    </a>
                  </li>
                </c:forEach>

                <!-- Next page link -->
                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                  <a class="page-link" href="${pageContext.request.contextPath}/photographer/list?page=${currentPage + 1}&search=${param.search}&specialty=${param.specialty}&location=${param.location}&sortBy=${param.sortBy}"
                     aria-label="Next">
                    <span aria-hidden="true">&raquo;</span>
                  </a>
                </li>
              </ul>
            </nav>
          </c:if>
        </c:when>
        <c:otherwise>
          <div class="alert alert-info">
            No photographers found matching your criteria. Please try different filters.
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
