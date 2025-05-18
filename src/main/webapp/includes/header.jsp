<nav class="navbar navbar-expand-lg sticky-top" style="background-color: #0D1321;">
    <div class="container">
        <a class="navbar-brand text-light" href="${pageContext.request.contextPath}/">
            <i class="bi bi-camera me-2 text-warning"></i><strong>SnapHouse</strong>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#navbarResponsive" aria-controls="navbarResponsive"
                aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarResponsive">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link text-light" href="${pageContext.request.contextPath}/">Home</a></li>
                <li class="nav-item"><a class="nav-link text-light" href="${pageContext.request.contextPath}/photographer/list">Photographers</a></li>
                <li class="nav-item"><a class="nav-link text-light" href="${pageContext.request.contextPath}/gallery/gallery_list.jsp">Galleries</a></li>
                <li class="nav-item">
                    <a class="nav-link text-light" href="#" data-bs-toggle="modal" data-bs-target="#aboutUsModal">About Us</a>
                </li>
            </ul>
            <!-- User Menu -->
            <div class="d-flex">
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/user/login.jsp" class="btn btn-outline-light me-2">Login</a>
                        <a href="${pageContext.request.contextPath}/user/register.jsp" class="btn btn-warning text-dark">Register</a>
                    </c:when>
                    <c:otherwise>
                        <!-- No button or dropdown for logged-in users -->
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>