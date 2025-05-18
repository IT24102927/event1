<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="com.photobooking.model.user.User" %>
<%@ page import="com.photobooking.model.booking.Booking" %>
<%@ page import="com.photobooking.model.photographer.UnavailableDate" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // Ensure user is logged in and is a photographer
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || currentUser.getUserType() != User.UserType.PHOTOGRAPHER) {
        response.sendRedirect(request.getContextPath() + "/user/login.jsp");
        return;
    }

    // Retrieve data set by the servlet
    List<Booking> upcomingBookings = (List<Booking>) request.getAttribute("upcomingBookings");
    List<UnavailableDate> unavailableDates = (List<UnavailableDate>) request.getAttribute("unavailableDates");
    String calendarEventsJson = (String) request.getAttribute("calendarEventsJson");

    // If not coming from the servlet, redirect to it
    if (upcomingBookings == null || unavailableDates == null || calendarEventsJson == null) {
        response.sendRedirect(request.getContextPath() + "/photographer/availability");
        return;
    }

    // Fallback for null values
    if (upcomingBookings == null) upcomingBookings = new ArrayList<>();
    if (unavailableDates == null) unavailableDates = new ArrayList<>();
    if (calendarEventsJson == null) calendarEventsJson = "[]";

    // Debug logging
    System.out.println("Upcoming Bookings: " + upcomingBookings.size());
    System.out.println("Unavailable Dates: " + unavailableDates.size());
    System.out.println("Calendar Events JSON: " + calendarEventsJson);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Availability Calendar - SnapHouse</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f4f6f9;
            padding-bottom: 50px;
        }
        .calendar-container {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 20px;
        }
        .time-slot {
            cursor: pointer;
            padding: 8px;
            margin: 5px 0;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            transition: background-color 0.3s;
        }
        .time-slot:hover { background-color: #f8f9fa; }
        .time-slot.selected {
            background-color: #dc3545;
            color: white;
        }
        .calendar-legend {
            margin-top: 20px;
            padding: 10px;
            border-radius: 8px;
            background-color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
        }
        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
            margin-right: 10px;
        }
        .fc-event {
            cursor: pointer;
        }
        .fc-daygrid-event {
            white-space: normal !important;
        }
        .calendar-header {
            background: linear-gradient(135deg, #4361ee 0%, #3a0ca3 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            border-radius: 0 0 10px 10px;
        }
    </style>
</head>
<body>
<!-- Include Header -->
<jsp:include page="/includes/header.jsp" />

<!-- Calendar Header -->
<div class="calendar-header">
    <div class="container">
        <h1 class="display-5">Availability Calendar</h1>
        <p class="lead">Manage your availability and view your bookings</p>
    </div>
</div>

<div class="container">
    <!-- Include Messages -->
    <jsp:include page="/includes/messages.jsp" />

    <div class="row">
        <div class="col-lg-8 offset-lg-2">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3 class="mb-0">Availability Calendar</h3>
                    <div>
                        <button class="btn btn-primary me-2" data-bs-toggle="modal" data-bs-target="#blockDatesModal">
                            <i class="bi bi-calendar-x me-1"></i>Block Dates
                        </button>
                        <button class="btn btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#unavailableDatesModal">
                            <i class="bi bi-calendar-minus me-1"></i>View Blocked
                        </button>
                    </div>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-9">
                            <div class="calendar-container">
                                <div id="calendar"></div>

                                <!-- Calendar Legend -->
                                <div class="calendar-legend">
                                    <h6 class="mb-3">Calendar Legend</h6>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #28a745;"></div>
                                                <span>Confirmed Booking</span>
                                            </div>
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #ffc107;"></div>
                                                <span>Pending Booking</span>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #dc3545;"></div>
                                                <span>Unavailable/Blocked</span>
                                            </div>
                                            <div class="legend-item">
                                                <div class="legend-color" style="background-color: #007bff;"></div>
                                                <span>Completed Booking</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-3">
                            <div id="timeSlots" style="display:none;">
                                <h5 id="selectedDateTitle" class="mb-3">Select a Date</h5>
                                <div class="time-slots-container">
                                    <div class="time-slot" data-time="09:00">9:00 AM</div>
                                    <div class="time-slot" data-time="10:00">10:00 AM</div>
                                    <div class="time-slot" data-time="11:00">11:00 AM</div>
                                    <div class="time-slot" data-time="12:00">12:00 PM</div>
                                    <div class="time-slot" data-time="13:00">1:00 PM</div>
                                    <div class="time-slot" data-time="14:00">2:00 PM</div>
                                    <div class="time-slot" data-time="15:00">3:00 PM</div>
                                    <div class="time-slot" data-time="16:00">4:00 PM</div>
                                    <div class="time-slot" data-time="17:00">5:00 PM</div>
                                    <div class="time-slot" data-time="18:00">6:00 PM</div>
                                    <div class="time-slot" data-time="19:00">7:00 PM</div>
                                    <div class="time-slot" data-time="20:00">8:00 PM</div>
                                </div>
                                <button id="saveAvailability" class="btn btn-success w-100 mt-3">
                                    Save Availability
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Upcoming Bookings Card -->
            <div class="card mt-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h3 class="mb-0">Upcoming Bookings</h3>
                    <a href="${pageContext.request.contextPath}/booking/booking_list.jsp" class="btn btn-sm btn-outline-primary">View All</a>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty upcomingBookings}">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                    <tr>
                                        <th>Event Type</th>
                                        <th>Date & Time</th>
                                        <th>Location</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="booking" items="${upcomingBookings}">
                                        <tr>
                                            <td>${booking.eventType}</td>
                                            <td>${booking.eventDateTime}</td>
                                            <td>${booking.eventLocation}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${booking.status == 'CONFIRMED'}">
                                                        <span class="badge bg-success">CONFIRMED</span>
                                                    </c:when>
                                                    <c:when test="${booking.status == 'PENDING'}">
                                                        <span class="badge bg-warning">PENDING</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">${booking.status}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/booking/booking_details.jsp?id=${booking.bookingId}" class="btn btn-sm btn-outline-primary">Details</a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="alert alert-info mb-0">
                                You have no upcoming bookings.
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Unavailable Dates Modal -->
<div class="modal fade" id="unavailableDatesModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Blocked Dates</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="unavailableDatesList">
                <c:choose>
                    <c:when test="${not empty unavailableDates}">
                        <c:forEach var="unavailableDate" items="${unavailableDates}">
                            <div class="card mb-2">
                                <div class="card-body d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="card-title mb-1">${unavailableDate.date}</h6>
                                        <p class="text-muted mb-0">
                                            <c:choose>
                                                <c:when test="${unavailableDate.allDay}">
                                                    Blocked entire day
                                                </c:when>
                                                <c:otherwise>
                                                    Blocked from ${unavailableDate.startTime} to ${unavailableDate.endTime}
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${not empty unavailableDate.reason}">
                                                • ${unavailableDate.reason}
                                            </c:if>
                                        </p>
                                    </div>
                                    <button class="btn btn-sm btn-outline-danger remove-blocked-date"
                                            data-date-id="${unavailableDate.id}">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center text-muted">
                            <i class="bi bi-calendar-check fs-1 mb-3"></i>
                            <p>No blocked dates</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Block Dates Modal -->
