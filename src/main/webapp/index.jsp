<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SnapHouse - Book Photography & Videography Services</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', sans-serif;
        }
        .primary-section {
            background-color: #ffffff;
        }
        .highlight-section {
            background-color: #f0f2f5;
        }
        .hero-custom {
            background: linear-gradient(135deg, #0d6efd 30%, #6f42c1 100%);
            color: white;
        }
        .icon-box {
            width: 60px;
            height: 60px;
            background-color: #0d6efd;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            margin: 0 auto 15px;
        }
        .hover-light:hover {
            color: #F0EBD8 !important;
            transition: color 0.3s ease;
        }
        .social-icons a:hover {
            transform: translateY(-3px);
        }
        footer .text-muted {
            color: #e0e0e0 !important;
        }
    </style>
</head>
<body>

<!-- Header (from header.jsp) -->
<jsp:include page= "/includes/header.jsp" />

<!-- Hero Section -->
<section class="hero-custom p-5 text-center">
    <div class="container">
        <h1 class="display-4 fw-bold">Capture Life's Best Moments</h1>
        <p class="lead mb-4">Easily book professional photography and videography for any event</p>
        <a href="${pageContext.request.contextPath}/user/register.jsp" class="btn btn-outline-light btn-lg me-3">Get Started</a>
        <a href="${pageContext.request.contextPath}/photographer/photographer_list.jsp" class="btn btn-light btn-lg">Browse Professionals</a>
    </div>
</section>

<!-- How It Works -->
<section class="py-5 highlight-section">
    <div class="container">
        <h2 class="text-center mb-5">How Booking Works</h2>
        <div class="row text-center g-4">
            <div class="col-md-4">
                <div class="icon-box"><i class="bi bi-search"></i></div>
                <h5>Explore Services</h5>
                <p>Discover photographers and videographers for weddings, birthdays, and corporate events.</p>
            </div>
            <div class="col-md-4">
                <div class="icon-box"><i class="bi bi-calendar-check"></i></div>
                <h5>Schedule Easily</h5>
                <p>Pick your date, time, and service - and confirm your session instantly.</p>
            </div>
            <div class="col-md-4">
                <div class="icon-box"><i class="bi bi-image"></i></div>
                <h5>Get Your Memories</h5>
                <p>Receive high-quality edited photos and videos after your event.</p>
            </div>
        </div>
    </div>
</section>

<!-- Services -->
<section class="py-5 primary-section">
    <div class="container">
        <h2 class="text-center mb-5">What We Offer</h2>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-heart-pulse fs-1 text-danger mb-3"></i>
                        <h4>Wedding Shoots</h4>
                        <p>Beautifully crafted memories of your most special day.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-person-circle fs-1 text-success mb-3"></i>
                        <h4>Portrait Sessions</h4>
                        <p>Solo, couple, or family - book a studio or outdoor portrait shoot.</p>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-camera-video fs-1 text-warning mb-3"></i>
                        <h4>Event Videography</h4>
                        <p>Record corporate events, concerts, and private parties in stunning quality.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="py-5 bg-dark text-white text-center">
    <div class="container">
        <h2>Book with Confidence</h2>
        <p class="mb-4">Thousands trust SnapHouse for seamless bookings and amazing results.</p>
        <a href="${pageContext.request.contextPath}/photographer/photographer_list.jsp" class="btn btn-outline-light btn-lg">Start Booking</a>
    </div>
</section>

<!-- Footer (from footer.jsp) -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>