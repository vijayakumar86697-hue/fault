package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.FaultCategory;
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
 * Spring Repository for FaultCategory entities using JdbcTemplate.
 */
@Repository
public class CategoryDAO {
    private static final Logger LOGGER = Logger.getLogger(CategoryDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<FaultCategory> ROW_MAPPER = (rs, rowNum) -> {
        FaultCategory c = new FaultCategory();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setIcon(rs.getString("icon"));
        c.setDescription(rs.getString("description"));
        c.setDefaultPriority(rs.getString("default_priority"));
        c.setActive(rs.getBoolean("is_active"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    };

    public CategoryDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public CategoryDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public List<FaultCategory> findAllActive() {
        String sql = "SELECT * FROM fault_categories WHERE is_active = TRUE ORDER BY name ASC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching active categories", e);
            return Collections.emptyList();
        }
    }

    public List<FaultCategory> findAll() {
        String sql = "SELECT * FROM fault_categories ORDER BY name ASC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all categories", e);
            return Collections.emptyList();
        }
    }

    public FaultCategory findById(int id) {
        String sql = "SELECT * FROM fault_categories WHERE id = ?";
        try {
            List<FaultCategory> list = jdbcTemplate.query(sql, ROW_MAPPER, id);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding category by id: " + id, e);
            return null;
        }
    }

    public boolean create(FaultCategory c) {
        String sql = "INSERT INTO fault_categories (name, icon, description, default_priority, is_active) VALUES (?, ?, ?, ?, ?)";
        try {
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, c.getName());
                ps.setString(2, c.getIcon() != null ? c.getIcon() : "bi-tools");
                ps.setString(3, c.getDescription());
                ps.setString(4, c.getDefaultPriority() != null ? c.getDefaultPriority() : "MEDIUM");
                ps.setBoolean(5, c.isActive());
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                c.setId(keyHolder.getKey().intValue());
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error creating category: " + c.getName(), e);
        }
        return false;
    }

    public boolean update(FaultCategory c) {
        String sql = "UPDATE fault_categories SET name = ?, icon = ?, description = ?, default_priority = ?, is_active = ? WHERE id = ?";
        try {
            return jdbcTemplate.update(
                sql,
                c.getName(),
                c.getIcon(),
                c.getDescription(),
                c.getDefaultPriority(),
                c.isActive(),
                c.getId()
            ) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error updating category id: " + c.getId(), e);
            return false;
        }
    }

    public boolean toggleActive(int id, boolean active) {
        String sql = "UPDATE fault_categories SET is_active = ? WHERE id = ?";
        try {
            return jdbcTemplate.update(sql, active, id) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error toggling category status", e);
            return false;
        }
    }
}
