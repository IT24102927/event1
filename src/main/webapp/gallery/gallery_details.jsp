<%-- gallery_details.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${gallery.title} - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <!-- Lightbox CSS -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.11.3/css/lightbox.min.css" rel="stylesheet">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <style>
    body {
      font-family: 'Poppins', sans-serif;
      background-color: #f8f9fa;
    }

    .gallery-header {
      background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
      color: white;
      padding: 60px 0 30px;
      margin-bottom: 30px;
    }

    .status-badge {
      display: inline-block;
      padding: 5px 10px;
      border-radius: 50px;
      font-size: 0.8rem;
      text-transform: lowercase;
    }

    .photo-container {
      margin-bottom: 30px;
    }

    .photo-item {
      margin-bottom: 20px;
      border-radius: 10px;
      overflow: hidden;
      position: relative;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      transition: transform 0.3s ease;
    }

    .photo-item:hover {
      transform: translateY(-5px);
    }

    .photo-img {
      width: 100%;
      height: 200px;
      object-fit: cover;
      cursor: pointer;
    }

    .photo-overlay {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      background: rgba(0,0,0,0.7);
      padding: 10px;
      opacity: 0;
      transition: all 0.3s ease;
    }

    .photo-item:hover .photo-overlay {
      opacity: 1;
    }

    .photo-actions {
      position: absolute;
      top: 10px;
      right: 10px;
      z-index: 10;
    }

    .photo-actions .btn {
      width: 35px;
      height: 35px;
      border-radius: 50%;
      margin-left: 5px;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 0;
      box-shadow: 0 2px 5px rgba(0,0,0,0.2);
      opacity: 0.8;
    }

    .photo-actions .btn:hover {
      opacity: 1;
    }

    .photo-title {
      color: white;
      font-weight: 500;
      margin-bottom: 3px;
    }

    .photo-description {
      color: rgba(255,255,255,0.8);
      font-size: 0.8rem;
      margin-bottom: 0;
    }

    .photo-meta {
      color: white;
      font-size: 0.8rem;
      opacity: 0.7;
    }

    .gallery-info {
      background: white;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      padding: 20px;
      margin-bottom: 20px;
    }

    .gallery-details {
      background: white;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      padding: 20px;
    }

    .no-photos {
      text-align: center;
      padding: 50px 20px;
      background: white;
      border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .edit-modal .form-control {
      margin-bottom: 15px;
    }

    .edit-modal .modal-title {
      font-weight: 600;
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<!-- Gallery Header -->
<div class="gallery-header">
  <div class="container">
    <div class="row align-items-center">
      <div class="col-md-8">
        <h1 class="display-5 fw-bold">${gallery.title}</h1>
        <p class="lead">
          <c:if test="${not empty gallery.category}">
            ${gallery.category} Photography
          </c:if>
        </p>
        <div class="d-flex align-items-center">
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
          <span class="ms-3 text-light">
                            <i class="bi bi-images me-1"></i> ${photos.size()} photos
                        </span>
          <span class="ms-3 text-light">
                            <i class="bi bi-calendar-event me-1"></i>
                            <% pageContext.setAttribute("dateFormat", java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy")); %>
                            ${gallery.createdDate.format(dateFormat)}
                        </span>
        </div>
      </div>
      <div class="col-md-4 text-md-end mt-3 mt-md-0">
        <c:if test="${isOwner}">
          <div class="btn-group">
            <a href="${pageContext.request.contextPath}/gallery/upload-form?galleryId=${gallery.galleryId}" class="btn btn-light">
              <i class="bi bi-cloud-upload me-1"></i> Add Photos
            </a>
            <button type="button" class="btn btn-light dropdown-toggle dropdown-toggle-split" data-bs-toggle="dropdown" aria-expanded="false">
              <span class="visually-hidden">Toggle Dropdown</span>
            </button>
            <ul class="dropdown-menu">
              <li>
                <a class="dropdown-item" href="${pageContext.request.contextPath}/gallery/edit?id=${gallery.galleryId}">
                  <i class="bi bi-pencil me-2"></i> Edit Gallery
                </a>
              </li>
              <li>
                <hr class="dropdown-divider">
              </li>
              <li>
                <a class="dropdown-item text-danger" href="#" data-bs-toggle="modal" data-bs-target="#deleteGalleryModal">
                  <i class="bi bi-trash me-2"></i> Delete Gallery
                </a>
              </li>
            </ul>
          </div>
        </c:if>
      </div>
    </div>
  </div>
</div>

<div class="container mb-5">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <div class="row">
    <div class="col-md-8">
      <!-- Photos Grid -->
      <c:choose>
        <c:when test="${not empty photos}">
          <div class="photo-container">
            <div class="row g-3">
              <c:forEach var="photo" items="${photos}">
                <div class="col-md-4">
                  <div class="photo-item">
                    <a href="${pageContext.request.contextPath}/${photo.filePath}" data-lightbox="gallery" data-title="${not empty photo.title ? photo.title : photo.originalFileName}">
                      <img src="${pageContext.request.contextPath}/${photo.thumbnailPath}" class="photo-img" alt="${not empty photo.title ? photo.title : photo.originalFileName}">
                    </a>

                    <c:if test="${isOwner}">
                      <div class="photo-actions">
                        <button type="button" class="btn btn-light" onclick="editPhoto('${photo.photoId}', '${not empty photo.title ? photo.title : ''}', '${not empty photo.description ? photo.description : ''}')">
                          <i class="bi bi-pencil"></i>
                        </button>
                        <button type="button" class="btn btn-danger" onclick="deletePhoto('${photo.photoId}')">
                          <i class="bi bi-trash"></i>
                        </button>
                        <c:if test="${gallery.coverPhotoId != photo.photoId}">
                          <button type="button" class="btn btn-primary" onclick="setCoverPhoto('${photo.photoId}')">
                            <i class="bi bi-star"></i>
                          </button>
                        </c:if>
                      </div>
                    </c:if>

                    <div class="photo-overlay">
                      <c:if test="${not empty photo.title}">
                        <h6 class="photo-title">${photo.title}</h6>
                      </c:if>
                      <c:if test="${not empty photo.description}">
                        <p class="photo-description">${photo.description}</p>
                      </c:if>
                      <div class="photo-meta mt-2">
                        <small>
                          <% pageContext.setAttribute("uploadDateFormat", java.time.format.DateTimeFormatter.ofPattern("MMM d, yyyy")); %>
                            ${photo.uploadDate.format(uploadDateFormat)}
                        </small>
                      </div>
                    </div>
                  </div>
                </div>
              </c:forEach>
            </div>
          </div>
        </c:when>
        <c:otherwise>
          <div class="no-photos">
            <i class="bi bi-images display-3 text-muted"></i>
            <h3 class="mt-3">No Photos Yet</h3>
            <p class="text-muted">This gallery doesn't have any photos yet.</p>

            <c:if test="${isOwner}">
              <a href="${pageContext.request.contextPath}/gallery/upload-form?galleryId=${gallery.galleryId}" class="btn btn-primary mt-3">
                <i class="bi bi-cloud-upload me-2"></i>Upload Photos
              </a>
            </c:if>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <div class="col-md-4">
      <!-- Gallery Info -->
      <div class="gallery-info">
        <h4>About This Gallery</h4>
        <c:if test="${not empty gallery.description}">
          <p>${gallery.description}</p>
        </c:if>
        <c:if test="${empty gallery.description && isOwner}">
          <p class="text-muted">No description provided. <a href="${pageContext.request.contextPath}/gallery/edit?id=${gallery.galleryId}">Add one?</a></p>
        </c:if>
      </div>

      <!-- Gallery Details -->
      <div class="gallery-details">
        <h4>Gallery Details</h4>
        <ul class="list-group list-group-flush">
          <li class="list-group-item d-flex justify-content-between align-items-center border-0 px-0">
            <span>Status</span>
            <c:choose>
              <c:when test="${gallery.status == 'PUBLISHED'}">
                <span class="badge bg-success">Published</span>
              </c:when>
              <c:when test="${gallery.status == 'PRIVATE'}">
                <span class="badge bg-primary">Private</span>
              </c:when>
              <c:otherwise>
                <span class="badge bg-secondary">Draft</span>
              </c:otherwise>
            </c:choose>
          </li>
          <li class="list-group-item d-flex justify-content-between align-items-center border-0 px-0">
            <span>Created On</span>
            <span>
                                <% pageContext.setAttribute("createdDateFormat", java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy")); %>
                                ${gallery.createdDate.format(createdDateFormat)}
                            </span>
          </li>
          <li class="list-group-item d-flex justify-content-between align-items-center border-0 px-0">
            <span>Last Updated</span>
            <span>
                                <% pageContext.setAttribute("updatedDateFormat", java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy")); %>
                                ${gallery.lastUpdatedDate.format(updatedDateFormat)}
                            </span>
          </li>
          <li class="list-group-item d-flex justify-content-between align-items-center border-0 px-0">
            <span>Category</span>
            <span>${not empty gallery.category ? gallery.category : 'Not specified'}</span>
          </li>
          <li class="list-group-item d-flex justify-content-between align-items-center border-0 px-0">
            <span>Photo Count</span>
            <span>${photos.size()}</span>
          </li>
        </ul>
      </div>

      <!-- Share Section -->
      <div class="card mt-4">
        <div class="card-body">
          <h5 class="card-title">Share This Gallery</h5>
          <div class="input-group mb-3">
            <input type="text" class="form-control" id="shareUrl" value="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath}/gallery/details?id=${gallery.galleryId}" readonly>
            <button class="btn btn-primary" type="button" onclick="copyShareUrl()">
              <i class="bi bi-clipboard"></i>
            </button>
          </div>
          <div class="d-flex justify-content-around mt-3">
            <a href="#" class="btn btn-outline-primary">
              <i class="bi bi-facebook"></i>
            </a>
            <a href="#" class="btn btn-outline-info">
              <i class="bi bi-twitter"></i>
            </a>
            <a href="#" class="btn btn-outline-success">
              <i class="bi bi-whatsapp"></i>
            </a>
            <a href="#" class="btn btn-outline-danger">
              <i class="bi bi-envelope"></i>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Delete Gallery Modal -->
<div class="modal fade" id="deleteGalleryModal" tabindex="-1" aria-labelledby="deleteGalleryModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="deleteGalleryModalLabel">Confirm Deletion</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <p>Are you sure you want to delete this gallery? This will delete all photos in the gallery and cannot be undone.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <form action="${pageContext.request.contextPath}/gallery/delete" method="post">
          <input type="hidden" name="galleryId" value="${gallery.galleryId}">
          <button type="submit" class="btn btn-danger">Delete Gallery</button>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Edit Photo Modal -->
<div class="modal fade edit-modal" id="editPhotoModal" tabindex="-1" aria-labelledby="editPhotoModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="editPhotoModalLabel">Edit Photo</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
        <form id="editPhotoForm" action="${pageContext.request.contextPath}/gallery/update-photo" method="post">
          <input type="hidden" id="photoId" name="photoId">
          <div class="mb-3">
            <label for="photoTitle" class="form-label">Title</label>
            <input type="text" class="form-control" id="photoTitle" name="title">
          </div>
          <div class="mb-3">
            <label for="photoDescription" class="form-label">Description</label>
            <textarea class="form-control" id="photoDescription" name="description" rows="3"></textarea>
          </div>
          <div class="mb-3 form-check">
            <input type="checkbox" class="form-check-input" id="setCover" name="setCover" value="true">
            <label class="form-check-label" for="setCover">Set as cover photo</label>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" onclick="document.getElementById('editPhotoForm').submit()">Save Changes</button>
      </div>
    </div>
  </div>
</div>

<!-- Delete Photo Form -->
<form id="deletePhotoForm" action="${pageContext.request.contextPath}/gallery/delete-photo" method="post" style="display: none;">
  <input type="hidden" id="deletePhotoId" name="photoId">
</form>

<!-- Set Cover Photo Form -->
<form id="setCoverPhotoForm" action="${pageContext.request.contextPath}/gallery/update-photo" method="post" style="display: none;">
  <input type="hidden" id="coverPhotoId" name="photoId">
  <input type="hidden" name="setCover" value="true">
</form>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Lightbox JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.11.3/js/lightbox.min.js"></script>

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  // Configure Lightbox
  lightbox.option({
    'resizeDuration': 200,
    'wrapAround': true,
    'albumLabel': "Photo %1 of %2"
  });

  // Edit Photo
  function editPhoto(photoId, title, description) {
    document.getElementById('photoId').value = photoId;
    document.getElementById('photoTitle').value = title;
    document.getElementById('photoDescription').value = description;
    document.getElementById('setCover').checked = false;

    var editModal = new bootstrap.Modal(document.getElementById('editPhotoModal'));
    editModal.show();
  }

  // Delete Photo
  function deletePhoto(photoId) {
    if (confirm('Are you sure you want to delete this photo? This cannot be undone.')) {
      document.getElementById('deletePhotoId').value = photoId;
      document.getElementById('deletePhotoForm').submit();
    }
  }

  // Set Cover Photo
  function setCoverPhoto(photoId) {
    document.getElementById('coverPhotoId').value = photoId;
    document.getElementById('setCoverPhotoForm').submit();
  }

  // Copy Share URL
  function copyShareUrl() {
    var copyText = document.getElementById("shareUrl");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");

    alert("Gallery link copied to clipboard!");
  }
</script>
</body>
</html>
