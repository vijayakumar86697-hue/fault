package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.Notification;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Types;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring Repository for in-app notifications using JdbcTemplate.
 */
@Repository
public class NotificationDAO {
    private static final Logger LOGGER = Logger.getLogger(NotificationDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<Notification> ROW_MAPPER = (rs, rowNum) -> {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        int compId = rs.getInt("complaint_id");
        n.setComplaintId(rs.wasNull() ? null : compId);
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        n.setComplaintTicketNumber(rs.getString("complaint_ticket"));
        return n;
    };

    public NotificationDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public NotificationDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public boolean createNotification(Notification n) {
        String sql = "INSERT INTO notifications (user_id, complaint_id, title, message, type, is_read) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, n.getUserId());
                if (n.getComplaintId() != null) {
                    ps.setInt(2, n.getComplaintId());
                } else {
                    ps.setNull(2, Types.INTEGER);
                }
                ps.setString(3, n.getTitle());
                ps.setString(4, n.getMessage());
                ps.setString(5, n.getType() != null ? n.getType() : "INFO");
                ps.setBoolean(6, n.isRead());
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                n.setId(keyHolder.getKey().intValue());
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error creating notification for user " + n.getUserId(), e);
        }
        return false;
    }

    public List<Notification> findAllByUser(int userId, int limit) {
        String sql = "SELECT n.*, c.ticket_number AS complaint_ticket " +
                     "FROM notifications n " +
                     "LEFT JOIN complaints c ON n.complaint_id = c.id " +
                     "WHERE n.user_id = ? " +
                     "ORDER BY n.created_at DESC LIMIT ?";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER, userId, limit <= 0 ? 50 : limit);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching notifications for user " + userId, e);
            return Collections.emptyList();
        }
    }

    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";
        try {
            Integer count = jdbcTemplate.queryForObject(sql, Integer.class, userId);
            return count != null ? count : 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error counting unread notifications for user " + userId, e);
            return 0;
        }
    }

    public int getUnreadCount(int userId) {
        return countUnread(userId);
    }

    public boolean markAsRead(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?";
        try {
            return jdbcTemplate.update(sql, notificationId, userId) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error marking notification as read", e);
            return false;
        }
    }

    public boolean markAllAsRead(int userId) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ?";
        try {
            return jdbcTemplate.update(sql, userId) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error marking all notifications as read for user " + userId, e);
            return false;
        }
    }
}
