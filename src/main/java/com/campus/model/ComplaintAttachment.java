package com.campus.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class for fault photographs and repair evidence attachments.
 */
public class ComplaintAttachment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int complaintId;
    private int uploadedBy;
    private String attachmentType; // BEFORE_REPAIR, AFTER_REPAIR, DOCUMENT
    private String originalName;
    private String storedName;
    private String filePath;
    private long fileSize;
    private String mimeType;
    private Timestamp uploadedAt;

    // Joined presentation field
    private String uploadedByName;

    public ComplaintAttachment() {}

    public ComplaintAttachment(int complaintId, int uploadedBy, String attachmentType, String originalName, 
                               String storedName, String filePath, long fileSize, String mimeType) {
        this.complaintId = complaintId;
        this.uploadedBy = uploadedBy;
        this.attachmentType = attachmentType;
        this.originalName = originalName;
        this.storedName = storedName;
        this.filePath = filePath;
        this.fileSize = fileSize;
        this.mimeType = mimeType;
    }

    public boolean isImage() {
        return mimeType != null && mimeType.startsWith("image/");
    }

    public String getFormattedSize() {
        if (fileSize < 1024) return fileSize + " B";
        if (fileSize < 1024 * 1024) return String.format("%.1f KB", fileSize / 1024.0);
        return String.format("%.2f MB", fileSize / (1024.0 * 1024.0));
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getComplaintId() { return complaintId; }
    public void setComplaintId(int complaintId) { this.complaintId = complaintId; }

    public int getUploadedBy() { return uploadedBy; }
    public void setUploadedBy(int uploadedBy) { this.uploadedBy = uploadedBy; }

    public String getAttachmentType() { return attachmentType; }
    public void setAttachmentType(String attachmentType) { this.attachmentType = attachmentType; }

    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }

    public String getStoredName() { return storedName; }
    public void setStoredName(String storedName) { this.storedName = storedName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }

    public String getMimeType() { return mimeType; }
    public void setMimeType(String mimeType) { this.mimeType = mimeType; }

    public Timestamp getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(Timestamp uploadedAt) { this.uploadedAt = uploadedAt; }

    public String getUploadedByName() { return uploadedByName; }
    public void setUploadedByName(String uploadedByName) { this.uploadedByName = uploadedByName; }
}
