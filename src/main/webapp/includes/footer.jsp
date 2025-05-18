<footer style="background-color: #0D1321;" class="text-light py-3 mt-4">
    <div class="container">
        <div class="row align-items-center g-2">
            <!-- Company Info -->
            <div class="col-md-4 mb-2 mb-md-0">
                <div class="d-flex align-items-center mb-2">
                    <i class="bi bi-camera me-2 text-warning fs-4"></i>
                    <span class="fw-bold fs-5">SnapHouse</span>
                </div>
                <small class="text-muted">Premium photography & videography for your best moments.</small>
            </div>
            <!-- Quick Links -->
            <div class="col-md-5 mb-2 mb-md-0">
                <ul class="list-inline mb-0 text-center">
                    <li class="list-inline-item"><a href="${pageContext.request.contextPath}/" class="text-muted text-decoration-none hover-light small">Home</a></li>
                    <li class="list-inline-item"><a href="${pageContext.request.contextPath}/photographer/photographer_list.jsp" class="text-muted text-decoration-none hover-light small">Photographers</a></li>
                    <li class="list-inline-item"><a href="${pageContext.request.contextPath}/gallery/gallery_list.jsp" class="text-muted text-decoration-none hover-light small">Galleries</a></li>
                    <li class="list-inline-item">
                        <a href="#" class="text-muted text-decoration-none hover-light small" data-bs-toggle="modal" data-bs-target="#aboutUsModal">About</a>
                    </li>
                    <li class="list-inline-item">
                        <a href="#" class="text-muted text-decoration-none hover-light small" data-bs-toggle="modal" data-bs-target="#contactModal">Contact</a>
                    </li>
                </ul>
            </div>
            <!-- Contact & Social -->
            <div class="col-md-3 text-md-end text-center">
                <div class="mb-1">
                    <a href="#" class="text-light me-2"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="text-light me-2"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="text-light me-2"><i class="bi bi-twitter"></i></a>
                    <a href="#" class="text-light"><i class="bi bi-linkedin"></i></a>
                </div>
                <small class="text-muted d-block"><i class="bi bi-envelope me-1"></i>info@SnapHouse.com</small>
            </div>
        </div>
        <hr class="my-2" style="border-top: 1px solid #748CAB;">
        <div class="row">
            <div class="col-12 text-center text-muted small">
                &copy; 2025 SnapHouse. All rights reserved. &nbsp;|&nbsp; Designed by <a href="#" class="text-warning text-decoration-none">PGNO - 60</a>
            </div>
        </div>
    </div>
</footer>
<!-- About Us Modal -->
<div class="modal fade" id="aboutUsModal" tabindex="-1" aria-labelledby="aboutUsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="aboutUsModalLabel">About Us</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <!-- Your About Us content here -->
                <p>We are group number 60 and this website is for the project for OOP and DSA modules in our University.</p>
            </div>
        </div>
    </div>
</div>
<!-- End About Us Modal -->

<!-- Contact Modal -->
<div class="modal fade" id="contactModal" tabindex="-1" aria-labelledby="contactModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="contactModalLabel">Contact Information</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p><strong>Email:</strong> info@SnapHouse.com</p>
                <p><strong>Phone:</strong> +94 71 255 9865</p>
                <p><strong>Address:</strong> Sliit, Pittugala, Malabe</p>
                <div>
                    <a href="#" class="text-dark me-2"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="text-dark me-2"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="text-dark me-2"><i class="bi bi-twitter"></i></a>
                    <a href="#" class="text-dark"><i class="bi bi-linkedin"></i></a>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- End Contact Modal -->