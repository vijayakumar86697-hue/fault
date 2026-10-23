<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Task ${complaint.ticketNumber} - Maintenance Desk" />
<c:set var="activeMenu" value="tasks" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-1 small">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/worker/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/worker/tasks">My Tasks</a></li>
                            <li class="breadcrumb-item active"><c:out value="${complaint.ticketNumber}" /></li>
                        </ol>
                    </nav>
                    <div class="d-flex align-items-center gap-2">
                        <h2 class="mb-0"><c:out value="${complaint.ticketNumber}" /></h2>
                        <span class="badge-status badge-${complaint.status.toLowerCase().replace('_', '-')} fs-6">
                            <c:out value="${complaint.status}" />
                        </span>
                        <span class="badge ${complaint.priorityBadgeClass} fs-6">
                            <c:out value="${complaint.priority}" /> Priority
                        </span>
                    </div>
                </div>

                <div>
                    <a href="${pageContext.request.contextPath}/worker/tasks" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Back to Tasks
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="row g-4">
                <!-- Left Column: Details & Repair Form -->
                <div class="col-lg-8">
                    <!-- Task Overview Card -->
                    <div class="card-custom mb-4">
                        <div class="card-body p-4">
                            <h4 class="fw-bold text-dark mb-2"><c:out value="${complaint.title}" /></h4>
                            <p class="text-secondary mb-4" style="white-space: pre-line;"><c:out value="${complaint.description}" /></p>

                            <div class="row g-3 p-3 bg-light rounded-3 border">
                                <div class="col-sm-6 col-md-3">
                                    <small class="text-muted d-block">Fault Category</small>
                                    <span class="fw-semibold text-dark">
                                        <i class="bi ${complaint.categoryIcon != null ? complaint.categoryIcon : 'bi-tools'} me-1 text-primary"></i>
                                        <c:out value="${complaint.categoryName}" />
                                    </span>
                                </div>
                                <div class="col-sm-6 col-md-3">
                                    <small class="text-muted d-block">Building / Facility</small>
                                    <span class="fw-semibold text-dark"><c:out value="${complaint.buildingName}" /></span>
                                </div>
                                <div class="col-sm-6 col-md-3">
                                    <small class="text-muted d-block">Block &amp; Floor</small>
                                    <span class="fw-semibold text-dark"><c:out value="${complaint.blockFloor}" /></span>
                                </div>
                                <div class="col-sm-6 col-md-3">
                                    <small class="text-muted d-block">Room / Location</small>
                                    <span class="fw-semibold text-dark"><c:out value="${complaint.roomLocation}" /></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Work Order Update Form -->
                    <div class="card-custom mb-4 border-primary">
                        <div class="card-header bg-navy text-white py-3 px-4" style="background-color: var(--navy-primary);">
                            <h5 class="mb-0 fw-bold text-white"><i class="bi bi-tools me-2 text-warning"></i>Update Task Status &amp; Evidence</h5>
                        </div>
                        <div class="card-body p-4">
                            <form action="${pageContext.request.contextPath}/worker/tasks/status" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                <input type="hidden" name="complaintId" value="${complaint.id}" />

                                <div class="mb-3">
                                    <label for="newStatus" class="form-label-custom">Work Status *</label>
                                    <select class="form-select" id="newStatus" name="newStatus" required>
                                        <option value="IN_PROGRESS" ${complaint.status == 'IN_PROGRESS' ? 'selected' : ''}>
                                            IN PROGRESS - Started repair work on site
                                        </option>
                                        <option value="ON_HOLD" ${complaint.status == 'ON_HOLD' ? 'selected' : ''}>
                                            ON HOLD - Awaiting spare parts, specialized tools, or area access
                                        </option>
                                        <option value="COMPLETED" ${complaint.status == 'COMPLETED' ? 'selected' : ''}>
                                            COMPLETED - Work completed and verified
                                        </option>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label for="remarks" class="form-label-custom">Repair Details &amp; Work Notes</label>
                                    <textarea class="form-control" id="remarks" name="remarks" rows="3" placeholder="Explain the actions taken, parts replaced, or reasons if placed on hold..."></textarea>
                                </div>

                                <div class="mb-4">
                                    <label for="photoInput" class="form-label-custom">Upload After-Repair Photograph (Completion Proof)</label>
                                    <input class="form-control" type="file" id="photoInput" name="afterPhoto" accept="image/png, image/jpeg, image/webp" />
                                    <div class="form-text small">Upload photographic proof after repairing the issue to submit to the administrator.</div>

                                    <div id="photoPreviewContainer" class="d-none mt-2 p-2 bg-light border rounded text-center">
                                        <small class="text-muted d-block mb-1">After-Repair Photo Preview</small>
                                        <img id="photoPreview" src="#" alt="Preview" class="img-fluid rounded" style="max-height: 150px;" />
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-navy px-4 shadow-sm">
                                    <i class="bi bi-check-circle me-1"></i> Save Status &amp; Submit Notes
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Photographs & Evidence -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h5 class="mb-0 fw-bold"><i class="bi bi-images me-2 text-primary"></i>Photographs (Before &amp; After)</h5>
                        </div>
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${empty complaint.attachments}">
                                    <div class="text-center py-4 text-muted">
                                        <i class="bi bi-camera fs-2 text-secondary d-block mb-1"></i>
                                        <p class="small mb-0">No photographs uploaded yet.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="row g-3">
                                        <c:forEach var="att" items="${complaint.attachments}">
                                            <div class="col-sm-6 col-md-4">
                                                <div class="card h-100 border shadow-none overflow-hidden">
                                                    <c:choose>
                                                        <c:when test="${att.image}">
                                                            <a href="${pageContext.request.contextPath}/uploads/${att.storedName}" target="_blank">
                                                                <img src="${pageContext.request.contextPath}/uploads/${att.storedName}" class="card-img-top" style="height: 160px; object-fit: cover;" alt="${att.originalName}" />
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="bg-light d-flex align-items-center justify-content-center" style="height: 160px;">
                                                                <i class="bi bi-file-earmark-pdf fs-1 text-danger"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="card-body p-2 text-center bg-white">
                                                        <span class="badge ${att.attachmentType == 'BEFORE_REPAIR' ? 'bg-secondary' : 'bg-success'} mb-1">
                                                            ${att.attachmentType.replace('_', ' ')}
                                                        </span>
                                                        <small class="d-block text-truncate text-muted" title="${att.originalName}">${att.originalName}</small>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Dispatch Instructions & Audit -->
                <div class="col-lg-4">
                    <!-- Dispatch Instructions Card -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-clipboard-check me-2 text-primary"></i>Admin Dispatch Instructions</h6>
                        </div>
                        <div class="card-body p-4">
                            <c:if test="${not empty activeAssignment}">
                                <div class="mb-3">
                                    <small class="text-muted d-block">Target Completion</small>
                                    <span class="fw-bold text-dark">
                                        <fmt:formatDate value="${activeAssignment.expectedCompletion}" pattern="dd MMM yyyy" />
                                    </span>
                                </div>
                                <div class="mb-3">
                                    <small class="text-muted d-block">Assigned By</small>
                                    <span class="text-dark"><c:out value="${activeAssignment.assignerName}" /></span>
                                </div>
                                <c:if test="${not empty activeAssignment.instructions}">
                                    <div class="p-3 bg-light rounded border small">
                                        <span class="fw-semibold text-muted d-block mb-1" style="font-size: 0.72rem;">SCOPE &amp; INSTRUCTIONS:</span>
                                        <c:out value="${activeAssignment.instructions}" />
                                    </div>
                                </c:if>
                            </c:if>
                        </div>
                    </div>

                    <!-- Audit Timeline -->
                    <div class="card-custom">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-primary"></i>Task History</h6>
                        </div>
                        <div class="card-body p-4">
                            <div class="timeline">
                                <c:forEach var="h" items="${complaint.statusHistories}">
                                    <div class="timeline-item">
                                        <div class="timeline-point ${h.newStatus == 'COMPLETED' ? 'completed' : ''}"></div>
                                        <div class="timeline-content">
                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                <span class="badge-status badge-${h.newStatus.toLowerCase().replace('_', '-')}">
                                                    <c:out value="${h.newStatus}" />
                                                </span>
                                                <small class="text-muted" style="font-size: 0.72rem;">
                                                    <fmt:formatDate value="${h.createdAt}" pattern="dd MMM, hh:mm a" />
                                                </small>
                                            </div>
                                            <c:if test="${not empty h.remarks}">
                                                <div class="small text-secondary mb-1"><c:out value="${h.remarks}" /></div>
                                            </c:if>
                                            <small class="text-muted" style="font-size: 0.72rem;">
                                                By: <c:out value="${h.changedByName}" />
                                            </small>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
