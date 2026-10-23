package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.Building;
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
 * Spring Repository for Building entities using JdbcTemplate.
 */
@Repository
public class BuildingDAO {
    private static final Logger LOGGER = Logger.getLogger(BuildingDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<Building> ROW_MAPPER = (rs, rowNum) -> {
        Building b = new Building();
        b.setId(rs.getInt("id"));
        b.setName(rs.getString("name"));
        b.setCode(rs.getString("code"));
        b.setFloors(rs.getInt("floors"));
        b.setDescription(rs.getString("description"));
        b.setActive(rs.getBoolean("is_active"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        return b;
    };

    public BuildingDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public BuildingDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public List<Building> findAllActive() {
        String sql = "SELECT * FROM buildings WHERE is_active = TRUE ORDER BY name ASC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching active buildings", e);
            return Collections.emptyList();
        }
    }

    public List<Building> findAll() {
        String sql = "SELECT * FROM buildings ORDER BY name ASC";
        try {
            return jdbcTemplate.query(sql, ROW_MAPPER);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all buildings", e);
            return Collections.emptyList();
        }
    }

    public Building findById(int id) {
        String sql = "SELECT * FROM buildings WHERE id = ?";
        try {
            List<Building> list = jdbcTemplate.query(sql, ROW_MAPPER, id);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding building by id: " + id, e);
            return null;
        }
    }

    public boolean create(Building b) {
        String sql = "INSERT INTO buildings (name, code, floors, description, is_active) VALUES (?, ?, ?, ?, ?)";
        try {
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, b.getName());
                ps.setString(2, b.getCode());
                ps.setInt(3, b.getFloors());
                ps.setString(4, b.getDescription());
                ps.setBoolean(5, b.isActive());
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                b.setId(keyHolder.getKey().intValue());
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error creating building: " + b.getName(), e);
        }
        return false;
    }

    public boolean update(Building b) {
        String sql = "UPDATE buildings SET name = ?, code = ?, floors = ?, description = ?, is_active = ? WHERE id = ?";
        try {
            return jdbcTemplate.update(
                sql,
                b.getName(),
                b.getCode(),
                b.getFloors(),
                b.getDescription(),
                b.isActive(),
                b.getId()
            ) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error updating building id: " + b.getId(), e);
            return false;
        }
    }

    public boolean toggleActive(int id, boolean active) {
        String sql = "UPDATE buildings SET is_active = ? WHERE id = ?";
        try {
            return jdbcTemplate.update(sql, active, id) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error toggling building status", e);
            return false;
        }
    }
}
