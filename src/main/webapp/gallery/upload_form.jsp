<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Upload Photos - SnapHouse</title>

  <!-- Favicon -->
  <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon">

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <!-- Dropzone CSS -->
  <link rel="stylesheet" href="https://unpkg.com/dropzone@5/dist/min/dropzone.min.css" type="text/css" />

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

  <!-- Custom CSS -->
  <style>
    :root {
      --primary-color: #4361ee;
      --primary-hover: #3a56d4;
      --secondary-color: #7209b7;
      --accent-color: #f72585;
      --light-bg: #f8f9fa;
      --dark-bg: #212529;
      --text-color: #212529;
      --text-muted: #6c757d;
      --border-color: #dee2e6;
      --card-shadow: 0 5px 15px rgba(0,0,0,0.08);
    }

    body {
      font-family: 'Poppins', sans-serif;
      background-color: #f0f2f5;
      color: var(--text-color);
    }

    .page-header {
      background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
      padding: 2rem 0;
      color: white;
      margin-bottom: 2rem;
      border-radius: 0 0 20px 20px;
      box-shadow: var(--card-shadow);
    }

    .page-title {
      font-weight: 600;
      font-size: 1.8rem;
      margin-bottom: 0.5rem;
    }

    .content-card {
      background-color: white;
      border-radius: 15px;
      padding: 1.5rem;
      box-shadow: var(--card-shadow);
      border: none;
      margin-bottom: 1.5rem;
    }

    .card-header-custom {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2px solid var(--light-bg);
      padding-bottom: 1rem;
      margin-bottom: 1.5rem;
    }

    .card-title-custom {
      font-weight: 600;
      font-size: 1.25rem;
      margin-bottom: 0;
      color: var(--primary-color);
    }

    .btn-custom {
      padding: 0.6rem 1.2rem;
      border-radius: 10px;
      font-weight: 500;
      transition: all 0.3s ease;
    }

    .btn-primary-custom {
      background-color: var(--primary-color);
      border-color: var(--primary-color);
      color: white;
    }

    .btn-primary-custom:hover {
      background-color: var(--primary-hover);
      border-color: var(--primary-hover);
      transform: translateY(-2px);
    }

    .btn-outline-custom {
      border-color: var(--border-color);
      color: var(--text-color);
    }

    .btn-outline-custom:hover {
      background-color: var(--light-bg);
      color: var(--primary-color);
    }

    .form-control, .form-select {
      border-radius: 10px;
      padding: 0.75rem 1rem;
      border: 1px solid var(--border-color);
      background-color: white;
      font-size: 1rem;
    }

    .form-control:focus, .form-select:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
    }

    .form-label {
      font-weight: 500;
      margin-bottom: 0.5rem;
    }

    /* Dropzone styling */
    .dropzone {
      border: 2px dashed var(--border-color);
      border-radius: 10px;
      background-color: var(--light-bg);
      transition: all 0.3s ease;
      min-height: 200px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }

    .dropzone:hover {
      border-color: var(--primary-color);
    }

    .dropzone.dz-clickable {
      cursor: pointer;
    }

    .dropzone .dz-message {
      font-size: 1.2rem;
      font-weight: 500;
      text-align: center;
      color: var(--text-muted);
    }

    .dropzone .dz-preview {
      margin: 1rem;
    }

    .dropzone .dz-preview .dz-image {
      border-radius: 10px;
      overflow: hidden;
    }

    .dropzone .dz-preview .dz-progress {
      height: 6px;
      border-radius: 3px;
    }

    .dropzone .dz-preview .dz-progress .dz-upload {
      background-color: var(--primary-color);
    }

    .upload-icon {
      font-size: 3rem;
      color: var(--primary-color);
      margin-bottom: 1rem;
    }

    /* Gallery selection styles */
    .gallery-option {
      display: block;
      border: 1px solid var(--border-color);
      border-radius: 10px;
      padding: 1rem;
      margin-bottom: 1rem;
      transition: all 0.3s ease;
      cursor: pointer;
    }

    .gallery-option:hover {
      border-color: var(--primary-color);
      transform: translateY(-3px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    }

    .gallery-option.selected {
      border-color: var(--primary-color);
      background-color: rgba(67, 97, 238, 0.05);
    }

    .gallery-option-header {
      display: flex;
      align-items: center;
      margin-bottom: 0.5rem;
    }

    .gallery-radio {
      margin-right: 0.75rem;
    }

    .gallery-name {
      font-weight: 600;
      margin-bottom: 0;
    }

    .gallery-meta {
      font-size: 0.85rem;
      color: var(--text-muted);
    }

    /* Existing photos styles */
    .photo-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
      gap: 1rem;
    }

    .photo-item {
      position: relative;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 3px 10px rgba(0,0,0,0.1);
    }

    .photo-img {
      width: 100%;
      aspect-ratio: 1;
      object-fit: cover;
      transition: all 0.3s ease;
    }

    .photo-overlay {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.3s ease;
    }

    .photo-item:hover .photo-overlay {
      opacity: 1;
    }

    .photo-item:hover .photo-img {
      transform: scale(1.05);
    }

    .photo-actions {
      display: flex;
      gap: 0.5rem;
    }

    .photo-action {
      width: 35px;
      height: 35px;
      border-radius: 50%;
      background-color: white;
      color: var(--text-color);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1rem;
      transition: all 0.3s ease;
      cursor: pointer;
    }

    .photo-action:hover {
      background-color: var(--primary-color);
      color: white;
    }

    .progress-bar {
      height: 8px;
      background-color: var(--light-bg);
      border-radius: 4px;
      margin-top: 1.5rem;
      overflow: hidden;
    }

    .progress-value {
      background-color: var(--primary-color);
      height: 100%;
      width: 0;
      transition: width 0.3s ease;
    }

    .gallery-status {
      display: inline-block;
      padding: 0.3rem 0.6rem;
      border-radius: 50px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    .status-draft {
      background-color: rgba(108, 117, 125, 0.1);
      color: #6c757d;
    }

    .status-published {
      background-color: rgba(25, 135, 84, 0.1);
      color: #198754;
    }

    .status-private {
      background-color: rgba(13, 110, 253, 0.1);
      color: #0d6efd;
    }

    @media (max-width: 768px) {
      .content-card {
        padding: 1rem;
      }

      .dropzone {
        min-height: 150px;
        padding: 1rem;
      }

      .dropzone .dz-message {
        font-size: 1rem;
      }

      .upload-icon {
        font-size: 2rem;
      }
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container">
  <!-- Page Header -->
  <div class="page-header">
    <div class="container">
      <h1 class="page-title">Upload Photos</h1>
      <p class="mb-0 lead">Add photos to your galleries or create a new gallery.</p>
    </div>
  </div>

  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <div class="row">
    <div class="col-lg-8">
      <!-- Upload Form -->
      <div class="content-card">
        <div class="card-header-custom">
          <h5 class="card-title-custom">
            <i class="bi bi-cloud-upload me-2"></i>Upload Photos
          </h5>
        </div>

        <!-- Step 1: Select Gallery -->
        <div id="step1" class="mb-4">
          <h6 class="mb-3">Step 1: Select or Create Gallery</h6>

          <div class="gallery-selection mb-4">
            <!-- Existing Galleries -->
            <div class="existing-galleries mb-3">
              <label class="gallery-option">
                <div class="gallery-option-header">
                  <input type="radio" name="galleryOption" value="existing" class="gallery-radio" checked>
                  <h6 class="gallery-name">Add to Existing Gallery</h6>
                </div>
              </label>

              <div id="existingGalleryContainer" class="ms-4">
                <div class="mb-3">
                  <select class="form-select" id="existingGallery">
                    <option value="">Select Gallery</option>
                    <option value="g001">Smith Wedding (Dec 15, 2023)</option>
                    <option value="g002">Johnson Corporate Event (Nov 5, 2023)</option>
                    <option value="g003">Nature Portfolio</option>
                  </select>
                </div>

                <div id="galleryDetails" class="p-3 rounded border" style="display: none;">
                  <div class="d-flex justify-content-between align-items-start mb-2">
                    <h6 class="mb-0" id="selectedGalleryName">Smith Wedding</h6>
                    <span class="gallery-status status-published" id="selectedGalleryStatus">Published</span>
                  </div>
                  <p class="small text-muted mb-2" id="selectedGalleryDescription">Wedding photos from Smith's ceremony at Park Plaza Hotel.</p>
                  <div class="d-flex align-items-center">
                    <span class="small me-3" id="selectedGalleryPhotos"><i class="bi bi-images me-1"></i> 95 photos</span>
                    <span class="small" id="selectedGalleryDate"><i class="bi bi-calendar3 me-1"></i> Dec 16, 2023</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Create New Gallery -->
            <div class="new-gallery">
              <label class="gallery-option">
                <div class="gallery-option-header">
                  <input type="radio" name="galleryOption" value="new" class="gallery-radio">
                  <h6 class="gallery-name">Create New Gallery</h6>
                </div>
              </label>

              <div id="newGalleryContainer" class="ms-4" style="display: none;">
                <div class="mb-3">
                  <label for="galleryTitle" class="form-label">Gallery Title</label>
                  <input type="text" class="form-control" id="galleryTitle" placeholder="Enter gallery title">
                </div>

                <div class="mb-3">
                  <label for="galleryDescription" class="form-label">Description</label>
                  <textarea class="form-control" id="galleryDescription" rows="3" placeholder="Enter description (optional)"></textarea>
                </div>

                <div class="mb-3">
                  <label for="galleryCategory" class="form-label">Category</label>
                  <select class="form-select" id="galleryCategory">
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
                  <select class="form-select" id="galleryBooking">
                    <option value="">None</option>
                    <option value="b001">Smith Wedding - Dec 15, 2023</option>
                    <option value="b004">Corporate Headshots - Jan 20, 2024</option>
                    <option value="b005">Product Photoshoot - Feb 5, 2024</option>
                  </select>
                </div>

                <div class="form-check mb-3">
                  <input class="form-check-input" type="checkbox" value="" id="galleryPublic" checked>
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
        <div id="step2">
          <h6 class="mb-3">Step 2: Upload Photos</h6>

          <div class="dropzone-container">
            <div id="dropzoneUpload" class="dropzone">
              <div class="dz-message">
                <i class="bi bi-cloud-arrow-up upload-icon"></i>
                <div>Drag and drop photos here</div>
                <div class="text-muted small mt-2">or click to browse files</div>
              </div>
            </div>

            <div class="progress-container mt-3" style="display: none;">
              <div class="d-flex justify-content-between align-items-center mb-2">
                <span class="progress-text">Uploading photos...</span>
                <span class="progress-percentage">0%</span>
              </div>
              <div class="progress-bar">
                <div class="progress-value"></div>
              </div>
            </div>
          </div>

          <div class="mt-4">
            <div class="form-check mb-3">
              <input class="form-check-input" type="checkbox" value="" id="autoProcess" checked>
              <label class="form-check-label" for="autoProcess">
                Automatically optimize images
              </label>
              <div class="form-text">Resize large images for faster loading and reduce file size</div>
            </div>

            <div class="d-flex justify-content-between mt-4">
              <button type="button" class="btn btn-outline-custom" id="cancelUpload">Cancel</button>
              <button type="button" class="btn btn-primary-custom" id="startUpload">
                <i class="bi bi-cloud-upload me-2"></i>Upload Photos
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-4">
      <!-- Help & Tips -->
      <div class="content-card">
        <div class="card-header-custom">
          <h5 class="card-title-custom">
            <i class="bi bi-lightbulb me-2"></i>Tips for Uploading
          </h5>
        </div>

        <div class="tips-content">
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
      </div>

      <!-- My Galleries Quick Access -->
      <div class="content-card">
        <div class="card-header-custom">
          <h5 class="card-title-custom">
            <i class="bi bi-images me-2"></i>My Galleries
          </h5>
          <a href="${pageContext.request.contextPath}/gallery/gallery_list.jsp?userOnly=true" class="btn btn-sm btn-outline-custom">View All</a>
        </div>

        <div class="recent-galleries">
          <div class="gallery-option mb-2">
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <h6 class="gallery-name">Johnson Corporate Event</h6>
                <p class="gallery-meta mb-0">94 photos • Nov 5, 2023</p>
              </div>
              <span class="gallery-status status-published">Published</span>
            </div>
          </div>

          <div class="gallery-option mb-2">
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <h6 class="gallery-name">Nature Portfolio</h6>
                <p class="gallery-meta mb-0">52 photos • Sep 15, 2023</p>
              </div>
              <span class="gallery-status status-published">Published</span>
            </div>
          </div>

          <div class="gallery-option mb-2">
            <div class="d-flex justify-content-between align-items-start">
              <div>
                <h6 class="gallery-name">City Landscapes</h6>
                <p class="gallery-meta mb-0">38 photos • Aug 20, 2023</p>
              </div>
              <span class="gallery-status status-draft">Draft</span>
            </div>
          </div>
        </div>

        <div class="d-grid mt-3">
          <a href="${pageContext.request.contextPath}/gallery/gallery_list.jsp?userOnly=true" class="btn btn-outline-custom">
            <i class="bi bi-grid me-2"></i>Manage Galleries
          </a>
        </div>
      </div>
    </div>
  </div>

  <!-- Recently Uploaded Photos (shows after upload) -->
  <div class="content-card" id="recentUploadsCard" style="display: none;">
    <div class="card-header-custom">
      <h5 class="card-title-custom">
        <i class="bi bi-images me-2"></i>Recently Uploaded Photos
      </h5>
      <a href="#" class="btn btn-sm btn-primary-custom" id="editMetadataBtn">
        <i class="bi bi-pencil me-1"></i>Edit Metadata
      </a>
    </div>

    <div class="photo-grid">
      <!-- Photo 1 -->
      <div class="photo-item">
        <img src="https://images.unsplash.com/photo-1532712938310-34cb3982ef74?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3540&q=80" alt="Photo" class="photo-img">
        <div class="photo-overlay">
          <div class="photo-actions">
            <div class="photo-action">
              <i class="bi bi-pencil"></i>
            </div>
            <div class="photo-action">
              <i class="bi bi-trash"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Photo 2 -->
      <div class="photo-item">
        <img src="https://images.unsplash.com/photo-1511285560929-80b456f7a771?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3538&q=80" alt="Photo" class="photo-img">
        <div class="photo-overlay">
          <div class="photo-actions">
            <div class="photo-action">
              <i class="bi bi-pencil"></i>
            </div>
            <div class="photo-action">
              <i class="bi bi-trash"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Photo 3 -->
      <div class="photo-item">
        <img src="https://images.unsplash.com/photo-1555952494-efd681c7e3f9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3540&q=80" alt="Photo" class="photo-img">
        <div class="photo-overlay">
          <div class="photo-actions">
            <div class="photo-action">
              <i class="bi bi-pencil"></i>
            </div>
            <div class="photo-action">
              <i class="bi bi-trash"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Photo 4 -->
      <div class="photo-item">
        <img src="https://images.unsplash.com/photo-1554941426-e9604e34bc29?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3540&q=80" alt="Photo" class="photo-img">
        <div class="photo-overlay">
          <div class="photo-actions">
            <div class="photo-action">
              <i class="bi bi-pencil"></i>
            </div>
            <div class="photo-action">
              <i class="bi bi-trash"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Photo 5 -->
      <div class="photo-item">
        <img src="https://images.unsplash.com/photo-1534531173927-aeb928d54385?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3456&q=80" alt="Photo" class="photo-img">
        <div class="photo-overlay">
          <div class="photo-actions">
            <div class="photo-action">
              <i class="bi bi-pencil"></i>
            </div>
            <div class="photo-action">
              <i class="bi bi-trash"></i>
            </div>
          </div>
        </div>
      </div>

      <!-- Photo 6 -->
      <div class="photo-item">
        <img src="https://images.unsplash.com/photo-1540575861501-7cf05a4b125a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3540&q=80" alt="Photo" class="photo-img">
        <div class="photo-overlay">
          <div class="photo-actions">
            <div class="photo-action">
              <i class="bi bi-pencil"></i>
            </div>
            <div class="photo-action">
              <i class="bi bi-trash"></i>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="d-flex justify-content-between mt-4">
      <button type="button" class="btn btn-outline-custom" id="uploadMoreBtn">
        <i class="bi bi-plus-circle me-2"></i>Upload More Photos
      </button>
      <a href="${pageContext.request.contextPath}/gallery/gallery_details.jsp?id=g001" class="btn btn-primary-custom">
        <i class="bi bi-eye me-2"></i>View Gallery
      </a>
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
  // Initialize when document is ready
  document.addEventListener('DOMContentLoaded', function() {
    // Handle gallery selection
    const galleryOptions = document.querySelectorAll('.gallery-option');
    const galleryRadios = document.querySelectorAll('.gallery-radio');
    const existingGalleryContainer = document.getElementById('existingGalleryContainer');
    const newGalleryContainer = document.getElementById('newGalleryContainer');

    galleryOptions.forEach(function(option) {
      option.addEventListener('click', function() {
        // Update gallery options appearance
        galleryOptions.forEach(function(opt) {
          opt.classList.remove('selected');
        });
        this.classList.add('selected');

        // Find the radio button and check it
        const radio = this.querySelector('input[type="radio"]');
        if (radio) {
          radio.checked = true;

          // Show appropriate form based on selection
          if (radio.value === 'existing') {
            existingGalleryContainer.style.display = 'block';
            newGalleryContainer.style.display = 'none';
          } else if (radio.value === 'new') {
            existingGalleryContainer.style.display = 'none';
            newGalleryContainer.style.display = 'block';
          }
        }
      });
    });

    // Handle existing gallery selection
    const existingGallerySelect = document.getElementById('existingGallery');
    const galleryDetails = document.getElementById('galleryDetails');

    existingGallerySelect.addEventListener('change', function() {
      if (this.value) {
        // Show gallery details
        galleryDetails.style.display = 'block';

        // Simulate fetching gallery details from server
        // In a real app, this would be an AJAX call
        const galleries = {
          'g001': {
            name: 'Smith Wedding',
            status: 'Published',
            description: 'Wedding photos from Smith\'s ceremony at Park Plaza Hotel.',
            photos: 95,
            date: 'Dec 16, 2023'
          },
          'g002': {
            name: 'Johnson Corporate Event',
            status: 'Published',
            description: 'Professional photography from the annual Johnson company meeting.',
            photos: 94,
            date: 'Nov 5, 2023'
          },
          'g003': {
            name: 'Nature Portfolio',
            status: 'Published',
            description: 'Landscape photography samples showcasing natural beauty.',
            photos: 52,
            date: 'Sep 15, 2023'
          }
        };

        const selectedGallery = galleries[this.value];

        // Update gallery details
        document.getElementById('selectedGalleryName').textContent = selectedGallery.name;
        document.getElementById('selectedGalleryStatus').textContent = selectedGallery.status;
        document.getElementById('selectedGalleryStatus').className = 'gallery-status status-' + selectedGallery.status.toLowerCase();
        document.getElementById('selectedGalleryDescription').textContent = selectedGallery.description;
        document.getElementById('selectedGalleryPhotos').innerHTML = `<i class="bi bi-images me-1"></i> ${selectedGallery.photos} photos`;
        document.getElementById('selectedGalleryDate').innerHTML = `<i class="bi bi-calendar3 me-1"></i> ${selectedGallery.date}`;
      } else {
        galleryDetails.style.display = 'none';
      }
    });

    // Initialize Dropzone
    Dropzone.autoDiscover = false;

    const dropzone = new Dropzone("#dropzoneUpload", {
      url: "${pageContext.request.contextPath}/gallery/PhotoUploadServlet",
      paramName: "photos",
      maxFilesize: 20, // MB
      maxFiles: 100,
      acceptedFiles: "image/jpeg,image/png,image/webp",
      autoProcessQueue: false,
      addRemoveLinks: true,
      parallelUploads: 5,
      uploadMultiple: true,
      createImageThumbnails: true,
      thumbnailWidth: 120,
      thumbnailHeight: 120,
      previewTemplate: `
                                <div class="dz-preview dz-file-preview">
                                    <div class="dz-image">
                                        <img data-dz-thumbnail />
                                    </div>
                                    <div class="dz-details">
                                        <div class="dz-filename"><span data-dz-name></span></div>
                                        <div class="dz-size"><span data-dz-size></span></div>
                                    </div>
                                    <div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div>
                                    <div class="dz-error-message"><span data-dz-errormessage></span></div>
                                    <div class="dz-success-mark">
                                        <i class="bi bi-check-circle-fill"></i>
                                    </div>
                                    <div class="dz-error-mark">
                                        <i class="bi bi-x-circle-fill"></i>
                                    </div>
                                </div>
                            `
    });

    // Start Upload button
    document.getElementById('startUpload').addEventListener('click', function() {
      // Validate form inputs
      if (document.querySelector('input[name="galleryOption"]:checked').value === 'existing') {
        if (!document.getElementById('existingGallery').value) {
          showToast('Please select a gallery', 'error');
          return;
        }
      } else {
        if (!document.getElementById('galleryTitle').value) {
          showToast('Please enter a gallery title', 'error');
          return;
        }
      }

      // Check if files are selected
      if (dropzone.files.length === 0) {
        showToast('Please select files to upload', 'error');
        return;
      }

      // Show progress container
      document.querySelector('.progress-container').style.display = 'block';

      // Add form data
      const galleryOption = document.querySelector('input[name="galleryOption"]:checked').value;

      if (galleryOption === 'existing') {
        const galleryId = document.getElementById('existingGallery').value;
        dropzone.options.params = {
          galleryId: document.getElementById('existingGallery').value,
          galleryType: 'existing'
        };
      } else {
        dropzone.options.params = {
          galleryTitle: document.getElementById('galleryTitle').value,
          galleryDescription: document.getElementById('galleryDescription').value,
          galleryCategory: document.getElementById('galleryCategory').value,
          galleryBooking: document.getElementById('galleryBooking').value,
          galleryPublic: document.getElementById('galleryPublic').checked,
          galleryType: 'new'
        };
      }

      // Add auto process option
      dropzone.options.params.autoProcess = document.getElementById('autoProcess').checked;

      // Process the queue
      dropzone.processQueue();
    });

    // Cancel Upload button
    document.getElementById('cancelUpload').addEventListener('click', function() {
      dropzone.removeAllFiles(true);
      document.querySelector('.progress-container').style.display = 'none';
      showToast('Upload canceled', 'info');
    });

    // Handle upload progress
    dropzone.on("totaluploadprogress", function(progress) {
      document.querySelector('.progress-value').style.width = progress + "%";
      document.querySelector('.progress-percentage').textContent = Math.round(progress) + "%";
    });

    // Handle successful upload
    dropzone.on("success", function() {
      document.querySelector('.progress-text').textContent = "Upload complete!";
    });

    // Handle all files uploaded
    dropzone.on("queuecomplete", function() {
      // Show success message
      showToast('Photos uploaded successfully!', 'success');

      // Show recently uploaded section
      document.getElementById('recentUploadsCard').style.display = 'block';

      // Scroll to the uploaded photos section
      document.getElementById('recentUploadsCard').scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    });

    // Handle upload more button
    document.getElementById('uploadMoreBtn').addEventListener('click', function() {
      // Reset dropzone
      dropzone.removeAllFiles(true);
      document.querySelector('.progress-container').style.display = 'none';

      // Scroll to the upload form
      document.getElementById('step1').scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    });

    // Handle edit metadata button - this would open a form to edit photo details
    document.getElementById('editMetadataBtn').addEventListener('click', function(e) {
      e.preventDefault();
      alert('This would open a metadata editor in a real application.');
    });

    // Photo action buttons
    document.querySelectorAll('.photo-action').forEach(function(action) {
      action.addEventListener('click', function() {
        const icon = this.querySelector('i');
        if (icon.classList.contains('bi-pencil')) {
          alert('This would open an editor for this specific photo in a real application.');
        } else if (icon.classList.contains('bi-trash')) {
          if (confirm('Are you sure you want to delete this photo?')) {
            // Delete photo - in a real app, this would call an API
            this.closest('.photo-item').remove();
            showToast('Photo deleted successfully', 'success');
          }
        }
      });
    });

    // Helper function to show toast messages
    function showToast(message, type = 'info') {
      // Check if showToast function exists in the main.js
      if (typeof window.showToast === 'function') {
        window.showToast(message, type);
      } else {
        alert(message);
      }
    }
  });
</script>
</body>
</html>