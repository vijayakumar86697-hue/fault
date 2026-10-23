<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="My Complaints - Campus Infrastructure Portal" />
<c:set var="activeMenu" value="my-complaints" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">My Reported Complaints</h2>
                    <p class="text-muted mb-0">Track status updates, technician assignments, and resolution notes for your tickets.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/complaints/new" class="btn btn-navy shadow-sm">
                        <i class="bi bi-plus-circle me-1"></i> New Complaint
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="card-custom">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-custom">
                            <thead>
                                <tr>
                                    <th>Ticket #</th>
                                    <th>Title</th>
                                    <th>Category</th>
                                    <th>Campus Location</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Reported</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty complaints}">
                                        <tr>
                                            <td colspan="8" class="text-center py-5 text-muted">
                                                <i class="bi bi-inbox fs-1 text-secondary d-block mb-2"></i>
                                                <h5>No Complaints Found</h5>
                                                <p class="small mb-3">You have not submitted any complaint reports yet.</p>
                                                <a href="${pageContext.request.contextPath}/complaints/new" class="btn btn-sm btn-navy">
                                                    Submit a Complaint Now
                                                </a>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="c" items="${complaints}">
                                            <tr>
                                                <td class="fw-bold text-primary">
                                                    <a href="${pageContext.request.contextPath}/complaints/view?id=${c.id}" class="text-decoration-none">
                                                        <c:out value="${c.ticketNumber}" />
                                                    </a>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold text-dark"><c:out value="${c.title}" /></div>
                                                </td>
                                                <td>
                                                    <i class="bi ${c.categoryIcon != null ? c.categoryIcon : 'bi-tools'} me-1 text-secondary"></i>
                                                    <c:out value="${c.categoryName}" />
                                                </td>
                                                <td>
                                                    <span class="d-block fw-medium text-dark"><c:out value="${c.buildingName}" /></span>
                                                    <small class="text-muted"><c:out value="${c.roomLocation}" /></small>
                                                </td>
                                                <td>
                                                    <span class="badge ${c.priorityBadgeClass}">
                                                        <c:out value="${c.priority}" />
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge-status badge-${c.status.toLowerCase().replace('_', '-')}">
                                                        <c:out value="${c.status}" />
                                                    </span>
                                                </td>
                                                <td class="text-muted small">
                                                    <fmt:formatDate value="${c.submittedAt}" pattern="dd MMM yyyy, hh:mm a" />
                                                </td>
                                                <td class="text-end">
                                                    <a href="${pageContext.request.contextPath}/complaints/view?id=${c.id}" class="btn btn-sm btn-outline-primary">
                                                        Details &amp; Timeline <i class="bi bi-arrow-right ms-1"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
