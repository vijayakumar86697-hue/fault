package com.campus.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Global Spring MVC Exception Handler providing centralized exception handling,
 * friendly user notifications, and security error masking.
 */
@ControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger LOGGER = Logger.getLogger(GlobalExceptionHandler.class.getName());

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public String handleMaxSizeException(MaxUploadSizeExceededException exc, HttpServletRequest request, Model model) {
        LOGGER.log(Level.WARNING, "File upload size exceeded limit", exc);
        model.addAttribute("errorMessage", "The uploaded file exceeds the maximum allowed file size (10MB). Please choose a smaller file.");
        return "error";
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public String handleIllegalArgument(IllegalArgumentException exc, HttpServletRequest request, Model model) {
        LOGGER.log(Level.WARNING, "Illegal argument error: " + exc.getMessage());
        model.addAttribute("errorMessage", exc.getMessage());
        return "error";
    }

    @ExceptionHandler(Exception.class)
    public String handleGeneralException(Exception exc, HttpServletRequest request, Model model) {
        LOGGER.log(Level.SEVERE, "Unhandled exception processing request: " + request.getRequestURI(), exc);
        model.addAttribute("errorMessage", "An unexpected error occurred while processing your request. Please try again later.");
        return "error";
    }
}
