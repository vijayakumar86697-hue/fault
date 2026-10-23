package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing an Infrastructure Fault Complaint.
 */
public class Complaint implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String ticketNumber;
    private int reporterId;
    private int categoryId;
    private int buildingId;
    private String blockFloor;
    private String roomLocation;
    private String title;
    private String description;
    private String priority; // LOW, MEDIUM, HIGH, CRITICAL
    private String status;   // SUBMITTED, UNDER_REVIEW, ASSIGNED, IN_PROGRESS, ON_HOLD, COMPLETED, CLOSED, REJECTED, REOPENED
    private int reopenCount;
    private String reopenReason;
    private String rejectionReason;
    private String onHoldReason;
    private Timestamp submittedAt;
    private Timestamp resolvedAt;
    private Timestamp closedAt;
    private Timestamp updatedAt;

    // Joined presentation fields
    private String reporterName;
    private String reporterEmail;
    private String reporterPhone;
    private String reporterRole;
    private String categoryName;
    private String categoryIcon;
    private String buildingName;
    private String buildingCode;
    private Integer assignedWorkerId;
    private String assignedWorkerName;
    private String assignedWorkerPhone;
    private String assignedWorkerSpecialty;
    private String assignmentInstructions;

    private List<ComplaintAttachment> attachments = new ArrayList<>();
    private List<StatusHistory> statusHistories = new ArrayList<>();
    private List<ComplaintComment> comments = new ArrayList<>();

    public Complaint() {}

    // Badge styling helpers
    public String getStatusBadgeClass() {
        if (status == null) return "bg-secondary";
        return switch (status.toUpperCase()) {
            case "SUBMITTED" -> "bg-secondary";
            case "UNDER_REVIEW" -> "bg-info text-dark";
            case "ASSIGNED" -> "bg-primary";
            case "IN_PROGRESS" -> "bg-warning text-dark";
            case "ON_HOLD" -> "bg-dark text-white";
            case "COMPLETED" -> "bg-success";
            case "CLOSED" -> "bg-secondary";
            case "REJECTED" -> "bg-danger";
            case "REOPENED" -> "bg-danger text-white";
            default -> "bg-secondary";
        };
    }

    public String getPriorityBadgeClass() {
        if (priority == null) return "bg-secondary";
        return switch (priority.toUpperCase()) {
            case "LOW" -> "bg-secondary";
            case "MEDIUM" -> "bg-primary";
            case "HIGH" -> "bg-warning text-dark";
            case "CRITICAL" -> "bg-danger";
            default -> "bg-secondary";
        };
    }

    public boolean canBeReopened() {
        return "COMPLETED".equalsIgnoreCase(status) || "CLOSED".equalsIgnoreCase(status);
    }

    public boolean isClosedOrCompleted() {
        return "CLOSED".equalsIgnoreCase(status) || "COMPLETED".equalsIgnoreCase(status);
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTicketNumber() { return ticketNumber; }
    public void setTicketNumber(String ticketNumber) { this.ticketNumber = ticketNumber; }

    public int getReporterId() { return reporterId; }
    public void setReporterId(int reporterId) { this.reporterId = reporterId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public int getBuildingId() { return buildingId; }
    public void setBuildingId(int buildingId) { this.buildingId = buildingId; }

    public String getBlockFloor() { return blockFloor; }
    public void setBlockFloor(String blockFloor) { this.blockFloor = blockFloor; }

    public String getRoomLocation() { return roomLocation; }
    public void setRoomLocation(String roomLocation) { this.roomLocation = roomLocation; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getReopenCount() { return reopenCount; }
    public void setReopenCount(int reopenCount) { this.reopenCount = reopenCount; }

    public String getReopenReason() { return reopenReason; }
    public void setReopenReason(String reopenReason) { this.reopenReason = reopenReason; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public String getOnHoldReason() { return onHoldReason; }
    public void setOnHoldReason(String onHoldReason) { this.onHoldReason = onHoldReason; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }

    public Timestamp getClosedAt() { return closedAt; }
    public void setClosedAt(Timestamp closedAt) { this.closedAt = closedAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getReporterEmail() { return reporterEmail; }
    public void setReporterEmail(String reporterEmail) { this.reporterEmail = reporterEmail; }

    public String getReporterPhone() { return reporterPhone; }
    public void setReporterPhone(String reporterPhone) { this.reporterPhone = reporterPhone; }

    public String getReporterRole() { return reporterRole; }
    public void setReporterRole(String reporterRole) { this.reporterRole = reporterRole; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getCategoryIcon() { return categoryIcon; }
    public void setCategoryIcon(String categoryIcon) { this.categoryIcon = categoryIcon; }

    public String getBuildingName() { return buildingName; }
    public void setBuildingName(String buildingName) { this.buildingName = buildingName; }

    public String getBuildingCode() { return buildingCode; }
    public void setBuildingCode(String buildingCode) { this.buildingCode = buildingCode; }

    public Integer getAssignedWorkerId() { return assignedWorkerId; }
    public void setAssignedWorkerId(Integer assignedWorkerId) { this.assignedWorkerId = assignedWorkerId; }

    public String getAssignedWorkerName() { return assignedWorkerName; }
    public void setAssignedWorkerName(String assignedWorkerName) { this.assignedWorkerName = assignedWorkerName; }

    public String getAssignedWorkerPhone() { return assignedWorkerPhone; }
    public void setAssignedWorkerPhone(String assignedWorkerPhone) { this.assignedWorkerPhone = assignedWorkerPhone; }

    public String getAssignedWorkerSpecialty() { return assignedWorkerSpecialty; }
    public void setAssignedWorkerSpecialty(String assignedWorkerSpecialty) { this.assignedWorkerSpecialty = assignedWorkerSpecialty; }

    public String getAssignmentInstructions() { return assignmentInstructions; }
    public void setAssignmentInstructions(String assignmentInstructions) { this.assignmentInstructions = assignmentInstructions; }

    public List<ComplaintAttachment> getAttachments() { return attachments; }
    public void setAttachments(List<ComplaintAttachment> attachments) { this.attachments = attachments; }

    public List<StatusHistory> getStatusHistories() { return statusHistories; }
    public void setStatusHistories(List<StatusHistory> statusHistories) { this.statusHistories = statusHistories; }

    public List<ComplaintComment> getComments() { return comments; }
    public void setComments(List<ComplaintComment> comments) { this.comments = comments; }
}
