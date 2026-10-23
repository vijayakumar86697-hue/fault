package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.Complaint;
import com.campus.model.Notification;
import com.campus.model.StatusHistory;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.time.Year;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring Repository for Complaints using JdbcTemplate.
 * Handles ticket lifecycle, assignments, filtering, and reporting aggregations.
 */
@Repository
public class ComplaintDAO {
    private static final Logger LOGGER = Logger.getLogger(ComplaintDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;
    private final StatusHistoryDAO historyDAO;
    private final NotificationDAO notificationDAO;

    private static final RowMapper<Complaint> ROW_MAPPER = (rs, rowNum) -> {
        Complaint c = new Complaint();
        c.setId(rs.getInt("id"));
        c.setTicketNumber(rs.getString("ticket_number"));
        c.setReporterId(rs.getInt("reporter_id"));
        c.setCategoryId(rs.getInt("category_id"));
        c.setBuildingId(rs.getInt("building_id"));
        c.setBlockFloor(rs.getString("block_floor"));
        c.setRoomLocation(rs.getString("room_location"));
        c.setTitle(rs.getString("title"));
        c.setDescription(rs.getString("description"));
        c.setPriority(rs.getString("priority"));
        c.setStatus(rs.getString("status"));
        c.setReopenCount(rs.getInt("reopen_count"));
        c.setReopenReason(rs.getString("reopen_reason"));
        c.setRejectionReason(rs.getString("rejection_reason"));
        c.setOnHoldReason(rs.getString("on_hold_reason"));
        c.setSubmittedAt(rs.getTimestamp("submitted_at"));
        c.setResolvedAt(rs.getTimestamp("resolved_at"));
        c.setClosedAt(rs.getTimestamp("closed_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));

        c.setReporterName(rs.getString("reporter_name"));
        c.setReporterEmail(rs.getString("reporter_email"));
        c.setReporterPhone(rs.getString("reporter_phone"));
        c.setReporterRole(rs.getString("reporter_role"));

        c.setCategoryName(rs.getString("category_name"));
        c.setCategoryIcon(rs.getString("category_icon"));

        c.setBuildingName(rs.getString("building_name"));
        c.setBuildingCode(rs.getString("building_code"));

        int workerId = rs.getInt("assigned_worker_id");
        if (!rs.wasNull()) {
            c.setAssignedWorkerId(workerId);
            c.setAssignedWorkerName(rs.getString("assigned_worker_name"));
            c.setAssignedWorkerPhone(rs.getString("assigned_worker_phone"));
            c.setAssignedWorkerSpecialty(rs.getString("assigned_worker_specialty"));
            c.setAssignmentInstructions(rs.getString("assignment_instructions"));
        }

        return c;
    };

    public ComplaintDAO(JdbcTemplate jdbcTemplate, StatusHistoryDAO historyDAO, NotificationDAO notificationDAO) {
        this.jdbcTemplate = jdbcTemplate;
        this.historyDAO = historyDAO;
        this.notificationDAO = notificationDAO;
    }

    /**
     * Fallback constructor for legacy callers and unit tests.
     */
    public ComplaintDAO() {
        this(DBConnection.getJdbcTemplate(), new StatusHistoryDAO(), new NotificationDAO());
    }

    /**
     * Generates a unique complaint ticket number in the format CMP-YYYY-XXXX.
     */
    public synchronized String generateTicketNumber() {
        int currentYear = Year.now().getValue();
        String prefix = "CMP-" + currentYear + "-";
        String sql = "SELECT COUNT(*) FROM complaints WHERE ticket_number LIKE ?";
        try {
            Integer count = jdbcTemplate.queryForObject(sql, Integer.class, prefix + "%");
            int nextIndex = (count != null ? count : 0) + 1;
            return String.format("%s%04d", prefix, nextIndex);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error generating ticket number", e);
            return "CMP-" + currentYear + "-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
        }
    }

    public boolean create(Complaint c) {
        if (c.getTicketNumber() == null || c.getTicketNumber().isBlank()) {
            c.setTicketNumber(generateTicketNumber());
        }

        String sql = "INSERT INTO complaints (ticket_number, reporter_id, category_id, building_id, block_floor, room_location, " +
                     "title, description, priority, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try {
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, c.getTicketNumber());
                ps.setInt(2, c.getReporterId());
                ps.setInt(3, c.getCategoryId());
                ps.setInt(4, c.getBuildingId());
                ps.setString(5, c.getBlockFloor());
                ps.setString(6, c.getRoomLocation());
                ps.setString(7, c.getTitle());
                ps.setString(8, c.getDescription());
                ps.setString(9, c.getPriority() != null ? c.getPriority() : "MEDIUM");
                ps.setString(10, "SUBMITTED");
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                c.setId(keyHolder.getKey().intValue());

                // Log initial status history
                StatusHistory initialHistory = new StatusHistory(
                    c.getId(),
                    c.getReporterId(),
                    null,
                    "SUBMITTED",
                    "Complaint registered successfully."
                );
                historyDAO.logHistory(initialHistory);

                // Create confirmation notification for reporter
                Notification reporterNotif = new Notification(
                    c.getReporterId(),
                    c.getId(),
                    "Complaint Submitted",
                    "Your report '" + c.getTitle() + "' was received. Ticket: " + c.getTicketNumber(),
                    "SUCCESS"
                );
                notificationDAO.createNotification(reporterNotif);

                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error inserting complaint: " + c.getTitle(), e);
        }
        return false;
    }

    public Complaint findById(int id) {
        String sql = baseComplaintQuery() + " WHERE c.id = ?";
        try {
            List<Complaint> list = jdbcTemplate.query(sql, ROW_MAPPER, id);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding complaint by id: " + id, e);
            return null;
        }
    }

    public Complaint findByTicketNumber(String ticketNumber) {
        String sql = baseComplaintQuery() + " WHERE c.ticket_number = ?";
        try {
            List<Complaint> list = jdbcTemplate.query(sql, ROW_MAPPER, ticketNumber.trim());
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding complaint by ticket: " + ticketNumber, e);
            return null;
        }
    }

    public List<Complaint> findByReporter(int reporterId) {
        String sql = baseComplaintQuery() + " WHERE c.reporter_id = ? ORDER BY c.submitted_at DESC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER, reporterId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding complaints by reporter: " + reporterId, e);
            return Collections.emptyList();
        }
    }

    public List<Complaint> findByWorker(int workerId, String statusFilter) {
        StringBuilder sql = new StringBuilder(baseComplaintQuery())
            .append(" WHERE ca.worker_id = ? AND ca.is_active = TRUE ");
        boolean hasStatus = statusFilter != null && !statusFilter.isBlank();
        if (hasStatus) {
            sql.append(" AND c.status = ? ");
        }
        sql.append(" ORDER BY FIELD(c.priority, 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'), c.submitted_at DESC");

        try {
            if (hasStatus) {
                return jdbcTemplate.query(sql.toString(), ROW_MAPPER, workerId, statusFilter.toUpperCase());
            } else {
                return jdbcTemplate.query(sql.toString(), ROW_MAPPER, workerId);
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding complaints for worker: " + workerId, e);
            return Collections.emptyList();
        }
    }

    public List<Complaint> findFiltered(Map<String, Object> filters, int offset, int limit) {
        StringBuilder sql = new StringBuilder(baseComplaintQuery());
        List<Object> params = buildFilterClause(filters, sql);

        sql.append(" ORDER BY c.submitted_at DESC LIMIT ? OFFSET ?");
        params.add(limit <= 0 ? 50 : limit);
        params.add(Math.max(offset, 0));

        try {
            return jdbcTemplate.query(sql.toString(), ROW_MAPPER, params.toArray());
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding filtered complaints", e);
            return Collections.emptyList();
        }
    }

    public int countFiltered(Map<String, Object> filters) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM complaints c " +
            "JOIN users u ON c.reporter_id = u.id " +
            "JOIN fault_categories cat ON c.category_id = cat.id " +
            "JOIN buildings b ON c.building_id = b.id " +
            "LEFT JOIN complaint_assignments ca ON c.id = ca.complaint_id AND ca.is_active = TRUE "
        );
        List<Object> params = buildFilterClause(filters, sql);

        try {
            Integer count = jdbcTemplate.queryForObject(sql.toString(), Integer.class, params.toArray());
            return count != null ? count : 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error counting filtered complaints", e);
            return 0;
        }
    }

    private List<Object> buildFilterClause(Map<String, Object> filters, StringBuilder sql) {
        List<Object> params = new ArrayList<>();
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");

        if (filters != null) {
            if (filters.get("status") != null && !((String) filters.get("status")).isBlank()) {
                where.append(" AND c.status = ?");
                params.add(filters.get("status"));
            }
            if (filters.get("priority") != null && !((String) filters.get("priority")).isBlank()) {
                where.append(" AND c.priority = ?");
                params.add(filters.get("priority"));
            }
            if (filters.get("categoryId") != null) {
                int catId = (Integer) filters.get("categoryId");
                if (catId > 0) {
                    where.append(" AND c.category_id = ?");
                    params.add(catId);
                }
            }
            if (filters.get("buildingId") != null) {
                int bldgId = (Integer) filters.get("buildingId");
                if (bldgId > 0) {
                    where.append(" AND c.building_id = ?");
                    params.add(bldgId);
                }
            }
            if (filters.get("workerId") != null) {
                int wId = (Integer) filters.get("workerId");
                if (wId > 0) {
                    where.append(" AND ca.worker_id = ?");
                    params.add(wId);
                }
            }
            if (filters.get("search") != null && !((String) filters.get("search")).isBlank()) {
                String search = "%" + ((String) filters.get("search")).trim() + "%";
                where.append(" AND (c.ticket_number LIKE ? OR c.title LIKE ? OR c.description LIKE ? OR c.room_location LIKE ? OR u.full_name LIKE ?)");
                params.add(search);
                params.add(search);
                params.add(search);
                params.add(search);
                params.add(search);
            }
            if (filters.get("startDate") != null && !((String) filters.get("startDate")).isBlank()) {
                where.append(" AND DATE(c.submitted_at) >= ?");
                params.add(filters.get("startDate"));
            }
            if (filters.get("endDate") != null && !((String) filters.get("endDate")).isBlank()) {
                where.append(" AND DATE(c.submitted_at) <= ?");
                params.add(filters.get("endDate"));
            }
        }

        sql.append(where);
        return params;
    }

    public boolean updateStatus(int complaintId, String newStatus, String remarks, int changedBy) {
        Complaint complaint = findById(complaintId);
        if (complaint == null) return false;

        String prevStatus = complaint.getStatus();
        StringBuilder sql = new StringBuilder("UPDATE complaints SET status = ? ");
        List<Object> params = new ArrayList<>();
        params.add(newStatus);

        if ("COMPLETED".equalsIgnoreCase(newStatus)) {
            sql.append(", resolved_at = NOW() ");
        } else if ("CLOSED".equalsIgnoreCase(newStatus)) {
            sql.append(", closed_at = NOW() ");
        } else if ("REJECTED".equalsIgnoreCase(newStatus)) {
            sql.append(", rejection_reason = ? ");
            params.add(remarks);
        } else if ("ON_HOLD".equalsIgnoreCase(newStatus)) {
            sql.append(", on_hold_reason = ? ");
            params.add(remarks);
        }
        sql.append(" WHERE id = ?");
        params.add(complaintId);

        try {
            int affected = jdbcTemplate.update(sql.toString(), params.toArray());
            if (affected > 0) {
                // Log history
                StatusHistory history = new StatusHistory(complaintId, changedBy, prevStatus, newStatus, remarks);
                historyDAO.logHistory(history);

                // Notify reporter
                Notification notif = new Notification(
                    complaint.getReporterId(),
                    complaintId,
                    "Ticket Status Updated",
                    "Ticket " + complaint.getTicketNumber() + " status changed from " + prevStatus + " to " + newStatus + ".",
                    "COMPLETED".equalsIgnoreCase(newStatus) ? "SUCCESS" : "INFO"
                );
                notificationDAO.createNotification(notif);

                // If assigned, also notify worker
                if (complaint.getAssignedWorkerId() != null && complaint.getAssignedWorkerId() != changedBy) {
                    Notification workerNotif = new Notification(
                        complaint.getAssignedWorkerId(),
                        complaintId,
                        "Task Status Changed",
                        "Ticket " + complaint.getTicketNumber() + " is now " + newStatus,
                        "INFO"
                    );
                    notificationDAO.createNotification(workerNotif);
                }

                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error updating status for complaint " + complaintId, e);
        }
        return false;
    }

    public boolean updatePriority(int complaintId, String newPriority, int changedBy) {
        Complaint complaint = findById(complaintId);
        if (complaint == null) return false;

        String sql = "UPDATE complaints SET priority = ? WHERE id = ?";
        try {
            int affected = jdbcTemplate.update(sql, newPriority, complaintId);
            if (affected > 0) {
                StatusHistory history = new StatusHistory(
                    complaintId,
                    changedBy,
                    complaint.getPriority(),
                    complaint.getStatus(),
                    "Priority updated to " + newPriority
                );
                historyDAO.logHistory(history);

                Notification notif = new Notification(
                    complaint.getReporterId(),
                    complaintId,
                    "Ticket Priority Adjusted",
                    "The priority of ticket " + complaint.getTicketNumber() + " was set to " + newPriority,
                    "INFO"
                );
                notificationDAO.createNotification(notif);
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error updating priority for complaint " + complaintId, e);
        }
        return false;
    }

    public boolean reopen(int complaintId, String reason, int changedBy) {
        Complaint complaint = findById(complaintId);
        if (complaint == null) return false;

        String sql = "UPDATE complaints SET status = 'REOPENED', reopen_count = reopen_count + 1, " +
                     "reopen_reason = ?, resolved_at = NULL, closed_at = NULL WHERE id = ?";
        try {
            int affected = jdbcTemplate.update(sql, reason, complaintId);
            if (affected > 0) {
                StatusHistory history = new StatusHistory(
                    complaintId,
                    changedBy,
                    complaint.getStatus(),
                    "REOPENED",
                    "User requested reopening. Reason: " + reason
                );
                historyDAO.logHistory(history);

                // Notify admin
                String adminQuery = "SELECT id FROM users WHERE role = 'ADMIN' LIMIT 5";
                List<Integer> adminIds = jdbcTemplate.query(adminQuery, (rs, rowNum) -> rs.getInt("id"));
                for (Integer adminId : adminIds) {
                    Notification adminNotif = new Notification(
                        adminId,
                        complaintId,
                        "Complaint Reopened",
                        "Ticket " + complaint.getTicketNumber() + " was reopened by reporter: " + reason,
                        "DANGER"
                    );
                    notificationDAO.createNotification(adminNotif);
                }

                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error reopening complaint " + complaintId, e);
        }
        return false;
    }

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) AS total, " +
                     "SUM(CASE WHEN status = 'SUBMITTED' THEN 1 ELSE 0 END) AS submitted, " +
                     "SUM(CASE WHEN status = 'UNDER_REVIEW' THEN 1 ELSE 0 END) AS under_review, " +
                     "SUM(CASE WHEN status = 'ASSIGNED' THEN 1 ELSE 0 END) AS assigned, " +
                     "SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress, " +
                     "SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed, " +
                     "SUM(CASE WHEN status = 'CLOSED' THEN 1 ELSE 0 END) AS closed, " +
                     "SUM(CASE WHEN status IN ('SUBMITTED', 'UNDER_REVIEW') THEN 1 ELSE 0 END) AS unassigned, " +
                     "SUM(CASE WHEN priority = 'CRITICAL' AND status NOT IN ('COMPLETED', 'CLOSED', 'REJECTED') THEN 1 ELSE 0 END) AS critical, " +
                     "SUM(CASE WHEN priority = 'HIGH' AND status NOT IN ('COMPLETED', 'CLOSED', 'REJECTED') THEN 1 ELSE 0 END) AS high, " +
                     "AVG(CASE WHEN resolved_at IS NOT NULL THEN TIMESTAMPDIFF(HOUR, submitted_at, resolved_at) ELSE NULL END) AS avg_resolution_hours " +
                     "FROM complaints";

        try {
            return jdbcTemplate.query(sql, rs -> {
                if (rs.next()) {
                    stats.put("total", rs.getInt("total"));
                    stats.put("submitted", rs.getInt("submitted"));
                    stats.put("under_review", rs.getInt("under_review"));
                    stats.put("assigned", rs.getInt("assigned"));
                    stats.put("in_progress", rs.getInt("in_progress"));
                    stats.put("completed", rs.getInt("completed"));
                    stats.put("closed", rs.getInt("closed"));
                    stats.put("unassigned", rs.getInt("unassigned"));
                    stats.put("critical", rs.getInt("critical"));
                    stats.put("high", rs.getInt("high"));
                    double avgHours = rs.getDouble("avg_resolution_hours");
                    stats.put("avg_resolution_hours", Math.round(avgHours * 10.0) / 10.0);
                }
                return stats;
            });
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error computing dashboard statistics", e);
            return stats;
        }
    }

    public Map<String, Object> getUserStats(int userId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) AS total, " +
                     "SUM(CASE WHEN status IN ('SUBMITTED', 'UNDER_REVIEW', 'ASSIGNED') THEN 1 ELSE 0 END) AS pending, " +
                     "SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress, " +
                     "SUM(CASE WHEN status IN ('COMPLETED', 'CLOSED') THEN 1 ELSE 0 END) AS resolved " +
                     "FROM complaints WHERE reporter_id = ?";

        try {
            return jdbcTemplate.query(sql, rs -> {
                if (rs.next()) {
                    stats.put("total", rs.getInt("total"));
                    stats.put("pending", rs.getInt("pending"));
                    stats.put("in_progress", rs.getInt("in_progress"));
                    stats.put("resolved", rs.getInt("resolved"));
                }
                return stats;
            }, userId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching user statistics for user " + userId, e);
            return stats;
        }
    }

    public Map<String, Object> getWorkerStats(int workerId) {
        Map<String, Object> stats = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(*) AS total_assigned, " +
                     "SUM(CASE WHEN c.priority = 'CRITICAL' AND c.status NOT IN ('COMPLETED', 'CLOSED') THEN 1 ELSE 0 END) AS critical_tasks, " +
                     "SUM(CASE WHEN c.status IN ('ASSIGNED', 'IN_PROGRESS', 'ON_HOLD') THEN 1 ELSE 0 END) AS pending_work, " +
                     "SUM(CASE WHEN c.status IN ('COMPLETED', 'CLOSED') THEN 1 ELSE 0 END) AS completed_work " +
                     "FROM complaint_assignments ca " +
                     "JOIN complaints c ON ca.complaint_id = c.id " +
                     "WHERE ca.worker_id = ? AND ca.is_active = TRUE";

        try {
            return jdbcTemplate.query(sql, rs -> {
                if (rs.next()) {
                    stats.put("total_assigned", rs.getInt("total_assigned"));
                    stats.put("critical_tasks", rs.getInt("critical_tasks"));
                    stats.put("pending_work", rs.getInt("pending_work"));
                    stats.put("completed_work", rs.getInt("completed_work"));
                }
                return stats;
            }, workerId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching worker stats for worker " + workerId, e);
            return stats;
        }
    }

    public Map<String, Integer> getCategoryDistribution() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT cat.name, COUNT(c.id) AS count " +
                     "FROM fault_categories cat " +
                     "LEFT JOIN complaints c ON cat.id = c.category_id " +
                     "GROUP BY cat.id, cat.name ORDER BY count DESC";

        try {
            return jdbcTemplate.query(sql, rs -> {
                while (rs.next()) {
                    map.put(rs.getString("name"), rs.getInt("count"));
                }
                return map;
            });
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching category distribution", e);
            return map;
        }
    }

    public Map<String, Integer> getLocationDistribution() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT b.name, COUNT(c.id) AS count " +
                     "FROM buildings b " +
                     "LEFT JOIN complaints c ON b.id = c.building_id " +
                     "GROUP BY b.id, b.name ORDER BY count DESC";

        try {
            return jdbcTemplate.query(sql, rs -> {
                while (rs.next()) {
                    map.put(rs.getString("name"), rs.getInt("count"));
                }
                return map;
            });
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching location distribution", e);
            return map;
        }
    }

    private String baseComplaintQuery() {
        return "SELECT c.*, " +
               "u.full_name AS reporter_name, u.email AS reporter_email, u.phone AS reporter_phone, u.role AS reporter_role, " +
               "cat.name AS category_name, cat.icon AS category_icon, " +
               "b.name AS building_name, b.code AS building_code, " +
               "w.id AS assigned_worker_id, w.full_name AS assigned_worker_name, w.phone AS assigned_worker_phone, " +
               "w.worker_specialty AS assigned_worker_specialty, ca.instructions AS assignment_instructions " +
               "FROM complaints c " +
               "JOIN users u ON c.reporter_id = u.id " +
               "JOIN fault_categories cat ON c.category_id = cat.id " +
               "JOIN buildings b ON c.building_id = b.id " +
               "LEFT JOIN complaint_assignments ca ON c.id = ca.complaint_id AND ca.is_active = TRUE " +
               "LEFT JOIN users w ON ca.worker_id = w.id ";
    }
}