<div class="modal fade" id="blockDatesModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Block Dates</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="blockDatesForm">
                    <div class="mb-3">
                        <label class="form-label">Start Date</label>
                        <input type="date" class="form-control" id="blockStartDate" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">End Date (Optional)</label>
                        <input type="date" class="form-control" id="blockEndDate">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Reason (Optional)</label>
                        <input type="text" class="form-control" id="blockReason" placeholder="Holiday, Personal, etc.">
                    </div>
                    <div class="form-check mb-3">
                        <input type="checkbox" class="form-check-input" id="blockAllDay" checked>
                        <label class="form-check-label">Block Entire Day</label>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="confirmBlockDates">Block Dates</button>
            </div>
        </div>
    </div>
</div>

<!-- Event Details Modal -->
<div class="modal fade" id="eventDetailsModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="eventDetailsTitle">Event Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="eventDetailsBody">
                <!-- Event details will be inserted here dynamically -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <a href="#" class="btn btn-primary" id="eventDetailsLink">View Details</a>
            </div>
        </div>
    </div>
</div>

<!-- FullCalendar JS -->
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js"></script>

<!-- Bootstrap Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Debug: Log calendar events from server
        console.log('Calendar Events (JSON):', <%= calendarEventsJson %>);

        // Calendar Initialization
        const calendarEl = document.getElementById('calendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            height: 'auto',
            selectable: true,
            events: <%= calendarEventsJson %>,
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,listWeek'
            },
            eventClick: function(info) {
                // Handle event clicks to show details
                const event = info.event;
                console.log('Event clicked:', event);

                // Get event ID to determine if it's a booking or unavailable date
                const eventId = event.id;

                if (eventId && eventId.startsWith('booking-')) {
                    // It's a booking event
                    const bookingId = eventId.replace('booking-', '');
                    showEventDetails(event, bookingId);
                } else {
                    // It's an unavailable date, just show basic info
                    showUnavailableDateDetails(event);
                }
            },
            dateClick: function(info) {
                selectDate(info.dateStr);
            },
            eventTimeFormat: {
                hour: 'numeric',
                minute: '2-digit',
                meridiem: 'short'
            }
        });
        calendar.render();

        // Date Selection
        function selectDate(dateStr) {
            const timeSlots = document.getElementById('timeSlots');
            const selectedDateTitle = document.getElementById('selectedDateTitle');

            selectedDateTitle.textContent = new Date(dateStr).toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });

            timeSlots.style.display = 'block';

            // Reset time slots
            document.querySelectorAll('.time-slot').forEach(slot => {
                slot.classList.remove('selected');
                slot.style.pointerEvents = '';
            });

            // Check if this date has any bookings or blocked periods
            const events = calendar.getEvents();
            for (let event of events) {
                // Check if the event is on the selected date
                const eventStart = new Date(event.start);
                const selectedDate = new Date(dateStr);

                if (eventStart.toDateString() === selectedDate.toDateString()) {
                    // If it's an all-day event or unavailable date, disable all time slots
                    if (event.allDay && event.id && event.id.startsWith('unavailable-')) {
                        document.querySelectorAll('.time-slot').forEach(slot => {
                            slot.classList.add('selected');
                            slot.style.pointerEvents = 'none';
                        });
                        // Add message
                        selectedDateTitle.textContent += " (Fully Blocked)";
                        break;
                    }
                    // If it's a booking that takes specific time slots
                    else if (!event.allDay) {
                        // Get the event time and mark those slots as unavailable
                        const eventHour = eventStart.getHours();
                        const eventSlot = document.querySelector(`.time-slot[data-time="${eventHour.toString().padStart(2, '0')}:00"]`);
                        if (eventSlot) {
                            eventSlot.classList.add('selected');
                            eventSlot.style.pointerEvents = 'none';
                        }
                    }
                }
            }
        }

        // Show event details in modal
        function showEventDetails(event, bookingId) {
            const title = document.getElementById('eventDetailsTitle');
            const body = document.getElementById('eventDetailsBody');
            const link = document.getElementById('eventDetailsLink');

            // Set modal title
            title.textContent = event.title;

            // Format event details
            const startDate = new Date(event.start);
            const formattedDate = startDate.toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
            const formattedTime = startDate.toLocaleTimeString('en-US', {
                hour: 'numeric',
                minute: '2-digit',
                hour12: true
            });

            // Create event details content
            let detailsHtml = `
                    <p><strong>Date:</strong> ${formattedDate}</p>
                    <p><strong>Time:</strong> ${formattedTime}</p>
                `;

            // Add more details if available in the event's extendedProps
            if (event.extendedProps) {
                if (event.extendedProps.description) {
                    detailsHtml += `<p><strong>Details:</strong> ${event.extendedProps.description}</p>`;
                }
                if (event.extendedProps.status) {
                    let statusClass = '';
                    switch(event.extendedProps.status) {
                        case 'CONFIRMED': statusClass = 'success'; break;
                        case 'PENDING': statusClass = 'warning'; break;
                        case 'CANCELLED': statusClass = 'danger'; break;
                        case 'COMPLETED': statusClass = 'primary'; break;
                        default: statusClass = 'secondary';
                    }

                    detailsHtml += `
                            <p>
                                <strong>Status:</strong>
                                <span class="badge bg-${statusClass}">
                                    ${event.extendedProps.status}
                                </span>
                            </p>
                        `;
                }
            }

            body.innerHTML = detailsHtml;

            // Set link to booking details page
            link.href = `${pageContext.request.contextPath}/booking/booking_details.jsp?id=${bookingId}`;
            link.style.display = '';

            // Show the modal
            const modal = new bootstrap.Modal(document.getElementById('eventDetailsModal'));
            modal.show();
        }

        // Show unavailable date details
        function showUnavailableDateDetails(event) {
            const title = document.getElementById('eventDetailsTitle');
            const body = document.getElementById('eventDetailsBody');
            const link = document.getElementById('eventDetailsLink');

            // Set modal title
            title.textContent = event.title || "Unavailable";

            // Format date
            const startDate = new Date(event.start);
            const formattedDate = startDate.toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });

            // Create content
            let detailsHtml = `
                    <p><strong>Date:</strong> ${formattedDate}</p>
                    <p><strong>Type:</strong> <span class="badge bg-danger">Unavailable</span></p>
                `;

            if (event.allDay) {
                detailsHtml += `<p><strong>Duration:</strong> All Day</p>`;
            } else {
                const endDate = new Date(event.end);
                const startTime = startDate.toLocaleTimeString('en-US', {
                    hour: 'numeric',
                    minute: '2-digit',
                    hour12: true
                });
                const endTime = endDate.toLocaleTimeString('en-US', {
                    hour: 'numeric',
                    minute: '2-digit',
                    hour12: true
                });
                detailsHtml += `<p><strong>Time:</strong> ${startTime} - ${endTime}</p>`;
            }

            body.innerHTML = detailsHtml;

            // Hide details link for unavailable dates
            link.style.display = 'none';

            // Show the modal
            const modal = new bootstrap.Modal(document.getElementById('eventDetailsModal'));
            modal.show();
        }

        // Time Slot Selection
        document.querySelectorAll('.time-slot').forEach(slot => {
            slot.addEventListener('click', function() {
                if (this.style.pointerEvents !== 'none') {
                    this.classList.toggle('selected');
                }
            });
        });

        // Save Availability
        document.getElementById('saveAvailability').addEventListener('click', function() {
            const selectedDateText = document.getElementById('selectedDateTitle').textContent;
            const dateMatch = selectedDateText.match(/([A-Za-z]+, [A-Za-z]+ \d+, \d+)/);
            const selectedDate = dateMatch ? new Date(dateMatch[0]) : new Date();
            const dateStr = selectedDate.toISOString().split('T')[0];

            const selectedTimeSlots = Array.from(
                document.querySelectorAll('.time-slot.selected')
            ).map(slot => slot.getAttribute('data-time'));

            // Call backend to save availability
            fetch('${pageContext.request.contextPath}/photographer/save-availability', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    date: dateStr,
                    unavailableTimeSlots: selectedTimeSlots
                })
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Refresh calendar
                        window.location.reload();
                        alert('Availability saved successfully!');
                    } else {
                        alert('Error: ' + (data.message || 'Failed to save availability'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while saving availability.');
                });
        });

        // Block Dates
        document.getElementById('confirmBlockDates').addEventListener('click', function() {
            const startDate = document.getElementById('blockStartDate').value;
            const endDate = document.getElementById('blockEndDate').value;
            const blockAllDay = document.getElementById('blockAllDay').checked;
            const blockReason = document.getElementById('blockReason').value || 'Unavailable';

            if (!startDate) {
                alert('Please select a start date');
                return;
            }

            // Debug
            console.log('Block Dates Form Data:');
            console.log('Start Date:', startDate);
            console.log('End Date:', endDate);
            console.log('All Day:', blockAllDay);
            console.log('Reason:', blockReason);

            // Prepare form data
            const formData = new FormData();
            formData.append('startDate', startDate);
            if (endDate) formData.append('endDate', endDate);
            if (blockAllDay) formData.append('allDay', 'on');
            formData.append('reason', blockReason);

            // Call backend to block dates
            fetch('${pageContext.request.contextPath}/photographer/block-dates', {
                method: 'POST',
                body: formData
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        // Refresh page to update calendar
                        window.location.reload();
                        alert('Dates blocked successfully!');
                    } else {
                        alert('Error: ' + (data.message || 'Failed to block dates'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while blocking dates.');
                });
        });

        // Remove Blocked Date
        document.querySelectorAll('.remove-blocked-date').forEach(button => {
            button.addEventListener('click', function() {
                const dateId = this.getAttribute('data-date-id');
                if (!dateId) return;

                if (confirm('Are you sure you want to remove this blocked date?')) {
                    // Call backend to remove blocked date
                    fetch('${pageContext.request.contextPath}/photographer/remove-blocked-date', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'dateId=' + dateId
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                // Refresh page to update calendar
                                window.location.reload();
                                alert('Blocked date removed successfully!');
                            } else {
                                alert('Error: ' + (data.message || 'Failed to remove blocked date'));
                            }
                        })
                })
            .catch(error => {
                    console.error('Error:', error);
                    alert('An error occurred while removing blocked date.');
                });
            }
        });
    });

    // Set today's date as minimum date for date pickers
    const today = new Date();
    const formattedToday = today.toISOString().split('T')[0];
    document.getElementById('blockStartDate').min = formattedToday;
    document.getElementById('blockEndDate').min = formattedToday;

    // Set today as default date
    document.getElementById('blockStartDate').value = formattedToday;

    // Synchronize end date with start date if empty
    document.getElementById('blockStartDate').addEventListener('change', function() {
        const endDateInput = document.getElementById('blockEndDate');
        if (!endDateInput.value) {
            endDateInput.value = this.value;
        }
        // Ensure end date is not before start date
        if (endDateInput.value < this.value) {
            endDateInput.value = this.value;
        }
        endDateInput.min = this.value;
    });
    });
</script>
</body>
</html>