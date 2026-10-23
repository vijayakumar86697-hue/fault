package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.ComplaintAttachment;
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
 * Spring Repository for complaint photographs and file attachments using JdbcTemplate.
 */
@Repository
public class AttachmentDAO {
    private static final Logger LOGGER = Logger.getLogger(AttachmentDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<ComplaintAttachment> ROW_MAPPER = (rs, rowNum) -> {
        ComplaintAttachment a = new ComplaintAttachment();
        a.setId(rs.getInt("id"));
        a.setComplaintId(rs.getInt("complaint_id"));
        a.setUploadedBy(rs.getInt("uploaded_by"));
        a.setAttachmentType(rs.getString("attachment_type"));
        a.setOriginalName(rs.getString("original_name"));
        a.setStoredName(rs.getString("stored_name"));
        a.setFilePath(rs.getString("file_path"));
        a.setFileSize(rs.getLong("file_size"));
        a.setMimeType(rs.getString("mime_type"));
        a.setUploadedAt(rs.getTimestamp("uploaded_at"));
        a.setUploadedByName(rs.getString("uploaded_by_name"));
        return a;
    };

    public AttachmentDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public AttachmentDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public boolean addAttachment(ComplaintAttachment att) {
        String sql = "INSERT INTO complaint_attachments (complaint_id, uploaded_by, attachment_type, original_name, stored_name, file_path, file_size, mime_type) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, att.getComplaintId());
                ps.setInt(2, att.getUploadedBy());
                ps.setString(3, att.getAttachmentType() != null ? att.getAttachmentType() : "BEFORE_REPAIR");
                ps.setString(4, att.getOriginalName());
                ps.setString(5, att.getStoredName());
                ps.setString(6, att.getFilePath());
                ps.setLong(7, att.getFileSize());
                ps.setString(8, att.getMimeType());
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                att.setId(keyHolder.getKey().intValue());
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error inserting attachment", e);
        }
        return false;
    }

    public List<ComplaintAttachment> findByComplaint(int complaintId) {
        String sql = "SELECT a.*, u.full_name AS uploaded_by_name " +
                     "FROM complaint_attachments a " +
                     "JOIN users u ON a.uploaded_by = u.id " +
                     "WHERE a.complaint_id = ? ORDER BY a.uploaded_at ASC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER, complaintId);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching attachments for complaint " + complaintId, e);
            return Collections.emptyList();
        }
    }

    public ComplaintAttachment findById(int id) {
        String sql = "SELECT a.*, u.full_name AS uploaded_by_name " +
                     "FROM complaint_attachments a " +
                     "JOIN users u ON a.uploaded_by = u.id " +
                     "WHERE a.id = ?";
        try {
            List<ComplaintAttachment> list = jdbcTemplate.query(sql, ROW_MAPPER, id);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding attachment id: " + id, e);
            return null;
        }
    }
}
