package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class for feedback, status discussions, and maintenance notes.
 */
public class ComplaintComment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int complaintId;
    private int userId;
    private String commentText;
    private boolean internal;
    private Timestamp createdAt;

    // Joined presentation fields
    private String userName;
    private String userRole;

    public ComplaintComment() {}

    public ComplaintComment(int complaintId, int userId, String commentText, boolean internal) {
        this.complaintId = complaintId;
        this.userId = userId;
        this.commentText = commentText;
        this.internal = internal;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getComplaintId() { return complaintId; }
    public void setComplaintId(int complaintId) { this.complaintId = complaintId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }

    public boolean isInternal() { return internal; }
    public void setInternal(boolean internal) { this.internal = internal; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
}
