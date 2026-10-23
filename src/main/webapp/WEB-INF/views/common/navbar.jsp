<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<header class="app-topbar">
    <div class="d-flex align-items-center gap-3">
        <button class="btn btn-outline-secondary d-lg-none" id="sidebarToggle" type="button" aria-label="Toggle Navigation">
            <i class="bi bi-list fs-5"></i>
        </button>
        <span class="d-none d-md-inline text-muted small fw-medium">
            <i class="bi bi-shield-check text-primary me-1"></i> Campus Infrastructure Operations Portal
        </span>
    </div>

    <div class="d-flex align-items-center gap-3">
        <!-- In-app Notifications Dropdown Trigger -->
        <a href="${pageContext.request.contextPath}/notifications" class="btn btn-light position-relative p-2 rounded-circle" title="Notifications">
            <i class="bi bi-bell text-secondary fs-5"></i>
            <c:if test="${sessionScope.unreadCount > 0}">
                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                    ${sessionScope.unreadCount}
                    <span class="visually-hidden">unread messages</span>
                </span>
            </c:if>
        </a>

        <!-- User Profile Dropdown -->
        <div class="dropdown">
            <button class="btn btn-light dropdown-toggle d-flex align-items-center gap-2 py-1 px-2 border rounded-pill" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width: 32px; height: 32px; font-size: 0.85rem;">
                    ${not empty sessionScope.currentUser.fullName ? fn:substring(sessionScope.currentUser.fullName, 0, 1) : 'U'}
                </div>
                <div class="text-start d-none d-sm-block pe-1">
                    <div class="fw-semibold small text-dark lh-1">${sessionScope.currentUser.fullName}</div>
                    <small class="text-muted" style="font-size: 0.72rem;">${sessionScope.currentUser.role}</small>
                </div>
            </button>
            <ul class="dropdown-menu dropdown-menu-end shadow-sm border mt-2">
                <li class="px-3 py-2 border-bottom">
                    <span class="d-block fw-semibold text-dark">${sessionScope.currentUser.fullName}</span>
                    <small class="text-muted">${sessionScope.currentUser.email}</small>
                    <span class="badge bg-primary-subtle text-primary mt-1">${sessionScope.currentUser.role}</span>
                </li>
                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/dashboard"><i class="bi bi-speedometer2 me-2 text-primary"></i> Dashboard</a></li>
                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/notifications"><i class="bi bi-bell me-2 text-warning"></i> Notifications</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth/logout"><i class="bi bi-box-arrow-right me-2"></i> Log Out</a></li>
            </ul>
        </div>
    </div>
</header>
