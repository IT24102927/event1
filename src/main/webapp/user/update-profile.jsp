<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Profile - SnapHouse Photography</title>

    <!-- Favicon -->
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">

    <!-- Custom CSS -->
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Roboto', sans-serif;
        }

        .profile-header {
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            padding: 40px 0;
            margin-bottom: 30px;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        .profile-avatar {
            width: 180px;
            height: 180px;
            border-radius: 50%;
            object-fit: cover;
            border: 6px solid white;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            transition: transform 0.3s ease;
        }

        .profile-avatar:hover {
            transform: scale(1.05);
        }

        .profile-container {
            background-color: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            padding: 40px;
        }

        .form-control {
            background-color: #f8f9fa;
            border: none;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            background-color: white;
            box-shadow: 0 0 0 0.2rem rgba(37, 117, 252, 0.25);
        }

        .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #6c757d;
            cursor: pointer;
            z-index: 10;
        }

        .badge-status {
            font-size: 0.9rem;
            padding: 0.4rem 0.6rem;
        }

        .section-header {
            border-bottom: 2px solid #2575fc;
            padding-bottom: 10px;
            margin-bottom: 20px;
            color: #2575fc;
        }
    </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <jsp:include page="/includes/sidebar.jsp" />

        <!-- Main Content -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
            <!-- Profile Header -->
            <div class="profile-header text-center">
                <div class="container">
                    <img src="${pageContext.request.contextPath}/assets/images/default-avatar.jpg"
                         alt="Profile Avatar" class="profile-avatar mb-4">
                    <h1 class="display-6">${sessionScope.user.fullName}</h1>
                    <p class="lead mb-2">@${sessionScope.user.username}</p>

                    <span class="badge badge-status
                            ${sessionScope.userType == 'client' ? 'bg-primary' :
                              (sessionScope.userType == 'photographer' ? 'bg-success' : 'bg-danger')}">
                        ${sessionScope.userType == 'client' ? 'Client' :
                                (sessionScope.userType == 'photographer' ? 'Photographer' : 'Administrator')}
                    </span>
                </div>
            </div>

            <!-- Include Messages -->
            <jsp:include page="/includes/messages.jsp" />

            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-10">
                        <div class="profile-container">
                            <h2 class="section-header mb-4">
                                <i class="bi bi-person-gear me-2"></i>Profile Settings
                            </h2>

                            <form action="${pageContext.request.contextPath}/update-profile" method="post">
                                <!-- Personal Information Section -->
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="fullName" class="form-label">Full Name</label>
                                        <input type="text" class="form-control" id="fullName"
                                               name="fullName" value="${sessionScope.user.fullName}"
                                               required maxlength="100">
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="email" class="form-label">Email Address</label>
                                        <input type="email" class="form-control" id="email"
                                               name="email" value="${sessionScope.user.email}"
                                               required maxlength="100">
                                    </div>
                                </div>

                                <!-- Password Change Section -->
                                <h4 class="mt-4 mb-3">
                                    <i class="bi bi-lock me-2"></i>Change Password
                                </h4>

                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label for="currentPassword" class="form-label">Current Password</label>
                                        <div class="position-relative">
                                            <input type="password" class="form-control" id="currentPassword"
                                                   name="currentPassword"
                                                   placeholder="Enter current password">
                                            <button type="button" class="toggle-password"
                                                    data-target="currentPassword">
                                                <i class="bi bi-eye-slash"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label for="newPassword" class="form-label">New Password</label>
                                        <div class="position-relative">
                                            <input type="password" class="form-control" id="newPassword"
                                                   name="newPassword"
                                                   placeholder="Enter new password"
                                                   minlength="8" maxlength="20">
                                            <button type="button" class="toggle-password"
                                                    data-target="newPassword">
                                                <i class="bi bi-eye-slash"></i>
                                            </button>
                                        </div>
                                        <small class="form-text text-muted">
                                            8-20 characters, with uppercase, lowercase, number, and special character
                                        </small>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label for="confirmPassword" class="form-label">Confirm New Password</label>
                                        <div class="position-relative">
                                            <input type="password" class="form-control" id="confirmPassword"
                                                   name="confirmPassword"
                                                   placeholder="Confirm new password">
                                            <button type="button" class="toggle-password"
                                                    data-target="confirmPassword">
                                                <i class="bi bi-eye-slash"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Account Type Specific Options -->
                                <c:if test="${sessionScope.userType == 'client'}">
                                    <div class="mt-4">
                                        <h4 class="mb-3">
                                            <i class="bi bi-arrow-up-circle me-2"></i>Account Upgrade
                                        </h4>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox"
                                                   id="upgradeAccount" name="upgradeAccount" value="yes">
                                            <label class="form-check-label" for="upgradeAccount">
                                                Upgrade to Photographer Account
                                            </label>
                                            <small class="form-text text-muted d-block">
                                                Gain access to additional features and services
                                            </small>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Action Buttons -->
                                <div class="d-flex justify-content-between mt-4">
                                    <a href="${pageContext.request.contextPath}/user/delete-account.jsp"
                                       class="btn btn-outline-danger">
                                        <i class="bi bi-trash me-2"></i>Delete Account
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-save me-2"></i>Save Changes
                                    </button>
                                </div>
                            </form>
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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

<script>
    // Password Visibility Toggle
    document.querySelectorAll('.toggle-password').forEach(button => {
        button.addEventListener('click', function() {
            const targetId = this.getAttribute('data-target');
            const passwordField = document.getElementById(targetId);
            const icon = this.querySelector('i');

            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            } else {
                passwordField.type = 'password';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            }
        });
    });

    // Password Match Validation
    const newPassword = document.getElementById('newPassword');
    const confirmPassword = document.getElementById('confirmPassword');

    function validatePasswordMatch() {
        if (newPassword.value && newPassword.value !== confirmPassword.value) {
            confirmPassword.setCustomValidity('Passwords do not match');
            confirmPassword.classList.add('is-invalid');
        } else {
            confirmPassword.setCustomValidity('');
            confirmPassword.classList.remove('is-invalid');
        }
    }

    newPassword.addEventListener('input', validatePasswordMatch);
    confirmPassword.addEventListener('input', validatePasswordMatch);
</script>
</body>
</html>