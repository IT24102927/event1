<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - SnapHouse</title>

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
        <!-- Include Sidebar with "profile" as active page -->
        <c:set var="activePage" value="profile" scope="request"/>
        <jsp:include page="/includes/sidebar.jsp" />

        <!-- Main Content Area -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">My Profile</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="btn-group me-2">
                        <a href="${pageContext.request.contextPath}/update-profile" class="btn btn-sm btn-primary">
                            <i class="bi bi-pencil me-1"></i>Edit Profile
                        </a>
                    </div>
                </div>
            </div>

            <!-- Include Messages -->
            <jsp:include page="/includes/messages.jsp" />

            <div class="row">
                <div class="col-md-4 mb-4">
                    <div class="card">
                        <div class="card-body text-center">
                            <img src="${pageContext.request.contextPath}/assets/images/default-avatar.jpg"
                                 alt="Profile Picture"
                                 class="img-thumbnail rounded-circle mb-3"
                                 style="width: 150px; height: 150px; object-fit: cover;">
                            <h4>${sessionScope.user.fullName}</h4>
                            <p class="text-muted">@${sessionScope.user.username}</p>
                            <p class="text-muted">${sessionScope.user.userType}</p>
                        </div>
                    </div>
                </div>

                <div class="col-md-8 mb-4">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Profile Information</h5>
                        </div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-sm-3">
                                    <strong>Full Name:</strong>
                                </div>
                                <div class="col-sm-9">
                                    ${sessionScope.user.fullName}
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3">
                                    <strong>Username:</strong>
                                </div>
                                <div class="col-sm-9">
                                    ${sessionScope.user.username}
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3">
                                    <strong>Email:</strong>
                                </div>
                                <div class="col-sm-9">
                                    ${sessionScope.user.email}
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-sm-3">
                                    <strong>Account Type:</strong>
                                </div>
                                <div class="col-sm-9">
                                    ${sessionScope.user.userType}
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-3">
                                    <strong>Account Status:</strong>
                                </div>
                                <div class="col-sm-9">
                                    <span class="badge bg-success">Active</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Account Actions -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">Account Actions</h5>
                        </div>
                        <div class="card-body">
                            <div class="d-grid gap-2 d-md-flex">
                                <a href="${pageContext.request.contextPath}/update-profile" class="btn btn-primary">
                                    <i class="bi bi-pencil-square me-2"></i>Edit Profile
                                </a>
                                <c:if test="${sessionScope.user.userType == 'CLIENT'}">
                                    <a href="${pageContext.request.contextPath}/photographer/register" class="btn btn-secondary">
                                        <i class="bi bi-camera me-2"></i>Become a Photographer
                                    </a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/delete-account" class="btn btn-danger ms-md-auto">
                                    <i class="bi bi-trash me-2"></i>Delete Account
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Include Footer -->
<jsp:include page="/includes/footer.jsp" />

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>