<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.photobooking.model.booking.BookingManager" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="java.util.List" %>

<%
  // Get current user from session
  String currentUserId = (String) session.getAttribute("userId");
  User currentUser = (User) session.getAttribute("user");

  if (currentUserId == null || currentUser == null) {
    response.sendRedirect(request.getContextPath() + "/user/login.jsp");
    return;
  }

  BookingManager bookingManager = new BookingManager();
  List<Booking> bookings;

  // Get bookings based on user type
  if (currentUser.getUserType() == User.UserType.CLIENT) {
    bookings = bookingManager.getBookingsByClient(currentUserId);
  } else if (currentUser.getUserType() == User.UserType.PHOTOGRAPHER) {
    bookings = bookingManager.getBookingsByPhotographer(currentUserId);
  } else {
    bookings = bookingManager.getAllBookings();
  }

  request.setAttribute("bookings", bookings);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Bookings - SnapHouse</title>

  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <!-- Bootstrap Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid">
  <div class="row">
    <!-- Include Sidebar with "bookings" as active page -->
    <c:set var="activePage" value="bookings" scope="request"/>
    <jsp:include page="/includes/sidebar.jsp" />

    <!-- Main Content Area -->
    <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
      <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
        <h1 class="h2">My Bookings</h1>
        <div class="btn-toolbar mb-2 mb-md-0">
          <div class="btn-group me-2">
            <a href="${pageContext.request.contextPath}/booking/booking_form.jsp" class="btn btn-sm btn-primary">
              <i class="bi bi-calendar-plus me-1"></i>New Booking
            </a>
          </div>
        </div>
      </div>

      <!-- Include Messages -->
      <jsp:include page="/includes/messages.jsp" />

      <!-- Filter Options -->
      <div class="row mb-4">
        <div class="col-md-6">
          <select class="form-select" id="statusFilter">
            <option value="">All Status</option>
            <option value="PENDING">Pending</option>
            <option value="CONFIRMED">Confirmed</option>
            <option value="COMPLETED">Completed</option>
            <option value="CANCELLED">Cancelled</option>
          </select>
        </div>
        <div class="col-md-6">
          <input type="text" class="form-control" id="searchInput" placeholder="Search bookings...">
        </div>
      </div>

      <!-- Bookings Table -->
      <div class="table-responsive">
        <table class="table table-striped" id="bookingsTable">
          <thead>
          <tr>
            <th>Booking ID</th>
            <th>Date</th>
            <th>Event Type</th>
            <th>Location</th>
            <c:if test="${sessionScope.user.userType == 'CLIENT'}">
              <th>Photographer</th>
            </c:if>
            <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
              <th>Client</th>
            </c:if>
            <th>Status</th>
            <th>Actions</th>
          </tr>
          </thead>
          <tbody>
          <c:choose>
            <c:when test="${not empty bookings}">
              <c:forEach var="booking" items="${bookings}">
                <tr>
                  <td>${booking.bookingId}</td>
                  <td>${booking.eventDateTime}</td>
                  <td>${booking.eventType}</td>
                  <td>${booking.eventLocation}</td>
                  <c:if test="${sessionScope.user.userType == 'CLIENT'}">
                    <td>${booking.photographerId}</td>
                  </c:if>
                  <c:if test="${sessionScope.user.userType == 'PHOTOGRAPHER'}">
                    <td>${booking.clientId}</td>
                  </c:if>
                  <td>
                    <c:choose>
                      <c:when test="${booking.status == 'PENDING'}">
                        <span class="badge bg-warning">Pending</span>
                      </c:when>
                      <c:when test="${booking.status == 'CONFIRMED'}">
                        <span class="badge bg-success">Confirmed</span>
                      </c:when>
                      <c:when test="${booking.status == 'COMPLETED'}">
                        <span class="badge bg-primary">Completed</span>
                      </c:when>
                      <c:when test="${booking.status == 'CANCELLED'}">
                        <span class="badge bg-danger">Cancelled</span>
                      </c:when>
                    </c:choose>
                  </td>
                  <td>
                    <a href="${pageContext.request.contextPath}/booking/booking_details.jsp?id=${booking.bookingId}"
                       class="btn btn-sm btn-outline-primary">
                      <i class="bi bi-eye me-1"></i>View
                    </a>
                    <c:if test="${booking.status != 'CANCELLED' && booking.status != 'COMPLETED'}">
                      <a href="${pageContext.request.contextPath}/booking/cancel?id=${booking.bookingId}"
                         class="btn btn-sm btn-outline-danger"
                         onclick="return confirm('Are you sure you want to cancel this booking?')">
                        <i class="bi bi-x-circle me-1"></i>Cancel
                      </a>
                    </c:if>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="8" class="text-center py-4">
                  No bookings found
                </td>
              </tr>
            </c:otherwise>
          </c:choose>
          </tbody>
        </table>
      </div>
    </main>
  </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
  // Filter functionality
  document.getElementById('statusFilter').addEventListener('change', filterTable);
  document.getElementById('searchInput').addEventListener('keyup', filterTable);

  function filterTable() {
    const statusFilter = document.getElementById('statusFilter').value.toLowerCase();
    const searchInput = document.getElementById('searchInput').value.toLowerCase();
    const table = document.getElementById('bookingsTable');
    const rows = table.getElementsByTagName('tr');

    for (let i = 1; i < rows.length; i++) {
      const row = rows[i];
      const cells = row.getElementsByTagName('td');
      let showRow = true;

      // Status filter
      if (statusFilter) {
        const statusBadge = cells[5].querySelector('.badge');
        if (statusBadge) {
          const rowStatus = statusBadge.textContent.toLowerCase();
          if (rowStatus !== statusFilter) {
            showRow = false;
          }
        }
      }

      // Search filter
      if (searchInput && showRow) {
        let rowText = '';
        for (let j = 0; j < cells.length; j++) {
          rowText += cells[j].textContent.toLowerCase() + ' ';
        }
        if (!rowText.includes(searchInput)) {
          showRow = false;
        }
      }

      row.style.display = showRow ? '' : 'none';
    }
  }
</script>
</body>
</html>