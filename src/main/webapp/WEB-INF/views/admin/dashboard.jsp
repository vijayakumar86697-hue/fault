<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Admin Executive Dashboard - Campus Infrastructure" />
<c:set var="activeMenu" value="dashboard" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <!-- Header -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Campus Operations Dashboard</h2>
                    <p class="text-muted mb-0">Overview of campus infrastructure complaints, worker assignments, and triage priorities.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-graph-up me-1"></i> View Analytics
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-navy btn-sm">
                        <i class="bi bi-list-task me-1"></i> Manage Complaints
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <!-- Metric Cards (Row 1) -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val"><c:out value="${stats.total != null ? stats.total : 0}" /></div>
                            <div class="stat-lbl">Total Complaints</div>
                        </div>
                        <div class="stat-icon navy">
                            <i class="bi bi-collection"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val text-warning"><c:out value="${stats.unassigned != null ? stats.unassigned : 0}" /></div>
                            <div class="stat-lbl">Unassigned / New</div>
                        </div>
                        <div class="stat-icon warning">
                            <i class="bi bi-person-exclamation"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val text-danger"><c:out value="${stats.critical != null ? stats.critical : 0}" /></div>
                            <div class="stat-lbl">Critical Emergencies</div>
                        </div>
                        <div class="stat-icon danger">
                            <i class="bi bi-exclamation-octagon"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val text-success">
                                <c:out value="${stats.avg_resolution_hours != null ? stats.avg_resolution_hours : '0.0'}" />h
                            </div>
                            <div class="stat-lbl">Avg Resolution Time</div>
                        </div>
                        <div class="stat-icon success">
                            <i class="bi bi-speedometer"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Metric Cards (Row 2: Pipeline Breakdown) -->
            <div class="row g-3 mb-4">
                <div class="col-sm-4">
                    <div class="p-3 bg-white border rounded-3 d-flex align-items-center justify-content-between">
                        <div>
                            <small class="text-muted text-uppercase fw-semibold" style="font-size: 0.72rem;">Assigned to Workers</small>
                            <h4 class="mb-0 fw-bold text-primary"><c:out value="${stats.assigned != null ? stats.assigned : 0}" /></h4>
                        </div>
                        <i class="bi bi-person-check fs-2 text-primary opacity-50"></i>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="p-3 bg-white border rounded-3 d-flex align-items-center justify-content-between">
                        <div>
                            <small class="text-muted text-uppercase fw-semibold" style="font-size: 0.72rem;">Work In Progress</small>
                            <h4 class="mb-0 fw-bold text-warning"><c:out value="${stats.in_progress != null ? stats.in_progress : 0}" /></h4>
                        </div>
                        <i class="bi bi-tools fs-2 text-warning opacity-50"></i>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="p-3 bg-white border rounded-3 d-flex align-items-center justify-content-between">
                        <div>
                            <small class="text-muted text-uppercase fw-semibold" style="font-size: 0.72rem;">Completed &amp; Closed</small>
                            <h4 class="mb-0 fw-bold text-success">
                                ${stats.completed + stats.closed}
                            </h4>
                        </div>
                        <i class="bi bi-check2-all fs-2 text-success opacity-50"></i>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-6">
                    <div class="card-custom h-100">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-pie-chart me-2 text-primary"></i>Complaints by Fault Category</h6>
                        </div>
                        <div class="card-body p-4">
                            <div style="height: 280px; position: relative;">
                                <canvas id="categoryChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card-custom h-100">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-bar-chart-line me-2 text-primary"></i>Complaints by Campus Facility / Building</h6>
                        </div>
                        <div class="card-body p-4">
                            <div style="height: 280px; position: relative;">
                                <canvas id="buildingChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Complaints Triage Table -->
            <div class="card-custom">
                <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">Recent Complaints for Administrative Triage</h5>
                    <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-sm btn-link text-decoration-none">
                        View All Complaints <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Ticket #</th>
                                <th>Reporter</th>
                                <th>Category</th>
                                <th>Location</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Assigned Worker</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${recentComplaints}">
                                <tr>
                                    <td class="fw-bold text-primary">
                                        <a href="${pageContext.request.contextPath}/admin/complaints/view?id=${c.id}" class="text-decoration-none">
                                            <c:out value="${c.ticketNumber}" />
                                        </a>
                                    </td>
                                    <td>
                                        <div class="fw-semibold text-dark"><c:out value="${c.reporterName}" /></div>
                                        <small class="text-muted"><c:out value="${c.reporterRole}" /></small>
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
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty c.assignedWorkerName}">
                                                <span class="fw-medium text-dark"><c:out value="${c.assignedWorkerName}" /></span>
                                                <small class="d-block text-muted"><c:out value="${c.assignedWorkerSpecialty}" /></small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning-subtle text-warning-emphasis">Unassigned</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end">
                                        <a href="${pageContext.request.contextPath}/admin/complaints/view?id=${c.id}" class="btn btn-sm btn-outline-primary">
                                            Review &amp; Assign <i class="bi bi-chevron-right ms-1"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<script>
document.addEventListener('DOMContentLoaded', function () {
    // Populate Category Chart
    const catLabels = [
        <c:forEach var="entry" items="${categoryStats}" varStatus="status">
            "<c:out value='${entry.key}' />"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    const catData = [
        <c:forEach var="entry" items="${categoryStats}" varStatus="status">
            ${entry.value}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    initCategoryDoughnutChart('categoryChart', catLabels, catData);

    // Populate Building Chart
    const bldgLabels = [
        <c:forEach var="entry" items="${locationStats}" varStatus="status">
            "<c:out value='${entry.key}' />"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    const bldgData = [
        <c:forEach var="entry" items="${locationStats}" varStatus="status">
            ${entry.value}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    initBuildingBarChart('buildingChart', bldgLabels, bldgData);
});
</script>
