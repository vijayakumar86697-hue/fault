package com.campus.controller;

import com.campus.dao.*;
import com.campus.model.Complaint;
import com.campus.model.User;
import com.campus.service.ComplaintService;
import com.campus.service.StorageService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * Spring MVC Controller for maintenance technicians to manage task queues,
 * update progress statuses, record work notes, and submit resolution photo proof.
 */
@Controller
@RequestMapping("/worker/tasks")
public class WorkerComplaintController {

    private final ComplaintService complaintService;
    private final ComplaintDAO complaintDAO;
    private final AssignmentDAO assignmentDAO;
    private final StorageService storageService;

    public WorkerComplaintController(ComplaintService complaintService,
                                     ComplaintDAO complaintDAO,
                                     AssignmentDAO assignmentDAO,
                                     StorageService storageService) {
        this.complaintService = complaintService;
        this.complaintDAO = complaintDAO;
        this.assignmentDAO = assignmentDAO;
        this.storageService = storageService;
    }

    @GetMapping({"", "/", "/list"})
    public String handleTaskList(@RequestParam(value = "status", required = false) String statusFilter,
                                 HttpServletRequest request,
                                 Model model) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        List<Complaint> tasks = complaintDAO.findByWorker(currentUser.getId(), statusFilter);

        model.addAttribute("tasks", tasks);
        model.addAttribute("selectedStatus", statusFilter);
        model.addAttribute("stats", complaintDAO.getWorkerStats(currentUser.getId()));

        return "worker/my-tasks";
    }

    @GetMapping("/view")
    public String handleViewTask(@RequestParam("id") int id,
                                 HttpServletRequest request,
                                 Model model) {

        Complaint complaint = complaintService.getComplaintWithDetails(id, true);
        if (complaint == null) {
            model.addAttribute("errorMessage", "Assigned task not found.");
            return "error/404";
        }

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (!currentUser.isAdmin() && (complaint.getAssignedWorkerId() == null || complaint.getAssignedWorkerId() != currentUser.getId())) {
            model.addAttribute("errorMessage", "Access Denied: This task is not assigned to you.");
            return "error/403";
        }

        model.addAttribute("complaint", complaint);
        model.addAttribute("activeAssignment", assignmentDAO.findActiveByComplaint(id));

        return "worker/task-detail";
    }

    @PostMapping("/status")
    public String handleUpdateTaskStatus(@RequestParam("complaintId") int complaintId,
                                         @RequestParam("newStatus") String newStatus,
                                         @RequestParam(value = "remarks", required = false) String remarks,
                                         @RequestParam(value = "afterPhoto", required = false) MultipartFile afterPhoto,
                                         HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (complaintId <= 0 || newStatus == null || newStatus.isBlank()) {
            return "redirect:/worker/tasks";
        }

        if ("COMPLETED".equalsIgnoreCase(newStatus)) {
            complaintService.completeTask(complaintId, currentUser.getId(), remarks, afterPhoto, storageService.getUploadDirectory());
        } else {
            if (remarks != null && !remarks.isBlank()) {
                com.campus.model.ComplaintComment comment = new com.campus.model.ComplaintComment(
                    complaintId,
                    currentUser.getId(),
                    "Worker note (" + newStatus + "): " + remarks.trim(),
                    false
                );
                complaintService.addComment(comment);
            }
            complaintService.updateStatus(complaintId, newStatus.toUpperCase(), remarks, currentUser.getId());
        }

        return "redirect:/worker/tasks/view?id=" + complaintId + "&success=task_updated";
    }
}
