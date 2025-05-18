<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Success message from session -->
<c:if test="${not empty sessionScope.successMessage}">
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i>
      ${sessionScope.successMessage}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
  <c:remove var="successMessage" scope="session" />
</c:if>

<!-- Error message from session -->
<c:if test="${not empty sessionScope.errorMessage}">
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    <i class="bi bi-exclamation-triangle-fill me-2"></i>
      ${sessionScope.errorMessage}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
  <c:remove var="errorMessage" scope="session" />
</c:if>

<!-- Warning message from session -->
<c:if test="${not empty sessionScope.warningMessage}">
  <div class="alert alert-warning alert-dismissible fade show" role="alert">
    <i class="bi bi-exclamation-circle-fill me-2"></i>
      ${sessionScope.warningMessage}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
  <c:remove var="warningMessage" scope="session" />
</c:if>

<!-- Info message from session -->
<c:if test="${not empty sessionScope.infoMessage}">
  <div class="alert alert-info alert-dismissible fade show" role="alert">
    <i class="bi bi-info-circle-fill me-2"></i>
      ${sessionScope.infoMessage}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
  <c:remove var="infoMessage" scope="session" />
</c:if>

<!-- Success message from request -->
<c:if test="${not empty requestScope.successMessage}">
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i>
      ${requestScope.successMessage}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>

<!-- Error message from request -->
<c:if test="${not empty requestScope.errorMessage}">
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    <i class="bi bi-exclamation-triangle-fill me-2"></i>
      ${requestScope.errorMessage}
    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
  </div>
</c:if>

<!-- Auto-close alerts after 5 seconds -->
<script>
  // Wait for the DOM to fully load
  document.addEventListener('DOMContentLoaded', function() {
    // Get all the alert elements
    const alerts = document.querySelectorAll('.alert');

    // Set a timeout to close each alert after 5 seconds
    alerts.forEach(function(alert) {
      setTimeout(function() {
        // Create and trigger the close event
        const closeEvent = new bootstrap.Alert(alert);
        closeEvent.close();
      }, 5000);
    });
  });
</script>