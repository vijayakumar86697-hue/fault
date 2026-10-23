<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Register - Campus Infrastructure Portal" />
<jsp:include page="../common/header.jsp" />

<div class="min-vh-100 d-flex flex-column justify-content-center py-5" style="background: linear-gradient(135deg, #0f2744 0%, #1e3a5f 100%);">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-9 col-lg-8 col-xl-7">
                <div class="text-center mb-4">
                    <h2 class="text-white fw-bold">Campus Account Registration</h2>
                    <p class="text-light opacity-75 small">Join the centralized campus infrastructure fault reporting platform</p>
                </div>

                <div class="card shadow-lg border-0 rounded-4 overflow-hidden">
                    <div class="card-body p-4 p-sm-5">
                        <c:if test="${not empty errorMessage}">
                            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2 fs-5"></i>
                                <div><c:out value="${errorMessage}" /></div>
                                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/auth/register" method="POST" id="registerForm">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="fullName" class="form-label-custom">Full Name *</label>
                                    <input type="text" class="form-control" id="fullName" name="fullName" placeholder="e.g. Emily Watson" required />
                                </div>
                                <div class="col-md-6">
                                    <label for="username" class="form-label-custom">Username *</label>
                                    <input type="text" class="form-control" id="username" name="username" placeholder="e.g. emily_w" required />
                                </div>

                                <div class="col-md-6">
                                    <label for="email" class="form-label-custom">Campus Email Address *</label>
                                    <input type="email" class="form-control" id="email" name="email" placeholder="e.g. emily@student.campus.edu" required />
                                </div>
                                <div class="col-md-6">
                                    <label for="phone" class="form-label-custom">Contact Phone Number</label>
                                    <input type="tel" class="form-control" id="phone" name="phone" placeholder="e.g. +1 (555) 012-3456" />
                                </div>

                                <div class="col-md-6">
                                    <label for="role" class="form-label-custom">Role Category *</label>
                                    <select class="form-select" id="role" name="role" required>
                                        <option value="STUDENT" selected>Student</option>
                                        <option value="FACULTY">Faculty Member</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="department" class="form-label-custom">Department / School</label>
                                    <input type="text" class="form-control" id="department" name="department" placeholder="e.g. Computer Science & Eng." />
                                </div>

                                <div class="col-md-6">
                                    <label for="password" class="form-label-custom">Password (Min 6 chars) *</label>
                                    <input type="password" class="form-control" id="password" name="password" minlength="6" placeholder="••••••••" required />
                                </div>
                                <div class="col-md-6">
                                    <label for="confirmPassword" class="form-label-custom">Confirm Password *</label>
                                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" minlength="6" placeholder="••••••••" required />
                                </div>
                            </div>

                            <div class="mt-4 pt-2">
                                <button type="submit" class="btn btn-navy w-100 py-2 fs-6 shadow-sm">
                                    <i class="bi bi-person-plus me-1"></i> Register Account
                                </button>
                            </div>
                        </form>

                        <div class="text-center mt-3 pt-3 border-top">
                            <span class="text-muted small">Already have an account?</span>
                            <a href="${pageContext.request.contextPath}/auth/login" class="fw-semibold small ms-1 text-primary text-decoration-none">
                                Sign In
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
