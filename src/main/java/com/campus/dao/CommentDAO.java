package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.ComplaintComment;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring Repository for complaint discussions and notes using JdbcTemplate.
 */
@Repository
public class CommentDAO {
    private static final Logger LOGGER = Logger.getLogger(CommentDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<ComplaintComment> ROW_MAPPER = (rs, rowNum) -> {
        ComplaintComment c = new ComplaintComment();
        c.setId(rs.getInt("id"));
        c.setComplaintId(rs.getInt("complaint_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setCommentText(rs.getString("comment_text"));
        c.setInternal(rs.getBoolean("is_internal"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUserName(rs.getString("user_name"));
        c.setUserRole(rs.getString("user_role"));
        return c;
    };

    public CommentDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public CommentDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public boolean addComment(ComplaintComment comment) {
        String sql = "INSERT INTO complaint_comments (complaint_id, user_id, comment_text, is_internal) VALUES (?, ?, ?, ?)";
        try {
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, comment.getComplaintId());
                ps.setInt(2, comment.getUserId());
                ps.setString(3, comment.getCommentText());
                ps.setBoolean(4, comment.isInternal());
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                comment.setId(keyHolder.getKey().intValue());
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error adding comment to complaint " + comment.getComplaintId(), e);
        }
        return false;
    }

    public List<ComplaintComment> findByComplaint(int complaintId, boolean includeInternal) {
        StringBuilder sql = new StringBuilder(
            "SELECT c.*, u.full_name AS user_name, u.role AS user_role " +
            "FROM complaint_comments c " +
            "JOIN users u ON c.user_id = u.id " +
            "WHERE c.complaint_id = ? "
        );
        if (!includeInternal) {
            sql.append("AND c.is_internal = FALSE ");
        }
        sql.append("ORDER BY c.created_at ASC");

        try {
            return jdbcTemplate.query(sql.toString(), ROW_MAPPER, complaintId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching comments for complaint " + complaintId, e);
            return Collections.emptyList();
        }
    }
}
