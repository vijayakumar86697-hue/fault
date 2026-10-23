package com.campus.service;

import com.campus.dao.NotificationDAO;
import com.campus.model.Notification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Spring Service managing notification lifecycle, alerts, and unread counts.
 */
@Service
public class NotificationService {

    private final NotificationDAO notificationDAO;

    public NotificationService(NotificationDAO notificationDAO) {
        this.notificationDAO = notificationDAO;
    }

    public List<Notification> getNotificationsForUser(int userId, int limit) {
        return notificationDAO.findAllByUser(userId, limit);
    }

    public int getUnreadCount(int userId) {
        return notificationDAO.getUnreadCount(userId);
    }

    @Transactional
    public boolean markAsRead(int notificationId, int userId) {
        return notificationDAO.markAsRead(notificationId, userId);
    }

    @Transactional
    public boolean markAllAsRead(int userId) {
        return notificationDAO.markAllAsRead(userId);
    }

    @Transactional
    public boolean createNotification(Notification notification) {
        return notificationDAO.createNotification(notification);
    }
}
