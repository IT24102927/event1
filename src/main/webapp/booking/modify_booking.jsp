<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Modify Booking - SnapHouse</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/includes/header.jsp" />

<div class="container mt-4">
    <h2>Modify Booking</h2>
    <form action="${pageContext.request.contextPath}/booking/modify" method="post">
        <input type="hidden" name="bookingId" value="${booking.bookingId}" />

        <div class="mb-3">
            <label for="eventDateTime" class="form-label">Event Date & Time</label>
            <input type="datetime-local" class="form-control" id="eventDateTime" name="eventDateTime"
                   value="${booking.eventDateTime}" required>
        </div>

        <div class="mb-3">
            <label for="eventLocation" class="form-label">Event Location</label>
            <input type="text" class="form-control" id="eventLocation" name="eventLocation"
                   value="${booking.eventLocation}" required>
        </div>

        <div class="mb-3">
            <label for="eventNotes" class="form-label">Event Notes</label>
            <textarea class="form-control" id="eventNotes" name="eventNotes" rows="3">${booking.eventNotes}</textarea>
        </div>

        <div class="mb-3">
            <label for="eventType" class="form-label">Event Type</label>
            <select class="form-select" id="eventType" name="eventType" required>
                <c:forEach var="type" items="${eventTypes}">
                    <option value="${type}" <c:if test="${type == booking.eventType}">selected</c:if>>${type}</option>
                </c:forEach>
            </select>
        </div>

        <div class="mb-3">
            <label for="status" class="form-label">Status</label>
            <select class="form-select" id="status" name="status" required>
                <c:forEach var="status" items="${statuses}">
                    <option value="${status}" <c:if test="${status == booking.status}">selected</c:if>>${status}</option>
                </c:forEach>
            </select>
        </div>

        <button type="submit" class="btn btn-primary">Save Changes</button>
        <a href="${pageContext.request.contextPath}/booking/list" class="btn btn-secondary">Cancel</a>
    </form>
</div>

<jsp:include page="/includes/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>