<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Campus Buildings - Campus Infrastructure" />
<c:set var="activeMenu" value="buildings" />
<jsp:include page="../common/header.jsp" />

<div class="app-wrapper">
    <jsp:include page="../common/sidebar.jsp" />
    <div class="app-main">
        <jsp:include page="../common/navbar.jsp" />
        <main class="content-body">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-4">
                <div>
                    <h2 class="mb-1">Campus Buildings &amp; Facilities</h2>
                    <p class="text-muted mb-0">Configure campus blocks, code identifiers, and building floors.</p>
                </div>
                <div>
                    <button type="button" class="btn btn-navy btn-sm" data-bs-toggle="modal" data-bs-target="#bldgModal" onclick="prepareCreate()">
                        <i class="bi bi-plus-circle me-1"></i> Add Building
                    </button>
                </div>
            </div>

            <jsp:include page="../common/messages.jsp" />

            <div class="card-custom">
                <div class="table-responsive">
                    <table class="table table-custom">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Building Name</th>
                                <th>Floors</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th class="text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${buildings}">
                                <tr>
                                    <td><span class="badge bg-light text-primary border fw-bold"><c:out value="${b.code}" /></span></td>
                                    <td class="fw-bold text-dark"><c:out value="${b.name}" /></td>
                                    <td><c:out value="${b.floors}" /> Floors</td>
                                    <td class="text-secondary small"><c:out value="${b.description}" /></td>
                                    <td>
                                        <span class="badge ${b.active ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary'}">
                                            ${b.active ? 'Active' : 'Disabled'}
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <button class="btn btn-sm btn-outline-secondary me-1" 
                                                onclick="prepareEdit(${b.id}, '<c:out value="${b.name}" />', '<c:out value="${b.code}" />', ${b.floors}, '<c:out value="${b.description}" />', ${b.active})">
                                            <i class="bi bi-pencil"></i>
                                        </button>
                                        <form action="${pageContext.request.contextPath}/admin/buildings" method="POST" class="d-inline">
                                            <input type="hidden" name="csrfToken" value="${csrfToken}" />
                                            <input type="hidden" name="action" value="toggle" />
                                            <input type="hidden" name="id" value="${b.id}" />
                                            <input type="hidden" name="active" value="${!b.active}" />
                                            <button type="submit" class="btn btn-sm ${b.active ? 'btn-outline-danger' : 'btn-outline-success'}" title="${b.active ? 'Disable' : 'Enable'}">
                                                <i class="bi ${b.active ? 'bi-slash-circle' : 'bi-check-circle'}"></i>
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

<!-- Building Modal -->
<div class="modal fade" id="bldgModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/admin/buildings" method="POST">
                <input type="hidden" name="csrfToken" value="${csrfToken}" />
                <input type="hidden" name="action" value="save" />
                <input type="hidden" id="bldgId" name="id" value="0" />

                <div class="modal-header">
                    <h5 class="modal-title fw-bold" id="bldgModalTitle">Add Campus Building</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="bldgName" class="form-label-custom">Building / Block Name *</label>
                        <input type="text" class="form-control" id="bldgName" name="name" required />
                    </div>
                    <div class="row g-2 mb-3">
                        <div class="col-md-6">
                            <label for="bldgCode" class="form-label-custom">Building Code *</label>
                            <input type="text" class="form-control" id="bldgCode" name="code" placeholder="e.g. ENG-A" required />
                        </div>
                        <div class="col-md-6">
                            <label for="bldgFloors" class="form-label-custom">Total Floors</label>
                            <input type="number" class="form-control" id="bldgFloors" name="floors" min="1" max="50" value="4" required />
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="bldgDesc" class="form-label-custom">Description &amp; Departments</label>
                        <textarea class="form-control" id="bldgDesc" name="description" rows="2"></textarea>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="bldgActive" name="active" value="true" checked />
                        <label class="form-check-label small" for="bldgActive">Building is Active</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-navy">Save Building</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function prepareCreate() {
    document.getElementById('bldgModalTitle').innerText = 'Add Campus Building';
    document.getElementById('bldgId').value = '0';
    document.getElementById('bldgName').value = '';
    document.getElementById('bldgCode').value = '';
    document.getElementById('bldgFloors').value = '4';
    document.getElementById('bldgDesc').value = '';
    document.getElementById('bldgActive').checked = true;
}

function prepareEdit(id, name, code, floors, desc, active) {
    document.getElementById('bldgModalTitle').innerText = 'Edit Campus Building';
    document.getElementById('bldgId').value = id;
    document.getElementById('bldgName').value = name;
    document.getElementById('bldgCode').value = code;
    document.getElementById('bldgFloors').value = floors;
    document.getElementById('bldgDesc').value = desc;
    document.getElementById('bldgActive').checked = active;
    new bootstrap.Modal(document.getElementById('bldgModal')).show();
}
</script>

<jsp:include page="../common/footer.jsp" />
