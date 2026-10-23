package com.campus.controller;

import com.campus.dao.*;
import com.campus.model.Complaint;
import com.campus.model.User;
import com.campus.service.ComplaintService;
import com.campus.service.UserService;
import com.campus.util.SecurityUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Spring MVC Controller for administrator complaint triage, assignment, priority, and staff management.
 */
@Controller
@RequestMapping("/admin")
public class AdminComplaintController {

    private final ComplaintService complaintService;
    private final ComplaintDAO complaintDAO;
    private final CategoryDAO categoryDAO;
    private final BuildingDAO buildingDAO;
    private final UserService userService;
    private final AssignmentDAO assignmentDAO;

    public AdminComplaintController(ComplaintService complaintService,
                                    ComplaintDAO complaintDAO,
                                    CategoryDAO categoryDAO,
                                    BuildingDAO buildingDAO,
                                    UserService userService,
                                    AssignmentDAO assignmentDAO) {
        this.complaintService = complaintService;
        this.complaintDAO = complaintDAO;
        this.categoryDAO = categoryDAO;
        this.buildingDAO = buildingDAO;
        this.userService = userService;
        this.assignmentDAO = assignmentDAO;
    }

    @GetMapping({"/complaints", "/complaints/list"})
    public String handleComplaintsList(@RequestParam(value = "search", required = false) String search,
                                       @RequestParam(value = "status", required = false) String status,
                                       @RequestParam(value = "priority", required = false) String priority,
                                       @RequestParam(value = "categoryId", required = false) String catStr,
                                       @RequestParam(value = "buildingId", required = false) String bldgStr,
                                       @RequestParam(value = "page", defaultValue = "1") int page,
                                       Model model) {

        int categoryId = SecurityUtil.parseInt(catStr, 0);
        int buildingId = SecurityUtil.parseInt(bldgStr, 0);
        int pageSize = 12;
        int offset = (page - 1) * pageSize;

        Map<String, Object> filters = new HashMap<>();
        if (search != null && !search.isBlank()) filters.put("search", search);
        if (status != null && !status.isBlank()) filters.put("status", status);
        if (priority != null && !priority.isBlank()) filters.put("priority", priority);
        if (categoryId > 0) filters.put("categoryId", categoryId);
        if (buildingId > 0) filters.put("buildingId", buildingId);

        List<Complaint> complaints = complaintDAO.findFiltered(filters, offset, pageSize);
        int totalCount = complaintDAO.countFiltered(filters);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        model.addAttribute("complaints", complaints);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);

        model.addAttribute("categories", categoryDAO.findAll());
        model.addAttribute("buildings", buildingDAO.findAll());
        model.addAttribute("workers", userService.findAllWorkers());

        return "admin/complaints-list";
    }

    @GetMapping("/complaints/view")
    public String handleViewComplaint(@RequestParam("id") int id, Model model) {
        Complaint complaint = complaintService.getComplaintWithDetails(id, true);
        if (complaint == null) {
            model.addAttribute("errorMessage", "Complaint not found.");
            return "error/404";
        }

        model.addAttribute("complaint", complaint);
        model.addAttribute("activeAssignment", assignmentDAO.findActiveByComplaint(id));
        model.addAttribute("assignmentHistory", assignmentDAO.findHistoryByComplaint(id));
        model.addAttribute("workers", userService.findAllWorkers());

        return "admin/complaint-detail";
    }

    @PostMapping("/complaints/assign")
    public String handleAssignWorker(@RequestParam("complaintId") int complaintId,
                                     @RequestParam("workerId") int workerId,
                                     @RequestParam(value = "instructions", required = false) String instructions,
                                     @RequestParam(value = "expectedCompletion", required = false) String dateStr,
                                     HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        Date expectedDate = null;
        if (dateStr != null && !dateStr.isBlank()) {
            try {
                expectedDate = Date.valueOf(dateStr);
            } catch (Exception ignored) {}
        }

        if (complaintId > 0 && workerId > 0) {
            complaintService.assignWorker(complaintId, workerId, currentUser.getId(), instructions, expectedDate);
        }

        return "redirect:/admin/complaints/view?id=" + complaintId + "&success=assigned";
    }

    @PostMapping("/complaints/status")
    public String handleUpdateStatus(@RequestParam("complaintId") int complaintId,
                                     @RequestParam("newStatus") String newStatus,
                                     @RequestParam(value = "remarks", required = false) String remarks,
                                     HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (complaintId > 0 && newStatus != null && !newStatus.isBlank()) {
            complaintService.updateStatus(complaintId, newStatus.toUpperCase(), remarks, currentUser.getId());
        }

        return "redirect:/admin/complaints/view?id=" + complaintId + "&success=status_updated";
    }

    @PostMapping("/complaints/priority")
    public String handleUpdatePriority(@RequestParam("complaintId") int complaintId,
                                       @RequestParam("newPriority") String newPriority,
                                       HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (complaintId > 0 && newPriority != null && !newPriority.isBlank()) {
            complaintService.updatePriority(complaintId, newPriority.toUpperCase(), currentUser.getId());
        }

        return "redirect:/admin/complaints/view?id=" + complaintId + "&success=priority_updated";
    }

    @PostMapping("/complaints/comment")
    public String handleAdminComment(@RequestParam("complaintId") int complaintId,
                                     @RequestParam("commentText") String text,
                                     @RequestParam(value = "isInternal", defaultValue = "false") boolean isInternal,
                                     HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (complaintId > 0 && text != null && !text.isBlank()) {
            com.campus.model.ComplaintComment comment = new com.campus.model.ComplaintComment(
                complaintId,
                currentUser.getId(),
                text.trim(),
                isInternal
            );
            complaintService.addComment(comment);
        }

        return "redirect:/admin/complaints/view?id=" + complaintId + "#comments";
    }
}
