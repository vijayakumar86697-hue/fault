package com.campus.config;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceUtils;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Database Connection Manager bridging Spring Boot's DataSource and JdbcTemplate
 * with backwards-compatible connection access for legacy callers.
 */
public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static DataSource dataSource;
    private static JdbcTemplate jdbcTemplate;

    static {
        try {
            Class.forName(AppConfig.getDbDriver());
            LOGGER.fine("MySQL JDBC Driver registered successfully.");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.WARNING, "MySQL JDBC Driver registration note: " + e.getMessage());
        }
    }

    /**
     * Injects Spring Boot's managed DataSource (HikariCP) and initializes JdbcTemplate.
     */
    public static synchronized void setDataSource(DataSource ds) {
        dataSource = ds;
        if (ds != null) {
            jdbcTemplate = new JdbcTemplate(ds);
        }
    }

    public static synchronized DataSource getDataSource() {
        if (dataSource == null) {
            // Fallback for standalone unit tests executing outside Spring Boot application context
            DriverManagerDataSource ds = new DriverManagerDataSource();
            ds.setDriverClassName(AppConfig.getDbDriver());
            ds.setUrl(AppConfig.getDbUrl());
            ds.setUsername(AppConfig.getDbUsername());
            ds.setPassword(AppConfig.getDbPassword());
            dataSource = ds;
            jdbcTemplate = new JdbcTemplate(ds);
        }
        return dataSource;
    }

    public static synchronized JdbcTemplate getJdbcTemplate() {
        if (jdbcTemplate == null) {
            getDataSource();
        }
        return jdbcTemplate;
    }

    private DBConnection() {
        // Prevent instantiation
    }

    /**
     * Obtains a database connection. When Spring's DataSource is active,
     * uses DataSourceUtils to participate in any active Spring @Transactional transaction.
     */
    public static Connection getConnection() throws SQLException {
        DataSource ds = getDataSource();
        if (ds != null) {
            return DataSourceUtils.getConnection(ds);
        }
        throw new SQLException("No DataSource configured");
    }

    /**
     * Safely closes one or more database resources (Connection, Statement, ResultSet).
     */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    if (res instanceof Connection conn && dataSource != null) {
                        DataSourceUtils.releaseConnection(conn, dataSource);
                    } else {
                        res.close();
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.FINE, "Error closing resource: " + e.getMessage());
                }
            }
        }
    }

    /**
     * Verifies if the database server is reachable and active.
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Database ping failed: " + e.getMessage());
            return false;
        }
    }
}
