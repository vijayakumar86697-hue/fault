package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class for in-app alerts and notifications.
 */
public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private Integer complaintId;
    private String title;
    private String message;
    private String type; // INFO, SUCCESS, WARNING, DANGER
    private boolean read;
    private Timestamp createdAt;

    // Joined ticket number if available
    private String complaintTicketNumber;

    public Notification() {}

    public Notification(int userId, Integer complaintId, String title, String message, String type) {
        this.userId = userId;
        this.complaintId = complaintId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.read = false;
    }

    public String getBadgeClass() {
        if (type == null) return "bg-info";
        return switch (type.toUpperCase()) {
            case "SUCCESS" -> "bg-success";
            case "WARNING" -> "bg-warning text-dark";
            case "DANGER" -> "bg-danger";
            default -> "bg-primary";
        };
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Integer getComplaintId() { return complaintId; }
    public void setComplaintId(Integer complaintId) { this.complaintId = complaintId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getComplaintTicketNumber() { return complaintTicketNumber; }
    public void setComplaintTicketNumber(String complaintTicketNumber) { this.complaintTicketNumber = complaintTicketNumber; }
}
