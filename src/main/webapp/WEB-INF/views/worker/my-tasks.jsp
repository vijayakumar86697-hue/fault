<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="My Tasks - Campus Infrastructure" />
<c:set var="activeMenu" value="tasks" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Assigned Maintenance Tasks</h2>
                    <p class="text-muted mb-0">View work details, accept assigned work, update progress, and attach resolution photos.</p>
                </div>
                <div>
                    <form action="${pageContext.request.contextPath}/worker/tasks" method="GET" class="d-flex gap-2">
                        <select class="form-select form-select-sm" name="status" onchange="this.form.submit()">
                            <option value="">All Tasks</option>
                            <option value="ASSIGNED" ${selectedStatus == 'ASSIGNED' ? 'selected' : ''}>New Assigned</option>
                            <option value="IN_PROGRESS" ${selectedStatus == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                            <option value="ON_HOLD" ${selectedStatus == 'ON_HOLD' ? 'selected' : ''}>On Hold</option>
                            <option value="COMPLETED" ${selectedStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        </select>
                    </form>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="card-custom">
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Ticket #</th>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Facility Location</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Reported</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty tasks}">
                                    <tr>
                                        <td colspan="8" class="text-center py-5 text-muted">
                                            <i class="bi bi-inbox fs-1 text-secondary d-block mb-2"></i>
                                            <h5>No Tasks Found</h5>
                                            <p class="small mb-0">No assigned tasks match the selected status filter.</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="t" items="${tasks}">
                                        <tr>
                                            <td class="fw-bold text-primary">
                                                <a href="${pageContext.request.contextPath}/worker/tasks/view?id=${t.id}" class="text-decoration-none">
                                                    <c:out value="${t.ticketNumber}" />
                                                </a>
                                            </td>
                                            <td>
                                                <div class="fw-semibold text-dark"><c:out value="${t.title}" /></div>
                                            </td>
                                            <td>
                                                <i class="bi ${t.categoryIcon != null ? t.categoryIcon : 'bi-tools'} me-1 text-secondary"></i>
                                                <c:out value="${t.categoryName}" />
                                            </td>
                                            <td>
                                                <span class="d-block fw-medium text-dark"><c:out value="${t.buildingName}" /></span>
                                                <small class="text-muted"><c:out value="${t.roomLocation}" /></small>
                                            </td>
                                            <td>
                                                <span class="badge ${t.priorityBadgeClass}"><c:out value="${t.priority}" /></span>
                                            </td>
                                            <td>
                                                <span class="badge-status badge-${t.status.toLowerCase().replace('_', '-')}"><c:out value="${t.status}" /></span>
                                            </td>
                                            <td class="text-muted small">
                                                <fmt:formatDate value="${t.submittedAt}" pattern="dd MMM yyyy" />
                                            </td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/worker/tasks/view?id=${t.id}" class="btn btn-sm btn-navy">
                                                    Work Details <i class="bi bi-arrow-right ms-1"></i>
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
        </main>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
