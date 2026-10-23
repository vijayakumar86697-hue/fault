<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="pageTitle" value="Ticket ${complaint.ticketNumber} - Campus Infrastructure" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <!-- Navigation Breadcrumb -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb mb-1 small">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/complaints/my">My Complaints</a></li>
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

                <div class="d-flex align-items-center gap-2">
                    <c:if test="${complaint.canBeReopened()}">
                        <button type="button" class="btn btn-outline-danger btn-sm" data-bs-toggle="modal" data-bs-target="#reopenModal">
                            <i class="bi bi-arrow-counterclockwise me-1"></i> Reopen Ticket
                        </button>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/complaints/my" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left me-1"></i> Back to List
                    </a>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="row g-4">
                <!-- Left Column: Details, Photos, Comments -->
                <div class="col-lg-8">
                    <!-- Ticket Title and Description Card -->
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
                                    <small class="text-muted d-block">Campus Building</small>
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

                    <!-- Photographs & Evidence Gallery -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h5 class="mb-0 fw-bold"><i class="bi bi-images me-2 text-primary"></i>Photographs &amp; Repair Evidence</h5>
                        </div>
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${empty complaint.attachments}">
                                    <div class="text-center py-4 text-muted">
                                        <i class="bi bi-camera fs-2 text-secondary d-block mb-1"></i>
                                        <p class="small mb-0">No photographs attached to this ticket.</p>
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

                    <!-- Communication & Comments Thread -->
                    <div class="card-custom mb-4" id="comments">
                        <div class="card-header bg-white py-3 px-4 border-bottom d-flex justify-content-between align-items-center">
                            <h5 class="mb-0 fw-bold"><i class="bi bi-chat-dots me-2 text-primary"></i>Activity &amp; Discussion</h5>
                            <span class="badge bg-light text-secondary border">${complaint.comments.size()} Notes</span>
                        </div>
                        <div class="card-body p-4">
                            <c:if test="${empty complaint.comments}">
                                <div class="text-center py-4 text-muted">
                                    <i class="bi bi-chat-square-text fs-2 text-secondary d-block mb-1"></i>
                                    <p class="small mb-0">No comments posted yet. Use the box below to ask questions or provide updates.</p>
                                </div>
                            </c:if>

                            <c:forEach var="cmt" items="${complaint.comments}">
                                <div class="d-flex align-items-start gap-3 mb-3 p-3 rounded-3 ${cmt.internal ? 'bg-warning-subtle border-warning' : 'bg-light border'}">
                                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width: 38px; height: 38px; flex-shrink: 0;">
                                        ${fn:substring(cmt.userName, 0, 1)}
                                    </div>
                                    <div class="flex-grow-1">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <span class="fw-semibold text-dark">
                                                <c:out value="${cmt.userName}" />
                                                <span class="badge bg-secondary-subtle text-secondary ms-1" style="font-size: 0.7rem;">${cmt.userRole}</span>
                                                <c:if test="${cmt.internal}">
                                                    <span class="badge bg-warning text-dark ms-1" style="font-size: 0.65rem;">INTERNAL NOTE</span>
                                                </c:if>
                                            </span>
                                            <small class="text-muted"><fmt:formatDate value="${cmt.createdAt}" pattern="dd MMM, hh:mm a" /></small>
                                        </div>
                                        <p class="mb-0 text-secondary small"><c:out value="${cmt.commentText}" /></p>
                                    </div>
                                </div>
                            </c:forEach>

                            <!-- Add Comment Form -->
                            <form action="${pageContext.request.contextPath}/complaints/comment" method="POST" class="mt-4 pt-3 border-top">
                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                <input type="hidden" name="complaintId" value="${complaint.id}" />

                                <label for="commentText" class="form-label-custom">Post a Comment / Inquiry</label>
                                <div class="input-group">
                                    <textarea class="form-control" id="commentText" name="commentText" rows="2" placeholder="Write a message or provide additional details..." required></textarea>
                                    <button class="btn btn-navy px-4" type="submit">
                                        <i class="bi bi-send me-1"></i> Post
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Status Timeline & Assigned Staff -->
                <div class="col-lg-4">
                    <!-- Assigned Worker Card -->
                    <div class="card-custom mb-4">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-person-gear me-2 text-primary"></i>Assigned Technician</h6>
                        </div>
                        <div class="card-body p-4">
                            <c:choose>
                                <c:when test="${complaint.assignedWorkerId != null}">
                                    <div class="d-flex align-items-center gap-3 mb-3">
                                        <div class="bg-success text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-5" style="width: 48px; height: 48px;">
                                            <i class="bi bi-tools"></i>
                                        </div>
                                        <div>
                                            <h6 class="mb-0 fw-bold text-dark"><c:out value="${complaint.assignedWorkerName}" /></h6>
                                            <small class="text-muted"><c:out value="${complaint.assignedWorkerSpecialty}" /></small>
                                        </div>
                                    </div>
                                    <c:if test="${not empty complaint.assignedWorkerPhone}">
                                        <div class="mb-2 small">
                                            <i class="bi bi-telephone text-secondary me-2"></i>
                                            <c:out value="${complaint.assignedWorkerPhone}" />
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty complaint.assignmentInstructions}">
                                        <div class="mt-3 p-2 bg-light rounded border small">
                                            <span class="fw-semibold text-muted d-block" style="font-size: 0.75rem;">DISPATCH INSTRUCTIONS</span>
                                            <c:out value="${complaint.assignmentInstructions}" />
                                        </div>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-3 text-muted">
                                        <i class="bi bi-clock-history fs-3 text-secondary d-block mb-1"></i>
                                        <p class="small mb-0">Under review by estate administration. A maintenance technician will be dispatched shortly.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Status History Timeline -->
                    <div class="card-custom">
                        <div class="card-header bg-white py-3 px-4 border-bottom">
                            <h6 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-primary"></i>Audit Timeline</h6>
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

<!-- Modal: Reopen Complaint -->
<div class="modal fade" id="reopenModal" tabindex="-1" aria-labelledby="reopenModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/complaints/reopen" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                <input type="hidden" name="complaintId" value="${complaint.id}" />

                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="reopenModalLabel">
                        <i class="bi bi-arrow-counterclockwise text-danger me-1"></i> Reopen Complaint Ticket
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="small text-muted mb-3">
                        If the issue has re-occurred or was not resolved satisfactorily, please explain why you are requesting to reopen this ticket.
                    </p>
                    <div class="mb-3">
                        <label for="reopenReason" class="form-label-custom">Reason for Reopening *</label>
                        <textarea class="form-control" id="reopenReason" name="reopenReason" rows="3" placeholder="e.g. The leak resumed after 2 hours of technician visit..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">
                        Confirm Reopen
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
