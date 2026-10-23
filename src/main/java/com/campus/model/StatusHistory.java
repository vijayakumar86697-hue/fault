package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Audit log recording complaint state transitions.
 */
public class StatusHistory implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int complaintId;
    private int changedBy;
    private String previousStatus;
    private String newStatus;
    private String remarks;
    private Timestamp createdAt;

    // Joined presentation fields
    private String changedByName;
    private String changedByRole;

    public StatusHistory() {}

    public StatusHistory(int complaintId, int changedBy, String previousStatus, String newStatus, String remarks) {
        this.complaintId = complaintId;
        this.changedBy = changedBy;
        this.previousStatus = previousStatus;
        this.newStatus = newStatus;
        this.remarks = remarks;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getComplaintId() { return complaintId; }
    public void setComplaintId(int complaintId) { this.complaintId = complaintId; }

    public int getChangedBy() { return changedBy; }
    public void setChangedBy(int changedBy) { this.changedBy = changedBy; }

    public String getPreviousStatus() { return previousStatus; }
    public void setPreviousStatus(String previousStatus) { this.previousStatus = previousStatus; }

    public String getNewStatus() { return newStatus; }
    public void setNewStatus(String newStatus) { this.newStatus = newStatus; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getChangedByName() { return changedByName; }
    public void setChangedByName(String changedByName) { this.changedByName = changedByName; }

    public String getChangedByRole() { return changedByRole; }
    public void setChangedByRole(String changedByRole) { this.changedByRole = changedByRole; }
}
