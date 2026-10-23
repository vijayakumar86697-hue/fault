<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="All Complaints - Campus Infrastructure Admin" />
<c:set var="activeMenu" value="admin-complaints" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Complaint Management Console</h2>
                    <p class="text-muted mb-0">Search, filter, assign, and supervise all campus infrastructure fault reports.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/admin/reports/export" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-file-earmark-spreadsheet me-1"></i> Export Filtered CSV
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <!-- Filter Panel -->
            <div class="card-custom mb-4">
                <div class="card-body p-3 p-md-4">
                    <form action="${pageContext.request.contextPath}/admin/complaints" method="GET" class="row g-2 align-items-end">
                        <div class="col-md-3">
                            <label for="search" class="form-label-custom">Search Ticket / Location / Keyword</label>
                            <div class="input-group">
                                <span class="input-group-text bg-light text-muted"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control" id="search" name="search" value="<c:out value='${param.search}' />" placeholder="e.g. CMP-2026 or Lab 102" />
                            </div>
                        </div>

                        <div class="col-md-2">
                            <label for="status" class="form-label-custom">Status</label>
                            <select class="form-select" id="status" name="status">
                                <option value="">All Statuses</option>
                                <option value="SUBMITTED" ${param.status == 'SUBMITTED' ? 'selected' : ''}>Submitted</option>
                                <option value="UNDER_REVIEW" ${param.status == 'UNDER_REVIEW' ? 'selected' : ''}>Under Review</option>
                                <option value="ASSIGNED" ${param.status == 'ASSIGNED' ? 'selected' : ''}>Assigned</option>
                                <option value="IN_PROGRESS" ${param.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                <option value="ON_HOLD" ${param.status == 'ON_HOLD' ? 'selected' : ''}>On Hold</option>
                                <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                <option value="CLOSED" ${param.status == 'CLOSED' ? 'selected' : ''}>Closed</option>
                                <option value="REJECTED" ${param.status == 'REJECTED' ? 'selected' : ''}>Rejected</option>
                                <option value="REOPENED" ${param.status == 'REOPENED' ? 'selected' : ''}>Reopened</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label for="priority" class="form-label-custom">Priority</label>
                            <select class="form-select" id="priority" name="priority">
                                <option value="">All Priorities</option>
                                <option value="LOW" ${param.priority == 'LOW' ? 'selected' : ''}>Low</option>
                                <option value="MEDIUM" ${param.priority == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                                <option value="HIGH" ${param.priority == 'HIGH' ? 'selected' : ''}>High</option>
                                <option value="CRITICAL" ${param.priority == 'CRITICAL' ? 'selected' : ''}>Critical</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label for="categoryId" class="form-label-custom">Category</label>
                            <select class="form-select" id="categoryId" name="categoryId">
                                <option value="">All Categories</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.id}" ${param.categoryId == cat.id ? 'selected' : ''}>
                                        <c:out value="${cat.name}" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label for="buildingId" class="form-label-custom">Building</label>
                            <select class="form-select" id="buildingId" name="buildingId">
                                <option value="">All Buildings</option>
                                <c:forEach var="b" items="${buildings}">
                                    <option value="${b.id}" ${param.buildingId == b.id ? 'selected' : ''}>
                                        <c:out value="${b.code}" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="col-md-1 d-flex gap-1">
                            <button type="submit" class="btn btn-navy w-100" title="Apply Filter">
                                <i class="bi bi-funnel-fill"></i>
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-outline-secondary" title="Reset Filters">
                                <i class="bi bi-arrow-counterclockwise"></i>
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Table of Complaints -->
            <div class="card-custom">
                <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                    <span class="fw-semibold text-secondary small">
                        Showing <strong>${complaints.size()}</strong> of <strong>${totalCount}</strong> complaint tickets
                    </span>
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
                                <th>Worker</th>
                                <th>Submitted</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty complaints}">
                                    <tr>
                                        <td colspan="10" class="text-center py-5 text-muted">
                                            <i class="bi bi-search fs-2 text-secondary d-block mb-2"></i>
                                            <h5>No Complaints Matched</h5>
                                            <p class="small mb-0">Try adjusting your search criteria or resetting filters.</p>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${complaints}">
                                        <tr>
                                            <td class="fw-bold text-primary">
                                                <a href="${pageContext.request.contextPath}/admin/complaints/view?id=${c.id}" class="text-decoration-none">
                                                    <c:out value="${c.ticketNumber}" />
                                                </a>
                                            </td>
                                            <td>
                                                <div class="fw-semibold text-dark text-truncate" style="max-width: 220px;" title="${c.title}">
                                                    <c:out value="${c.title}" />
                                                </div>
                                            </td>
                                            <td>
                                                <i class="bi ${c.categoryIcon != null ? c.categoryIcon : 'bi-tools'} me-1 text-secondary"></i>
                                                <c:out value="${c.categoryName}" />
                                            </td>
                                            <td>
                                                <span class="d-block fw-medium text-dark"><c:out value="${c.buildingCode}" /></span>
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
                                                <span class="d-block fw-medium text-dark"><c:out value="${c.reporterName}" /></span>
                                                <small class="text-muted">${c.reporterRole}</small>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty c.assignedWorkerName}">
                                                        <span class="text-dark fw-medium"><c:out value="${c.assignedWorkerName}" /></span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small italic">Unassigned</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-muted small">
                                                <fmt:formatDate value="${c.submittedAt}" pattern="dd MMM yyyy" />
                                            </td>
                                            <td class="text-end">
                                                <a href="${pageContext.request.contextPath}/admin/complaints/view?id=${c.id}" class="btn btn-sm btn-navy">
                                                    Manage <i class="bi bi-chevron-right ms-1"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="card-footer bg-white py-3 px-4 border-top d-flex justify-content-between align-items-center">
                        <small class="text-muted">Page ${currentPage} of ${totalPages}</small>
                        <ul class="pagination pagination-sm mb-0">
                            <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&search=${param.search}&status=${param.status}&priority=${param.priority}&categoryId=${param.categoryId}&buildingId=${param.buildingId}">Previous</a>
                            </li>
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-item ${currentPage == i ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}&search=${param.search}&status=${param.status}&priority=${param.priority}&categoryId=${param.categoryId}&buildingId=${param.buildingId}">${i}</a>
                                </li>
                            </c:forEach>
                            <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&search=${param.search}&status=${param.status}&priority=${param.priority}&categoryId=${param.categoryId}&buildingId=${param.buildingId}">Next</a>
                            </li>
                        </ul>
                    </div>
                </c:if>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
