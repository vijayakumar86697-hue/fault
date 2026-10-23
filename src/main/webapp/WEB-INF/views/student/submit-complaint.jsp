<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Report Fault - Campus Infrastructure Portal" />
<c:set var="activeMenu" value="new-complaint" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="mb-4">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-1 small">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Report Infrastructure Fault</li>
                    </ol>
                </nav>
                <div class="d-flex flex-wrap justify-content-between align-items-center gap-2">
                    <div>
                        <h2 class="mb-1">Report an Infrastructure Problem</h2>
                        <p class="text-muted mb-0">Submit a detailed complaint ticket for prompt maintenance inspection and resolution.</p>
                    </div>
                    <div>
                        <span class="badge bg-light text-secondary border px-3 py-2 fs-6">
                            <i class="bi bi-ticket-perforated me-1 text-primary"></i>
                            Estimated Ticket: <strong class="text-dark"><c:out value="${previewTicket}" /></strong>
                        </span>
                    </div>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="card-custom">
                <div class="card-body p-4 p-md-5">
                    <form action="${pageContext.request.contextPath}/complaints/new" method="POST" enctype="multipart/form-data" id="complaintForm">
                        <input type="hidden" name="csrfToken" value="${csrfToken}" />

                        <!-- Section 1: Reporter Info (Read-Only) -->
                        <div class="p-3 bg-light rounded-3 mb-4 border">
                            <div class="row g-3 align-items-center">
                                <div class="col-md-4">
                                    <small class="text-muted d-block">Reported By</small>
                                    <strong class="text-dark"><c:out value="${sessionScope.currentUser.fullName}" /></strong>
                                    <span class="badge bg-secondary-subtle text-secondary ms-1">${sessionScope.currentUser.role}</span>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-muted d-block">Contact Email</small>
                                    <span class="text-dark"><c:out value="${sessionScope.currentUser.email}" /></span>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-muted d-block">Department</small>
                                    <span class="text-dark"><c:out value="${sessionScope.currentUser.department != null ? sessionScope.currentUser.department : 'Campus Student'}" /></span>
                                </div>
                            </div>
                        </div>

                        <!-- Section 2: Fault Classification & Location -->
                        <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">1. Location & Classification</h5>
                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label for="categoryId" class="form-label-custom">Fault Category *</label>
                                <select class="form-select" id="categoryId" name="categoryId" required>
                                    <option value="" disabled selected>-- Select Fault Category --</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}">
                                            <c:out value="${cat.name}" /> (Default: ${cat.defaultPriority})
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label for="priority" class="form-label-custom">Severity / Priority Level *</label>
                                <select class="form-select" id="priority" name="priority" required>
                                    <option value="LOW">Low - Minor defect, does not disrupt regular activity</option>
                                    <option value="MEDIUM" selected>Medium - Noticeable issue requiring scheduled fix</option>
                                    <option value="HIGH">High - Significant disruption to campus operations or classes</option>
                                    <option value="CRITICAL">Critical - Immediate safety hazard, fire risk, or lab emergency</option>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label for="buildingId" class="form-label-custom">Campus Building *</label>
                                <select class="form-select" id="buildingId" name="buildingId" required>
                                    <option value="" disabled selected>-- Select Building --</option>
                                    <c:forEach var="b" items="${buildings}">
                                        <option value="${b.id}">
                                            <c:out value="${b.name}" /> (<c:out value="${b.code}" />)
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-md-4">
                                <label for="blockFloor" class="form-label-custom">Block and Floor *</label>
                                <input type="text" class="form-control" id="blockFloor" name="blockFloor" placeholder="e.g. Block B, 2nd Floor" required />
                            </div>

                            <div class="col-md-4">
                                <label for="roomLocation" class="form-label-custom">Room or Exact Location *</label>
                                <input type="text" class="form-control" id="roomLocation" name="roomLocation" placeholder="e.g. Room 204 or Physics Lab" required />
                            </div>
                        </div>

                        <!-- Section 3: Problem Description -->
                        <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">2. Problem Description</h5>
                        <div class="row g-3 mb-4">
                            <div class="col-12">
                                <label for="title" class="form-label-custom">Complaint Headline / Title *</label>
                                <input type="text" class="form-control" id="title" name="title" maxlength="150" placeholder="Brief summary, e.g. 'Ceiling Fan Making Loud Noise in Hall 301'" required />
                            </div>

                            <div class="col-12">
                                <label for="description" class="form-label-custom">Detailed Problem Description *</label>
                                <textarea class="form-control" id="description" name="description" rows="4" placeholder="Please describe the exact issue, symptoms, when it started, and any potential hazard..." required></textarea>
                            </div>
                        </div>

                        <!-- Section 4: Photograph Upload -->
                        <h5 class="fw-bold text-dark border-bottom pb-2 mb-3">3. Supporting Evidence (Optional)</h5>
                        <div class="row g-3 mb-4">
                            <div class="col-md-7">
                                <label for="photoInput" class="form-label-custom">Fault Photograph / Image Evidence</label>
                                <input class="form-control" type="file" id="photoInput" name="photo" accept="image/png, image/jpeg, image/webp, image/gif, application/pdf" />
                                <div class="form-text small">
                                    Supported formats: JPG, PNG, WEBP, PDF. Maximum file size: 10 MB.
                                </div>
                            </div>
                            <div class="col-md-5">
                                <div id="photoPreviewContainer" class="d-none border rounded-3 p-2 bg-light text-center">
                                    <small class="text-muted d-block mb-1">Image Preview</small>
                                    <img id="photoPreview" src="#" alt="Upload preview" class="img-fluid rounded" style="max-height: 140px;" />
                                </div>
                            </div>
                        </div>

                        <!-- Form Actions -->
                        <div class="d-flex justify-content-end gap-2 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary px-4">
                                Cancel
                            </a>
                            <button type="submit" class="btn btn-navy px-4 shadow-sm" id="submitBtn">
                                <i class="bi bi-send-check me-1"></i> Submit Complaint Ticket
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
