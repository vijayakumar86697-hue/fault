<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="User Management - Campus Infrastructure" />
<c:set var="activeMenu" value="users" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Users &amp; Maintenance Staff</h2>
                    <p class="text-muted mb-0">Supervise campus user accounts, assign technicians, and toggle active statuses.</p>
                </div>
                <div>
                    <form action="${pageContext.request.contextPath}/admin/users" method="GET" class="d-flex gap-2">
                        <select class="form-select form-select-sm" name="role" onchange="this.form.submit()">
                            <option value="">All Roles</option>
                            <option value="ADMIN" ${selectedRole == 'ADMIN' ? 'selected' : ''}>Administrators</option>
                            <option value="WORKER" ${selectedRole == 'WORKER' ? 'selected' : ''}>Maintenance Staff</option>
                            <option value="FACULTY" ${selectedRole == 'FACULTY' ? 'selected' : ''}>Faculty</option>
                            <option value="STUDENT" ${selectedRole == 'STUDENT' ? 'selected' : ''}>Students</option>
                        </select>
                    </form>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="card-custom">
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Name / Username</th>
                                <th>Role</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Department / Specialty</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="u" items="${users}">
                                <tr>
                                    <td>
                                        <div class="fw-bold text-dark"><c:out value="${u.fullName}" /></div>
                                        <small class="text-muted">@<c:out value="${u.username}" /></small>
                                    </td>
                                    <td>
                                        <span class="badge ${u.admin ? 'bg-danger-subtle text-danger' : u.worker ? 'bg-warning-subtle text-warning-emphasis' : u.faculty ? 'bg-info-subtle text-info-emphasis' : 'bg-primary-subtle text-primary'}">
                                            <c:out value="${u.role}" />
                                        </span>
                                    </td>
                                    <td><c:out value="${u.email}" /></td>
                                    <td><c:out value="${u.phone != null ? u.phone : 'N/A'}" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty u.workerSpecialty}">
                                                <span class="badge bg-light text-dark border"><i class="bi bi-tools me-1 text-warning"></i><c:out value="${u.workerSpecialty}" /></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-secondary small"><c:out value="${u.department != null ? u.department : 'General'}" /></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge ${u.status == 'ACTIVE' ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'}">
                                            <c:out value="${u.status}" />
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <c:if test="${!u.admin}">
                                            <form action="${pageContext.request.contextPath}/admin/users" method="POST" class="d-inline">
                                                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                                <input type="hidden" name="userId" value="${u.id}" />
                                                <input type="hidden" name="status" value="${u.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}" />
                                                <button type="submit" class="btn btn-sm ${u.status == 'ACTIVE' ? 'btn-outline-danger' : 'btn-outline-success'}"
                                                        onclick="return confirm('Are you sure you want to change account status for ${u.username}?')">
                                                    ${u.status == 'ACTIVE' ? 'Deactivate' : 'Activate'}
                                                </button>
                                            </form>
                                        </c:if>
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
