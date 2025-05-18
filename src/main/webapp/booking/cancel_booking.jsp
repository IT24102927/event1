<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cancel Booking - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container mt-4">
    <!-- Include Messages -->
    <jsp:include page="/includes/messages.jsp" />

    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header bg-danger text-white">
                    <h3 class="card-title mb-0">Cancel Booking</h3>
                </div>
                <div class="card-body">
                    <h5>Are you sure you want to cancel this booking?</h5>

                    <c:if test="${not empty booking}">
                        <div class="card bg-light mb-4">
                            <div class="card-body">
                                <h6>Booking Details:</h6>
                                <p><strong>Booking ID:</strong> ${booking.bookingId}</p>
                                <p><strong>Event Type:</strong> ${booking.eventType}</p>
                                <p><strong>Event Date:</strong> ${booking.eventDateTime}</p>
                                <p><strong>Location:</strong> ${booking.eventLocation}</p>
                            </div>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/booking/cancel" method="post">
                        <input type="hidden" name="bookingId" value="${param.id}">

                        <div class="mb-3">
                            <label for="cancellationReason" class="form-label">Please provide a reason for cancellation:</label>
                            <textarea class="form-control" id="cancellationReason" name="cancellationReason" rows="3"></textarea>
                        </div>

                        <div class="form-check mb-4">
                            <input class="form-check-input" type="checkbox" id="confirmedCancel" name="confirmedCancel" value="yes" required>
                            <label class="form-check-label" for="confirmedCancel">
                                I confirm that I want to cancel this booking
                            </label>
                        </div>

                        <div class="d-grid gap-2 d-md-flex">
                            <button type="submit" class="btn btn-danger">
                                <i class="bi bi-x-circle me-2"></i>Cancel Booking
                            </button>
                            <a href="${pageContext.request.contextPath}/booking/booking_details.jsp?id=${param.id}" class="btn btn-secondary">
                                <i class="bi bi-arrow-left me-2"></i>Go Back
                            </a>
                        </div>
                    </form>
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