package com.campus.controller;

import com.campus.model.User;
import com.campus.service.NotificationService;
import com.campus.service.UserService;
import com.campus.util.SecurityUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Spring MVC Controller handling authentication, registration, session management, and logout.
 */
@Controller
@RequestMapping("/auth")
public class AuthController {

    private final UserService userService;
    private final NotificationService notificationService;

    public AuthController(UserService userService, NotificationService notificationService) {
        this.userService = userService;
        this.notificationService = notificationService;
    }

    @GetMapping("/login")
    public String showLoginPage(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            return "redirect:/dashboard";
        }
        return "auth/login";
    }

    @PostMapping("/login")
    public String handleLogin(@RequestParam(value = "username", required = false) String username,
                              @RequestParam(value = "password", required = false) String password,
                              @RequestParam(value = "redirect", required = false) String redirect,
                              HttpServletRequest request,
                              Model model) {
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            model.addAttribute("errorMessage", "Please provide both username and password.");
            return "auth/login";
        }

        User user = userService.authenticate(username.trim(), password);
        if (user == null) {
            model.addAttribute("errorMessage", "Invalid username or password. Please verify your credentials.");
            return "auth/login";
        }

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            model.addAttribute("errorMessage", "Your account has been deactivated. Please contact campus administration.");
            return "auth/login";
        }

        // Establish secure session
        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);
        session.setAttribute("user", user);

        int unread = notificationService.getUnreadCount(user.getId());
        session.setAttribute("unreadCount", unread);

        if (redirect != null && !redirect.isBlank() && !redirect.contains("://")) {
            return "redirect:" + redirect;
        }
        return "redirect:/dashboard";
    }

    @GetMapping("/register")
    public String showRegisterPage() {
        return "auth/register";
    }

    @PostMapping("/register")
    public String handleRegister(@RequestParam(value = "username", required = false) String username,
                                 @RequestParam(value = "fullName", required = false) String fullName,
                                 @RequestParam(value = "email", required = false) String email,
                                 @RequestParam(value = "phone", required = false) String phone,
                                 @RequestParam(value = "role", required = false) String role,
                                 @RequestParam(value = "department", required = false) String department,
                                 @RequestParam(value = "password", required = false) String password,
                                 @RequestParam(value = "confirmPassword", required = false) String confirmPassword,
                                 Model model) {

        if (username == null || !SecurityUtil.isValidUsername(username)) {
            model.addAttribute("errorMessage", "Username must be 3-30 alphanumeric characters or underscores.");
            return "auth/register";
        }

        if (email == null || !SecurityUtil.isValidEmail(email)) {
            model.addAttribute("errorMessage", "Please enter a valid campus email address.");
            return "auth/register";
        }

        if (password == null || password.length() < 6) {
            model.addAttribute("errorMessage", "Password must be at least 6 characters long.");
            return "auth/register";
        }

        if (!password.equals(confirmPassword)) {
            model.addAttribute("errorMessage", "Passwords do not match.");
            return "auth/register";
        }

        if (fullName == null || fullName.trim().isEmpty()) {
            model.addAttribute("errorMessage", "Full name is required.");
            return "auth/register";
        }

        String validRole = ("FACULTY".equalsIgnoreCase(role)) ? "FACULTY" : "STUDENT";

        User newUser = new User();
        newUser.setUsername(username.trim());
        newUser.setFullName(fullName.trim());
        newUser.setEmail(email.trim());
        newUser.setPhone(phone != null ? phone.trim() : null);
        newUser.setRole(validRole);
        newUser.setDepartment(department != null ? department.trim() : null);
        newUser.setStatus("ACTIVE");

        boolean created = userService.register(newUser, password);
        if (created) {
            return "redirect:/auth/login?registered=true";
        } else {
            model.addAttribute("errorMessage", "Registration failed: Username or email might already be taken.");
            return "auth/register";
        }
    }

    @GetMapping("/logout")
    public String handleLogout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/auth/login?loggedOut=true";
    }
}
