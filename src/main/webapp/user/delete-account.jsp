<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Account - SnapHouse</title>

    <!-- Favicon -->
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <!-- Custom CSS -->
    <style>
        body {
            background: linear-gradient(135deg, rgba(255, 0, 0, 0.1) 0%, rgba(255, 0, 0, 0.3) 100%);
            font-family: 'Montserrat', sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            margin: 0;
            color: #333;
        }

        .delete-account-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            padding: 40px;
            width: 100%;
            max-width: 500px;
        }

        .delete-icon {
            font-size: 4rem;
            color: #dc3545;
            text-align: center;
            width: 100%;
            margin-bottom: 20px;
        }

        .btn-delete {
            background-color: #dc3545;
            border-color: #dc3545;
            transition: all 0.3s ease;
        }

        .btn-delete:hover {
            background-color: #c82333;
            border-color: #bd2130;
        }

        .warning-text {
            color: #dc3545;
            font-weight: 500;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="delete-account-container">
        <div class="text-center">
            <i class="bi bi-exclamation-triangle delete-icon"></i>
            <h2 class="mb-3 warning-text">Delete Your Account</h2>
        </div>

        <!-- Include message display -->
        <jsp:include page="/includes/messages.jsp" />

        <div class="alert alert-danger" role="alert">
            <strong>Warning:</strong> Deleting your account is a permanent action and cannot be undone.
        </div>

        <form action="${pageContext.request.contextPath}/delete-account" method="post">
            <div class="mb-3">
                <p>To confirm account deletion, please:</p>
                <ul>
                    <li>Understand that all your data will be permanently removed</li>
                    <li>Confirm your identity by entering your current password</li>
                    <li>Acknowledge that this action cannot be reversed</li>
                </ul>
            </div>

            <div class="mb-3">
                <label for="currentPassword" class="form-label">
                    Current Password <span class="text-danger">*</span>
                </label>
                <div class="position-relative">
                    <input type="password" class="form-control" id="currentPassword"
                           name="currentPassword" required
                           placeholder="Enter your current password">
                    <button type="button" class="toggle-password" id="togglePassword">
                        <i class="bi bi-eye-slash text-muted"></i>
                    </button>
                </div>
            </div>

            <div class="form-check mb-3">
                <input class="form-check-input" type="checkbox" id="confirmDelete" name="confirmDelete" value="yes" required>
                <label class="form-check-label warning-text" for="confirmDelete">
                    I understand that deleting my account is permanent and cannot be undone
                </label>
            </div>

            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-delete btn-danger">
                    <i class="bi bi-trash me-2"></i>Permanently Delete My Account
                </button>
                <a href="${pageContext.request.contextPath}/user/profile.jsp"
                   class="btn btn-outline-secondary">
                    Cancel and Go Back
                </a>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

<script>
    // Password visibility toggle
    document.getElementById('togglePassword').addEventListener('click', function() {
        const passwordField = document.getElementById('currentPassword');
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

    // Prevent form submission if checkbox is not checked
    document.querySelector('form').addEventListener('submit', function(event) {
        const confirmCheckbox = document.getElementById('confirmDelete');

        if (!confirmCheckbox.checked) {
            event.preventDefault();
            alert('You must confirm that you understand the consequences of deleting your account.');
        }
    });
</script>
</body>
</html>
