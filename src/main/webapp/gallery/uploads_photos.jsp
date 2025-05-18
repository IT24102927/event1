<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Upload Photos - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <!-- Dropzone CSS -->
  <link rel="stylesheet" href="https://unpkg.com/dropzone@5/dist/min/dropzone.min.css" type="text/css" />

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

    .upload-container {
      background-color: white;
      border-radius: 15px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
      padding: 30px;
      margin-bottom: 30px;
    }

    .section-header {
      border-bottom: 2px solid #f1f1f1;
      margin-bottom: 20px;
      padding-bottom: 10px;
    }

    /* Dropzone styling */
    .dropzone {
      border: 2px dashed #4361ee;
      border-radius: 10px;
      background-color: #f8f9fa;
      transition: all 0.3s ease;
      min-height: 200px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 30px;
    }

    .dropzone:hover {
      border-color: #3a0ca3;
      background-color: #eef2ff;
    }

    .dropzone .dz-message {
      font-size: 1.2rem;
      color: #4361ee;
      text-align: center;
    }

    .dropzone .dz-preview .dz-image {
      border-radius: 10px;
    }

    .upload-icon {
      font-size: 3rem;
      color: #4361ee;
      margin-bottom: 1rem;
    }

    .gallery-option {
      display: block;
      border: 1px solid #dee2e6;
      border-radius: 10px;
      padding: 15px;
      margin-bottom: 15px;
      transition: all 0.3s ease;
      cursor: pointer;
    }

    .gallery-option:hover {
      border-color: #4361ee;
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    }

    .gallery-option.selected {
      border-color: #4361ee;
      background-color: #eef2ff;
    }

    .progress-container {
      margin-top: 20px;
    }

    .progress-bar {
      height: 8px;
      border-radius: 4px;
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<!-- Page Header -->
<section class="page-header">
  <div class="container">
    <h1 class="display-4 fw-bold">Upload Photos</h1>
    <p class="lead">Add photos to your galleries or create a new gallery</p>
  </div>
</section>

<div class="container">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <div class="row">
    <div class="col-lg-8">
      <div class="upload-container">
        <div class="section-header">
          <h2 class="h4">Upload Photos</h2>
        </div>

        <form id="uploadForm" action="${pageContext.request.contextPath}/gallery/upload" method="post" enctype="multipart/form-data">
          <!-- Step 1: Select Gallery -->
          <div class="mb-4">
            <h5>Step 1: Select or Create Gallery</h5>

            <div class="gallery-selection mb-4">
              <!-- Existing Galleries -->
              <div class="mb-3">
                <label class="gallery-option" id="existingGalleryOption">
                  <div class="d-flex align-items-center">
                    <input type="radio" name="galleryType" value="existing" class="form-check-input me-2"
                    ${empty param.galleryId ? 'checked' : 'checked'}>
                    <h6 class="mb-0">Add to Existing Gallery</h6>
                  </div>
                </label>

                <div id="existingGalleryContainer" class="ps-4">
                  <div class="mb-3">
                    <select class="form-select" id="galleryId" name="galleryId">
                      <option value="">Select Gallery</option>
                      <c:forEach var="gallery" items="${galleries}">
                        <option value="${gallery.galleryId}" ${param.galleryId == gallery.galleryId ? 'selected' : ''}>
                            ${gallery.title}
                          <c:if test="${not empty gallery.createdDate}">
                            <% pageContext.setAttribute("dateFormat", java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy")); %>
                            - ${gallery.createdDate.format(dateFormat)}
                          </c:if>
                        </option>
                      </c:forEach>
                    </select>
                  </div>
                </div>
              </div>

              <!-- Create New Gallery -->
              <div>
                <label class="gallery-option" id="newGalleryOption">
                  <div class="d-flex align-items-center">
                    <input type="radio" name="galleryType" value="new" class="form-check-input me-2"
                    ${empty galleries ? 'checked' : ''}>
                    <h6 class="mb-0">Create New Gallery</h6>
                  </div>
                </label>

                <div id="newGalleryContainer" class="ps-4" style="display: ${empty galleries ? 'block' : 'none'};">
                  <div class="mb-3">
                    <label for="galleryTitle" class="form-label">Gallery Title</label>
                    <input type="text" class="form-control" id="galleryTitle" name="galleryTitle" placeholder="Enter gallery title">
                  </div>

                  <div class="mb-3">
                    <label for="galleryDescription" class="form-label">Description</label>
                    <textarea class="form-control" id="galleryDescription" name="galleryDescription" rows="3" placeholder="Enter description (optional)"></textarea>
                  </div>

                  <div class="mb-3">
                    <label for="galleryCategory" class="form-label">Category</label>
                    <select class="form-select" id="galleryCategory" name="galleryCategory">
                      <option value="">Select Category</option>
                      <option value="WEDDING">Wedding</option>
                      <option value="PORTRAIT">Portrait</option>
                      <option value="EVENT">Event</option>
                      <option value="CORPORATE">Corporate</option>
                      <option value="LANDSCAPE">Landscape</option>
                      <option value="PRODUCT">Product</option>
                      <option value="OTHER">Other</option>
                    </select>
                  </div>

                  <div class="mb-3">
                    <label for="galleryBooking" class="form-label">Associated Booking (optional)</label>
                    <select class="form-select" id="galleryBooking" name="galleryBooking">
                      <option value="">None</option>
                      <c:forEach var="booking" items="${bookings}">
                        <option value="${booking.bookingId}">
                            ${booking.eventType} -
                          <% pageContext.setAttribute("eventDateFormat", java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy")); %>
                            ${booking.eventDateTime.format(eventDateFormat)}
                        </option>
                      </c:forEach>
                    </select>
                  </div>

                  <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" id="galleryPublic" name="galleryPublic" checked>
                    <label class="form-check-label" for="galleryPublic">
                      Make gallery public
                    </label>
                    <div class="form-text">Public galleries can be viewed by anyone with the link</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Step 2: Upload Photos -->
          <div class="mb-4">
            <h5>Step 2: Upload Photos</h5>

            <div class="dropzone-container">
              <!-- Hidden file input field for non-JS fallback and direct file input -->
              <input type="file" name="photos" multiple accept="image/*" id="photoFileInput" style="display: none;">

              <div id="dropzoneUpload" class="dropzone">
                <div class="dz-message">
                  <i class="bi bi-cloud-arrow-up upload-icon"></i>
                  <div>Drag and drop photos here</div>
                  <div class="text-muted small mt-2">or click to browse files</div>
                </div>
              </div>

              <div class="progress-container" style="display: none;">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span id="progressText">Uploading photos...</span>
                  <span id="progressPercentage">0%</span>
                </div>
                <div class="progress">
                  <div id="progressBar" class="progress-bar bg-primary" role="progressbar" style="width: 0%"></div>
                </div>
              </div>
            </div>

            <div class="form-check mt-3">
              <input class="form-check-input" type="checkbox" id="autoProcess" name="autoProcess" checked>
              <label class="form-check-label" for="autoProcess">
                Automatically optimize images
              </label>
              <div class="form-text">Resize large images for faster loading and reduce file size</div>
            </div>
          </div>

          <div class="d-flex justify-content-between mt-4">
            <a href="${pageContext.request.contextPath}/gallery/list?userOnly=true" class="btn btn-outline-secondary">
              <i class="bi bi-arrow-left me-1"></i> Cancel
            </a>
            <button type="button" id="uploadButton" class="btn btn-primary">
              <i class="bi bi-cloud-upload me-1"></i> Upload Photos
            </button>
          </div>
        </form>
      </div>
    </div>

    <div class="col-lg-4">
      <!-- Help & Tips -->
      <div class="upload-container">
        <div class="section-header">
          <h2 class="h4">Tips for Uploading</h2>
        </div>

        <ul class="list-unstyled">
          <li class="mb-3">
            <i class="bi bi-check-circle-fill text-primary me-2"></i>
            <strong>Accepted formats:</strong> JPG, PNG, WebP
          </li>
          <li class="mb-3">
            <i class="bi bi-check-circle-fill text-primary me-2"></i>
            <strong>Maximum file size:</strong> 20MB per image
          </li>
          <li class="mb-3">
            <i class="bi bi-check-circle-fill text-primary me-2"></i>
            <strong>Recommended resolution:</strong> 2000-3000px on longest side
          </li>
          <li class="mb-3">
            <i class="bi bi-check-circle-fill text-primary me-2"></i>
            <strong>Batch uploading:</strong> You can upload up to 100 photos at once
          </li>
        </ul>

        <div class="alert alert-info">
          <i class="bi bi-info-circle-fill me-2"></i>
          Original photos are preserved while optimized versions are created for web display.
        </div>
      </div>

      <!-- My Galleries -->
      <div class="upload-container">
        <div class="section-header d-flex justify-content-between align-items-center">
          <h2 class="h4 mb-0">My Galleries</h2>
          <a href="${pageContext.request.contextPath}/gallery/list?userOnly=true" class="btn btn-sm btn-outline-primary">View All</a>
        </div>

        <div class="recent-galleries">
          <c:choose>
            <c:when test="${not empty galleries}">
              <c:forEach var="gallery" items="${galleries}" begin="0" end="2">
                <div class="card mb-2">
                  <div class="card-body p-3">
                    <h6 class="card-title mb-1">${gallery.title}</h6>
                    <p class="small text-muted mb-0">
                        ${gallery.photoIds.size()} photos •
                      <% pageContext.setAttribute("galleryDateFormat", java.time.format.DateTimeFormatter.ofPattern("MMM d, yyyy")); %>
                        ${gallery.createdDate.format(galleryDateFormat)}
                    </p>
                  </div>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="text-center text-muted py-4">
                <i class="bi bi-images d-block mb-2" style="font-size: 2rem;"></i>
                <p>No galleries yet</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Dropzone JS -->
<script src="https://unpkg.com/dropzone@5/dist/min/dropzone.min.js"></script>

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  // Initialize Dropzone
  Dropzone.autoDiscover = false;

  document.addEventListener('DOMContentLoaded', function() {
    // Gallery selection
    const existingGalleryOption = document.getElementById('existingGalleryOption');
    const newGalleryOption = document.getElementById('newGalleryOption');
    const existingGalleryRadio = document.querySelector('input[value="existing"]');
    const newGalleryRadio = document.querySelector('input[value="new"]');
    const existingGalleryContainer = document.getElementById('existingGalleryContainer');
    const newGalleryContainer = document.getElementById('newGalleryContainer');
    const photoFileInput = document.getElementById('photoFileInput');

    // Check if there are galleries available
    const galleriesAvailable = ${not empty galleries};

    // If no galleries available, select the "Create New Gallery" option by default
    if (!galleriesAvailable) {
      newGalleryRadio.checked = true;
      newGalleryOption.classList.add('selected');
      newGalleryContainer.style.display = 'block';
      existingGalleryContainer.style.display = 'none';
    } else {
      existingGalleryRadio.checked = true;
      existingGalleryOption.classList.add('selected');
    }

    // Click event for existing gallery option
    existingGalleryOption.addEventListener('click', function() {
      existingGalleryRadio.checked = true;
      existingGalleryOption.classList.add('selected');
      newGalleryOption.classList.remove('selected');
      existingGalleryContainer.style.display = 'block';
      newGalleryContainer.style.display = 'none';
    });

    // Click event for new gallery option
    newGalleryOption.addEventListener('click', function() {
      newGalleryRadio.checked = true;
      newGalleryOption.classList.add('selected');
      existingGalleryOption.classList.remove('selected');
      newGalleryContainer.style.display = 'block';
      existingGalleryContainer.style.display = 'none';
    });

    // Initialize Dropzone
    const myDropzone = new Dropzone("#dropzoneUpload", {
      url: "${pageContext.request.contextPath}/gallery/upload",
      paramName: "photos",
      maxFilesize: 20, // MB
      maxFiles: 100,
      acceptedFiles: "image/jpeg,image/png,image/webp",
      autoProcessQueue: false,
      uploadMultiple: true,
      parallelUploads: 5,
      addRemoveLinks: true,
      createImageThumbnails: true,
      thumbnailWidth: 120,
      thumbnailHeight: 120,
      clickable: true,
      // Important: This connects the dropzone to the hidden file input
      hiddenInputContainer: document.getElementById('photoFileInput')
    });

    // When clicking on the dropzone, trigger the file input
    myDropzone.on("clicking", function() {
      photoFileInput.click();
    });

    // Update progress bar
    myDropzone.on("totaluploadprogress", function(progress) {
      document.getElementById('progressBar').style.width = progress + "%";
      document.getElementById('progressPercentage').textContent = Math.round(progress) + "%";
    });

    // Show progress container when upload starts
    myDropzone.on("sendingmultiple", function() {
      document.querySelector('.progress-container').style.display = 'block';
    });

    // Update progress text on success
    myDropzone.on("successmultiple", function() {
      document.getElementById('progressText').textContent = "Upload complete!";
    });

    // Handle upload button click
    document.getElementById('uploadButton').addEventListener('click', function() {
      // Validate form
      let isValid = true;

      // Check gallery selection
      if (existingGalleryRadio.checked) {
        const galleryId = document.getElementById('galleryId').value;
        if (!galleryId) {
          alert('Please select a gallery');
          isValid = false;
        }
      } else if (newGalleryRadio.checked) {
        const galleryTitle = document.getElementById('galleryTitle').value;
        if (!galleryTitle) {
          alert('Please enter a gallery title');
          isValid = false;
        }
      }

      // Check if files are selected
      if (myDropzone.files.length === 0) {
        // Also check the regular file input in case Dropzone failed
        if (photoFileInput.files.length === 0) {
          alert('Please select files to upload');
          isValid = false;
        } else {
          // If files were selected via the regular input, submit the form directly
          if (isValid) {
            document.getElementById('uploadForm').submit();
            return;
          }
        }
      }

      if (isValid) {
        // Add form data to dropzone
        myDropzone.options.params = {
          galleryType: document.querySelector('input[name="galleryType"]:checked').value,
          autoProcess: document.getElementById('autoProcess').checked
        };

        if (existingGalleryRadio.checked) {
          myDropzone.options.params.galleryId = document.getElementById('galleryId').value;
        } else {
          myDropzone.options.params.galleryTitle = document.getElementById('galleryTitle').value;
          myDropzone.options.params.galleryDescription = document.getElementById('galleryDescription').value;
          myDropzone.options.params.galleryCategory = document.getElementById('galleryCategory').value;
          myDropzone.options.params.galleryBooking = document.getElementById('galleryBooking').value;
          myDropzone.options.params.galleryPublic = document.getElementById('galleryPublic').checked;
        }

        // Process the queue
        myDropzone.processQueue();
      }
    });

    // Handle completed upload
    myDropzone.on("queuecomplete", function() {
      setTimeout(function() {
        // Get gallery ID to redirect to
        let galleryId;

        if (existingGalleryRadio.checked) {
          galleryId = document.getElementById('galleryId').value;
        } else {
          // For new galleries, we'll need to get the ID from the server response
          // This is a simplification - in a real app, you'd get this from the server response
          galleryId = "new";
        }

        if (galleryId && galleryId !== "new") {
          window.location.href = "${pageContext.request.contextPath}/gallery/details?id=" + galleryId;
        } else {
          window.location.href = "${pageContext.request.contextPath}/gallery/list?userOnly=true";
        }
      }, 1000);
    });

    // Also handle direct file input changes (fallback if dropzone doesn't work)
    photoFileInput.addEventListener('change', function() {
      if (this.files.length > 0) {
        // Add these files to dropzone
        for (let i = 0; i < this.files.length; i++) {
          myDropzone.addFile(this.files[i]);
        }
      }
    });
  });
</script>
</body>
</html>