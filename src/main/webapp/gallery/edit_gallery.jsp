<%-- edit_gallery.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Edit Gallery - SnapHouse</title>

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

    .form-container {
      max-width: 800px;
      margin: 2rem auto;
      background: white;
      padding: 2rem;
      border-radius: 10px;
      box-shadow: 0 0 20px rgba(0,0,0,0.05);
    }

    .form-header {
      border-bottom: 2px solid #f1f1f1;
      margin-bottom: 2rem;
      padding-bottom: 1rem;
    }

    .form-footer {
      border-top: 2px solid #f1f1f1;
      margin-top: 2rem;
      padding-top: 1rem;
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <div class="form-container">
    <div class="form-header">
      <h1 class="h3">Edit Gallery</h1>
      <p class="text-muted">Update your gallery information</p>
    </div>

    <form action="${pageContext.request.contextPath}/gallery/update" method="post">
      <input type="hidden" name="galleryId" value="${gallery.galleryId}">

      <div class="mb-3">
        <label for="title" class="form-label">Gallery Title <span class="text-danger">*</span></label>
        <input type="text" class="form-control" id="title" name="title" value="${gallery.title}" required>
      </div>

      <div class="mb-3">
        <label for="description" class="form-label">Description</label>
        <textarea class="form-control" id="description" name="description" rows="3">${gallery.description}</textarea>
      </div>

      <div class="mb-3">
        <label for="category" class="form-label">Category</label>
        <select class="form-select" id="category" name="category">
          <option value="">Select Category</option>
          <option value="WEDDING" ${gallery.category == 'WEDDING' ? 'selected' : ''}>Wedding</option>
          <option value="PORTRAIT" ${gallery.category == 'PORTRAIT' ? 'selected' : ''}>Portrait</option>
          <option value="EVENT" ${gallery.category == 'EVENT' ? 'selected' : ''}>Event</option>
          <option value="CORPORATE" ${gallery.category == 'CORPORATE' ? 'selected' : ''}>Corporate</option>
          <option value="LANDSCAPE" ${gallery.category == 'LANDSCAPE' ? 'selected' : ''}>Landscape</option>
          <option value="PRODUCT" ${gallery.category == 'PRODUCT' ? 'selected' : ''}>Product</option>
          <option value="OTHER" ${gallery.category == 'OTHER' ? 'selected' : ''}>Other</option>
        </select>
      </div>

      <div class="mb-3">
        <label for="bookingId" class="form-label">Associated Booking (optional)</label>
        <select class="form-select" id="bookingId" name="bookingId">
          <option value="">None</option>
          <!-- This would be populated with the photographer's bookings -->
          <c:forEach var="booking" items="${bookings}">
            <option value="${booking.bookingId}" ${gallery.bookingId == booking.bookingId ? 'selected' : ''}>
                ${booking.eventType} - <fmt:formatDate value="${booking.eventDateTime}" pattern="MMM dd, yyyy"/>
            </option>
          </c:forEach>
        </select>
      </div>

      <div class="mb-3">
        <label for="status" class="form-label">Gallery Visibility</label>
        <select class="form-select" id="status" name="status">
          <option value="DRAFT" ${gallery.status == 'DRAFT' ? 'selected' : ''}>Draft (Only visible to you)</option>
          <option value="PRIVATE" ${gallery.status == 'PRIVATE' ? 'selected' : ''}>Private (Only visible to client)</option>
          <option value="PUBLISHED" ${gallery.status == 'PUBLISHED' ? 'selected' : ''}>Published (Visible to everyone)</option>
        </select>
      </div>

      <div class="form-footer d-flex justify-content-between">
        <a href="${pageContext.request.contextPath}/gallery/details?id=${gallery.galleryId}" class="btn btn-outline-secondary">
          <i class="bi bi-arrow-left"></i> Cancel
        </a>
        <button type="submit" class="btn btn-primary">
          <i class="bi bi-save"></i> Save Changes
        </button>
      </div>
    </form>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
