package com.campus.interceptor;

import com.campus.model.User;
import com.campus.service.NotificationService;
import com.campus.util.CSRFUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Spring MVC HandlerInterceptor enforcing Role-Based Access Control (RBAC),
 * session security, CSRF token attachment, and security response headers.
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final NotificationService notificationService;

    public AuthInterceptor(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Security response headers
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "SAMEORIGIN");
        response.setHeader("X-XSS-Protection", "1; mode=block");

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.substring(contextPath.length());

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Populate CSRF token for active session
        if (session != null) {
            String csrfToken = CSRFUtil.getToken(session);
            request.setAttribute("csrfToken", csrfToken);
        }

        // Validate state-changing CSRF for POST/PUT/DELETE
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            // Exclude public auth endpoints from CSRF if token not yet established
            if (!path.startsWith("/auth/")) {
                String reqCsrf = request.getParameter("csrfToken");
                if (reqCsrf == null) reqCsrf = request.getHeader("X-CSRF-TOKEN");
                if (!CSRFUtil.validateToken(session, reqCsrf)) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or missing CSRF token");
                    return false;
                }
            }
        }

        // Check if path is protected
        boolean isAdminPath = path.startsWith("/admin/");
        boolean isWorkerPath = path.startsWith("/worker/");
        boolean isStudentPath = path.startsWith("/student/");
        boolean isComplaintPath = path.startsWith("/complaints/");
        boolean isNotificationPath = path.startsWith("/notifications/");

        if (isAdminPath || isWorkerPath || isStudentPath || isComplaintPath || isNotificationPath) {
            if (user == null) {
                response.sendRedirect(contextPath + "/auth/login?redirect=" + path);
                return false;
            }

            String role = user.getRole();

            if (isAdminPath && !"ADMIN".equalsIgnoreCase(role)) {
                request.setAttribute("errorMessage", "Access Denied: Administrator role required.");
                request.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
                return false;
            }

            if (isWorkerPath && !"WORKER".equalsIgnoreCase(role)) {
                request.setAttribute("errorMessage", "Access Denied: Maintenance Worker role required.");
                request.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
                return false;
            }

            if (isStudentPath && !"STUDENT".equalsIgnoreCase(role) && !"FACULTY".equalsIgnoreCase(role)) {
                request.setAttribute("errorMessage", "Access Denied: Student or Faculty role required.");
                request.getRequestDispatcher("/WEB-INF/views/error/403.jsp").forward(request, response);
                return false;
            }

            // Populate unread notifications count for header
            int unreadCount = notificationService.getUnreadCount(user.getId());
            request.setAttribute("unreadNotificationsCount", unreadCount);
        }

        return true;
    }
}
