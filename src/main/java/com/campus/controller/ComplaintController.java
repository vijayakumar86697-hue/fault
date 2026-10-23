package com.campus.controller;

import com.campus.dao.BuildingDAO;
import com.campus.dao.CategoryDAO;
import com.campus.dao.ComplaintDAO;
import com.campus.model.Complaint;
import com.campus.model.ComplaintComment;
import com.campus.model.User;
import com.campus.service.ComplaintService;
import com.campus.service.StorageService;
import com.campus.util.SecurityUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * Spring MVC Controller handling student/faculty complaint reporting, ticket tracking,
 * evidence uploads, and reopen requests via ComplaintService.
 */
@Controller
@RequestMapping("/complaints")
public class ComplaintController {

    private final ComplaintService complaintService;
    private final ComplaintDAO complaintDAO;
    private final CategoryDAO categoryDAO;
    private final BuildingDAO buildingDAO;
    private final StorageService storageService;

    public ComplaintController(ComplaintService complaintService,
                               ComplaintDAO complaintDAO,
                               CategoryDAO categoryDAO,
                               BuildingDAO buildingDAO,
                               StorageService storageService) {
        this.complaintService = complaintService;
        this.complaintDAO = complaintDAO;
        this.categoryDAO = categoryDAO;
        this.buildingDAO = buildingDAO;
        this.storageService = storageService;
    }

    @GetMapping("/new")
    public String showSubmitForm(Model model) {
        model.addAttribute("categories", categoryDAO.findAllActive());
        model.addAttribute("buildings", buildingDAO.findAllActive());
        model.addAttribute("previewTicket", complaintDAO.generateTicketNumber());
        return "student/submit-complaint";
    }

    @PostMapping("/new")
    public String handleSubmitComplaint(@RequestParam("title") String title,
                                        @RequestParam("categoryId") String categoryIdStr,
                                        @RequestParam("buildingId") String buildingIdStr,
                                        @RequestParam("blockFloor") String blockFloor,
                                        @RequestParam("roomLocation") String roomLocation,
                                        @RequestParam("description") String description,
                                        @RequestParam(value = "priority", required = false, defaultValue = "MEDIUM") String priority,
                                        @RequestParam(value = "photo", required = false) MultipartFile photo,
                                        HttpServletRequest request,
                                        Model model) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            return "redirect:/auth/login";
        }

        if (title == null || title.isBlank() || description == null || description.isBlank() ||
            categoryIdStr == null || buildingIdStr == null || blockFloor == null || roomLocation == null) {
            model.addAttribute("errorMessage", "All required fields must be filled out.");
            model.addAttribute("categories", categoryDAO.findAllActive());
            model.addAttribute("buildings", buildingDAO.findAllActive());
            model.addAttribute("previewTicket", complaintDAO.generateTicketNumber());
            return "student/submit-complaint";
        }

        int categoryId = SecurityUtil.parseInt(categoryIdStr, 0);
        int buildingId = SecurityUtil.parseInt(buildingIdStr, 0);

        if (categoryId <= 0 || buildingId <= 0) {
            model.addAttribute("errorMessage", "Please select a valid fault category and campus building.");
            model.addAttribute("categories", categoryDAO.findAllActive());
            model.addAttribute("buildings", buildingDAO.findAllActive());
            model.addAttribute("previewTicket", complaintDAO.generateTicketNumber());
            return "student/submit-complaint";
        }

        Complaint complaint = new Complaint();
        complaint.setReporterId(currentUser.getId());
        complaint.setCategoryId(categoryId);
        complaint.setBuildingId(buildingId);
        complaint.setBlockFloor(blockFloor.trim());
        complaint.setRoomLocation(roomLocation.trim());
        complaint.setTitle(title.trim());
        complaint.setDescription(description.trim());
        complaint.setPriority(priority != null ? priority : "MEDIUM");

        boolean created = complaintService.submitComplaint(complaint, photo, storageService.getUploadDirectory());
        if (!created) {
            model.addAttribute("errorMessage", "Could not submit complaint due to a server error. Please try again.");
            model.addAttribute("categories", categoryDAO.findAllActive());
            model.addAttribute("buildings", buildingDAO.findAllActive());
            model.addAttribute("previewTicket", complaintDAO.generateTicketNumber());
            return "student/submit-complaint";
        }

        return "redirect:/complaints/view?id=" + complaint.getId() + "&success=submitted";
    }

    @GetMapping("/view")
    public String viewComplaintDetail(@RequestParam(value = "id", required = false) String idStr,
                                      @RequestParam(value = "ticket", required = false) String ticket,
                                      HttpServletRequest request,
                                      Model model) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        Complaint complaint = null;
        if (idStr != null && !idStr.isBlank()) {
            int compId = SecurityUtil.parseInt(idStr, 0);
            complaint = complaintService.getComplaintWithDetails(compId, currentUser.isAdmin() || currentUser.isWorker());
        } else if (ticket != null && !ticket.isBlank()) {
            Complaint found = complaintDAO.findByTicketNumber(ticket);
            if (found != null) {
                complaint = complaintService.getComplaintWithDetails(found.getId(), currentUser.isAdmin() || currentUser.isWorker());
            }
        }

        if (complaint == null) {
            model.addAttribute("errorMessage", "Complaint not found.");
            return "error/404";
        }

        // RBAC Check: Normal students/faculty can only view their own complaint details
        if (currentUser.isStudentOrFaculty() && complaint.getReporterId() != currentUser.getId()) {
            model.addAttribute("errorMessage", "Access Denied: You do not have permission to view this complaint.");
            return "error/403";
        }

        model.addAttribute("complaint", complaint);
        return "student/complaint-detail";
    }

    @GetMapping("/my")
    public String showMyComplaints(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        List<Complaint> myComplaints = complaintDAO.findByReporter(currentUser.getId());
        model.addAttribute("complaints", myComplaints);
        model.addAttribute("stats", complaintDAO.getUserStats(currentUser.getId()));
        return "student/my-complaints";
    }

    @PostMapping("/comment")
    public String handleAddComment(@RequestParam("complaintId") int complaintId,
                                   @RequestParam("commentText") String commentText,
                                   @RequestParam(value = "isInternal", required = false) String isInternalStr,
                                   HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        boolean isInternal = "true".equalsIgnoreCase(isInternalStr) && (currentUser.isAdmin() || currentUser.isWorker());

        if (complaintId > 0 && commentText != null && !commentText.isBlank()) {
            ComplaintComment comment = new ComplaintComment(complaintId, currentUser.getId(), commentText.trim(), isInternal);
            complaintService.addComment(comment);
        }

        return "redirect:/complaints/view?id=" + complaintId + "#comments";
    }

    @PostMapping("/reopen")
    public String handleReopenComplaint(@RequestParam("complaintId") int complaintId,
                                        @RequestParam("reopenReason") String reason,
                                        HttpServletRequest request) {

        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");

        if (complaintId > 0 && reason != null && !reason.isBlank()) {
            Complaint c = complaintDAO.findById(complaintId);
            if (c != null && (c.getReporterId() == currentUser.getId() || currentUser.isAdmin())) {
                complaintService.reopenComplaint(complaintId, reason.trim(), currentUser.getId());
            }
        }

        return "redirect:/complaints/view?id=" + complaintId + "&success=reopened";
    }
}
