<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Login - Campus Infrastructure Fault Reporting System" />
<jsp:include page="../common/header.jsp" />

<div class="min-vh-100 d-flex flex-column justify-content-center py-5" style="background: linear-gradient(135deg, #0f2744 0%, #1e3a5f 100%);">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-9 col-lg-7 col-xl-6">
                <!-- Branding Header -->
                <div class="text-center mb-4">
                    <div class="d-inline-flex align-items-center justify-content-center bg-white rounded-circle shadow-lg mb-3" style="width: 72px; height: 72px;">
                        <i class="bi bi-building-gear text-primary fs-1"></i>
                    </div>
                    <h2 class="text-white fw-bold">Campus Infrastructure Portal</h2>
                    <p class="text-light opacity-75 small">Fault Reporting, Maintenance Dispatch & Resolution Tracking</p>
                </div>

                <!-- Login Card -->
                <div class="card shadow-lg border-0 rounded-4 overflow-hidden">
                    <div class="card-body p-4 p-sm-5">
                        <h4 class="fw-bold text-dark mb-1">Sign In</h4>
                        <p class="text-muted small mb-4">Enter your campus credentials to access your dashboard.</p>

                        <!-- Messages -->
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                                <i class="bi bi-exclamation-circle-fill me-2 fs-5"></i>
                                <div><c:out value="${errorMessage}" /></div>
                                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <c:if test="${param.registered == 'true'}">
                            <div class="alert alert-success d-flex align-items-center" role="alert">
                                <i class="bi bi-check-circle-fill me-2 fs-5"></i>
                                <div>Registration successful! You may now log in with your credentials.</div>
                            </div>
                        </c:if>

                        <c:if test="${param.loggedOut == 'true'}">
                            <div class="alert alert-info d-flex align-items-center" role="alert">
                                <i class="bi bi-info-circle-fill me-2 fs-5"></i>
                                <div>You have been safely signed out.</div>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/auth/login" method="POST">
                            <input type="hidden" name="redirect" value="<c:out value='${param.redirect}' />" />

                            <div class="mb-3">
                                <label for="username" class="form-label-custom">Username or Campus Email</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-person"></i></span>
                                    <input type="text" class="form-control border-start-0" id="username" name="username" placeholder="e.g. admin or student1" required autofocus />
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="password" class="form-label-custom">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                                    <input type="password" class="form-control border-start-0" id="password" name="password" placeholder="••••••••" required />
                                </div>
                            </div>

                            <button type="submit" class="btn btn-navy w-100 py-2 fs-6 shadow-sm mb-3">
                                <i class="bi bi-box-arrow-in-right me-1"></i> Sign In to Portal
                            </button>
                        </form>

                        <div class="text-center mt-3 pt-3 border-top">
                            <span class="text-muted small">New Student or Faculty?</span>
                            <a href="${pageContext.request.contextPath}/auth/register" class="fw-semibold small ms-1 text-primary text-decoration-none">
                                Create an Account
                            </a>
                        </div>
                    </div>

                    <!-- Demo Credentials Helper Card -->
                    <div class="bg-light p-3 border-top">
                        <div class="small fw-semibold text-muted text-uppercase mb-2 text-center" style="font-size: 0.7rem; letter-spacing: 0.05em;">
                            One-Click Demo Credentials (Academic Evaluation)
                        </div>
                        <div class="d-flex flex-wrap gap-2 justify-content-center">
                            <button type="button" class="btn btn-sm btn-outline-secondary bg-white shadow-none demo-btn" onclick="fillCreds('admin', 'admin123')">
                                <i class="bi bi-shield-lock text-primary me-1"></i> Admin
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-secondary bg-white shadow-none demo-btn" onclick="fillCreds('student1', 'student123')">
                                <i class="bi bi-mortarboard text-success me-1"></i> Student
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-secondary bg-white shadow-none demo-btn" onclick="fillCreds('prof_smith', 'faculty123')">
                                <i class="bi bi-person-badge text-info me-1"></i> Faculty
                            </button>
                            <button type="button" class="btn btn-sm btn-outline-secondary bg-white shadow-none demo-btn" onclick="fillCreds('worker_elec', 'worker123')">
                                <i class="bi bi-tools text-warning me-1"></i> Worker
                            </button>
                        </div>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <small class="text-white-50">&copy; Campus Infrastructure Operations &amp; Facilities Management System</small>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function fillCreds(u, p) {
    document.getElementById('username').value = u;
    document.getElementById('password').value = p;
}
</script>

<jsp:include page="../common/footer.jsp" />
