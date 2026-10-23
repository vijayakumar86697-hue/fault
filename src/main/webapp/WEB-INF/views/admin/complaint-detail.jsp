<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Admin Ticket ${complaint.ticketNumber} - Campus Infrastructure" />
<c:set var="activeMenu" value="admin-complaints" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <!-- Header -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-1 small">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/complaints">Complaints</a></li>
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

                <div class="d-flex flex-wrap gap-2">
                    <button type="button" class="btn btn-navy btn-sm" data-bs-toggle="modal" data-bs-target="#assignModal">
                        <i class="bi bi-person-plus me-1"></i> Assign Worker
                    </button>
                    <button type="button" class="btn btn-outline-primary btn-sm" data-bs-toggle="modal" data-bs-target="#statusModal">
                        <i class="bi bi-arrow-repeat me-1"></i> Update Status
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#priorityModal">
                        <i class="bi bi-flag me-1"></i> Set Priority
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/complaints" class="btn btn-light btn-sm border">
                        <i class="bi bi-arrow-left"></i>
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="row g-4">
                <!-- Main Column -->
                <div class="col-lg-8">
                    <!-- Ticket Details Card -->
                    <div class="card-custom mb-4">
                        <div class="card-body p-4">
                            <h4 class="fw-bold text-dark mb-2"><c:out value="${complaint.title}" /></h4>
                            <p class="text-secondary mb-4" style="white-space: pre-line;"><c:out value="${complaint.description}" /></p>

                            <div class="row g-3 p-3 bg-light rounded-3 border">
                                <div class="col-sm-6 col-md-3">
                                    <small class="text-muted d-block">Category</small>
                                    <span class="fw-semibold text-dark">
                                        <i class="bi ${complaint.categoryIcon != null ? complaint.categoryIcon : 'bi-tools'} me-1 text-primary"></i>
                                        <c:out value="${complaint.categoryName}" />
                                    </span>
                                </div>
                                <div class="col-sm-6 col-md-3">
                                    <small class="text-muted d-block">Facility / Building</small>
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

                    <!-- Photographs & Evidence -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h5 class="mb-0 fw-bold"><i class="bi bi-images me-2 text-primary"></i>Photographs &amp; Repair Verification</h5>
                        </div>
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${empty complaint.attachments}">
                                    <div class="text-center py-4 text-muted">
                                        <i class="bi bi-camera fs-2 text-secondary d-block mb-1"></i>
                                        <p class="small mb-0">No photographic evidence attached to this ticket.</p>
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

                    <!-- Discussion & Work Notes -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                            <h5 class="mb-0 fw-bold"><i class="bi bi-chat-dots me-2 text-primary"></i>Communication &amp; Notes</h5>
                            <span class="badge bg-light text-secondary border">${complaint.comments.size()} Notes</span>
                        </div>
                        <div class="card-body p-4">
                            <c:forEach var="cmt" items="${complaint.comments}">
                                <div class="d-flex align-items-start gap-3 mb-3 p-3 rounded-3 ${cmt.internal ? 'bg-warning-subtle border border-warning' : 'bg-light border'}">
                                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width: 38px; height: 38px; flex-shrink: 0;">
                                        ${fn:substring(cmt.userName, 0, 1)}
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <span class="fw-semibold text-dark">
                                                <c:out value="${cmt.userName}" />
                                                <span class="badge bg-secondary-subtle text-secondary ms-1" style="font-size: 0.7rem;">${cmt.userRole}</span>
                                                <c:if test="${cmt.internal}">
                                                    <span class="badge bg-warning text-dark ms-1" style="font-size: 0.65rem;">INTERNAL STAFF ONLY</span>
                                                </c:if>
                                            </span>
                                            <small class="text-muted"><fmt:formatDate value="${cmt.createdAt}" pattern="dd MMM, hh:mm a" /></small>
                                        </div>
                                        <p class="mb-0 text-secondary small"><c:out value="${cmt.commentText}" /></p>
                                    </div>
                                </div>
                            </c:forEach>

                            <form action="${pageContext.request.contextPath}/complaints/comment" method="POST" class="mt-4 pt-3 border-top">
                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                <input type="hidden" name="complaintId" value="${complaint.id}" />

                                <div class="mb-2">
                                    <label for="commentText" class="form-label-custom">Add Administrative Note or Response</label>
                                    <textarea class="form-control" id="commentText" name="commentText" rows="2" placeholder="Write comment or instruction..." required></textarea>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="isInternal" value="true" id="isInternalCheck" />
                                        <label class="form-check-label small text-muted" for="isInternalCheck">
                                            Mark as internal note (visible only to admins and technicians)
                                        </label>
                                    </div>
                                    <button class="btn btn-navy btn-sm px-3" type="submit">Post Note</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Reporter, Worker, Audit -->
                <div class="col-lg-4">
                    <!-- Reporter Profile -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-person me-2 text-primary"></i>Reporter Profile</h6>
                        </div>
                        <div class="card-body p-4">
                            <div class="fw-bold text-dark fs-6 mb-1"><c:out value="${complaint.reporterName}" /></div>
                            <div class="small text-muted mb-2">${complaint.reporterRole} &bull; ${complaint.reporterEmail}</div>
                            <c:if test="${not empty complaint.reporterPhone}">
                                <div class="small text-dark mb-2"><i class="bi bi-telephone me-1 text-secondary"></i> <c:out value="${complaint.reporterPhone}" /></div>
                            </c:if>
                            <div class="small text-muted">
                                <i class="bi bi-calendar3 me-1"></i> Reported on <fmt:formatDate value="${complaint.submittedAt}" pattern="dd MMM yyyy, hh:mm a" />
                            </div>
                        </div>
                    </div>

                    <!-- Active Assignment -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-person-gear me-2 text-primary"></i>Assigned Worker</h6>
                            <button class="btn btn-link btn-sm p-0 text-decoration-none" data-bs-toggle="modal" data-bs-target="#assignModal">Change</button>
                        </div>
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${not empty activeAssignment}">
                                    <div class="fw-bold text-dark fs-6 mb-1"><c:out value="${activeAssignment.workerName}" /></div>
                                    <div class="small text-muted mb-2"><c:out value="${activeAssignment.workerSpecialty}" /> &bull; <c:out value="${activeAssignment.workerEmail}" /></div>
                                    <c:if test="${not empty activeAssignment.workerPhone}">
                                        <div class="small text-dark mb-2"><i class="bi bi-telephone me-1 text-secondary"></i> <c:out value="${activeAssignment.workerPhone}" /></div>
                                    </c:if>
                                    <c:if test="${not empty activeAssignment.expectedCompletion}">
                                        <div class="small text-dark mb-2"><i class="bi bi-clock me-1 text-secondary"></i> Target: <fmt:formatDate value="${activeAssignment.expectedCompletion}" pattern="dd MMM yyyy" /></div>
                                    </c:if>
                                    <c:if test="${not empty activeAssignment.instructions}">
                                        <div class="p-2 bg-light border rounded small mt-2">
                                            <span class="text-muted fw-semibold d-block" style="font-size: 0.72rem;">WORK ORDER INSTRUCTIONS:</span>
                                            <c:out value="${activeAssignment.instructions}" />
                                        </div>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-3 text-muted">
                                        <i class="bi bi-person-slash fs-2 text-secondary d-block mb-1"></i>
                                        <p class="small mb-2">No technician currently assigned.</p>
                                        <button class="btn btn-sm btn-navy" data-bs-toggle="modal" data-bs-target="#assignModal">
                                            Assign Technician Now
                                        </button>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Audit Timeline -->
                    <div class="card-custom">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-primary"></i>Status Transition Audit</h6>
                        </div>
                        <div class="card-body p-4">
                            <div class="timeline">
                                <c:forEach var="h" items="${complaint.statusHistories}">
                                    <div class="timeline-item">
                                        <div class="timeline-point ${h.newStatus == 'COMPLETED' || h.newStatus == 'CLOSED' ? 'completed' : ''}"></div>
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
                                                By: <c:out value="${h.changedByName}" /> (${h.changedByRole})
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

