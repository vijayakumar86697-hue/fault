package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.ComplaintAssignment;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring Repository for complaint assignments using JdbcTemplate.
 */
@Repository
public class AssignmentDAO {
    private static final Logger LOGGER = Logger.getLogger(AssignmentDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<ComplaintAssignment> ROW_MAPPER = (rs, rowNum) -> {
        ComplaintAssignment a = new ComplaintAssignment();
        a.setId(rs.getInt("id"));
        a.setComplaintId(rs.getInt("complaint_id"));
        a.setWorkerId(rs.getInt("worker_id"));
        a.setAssignedBy(rs.getInt("assigned_by"));
        a.setAssignedAt(rs.getTimestamp("assigned_at"));
        a.setInstructions(rs.getString("instructions"));
        a.setExpectedCompletion(rs.getDate("expected_completion"));
        a.setActive(rs.getBoolean("is_active"));
        a.setWorkerName(rs.getString("worker_name"));
        a.setWorkerEmail(rs.getString("worker_email"));
        a.setWorkerPhone(rs.getString("worker_phone"));
        a.setWorkerSpecialty(rs.getString("worker_specialty"));
        a.setAssignerName(rs.getString("assigner_name"));
        return a;
    };

    public AssignmentDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public AssignmentDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    @Transactional
    public boolean assignWorker(int complaintId, int workerId, int assignedBy, String instructions, Date expectedDate) {
        String deactivateOldSql = "UPDATE complaint_assignments SET is_active = FALSE WHERE complaint_id = ?";
        String insertSql = "INSERT INTO complaint_assignments (complaint_id, worker_id, assigned_by, instructions, expected_completion, is_active) " +
                           "VALUES (?, ?, ?, ?, ?, TRUE)";

        try {
            jdbcTemplate.update(deactivateOldSql, complaintId);
            jdbcTemplate.update(insertSql, complaintId, workerId, assignedBy, instructions, expectedDate);
            return true;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error assigning worker to complaint " + complaintId, e);
            throw e;
        }
    }

    public ComplaintAssignment findActiveByComplaint(int complaintId) {
        String sql = "SELECT ca.*, u.full_name AS worker_name, u.email AS worker_email, u.phone AS worker_phone, " +
                     "u.worker_specialty, admin.full_name AS assigner_name " +
                     "FROM complaint_assignments ca " +
                     "JOIN users u ON ca.worker_id = u.id " +
                     "JOIN users admin ON ca.assigned_by = admin.id " +
                     "WHERE ca.complaint_id = ? AND ca.is_active = TRUE " +
                     "LIMIT 1";

        try {
            List<ComplaintAssignment> list = jdbcTemplate.query(sql, ROW_MAPPER, complaintId);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding active assignment for complaint " + complaintId, e);
            return null;
        }
    }

    public List<ComplaintAssignment> findHistoryByComplaint(int complaintId) {
        String sql = "SELECT ca.*, u.full_name AS worker_name, u.email AS worker_email, u.phone AS worker_phone, " +
                     "u.worker_specialty, admin.full_name AS assigner_name " +
                     "FROM complaint_assignments ca " +
                     "JOIN users u ON ca.worker_id = u.id " +
                     "JOIN users admin ON ca.assigned_by = admin.id " +
                     "WHERE ca.complaint_id = ? ORDER BY ca.assigned_at DESC";

        try {
            return jdbcTemplate.query(sql, ROW_MAPPER, complaintId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding assignment history for complaint " + complaintId, e);
            return Collections.emptyList();
        }
    }
}
