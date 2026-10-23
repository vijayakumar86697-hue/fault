package com.campus.controller;

import com.campus.dao.BuildingDAO;
import com.campus.model.Building;
import com.campus.util.SecurityUtil;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Spring MVC Controller for administrator campus buildings and facilities management.
 */
@Controller
@RequestMapping("/admin/buildings")
public class BuildingController {

    private final BuildingDAO buildingDAO;

    public BuildingController(BuildingDAO buildingDAO) {
        this.buildingDAO = buildingDAO;
    }

    @GetMapping({"", "/", "/list"})
    public String showBuildings(Model model) {
        List<Building> buildings = buildingDAO.findAll();
        model.addAttribute("buildings", buildings);
        return "admin/buildings";
    }

    @PostMapping({"", "/", "/save"})
    public String handleSaveBuilding(@RequestParam(value = "action", required = false, defaultValue = "save") String action,
                                     @RequestParam(value = "id", defaultValue = "0") int id,
                                     @RequestParam(value = "name", required = false) String name,
                                     @RequestParam(value = "code", required = false) String code,
                                     @RequestParam(value = "floors", defaultValue = "4") int floors,
                                     @RequestParam(value = "description", required = false) String description,
                                     @RequestParam(value = "active", required = false) String activeStr) {

        boolean active = "true".equalsIgnoreCase(activeStr);

        if ("toggle".equalsIgnoreCase(action)) {
            buildingDAO.toggleActive(id, active);
        } else if ("save".equalsIgnoreCase(action)) {
            if (name != null && !name.isBlank() && code != null && !code.isBlank()) {
                Building b = new Building(id, name.trim(), code.trim().toUpperCase(), floors, description, active);
                if (id > 0) {
                    buildingDAO.update(b);
                } else {
                    buildingDAO.create(b);
                }
            }
        }

        return "redirect:/admin/buildings?success=updated";
    }
}
