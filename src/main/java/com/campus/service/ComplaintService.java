package com.campus.service;

import com.campus.dao.*;
import com.campus.model.*;
import com.campus.util.FileUploadUtil;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Spring Service managing transactional complaint workflows, ticket progression,
 * dispatching, and evidence management.
 */
@Service
public class ComplaintService {
    private static final Logger LOGGER = Logger.getLogger(ComplaintService.class.getName());

    private final ComplaintDAO complaintDAO;
    private final AssignmentDAO assignmentDAO;
    private final AttachmentDAO attachmentDAO;
    private final StatusHistoryDAO historyDAO;
    private final CommentDAO commentDAO;
    private final NotificationDAO notificationDAO;

    public ComplaintService(ComplaintDAO complaintDAO,
                            AssignmentDAO assignmentDAO,
                            AttachmentDAO attachmentDAO,
                            StatusHistoryDAO historyDAO,
                            CommentDAO commentDAO,
                            NotificationDAO notificationDAO) {
        this.complaintDAO = complaintDAO;
        this.assignmentDAO = assignmentDAO;
        this.attachmentDAO = attachmentDAO;
        this.historyDAO = historyDAO;
        this.commentDAO = commentDAO;
        this.notificationDAO = notificationDAO;
    }

    @Transactional
    public boolean submitComplaint(Complaint complaint, MultipartFile photo, String uploadDir) {
        boolean created = complaintDAO.create(complaint);
        if (!created) {
            return false;
        }

        // Process initial evidence photo if provided
        if (photo != null && !photo.isEmpty()) {
            try {
                FileUploadUtil.UploadResult upload = FileUploadUtil.saveMultipartFile(photo, uploadDir);
                ComplaintAttachment att = new ComplaintAttachment(
                    complaint.getId(),
                    complaint.getReporterId(),
                    "BEFORE_REPAIR",
                    upload.getOriginalName(),
                    upload.getStoredName(),
                    "uploads/" + upload.getStoredName(),
                    upload.getSize(),
                    upload.getMimeType()
                );
                attachmentDAO.addAttachment(att);
            } catch (IOException e) {
                LOGGER.log(Level.WARNING, "Failed to upload photo for complaint: " + complaint.getTicketNumber(), e);
            }
        }
        return true;
    }

    @Transactional
    public boolean assignWorker(int complaintId, int workerId, int assignedBy, String instructions, Date expectedDate) {
        Complaint complaint = complaintDAO.findById(complaintId);
        if (complaint == null) return false;

        // 1. Assign worker record
        boolean assigned = assignmentDAO.assignWorker(complaintId, workerId, assignedBy, instructions, expectedDate);
        if (!assigned) return false;

        // 2. Advance status to ASSIGNED if currently SUBMITTED or UNDER_REVIEW
        if ("SUBMITTED".equalsIgnoreCase(complaint.getStatus()) || "UNDER_REVIEW".equalsIgnoreCase(complaint.getStatus())) {
            complaintDAO.updateStatus(complaintId, "ASSIGNED", "Assigned to maintenance technician.", assignedBy);
        }

        // 3. Notify assigned worker
        Notification workerNotif = new Notification(
            workerId,
            complaintId,
            "New Work Assignment",
            "You have been assigned to ticket " + complaint.getTicketNumber() + ": " + complaint.getTitle(),
            "INFO"
        );
        notificationDAO.createNotification(workerNotif);

        return true;
    }

    @Transactional
    public boolean updateStatus(int complaintId, String newStatus, String remarks, int changedBy) {
        return complaintDAO.updateStatus(complaintId, newStatus, remarks, changedBy);
    }

    @Transactional
    public boolean updatePriority(int complaintId, String newPriority, int changedBy) {
        return complaintDAO.updatePriority(complaintId, newPriority, changedBy);
    }

    @Transactional
    public boolean reopenComplaint(int complaintId, String reason, int changedBy) {
        return complaintDAO.reopen(complaintId, reason, changedBy);
    }

    @Transactional
    public boolean addComment(ComplaintComment comment) {
        return commentDAO.addComment(comment);
    }

    @Transactional
    public boolean completeTask(int complaintId, int workerId, String remarks, MultipartFile afterPhoto, String uploadDir) {
        Complaint complaint = complaintDAO.findById(complaintId);
        if (complaint == null) return false;

        // 1. Upload resolution evidence photo if present
        if (afterPhoto != null && !afterPhoto.isEmpty()) {
            try {
                FileUploadUtil.UploadResult upload = FileUploadUtil.saveMultipartFile(afterPhoto, uploadDir);
                ComplaintAttachment attachment = new ComplaintAttachment(
                    complaintId,
                    workerId,
                    "AFTER_REPAIR",
                    upload.getOriginalName(),
                    upload.getStoredName(),
                    "uploads/" + upload.getStoredName(),
                    upload.getSize(),
                    upload.getMimeType()
                );
                attachmentDAO.addAttachment(attachment);
            } catch (IOException e) {
                LOGGER.log(Level.WARNING, "Failed to upload repair proof for complaint: " + complaintId, e);
            }
        }

        // 2. Add completion comment if remarks supplied
        if (remarks != null && !remarks.isBlank()) {
            ComplaintComment comment = new ComplaintComment(complaintId, workerId, remarks.trim(), false);
            commentDAO.addComment(comment);
        }

        // 3. Update status to COMPLETED
        return complaintDAO.updateStatus(complaintId, "COMPLETED", remarks, workerId);
    }

    public Complaint getComplaintWithDetails(int id, boolean includeInternalComments) {
        Complaint complaint = complaintDAO.findById(id);
        if (complaint == null) return null;

        complaint.setAttachments(attachmentDAO.findByComplaint(id));
        complaint.setStatusHistories(historyDAO.findByComplaint(id));
        complaint.setComments(commentDAO.findByComplaint(id, includeInternalComments));
        return complaint;
    }
}
