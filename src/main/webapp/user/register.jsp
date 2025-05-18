<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <style>
        body {
            background-color: #f3f4f6;
        }
        .register-card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .register-header {
            background-color: #6f42c1;
            color: white;
            border-top-left-radius: 1rem;
            border-top-right-radius: 1rem;
            padding: 1.5rem;
            text-align: center;
        }
        .btn-primary {
            background-color: #6f42c1;
            border-color: #6f42c1;
        }
        .btn-primary:hover {
            background-color: #5a32a3;
            border-color: #5a32a3;
        }
        .form-control:focus, .form-select:focus {
            border-color: #6f42c1;
            box-shadow: 0 0 0 0.2rem rgba(111, 66, 193, 0.25);
        }
        a {
            color: #6f42c1;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<div class="container d-flex align-items-center justify-content-center min-vh-100">
    <div class="row w-100 justify-content-center">
        <div class="col-md-7 col-lg-6">
            <div class="card register-card">
                <div class="register-header">
                    <h3>Create Your Account</h3>
                    <p class="mb-0">Join SnapHouse and get started</p>
                </div>
                <div class="card-body p-4">
                    <jsp:include page="/includes/messages.jsp" />

                    <form action="${pageContext.request.contextPath}/register" method="post">
                        <div class="mb-3">
                            <label for="fullName" class="form-label">Full Name</label>
                            <input type="text" class="form-control" id="fullName" name="fullName" required>
                        </div>

                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="username" name="username" required>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email" required>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>

                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">Confirm Password</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        </div>

                        <div class="mb-4">
                            <label for="userType" class="form-label">Account Type</label>
                            <select class="form-select" id="userType" name="userType" required>
                                <option value="" selected disabled>Select account type</option>
                                <option value="CLIENT">Client</option>
                                <option value="PHOTOGRAPHER">Photographer</option>
                            </select>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">Register</button>
                        </div>
                    </form>

                    <p class="mt-4 text-center">
                        Already have an account?
                        <a href="${pageContext.request.contextPath}/user/login.jsp">Login here</a>
                    </p>
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
