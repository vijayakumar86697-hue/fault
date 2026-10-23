/**
 * Campus Infrastructure Fault Reporting System - Frontend JavaScript Utilities
 */

document.addEventListener('DOMContentLoaded', function () {
    // 1. Initialize Bootstrap Tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // 2. Mobile Sidebar Toggle
    const sidebarToggle = document.getElementById('sidebarToggle');
    const appSidebar = document.querySelector('.app-sidebar');
    if (sidebarToggle && appSidebar) {
        sidebarToggle.addEventListener('click', function () {
            appSidebar.classList.toggle('show');
        });
    }

    // 3. Image Upload Preview & Validation
    const photoInput = document.getElementById('photoInput');
    const previewContainer = document.getElementById('photoPreviewContainer');
    const previewImage = document.getElementById('photoPreview');

    if (photoInput) {
        photoInput.addEventListener('change', function (e) {
            const file = e.target.files[0];
            if (!file) return;

            // Size validation (Max 10MB)
            if (file.size > 10 * 1024 * 1024) {
                alert('File is too large! Maximum allowed upload size is 10 MB.');
                photoInput.value = '';
                if (previewContainer) previewContainer.classList.add('d-none');
                return;
            }

            // Preview if it is an image
            if (file.type.startsWith('image/') && previewImage && previewContainer) {
                const reader = new FileReader();
                reader.onload = function (event) {
                    previewImage.src = event.target.result;
                    previewContainer.classList.remove('d-none');
                };
                reader.readAsDataURL(file);
            }
        });
    }

    // 4. Auto-dismiss alerts after 6 seconds
    const alerts = document.querySelectorAll('.alert-dismissible');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 6000);
    });
});

/**
 * Global confirmation helper
 */
function confirmAction(message) {
    return confirm(message || 'Are you sure you want to proceed with this action?');
}
