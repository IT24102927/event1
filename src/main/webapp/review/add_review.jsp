<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Review - SnapHouse</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <style>
        .rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
        }
        .rating input {
            display: none;
        }
        .rating label {
            cursor: pointer;
            font-size: 30px;
            color: #ccc;
            padding: 5px;
        }
        .rating input:checked ~ label {
            color: #ffcc00;
        }
        .rating label:hover,
        .rating label:hover ~ label {
            color: #ffcc00;
        }
    </style>
</head>
<body>
<jsp:include page="../includes/header.jsp" />

<div class="container mt-5">
    <div class="row">
        <div class="col-lg-8 mx-auto">
            <jsp:include page="../includes/messages.jsp" />

            <h2 class="mb-4">Write a Review</h2>

            <div class="card mb-4">
                <div class="card-body">
                    <h4 class="card-title">Reviewing: ${photographer.businessName}</h4>
                    <p class="card-text text-muted">${photographer.location}</p>

                    <form action="${pageContext.request.contextPath}/review/add" method="post">
                        <input type="hidden" name="photographerId" value="${photographer.photographerId}">

                        <div class="mb-3">
                            <label class="form-label">Your Rating</label>
                            <div class="rating">
                                <input type="radio" name="rating" value="5" id="star5" required>
                                <label for="star5"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="4" id="star4">
                                <label for="star4"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="3" id="star3">
                                <label for="star3"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="2" id="star2">
                                <label for="star2"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="1" id="star1">
                                <label for="star1"><i class="bi bi-star-fill"></i></label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="serviceType" class="form-label">Service Type</label>
                            <select class="form-select" id="serviceType" name="serviceType" required>
                                <option value="">Select Service Type</option>
                                <option value="WEDDING">Wedding Photography</option>
                                <option value="CORPORATE">Corporate Event</option>
                                <option value="PORTRAIT">Portrait Session</option>
                                <option value="EVENT">Event Photography</option>
                                <option value="FAMILY">Family Photography</option>
                                <option value="PRODUCT">Product Photography</option>
                                <option value="OTHER">Other</option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="comment" class="form-label">Your Review</label>
                            <textarea class="form-control" id="comment" name="comment" rows="5"
                                      placeholder="Share your experience with this photographer..." required></textarea>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographer.photographerId}"
                               class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-primary">Submit Review</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
