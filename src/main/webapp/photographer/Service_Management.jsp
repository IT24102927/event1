<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.photobooking.model.photographer.PhotographerServiceManager" %>
<%@ page import="com.photobooking.model.photographer.PhotographerService" %>
<%@ page import="com.photobooking.model.photographer.PhotographerManager" %>
<%@ page import="com.photobooking.model.photographer.Photographer" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="java.util.List" %>

<%
  // Get current user from session
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    return;
  }

  // Check if user is a photographer
  if (currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
    session.setAttribute("errorMessage", "Access denied. Only photographers can access this page.");
    response.sendRedirect(request.getContextPath() + "/user/dashboard.jsp");
    return;
  }

  // Get photographerId from session or from the database
  String photographerId = (String) session.getAttribute("photographerId");
  if (photographerId == null) {
    // Try to get photographer ID from database
    PhotographerManager photographerManager = new PhotographerManager();
    Photographer photographer = photographerManager.getPhotographerByUserId(currentUser.getUserId());

    if (photographer != null) {
      photographerId = photographer.getPhotographerId();
      session.setAttribute("photographerId", photographerId);
    } else {
      session.setAttribute("errorMessage", "Photographer profile not found. Please create one first.");
      response.sendRedirect(request.getContextPath() + "/photographer/register.jsp");
      return;
    }
  }

  // Load services for this photographer
  PhotographerServiceManager serviceManager = new PhotographerServiceManager();
  List<PhotographerService> services = serviceManager.getServicesByPhotographer(photographerId);

  // Set services as request attribute to access in JSP
  request.setAttribute("services", services);
  request.setAttribute("photographerId", photographerId);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Service Management - SnapEvent</title>

  <!-- Favicon -->
  <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon">

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Custom CSS -->
  <style>
    body {
      font-family: 'Poppins', sans-serif;
      background-color: #f8f9fa;
    }

    .service-management-container {
      padding: 20px;
    }

    .section-header {
      background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
      color: white;
      padding: 20px;
      border-radius: 10px;
      margin-bottom: 20px;
    }

    .content-card {
      background-color: white;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
      padding: 20px;
      margin-bottom: 20px;
    }

    .card-header-custom {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      border-bottom: 1px solid #eee;
      padding-bottom: 15px;
    }

    .card-title-custom {
      font-weight: 600;
      color: #4361ee;
      margin-bottom: 0;
    }

    .service-card {
      border: 1px solid #eee;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 20px;
      position: relative;
    }

    .service-card:hover {
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .service-actions {
      position: absolute;
      top: 15px;
      right: 15px;
      display: flex;
      gap: 5px;
    }

    .service-price {
      font-size: 1.5rem;
      font-weight: 600;
      color: #4361ee;
      margin-bottom: 10px;
    }

    .service-description {
      color: #6c757d;
      margin-bottom: 15px;
    }

    .service-detail {
      margin-bottom: 5px;
    }

    .service-status {
      position: absolute;
      top: 20px;
      right: 20px;
    }

    .badge-custom {
      font-size: 0.8rem;
      padding: 5px 10px;
      border-radius: 20px;
    }

    .nav-link.active {
      background-color: #4361ee;
      color: white !important;
      border-radius: 0.25rem;
    }

    .btn-primary-custom {
      background-color: #4361ee;
      border-color: #4361ee;
    }

    .btn-primary-custom:hover {
      background-color: #3a56d4;
      border-color: #3a56d4;
    }

    .btn-outline-custom {
      color: #4361ee;
      border-color: #4361ee;
    }

    .btn-outline-custom:hover {
      background-color: #4361ee;
      color: white;
    }

    /* Package Features List */
    .package-features {
      margin-top: 15px;
      margin-bottom: 20px;
    }

    .package-features ul {
      padding-left: 20px;
      list-style-type: none;
    }

    .package-features ul li {
      position: relative;
      padding-left: 25px;
      margin-bottom: 8px;
    }

    .package-features ul li:before {
      content: "✓";
      position: absolute;
      left: 0;
      color: #4361ee;
      font-weight: bold;
    }

    /* Modal styles */
    .modal-style .modal-header {
      background-color: #4361ee;
      color: white;
    }

    .modal-style .modal-header .btn-close {
      color: white;
      opacity: 1;
    }

    .no-services-message {
      text-align: center;
      padding: 60px 20px;
      color: #6c757d;
    }

    .no-services-message .icon {
      font-size: 4rem;
      color: #4361ee;
      margin-bottom: 20px;
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid">
  <div class="row">
    <!-- Include Sidebar with "services" as active page -->
    <c:set var="activePage" value="services" scope="request"/>
    <jsp:include page="/includes/sidebar.jsp" />

    <!-- Main Content Area -->
    <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
      <div class="service-management-container">
        <!-- Include Messages for notifications -->
        <jsp:include page="/includes/messages.jsp" />

        <!-- Section Header -->
        <div class="section-header">
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <h1 class="h3 mb-0">Service Management</h1>
              <p class="mb-0">Create and manage your photography service packages</p>
            </div>
            <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#addServiceModal">
              <i class="bi bi-plus-circle me-2"></i>Add New Package
            </button>
          </div>
        </div>

        <!-- Main Content Section -->
        <div class="row g-4">
          <!-- Service Packages Column -->
          <div class="col-lg-8">
            <div class="content-card">
              <div class="card-header-custom">
                <h5 class="card-title-custom">
                  <i class="bi bi-camera me-2"></i>Your Service Packages
                </h5>
                <div class="dropdown">
                  <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" id="filterDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="bi bi-funnel me-1"></i>Filter
                  </button>
                  <ul class="dropdown-menu" aria-labelledby="filterDropdown">
                    <li><a class="dropdown-item" href="#">All Packages</a></li>
                    <li><a class="dropdown-item" href="#">Active Packages</a></li>
                    <li><a class="dropdown-item" href="#">Inactive Packages</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="#">Wedding</a></li>
                    <li><a class="dropdown-item" href="#">Portrait</a></li>
                    <li><a class="dropdown-item" href="#">Event</a></li>
                    <li><a class="dropdown-item" href="#">Corporate</a></li>
                  </ul>
                </div>
              </div>

              <!-- Package List -->
              <div class="service-list">
                <c:choose>
                  <c:when test="${not empty services}">
                    <c:forEach var="service" items="${services}">
                      <div class="service-card">
                        <div class="service-actions">
                          <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editServiceModal" onclick="editService('${service.serviceId}')">
                            <i class="bi bi-pencil"></i>
                          </button>
                          <button class="btn btn-sm btn-outline-danger" data-bs-toggle="modal" data-bs-target="#deleteServiceModal" onclick="deleteService('${service.serviceId}')">
                            <i class="bi bi-trash"></i>
                          </button>
                        </div>
                        <h5>${service.name}</h5>
                        <div class="service-price">$${service.price}</div>
                        <div class="badge ${service.active ? 'bg-success' : 'bg-secondary'} badge-custom">${service.active ? 'Active' : 'Inactive'}</div>
                        <p class="service-description">${service.description}</p>
                        <div class="service-detail"><i class="bi bi-tag me-2"></i><strong>Category:</strong> ${service.category}</div>
                        <div class="service-detail"><i class="bi bi-clock me-2"></i><strong>Duration:</strong> ${service.durationHours} hours</div>
                        <div class="service-detail"><i class="bi bi-camera me-2"></i><strong>Photographers:</strong> ${service.photographersCount}</div>
                        <div class="service-detail"><i class="bi bi-image me-2"></i><strong>Deliverables:</strong> ${service.deliverables}</div>
                        <div class="service-detail"><i class="bi bi-calendar-check me-2"></i><strong>Bookings:</strong> ${service.bookingCount} times booked</div>

                        <div class="package-features">
                          <h6>Package Includes:</h6>
                          <ul>
                            <c:forEach var="feature" items="${service.features}">
                              <li>${feature}</li>
                            </c:forEach>
                          </ul>
                        </div>
                      </div>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>
                    <div class="no-services-message">
                      <div class="icon">
                        <i class="bi bi-camera"></i>
                      </div>
                      <h4>No Services Yet</h4>
                      <p>You haven't added any service packages yet. Click the "Add New Package" button to create your first service.</p>
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>

          <!-- Stats & Tips Column -->
          <div class="col-lg-4">
            <!-- Stats Card -->
            <div class="content-card mb-4">
              <div class="card-header-custom">
                <h5 class="card-title-custom">
                  <i class="bi bi-graph-up me-2"></i>Service Stats
                </h5>
              </div>
              <div>
                <c:choose>
                  <c:when test="${not empty services}">
                    <c:set var="totalServices" value="${services.size()}" />
                    <c:set var="activeServices" value="0" />
                    <c:forEach var="service" items="${services}">
                      <c:if test="${service.active}">
                        <c:set var="activeServices" value="${activeServices + 1}" />
                      </c:if>
                    </c:forEach>

                    <div class="mb-3">
                      <h6>Total Packages</h6>
                      <p class="mb-1">${totalServices} packages created</p>
                      <div class="progress" style="height: 10px;">
                        <div class="progress-bar bg-primary" role="progressbar" style="width: 100%;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                      </div>
                    </div>

                    <div class="mb-3">
                      <h6>Active Packages</h6>
                      <p class="mb-1">${activeServices} active packages</p>
                      <div class="progress" style="height: 10px;">
                        <div class="progress-bar bg-success" role="progressbar" style="width: ${activeServices * 100 / totalServices}%;" aria-valuenow="${activeServices * 100 / totalServices}" aria-valuemin="0" aria-valuemax="100"></div>
                      </div>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="text-center">
                      <p class="text-muted">No statistics available yet</p>
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <!-- Tips Card -->
            <div class="content-card">
              <div class="card-header-custom">
                <h5 class="card-title-custom">
                  <i class="bi bi-lightbulb me-2"></i>Tips for Effective Packages
                </h5>
              </div>
              <div>
                <ul class="mb-0">
                  <li class="mb-2">Create packages at 3 different price points (good, better, best)</li>
                  <li class="mb-2">Make your offerings clear and easy to understand</li>
                  <li class="mb-2">Highlight what makes your packages unique</li>
                  <li class="mb-2">Offer add-ons to make packages customizable</li>
                  <li class="mb-2">Update prices seasonally for peak demand periods</li>
                  <li>Include sample photos with each package description</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</div>

<!-- Add Service Modal -->
<div class="modal fade modal-style" id="addServiceModal" tabindex="-1" aria-labelledby="addServiceModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="addServiceModalLabel">Add New Service Package</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="addServiceForm" action="${pageContext.request.contextPath}/photographer/add-service" method="post">
          <div class="row g-3">
            <!-- Basic Information -->
            <div class="col-md-8">
              <label for="packageName" class="form-label">Package Name</label>
              <input type="text" class="form-control" id="packageName" name="packageName" required>
            </div>

            <div class="col-md-4">
              <label for="packageCategory" class="form-label">Category</label>
              <select class="form-select" id="packageCategory" name="packageCategory" required>
                <option value="" selected disabled>Select category</option>
                <option value="WEDDING">Wedding</option>
                <option value="PORTRAIT">Portrait</option>
                <option value="EVENT">Event</option>
                <option value="CORPORATE">Corporate</option>
                <option value="FAMILY">Family</option>
                <option value="PRODUCT">Product</option>
                <option value="OTHER">Other</option>
              </select>
            </div>

            <div class="col-md-12">
              <label for="packageDescription" class="form-label">Description</label>
              <textarea class="form-control" id="packageDescription" name="packageDescription" rows="3" required></textarea>
            </div>

            <!-- Pricing & Duration -->
            <div class="col-md-4">
              <label for="packagePrice" class="form-label">Price ($)</label>
              <input type="number" class="form-control" id="packagePrice" name="packagePrice" step="0.01" min="0" required>
            </div>

            <div class="col-md-4">
              <label for="packageDuration" class="form-label">Duration (hours)</label>
              <input type="number" class="form-control" id="packageDuration" name="packageDuration" min="1" required>
            </div>

            <div class="col-md-4">
              <label for="packagePhotographers" class="form-label">Number of Photographers</label>
              <input type="number" class="form-control" id="packagePhotographers" name="packagePhotographers" min="1" max="5" value="1" required>
            </div>

            <!-- Features Section -->
            <div class="col-md-12">
              <label class="form-label">Package Features</label>
              <div class="form-text mb-2">Enter each feature on a new line</div>
              <textarea class="form-control" id="packageFeatures" name="packageFeatures" rows="5" placeholder="e.g.
Online gallery with digital downloads
100+ edited digital images
Print release"></textarea>
            </div>

            <!-- Deliverables -->
            <div class="col-md-12">
              <label for="packageDeliverables" class="form-label">Deliverables</label>
              <input type="text" class="form-control" id="packageDeliverables" name="packageDeliverables" placeholder="e.g. 100+ edited images, 1 album">
            </div>

            <!-- Status -->
            <div class="col-md-12">
              <div class="form-check form-switch">
                <input class="form-check-input" type="checkbox" id="packageActive" name="packageActive" checked>
                <label class="form-check-label" for="packageActive">Package Active</label>
              </div>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" form="addServiceForm" class="btn btn-primary">Add Package</button>
      </div>
    </div>
  </div>
</div>

<!-- Edit Service Modal -->
<div class="modal fade modal-style" id="editServiceModal" tabindex="-1" aria-labelledby="editServiceModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="editServiceModalLabel">Edit Service Package</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="editServiceForm" action="${pageContext.request.contextPath}/photographer/update-service" method="post">
          <input type="hidden" name="packageId" id="editPackageId">
          <!-- Form fields will be populated by JavaScript -->
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" form="editServiceForm" class="btn btn-primary">Update Package</button>
      </div>
    </div>
  </div>
</div>

<!-- Delete Service Modal -->
<div class="modal fade modal-style" id="deleteServiceModal" tabindex="-1" aria-labelledby="deleteServiceModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="deleteServiceModalLabel">Delete Service Package</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p>Are you sure you want to delete this service package?</p>
        <p class="text-danger">This action cannot be undone. This will permanently delete this package and remove it from client booking options.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <form action="${pageContext.request.contextPath}/photographer/delete-service" method="post">
          <input type="hidden" name="packageId" id="deletePackageId">
          <button type="submit" class="btn btn-danger">Delete Package</button>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  // Store service data for editing
  let services = {};
  <c:forEach var="service" items="${services}">
  services['${service.serviceId}'] = {
    name: '${service.name}',
    category: '${service.category}',
    description: '${service.description}',
    price: ${service.price},
    duration: ${service.durationHours},
    photographers: ${service.photographersCount},
    features: [
      <c:forEach var="feature" items="${service.features}" varStatus="status">
      '${feature}'<c:if test="${!status.last}">, </c:if>
      </c:forEach>
    ],
    deliverables: '${service.deliverables}',
    active: ${service.active}
  };
  </c:forEach>

  function editService(serviceId) {
    const service = services[serviceId];
    const form = document.getElementById('editServiceForm');

    // Clear previous form content
    form.innerHTML = '<input type="hidden" name="packageId" value="' + serviceId + '">';

    // Create form fields - using string concatenation instead of template literals
    let featuresText = '';
    if (service.features && service.features.length > 0) {
      featuresText = service.features.join('\n');
    }

    form.innerHTML += '<div class="row g-3">' +
            '<div class="col-md-8">' +
            '<label for="editPackageName" class="form-label">Package Name</label>' +
            '<input type="text" class="form-control" id="editPackageName" name="packageName" value="' + service.name + '" required>' +
            '</div>' +
            '<div class="col-md-4">' +
            '<label for="editPackageCategory" class="form-label">Category</label>' +
            '<select class="form-select" id="editPackageCategory" name="packageCategory" required>' +
            '<option value="WEDDING" ' + (service.category == 'WEDDING' ? 'selected' : '') + '>Wedding</option>' +
            '<option value="PORTRAIT" ' + (service.category == 'PORTRAIT' ? 'selected' : '') + '>Portrait</option>' +
            '<option value="EVENT" ' + (service.category == 'EVENT' ? 'selected' : '') + '>Event</option>' +
            '<option value="CORPORATE" ' + (service.category == 'CORPORATE' ? 'selected' : '') + '>Corporate</option>' +
            '<option value="FAMILY" ' + (service.category == 'FAMILY' ? 'selected' : '') + '>Family</option>' +
            '<option value="PRODUCT" ' + (service.category == 'PRODUCT' ? 'selected' : '') + '>Product</option>' +
            '<option value="OTHER" ' + (service.category == 'OTHER' ? 'selected' : '') + '>Other</option>' +
            '</select>' +
            '</div>' +
            '<div class="col-md-12">' +
            '<label for="editPackageDescription" class="form-label">Description</label>' +
            '<textarea class="form-control" id="editPackageDescription" name="packageDescription" rows="3" required>' + service.description + '</textarea>' +
            '</div>' +
            '<div class="col-md-4">' +
            '<label for="editPackagePrice" class="form-label">Price ($)</label>' +
            '<input type="number" class="form-control" id="editPackagePrice" name="packagePrice" step="0.01" min="0" value="' + service.price + '" required>' +
            '</div>' +
            '<div class="col-md-4">' +
            '<label for="editPackageDuration" class="form-label">Duration (hours)</label>' +
            '<input type="number" class="form-control" id="editPackageDuration" name="packageDuration" min="1" value="' + service.duration + '" required>' +
            '</div>' +
            '<div class="col-md-4">' +
            '<label for="editPackagePhotographers" class="form-label">Number of Photographers</label>' +
            '<input type="number" class="form-control" id="editPackagePhotographers" name="packagePhotographers" min="1" max="5" value="' + service.photographers + '" required>' +
            '</div>' +
            '<div class="col-md-12">' +
            '<label class="form-label">Package Features</label>' +
            '<div class="form-text mb-2">Enter each feature on a new line</div>' +
            '<textarea class="form-control" id="editPackageFeatures" name="packageFeatures" rows="5">' + featuresText + '</textarea>' +
            '</div>' +
            '<div class="col-md-12">' +
            '<label for="editPackageDeliverables" class="form-label">Deliverables</label>' +
            '<input type="text" class="form-control" id="editPackageDeliverables" name="packageDeliverables" value="' + service.deliverables + '">' +
            '</div>' +
            '<div class="col-md-12">' +
            '<div class="form-check form-switch">' +
            '<input class="form-check-input" type="checkbox" id="editPackageActive" name="packageActive" ' + (service.active ? 'checked' : '') + '>' +
            '<label class="form-check-label" for="editPackageActive">Package Active</label>' +
            '</div>' +
            '</div>' +
            '</div>';
  }

  function deleteService(serviceId) {
    document.getElementById('deletePackageId').value = serviceId;
  }
</script>
</body>
</html>
