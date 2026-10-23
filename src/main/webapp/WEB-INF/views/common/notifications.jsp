<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Notifications - Campus Infrastructure Portal" />
<c:set var="activeMenu" value="notifications" />
<jsp:include page="header.jsp" />

<div class="app-wrapper">
    <jsp:include page="sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="navbar.jsp" />
        <main class="content-body">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="mb-1">Notifications & Alerts</h2>
                    <p class="text-muted mb-0">Stay updated on your reported faults, task assignments, and resolutions.</p>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/notifications/read-all" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-check-all me-1"></i> Mark All as Read
                    </a>
                </div>
            </div>

            <jsp:include page="messages.jsp" />

            <div class="card-custom">
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty notifications}">
                            <div class="p-5 text-center text-muted">
                                <i class="bi bi-bell-slash fs-1 d-block mb-3 text-secondary"></i>
                                <h5>No Notifications Yet</h5>
                                <p class="mb-0">You're all caught up! Updates regarding your complaints will appear here.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="list-group list-group-flush">
                                <c:forEach var="n" items="${notifications}">
                                    <div class="list-group-item p-3 ${n.read ? 'bg-white' : 'bg-light'} d-flex align-items-start justify-content-between">
                                        <div class="d-flex align-items-start gap-3">
                                            <span class="badge ${n.badgeClass} rounded-circle p-2 mt-1">
                                                <i class="bi bi-bell-fill fs-6 text-white"></i>
                                            </span>
                                            <div>
                                                <div class="fw-semibold text-dark">
                                                    <c:out value="${n.title}" />
                                                    <c:if test="${!n.read}">
                                                        <span class="badge bg-danger ms-1" style="font-size: 0.65rem;">NEW</span>
                                                    </c:if>
                                                </div>
                                                <p class="text-secondary small mb-1"><c:out value="${n.message}" /></p>
                                                <small class="text-muted">
                                                    <i class="bi bi-clock me-1"></i>
                                                    <fmt:formatDate value="${n.createdAt}" pattern="dd MMM yyyy, hh:mm a" />
                                                </small>
                                            </div>
                                        </div>
                                        <div class="d-flex align-items-center gap-2">
                                            <c:if test="${n.complaintId != null}">
                                                <a href="${pageContext.request.contextPath}/complaints/view?id=${n.complaintId}" class="btn btn-sm btn-outline-primary">
                                                    View Ticket
                                                </a>
                                            </c:if>
                                            <c:if test="${!n.read}">
                                                <a href="${pageContext.request.contextPath}/notifications/read?id=${n.id}" class="btn btn-sm btn-link text-muted" title="Mark as read">
                                                    <i class="bi bi-check2"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="footer.jsp" />
