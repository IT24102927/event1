<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Photographer Registration - SnapHouse</title>

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
                <div class="card-header">
                    <h3 class="card-title">Become a Photographer</h3>
                </div>
                <div class="card-body">
                    <form action="${pageContext.request.contextPath}/photographer/register" method="post">
                        <div class="mb-3">
                            <label for="businessName" class="form-label">Business Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="businessName" name="businessName" required>
                        </div>

                        <div class="mb-3">
                            <label for="biography" class="form-label">Biography <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="biography" name="biography" rows="4" required></textarea>
                        </div>

                        <div class="mb-3">
                            <label for="location" class="form-label">Location <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="location" name="location" required>
                        </div>

                        <div class="mb-3">
                            <label for="specialties" class="form-label">Specialties <span class="text-danger">*</span></label>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="specialties" value="Wedding" id="wedding">
                                <label class="form-check-label" for="wedding">Wedding</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="specialties" value="Portrait" id="portrait">
                                <label class="form-check-label" for="portrait">Portrait</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="specialties" value="Event" id="event">
                                <label class="form-check-label" for="event">Event</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="specialties" value="Corporate" id="corporate">
                                <label class="form-check-label" for="corporate">Corporate</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="specialties" value="Family" id="family">
                                <label class="form-check-label" for="family">Family</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="specialties" value="Product" id="product">
                                <label class="form-check-label" for="product">Product</label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="basePrice" class="form-label">Base Price per Hour ($) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="basePrice" name="basePrice" step="0.01" min="1" required>
                        </div>

                        <div class="mb-3">
                            <label for="yearsOfExperience" class="form-label">Years of Experience</label>
                            <input type="number" class="form-control" id="yearsOfExperience" name="yearsOfExperience" min="0">
                        </div>

                        <div class="mb-3">
                            <label for="contactPhone" class="form-label">Contact Phone</label>
                            <input type="tel" class="form-control" id="contactPhone" name="contactPhone">
                        </div>

                        <div class="mb-3">
                            <label for="websiteUrl" class="form-label">Website URL</label>
                            <input type="url" class="form-control" id="websiteUrl" name="websiteUrl">
                        </div>

                        <div class="mb-3">
                            <label for="photographerType" class="form-label">Photographer Type <span class="text-danger">*</span></label>
                            <select class="form-select" id="photographerType" name="photographerType" required>
                                <option value="" selected disabled>Select photographer type</option>
                                <option value="freelance">Freelance</option>
                                <option value="studio">Studio</option>
                            </select>
                        </div>

                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary">Register as Photographer</button>
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