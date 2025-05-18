<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.photobooking.model.booking.BookingQueueManager" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
  // Get current user from session
  User currentUser = (User) session.getAttribute("user");

  if (currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    return;
  }

  // Check if we have the queued bookings attribute from the servlet
  List<Booking> queuedBookings = (List<Booking>) request.getAttribute("queuedBookings");

  // If we don't have queued bookings from the servlet, redirect to the servlet first
  if (queuedBookings == null) {
    response.sendRedirect(request.getContextPath() + "/booking/queue");
    return;
  }

  // Fallback to empty list if needed
  if (queuedBookings == null) {
    queuedBookings = new ArrayList<>();
  }

  // Get queue statistics from the servlet or directly (fallback)
  Integer totalQueueSize = (Integer) request.getAttribute("totalQueueSize");
  Integer userQueueSize = (Integer) request.getAttribute("userQueueSize");

  // Use fallback values if attributes are not set
  if (totalQueueSize == null) totalQueueSize = queuedBookings.size();
  if (userQueueSize == null) userQueueSize = queuedBookings.size();

  // Set attributes in request for use in JSP
  request.setAttribute("queuedBookings", queuedBookings);
  request.setAttribute("totalQueueSize", totalQueueSize);
  request.setAttribute("userQueueSize", userQueueSize);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Booking Queue - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

  <style>
    .queue-header {
      background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
      color: white;
      padding: 30px 0;
      margin-bottom: 30px;
      border-radius: 0 0 10px 10px;
    }

    .queue-card {
      background-color: white;
      border-radius: 10px;
      box-shadow: 0 0 20px rgba(0,0,0,0.05);
      padding: 30px;
      margin-bottom: 30px;
    }

    .queue-item {
      border-left: 5px solid #4361ee;
      margin-bottom: 15px;
      padding: 15px;
      background-color: #f8f9fa;
      border-radius: 5px;
      transition: all 0.3s ease;
    }

    .queue-item:hover {
      transform: translateY(-3px);
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .queue-stats {
      background-color: #f8f9fa;
      border-radius: 10px;
      padding: 20px;
      margin-bottom: 20px;
    }

    .stat-item {
      text-align: center;
      padding: 15px;
    }

    .stat-number {
      font-size: 2rem;
      font-weight: 600;
      color: #4361ee;
    }

    .stat-label {
      font-size: 0.9rem;
      color: #6c757d;
    }
  </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<!-- Queue Header -->
<div class="queue-header">
  <div class="container">
    <h1 class="display-5">Booking Queue</h1>
    <p class="lead">Manage your photography booking requests</p>
  </div>
</div>

<div class="container">
  <!-- Include Messages -->
  <jsp:include page="/includes/messages.jsp" />

  <!-- Queue Statistics -->
  <div class="row mb-4">
    <div class="col-md-8 offset-md-2">
      <div class="queue-stats">
        <div class="row">
          <div class="col-md-6">
            <div class="stat-item">
              <div class="stat-number">${userQueueSize}</div>
              <div class="stat-label">
                <c:choose>
                  <c:when test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                    Bookings Awaiting Your Approval
                  </c:when>
                  <c:when test="${sessionScope.user.userType == 'CLIENT'}">
                    Your Pending Bookings
                  </c:when>
                  <c:otherwise>
                    Total Bookings in Queue
                  </c:otherwise>
                </c:choose>
              </div>
            </div>
          </div>
          <c:if test="${sessionScope.user.userType == 'ADMIN' || sessionScope.user.userType == 'PHOTOGRAPHER'}">
            <div class="col-md-6">
              <div class="stat-item">
                <div class="stat-number">${totalQueueSize}</div>
                <div class="stat-label">System-wide Queue Size</div>
              </div>
            </div>
          </c:if>
        </div>
      </div>
    </div>
  </div>

  <div class="row">
    <!-- Queue List -->
    <div class="col-md-8">
      <div class="queue-card">
        <div class="d-flex justify-content-between align-items-center mb-4">
          <h2 class="h4 mb-0">
            <c:choose>
              <c:when test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                Bookings Pending Your Approval
              </c:when>
              <c:when test="${sessionScope.user.userType == 'CLIENT'}">
                Your Pending Booking Requests
              </c:when>
              <c:otherwise>
                All Pending Bookings
              </c:otherwise>
            </c:choose>
          </h2>

          <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER' || sessionScope.user.userType == 'ADMIN'}">
            <div class="btn-group">
              <form action="${pageContext.request.contextPath}/booking/queue" method="post">
                <input type="hidden" name="action" value="processNext">
                <button type="submit" class="btn btn-primary btn-sm">
                  <i class="bi bi-check2-circle me-1"></i>Process Next
                </button>
              </form>

              <c:if test="${sessionScope.user.userType == 'ADMIN'}">
                <form action="${pageContext.request.contextPath}/booking/queue" method="post" class="ms-2">
                  <input type="hidden" name="action" value="clear">
                  <button type="submit" class="btn btn-outline-danger btn-sm"
                          onclick="return confirm('Are you sure you want to clear all queues?')">
                    <i class="bi bi-trash3 me-1"></i>Clear All
                  </button>
                </form>
              </c:if>
            </div>
          </c:if>
        </div>

        <c:choose>
          <c:when test="${not empty queuedBookings && queuedBookings.size() > 0}">
            <c:forEach var="booking" items="${queuedBookings}" varStatus="status">
              <div class="queue-item">
                <div class="d-flex justify-content-between align-items-center">
                  <div>
                    <h5 class="mb-1">Queue Position #${status.index + 1}</h5>
                    <p class="mb-1"><strong>Booking ID:</strong> ${booking.bookingId}</p>
                    <p class="mb-1"><strong>Event Type:</strong> ${booking.eventType}</p>
                    <p class="mb-1"><strong>Event Date:</strong> ${booking.eventDateTime}</p>
                    <p class="mb-1"><strong>Location:</strong> ${booking.eventLocation}</p>
                    <p class="mb-0"><strong>Price:</strong> $${booking.totalPrice}</p>
                  </div>

                  <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER' || sessionScope.user.userType == 'ADMIN'}">
                    <form action="${pageContext.request.contextPath}/booking/queue" method="post">
                      <input type="hidden" name="action" value="processSpecific">
                      <input type="hidden" name="bookingId" value="${booking.bookingId}">
                      <button type="submit" class="btn btn-success">
                        <i class="bi bi-check-circle me-1"></i>Approve
                      </button>
                    </form>
                  </c:if>
                </div>
              </div>
            </c:forEach>
          </c:when>
          <c:otherwise>
            <div class="alert alert-info">
              <i class="bi bi-info-circle me-2"></i>
              <c:choose>
                <c:when test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                  No pending bookings awaiting your approval.
                </c:when>
                <c:when test="${sessionScope.user.userType == 'CLIENT'}">
                  You don't have any pending booking requests.
                </c:when>
                <c:otherwise>
                  No bookings in the queue.
                </c:otherwise>
              </c:choose>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>

    <!-- Queue Actions -->
    <div class="col-md-4">
      <div class="queue-card">
        <h3 class="h5 mb-4">Queue Actions</h3>

        <c:if test="${sessionScope.user.userType == 'CLIENT'}">
          <div class="d-grid gap-2 mb-4">
            <a href="${pageContext.request.contextPath}/booking/booking_form.jsp" class="btn btn-primary">
              <i class="bi bi-calendar-plus me-2"></i>Create New Booking
            </a>
          </div>

          <div class="alert alert-info">
            <h6><i class="bi bi-info-circle me-2"></i>About the Booking Queue</h6>
            <p class="mb-0">Your booking requests are placed in a queue and will be processed by photographers in the order they were received. Once approved, your booking will be confirmed and you'll receive a notification.</p>
          </div>
        </c:if>

        <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
          <div class="card mb-4">
            <div class="card-header">Batch Processing</div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/booking/queue" method="post">
                <input type="hidden" name="action" value="processBatch">

                <div class="mb-3">
                  <label for="limit" class="form-label">Number of bookings to process:</label>
                  <select class="form-select" id="limit" name="limit">
                    <option value="1">1 booking</option>
                    <option value="5" selected>5 bookings</option>
                    <option value="10">10 bookings</option>
                    <option value="20">20 bookings</option>
                  </select>
                </div>

                <button type="submit" class="btn btn-primary w-100">
                  <i class="bi bi-lightning-charge me-1"></i>Process Batch
                </button>
              </form>
            </div>
          </div>

          <div class="alert alert-info">
            <h6><i class="bi bi-info-circle me-2"></i>Processing Tips</h6>
            <p class="mb-0">Bookings in your queue are sorted by request date. Process them regularly to maintain good client satisfaction. You can approve individual bookings or process them in batches.</p>
          </div>
        </c:if>

        <c:if test="${sessionScope.user.userType == 'ADMIN'}">
          <div class="card mb-4">
            <div class="card-header">Advanced Queue Management</div>
            <div class="card-body">
              <form action="${pageContext.request.contextPath}/booking/queue" method="post" class="mb-3">
                <input type="hidden" name="action" value="processBatch">

                <div class="mb-3">
                  <label for="adminLimit" class="form-label">Batch process:</label>
                  <select class="form-select" id="adminLimit" name="limit">
                    <option value="5">5 bookings</option>
                    <option value="10">10 bookings</option>
                    <option value="20">20 bookings</option>
                    <option value="100">All bookings</option>
                  </select>
                </div>

                <button type="submit" class="btn btn-success w-100">
                  <i class="bi bi-lightning-charge me-1"></i>Process Batch
                </button>
              </form>
            </div>
          </div>
        </c:if>

        <div class="d-grid">
          <a href="${pageContext.request.contextPath}/booking/booking_list.jsp" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left me-2"></i>Back to Bookings
          </a>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>