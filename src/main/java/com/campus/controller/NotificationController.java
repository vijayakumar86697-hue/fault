package com.campus.controller;

import com.campus.model.Notification;
import com.campus.model.User;
import com.campus.service.NotificationService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * Spring MVC Controller for in-app notification center and read status updates.
 */
@Controller
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping({"", "/", "/list"})
    public String showNotifications(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        List<Notification> list = notificationService.getNotificationsForUser(currentUser.getId(), 50);
        model.addAttribute("notifications", list);
        return "common/notifications";
    }

    @GetMapping("/read")
    public String markNotificationRead(@RequestParam("id") int notifId,
                                       @RequestParam(value = "redirect", required = false) String redirect,
                                       HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (notifId > 0) {
            notificationService.markAsRead(notifId, currentUser.getId());
        }
        session.setAttribute("unreadCount", notificationService.getUnreadCount(currentUser.getId()));

        if (redirect != null && !redirect.isBlank()) {
            return "redirect:" + redirect;
        }
        return "redirect:/notifications";
    }

    @GetMapping("/read-all")
    public String markAllNotificationsRead(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        notificationService.markAllAsRead(currentUser.getId());
        session.setAttribute("unreadCount", 0);

        return "redirect:/notifications";
    }
}
