package com.campus.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model class representing a maintenance task assignment.
 */
public class ComplaintAssignment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int complaintId;
    private int workerId;
    private int assignedBy;
    private Timestamp assignedAt;
    private String instructions;
    private Date expectedCompletion;
    private boolean active;

    // Joined presentation fields
    private String workerName;
    private String workerEmail;
    private String workerPhone;
    private String workerSpecialty;
    private String assignerName;

    public ComplaintAssignment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getComplaintId() { return complaintId; }
    public void setComplaintId(int complaintId) { this.complaintId = complaintId; }

    public int getWorkerId() { return workerId; }
    public void setWorkerId(int workerId) { this.workerId = workerId; }

    public int getAssignedBy() { return assignedBy; }
    public void setAssignedBy(int assignedBy) { this.assignedBy = assignedBy; }

    public Timestamp getAssignedAt() { return assignedAt; }
    public void setAssignedAt(Timestamp assignedAt) { this.assignedAt = assignedAt; }

    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }

    public Date getExpectedCompletion() { return expectedCompletion; }
    public void setExpectedCompletion(Date expectedCompletion) { this.expectedCompletion = expectedCompletion; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getWorkerName() { return workerName; }
    public void setWorkerName(String workerName) { this.workerName = workerName; }

    public String getWorkerEmail() { return workerEmail; }
    public void setWorkerEmail(String workerEmail) { this.workerEmail = workerEmail; }

    public String getWorkerPhone() { return workerPhone; }
    public void setWorkerPhone(String workerPhone) { this.workerPhone = workerPhone; }

    public String getWorkerSpecialty() { return workerSpecialty; }
    public void setWorkerSpecialty(String workerSpecialty) { this.workerSpecialty = workerSpecialty; }

    public String getAssignerName() { return assignerName; }
    public void setAssignerName(String assignerName) { this.assignerName = assignerName; }
}
