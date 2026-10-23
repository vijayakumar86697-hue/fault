package com.campus.controller;

import com.campus.dao.ComplaintDAO;
import com.campus.model.Complaint;
import com.campus.model.User;
import com.campus.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Spring MVC Controller routing users to their role-specific analytics and dashboards.
 */
@Controller
public class DashboardController {

    private final ComplaintDAO complaintDAO;
    private final UserService userService;

    public DashboardController(ComplaintDAO complaintDAO, UserService userService) {
        this.complaintDAO = complaintDAO;
        this.userService = userService;
    }

    @GetMapping("/dashboard")
    public String handleDashboardRouting(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            return "redirect:/auth/login";
        }

        if (user.isAdmin()) {
            return "redirect:/admin/dashboard";
        } else if (user.isWorker()) {
            return "redirect:/worker/dashboard";
        } else {
            return "redirect:/student/dashboard";
        }
    }

    @GetMapping("/admin/dashboard")
    public String showAdminDashboard(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null || !user.isAdmin()) {
            return "redirect:/auth/login";
        }

        Map<String, Object> stats = complaintDAO.getDashboardStats();
        model.addAttribute("stats", stats);

        Map<String, Object> filters = new HashMap<>();
        List<Complaint> recentComplaints = complaintDAO.findFiltered(filters, 0, 6);
        model.addAttribute("recentComplaints", recentComplaints);

        Map<String, Object> critFilters = new HashMap<>();
        critFilters.put("priority", "CRITICAL");
        List<Complaint> criticalComplaints = complaintDAO.findFiltered(critFilters, 0, 5);
        model.addAttribute("criticalComplaints", criticalComplaints);

        model.addAttribute("categoryStats", complaintDAO.getCategoryDistribution());
        model.addAttribute("locationStats", complaintDAO.getLocationDistribution());
        model.addAttribute("workers", userService.findAllWorkers());

        return "admin/dashboard";
    }

    @GetMapping("/worker/dashboard")
    public String showWorkerDashboard(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        User worker = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (worker == null || !worker.isWorker()) {
            return "redirect:/auth/login";
        }

        Map<String, Object> stats = complaintDAO.getWorkerStats(worker.getId());
        model.addAttribute("stats", stats);

        List<Complaint> assignedTasks = complaintDAO.findByWorker(worker.getId(), null);
        model.addAttribute("assignedTasks", assignedTasks);

        return "worker/dashboard";
    }

    @GetMapping("/student/dashboard")
    public String showStudentDashboard(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
        if (user == null) {
            return "redirect:/auth/login";
        }

        Map<String, Object> stats = complaintDAO.getUserStats(user.getId());
        model.addAttribute("stats", stats);

        List<Complaint> myComplaints = complaintDAO.findByReporter(user.getId());
        model.addAttribute("myComplaints", myComplaints);

        return "student/dashboard";
    }
}
