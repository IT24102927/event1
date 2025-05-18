<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${photographer.businessName} - Reviews - SnapHouse</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <style>
        .review-item {
            border-bottom: 1px solid #eee;
            padding: 20px 0;
        }
        .review-item:last-child {
            border-bottom: none;
        }
        .rating-display {
            color: #ffcc00;
        }
        .rating-distribution .progress {
            height: 10px;
        }
        .photographer-response {
            background-color: #f8f9fa;
            border-left: 3px solid #6c757d;
            padding: 15px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
<jsp:include page="../includes/header.jsp" />

<div class="container mt-5">
    <jsp:include page="../includes/messages.jsp" />

    <div class="row">
        <!-- Photographer Info -->
        <div class="col-lg-4">
            <div class="card mb-4">
                <div class="card-body">
                    <h3 class="card-title">${photographer.businessName}</h3>
                    <p class="card-text"><i class="bi bi-geo-alt"></i> ${photographer.location}</p>

                    <div class="d-flex align-items-center mb-3">
                        <div class="rating-display me-2">
                            <c:forEach begin="1" end="5" var="i">
                                <i class="bi ${i <= averageRating ? 'bi-star-fill' : 'bi-star'}"></i>
                            </c:forEach>
                        </div>
                        <span class="fw-bold">${averageRating}</span>
                        <span class="text-muted ms-2">(${reviews.size()} reviews)</span>
                    </div>

                    <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographer.photographerId}"
                       class="btn btn-outline-primary mb-3">View Profile</a>

                    <c:if test="${sessionScope.userType == 'client'}">
                        <a href="${pageContext.request.contextPath}/review/add?photographerId=${photographer.photographerId}"
                           class="btn btn-primary mb-3">Write a Review</a>
                    </c:if>

                    <h5 class="mt-4">Rating Distribution</h5>
                    <div class="rating-distribution">
                        <c:forEach begin="5" end="1" step="-1" var="star">
                            <div class="d-flex align-items-center mb-1">
                                <div class="me-2" style="width: 35px;">
                                        ${star} <i class="bi bi-star-fill rating-display"></i>
                                </div>
                                <div class="progress flex-grow-1">
                                    <div class="progress-bar bg-warning" role="progressbar"
                                         style="width: ${ratingDistribution[star-1] * 100 / reviews.size()}%"
                                         aria-valuenow="${ratingDistribution[star-1]}"
                                         aria-valuemin="0" aria-valuemax="${reviews.size()}"></div>
                                </div>
                                <div class="ms-2" style="width: 30px;">${ratingDistribution[star-1]}</div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reviews List -->
        <div class="col-lg-8">
            <h2 class="mb-4">Reviews (${reviews.size()})</h2>

            <c:choose>
                <c:when test="${empty reviews}">
                    <div class="alert alert-info">
                        No reviews yet. Be the first to review this photographer!
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card">
                        <div class="card-body p-0">
                            <c:forEach var="review" items="${reviews}">
                                <div class="review-item p-4">
                                    <div class="d-flex justify-content-between mb-2">
                                        <div>
                                            <h5>${userManager.getUserById(review.clientId).fullName}</h5>
                                            <div class="rating-display">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <i class="bi ${i <= review.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                                                </c:forEach>
                                            </div>
                                        </div>
                                        <div class="text-muted">
                                            <small>
                                                <fmt:parseDate value="${review.reviewDate}"
                                                               pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                                <fmt:formatDate value="${parsedDate}"
                                                                pattern="MMM d, yyyy" />
                                            </small>
                                        </div>
                                    </div>

                                    <p class="mb-1"><span class="badge bg-secondary">${review.serviceType}</span></p>
                                    <p>${review.comment}</p>

                                    <c:if test="${review.hasResponse}">
                                        <div class="photographer-response">
                                            <h6 class="mb-2">Response from ${photographer.businessName}</h6>
                                            <p class="mb-1">${review.responseText}</p>
                                            <small class="text-muted">
                                                <fmt:parseDate value="${review.responseDate}"
                                                               pattern="yyyy-MM-dd'T'HH:mm" var="parsedRespDate" />
                                                <fmt:formatDate value="${parsedRespDate}"
                                                                pattern="MMM d, yyyy" />
                                            </small>
                                        </div>
                                    </c:if>

                                    <c:if test="${sessionScope.user.userId == review.clientId}">
                                        <div class="mt-3">
                                            <a href="${pageContext.request.contextPath}/review/edit?reviewId=${review.reviewId}"
                                               class="btn btn-sm btn-outline-secondary">
                                                <i class="bi bi-pencil-square"></i> Edit Review
                                            </a>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>