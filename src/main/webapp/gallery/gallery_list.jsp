<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.photobooking.model.gallery.Gallery" %>
<%@ page import="com.photobooking.model.gallery.GalleryManager" %>
<%@ page import="com.photobooking.model.gallery.Photo" %>
<%@ page import="com.photobooking.model.gallery.PhotoManager" %>
<%@ page import="java.util.List" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>

<%
  // Get the current user from session
  User currentUser = (User) session.getAttribute("user");

  // Check if we should show all galleries or just user galleries
  boolean userOnly = "true".equals(request.getParameter("userOnly"));

  // Initialize gallery manager
  GalleryManager galleryManager = new GalleryManager(application);
  PhotoManager photoManager = new PhotoManager(application);

  // Get appropriate galleries based on parameters
  List<Gallery> galleries = null;

  if (userOnly && currentUser != null) {
    if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
      // Get photographer's galleries
      galleries = galleryManager.getGalleriesByPhotographer(currentUser.getUserId());
    } else if (currentUser.getUserType() == User.UserType.CLIENT) {
      // Get galleries shared with client
      galleries = galleryManager.getGalleriesByClient(currentUser.getUserId());
    }
  } else {
    // Get all published galleries for public view
    List<Gallery> allGalleries = galleryManager.searchGalleries("");
    galleries = new java.util.ArrayList<>();

    for (Gallery gallery : allGalleries) {
      if (gallery.getStatus() == Gallery.GalleryStatus.PUBLISHED) {
        galleries.add(gallery);
      }
    }
  }

  // Store galleries in request for display
  request.setAttribute("galleries", galleries);

  // Get cover photos for each gallery
  Map<String, Photo> coverPhotos = new HashMap<>();

  if (galleries != null) {
    for (Gallery gallery : galleries) {
      if (gallery.getCoverPhotoId() != null) {
        Photo coverPhoto = photoManager.getPhotoById(gallery.getCoverPhotoId());
        if (coverPhoto != null) {
          coverPhotos.put(gallery.getGalleryId(), coverPhoto);
        }
      }
    }
  }

  request.setAttribute("coverPhotos", coverPhotos);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Photo Galleries - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <style>
    body {
      font-family: 'Poppins', sans-serif;
      background-color: #f8f9fa;
    }

    .page-header {
      background: linear-gradient(135deg, #4361ee 0%, #7209b7 100%);
      color: white;
      padding: 60px 0;
      text-align: center;
      margin-bottom: 40px;
      border-radius: 0 0 20px 20px;
    }

    .filter-section {
      background: white;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 30px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    }

    .gallery-card {
      border: none;
      border-radius: 15px;
      overflow: hidden;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      height: 100%;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    }

    .gallery-card:hover {
      transform: translateY(-5px);
      box-shadow: 0 15px 30px rgba(0,0,0,0.1);
    }

    .gallery-thumbnail {
      height: 200px;
      object-fit: cover;
      background-color: #e9ecef; /* Default background if image fails to load */
    }

    .gallery-card .card-body {
      padding: 20px;
    }

    .status-badge {
      position: absolute;
      top: 10px;
      right: 10px;
      padding: 5px 10px;
      border-radius: 50px;
      font-size: 0.75rem;
      font-weight: 500;
      box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    }

    .no-galleries-message {
      text-align: center;
      padding: 60px 20px;
      background-color: white;
      border-radius: 15px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
      margin-bottom: 40px;
    }

    .no-galleries-message h3 {
      color: #4361ee;
      margin-bottom: 20px;
    }

    .no-galleries-message .icon {
      font-size: 4rem;
      color: #4361ee;
      margin-bottom: 20px;
    }

    /* Fallback placeholder for images */
    .placeholder-thumbnail {
      height: 200px;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #e9ecef;
      color: #6c757d;
      font-size: 1.2rem;
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<!-- Page Header -->
<section class="page-header">
  <div class="container">
    <h1 class="display-4 fw-bold">Photo Galleries</h1>
    <c:choose>
      <c:when test="${param.userOnly && sessionScope.user.userType == 'PHOTOGRAPHER'}">
        <p class="lead">Manage and organize your photography portfolios</p>
      </c:when>
      <c:when test="${param.userOnly && sessionScope.user.userType == 'CLIENT'}">
        <p class="lead">View your event photography galleries</p>
      </c:when>
      <c:otherwise>
        <p class="lead">Explore beautiful photography from our talented photographers</p>
      </c:otherwise>
    </c:choose>
  </div>
</section>

<div class="container">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <!-- Filter Section -->
  <div class="filter-section">
    <div class="row align-items-end">
      <div class="col-md-3 mb-3 mb-md-0">
        <label for="searchGallery" class="form-label">Search</label>
        <input type="text" class="form-control" id="searchGallery" placeholder="Search galleries...">
      </div>

      <div class="col-md-3 mb-3 mb-md-0">
        <label for="categoryFilter" class="form-label">Category</label>
        <select class="form-select" id="categoryFilter">
          <option value="">All Categories</option>
          <option value="WEDDING">Wedding</option>
          <option value="PORTRAIT">Portrait</option>
          <option value="EVENT">Event</option>
          <option value="CORPORATE">Corporate</option>
          <option value="LANDSCAPE">Landscape</option>
          <option value="PRODUCT">Product</option>
          <option value="OTHER">Other</option>
        </select>
      </div>

      <div class="col-md-2 mb-3 mb-md-0">
        <label for="sortGalleries" class="form-label">Sort By</label>
        <select class="form-select" id="sortGalleries">
          <option value="date-desc">Newest First</option>
          <option value="date-asc">Oldest First</option>
          <option value="name-asc">Name A-Z</option>
          <option value="name-desc">Name Z-A</option>
        </select>
      </div>

      <div class="col-md-2 mb-3 mb-md-0">
        <label class="form-label d-block">View</label>
        <div class="btn-group" role="group">
          <button type="button" id="gridViewBtn" class="btn btn-outline-primary active">
            <i class="bi bi-grid"></i>
          </button>
          <button type="button" id="listViewBtn" class="btn btn-outline-primary">
            <i class="bi bi-list"></i>
          </button>
        </div>
      </div>

      <div class="col-md-2 text-md-end mb-3 mb-md-0">
        <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
          <a href="${pageContext.request.contextPath}/gallery/create_gallery.jsp" class="btn btn-primary">
            <i class="bi bi-plus-circle me-2"></i>Create Gallery
          </a>
        </c:if>
      </div>
    </div>
  </div>

  <!-- Galleries Grid -->
  <div class="row g-4 mb-4">
    <c:choose>
      <c:when test="${not empty galleries}">
        <c:forEach var="gallery" items="${galleries}">
          <div class="col-md-6 col-lg-4">
            <div class="card gallery-card">
              <div class="position-relative">
                <c:set var="coverPhoto" value="${coverPhotos[gallery.galleryId]}" />
                <c:choose>
                  <c:when test="${not empty coverPhoto}">
                    <div class="card-img-container">
                      <img src="${pageContext.request.contextPath}/${coverPhoto.thumbnailPath}"
                           class="card-img-top gallery-thumbnail"
                           alt="${gallery.title}"
                           onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                      <div class="placeholder-thumbnail" style="display:none;">
                        <div>
                          <i class="bi bi-image fs-1"></i>
                          <div class="mt-2">${gallery.title}</div>
                        </div>
                      </div>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="placeholder-thumbnail">
                      <div>
                        <i class="bi bi-image fs-1"></i>
                        <div class="mt-2">${gallery.title}</div>
                      </div>
                    </div>
                  </c:otherwise>
                </c:choose>

                <c:choose>
                  <c:when test="${gallery.status == 'PUBLISHED'}">
                    <span class="status-badge bg-success">Published</span>
                  </c:when>
                  <c:when test="${gallery.status == 'PRIVATE'}">
                    <span class="status-badge bg-primary">Private</span>
                  </c:when>
                  <c:otherwise>
                    <span class="status-badge bg-secondary">Draft</span>
                  </c:otherwise>
                </c:choose>
              </div>
              <div class="card-body">
                <h5 class="card-title">${gallery.title}</h5>
                <p class="card-text text-muted">
                  <c:if test="${not empty gallery.category}">
                    ${gallery.category} Photography
                  </c:if>
                </p>
                <div class="d-flex justify-content-between align-items-center mt-3">
                  <small class="text-muted">
                    <c:choose>
                      <c:when test="${gallery.createdDate != null}">
                        <% pageContext.setAttribute("dateFormat", java.time.format.DateTimeFormatter.ofPattern("MMM d, yyyy")); %>
                        ${gallery.createdDate.format(dateFormat)}
                      </c:when>
                      <c:otherwise>
                        Unknown date
                      </c:otherwise>
                    </c:choose>
                  </small>
                  <a href="${pageContext.request.contextPath}/gallery/details?id=${gallery.galleryId}" class="btn btn-outline-primary">
                    View Gallery
                  </a>
                </div>
              </div>
            </div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <!-- No Galleries Message -->
        <div class="col-12">
          <div class="no-galleries-message">
            <div class="icon">
              <i class="bi bi-images"></i>
            </div>
            <h3>No Galleries Found</h3>
            <p class="text-muted mb-4">
              <c:choose>
                <c:when test="${param.userOnly && sessionScope.user.userType == 'PHOTOGRAPHER'}">
                  You haven't created any galleries yet. Create your first gallery to showcase your work.
                </c:when>
                <c:when test="${param.userOnly && sessionScope.user.userType == 'CLIENT'}">
                  You don't have any galleries shared with you yet.
                </c:when>
                <c:otherwise>
                  No galleries match your search criteria.
                </c:otherwise>
              </c:choose>
            </p>

            <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
              <a href="${pageContext.request.contextPath}/gallery/create_gallery.jsp" class="btn btn-primary">
                <i class="bi bi-plus-circle me-2"></i>Create Your First Gallery
              </a>
            </c:if>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <%-- Debug Information --%>
  <div class="alert alert-info">
    <h5>Debug Information</h5>
    <p>Total Galleries Loaded: ${galleries.size()}</p>
    <c:if test="${not empty galleries}">
      <ul>
        <c:forEach var="gallery" items="${galleries}">
          <li>
            Gallery ID: ${gallery.galleryId}<br>
            Title: ${gallery.title}<br>
            Status: ${gallery.status}<br>
            Category: ${gallery.category}<br>
            Cover Photo ID: ${gallery.coverPhotoId}<br>
            <c:if test="${not empty coverPhotos[gallery.galleryId]}">
              Cover Photo Path: ${coverPhotos[gallery.galleryId].thumbnailPath}
            </c:if>
          </li>
        </c:forEach>
      </ul>
    </c:if>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Search functionality
    const searchInput = document.getElementById('searchGallery');
    const categoryFilter = document.getElementById('categoryFilter');
    const sortGalleries = document.getElementById('sortGalleries');
    const galleryCards = document.querySelectorAll('.gallery-card');

    function filterGalleries() {
      const searchTerm = searchInput.value.toLowerCase();
      const category = categoryFilter.value;
      let visibleCount = 0;

      galleryCards.forEach(card => {
        const title = card.querySelector('.card-title').textContent.toLowerCase();
        const cardCategory = card.querySelector('.card-text').textContent.toLowerCase();

        const matchesSearch = title.includes(searchTerm);
        const matchesCategory = category === '' || cardCategory.includes(category.toLowerCase());

        if (matchesSearch && matchesCategory) {
          card.closest('.col-md-6').style.display = 'block';
          visibleCount++;
        } else {
          card.closest('.col-md-6').style.display = 'none';
        }
      });

      // Show/hide no galleries message
      const noGalleriesMessage = document.querySelector('.no-galleries-message');
      if (noGalleriesMessage) {
        if (galleryCards.length > 0 && visibleCount === 0) {
          noGalleriesMessage.style.display = 'block';
        } else {
          noGalleriesMessage.style.display = 'none';
        }
      }
    }

    // Add event listeners
    if (searchInput) {
      searchInput.addEventListener('input', filterGalleries);
    }

    if (categoryFilter) {
      categoryFilter.addEventListener('change', filterGalleries);
    }

    // View toggle
    const gridViewBtn = document.getElementById('gridViewBtn');
    const listViewBtn = document.getElementById('listViewBtn');

    if (gridViewBtn && listViewBtn) {
      gridViewBtn.addEventListener('click', function() {
        gridViewBtn.classList.add('active');
        listViewBtn.classList.remove('active');
        document.querySelectorAll('.col-md-6').forEach(el => {
          el.classList.remove('col-md-12');
          el.classList.add('col-md-6', 'col-lg-4');
        });
      });

      listViewBtn.addEventListener('click', function() {
        listViewBtn.classList.add('active');
        gridViewBtn.classList.remove('active');
        document.querySelectorAll('.col-md-6').forEach(el => {
          el.classList.remove('col-md-6', 'col-lg-4');
          el.classList.add('col-md-12');
        });
      });
    }

    // Sort galleries
    if (sortGalleries) {
      sortGalleries.addEventListener('change', function() {
        const sortValue = this.value;
        const container = document.querySelector('.row.g-4');
        const items = Array.from(container.querySelectorAll('.col-md-6'));

        items.sort(function(a, b) {
          const dateA = new Date(a.querySelector('.text-muted').textContent);
          const dateB = new Date(b.querySelector('.text-muted').textContent);
          const titleA = a.querySelector('.card-title').textContent;
          const titleB = b.querySelector('.card-title').textContent;

          if (sortValue === 'date-desc') {
            return dateB - dateA;
          } else if (sortValue === 'date-asc') {
            return dateA - dateB;
          } else if (sortValue === 'name-asc') {
            return titleA.localeCompare(titleB);
          } else if (sortValue === 'name-desc') {
            return titleB.localeCompare(titleA);
          }

          return 0;
        });

        items.forEach(function(item) {
          container.appendChild(item);
        });
      });
    }
  });
</script>
</body>
</html>