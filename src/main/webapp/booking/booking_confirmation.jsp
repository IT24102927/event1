<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmation - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- Custom CSS -->
    <style>
        .confirmation-header {
            background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
            color: white;
            padding: 50px 0;
            margin-bottom: 30px;
            border-radius: 0 0 10px 10px;
            text-align: center;
        }

        .confirmation-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.05);
            padding: 30px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }

        .confirmation-icon {
            font-size: 60px;
            color: #4361ee;
            margin-bottom: 20px;
        }

        .booking-details {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .detail-row {
            margin-bottom: 15px;
        }

        .detail-label {
            font-weight: 600;
            color: #6c757d;
        }

        .success-badge {
            position: absolute;
            top: 0;
            right: 0;
            background-color: #4361ee;
            color: white;
            padding: 10px 20px;
            transform: rotate(45deg) translate(20px, -15px);
            transform-origin: top right;
            font-size: 0.8rem;
            font-weight: 600;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<!-- Confirmation Header -->
<div class="confirmation-header">
    <div class="container">
        <h1 class="display-4">Booking Confirmed!</h1>
        <p class="lead">Your photography session has been successfully booked</p>
    </div>
</div>

<div class="container">
    <!-- Include Messages -->
    <jsp:include page="/includes/messages.jsp" />

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="confirmation-card text-center">
                <div class="success-badge">CONFIRMED</div>
                <div class="confirmation-icon">
                    <i class="bi bi-check-circle"></i>
                </div>
                <h2 class="mb-4">Thank You for Your Booking!</h2>
                <p class="mb-4">Your booking has been confirmed and the photographer has been notified. You'll receive an email confirmation shortly with all the details.</p>

                <div class="booking-details text-start">
                    <h4 class="mb-4">Booking Details</h4>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Booking ID:</div>
                        <div class="col-md-8">${booking.bookingId}</div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Photographer:</div>
                        <div class="col-md-8">${photographer.businessName}</div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Service Package:</div>
                        <div class="col-md-8">${service.name}</div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Event Date:</div>
                        <div class="col-md-8">
                            <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                            <fmt:formatDate value="${parsedDate}" pattern="MMMM d, yyyy" />
                        </div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Time:</div>
                        <div class="col-md-8">
                            <fmt:parseDate value="${booking.eventDateTime}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedTime" />
                            <fmt:formatDate value="${parsedTime}" pattern="h:mm a" />
                        </div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Location:</div>
                        <div class="col-md-8">${booking.eventLocation}</div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Event Type:</div>
                        <div class="col-md-8">${booking.eventType}</div>
                    </div>

                    <div class="row detail-row">
                        <div class="col-md-4 detail-label">Total Price:</div>
                        <div class="col-md-8">$${booking.totalPrice}</div>
                    </div>
                </div>

                <p class="mb-4">If you need to make any changes or have questions about your booking, please contact the photographer directly or visit your bookings page.</p>

                <div class="d-grid gap-3 d-md-flex justify-content-md-center mt-5">
                    <a href="${pageContext.request.contextPath}/booking/list" class="btn btn-primary btn-lg">
                        <i class="bi bi-list me-2"></i>View All Bookings
                    </a>
                    <a href="${pageContext.request.contextPath}/user/dashboard.jsp" class="btn btn-outline-primary btn-lg">
                        <i class="bi bi-speedometer2 me-2"></i>Go to Dashboard
                    </a>
                </div>
            </div>

            <!-- What's Next Card -->
            <div class="confirmation-card">
                <h3 class="mb-4">What's Next?</h3>

                <div class="row">
                    <div class="col-md-6 mb-4">
                        <div class="d-flex">
                            <div class="flex-shrink-0 me-3 text-primary">
                                <i class="bi bi-envelope-check fs-3"></i>
                            </div>
                            <div>
                                <h5>Check Your Email</h5>
                                <p>You'll receive a detailed confirmation email with all the information about your booking.</p>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6 mb-4">
                        <div class="d-flex">
                            <div class="flex-shrink-0 me-3 text-primary">
                                <i class="bi bi-chat-dots fs-3"></i>
                            </div>
                            <div>
                                <h5>Photographer Contact</h5>
                                <p>The photographer may reach out to discuss specific details about your session.</p>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6 mb-4">
                        <div class="d-flex">
                            <div class="flex-shrink-0 me-3 text-primary">
                                <i class="bi bi-calendar-check fs-3"></i>
                            </div>
                            <div>
                                <h5>Prepare for Your Session</h5>
                                <p>Plan outfits, locations, and any specific shots you'd like to capture during your session.</p>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="d-flex">
                            <div class="flex-shrink-0 me-3 text-primary">
                                <i class="bi bi-clock-history fs-3"></i>
                            </div>
                            <div>
                                <h5>Day of Your Event</h5>
                                <p>The photographer will arrive at the scheduled time and location ready to capture your special moments.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>