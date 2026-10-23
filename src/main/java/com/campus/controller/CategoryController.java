package com.campus.controller;

import com.campus.dao.CategoryDAO;
import com.campus.model.FaultCategory;
import com.campus.util.SecurityUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Spring MVC Controller for administrator fault category management.
 */
@Controller
@RequestMapping("/admin/categories")
public class CategoryController {

    private final CategoryDAO categoryDAO;

    public CategoryController(CategoryDAO categoryDAO) {
        this.categoryDAO = categoryDAO;
    }

    @GetMapping({"", "/", "/list"})
    public String showCategories(Model model) {
        List<FaultCategory> categories = categoryDAO.findAll();
        model.addAttribute("categories", categories);
        return "admin/categories";
    }

    @PostMapping({"", "/", "/save"})
    public String handleSaveCategory(@RequestParam(value = "action", required = false, defaultValue = "save") String action,
                                     @RequestParam(value = "id", defaultValue = "0") int id,
                                     @RequestParam(value = "name", required = false) String name,
                                     @RequestParam(value = "icon", required = false) String icon,
                                     @RequestParam(value = "description", required = false) String description,
                                     @RequestParam(value = "defaultPriority", required = false, defaultValue = "MEDIUM") String defaultPriority,
                                     @RequestParam(value = "active", required = false) String activeStr) {

        boolean active = "true".equalsIgnoreCase(activeStr);

        if ("toggle".equalsIgnoreCase(action)) {
            categoryDAO.toggleActive(id, active);
        } else if ("save".equalsIgnoreCase(action)) {
            if (name != null && !name.isBlank()) {
                FaultCategory cat = new FaultCategory(id, name.trim(), icon, description, defaultPriority, active);
                if (id > 0) {
                    categoryDAO.update(cat);
                } else {
                    categoryDAO.create(cat);
                }
            }
        }

        return "redirect:/admin/categories?success=updated";
    }
}
