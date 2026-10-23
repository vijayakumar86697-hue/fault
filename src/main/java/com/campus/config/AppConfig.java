package com.campus.config;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring-managed application configuration component with backwards-compatible static getters.
 * Reads properties from application.properties / Spring Environment with fallback to db.properties.
 */
@Component
public class AppConfig {
    private static final Logger LOGGER = Logger.getLogger(AppConfig.class.getName());
    private static final Properties fallbackProperties = new Properties();
    private static AppConfig instance;

    @Value("${spring.datasource.driver-class-name:com.mysql.cj.jdbc.Driver}")
    private String dbDriver;

    @Value("${spring.datasource.url:jdbc:mysql://localhost:3306/campus_fault_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8}")
    private String dbUrl;

    @Value("${spring.datasource.username:root}")
    private String dbUsername;

    @Value("${spring.datasource.password:root}")
    private String dbPassword;

    @Value("${upload.directory:uploads}")
    private String uploadDirectory;

    @Value("${upload.maxFileSize:10485760}")
    private long maxFileSize;

    static {
        loadFallbackProperties();
    }

    @PostConstruct
    public void init() {
        instance = this;
        LOGGER.info("AppConfig initialized as Spring Component.");
    }

    private static void loadFallbackProperties() {
        try (InputStream input = AppConfig.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                fallbackProperties.load(input);
            }
        } catch (Exception ex) {
            LOGGER.log(Level.FINE, "db.properties fallback notice: " + ex.getMessage());
        }
    }

    public static String getProperty(String key, String defaultValue) {
        String sysProp = System.getProperty(key);
        if (sysProp != null && !sysProp.isBlank()) {
            return sysProp;
        }

        String envKey = key.toUpperCase().replace('.', '_');
        String envVal = System.getenv(envKey);
        if (envVal != null && !envVal.isBlank()) {
            return envVal;
        }

        return fallbackProperties.getProperty(key, defaultValue);
    }

    public static String getDbDriver() {
        if (instance != null && instance.dbDriver != null) return instance.dbDriver;
        return getProperty("db.driver", "com.mysql.cj.jdbc.Driver");
    }

    public static String getDbUrl() {
        if (instance != null && instance.dbUrl != null) return instance.dbUrl;
        return getProperty("db.url", "jdbc:mysql://localhost:3306/campus_fault_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8");
    }

    public static String getDbUsername() {
        if (instance != null && instance.dbUsername != null) return instance.dbUsername;
        return getProperty("db.username", "root");
    }

    public static String getDbPassword() {
        if (instance != null && instance.dbPassword != null) return instance.dbPassword;
        return getProperty("db.password", "root");
    }

    public static String getUploadDirectory() {
        if (instance != null && instance.uploadDirectory != null) return instance.uploadDirectory;
        return getProperty("upload.directory", "uploads");
    }

    public static long getMaxFileSize() {
        if (instance != null && instance.maxFileSize > 0) return instance.maxFileSize;
        try {
            return Long.parseLong(getProperty("upload.maxFileSize", "10485760"));
        } catch (NumberFormatException e) {
            return 10485760L; // 10MB
        }
    }
}
