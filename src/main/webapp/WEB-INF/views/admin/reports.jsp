<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Reports & Analytics - Campus Infrastructure Admin" />
<c:set var="activeMenu" value="reports" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Reports &amp; Infrastructure Analytics</h2>
                    <p class="text-muted mb-0">Evaluate resolution performance, recurring faults, campus load, and export audit data.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/reports/export?startDate=${param.startDate}&endDate=${param.endDate}&categoryId=${param.categoryId}&buildingId=${param.buildingId}&status=${param.status}&priority=${param.priority}" 
                       class="btn btn-success btn-sm shadow-sm">
                        <i class="bi bi-file-earmark-spreadsheet me-1"></i> Export Filtered Report (CSV)
                    </a>
                </div>
            </div>

            <!-- Filter Panel -->
            <div class="card-custom mb-4">
                <div class="card-body p-3 p-md-4">
                    <form action="${pageContext.request.contextPath}/admin/reports" method="GET" class="row g-2 align-items-end">
                        <div class="col-md-2">
                            <label for="startDate" class="form-label-custom">Start Date</label>
                            <input type="date" class="form-control" id="startDate" name="startDate" value="<c:out value='${param.startDate}' />" />
                        </div>
                        <div class="col-md-2">
                            <label for="endDate" class="form-label-custom">End Date</label>
                            <input type="date" class="form-control" id="endDate" name="endDate" value="<c:out value='${param.endDate}' />" />
                        </div>
                        <div class="col-md-2">
                            <label for="categoryId" class="form-label-custom">Category</label>
                            <select class="form-select" id="categoryId" name="categoryId">
                                <option value="">All Categories</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}" ${param.categoryId == cat.id ? 'selected' : ''}><c:out value="${cat.name}" /></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label for="buildingId" class="form-label-custom">Building</label>
                            <select class="form-select" id="buildingId" name="buildingId">
                                <option value="">All Buildings</option>
                                <c:forEach var="b" items="${buildings}">
                                    <option value="${b.id}" ${param.buildingId == b.id ? 'selected' : ''}><c:out value="${b.name}" /></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label for="status" class="form-label-custom">Status</label>
                            <select class="form-select" id="status" name="status">
                                <option value="">All Statuses</option>
                                <option value="SUBMITTED" ${param.status == 'SUBMITTED' ? 'selected' : ''}>Submitted</option>
                                <option value="IN_PROGRESS" ${param.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                <option value="CLOSED" ${param.status == 'CLOSED' ? 'selected' : ''}>Closed</option>
                            </select>
                        </div>
                        <div class="col-md-2 d-flex gap-1">
                            <button type="submit" class="btn btn-navy w-100"><i class="bi bi-filter me-1"></i> Filter</button>
                            <a href="${pageContext.request.contextPath}/admin/reports" class="btn btn-outline-secondary" title="Reset"><i class="bi bi-arrow-counterclockwise"></i></a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-6">
                    <div class="card-custom h-100">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-pie-chart me-2 text-primary"></i>Category Fault Distribution</h6>
                        </div>
                        <div class="card-body p-4">
                            <div style="height: 260px; position: relative;">
                                <canvas id="reportCategoryChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card-custom h-100">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-bar-chart-line me-2 text-primary"></i>Facility Fault Frequency</h6>
                        </div>
                        <div class="card-body p-4">
                            <div style="height: 260px; position: relative;">
                                <canvas id="reportBuildingChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Report Table -->
            <div class="card-custom">
                <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">Report Records (${complaints.size()} Found)</h5>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Ticket #</th>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Location</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Reporter</th>
                                <th>Technician</th>
                                <th>Submitted</th>
                                <th>Resolved</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${complaints}">
                                <tr>
                                    <td class="fw-bold text-primary">
                                        <a href="${pageContext.request.contextPath}/admin/complaints/view?id=${c.id}" class="text-decoration-none">
                                            <c:out value="${c.ticketNumber}" />
                                        </a>
                                    </td>
                                    <td><c:out value="${c.title}" /></td>
                                    <td><c:out value="${c.categoryName}" /></td>
                                    <td><c:out value="${c.buildingCode}" /> - <c:out value="${c.roomLocation}" /></td>
                                    <td><span class="badge ${c.priorityBadgeClass}"><c:out value="${c.priority}" /></span></td>
                                    <td><span class="badge-status badge-${c.status.toLowerCase().replace('_', '-')}"><c:out value="${c.status}" /></span></td>
                                    <td><c:out value="${c.reporterName}" /></td>
                                    <td><c:out value="${c.assignedWorkerName != null ? c.assignedWorkerName : 'Unassigned'}" /></td>
                                    <td class="text-muted small"><fmt:formatDate value="${c.submittedAt}" pattern="dd MMM yyyy" /></td>
                                    <td class="text-muted small">
                                        <c:choose>
                                            <c:when test="${c.resolvedAt != null}">
                                                <fmt:formatDate value="${c.resolvedAt}" pattern="dd MMM yyyy" />
                                            </c:when>
                                            <c:otherwise>&mdash;</c:otherwise>
                                        </c:choose>
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
    const catLabels = [
        <c:forEach var="entry" items="${categoryDistribution}" varStatus="status">
            "<c:out value='${entry.key}' />"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    const catData = [
        <c:forEach var="entry" items="${categoryDistribution}" varStatus="status">
            ${entry.value}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    initCategoryDoughnutChart('reportCategoryChart', catLabels, catData);

    const bldgLabels = [
        <c:forEach var="entry" items="${locationDistribution}" varStatus="status">
            "<c:out value='${entry.key}' />"<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    const bldgData = [
        <c:forEach var="entry" items="${locationDistribution}" varStatus="status">
            ${entry.value}<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    initBuildingBarChart('reportBuildingChart', bldgLabels, bldgData);
});
</script>
