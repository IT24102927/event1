<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Dashboard Sidebar -->
<div class="col-md-3 col-lg-2 d-md-block bg-light sidebar collapse" id="sidebarMenu">
    <div class="position-sticky pt-3">
        <div class="user-info text-center mb-4 d-none d-md-block">
            <img src="${pageContext.request.contextPath}/assets/images/default-avatar.jpg"
                 alt="User Avatar" class="img-thumbnail rounded-circle mb-2" style="width: 80px; height: 80px; object-fit: cover;">
            <h6 class="mb-0">${sessionScope.user.fullName}</h6>
            <p class="text-muted small">@${sessionScope.user.username}</p>
        </div>

        <hr class="d-none d-md-block">

        <ul class="nav flex-column">
            <!-- Client Menu Items -->
            <c:if test="${sessionScope.userType == 'client'}">
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'dashboard' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/user/dashboard.jsp">
                        <i class="bi bi-speedometer2 me-2"></i>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'bookings' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/booking/booking_list.jsp">
                        <i class="bi bi-calendar-check me-2"></i>
                        My Bookings
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'photographers' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/photographer/photographer_list.jsp">
                        <i class="bi bi-camera me-2"></i>
                        Find Photographers
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'galleries' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/gallery/gallery_list.jsp?userOnly=true">
                        <i class="bi bi-images me-2"></i>
                        My Galleries
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'favorites' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/user/favorites.jsp">
                        <i class="bi bi-heart me-2"></i>
                        Saved Photographers
                    </a>
                </li>
            </c:if>

            <!-- Photographer Menu Items -->
            <c:if test="${sessionScope.userType == 'photographer'}">
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'dashboard' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/photographer/dashboard.jsp">
                        <i class="bi bi-speedometer2 me-2"></i>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'bookings' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/booking/booking_list.jsp">
                        <i class="bi bi-calendar-check me-2"></i>
                        My Assignments
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'availability' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/photographer/availability_calendar.jsp">
                        <i class="bi bi-calendar-week me-2"></i>
                        Manage Availability
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'services' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/photographer/service_management.jsp">
                        <i class="bi bi-camera me-2"></i>
                        My Services
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'galleries' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/gallery/gallery_list.jsp?userOnly=true">
                        <i class="bi bi-images me-2"></i>
                        My Galleries
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'reviews' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/review/view_reviews.jsp?photographerId=${sessionScope.user.userId}">
                        <i class="bi bi-star me-2"></i>
                        My Reviews
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'earnings' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/photographer/earnings.jsp">
                        <i class="bi bi-cash-coin me-2"></i>
                        Earnings
                    </a>
                </li>
            </c:if>

            <!-- Admin Menu Items -->
            <c:if test="${sessionScope.userType == 'admin'}">
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'dashboard' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                        <i class="bi bi-speedometer2 me-2"></i>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'users' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/user_management.jsp">
                        <i class="bi bi-people me-2"></i>
                        User Management
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'bookings' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/booking_management.jsp">
                        <i class="bi bi-calendar-check me-2"></i>
                        Booking Management
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'photographers' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/photographer_management.jsp">
                        <i class="bi bi-camera me-2"></i>
                        Photographer Management
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'reviews' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/review_moderation.jsp">
                        <i class="bi bi-star me-2"></i>
                        Review Moderation
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'reports' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/reports.jsp">
                        <i class="bi bi-graph-up me-2"></i>
                        Reports & Analytics
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${param.activePage == 'settings' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/admin/settings.jsp">
                        <i class="bi bi-gear me-2"></i>
                        System Settings
                    </a>
                </li>
            </c:if>

            <!-- Common Menu Items -->
            <li class="nav-item">
                <a class="nav-link ${param.activePage == 'profile' ? 'active' : ''}"
                   href="${pageContext.request.contextPath}/user/profile.jsp">
                    <i class="bi bi-person me-2"></i>
                    My Profile
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="${pageContext.request.contextPath}/logout">
                    <i class="bi bi-box-arrow-right me-2"></i>
                    Logout
                </a>
            </li>
        </ul>

        <!-- Quick Action Buttons -->
        <div class="mt-4 px-3 d-none d-md-block">
            <c:if test="${sessionScope.userType == 'client'}">
                <a href="${pageContext.request.contextPath}/booking/booking_form.jsp"
                   class="btn btn-primary w-100 mb-2">
                    <i class="bi bi-plus-circle me-2"></i>Book a Photographer
                </a>
            </c:if>
            <c:if test="${sessionScope.userType == 'photographer'}">
                <a href="${pageContext.request.contextPath}/gallery/upload_photos.jsp"
                   class="btn btn-primary w-100 mb-2">
                    <i class="bi bi-cloud-upload me-2"></i>Upload Photos
                </a>
            </c:if>
            <a href="${pageContext.request.contextPath}/help/contact.jsp"
               class="btn btn-outline-secondary w-100">
                <i class="bi bi-question-circle me-2"></i>Get Help
            </a>
        </div>
    </div>
</div>

<!-- Sidebar Toggle for Mobile -->
<style>
    @media (max-width: 767.98px) {
        .sidebar {
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 100;
            padding: 48px 0 0;
            box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
            width: 100%;
            max-width: 280px;
            overflow-y: auto;
            transform: translateX(-100%);
            transition: transform .3s ease-in-out;
        }

        .sidebar.show {
            transform: translateX(0);
        }

        .nav-link.active {
            background-color: #4361ee;
            color: white !important;
            border-radius: 0.25rem;
        }
    }

    @media (min-width: 768px) {
        .nav-link.active {
            background-color: #4361ee;
            color: white !important;
            border-radius: 0.25rem;
        }
    }
</style>

<script>
    // Mobile sidebar toggle functionality
    document.addEventListener('DOMContentLoaded', function() {
        const sidebarToggleBtn = document.getElementById('sidebarToggleBtn');
        const sidebar = document.getElementById('sidebarMenu');

        if (sidebarToggleBtn && sidebar) {
            sidebarToggleBtn.addEventListener('click', function() {
                sidebar.classList.toggle('show');
            });

            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', function(event) {
                if (sidebar.classList.contains('show') &&
                    !sidebar.contains(event.target) &&
                    event.target !== sidebarToggleBtn) {
                    sidebar.classList.remove('show');
                }
            });
        }
    });
</script>