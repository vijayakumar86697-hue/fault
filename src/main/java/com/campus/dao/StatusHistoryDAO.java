package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.StatusHistory;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring Repository for complaint status history audit logs using JdbcTemplate.
 */
@Repository
public class StatusHistoryDAO {
    private static final Logger LOGGER = Logger.getLogger(StatusHistoryDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<StatusHistory> ROW_MAPPER = (rs, rowNum) -> {
        StatusHistory h = new StatusHistory();
        h.setId(rs.getInt("id"));
        h.setComplaintId(rs.getInt("complaint_id"));
        h.setChangedBy(rs.getInt("changed_by"));
        h.setPreviousStatus(rs.getString("previous_status"));
        h.setNewStatus(rs.getString("new_status"));
        h.setRemarks(rs.getString("remarks"));
        h.setCreatedAt(rs.getTimestamp("created_at"));
        h.setChangedByName(rs.getString("changed_by_name"));
        h.setChangedByRole(rs.getString("changed_by_role"));
        return h;
    };

    public StatusHistoryDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy unit tests.
     */
    public StatusHistoryDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public boolean logHistory(StatusHistory history) {
        String sql = "INSERT INTO complaint_status_history (complaint_id, changed_by, previous_status, new_status, remarks) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try {
            return jdbcTemplate.update(
                sql,
                history.getComplaintId(),
                history.getChangedBy(),
                history.getPreviousStatus(),
                history.getNewStatus(),
                history.getRemarks()
            ) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error logging status history", e);
            return false;
        }
    }

    public List<StatusHistory> findByComplaint(int complaintId) {
        String sql = "SELECT h.*, u.full_name AS changed_by_name, u.role AS changed_by_role " +
                     "FROM complaint_status_history h " +
                     "JOIN users u ON h.changed_by = u.id " +
                     "WHERE h.complaint_id = ? ORDER BY h.created_at ASC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER, complaintId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding status history for complaint " + complaintId, e);
            return Collections.emptyList();
        }
    }
}
