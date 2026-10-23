package com.campus.service;

import com.campus.dao.UserDAO;
import com.campus.model.User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Spring Service managing user authentication, registration, and directory queries.
 */
@Service
public class UserService {

    private final UserDAO userDAO;

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public User authenticate(String usernameOrEmail, String plainPassword) {
        if (usernameOrEmail == null || usernameOrEmail.isBlank() || plainPassword == null || plainPassword.isBlank()) {
            return null;
        }
        return userDAO.authenticate(usernameOrEmail.trim(), plainPassword);
    }

    @Transactional
    public boolean register(User user, String plainPassword) {
        if (user == null || plainPassword == null || plainPassword.isBlank()) {
            return false;
        }
        // Verify unique username and email
        if (userDAO.findByUsername(user.getUsername()) != null || userDAO.findByEmail(user.getEmail()) != null) {
            return false;
        }
        return userDAO.register(user, plainPassword);
    }

    public User findById(int id) {
        return userDAO.findById(id);
    }

    public User findByUsername(String username) {
        return userDAO.findByUsername(username);
    }

    public List<User> findAllWorkers() {
        return userDAO.findAllWorkers();
    }

    public List<User> findAll(String roleFilter) {
        return userDAO.findAll(roleFilter);
    }

    @Transactional
    public boolean updateStatus(int userId, String status) {
        return userDAO.updateStatus(userId, status);
    }
}
