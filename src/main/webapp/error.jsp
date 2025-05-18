<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Error Page</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6 text-center">
            <h1 class="display-4 text-danger">404 - Page Not Found</h1>
            <p class="lead">The page you are looking for might have been removed or is temporarily unavailable.</p>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Go to Home</a>
        </div>
    </div>
</div>
</body>
</html>