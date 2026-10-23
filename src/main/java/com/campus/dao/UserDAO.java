package com.campus.dao;

import com.campus.config.DBConnection;
import com.campus.model.User;
import com.campus.util.PasswordUtil;
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
 * Spring Repository for User entities using JdbcTemplate.
 */
@Repository
public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<User> ROW_MAPPER = (rs, rowNum) -> {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setDepartment(rs.getString("department"));
        u.setWorkerSpecialty(rs.getString("worker_specialty"));
        u.setStatus(rs.getString("status"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        u.setUpdatedAt(rs.getTimestamp("updated_at"));
        return u;
    };

    public UserDAO(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Fallback constructor for legacy callers.
     */
    public UserDAO() {
        this(DBConnection.getJdbcTemplate());
    }

    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try {
            List<User> list = jdbcTemplate.query(sql, ROW_MAPPER, username);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by username: " + username, e);
            return null;
        }
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try {
            List<User> list = jdbcTemplate.query(sql, ROW_MAPPER, email);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by email: " + email, e);
            return null;
        }
    }

    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try {
            List<User> list = jdbcTemplate.query(sql, ROW_MAPPER, id);
            return list.isEmpty() ? null : list.get(0);
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by id: " + id, e);
            return null;
        }
    }

    public boolean register(User user, String plainPassword) {
        String sql = "INSERT INTO users (username, password_hash, full_name, email, phone, role, department, worker_specialty, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try {
            String hashed = PasswordUtil.hashPassword(plainPassword);
            KeyHolder keyHolder = new GeneratedKeyHolder();
            int affected = jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, user.getUsername());
                ps.setString(2, hashed);
                ps.setString(3, user.getFullName());
                ps.setString(4, user.getEmail());
                ps.setString(5, user.getPhone());
                ps.setString(6, user.getRole() != null ? user.getRole().toUpperCase() : "STUDENT");
                ps.setString(7, user.getDepartment());
                ps.setString(8, user.getWorkerSpecialty());
                ps.setString(9, user.getStatus() != null ? user.getStatus() : "ACTIVE");
                return ps;
            }, keyHolder);

            if (affected > 0 && keyHolder.getKey() != null) {
                user.setId(keyHolder.getKey().intValue());
                return true;
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error registering user: " + user.getUsername(), e);
        }
        return false;
    }

    public User authenticate(String usernameOrEmail, String plainPassword) {
        String sql = "SELECT * FROM users WHERE (username = ? OR email = ?) AND status = 'ACTIVE'";
        try {
            List<User> list = jdbcTemplate.query(sql, ROW_MAPPER, usernameOrEmail, usernameOrEmail);
            for (User u : list) {
                if (PasswordUtil.checkPassword(plainPassword, u.getPasswordHash())) {
                    return u;
                }
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error authenticating user: " + usernameOrEmail, e);
        }
        return null;
    }

    public List<User> findAll(String roleFilter) {
        StringBuilder sql = new StringBuilder("SELECT * FROM users ");
        boolean hasFilter = roleFilter != null && !roleFilter.isBlank();
        if (hasFilter) {
            sql.append("WHERE role = ? ");
        }
        sql.append("ORDER BY full_name ASC");

        try {
            if (hasFilter) {
                return jdbcTemplate.query(sql.toString(), ROW_MAPPER, roleFilter.toUpperCase());
            } else {
                return jdbcTemplate.query(sql.toString(), ROW_MAPPER);
            }
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error fetching users list", e);
            return Collections.emptyList();
        }
    }

    public List<User> findAllWorkers() {
        return findAll("WORKER");
    }

    public boolean updateStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try {
            return jdbcTemplate.update(sql, status, userId) > 0;
        } catch (DataAccessException e) {
            LOGGER.log(Level.SEVERE, "Error updating status for user " + userId, e);
            return false;
        }
    }
}
