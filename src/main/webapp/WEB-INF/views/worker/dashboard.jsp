<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Worker Dashboard - Campus Infrastructure" />
<c:set var="activeMenu" value="dashboard" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Maintenance Technician Console</h2>
                    <p class="text-muted mb-0">Assigned work orders, status updates, and repair completion verification.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/worker/tasks" class="btn btn-navy btn-sm">
                        <i class="bi bi-tools me-1"></i> View All My Tasks
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <!-- Worker Metrics Cards -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val"><c:out value="${stats.total_assigned != null ? stats.total_assigned : 0}" /></div>
                            <div class="stat-lbl">Total Assigned</div>
                        </div>
                        <div class="stat-icon navy">
                            <i class="bi bi-clipboard2-check"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val text-danger"><c:out value="${stats.critical_tasks != null ? stats.critical_tasks : 0}" /></div>
                            <div class="stat-lbl">Critical Tasks</div>
                        </div>
                        <div class="stat-icon danger">
                            <i class="bi bi-exclamation-triangle"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val text-warning"><c:out value="${stats.pending_work != null ? stats.pending_work : 0}" /></div>
                            <div class="stat-lbl">Active &amp; In Progress</div>
                        </div>
                        <div class="stat-icon warning">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val text-success"><c:out value="${stats.completed_work != null ? stats.completed_work : 0}" /></div>
                            <div class="stat-lbl">Completed Work</div>
                        </div>
                        <div class="stat-icon success">
                            <i class="bi bi-check2-circle"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Assigned Tasks Table -->
            <div class="card-custom">
                <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">My Active Work Queue</h5>
                    <a href="${pageContext.request.contextPath}/worker/tasks" class="btn btn-sm btn-link text-decoration-none">
                        View All Tasks <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Ticket #</th>
                                <th>Task Title</th>
                                <th>Category</th>
                                <th>Location</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty assignedTasks}">
                                    <tr>
                                        <td colspan="7" class="text-center py-5 text-muted">
                                            <i class="bi bi-check2-all fs-1 text-success d-block mb-2"></i>
                                            <h5>All Caught Up!</h5>
                                            <p class="small mb-0">You currently have no pending tasks assigned to you.</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="t" items="${assignedTasks}">
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
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/worker/tasks/view?id=${t.id}" class="btn btn-sm btn-navy">
                                                    Manage Work Order <i class="bi bi-chevron-right ms-1"></i>
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
