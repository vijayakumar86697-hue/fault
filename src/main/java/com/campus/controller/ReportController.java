package com.campus.controller;

import com.campus.dao.BuildingDAO;
import com.campus.dao.CategoryDAO;
import com.campus.dao.ComplaintDAO;
import com.campus.model.Complaint;
import com.campus.util.DateUtil;
import com.campus.util.SecurityUtil;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Spring MVC Controller for administrative reports, interactive analytics, and CSV data export.
 */
@Controller
@RequestMapping("/admin/reports")
public class ReportController {

    private final ComplaintDAO complaintDAO;
    private final CategoryDAO categoryDAO;
    private final BuildingDAO buildingDAO;

    public ReportController(ComplaintDAO complaintDAO, CategoryDAO categoryDAO, BuildingDAO buildingDAO) {
        this.complaintDAO = complaintDAO;
        this.categoryDAO = categoryDAO;
        this.buildingDAO = buildingDAO;
    }

    @GetMapping({"", "/", "/view"})
    public String handleViewReports(@RequestParam(value = "startDate", required = false) String startDate,
                                    @RequestParam(value = "endDate", required = false) String endDate,
                                    @RequestParam(value = "categoryId", required = false) String categoryIdStr,
                                    @RequestParam(value = "buildingId", required = false) String buildingIdStr,
                                    @RequestParam(value = "status", required = false) String status,
                                    @RequestParam(value = "priority", required = false) String priority,
                                    Model model) {

        int categoryId = SecurityUtil.parseInt(categoryIdStr, 0);
        int buildingId = SecurityUtil.parseInt(buildingIdStr, 0);

        Map<String, Object> filters = new HashMap<>();
        if (startDate != null && !startDate.isBlank()) filters.put("startDate", startDate);
        if (endDate != null && !endDate.isBlank()) filters.put("endDate", endDate);
        if (categoryId > 0) filters.put("categoryId", categoryId);
        if (buildingId > 0) filters.put("buildingId", buildingId);
        if (status != null && !status.isBlank()) filters.put("status", status);
        if (priority != null && !priority.isBlank()) filters.put("priority", priority);

        List<Complaint> complaints = complaintDAO.findFiltered(filters, 0, 500);
        Map<String, Object> stats = complaintDAO.getDashboardStats();

        model.addAttribute("complaints", complaints);
        model.addAttribute("stats", stats);
        model.addAttribute("categories", categoryDAO.findAll());
        model.addAttribute("buildings", buildingDAO.findAll());
        model.addAttribute("categoryDistribution", complaintDAO.getCategoryDistribution());
        model.addAttribute("locationDistribution", complaintDAO.getLocationDistribution());

        return "admin/reports";
    }

    @GetMapping("/chart-data")
    @ResponseBody
    public Map<String, Object> handleChartDataJson() {
        Map<String, Object> chartData = new HashMap<>();
        chartData.put("categories", complaintDAO.getCategoryDistribution());
        chartData.put("locations", complaintDAO.getLocationDistribution());
        chartData.put("stats", complaintDAO.getDashboardStats());
        return chartData;
    }

    @GetMapping("/export")
    public void handleExportCsv(@RequestParam(value = "startDate", required = false) String startDate,
                                @RequestParam(value = "endDate", required = false) String endDate,
                                @RequestParam(value = "categoryId", required = false) String categoryIdStr,
                                @RequestParam(value = "buildingId", required = false) String buildingIdStr,
                                @RequestParam(value = "status", required = false) String status,
                                @RequestParam(value = "priority", required = false) String priority,
                                HttpServletResponse response) throws IOException {

        Map<String, Object> filters = new HashMap<>();
        if (startDate != null && !startDate.isBlank()) filters.put("startDate", startDate);
        if (endDate != null && !endDate.isBlank()) filters.put("endDate", endDate);
        if (categoryIdStr != null) filters.put("categoryId", SecurityUtil.parseInt(categoryIdStr, 0));
        if (buildingIdStr != null) filters.put("buildingId", SecurityUtil.parseInt(buildingIdStr, 0));
        if (status != null && !status.isBlank()) filters.put("status", status);
        if (priority != null && !priority.isBlank()) filters.put("priority", priority);

        List<Complaint> list = complaintDAO.findFiltered(filters, 0, 5000);

        String filename = "campus_faults_export_" + new SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".csv";
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        PrintWriter writer = response.getWriter();
        writer.write('\ufeff'); // UTF-8 BOM

        writer.println("Ticket Number,Title,Category,Building,Block/Floor,Location,Priority,Status,Reporter Name,Reporter Role,Submitted Date,Resolved Date,Assigned Worker");

        for (Complaint c : list) {
            StringBuilder sb = new StringBuilder();
            escapeCsv(sb, c.getTicketNumber());
            sb.append(",");
            escapeCsv(sb, c.getTitle());
            sb.append(",");
            escapeCsv(sb, c.getCategoryName());
            sb.append(",");
            escapeCsv(sb, c.getBuildingName());
            sb.append(",");
            escapeCsv(sb, c.getBlockFloor());
            sb.append(",");
            escapeCsv(sb, c.getRoomLocation());
            sb.append(",");
            escapeCsv(sb, c.getPriority());
            sb.append(",");
            escapeCsv(sb, c.getStatus());
            sb.append(",");
            escapeCsv(sb, c.getReporterName());
            sb.append(",");
            escapeCsv(sb, c.getReporterRole());
            sb.append(",");
            escapeCsv(sb, DateUtil.formatDateTime(c.getSubmittedAt()));
            sb.append(",");
            escapeCsv(sb, c.getResolvedAt() != null ? DateUtil.formatDateTime(c.getResolvedAt()) : "Pending");
            sb.append(",");
            escapeCsv(sb, c.getAssignedWorkerName() != null ? c.getAssignedWorkerName() : "Unassigned");

            writer.println(sb.toString());
        }

        writer.flush();
    }

    private void escapeCsv(StringBuilder sb, String text) {
        if (text == null) {
            sb.append("\"\"");
            return;
        }
        sb.append("\"").append(text.replace("\"", "\"\"")).append("\"");
    }
}
