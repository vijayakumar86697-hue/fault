<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="app-sidebar">
    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-brand">
            <i class="bi bi-building-gear"></i>
            <div>
                <span class="d-block lh-1 text-white fw-bold">CampusFault</span>
                <span style="font-size: 0.68rem; color: #94a3b8; font-weight: 400;">Report & Dispatch</span>
            </div>
        </a>
    </div>

    <div class="sidebar-menu">
        <div class="menu-section-label">Main Navigation</div>
        <a href="${pageContext.request.contextPath}/dashboard" class="nav-item-custom ${activeMenu == 'dashboard' ? 'active' : ''}">
            <i class="bi bi-grid-1x2"></i> Dashboard
        </a>

        <!-- Role: Student / Faculty Navigation -->
        <c:if test="${sessionScope.currentUser.role == 'STUDENT' || sessionScope.currentUser.role == 'FACULTY'}">
            <a href="${pageContext.request.contextPath}/complaints/new" class="nav-item-custom ${activeMenu == 'new-complaint' ? 'active' : ''}">
                <i class="bi bi-plus-circle text-info"></i> Report a Fault
            </a>
            <a href="${pageContext.request.contextPath}/complaints/my" class="nav-item-custom ${activeMenu == 'my-complaints' ? 'active' : ''}">
                <i class="bi bi-journal-text"></i> My Complaints
            </a>
        </c:if>

        <!-- Role: Maintenance Worker Navigation -->
        <c:if test="${sessionScope.currentUser.role == 'WORKER'}">
            <div class="menu-section-label">Maintenance Desk</div>
            <a href="${pageContext.request.contextPath}/worker/tasks" class="nav-item-custom ${activeMenu == 'tasks' ? 'active' : ''}">
                <i class="bi bi-tools text-warning"></i> Assigned Tasks
            </a>
            <a href="${pageContext.request.contextPath}/worker/tasks?status=IN_PROGRESS" class="nav-item-custom">
                <i class="bi bi-hourglass-split text-info"></i> In Progress Work
            </a>
        </c:if>

        <!-- Role: Administrator Navigation -->
        <c:if test="${sessionScope.currentUser.role == 'ADMIN'}">
            <div class="menu-section-label">Administration</div>
            <a href="${pageContext.request.contextPath}/admin/complaints" class="nav-item-custom ${activeMenu == 'admin-complaints' ? 'active' : ''}">
                <i class="bi bi-clipboard2-pulse"></i> All Complaints
            </a>
            <a href="${pageContext.request.contextPath}/admin/reports" class="nav-item-custom ${activeMenu == 'reports' ? 'active' : ''}">
                <i class="bi bi-graph-up-arrow text-success"></i> Reports & Analytics
            </a>
            <a href="${pageContext.request.contextPath}/complaints/new" class="nav-item-custom ${activeMenu == 'new-complaint' ? 'active' : ''}">
                <i class="bi bi-plus-circle text-info"></i> Log Direct Fault
            </a>

            <div class="menu-section-label">System Setup</div>
            <a href="${pageContext.request.contextPath}/admin/categories" class="nav-item-custom ${activeMenu == 'categories' ? 'active' : ''}">
                <i class="bi bi-tags"></i> Fault Categories
            </a>
            <a href="${pageContext.request.contextPath}/admin/buildings" class="nav-item-custom ${activeMenu == 'buildings' ? 'active' : ''}">
                <i class="bi bi-building"></i> Campus Buildings
            </a>
            <a href="${pageContext.request.contextPath}/admin/users" class="nav-item-custom ${activeMenu == 'users' ? 'active' : ''}">
                <i class="bi bi-people"></i> Users & Staff
            </a>
        </c:if>

        <div class="menu-section-label">Account</div>
        <a href="${pageContext.request.contextPath}/notifications" class="nav-item-custom ${activeMenu == 'notifications' ? 'active' : ''}">
            <i class="bi bi-bell"></i> Notifications
            <c:if test="${sessionScope.unreadCount > 0}">
                <span class="badge bg-danger ms-auto rounded-pill">${sessionScope.unreadCount}</span>
            </c:if>
        </a>
        <a href="${pageContext.request.contextPath}/auth/logout" class="nav-item-custom text-danger">
            <i class="bi bi-box-arrow-right text-danger"></i> Sign Out
        </a>
    </div>

    <!-- Active User Footer in Sidebar -->
    <div class="p-3 border-top border-white border-opacity-10 d-flex align-items-center gap-2">
        <i class="bi bi-person-circle fs-4 text-secondary"></i>
        <div class="overflow-hidden">
            <div class="text-white text-truncate fw-semibold small">${sessionScope.currentUser.fullName}</div>
            <div class="text-white-50 text-truncate" style="font-size: 0.72rem;">${sessionScope.currentUser.role}</div>
        </div>
    </div>
</aside>
