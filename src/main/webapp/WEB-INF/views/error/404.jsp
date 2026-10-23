<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="404 Not Found - Campus Infrastructure" />
<jsp:include page="../common/header.jsp" />

<div class="min-vh-100 d-flex align-items-center justify-content-center bg-light">
    <div class="text-center p-4">
        <div class="mb-3">
            <i class="bi bi-compass text-primary" style="font-size: 5rem;"></i>
        </div>
        <h1 class="display-4 fw-bold text-dark">404</h1>
        <h4 class="text-secondary mb-3">Resource or Ticket Not Found</h4>
        <p class="text-muted mb-4" style="max-width: 480px; margin: 0 auto;">
            The complaint ticket, page, or facility resource you requested could not be located on the campus network.
        </p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-navy px-4">
            <i class="bi bi-house-door me-1"></i> Return to Dashboard
        </a>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