<!-- Modal: Assign Worker -->
<div class="modal fade" id="assignModal" tabindex="-1" aria-labelledby="assignModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/complaints/assign" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                <input type="hidden" name="complaintId" value="${complaint.id}" />

                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="assignModalLabel">Dispatch Maintenance Worker</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="workerId" class="form-label-custom">Select Technician / Maintenance Staff *</label>
                        <select class="form-select" id="workerId" name="workerId" required>
                            <option value="" disabled selected>-- Choose Worker --</option>
                            <c:forEach var="w" items="${workers}">
                                <option value="${w.id}" ${complaint.assignedWorkerId == w.id ? 'selected' : ''}>
                                    <c:out value="${w.fullName}" /> - <c:out value="${w.workerSpecialty}" />
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="expectedCompletion" class="form-label-custom">Target Completion Date</label>
                        <input type="date" class="form-control" id="expectedCompletion" name="expectedCompletion" />
                    </div>

                    <div class="mb-3">
                        <label for="instructions" class="form-label-custom">Work Order Instructions / Scope</label>
                        <textarea class="form-control" id="instructions" name="instructions" rows="3" placeholder="Specific safety instructions, required tools, isolation steps..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-navy">Confirm &amp; Dispatch</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Update Status -->
<div class="modal fade" id="statusModal" tabindex="-1" aria-labelledby="statusModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/complaints/status" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                <input type="hidden" name="complaintId" value="${complaint.id}" />

                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="statusModalLabel">Update Complaint Status</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="newStatus" class="form-label-custom">New Status *</label>
                        <select class="form-select" id="newStatus" name="newStatus" required>
                            <option value="UNDER_REVIEW" ${complaint.status == 'UNDER_REVIEW' ? 'selected' : ''}>UNDER REVIEW</option>
                            <option value="ASSIGNED" ${complaint.status == 'ASSIGNED' ? 'selected' : ''}>ASSIGNED</option>
                            <option value="IN_PROGRESS" ${complaint.status == 'IN_PROGRESS' ? 'selected' : ''}>IN PROGRESS</option>
                            <option value="ON_HOLD" ${complaint.status == 'ON_HOLD' ? 'selected' : ''}>ON HOLD</option>
                            <option value="COMPLETED" ${complaint.status == 'COMPLETED' ? 'selected' : ''}>COMPLETED</option>
                            <option value="CLOSED" ${complaint.status == 'CLOSED' ? 'selected' : ''}>CLOSED (Verified)</option>
                            <option value="REJECTED" ${complaint.status == 'REJECTED' ? 'selected' : ''}>REJECTED</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="statusRemarks" class="form-label-custom">Status Transition Notes / Reason</label>
                        <textarea class="form-control" id="statusRemarks" name="remarks" rows="3" placeholder="Enter explanation or closing verification notes..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Status</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Update Priority -->
<div class="modal fade" id="priorityModal" tabindex="-1" aria-labelledby="priorityModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/complaints/priority" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                <input type="hidden" name="complaintId" value="${complaint.id}" />

                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="priorityModalLabel">Adjust Priority Level</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="newPriority" class="form-label-custom">Priority Level *</label>
                        <select class="form-select" id="newPriority" name="newPriority" required>
                            <option value="LOW" ${complaint.priority == 'LOW' ? 'selected' : ''}>LOW</option>
                            <option value="MEDIUM" ${complaint.priority == 'MEDIUM' ? 'selected' : ''}>MEDIUM</option>
                            <option value="HIGH" ${complaint.priority == 'HIGH' ? 'selected' : ''}>HIGH</option>
                            <option value="CRITICAL" ${complaint.priority == 'CRITICAL' ? 'selected' : ''}>CRITICAL</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Priority</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
