package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class representing a Fault Category.
 */
public class FaultCategory implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String icon;
    private String description;
    private String defaultPriority; // LOW, MEDIUM, HIGH, CRITICAL
    private boolean active;
    private Timestamp createdAt;

    public FaultCategory() {}

    public FaultCategory(int id, String name, String icon, String description, String defaultPriority, boolean active) {
        this.id = id;
        this.name = name;
        this.icon = icon;
        this.description = description;
        this.defaultPriority = defaultPriority;
        this.active = active;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDefaultPriority() { return defaultPriority; }
    public void setDefaultPriority(String defaultPriority) { this.defaultPriority = defaultPriority; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
