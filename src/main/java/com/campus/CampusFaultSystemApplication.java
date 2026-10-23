package com.campus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * Main entry point for the Campus Infrastructure Fault Reporting System (Spring Boot Edition).
 * Extends SpringBootServletInitializer to support both standalone 'mvn spring-boot:run'
 * and traditional WAR deployments to external Apache Tomcat servers.
 */
@SpringBootApplication
public class CampusFaultSystemApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {
        return builder.sources(CampusFaultSystemApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(CampusFaultSystemApplication.class, args);
    }
}
