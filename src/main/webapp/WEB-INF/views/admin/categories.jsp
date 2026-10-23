<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Fault Categories - Campus Infrastructure" />
<c:set var="activeMenu" value="categories" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Fault Categories</h2>
                    <p class="text-muted mb-0">Configure infrastructure fault domains, default priority ratings, and icons.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-navy btn-sm" data-bs-toggle="modal" data-bs-target="#categoryModal" onclick="prepareCreate()">
                        <i class="bi bi-plus-circle me-1"></i> Add Category
                    </button>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="card-custom">
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Icon</th>
                                <th>Category Name</th>
                                <th>Description</th>
                                <th>Default Priority</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${categories}">
                                <tr>
                                    <td>
                                        <div class="bg-light rounded p-2 text-center" style="width: 40px; height: 40px;">
                                            <i class="bi ${c.icon != null ? c.icon : 'bi-tools'} fs-5 text-primary"></i>
                                        </div>
                                    </td>
                                    <td class="fw-bold text-dark"><c:out value="${c.name}" /></td>
                                    <td class="text-secondary small"><c:out value="${c.description}" /></td>
                                    <td>
                                        <span class="badge ${c.defaultPriority == 'CRITICAL' ? 'bg-danger' : c.defaultPriority == 'HIGH' ? 'bg-warning text-dark' : 'bg-primary'}">
                                            <c:out value="${c.defaultPriority}" />
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge ${c.active ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'}">
                                            ${c.active ? 'Active' : 'Disabled'}
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <button class="btn btn-sm btn-outline-secondary me-1" 
                                                onclick="prepareEdit(${c.id}, '<c:out value="${c.name}" />', '<c:out value="${c.icon}" />', '<c:out value="${c.description}" />', '${c.defaultPriority}', ${c.active})">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <form action="${pageContext.request.contextPath}/admin/categories" method="POST" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                            <input type="hidden" name="action" value="toggle" />
                                            <input type="hidden" name="id" value="${c.id}" />
                                            <input type="hidden" name="active" value="${!c.active}" />
                                            <button type="submit" class="btn btn-sm ${c.active ? 'btn-outline-danger' : 'btn-outline-success'}" title="${c.active ? 'Disable' : 'Enable'}">
                                                <i class="bi ${c.active ? 'bi-slash-circle' : 'bi-check-circle'}"></i>
                                            </button>
                                        </form>
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

<!-- Category Modal -->
<div class="modal fade" id="categoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/categories" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                <input type="hidden" name="action" value="save" />
                <input type="hidden" id="catId" name="id" value="0" />

                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="catModalTitle">Add Fault Category</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="catName" class="form-label-custom">Category Name *</label>
                        <input type="text" class="form-control" id="catName" name="name" required />
                    </div>
                    <div class="mb-3">
                        <label for="catIcon" class="form-label-custom">Bootstrap Icon Class</label>
                        <input type="text" class="form-control" id="catIcon" name="icon" placeholder="e.g. bi-lightning-charge" />
                    </div>
                    <div class="mb-3">
                        <label for="catPriority" class="form-label-custom">Default Priority</label>
                        <select class="form-select" id="catPriority" name="defaultPriority">
                            <option value="LOW">LOW</option>
                            <option value="MEDIUM" selected>MEDIUM</option>
                            <option value="HIGH">HIGH</option>
                            <option value="CRITICAL">CRITICAL</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label for="catDesc" class="form-label-custom">Description</label>
                        <textarea class="form-control" id="catDesc" name="description" rows="2"></textarea>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="catActive" name="active" value="true" checked />
                        <label class="form-check-label small" for="catActive">Category is Active for reporting</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-navy">Save Category</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function prepareCreate() {
    document.getElementById('catModalTitle').innerText = 'Add Fault Category';
    document.getElementById('catId').value = '0';
    document.getElementById('catName').value = '';
    document.getElementById('catIcon').value = 'bi-tools';
    document.getElementById('catDesc').value = '';
    document.getElementById('catPriority').value = 'MEDIUM';
    document.getElementById('catActive').checked = true;
}

function prepareEdit(id, name, icon, desc, priority, active) {
    document.getElementById('catModalTitle').innerText = 'Edit Fault Category';
    document.getElementById('catId').value = id;
    document.getElementById('catName').value = name;
    document.getElementById('catIcon').value = icon;
    document.getElementById('catDesc').value = desc;
    document.getElementById('catPriority').value = priority;
    document.getElementById('catActive').checked = active;
    new bootstrap.Modal(document.getElementById('categoryModal')).show();
}
</script>

<jsp:include page="../common/footer.jsp" />
