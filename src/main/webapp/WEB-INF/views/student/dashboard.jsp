<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Student Dashboard - Campus Infrastructure Portal" />
<c:set var="activeMenu" value="dashboard" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <!-- Welcome Banner -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Welcome back, <c:out value="${sessionScope.currentUser.fullName}" />!</h2>
                    <p class="text-muted mb-0">Report infrastructure issues across campus and track repair progress in real time.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/complaints/new" class="btn btn-navy shadow-sm">
                        <i class="bi bi-plus-circle me-1"></i> Report Infrastructure Fault
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <!-- Metrics Cards -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val"><c:out value="${stats.total != null ? stats.total : 0}" /></div>
                            <div class="stat-lbl">Total Submitted</div>
                        </div>
                        <div class="stat-icon primary">
                            <i class="bi bi-journal-text"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val"><c:out value="${stats.pending != null ? stats.pending : 0}" /></div>
                            <div class="stat-lbl">Pending Review / Triage</div>
                        </div>
                        <div class="stat-icon warning">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val"><c:out value="${stats.in_progress != null ? stats.in_progress : 0}" /></div>
                            <div class="stat-lbl">Work In Progress</div>
                        </div>
                        <div class="stat-icon info">
                            <i class="bi bi-tools"></i>
                        </div>
                    </div>
                </div>

                <div class="col-sm-6 col-xl-3">
                    <div class="stat-card">
                        <div>
                            <div class="stat-val"><c:out value="${stats.resolved != null ? stats.resolved : 0}" /></div>
                            <div class="stat-lbl">Resolved &amp; Closed</div>
                        </div>
                        <div class="stat-icon success">
                            <i class="bi bi-check-circle"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Complaints Table -->
            <div class="card-custom">
                <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                    <h5 class="mb-0 fw-bold">Recent Fault Reports</h5>
                    <a href="${pageContext.request.contextPath}/complaints/my" class="btn btn-sm btn-link text-decoration-none">
                        View All My Reports <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Ticket</th>
                                <th>Title</th>
                                <th>Category</th>
                                <th>Location</th>
                                <th>Priority</th>
                                <th>Status</th>
                                <th>Submitted</th>
                                <th class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty myComplaints}">
                                    <tr>
                                        <td colspan="8" class="text-center py-5 text-muted">
                                            <i class="bi bi-clipboard2-check fs-1 text-secondary d-block mb-2"></i>
                                            <p class="mb-2">You haven't reported any infrastructure faults yet.</p>
                                            <a href="${pageContext.request.contextPath}/complaints/new" class="btn btn-sm btn-navy">
                                                Submit Your First Complaint
                                            </a>
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${myComplaints}" varStatus="loop">
                                        <c:if test="${loop.index < 5}">
                                            <tr>
                                                <td class="fw-semibold text-primary">
                                                    <a href="${pageContext.request.contextPath}/complaints/view?id=${c.id}" class="text-decoration-none">
                                                        <c:out value="${c.ticketNumber}" />
                                                    </a>
                                                </td>
                                                <td><c:out value="${c.title}" /></td>
                                                <td>
                                                    <i class="bi ${c.categoryIcon != null ? c.categoryIcon : 'bi-tools'} me-1 text-secondary"></i>
                                                    <c:out value="${c.categoryName}" />
                                                </td>
                                                <td>
                                                    <small class="text-dark d-block fw-medium"><c:out value="${c.buildingName}" /></small>
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
                                                    <fmt:formatDate value="${c.submittedAt}" pattern="dd MMM yyyy" />
                                                </td>
                                                <td class="text-end">
                                                    <a href="${pageContext.request.contextPath}/complaints/view?id=${c.id}" class="btn btn-sm btn-outline-primary">
                                                        Track <i class="bi bi-chevron-right ms-1"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:if>
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
