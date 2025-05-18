<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reviews - SnapHouse</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <style>
        .rating-display {
            color: #ffcc00;
        }
    </style>
</head>
<body>
<jsp:include page="../includes/header.jsp" />

<div class="container mt-5">
    <jsp:include page="../includes/messages.jsp" />

    <h2 class="mb-4">
        <c:choose>
            <c:when test="${sessionScope.userType == 'client'}">My Reviews</c:when>
            <c:when test="${sessionScope.userType == 'photographer'}">Reviews for My Services</c:when>
            <c:otherwise>All Reviews</c:otherwise>
        </c:choose>
    </h2>

    <!-- Debug info to check attributes -->
    <!-- <p>Debug: User Type: ${sessionScope.userType}, Reviews Count: ${empty reviews ? '0' : reviews.size()}</p> -->

    <c:choose>
        <c:when test="${empty reviews}">
            <div class="alert alert-info">
                <c:choose>
                    <c:when test="${sessionScope.userType == 'client'}">
                        You haven't written any reviews yet.
                        <a href="${pageContext.request.contextPath}/photographer/list">Find photographers</a> to review!
                    </c:when>
                    <c:when test="${sessionScope.userType == 'photographer'}">
                        You don't have any reviews yet. Keep providing great service, and the reviews will come!
                    </c:when>
                    <c:otherwise>There are no reviews in the system.</c:otherwise>
                </c:choose>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row">
                <c:forEach var="review" items="${reviews}">
                    <div class="col-md-6 mb-4">
                        <div class="card h-100">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div>
                                    <c:choose>
                                        <c:when test="${sessionScope.userType == 'client'}">
                                            <!-- For clients: show photographer info -->
                                            <c:set var="photographer"
                                                   value="${photographerManager.getPhotographerById(review.photographerId)}" />
                                            <h5 class="mb-0">
                                                <a href="${pageContext.request.contextPath}/photographer/profile?id=${photographer.photographerId}">
                                                        ${photographer.businessName}
                                                </a>
                                            </h5>
                                        </c:when>
                                        <c:otherwise>
                                            <!-- For photographers/admins: show client info -->
                                            <c:set var="client"
                                                   value="${userManager.getUserById(review.clientId)}" />
                                            <h5 class="mb-0">${client.fullName}</h5>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="rating-display">
                                    <c:forEach begin="1" end="5" var="i">
                                        <i class="bi ${i <= review.rating ? 'bi-star-fill' : 'bi-star'}"></i>
                                    </c:forEach>
                                </div>
                            </div>
                            <div class="card-body">
                                <p class="card-text mb-1">
                                    <span class="badge bg-secondary">${review.serviceType}</span>
                                    <small class="text-muted ms-2">
                                        <fmt:parseDate value="${review.reviewDate}"
                                                       pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" />
                                        <fmt:formatDate value="${parsedDate}"
                                                        pattern="MMM d, yyyy" />
                                    </small>
                                </p>
                                <p class="card-text">${review.comment}</p>

                                <c:if test="${review.hasResponse && (sessionScope.userType == 'client' || sessionScope.userType == 'admin')}">
                                    <div class="alert alert-light mt-2">
                                        <h6 class="mb-1">Photographer's Response:</h6>
                                        <p class="mb-1">${review.responseText}</p>
                                        <small class="text-muted">
                                            <fmt:parseDate value="${review.responseDate}"
                                                           pattern="yyyy-MM-dd'T'HH:mm" var="parsedRespDate" />
                                            <fmt:formatDate value="${parsedRespDate}"
                                                            pattern="MMM d, yyyy" />
                                        </small>
                                    </div>
                                </c:if>
                            </div>
                            <div class="card-footer">
                                <c:choose>
                                    <c:when test="${sessionScope.userType == 'client' && sessionScope.user.userId == review.clientId}">
                                        <!-- Actions for client who wrote the review -->
                                        <a href="${pageContext.request.contextPath}/review/edit?reviewId=${review.reviewId}"
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-pencil-square"></i> Edit Review
                                        </a>
                                        <button type="button" class="btn btn-sm btn-outline-danger ms-2"
                                                data-bs-toggle="modal" data-bs-target="#deleteModal${review.reviewId}">
                                            <i class="bi bi-trash"></i> Delete
                                        </button>
                                    </c:when>
                                    <c:when test="${sessionScope.userType == 'photographer' && !review.hasResponse}">
                                        <!-- Actions for photographer to respond -->
                                        <button type="button" class="btn btn-sm btn-outline-primary"
                                                data-bs-toggle="modal" data-bs-target="#responseModal${review.reviewId}">
                                            <i class="bi bi-reply"></i> Respond to Review
                                        </button>
                                    </c:when>
                                    <c:when test="${sessionScope.userType == 'admin'}">
                                        <!-- Actions for admin -->
                                        <button type="button" class="btn btn-sm btn-outline-danger"
                                                data-bs-toggle="modal" data-bs-target="#deleteModal${review.reviewId}">
                                            <i class="bi bi-trash"></i> Delete Review
                                        </button>
                                    </c:when>
                                </c:choose>
                            </div>
                        </div>

                        <!-- Delete Modal -->
                        <div class="modal fade" id="deleteModal${review.reviewId}" tabindex="-1"
                             aria-labelledby="deleteModalLabel${review.reviewId}" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="deleteModalLabel${review.reviewId}">Confirm Deletion</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Are you sure you want to delete this review? This action cannot be undone.
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                        <form action="${pageContext.request.contextPath}/review/delete" method="post">
                                            <input type="hidden" name="reviewId" value="${review.reviewId}">
                                            <button type="submit" class="btn btn-danger">Delete</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Response Modal for photographers -->
                        <c:if test="${sessionScope.userType == 'photographer'}">
                            <div class="modal fade" id="responseModal${review.reviewId}" tabindex="-1"
                                 aria-labelledby="responseModalLabel${review.reviewId}" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="responseModalLabel${review.reviewId}">Respond to Review</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/review/respond" method="post">
                                            <div class="modal-body">
                                                <input type="hidden" name="reviewId" value="${review.reviewId}">
                                                <div class="mb-3">
                                                    <label for="responseText${review.reviewId}" class="form-label">Your Response</label>
                                                    <textarea class="form-control" id="responseText${review.reviewId}"
                                                              name="responseText" rows="5" required></textarea>
                                                </div>
                                                <p class="text-muted small">
                                                    Your response will be visible to everyone who views this review.
                                                </p>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn btn-primary">Submit Response</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
