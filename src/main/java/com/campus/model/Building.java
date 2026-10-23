package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class representing a Campus Building/Facility.
 */
public class Building implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String code;
    private int floors;
    private String description;
    private boolean active;
    private Timestamp createdAt;

    public Building() {}

    public Building(int id, String name, String code, int floors, String description, boolean active) {
        this.id = id;
        this.name = name;
        this.code = code;
        this.floors = floors;
        this.description = description;
        this.active = active;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public int getFloors() { return floors; }
    public void setFloors(int floors) { this.floors = floors; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
