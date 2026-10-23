<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:if test="${not empty errorMessage}">
    <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center mb-4 shadow-sm" role="alert">
        <i class="bi bi-exclamation-triangle-fill fs-5 me-2"></i>
        <div><strong>Error:</strong> <c:out value="${errorMessage}" /></div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<c:if test="${not empty successMessage || param.success != null}">
    <div class="alert alert-success alert-dismissible fade show d-flex align-items-center mb-4 shadow-sm" role="alert">
        <i class="bi bi-check-circle-fill fs-5 me-2"></i>
        <div>
            <c:choose>
                <c:when test="${not empty successMessage}"><c:out value="${successMessage}" /></c:when>
                <c:when test="${param.success == 'submitted'}">Your complaint has been registered successfully! You can track progress below.</c:when>
                <c:when test="${param.success == 'assigned'}">Maintenance worker assigned successfully to this work order.</c:when>
                <c:when test="${param.success == 'status_updated'}">Complaint status has been updated and audit logged.</c:when>
                <c:when test="${param.success == 'priority_updated'}">Complaint priority level updated successfully.</c:when>
                <c:when test="${param.success == 'task_updated'}">Work status and repair notes updated successfully.</c:when>
                <c:when test="${param.success == 'reopened'}">Complaint successfully reopened for administrative review.</c:when>
                <c:when test="${param.success == 'updated'}">Records updated successfully.</c:when>
                <c:otherwise>Operation completed successfully.</c:otherwise>
            </c:choose>
        </div>
        <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
