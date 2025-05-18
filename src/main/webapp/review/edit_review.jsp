<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Review - SnapHouse</title>
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

            <h2 class="mb-4">Edit Review</h2>

            <div class="card mb-4">
                <div class="card-body">
                    <h4 class="card-title">Reviewing: ${photographer.businessName}</h4>
                    <p class="card-text text-muted">${photographer.location}</p>

                    <form action="${pageContext.request.contextPath}/review/edit" method="post">
                        <input type="hidden" name="reviewId" value="${review.reviewId}">

                        <div class="mb-3">
                            <label class="form-label">Your Rating</label>
                            <div class="rating">
                                <input type="radio" name="rating" value="5" id="star5"
                                ${review.rating == 5 ? 'checked' : ''} required>
                                <label for="star5"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="4" id="star4"
                                ${review.rating == 4 ? 'checked' : ''}>
                                <label for="star4"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="3" id="star3"
                                ${review.rating == 3 ? 'checked' : ''}>
                                <label for="star3"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="2" id="star2"
                                ${review.rating == 2 ? 'checked' : ''}>
                                <label for="star2"><i class="bi bi-star-fill"></i></label>
                                <input type="radio" name="rating" value="1" id="star1"
                                ${review.rating == 1 ? 'checked' : ''}>
                                <label for="star1"><i class="bi bi-star-fill"></i></label>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="serviceType" class="form-label">Service Type</label>
                            <select class="form-select" id="serviceType" name="serviceType" required>
                                <option value="">Select Service Type</option>
                                <option value="WEDDING" ${review.serviceType == 'WEDDING' ? 'selected' : ''}>
                                    Wedding Photography
                                </option>
                                <option value="CORPORATE" ${review.serviceType == 'CORPORATE' ? 'selected' : ''}>
                                    Corporate Event
                                </option>
                                <option value="PORTRAIT" ${review.serviceType == 'PORTRAIT' ? 'selected' : ''}>
                                    Portrait Session
                                </option>
                                <option value="EVENT" ${review.serviceType == 'EVENT' ? 'selected' : ''}>
                                    Event Photography
                                </option>
                                <option value="FAMILY" ${review.serviceType == 'FAMILY' ? 'selected' : ''}>
                                    Family Photography
                                </option>
                                <option value="PRODUCT" ${review.serviceType == 'PRODUCT' ? 'selected' : ''}>
                                    Product Photography
                                </option>
                                <option value="OTHER" ${review.serviceType == 'OTHER' ? 'selected' : ''}>
                                    Other
                                </option>
                            </select>
                        </div>

                        <div class="mb-3">
                            <label for="comment" class="form-label">Your Review</label>
                            <textarea class="form-control" id="comment" name="comment" rows="5" required>${review.comment}</textarea>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/review/myreviews"
                               class="btn btn-secondary">Cancel</a>
                            <div>
                                <button type="button" class="btn btn-danger me-2"
                                        data-bs-toggle="modal" data-bs-target="#deleteReviewModal">
                                    Delete Review
                                </button>
                                <button type="submit" class="btn btn-primary">Update Review</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Delete Review Modal -->
<div class="modal fade" id="deleteReviewModal" tabindex="-1" aria-labelledby="deleteReviewModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteReviewModalLabel">Confirm Deletion</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                Are you sure you want to delete this review? This action cannot be undone.
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <form action="${pageContext.request.contextPath}/review/delete" method="post">
                    <input type="hidden" name="reviewId" value="${review.reviewId}">
                    <button type="submit" class="btn btn-danger">Delete Review</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>